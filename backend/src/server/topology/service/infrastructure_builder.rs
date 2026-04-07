use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use super::{
    context::TopologyContext,
    edge_builder::EdgeBuilder,
    element_rules::{ElementMatchData, apply_element_rules_with_titles},
    view::ViewBuilder,
};
use crate::server::{
    hosts::r#impl::virtualization::HostVirtualization,
    if_entries::r#impl::base::Neighbor,
    services::r#impl::{definitions::ServiceDefinitionExt, virtualization::ServiceVirtualization},
    topology::types::{
        edges::{DiscoveryProtocol, Edge, EdgeHandle, EdgeType, EdgeViewConfig},
        grouping::GroupingConfig,
        nodes::{ContainerType, ElementEntityType, Node, NodeType},
    },
};

/// Sentinel container_id for elements in the flat view (before element rules group them).
const FLAT_ROOT_ID: Uuid = Uuid::from_bytes([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02,
]);

pub struct InfrastructureBuilder;

impl InfrastructureBuilder {
    /// Resolve which virtualizer host manages a given host.
    ///
    /// - Proxmox VM: host.virtualization.Proxmox.service_id → service.host_id
    /// - Docker: any service on this host with Docker virtualization → daemon service.host_id
    ///   (but only if the daemon host is a DIFFERENT host — same-host Docker doesn't make
    ///   the host "virtualized by" itself)
    fn resolve_virtualizer_host_id(host_id: Uuid, ctx: &TopologyContext) -> Option<Uuid> {
        let host = ctx.get_host_by_id(host_id)?;

        // Proxmox VM: host is virtualized by the hypervisor host
        if let Some(HostVirtualization::Proxmox(pv)) = &host.base.virtualization
            && let Some(service) = ctx.services.iter().find(|s| s.id == pv.service_id)
        {
            return Some(service.base.host_id);
        }

        None
    }

    /// Resolve the compose_project for a host from its Docker services.
    /// Returns Some only if all Docker services on the host share one compose_project.
    fn resolve_compose_project(host_id: Uuid, ctx: &TopologyContext) -> Option<String> {
        let mut projects: HashSet<&str> = HashSet::new();
        for service in ctx.services.iter().filter(|s| s.base.host_id == host_id) {
            if let Some(ServiceVirtualization::Docker(dv)) = &service.base.virtualization
                && let Some(ref project) = dv.compose_project
            {
                projects.insert(project.as_str());
            }
        }
        if projects.len() == 1 {
            projects.into_iter().next().map(String::from)
        } else {
            None
        }
    }

    /// Set `associated_service_definition` on Virtualizer and Stack subcontainers.
    ///
    /// For Virtualizer: looks up the virtualizing service (manages_virtualization) on the
    /// virtualizer host and uses its name. For Stack: always Docker.
    fn set_subcontainer_service_definitions(
        nodes: &mut [Node],
        virtualizer_map: &HashMap<Uuid, Option<Uuid>>,
        ctx: &TopologyContext,
    ) {
        // Build virtualizer_host_id → service definition name
        let virt_svc_defs: HashMap<Uuid, String> = ctx
            .services
            .iter()
            .filter(|s| s.base.service_definition.manages_virtualization().is_some())
            .map(|s| (s.base.host_id, s.base.service_definition.name().to_string()))
            .collect();

        // First pass: collect container_id → any child's host_id (for Virtualizer lookup)
        let container_to_child_host: HashMap<Uuid, Uuid> = nodes
            .iter()
            .filter_map(|n| {
                if let NodeType::Element {
                    container_id,
                    host_id,
                    ..
                } = &n.node_type
                {
                    Some((*container_id, *host_id))
                } else {
                    None
                }
            })
            .collect();

        // Second pass: set associated_service_definition on matching containers
        for node in nodes.iter_mut() {
            match &mut node.node_type {
                NodeType::Container {
                    container_type: ContainerType::Virtualizer,
                    associated_service_definition,
                    ..
                } => {
                    if let Some(&child_host_id) = container_to_child_host.get(&node.id)
                        && let Some(&Some(vid)) = virtualizer_map.get(&child_host_id)
                        && let Some(svc_def) = virt_svc_defs.get(&vid)
                    {
                        *associated_service_definition = Some(svc_def.clone());
                    }
                }
                NodeType::Container {
                    container_type: ContainerType::Stack,
                    associated_service_definition,
                    ..
                } => {
                    *associated_service_definition = Some("Docker".to_string());
                }
                _ => {}
            }
        }
    }

    /// Build a map of virtualizer_host_id → hostname for subcontainer titles.
    fn build_virtualizer_titles(
        virtualizer_host_ids: &HashSet<Uuid>,
        ctx: &TopologyContext,
    ) -> HashMap<Uuid, String> {
        virtualizer_host_ids
            .iter()
            .filter_map(|&vid| ctx.get_host_by_id(vid).map(|h| (vid, h.base.name.clone())))
            .collect()
    }
}

impl ViewBuilder for InfrastructureBuilder {
    fn build(&self, ctx: &TopologyContext, grouping: &GroupingConfig) -> (Vec<Node>, Vec<Edge>) {
        let mut nodes = Vec::new();
        let mut edges = Vec::new();

        // Root container — all host elements live here; element rules create subcontainers inside it
        nodes.push(Node {
            id: FLAT_ROOT_ID,
            node_type: NodeType::Container {
                container_type: ContainerType::Root,
                parent_container_id: None,
                layer_hint: None,
                icon: None,
                color: None,
                associated_service_definition: None,
            },
            position: Default::default(),
            size: Default::default(),
            header: None,
            element_rule_id: None,
            will_accept_edges: false,
        });

        // Pre-compute virtualizer_host_id for each host
        let virtualizer_map: HashMap<Uuid, Option<Uuid>> = ctx
            .hosts
            .iter()
            .map(|h| (h.id, Self::resolve_virtualizer_host_id(h.id, ctx)))
            .collect();

        // Collect all unique virtualizer host IDs for title lookup
        let virtualizer_host_ids: HashSet<Uuid> =
            virtualizer_map.values().filter_map(|v| *v).collect();
        let virtualizer_titles = Self::build_virtualizer_titles(&virtualizer_host_ids, ctx);

        // All hosts become Host {} elements in a flat view
        for host in ctx.hosts {
            let mut node =
                Node::element(host.id, FLAT_ROOT_ID, host.id, ElementEntityType::Host {});
            node.header = Some(host.base.name.clone());
            nodes.push(node);
        }

        // Apply element rules (ByVirtualizer creates subcontainers)
        let host_lookup: HashMap<Uuid, &crate::server::hosts::r#impl::base::Host> =
            ctx.hosts.iter().map(|h| (h.id, h)).collect();
        apply_element_rules_with_titles(
            &mut nodes,
            &grouping.element_rules,
            |node| {
                if let NodeType::Element { host_id, .. } = &node.node_type {
                    let host = host_lookup.get(host_id)?;
                    let categories = ctx
                        .services
                        .iter()
                        .filter(|s| s.base.host_id == *host_id)
                        .map(|s| s.base.service_definition.category())
                        .collect();
                    let tag_ids: HashSet<Uuid> = host.base.tags.iter().copied().collect();
                    let compose_project = Self::resolve_compose_project(*host_id, ctx);
                    Some(ElementMatchData {
                        categories,
                        tag_ids,
                        virtualizer_host_id: virtualizer_map.get(host_id).copied().flatten(),
                        compose_project,
                        native_vlan_id: None,
                        is_trunk_port: false,
                        oper_status: None,
                    })
                } else {
                    None
                }
            },
            Some(&virtualizer_titles),
        );

        // Post-process: set associated_service_definition on Virtualizer/Stack subcontainers
        Self::set_subcontainer_service_definitions(&mut nodes, &virtualizer_map, ctx);

        // HostVirtualization edges — connect hypervisor hosts to their VMs
        edges.extend(EdgeBuilder::create_vm_host_edges_by_host(ctx));

        // PhysicalLink overlay edges — connect hosts based on LLDP/CDP neighbor data.
        // Track processed pairs to avoid duplicate edges (A→B and B→A from bidirectional LLDP).
        let mut processed_pairs: HashSet<(Uuid, Uuid)> = HashSet::new();

        for source_entry in ctx.if_entries {
            let Some(ref neighbor) = source_entry.base.neighbor else {
                continue;
            };

            // Resolve target host_id and target if_entry_id from neighbor variant
            let (target_host_id, target_if_entry_id) = match neighbor {
                Neighbor::IfEntry(id) => match ctx.get_if_entry_by_id(*id) {
                    Some(target_entry) => (target_entry.base.host_id, *id),
                    None => continue,
                },
                Neighbor::Host(host_id) => (*host_id, Uuid::nil()),
            };

            let source_host_id = source_entry.base.host_id;

            // Skip self-loops
            if source_host_id == target_host_id {
                continue;
            }

            // Only create edges between hosts that are elements in the graph
            if !host_lookup.contains_key(&source_host_id)
                || !host_lookup.contains_key(&target_host_id)
            {
                continue;
            }

            // Dedup bidirectional pairs
            let pair = if source_host_id < target_host_id {
                (source_host_id, target_host_id)
            } else {
                (target_host_id, source_host_id)
            };
            if !processed_pairs.insert(pair) {
                continue;
            }

            edges.push(Edge {
                id: Uuid::new_v4(),
                source: source_host_id,
                target: target_host_id,
                edge_type: EdgeType::PhysicalLink {
                    source_if_entry_id: source_entry.id,
                    target_if_entry_id,
                    protocol: DiscoveryProtocol::default(),
                },
                label: None,
                source_handle: EdgeHandle::Bottom,
                target_handle: EdgeHandle::Top,
                is_multi_hop: false,
                view_config: EdgeViewConfig::default(),
            });
        }

        (nodes, edges)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::{
        hosts::r#impl::{
            base::{Host, HostBase},
            virtualization::{HostVirtualization, ProxmoxVirtualization},
        },
        services::r#impl::{
            base::{Service, ServiceBase},
            categories::ServiceCategory,
            definitions::ServiceDefinition,
            patterns::Pattern,
        },
        topology::{
            service::context::TopologyContext,
            types::{
                base::TopologyOptions,
                grouping::{ElementRule, GroupingConfig, IdentifiedRule},
                nodes::ContainerType,
            },
        },
    };
    use chrono::Utc;

    #[derive(PartialEq, Eq, Hash, Clone)]
    struct TestDef;
    impl ServiceDefinition for TestDef {
        fn name(&self) -> &'static str {
            "Test"
        }
        fn description(&self) -> &'static str {
            "Test"
        }
        fn category(&self) -> ServiceCategory {
            ServiceCategory::Virtualization
        }
        fn discovery_pattern(&self) -> Pattern<'_> {
            Pattern::None
        }
    }

    fn make_host(name: &str) -> Host {
        Host {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: HostBase {
                name: name.to_string(),
                ..Default::default()
            },
        }
    }

    fn make_proxmox_vm(name: &str, proxmox_service_id: Uuid) -> Host {
        Host {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: HostBase {
                name: name.to_string(),
                virtualization: Some(HostVirtualization::Proxmox(ProxmoxVirtualization {
                    vm_name: Some(name.to_string()),
                    vm_id: None,
                    service_id: proxmox_service_id,
                })),
                ..Default::default()
            },
        }
    }

    fn make_service(host_id: Uuid) -> Service {
        Service {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                service_definition: Box::new(TestDef),
                name: "Proxmox VE".to_string(),
                ..Default::default()
            },
        }
    }

    fn infra_grouping() -> GroupingConfig {
        GroupingConfig {
            container_rules: vec![],
            element_rules: vec![IdentifiedRule::new(ElementRule::ByVirtualizer)],
        }
    }

    #[test]
    fn test_empty_topology() {
        let options = TopologyOptions::default();
        let ctx = TopologyContext::new(&[], &[], &[], &[], &[], &[], &[], &[], &[], &options);
        let builder = InfrastructureBuilder;
        let (nodes, edges) = builder.build(&ctx, &infra_grouping());
        // Only the Root container, no elements
        assert_eq!(nodes.len(), 1);
        assert!(matches!(
            nodes[0].node_type,
            NodeType::Container {
                container_type: ContainerType::Root,
                ..
            }
        ));
        assert!(edges.is_empty());
    }

    #[test]
    fn test_bare_metal_hosts() {
        let h1 = make_host("server-1");
        let h2 = make_host("server-2");
        let hosts = vec![h1, h2];
        let options = TopologyOptions::default();
        let ctx = TopologyContext::new(&hosts, &[], &[], &[], &[], &[], &[], &[], &[], &options);

        let builder = InfrastructureBuilder;
        let (nodes, _edges) = builder.build(&ctx, &infra_grouping());

        // 1 Root container + 2 elements (no BareMetal — bare metal hosts stay ungrouped)
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 2);

        let bare_metal: Vec<&Node> = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::BareMetal,
                        ..
                    }
                )
            })
            .collect();
        assert_eq!(bare_metal.len(), 0);
    }

    #[test]
    fn test_proxmox_vms_grouped_under_hypervisor() {
        let hypervisor = make_host("pve-01");
        let proxmox_service = make_service(hypervisor.id);
        let vm1 = make_proxmox_vm("vm-web", proxmox_service.id);
        let vm2 = make_proxmox_vm("vm-db", proxmox_service.id);

        let hosts = vec![hypervisor.clone(), vm1, vm2];
        let services = vec![proxmox_service];
        let options = TopologyOptions::default();
        let ctx = TopologyContext::new(
            &hosts,
            &[],
            &[],
            &services,
            &[],
            &[],
            &[],
            &[],
            &[],
            &options,
        );

        let builder = InfrastructureBuilder;
        let (nodes, _edges) = builder.build(&ctx, &infra_grouping());

        // 3 host elements + 1 Root + 1 Virtualizer subcontainer
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 3);

        let virtualizer_containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::Virtualizer,
                        ..
                    }
                )
            })
            .collect();
        assert_eq!(virtualizer_containers.len(), 1);
        assert_eq!(virtualizer_containers[0].header.as_deref(), Some("pve-01"));

        // VM elements should be in the Virtualizer container
        let virt_id = virtualizer_containers[0].id;
        let vm_elements: Vec<&Node> = elements
            .iter()
            .filter(|n| {
                if let NodeType::Element { container_id, .. } = &n.node_type {
                    *container_id == virt_id
                } else {
                    false
                }
            })
            .copied()
            .collect();
        assert_eq!(vm_elements.len(), 2);

        // Hypervisor host stays ungrouped in Root (no BareMetal container)
        let hypervisor_element = elements
            .iter()
            .find(|n| n.header.as_deref() == Some("pve-01"))
            .expect("Hypervisor should be an element");
        if let NodeType::Element { container_id, .. } = &hypervisor_element.node_type {
            assert_eq!(
                *container_id, FLAT_ROOT_ID,
                "Hypervisor should remain in Root"
            );
        }
    }

    #[test]
    fn test_mixed_environment() {
        // 1 hypervisor with 2 VMs + 2 bare metal hosts
        let hypervisor = make_host("pve-01");
        let proxmox_service = make_service(hypervisor.id);
        let vm1 = make_proxmox_vm("vm-1", proxmox_service.id);
        let vm2 = make_proxmox_vm("vm-2", proxmox_service.id);
        let bare1 = make_host("bare-1");
        let bare2 = make_host("bare-2");

        let hosts = vec![hypervisor, vm1, vm2, bare1, bare2];
        let services = vec![proxmox_service];
        let options = TopologyOptions::default();
        let ctx = TopologyContext::new(
            &hosts,
            &[],
            &[],
            &services,
            &[],
            &[],
            &[],
            &[],
            &[],
            &options,
        );

        let builder = InfrastructureBuilder;
        let (nodes, _edges) = builder.build(&ctx, &infra_grouping());

        // 5 host elements + 1 Root + 1 Virtualizer = 7 (no BareMetal)
        assert_eq!(nodes.len(), 7);

        let virtualizers: Vec<&Node> = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::Virtualizer,
                        ..
                    }
                )
            })
            .collect();
        assert_eq!(virtualizers.len(), 1);
    }

    #[test]
    fn test_virtualization_edges_created() {
        let hypervisor = make_host("pve-01");
        let proxmox_service = make_service(hypervisor.id);
        let vm = make_proxmox_vm("vm-1", proxmox_service.id);

        let hypervisor_id = hypervisor.id;
        let vm_id = vm.id;
        let hosts = vec![hypervisor, vm];
        let services = vec![proxmox_service];
        let options = TopologyOptions::default();
        let ctx = TopologyContext::new(
            &hosts,
            &[],
            &[],
            &services,
            &[],
            &[],
            &[],
            &[],
            &[],
            &options,
        );

        let builder = InfrastructureBuilder;
        let (_nodes, edges) = builder.build(&ctx, &infra_grouping());

        // HostVirtualization edge connects hypervisor host to VM host
        assert_eq!(edges.len(), 1);
        let edge = &edges[0];
        assert_eq!(edge.source, hypervisor_id);
        assert_eq!(edge.target, vm_id);
        assert!(matches!(
            edge.edge_type,
            EdgeType::HostVirtualization { .. }
        ));
    }
}
