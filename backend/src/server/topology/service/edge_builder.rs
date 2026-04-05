use itertools::Itertools;
use petgraph::{Graph, graph::NodeIndex};
use std::collections::{HashMap, HashSet};
use strum::IntoDiscriminant;
use uuid::Uuid;

use crate::server::{
    dependencies::r#impl::{base::Dependency, types::DependencyType},
    hosts::r#impl::virtualization::HostVirtualization,
    if_entries::r#impl::base::Neighbor,
    services::r#impl::virtualization::ServiceVirtualization,
    subnets::r#impl::types::{SubnetType, SubnetTypeDiscriminants},
    topology::{
        service::context::TopologyContext,
        types::{
            edges::{DiscoveryProtocol, Edge, EdgeClassification, EdgeHandle, EdgeType},
            grouping::GroupingConfig,
            nodes::Node,
        },
    },
};

pub struct EdgeBuilder;

impl EdgeBuilder {
    /// Create dependency edges (connecting services in a dependency's service chain)
    pub fn create_dependency_edges(ctx: &TopologyContext) -> Vec<Edge> {
        ctx.dependencies
            .iter()
            .flat_map(|dependency| {
                let binding_ids = dependency.binding_ids();
                match &dependency.base.dependency_type {
                    DependencyType::RequestPath => binding_ids
                        .windows(2)
                        .filter_map(|window| {
                            EdgeBuilder::edge_from_service_bindings(
                                ctx, window[0], window[1], dependency,
                            )
                        })
                        .collect::<Vec<Edge>>(),
                    DependencyType::HubAndSpoke => {
                        let mut binding_ids = binding_ids.clone();
                        binding_ids.reverse();
                        if let Some(hub_binding_id) = binding_ids.pop() {
                            return binding_ids
                                .iter()
                                .filter_map(|spoke_binding| {
                                    EdgeBuilder::edge_from_service_bindings(
                                        ctx,
                                        hub_binding_id,
                                        *spoke_binding,
                                        dependency,
                                    )
                                })
                                .collect::<Vec<Edge>>();
                        }
                        Vec::new()
                    }
                }
            })
            .collect()
    }

    // Create edges to connect a host that virtualizes containers via docker to the docker bridge subnets
    pub fn create_containerized_service_edges(
        ctx: &TopologyContext,
        grouping: &GroupingConfig,
    ) -> (Vec<Edge>, HashMap<Uuid, Uuid>) {
        // Host id to subnet id that will be used for grouping, if enabled
        let mut docker_bridge_host_subnet_id_to_group_on: HashMap<Uuid, Uuid> = HashMap::new();

        let mut docker_service_to_containerized_service_ids: HashMap<Uuid, Vec<Uuid>> =
            HashMap::new();

        ctx.services.iter().for_each(|s| {
            if let Some(ServiceVirtualization::Docker(docker_virtualization)) =
                &s.base.virtualization
            {
                let entry = docker_service_to_containerized_service_ids
                    .entry(docker_virtualization.service_id)
                    .or_default();
                if !entry.contains(&s.id) {
                    entry.push(s.id);
                }
            }
        });

        let edges = ctx
            .services
            .iter()
            .filter(|s| {
                docker_service_to_containerized_service_ids
                    .keys()
                    .contains(&s.id)
            })
            .filter_map(|s| {
                let host = ctx.get_host_by_id(s.base.host_id)?;
                let origin_interface =
                    ctx.get_first_non_docker_bridge_interface_for_host(host.id)?;
                Some((s, host, origin_interface))
            })
            .flat_map(|(s, host, origin_interface)| {
                let host_interfaces = ctx.get_interfaces_for_host(host.id);
                let container_subnets: Vec<Uuid> = host_interfaces
                    .iter()
                    .filter_map(|i| ctx.get_subnet_by_id(i.base.subnet_id))
                    .filter_map(|s| {
                        if s.base.subnet_type == SubnetType::DockerBridge {
                            return Some(s.id);
                        }
                        None
                    })
                    .collect();

                let container_subnet_interface_ids: Vec<Uuid> = host_interfaces
                    .iter()
                    .filter_map(|i| {
                        if container_subnets.contains(&i.base.subnet_id) {
                            return Some(i.id);
                        }
                        None
                    })
                    .collect();

                if grouping.should_group_docker_bridges() {
                    // If subnets are grouped, pick an arbitrary subnet ID to use for grouping
                    if let (Some(first_interface_id), Some(first_subnet_id)) = (
                        container_subnet_interface_ids.first(),
                        container_subnets.first(),
                    ) {
                        let is_multi_hop =
                            ctx.edge_is_multi_hop(&origin_interface.id, first_interface_id);

                        docker_bridge_host_subnet_id_to_group_on
                            .entry(host.id)
                            .or_insert(*first_subnet_id);

                        return vec![Edge {
                            id: Uuid::new_v4(),
                            source: origin_interface.id,
                            target: *first_subnet_id,
                            edge_type: EdgeType::ServiceVirtualization {
                                containerizing_service_id: s.id,
                                host_id: host.id,
                            },
                            label: Some(format!("{} @ {}", s.base.name, host.base.name)),
                            source_handle: EdgeHandle::Bottom,
                            target_handle: EdgeHandle::Top,
                            is_multi_hop,
                            classification: EdgeClassification::default(),
                        }];
                    }
                } else {
                    return docker_service_to_containerized_service_ids
                        .get(&s.id)
                        .unwrap_or(&Vec::new())
                        .iter()
                        .filter_map(move |cs| {
                            let containerized = ctx.get_service_by_id(*cs)?;

                            let container_binding_interface_id = containerized
                                .base
                                .bindings
                                .iter()
                                .filter_map(|b| b.interface_id())
                                .find(|i| container_subnet_interface_ids.contains(i))?;

                            let is_multi_hop = ctx.edge_is_multi_hop(
                                &origin_interface.id,
                                &container_binding_interface_id,
                            );

                            Some(Edge {
                                id: Uuid::new_v4(),
                                source: origin_interface.id,
                                target: container_binding_interface_id,
                                edge_type: EdgeType::ServiceVirtualization {
                                    containerizing_service_id: s.id,
                                    host_id: host.id,
                                },
                                label: Some(format!("{} on {}", s.base.name, host.base.name)),
                                source_handle: EdgeHandle::Bottom,
                                target_handle: EdgeHandle::Top,
                                is_multi_hop,
                                classification: EdgeClassification::default(),
                            })
                        })
                        .collect();
                }

                Vec::new()
            })
            .collect();

        (edges, docker_bridge_host_subnet_id_to_group_on)
    }

    // Create edges to connect a host that virtualizes other hosts as VMs
    pub fn create_vm_host_edges(ctx: &TopologyContext) -> Vec<Edge> {
        // Proxmox service interface binding that is present for a given subnet.
        // There could be multiple host interfaces with a given subnet, we arbitrarily choose the first one so there's
        // one clustering hub rather than multiple hubs
        // (subnet_id, proxmox_service_id) : (interface_id)
        let mut subnet_to_promxox_host_interface_id: HashMap<(Uuid, Uuid), Uuid> = HashMap::new();

        // Hosts VMs managed by a given proxmox service
        let mut vm_host_id_to_proxmox_service: HashMap<Uuid, Uuid> = HashMap::new();

        ctx.hosts.iter().for_each(|h| {
            if let Some(HostVirtualization::Proxmox(proxmox_virtualization)) =
                &h.base.virtualization
            {
                // Create mapping between subnet and proxmox interface(s) on that subnet
                if let Some(promxox_service) =
                    ctx.get_service_by_id(proxmox_virtualization.service_id)
                {
                    promxox_service
                        .base
                        .bindings
                        .iter()
                        .filter_map(|b| b.interface_id())
                        .for_each(|i| {
                            if let Some(subnet) = ctx.get_subnet_from_interface_id(i)
                                && !subnet_to_promxox_host_interface_id
                                    .contains_key(&(subnet.id, promxox_service.id))
                            {
                                subnet_to_promxox_host_interface_id
                                    .entry((subnet.id, promxox_service.id))
                                    .insert_entry(i);
                            }
                        });
                }

                vm_host_id_to_proxmox_service.insert(h.id, proxmox_virtualization.service_id);
            }
        });

        // Creates edges between interface that proxmox service has on a given subnet with interfaces that the virtualized host has on the subnet
        ctx.hosts
            .iter()
            .flat_map(|h| {
                if let Some(proxmox_service_id) = vm_host_id_to_proxmox_service.get(&h.id) {
                    let host_interfaces = ctx.get_interfaces_for_host(h.id);
                    return host_interfaces
                        .into_iter()
                        .filter_map(|i| {
                            if let Some(proxmox_service_interface_id) =
                                subnet_to_promxox_host_interface_id
                                    .get(&(i.base.subnet_id, *proxmox_service_id))
                            {
                                let is_multi_hop =
                                    ctx.edge_is_multi_hop(proxmox_service_interface_id, &i.id);

                                return Some(Edge {
                                    id: Uuid::new_v4(),
                                    source: *proxmox_service_interface_id,
                                    target: i.id,
                                    edge_type: EdgeType::HostVirtualization {
                                        vm_service_id: *proxmox_service_id,
                                    },
                                    label: None,
                                    source_handle: EdgeHandle::Bottom,
                                    target_handle: EdgeHandle::Top,
                                    is_multi_hop,
                                    classification: EdgeClassification::default(),
                                });
                            }
                            None
                        })
                        .collect();
                }
                Vec::new()
            })
            .collect()
    }

    /// Create interface edges (connecting multiple interfaces on the same host)
    pub fn create_interface_edges(ctx: &TopologyContext) -> Vec<Edge> {
        ctx.hosts
            .iter()
            .flat_map(|host| {
                let host_interfaces = ctx.get_interfaces_for_host(host.id);

                // Use the first non-DockerBridge interface as the origin
                // This ensures we don't try to create edges FROM a DockerBridge interface
                if let Some(origin_interface) =
                    ctx.get_first_non_docker_bridge_interface_for_host(host.id)
                {
                    host_interfaces
                        .iter()
                        .filter(|interface| interface.id != origin_interface.id)
                        .filter_map(|interface| {
                            let source_subnet =
                                ctx.get_subnet_by_id(origin_interface.base.subnet_id);
                            let target_subnet = ctx.get_subnet_by_id(interface.base.subnet_id);

                            if let Some(source_subnet) = source_subnet
                                && source_subnet.base.subnet_type.discriminant()
                                    == SubnetTypeDiscriminants::DockerBridge
                            {
                                return None;
                            }

                            if let Some(target_subnet) = target_subnet
                                && target_subnet.base.subnet_type.discriminant()
                                    == SubnetTypeDiscriminants::DockerBridge
                            {
                                return None;
                            }

                            let is_multi_hop =
                                ctx.edge_is_multi_hop(&origin_interface.id, &interface.id);

                            // Hide label if both interfaces are on the same subnet
                            let label =
                                if origin_interface.base.subnet_id == interface.base.subnet_id {
                                    None
                                } else {
                                    Some(host.base.name.to_string())
                                };

                            Some(Edge {
                                id: Uuid::new_v4(),
                                source: origin_interface.id,
                                target: interface.id,
                                edge_type: EdgeType::Interface { host_id: host.id },
                                label,
                                source_handle: EdgeHandle::Bottom,
                                target_handle: EdgeHandle::Top,
                                is_multi_hop,
                                classification: EdgeClassification::default(),
                            })
                        })
                        .collect::<Vec<_>>()
                } else {
                    Vec::new()
                }
            })
            .collect()
    }

    /// Create physical link edges from LLDP/CDP neighbor discovery
    /// Only creates edges when both endpoints have associated interfaces (nodes)
    pub fn create_physical_link_edges(ctx: &TopologyContext) -> Vec<Edge> {
        // Track processed pairs to avoid duplicate edges (A→B and B→A)
        let mut processed_pairs: HashSet<(Uuid, Uuid)> = HashSet::new();

        ctx.get_if_entries_with_neighbor()
            .into_iter()
            .filter_map(|source_entry| {
                // Get the target IfEntry ID from resolved neighbor
                let target_if_entry_id = match &source_entry.base.neighbor {
                    Some(Neighbor::IfEntry(id)) => *id,
                    _ => return None, // Already filtered by get_if_entries_with_neighbor
                };

                // Skip if we've already processed this pair (in either direction)
                let pair_key = if source_entry.id < target_if_entry_id {
                    (source_entry.id, target_if_entry_id)
                } else {
                    (target_if_entry_id, source_entry.id)
                };

                if processed_pairs.contains(&pair_key) {
                    return None;
                }
                processed_pairs.insert(pair_key);

                // Resolve interface IDs with single-interface host fallback
                let source_interface_id = ctx.resolve_interface_for_if_entry(source_entry)?;
                let target_entry = ctx.get_if_entry_by_id(target_if_entry_id)?;
                let target_interface_id = ctx.resolve_interface_for_if_entry(target_entry)?;

                let is_multi_hop =
                    ctx.edge_is_multi_hop(&source_interface_id, &target_interface_id);

                // Build label from port descriptions: "Gi0/1 ↔ Gi0/2"
                let label = Some(format!(
                    "{} ↔ {}",
                    source_entry.display_name(),
                    target_entry.display_name()
                ));

                Some(Edge {
                    id: Uuid::new_v4(),
                    source: source_interface_id,
                    target: target_interface_id,
                    edge_type: EdgeType::PhysicalLink {
                        source_if_entry_id: source_entry.id,
                        target_if_entry_id: target_entry.id,
                        protocol: DiscoveryProtocol::LLDP, // TODO: Support CDP when implemented
                    },
                    label,
                    source_handle: EdgeHandle::Bottom,
                    target_handle: EdgeHandle::Top,
                    is_multi_hop,
                    classification: EdgeClassification::default(),
                })
            })
            .collect()
    }

    /// Add edges to a petgraph Graph
    pub fn add_edges_to_graph(
        graph: &mut Graph<Node, Edge>,
        node_indices: &HashMap<Uuid, NodeIndex>,
        edges: Vec<Edge>,
    ) {
        for edge in edges {
            if let (Some(&src_idx), Some(&tgt_idx)) = (
                node_indices.get(&edge.source),
                node_indices.get(&edge.target),
            ) {
                graph.add_edge(src_idx, tgt_idx, edge);
            }
        }
    }

    pub fn edge_from_service_bindings(
        ctx: &TopologyContext,
        source_binding_id: Uuid,
        target_binding_id: Uuid,
        dependency: &Dependency,
    ) -> Option<Edge> {
        let source_interface = ctx.services.iter().find_map(|s| {
            if let Some(source_binding) = s.get_binding(source_binding_id) {
                return Some(source_binding.interface_id());
            }
            None
        });

        let target_interface = ctx.services.iter().find_map(|s| {
            if let Some(target_binding) = s.get_binding(target_binding_id) {
                return Some(target_binding.interface_id());
            }
            None
        });

        let (Some(Some(source_interface)), Some(Some(target_interface))) =
            (source_interface, target_interface)
        else {
            return None;
        };

        let is_multi_hop = ctx.edge_is_multi_hop(&source_interface, &target_interface);

        // If edge is intra-subnet, don't label - gets too messy
        let label = if ctx
            .get_subnet_from_interface_id(source_interface)
            .map(|s| s.id)
            == ctx
                .get_subnet_from_interface_id(target_interface)
                .map(|s| s.id)
        {
            None
        } else {
            Some(dependency.base.name.to_string())
        };

        Some(Edge {
            id: Uuid::new_v4(),
            source: source_interface,
            target: target_interface,
            edge_type: match dependency.base.dependency_type {
                DependencyType::HubAndSpoke => EdgeType::HubAndSpoke {
                    source_binding_id,
                    target_binding_id,
                    group_id: dependency.id,
                },
                DependencyType::RequestPath => EdgeType::RequestPath {
                    source_binding_id,
                    target_binding_id,
                    group_id: dependency.id,
                },
            },
            label,
            source_handle: EdgeHandle::Bottom,
            target_handle: EdgeHandle::Top,
            is_multi_hop,
            classification: EdgeClassification::default(),
        })
    }
}
