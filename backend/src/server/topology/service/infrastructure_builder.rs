use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use super::{
    context::TopologyContext,
    element_rules::{ElementMatchData, apply_element_rules_with_titles},
    perspective::PerspectiveBuilder,
};
use crate::server::{
    hosts::r#impl::virtualization::HostVirtualization,
    if_entries::r#impl::base::Neighbor,
    topology::types::{
        edges::{DiscoveryProtocol, Edge, EdgeClassification, EdgeHandle, EdgeType},
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

impl PerspectiveBuilder for InfrastructureBuilder {
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
            },
            position: Default::default(),
            size: Default::default(),
            header: None,
            element_rule_id: None,
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
                    Some(ElementMatchData {
                        categories,
                        tag_ids,
                        virtualizer_host_id: virtualizer_map.get(host_id).copied().flatten(),
                    })
                } else {
                    None
                }
            },
            Some(&virtualizer_titles),
        );

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
                classification: EdgeClassification::default(),
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
                grouping::{ElementRule, GraphRule, GroupingConfig},
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
            element_rules: vec![GraphRule::new(ElementRule::ByVirtualizer)],
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

        // 2 elements + 1 BareMetal subcontainer
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 2);

        let containers: Vec<&Node> = nodes
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
        assert_eq!(containers.len(), 1);
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

        // 3 host elements + 1 Virtualizer subcontainer + 1 BareMetal subcontainer
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

        // Hypervisor host should be in BareMetal container
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
        assert_eq!(bare_metal.len(), 1);
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

        // 5 host elements + 1 Root + 1 Virtualizer + 1 BareMetal = 8
        assert_eq!(nodes.len(), 8);

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

        let bare_metals: Vec<&Node> = nodes
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
        assert_eq!(bare_metals.len(), 1);
    }

    #[test]
    fn test_no_virtualization_edges() {
        let hypervisor = make_host("pve-01");
        let proxmox_service = make_service(hypervisor.id);
        let vm = make_proxmox_vm("vm-1", proxmox_service.id);

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

        // No virtualization edges — containment IS the relationship.
        // Only PhysicalLink edges would appear (none in this test since no if_entries).
        assert!(edges.is_empty());
    }
}
