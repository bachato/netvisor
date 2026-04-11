use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use super::{
    context::TopologyContext,
    element_rules::{ElementMatchData, apply_element_rules_with_titles},
    view::ViewBuilder,
};
use crate::server::{
    dependencies::r#impl::{base::DependencyMembers, types::DependencyType},
    services::r#impl::definitions::ServiceDefinitionExt,
    topology::types::{
        edges::{DiscoveryProtocol, Edge, EdgeHandle, EdgeType, EdgeViewConfig},
        grouping::GroupingConfig,
        nodes::{ContainerType, ElementEntityType, Node, NodeType},
    },
};

pub struct WorkloadsBuilder;

impl WorkloadsBuilder {
    /// Generate a deterministic container UUID from host_id for the Workloads view.
    fn container_id_for_host(host_id: Uuid) -> Uuid {
        Uuid::new_v5(
            &Uuid::NAMESPACE_OID,
            format!("workloads:host:{host_id}").as_bytes(),
        )
    }

    /// Build a map of virtualizer_service_id → service_definition_name for subcontainer titles.
    fn build_virtualizer_titles(ctx: &TopologyContext) -> HashMap<Uuid, String> {
        ctx.services
            .iter()
            .filter(|s| s.base.service_definition.manages_virtualization().is_some())
            .map(|s| (s.id, s.base.service_definition.name().to_string()))
            .collect()
    }
}

impl ViewBuilder for WorkloadsBuilder {
    fn build(&self, ctx: &TopologyContext, grouping: &GroupingConfig) -> (Vec<Node>, Vec<Edge>) {
        let mut nodes = Vec::new();

        // --- Phase 1: Build lookup maps (provider-agnostic) ---

        // virtualizer_service_id → managed VM host_ids
        // (from hosts with virtualization, using the generic service_id() accessor)
        let mut virt_to_vm_hosts: HashMap<Uuid, Vec<Uuid>> = HashMap::new();
        for host in ctx.hosts {
            if let Some(ref virt) = host.base.virtualization
                && let Some(svc_id) = virt.service_id()
            {
                virt_to_vm_hosts.entry(svc_id).or_default().push(host.id);
            }
        }

        // virtualizer_service_id → managed container service_ids
        // (from services with virtualization, using the generic service_id() accessor)
        let mut virt_to_container_svcs: HashMap<Uuid, Vec<Uuid>> = HashMap::new();
        for service in ctx.services {
            if let Some(ref virt) = service.base.virtualization
                && let Some(svc_id) = virt.service_id()
            {
                virt_to_container_svcs
                    .entry(svc_id)
                    .or_default()
                    .push(service.id);
            }
        }

        // Services that are virtualizers (Docker daemon, Proxmox service, etc.)
        let virtualizer_service_ids: HashSet<Uuid> = ctx
            .services
            .iter()
            .filter(|s| s.base.service_definition.manages_virtualization().is_some())
            .map(|s| s.id)
            .collect();

        // Services that are managed by a virtualizer (containers)
        let managed_service_ids: HashSet<Uuid> = virt_to_container_svcs
            .values()
            .flat_map(|ids| ids.iter().copied())
            .collect();

        // Host lookup for resolving names and data
        let host_lookup: HashMap<Uuid, &crate::server::hosts::r#impl::base::Host> =
            ctx.hosts.iter().map(|h| (h.id, h)).collect();

        // Service lookup
        let service_lookup: HashMap<Uuid, &crate::server::services::r#impl::base::Service> =
            ctx.services.iter().map(|s| (s.id, s)).collect();

        // --- Phase 2: Create Host containers for non-VM hosts ---

        for host in ctx.hosts {
            // VMs are elements only, never containers
            if host.base.virtualization.is_some() {
                continue;
            }

            let container_id = Self::container_id_for_host(host.id);
            nodes.push(Node {
                id: container_id,
                node_type: NodeType::Container {
                    container_type: ContainerType::Host,
                    parent_container_id: None,
                    layer_hint: None,
                    icon: None,
                    color: None,
                    associated_service_definition: None,
                },
                position: Default::default(),
                size: Default::default(),
                header: Some(host.base.name.clone()),
                element_rule_id: None,
                will_accept_edges: false,
            });
        }

        // --- Phase 3: Create workload elements ---

        // 3a: VM elements — placed in the virtualizer service's host container
        for (virt_svc_id, vm_host_ids) in &virt_to_vm_hosts {
            // Find the host running this virtualizer service
            let Some(virt_svc) = service_lookup.get(virt_svc_id) else {
                continue;
            };
            let hypervisor_host_id = virt_svc.base.host_id;
            let container_id = Self::container_id_for_host(hypervisor_host_id);

            for &vm_host_id in vm_host_ids {
                let Some(vm_host) = host_lookup.get(&vm_host_id) else {
                    continue;
                };
                let mut node = Node::element(
                    vm_host_id,
                    container_id,
                    vm_host_id,
                    ElementEntityType::Host {},
                );
                node.header = Some(vm_host.base.name.clone());
                nodes.push(node);
            }
        }

        // 3b: Container elements — placed in their host's container
        for (virt_svc_id, container_svc_ids) in &virt_to_container_svcs {
            let Some(virt_svc) = service_lookup.get(virt_svc_id) else {
                continue;
            };
            let host_id = virt_svc.base.host_id;
            let container_id = Self::container_id_for_host(host_id);

            for &svc_id in container_svc_ids {
                let Some(svc) = service_lookup.get(&svc_id) else {
                    continue;
                };
                let mut node = Node::element(
                    svc_id,
                    container_id,
                    svc.base.host_id,
                    ElementEntityType::Service {},
                );
                node.header = Some(svc.base.name.clone());
                nodes.push(node);
            }
        }

        // 3c: Remaining services — not a virtualizer, not managed by one
        for service in ctx.services {
            if virtualizer_service_ids.contains(&service.id)
                || managed_service_ids.contains(&service.id)
            {
                continue;
            }

            // Skip services on VM hosts (VMs don't have containers)
            let Some(host) = host_lookup.get(&service.base.host_id) else {
                continue;
            };
            if host.base.virtualization.is_some() {
                continue;
            }

            let container_id = Self::container_id_for_host(service.base.host_id);
            let mut node = Node::element(
                service.id,
                container_id,
                service.base.host_id,
                ElementEntityType::Service {},
            );
            node.header = Some(service.base.name.clone());
            nodes.push(node);
        }

        // --- Phase 4: Apply element rules (ByVirtualizer + ByTag) ---

        let virtualizer_titles = Self::build_virtualizer_titles(ctx);

        apply_element_rules_with_titles(
            &mut nodes,
            &grouping.element_rules,
            |node| {
                match &node.node_type {
                    NodeType::Element {
                        element: ElementEntityType::Host {},
                        ..
                    } => {
                        // VM element: virtualizer_service_id from host's virtualization
                        let host = host_lookup.get(&node.id)?;
                        let virtualizer_service_id = host
                            .base
                            .virtualization
                            .as_ref()
                            .and_then(|v| v.service_id());
                        let tag_ids: HashSet<Uuid> = host.base.tags.iter().copied().collect();
                        Some(ElementMatchData {
                            categories: HashSet::new(),
                            tag_ids,
                            virtualizer_service_id,
                            compose_project: None,
                            native_vlan_id: None,
                            vlan_number: None,
                            vlan_name: None,
                            is_trunk_port: false,
                            oper_status: None,
                        })
                    }
                    NodeType::Element {
                        element: ElementEntityType::Service {},
                        ..
                    } => {
                        // Service element: virtualizer_service_id from service's virtualization
                        let svc = service_lookup.get(&node.id)?;
                        let virtualizer_service_id = svc
                            .base
                            .virtualization
                            .as_ref()
                            .and_then(|v| v.service_id());
                        let tag_ids: HashSet<Uuid> = svc.base.tags.iter().copied().collect();
                        let categories = [svc.base.service_definition.category()]
                            .into_iter()
                            .collect();
                        Some(ElementMatchData {
                            categories,
                            tag_ids,
                            virtualizer_service_id,
                            compose_project: None,
                            native_vlan_id: None,
                            vlan_number: None,
                            vlan_name: None,
                            is_trunk_port: false,
                            oper_status: None,
                        })
                    }
                    _ => None,
                }
            },
            Some(&virtualizer_titles),
        );

        // Physical link edges between hosts (LLDP/CDP discovered connections).
        // Unlike L3/L2, Workloads uses host IDs as edge source/target since
        // elements are hosts, not IP addresses or interfaces.
        let mut edges = Vec::new();
        let mut seen_host_pairs: HashSet<(Uuid, Uuid)> = HashSet::new();
        for entry in ctx.interfaces.iter() {
            let target_entry_id = match &entry.base.neighbor {
                Some(crate::server::interfaces::r#impl::base::Neighbor::Interface(id)) => *id,
                _ => continue,
            };
            let target_entry = match ctx.get_if_entry_by_id(target_entry_id) {
                Some(e) => e,
                None => continue,
            };
            // Only create edges between different hosts
            if entry.base.host_id == target_entry.base.host_id {
                continue;
            }
            let pair = if entry.base.host_id < target_entry.base.host_id {
                (entry.base.host_id, target_entry.base.host_id)
            } else {
                (target_entry.base.host_id, entry.base.host_id)
            };
            if seen_host_pairs.contains(&pair) {
                continue;
            }
            seen_host_pairs.insert(pair);

            let label = Some(format!(
                "{} ↔ {}",
                entry.display_name(),
                target_entry.display_name()
            ));

            edges.push(Edge {
                id: Uuid::new_v4(),
                source: entry.base.host_id,
                target: target_entry.base.host_id,
                edge_type: EdgeType::PhysicalLink {
                    source_entity_id: entry.id,
                    target_entity_id: target_entry.id,
                    protocol: DiscoveryProtocol::default(),
                },
                label,
                source_handle: EdgeHandle::Bottom,
                target_handle: EdgeHandle::Top,
                is_multi_hop: false,
                view_config: EdgeViewConfig::default(),
            });
        }

        // --- Dependency edges (connecting host containers) ---

        // Build service_id → host_id lookup
        let service_to_host: HashMap<Uuid, Uuid> = ctx
            .services
            .iter()
            .map(|s| (s.id, s.base.host_id))
            .collect();

        // Build binding_id → service_id lookup
        let binding_to_service: HashMap<Uuid, Uuid> = ctx
            .services
            .iter()
            .flat_map(|s| s.base.bindings.iter().map(move |b| (b.id, s.id)))
            .collect();

        // Set of host IDs that have containers (non-VM hosts)
        let host_container_ids: HashSet<Uuid> = ctx
            .hosts
            .iter()
            .filter(|h| h.base.virtualization.is_none())
            .map(|h| h.id)
            .collect();

        for dep in ctx.dependencies {
            // Resolve to ordered service IDs
            let service_ids: Vec<Uuid> = match &dep.base.members {
                DependencyMembers::Services { service_ids } => service_ids.clone(),
                DependencyMembers::Bindings { binding_ids } => {
                    let mut ids = Vec::new();
                    for binding_id in binding_ids {
                        if let Some(&service_id) = binding_to_service.get(binding_id)
                            && ids.last() != Some(&service_id)
                        {
                            ids.push(service_id);
                        }
                    }
                    ids
                }
            };

            // Map service IDs to host container IDs, deduplicating consecutive same-host entries
            let host_container_chain: Vec<Uuid> = service_ids
                .iter()
                .filter_map(|sid| {
                    let host_id = service_to_host.get(sid)?;
                    if host_container_ids.contains(host_id) {
                        Some(Self::container_id_for_host(*host_id))
                    } else {
                        None
                    }
                })
                .fold(Vec::new(), |mut acc, cid| {
                    if acc.last() != Some(&cid) {
                        acc.push(cid);
                    }
                    acc
                });

            if host_container_chain.len() < 2 {
                continue;
            }

            match dep.base.dependency_type {
                DependencyType::RequestPath => {
                    for window in host_container_chain.windows(2) {
                        edges.push(Edge {
                            id: Uuid::new_v4(),
                            source: window[0],
                            target: window[1],
                            edge_type: EdgeType::RequestPath {
                                dependency_id: dep.id,
                                source_binding_id: Uuid::nil(),
                                target_binding_id: Uuid::nil(),
                            },
                            label: Some(dep.base.name.clone()),
                            source_handle: EdgeHandle::Bottom,
                            target_handle: EdgeHandle::Top,
                            is_multi_hop: false,
                            view_config: EdgeViewConfig::default(),
                        });
                    }
                }
                DependencyType::HubAndSpoke => {
                    if let Some((&hub_id, spokes)) = host_container_chain.split_first() {
                        for &spoke_id in spokes {
                            edges.push(Edge {
                                id: Uuid::new_v4(),
                                source: hub_id,
                                target: spoke_id,
                                edge_type: EdgeType::HubAndSpoke {
                                    dependency_id: dep.id,
                                    source_binding_id: Uuid::nil(),
                                    target_binding_id: Uuid::nil(),
                                },
                                label: Some(dep.base.name.clone()),
                                source_handle: EdgeHandle::Bottom,
                                target_handle: EdgeHandle::Top,
                                is_multi_hop: false,
                                view_config: EdgeViewConfig::default(),
                            });
                        }
                    }
                }
            }
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
            virtualization::{DockerVirtualization, ServiceVirtualization},
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

    // --- Test service definitions ---

    #[derive(PartialEq, Eq, Hash, Clone)]
    struct ProxmoxDef;
    impl ServiceDefinition for ProxmoxDef {
        fn name(&self) -> &'static str {
            "Proxmox VE"
        }
        fn description(&self) -> &'static str {
            "Proxmox"
        }
        fn category(&self) -> ServiceCategory {
            ServiceCategory::Virtualization
        }
        fn discovery_pattern(&self) -> Pattern<'_> {
            Pattern::None
        }
    }

    #[derive(PartialEq, Eq, Hash, Clone)]
    struct DockerDef;
    impl ServiceDefinition for DockerDef {
        fn name(&self) -> &'static str {
            "Docker"
        }
        fn description(&self) -> &'static str {
            "Docker"
        }
        fn category(&self) -> ServiceCategory {
            ServiceCategory::Virtualization
        }
        fn discovery_pattern(&self) -> Pattern<'_> {
            Pattern::None
        }
    }

    #[derive(PartialEq, Eq, Hash, Clone)]
    struct RegularDef;
    impl ServiceDefinition for RegularDef {
        fn name(&self) -> &'static str {
            "Samba"
        }
        fn description(&self) -> &'static str {
            "Samba"
        }
        fn category(&self) -> ServiceCategory {
            ServiceCategory::Storage
        }
        fn discovery_pattern(&self) -> Pattern<'_> {
            Pattern::None
        }
    }

    #[derive(PartialEq, Eq, Hash, Clone)]
    struct GenericDef;
    impl ServiceDefinition for GenericDef {
        fn name(&self) -> &'static str {
            "SSH"
        }
        fn description(&self) -> &'static str {
            "SSH"
        }
        fn category(&self) -> ServiceCategory {
            ServiceCategory::RemoteAccess
        }
        fn discovery_pattern(&self) -> Pattern<'_> {
            Pattern::None
        }
        fn is_generic(&self) -> bool {
            true
        }
    }

    // --- Test helpers ---

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

    fn make_proxmox_service(host_id: Uuid) -> Service {
        Service {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                service_definition: Box::new(ProxmoxDef),
                name: "Proxmox VE".to_string(),
                ..Default::default()
            },
        }
    }

    fn make_docker_service(host_id: Uuid) -> Service {
        Service {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                service_definition: Box::new(DockerDef),
                name: "Docker".to_string(),
                ..Default::default()
            },
        }
    }

    fn make_docker_container(name: &str, host_id: Uuid, docker_service_id: Uuid) -> Service {
        Service {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                service_definition: Box::new(RegularDef),
                name: name.to_string(),
                virtualization: Some(ServiceVirtualization::Docker(DockerVirtualization {
                    container_name: Some(name.to_string()),
                    container_id: None,
                    service_id: docker_service_id,
                    compose_project: None,
                })),
                ..Default::default()
            },
        }
    }

    fn make_regular_service(name: &str, host_id: Uuid) -> Service {
        Service {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                service_definition: Box::new(RegularDef),
                name: name.to_string(),
                ..Default::default()
            },
        }
    }

    fn make_generic_service(name: &str, host_id: Uuid) -> Service {
        Service {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                service_definition: Box::new(GenericDef),
                name: name.to_string(),
                ..Default::default()
            },
        }
    }

    fn workloads_grouping() -> GroupingConfig {
        GroupingConfig {
            container_rules: vec![],
            element_rules: vec![IdentifiedRule::new(ElementRule::ByVirtualizer)],
        }
    }

    fn build(hosts: &[Host], services: &[Service]) -> (Vec<Node>, Vec<Edge>) {
        let options = TopologyOptions::default();
        let ctx = TopologyContext::new(
            hosts,
            &[],
            &[],
            services,
            &[],
            &[],
            &[],
            &[],
            &[],
            &[],
            &options,
        );
        WorkloadsBuilder.build(&ctx, &workloads_grouping())
    }

    // --- Tests ---

    #[test]
    fn test_empty_topology() {
        let (nodes, edges) = build(&[], &[]);
        assert!(nodes.is_empty());
        assert!(edges.is_empty());
    }

    #[test]
    fn test_bare_metal_host_with_services() {
        let host = make_host("nas-01");
        let svc1 = make_regular_service("samba", host.id);
        let svc2 = make_regular_service("nfs", host.id);
        let (nodes, _edges) = build(&[host], &[svc1, svc2]);

        // 1 Host container + 2 Service elements
        let containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Container { .. }))
            .collect();
        assert_eq!(containers.len(), 1);
        assert!(matches!(
            containers[0].node_type,
            NodeType::Container {
                container_type: ContainerType::Host,
                ..
            }
        ));
        assert_eq!(containers[0].header.as_deref(), Some("nas-01"));

        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 2);

        // Both elements are Service{} type
        for elem in &elements {
            assert!(matches!(
                elem.node_type,
                NodeType::Element {
                    element: ElementEntityType::Service {},
                    ..
                }
            ));
        }

        // Elements are in the host container
        let container_id = containers[0].id;
        for elem in &elements {
            if let NodeType::Element {
                container_id: cid, ..
            } = &elem.node_type
            {
                assert_eq!(*cid, container_id);
            }
        }
    }

    #[test]
    fn test_host_with_only_generic_services() {
        let host = make_host("router-01");
        let ssh = make_generic_service("SSH", host.id);

        let (nodes, _edges) = build(&[host], &[ssh]);

        // Host container IS created — generic filtering is a frontend concern
        let containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Container { .. }))
            .collect();
        assert_eq!(containers.len(), 1);

        // SSH service included as element
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 1);
    }

    #[test]
    fn test_proxmox_hypervisor_with_vms() {
        let hypervisor = make_host("pve-01");
        let proxmox_svc = make_proxmox_service(hypervisor.id);
        let vm1 = make_proxmox_vm("vm-web", proxmox_svc.id);
        let vm2 = make_proxmox_vm("vm-db", proxmox_svc.id);

        let (nodes, edges) = build(&[hypervisor.clone(), vm1, vm2], &[proxmox_svc]);

        // No edges
        assert!(edges.is_empty());

        // 1 Host container (hypervisor only, VMs don't get containers)
        let host_containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::Host,
                        ..
                    }
                )
            })
            .collect();
        assert_eq!(host_containers.len(), 1);
        assert_eq!(host_containers[0].header.as_deref(), Some("pve-01"));

        // 1 Virtualizer subcontainer (Proxmox VE)
        let virt_containers: Vec<&Node> = nodes
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
        assert_eq!(virt_containers.len(), 1);

        // 2 VM elements (Host{} type)
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 2);
        for elem in &elements {
            assert!(matches!(
                elem.node_type,
                NodeType::Element {
                    element: ElementEntityType::Host {},
                    ..
                }
            ));
        }

        // VM elements should be inside the Virtualizer subcontainer
        let virt_id = virt_containers[0].id;
        for elem in &elements {
            if let NodeType::Element { container_id, .. } = &elem.node_type {
                assert_eq!(*container_id, virt_id);
            }
        }
    }

    #[test]
    fn test_docker_host_with_containers() {
        let host = make_host("server-01");
        let docker_svc = make_docker_service(host.id);
        let c1 = make_docker_container("nginx", host.id, docker_svc.id);
        let c2 = make_docker_container("postgres", host.id, docker_svc.id);

        let (nodes, edges) = build(&[host], &[docker_svc, c1, c2]);

        assert!(edges.is_empty());

        // 1 Host container
        let host_containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::Host,
                        ..
                    }
                )
            })
            .collect();
        assert_eq!(host_containers.len(), 1);

        // 1 Virtualizer subcontainer (Docker)
        let virt_containers: Vec<&Node> = nodes
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
        assert_eq!(virt_containers.len(), 1);

        // 2 Service elements (containers)
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 2);

        // Elements inside Virtualizer
        let virt_id = virt_containers[0].id;
        for elem in &elements {
            if let NodeType::Element { container_id, .. } = &elem.node_type {
                assert_eq!(*container_id, virt_id);
            }
        }
    }

    #[test]
    fn test_vm_not_a_container() {
        // VM hosts should NOT get their own Host container
        let hypervisor = make_host("pve-01");
        let proxmox_svc = make_proxmox_service(hypervisor.id);
        let vm = make_proxmox_vm("media-vm", proxmox_svc.id);

        // Add a service on the VM (e.g., Docker running on the VM)
        let vm_service = make_regular_service("plex", vm.id);

        let (nodes, _edges) = build(&[hypervisor, vm], &[proxmox_svc, vm_service]);

        // Only 1 Host container (hypervisor), NOT 2
        let host_containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::Host,
                        ..
                    }
                )
            })
            .collect();
        assert_eq!(host_containers.len(), 1);
        assert_eq!(host_containers[0].header.as_deref(), Some("pve-01"));

        // The VM's service (plex) is NOT shown since the VM has no container
        // Services on VM hosts are skipped because the VM has virtualization
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        // Only the VM itself as an element, not plex
        assert_eq!(elements.len(), 1);
        assert_eq!(elements[0].header.as_deref(), Some("media-vm"));
    }

    #[test]
    fn test_no_edges() {
        let hypervisor = make_host("pve-01");
        let proxmox_svc = make_proxmox_service(hypervisor.id);
        let vm = make_proxmox_vm("vm-1", proxmox_svc.id);

        let (_nodes, edges) = build(&[hypervisor, vm], &[proxmox_svc]);

        assert!(edges.is_empty());
    }

    #[test]
    fn test_mixed_environment() {
        // Hypervisor with VMs + bare metal hosts with services
        let hypervisor = make_host("pve-01");
        let proxmox_svc = make_proxmox_service(hypervisor.id);
        let vm1 = make_proxmox_vm("vm-1", proxmox_svc.id);
        let vm2 = make_proxmox_vm("vm-2", proxmox_svc.id);

        let bare = make_host("nas-01");
        let docker_svc = make_docker_service(bare.id);
        let container = make_docker_container("nginx", bare.id, docker_svc.id);
        let samba = make_regular_service("samba", bare.id);

        let (nodes, edges) = build(
            &[hypervisor, vm1, vm2, bare],
            &[proxmox_svc, docker_svc, container, samba],
        );

        assert!(edges.is_empty());

        // 2 Host containers (hypervisor + bare), VMs don't get containers
        let host_containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::Host,
                        ..
                    }
                )
            })
            .collect();
        assert_eq!(host_containers.len(), 2);

        // 2 Virtualizer subcontainers (Proxmox on hypervisor, Docker on bare)
        let virt_containers: Vec<&Node> = nodes
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
        assert_eq!(virt_containers.len(), 2);

        // Elements: 2 VMs + 1 container + 1 samba = 4
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 4);
    }

}
