use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use crate::server::{
    hosts::r#impl::base::Host,
    interfaces::r#impl::base::IfOperStatus,
    services::r#impl::{base::Service, categories::ServiceCategory},
    shared::entities::EntityDiscriminants,
    topology::types::{
        grouping::{
            ElementRule, GraphRule, IdentifiedRule, InlineGroup, InlineGroupRole, PlacementDecision,
        },
        nodes::{ContainerType, Node, NodeType},
    },
};

/// Data resolved from an element node for matching against element rules.
#[derive(Clone)]
pub struct ElementMatchData {
    pub categories: HashSet<ServiceCategory>,
    pub tag_ids: HashSet<Uuid>,
    /// The entity type of this element (Host, Service, etc.) for rule filtering.
    pub element_entity: EntityDiscriminants,
    /// The service ID of the virtualizer managing this element (for ByHypervisor/ByContainerRuntime grouping).
    pub virtualizer_service_id: Option<Uuid>,
    /// The Docker Compose project name (for ByStack grouping).
    pub compose_project: Option<String>,
    /// Native VLAN entity UUID on this port (for ByVLAN grouping).
    pub native_vlan_id: Option<Uuid>,
    /// Native VLAN number (for grouping key and display).
    pub vlan_number: Option<u16>,
    /// Native VLAN name (for display in container header).
    pub vlan_name: Option<String>,
    /// Whether this port has tagged VLANs (for ByTrunkPort grouping).
    pub is_trunk_port: bool,
    /// Port operational status (for ByPortOpStatus grouping).
    pub oper_status: Option<IfOperStatus>,
}

/// Context for computing inline placement decisions.
pub struct InlinePlacementContext<'a> {
    pub hosts: &'a HashMap<Uuid, &'a Host>,
    pub service_lookup: &'a HashMap<Uuid, &'a Service>,
    /// virtualizer_service_id → managed container service IDs
    pub virt_to_container_svcs: &'a HashMap<Uuid, Vec<Uuid>>,
}

/// Compute inline placement decisions for all applicable element rules.
///
/// Returns a map of entity_id → PlacementDecision for entities that should be
/// inlined on another node rather than having their own element.
///
/// The match on ElementRule is **exhaustive** — adding a new variant forces
/// the developer to decide whether it produces inline placements.
pub fn compute_inline_placements(
    rules: &[IdentifiedRule<ElementRule>],
    ctx: &InlinePlacementContext,
) -> HashMap<Uuid, PlacementDecision> {
    let mut result = HashMap::new();
    for IdentifiedRule { rule, .. } in rules {
        let placements: HashMap<Uuid, PlacementDecision> = match rule {
            ElementRule::ByHypervisor => {
                // Services on VM hosts are inlined on the VM host element.
                // The hypervisor rule groups VMs under their hypervisor; as a consequence,
                // VMs are elements (not containers), so services on them can't have their
                // own element nodes.
                let mut map = HashMap::new();
                for (host_id, host) in ctx.hosts.iter() {
                    if host.base.virtualization.is_none() {
                        continue;
                    }
                    // Find all services on this VM host
                    for svc in ctx.service_lookup.values() {
                        if svc.base.host_id == *host_id {
                            // Skip services that ByContainerRuntime will handle with group info
                            if svc.base.virtualization.is_some() {
                                continue;
                            }
                            map.insert(
                                svc.id,
                                PlacementDecision::InlineOn {
                                    node_id: *host_id,
                                    inline_group: None,
                                },
                            );
                        }
                    }
                }
                map
            }
            ElementRule::ByContainerRuntime => {
                // Docker runtimes and their containers on VM hosts are inlined on the
                // VM host element, with InlineGroup metadata for the dotted-border
                // visual grouping in the frontend.
                let mut map = HashMap::new();
                for (&virt_svc_id, container_svc_ids) in ctx.virt_to_container_svcs {
                    let Some(virt_svc) = ctx.service_lookup.get(&virt_svc_id) else {
                        continue;
                    };
                    let Some(host) = ctx.hosts.get(&virt_svc.base.host_id) else {
                        continue;
                    };
                    // Only inline when the virtualizer runs on a VM
                    if host.base.virtualization.is_none() {
                        continue;
                    }
                    let vm_host_id = virt_svc.base.host_id;

                    // Docker runtime → Header role
                    map.insert(
                        virt_svc_id,
                        PlacementDecision::InlineOn {
                            node_id: vm_host_id,
                            inline_group: Some(InlineGroup {
                                group_id: virt_svc_id,
                                role: InlineGroupRole::Header,
                            }),
                        },
                    );

                    // Container services → Member role
                    for &svc_id in container_svc_ids {
                        map.insert(
                            svc_id,
                            PlacementDecision::InlineOn {
                                node_id: vm_host_id,
                                inline_group: Some(InlineGroup {
                                    group_id: virt_svc_id,
                                    role: InlineGroupRole::Member,
                                }),
                            },
                        );
                    }
                }
                map
            }
            // These rules only create subcontainers — no inline placements.
            ElementRule::ByStack
            | ElementRule::ByServiceCategory { .. }
            | ElementRule::ByTag { .. }
            | ElementRule::ByTrunkPort
            | ElementRule::ByVLAN
            | ElementRule::ByPortOpStatus => HashMap::new(),
        };
        result.extend(placements);
    }
    result
}

/// Result of applying element rules — contains the reassignments made by subcontainer grouping.
pub struct ElementRuleResult {
    /// Maps element node ID → new container ID (the subcontainer it was reassigned to).
    /// Used by builders to derive virtualizer→subcontainer mappings for edge resolution.
    pub reassignments: HashMap<Uuid, Uuid>,
}

/// Apply element rules to nodes, creating nested subcontainers within each parent container.
///
/// `resolve_element` maps an Element node to its matchable data. Returns `None` for nodes
/// that should be skipped (e.g. not found in the lookup). Each perspective provides its own
/// resolver:
/// - L3: resolves via host_id → host's service categories and host's tags
/// - Application: resolves via node.id (= service.id) → service's category and tags
///
/// First-match-wins: nodes claimed by an earlier rule are not reassigned.
pub fn apply_element_rules(
    nodes: &mut Vec<Node>,
    element_rules: &[IdentifiedRule<ElementRule>],
    resolve_element: impl Fn(&Node) -> Option<ElementMatchData>,
) -> ElementRuleResult {
    apply_element_rules_with_titles(nodes, element_rules, resolve_element, None)
}

/// Apply element rules with optional virtualizer title mapping.
/// `virtualizer_titles` maps virtualizer service IDs to display names (for ByHypervisor/ByContainerRuntime subcontainers).
pub fn apply_element_rules_with_titles(
    nodes: &mut Vec<Node>,
    element_rules: &[IdentifiedRule<ElementRule>],
    resolve_element: impl Fn(&Node) -> Option<ElementMatchData>,
    virtualizer_titles: Option<&HashMap<Uuid, String>>,
) -> ElementRuleResult {
    if element_rules.is_empty() {
        return ElementRuleResult {
            reassignments: HashMap::new(),
        };
    }

    // Collect element nodes grouped by their current parent container
    let mut elements_by_container: HashMap<Uuid, Vec<Uuid>> = HashMap::new();
    for node in nodes.iter() {
        if let NodeType::Element { container_id, .. } = &node.node_type {
            elements_by_container
                .entry(*container_id)
                .or_default()
                .push(node.id);
        }
    }

    // Resolve match data for all element nodes upfront
    let match_data: HashMap<Uuid, ElementMatchData> = nodes
        .iter()
        .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
        .filter_map(|n| resolve_element(n).map(|data| (n.id, data)))
        .collect();

    let mut claimed: HashSet<Uuid> = HashSet::new();
    // Collect new subcontainers to add after iteration
    let mut new_containers: Vec<Node> = Vec::new();
    // Collect reassignments: node_id → new container_id
    let mut reassignments: HashMap<Uuid, Uuid> = HashMap::new();

    for IdentifiedRule { id: rule_id, rule } in element_rules {
        match rule {
            ElementRule::ByHypervisor | ElementRule::ByContainerRuntime => {
                // ByHypervisor groups VM (Host) elements by their hypervisor service.
                // ByContainerRuntime groups container (Service) elements by their runtime.
                // Each unique virtualizer service gets its own subcontainer.
                // Elements with no virtualizer stay ungrouped in their parent container.
                let (container_type, target_entity) = if matches!(rule, ElementRule::ByHypervisor) {
                    (ContainerType::Hypervisor, EntityDiscriminants::Host)
                } else {
                    (
                        ContainerType::ContainerRuntime,
                        EntityDiscriminants::Service,
                    )
                };

                for (parent_id, element_ids) in &elements_by_container {
                    // Only consider elements matching the target entity type
                    let unclaimed: Vec<Uuid> = element_ids
                        .iter()
                        .filter(|id| !claimed.contains(id))
                        .filter(|id| {
                            match_data
                                .get(id)
                                .is_some_and(|d| d.element_entity == target_entity)
                        })
                        .copied()
                        .collect();
                    if unclaimed.is_empty() {
                        continue;
                    }

                    // Group by virtualizer_service_id
                    let mut by_virtualizer: HashMap<Option<Uuid>, Vec<Uuid>> = HashMap::new();
                    for id in &unclaimed {
                        let virt_id = match_data.get(id).and_then(|d| d.virtualizer_service_id);
                        by_virtualizer.entry(virt_id).or_default().push(*id);
                    }

                    for (virt_host_id, ids) in by_virtualizer {
                        let Some(vid) = virt_host_id else {
                            continue;
                        };

                        let group_key = format!("{parent_id}:{rule_id}:{vid}");
                        let group_id = Uuid::new_v5(&Uuid::NAMESPACE_OID, group_key.as_bytes());

                        new_containers.push(Node {
                            id: group_id,
                            node_type: NodeType::Container {
                                container_type,
                                parent_container_id: Some(*parent_id),
                                entity_id: None,
                                icon: None,
                                color: None,
                                associated_service_definition: virtualizer_titles
                                    .as_ref()
                                    .and_then(|t| t.get(&vid).cloned()),
                                element_rule_id: Some(*rule_id),
                                will_accept_edges: rule.will_accept_edges(),
                            },
                            position: Default::default(),
                            size: Default::default(),
                            header: virtualizer_titles
                                .as_ref()
                                .and_then(|t| t.get(&vid).cloned()),
                        });

                        for id in &ids {
                            reassignments.insert(*id, group_id);
                        }
                        claimed.extend(ids);
                    }
                }
            }
            ElementRule::ByStack => {
                // ByStack groups elements by their compose_project.
                // Elements with the same compose_project share a Stack subcontainer.
                // Elements with no compose_project remain ungrouped.
                for (parent_id, element_ids) in &elements_by_container {
                    let unclaimed: Vec<Uuid> = element_ids
                        .iter()
                        .filter(|id| !claimed.contains(id))
                        .copied()
                        .collect();
                    if unclaimed.is_empty() {
                        continue;
                    }

                    // Group by compose_project (only Some values)
                    let mut by_stack: HashMap<String, Vec<Uuid>> = HashMap::new();
                    for id in &unclaimed {
                        if let Some(project) =
                            match_data.get(id).and_then(|d| d.compose_project.clone())
                        {
                            by_stack.entry(project).or_default().push(*id);
                        }
                    }

                    for (project, ids) in by_stack {
                        let group_id = Uuid::new_v5(
                            &Uuid::NAMESPACE_OID,
                            format!("stack:{project}:{parent_id}").as_bytes(),
                        );

                        new_containers.push(Node {
                            id: group_id,
                            node_type: NodeType::Container {
                                container_type: ContainerType::Stack,
                                parent_container_id: Some(*parent_id),
                                entity_id: None,
                                icon: None,
                                color: None,
                                associated_service_definition: None,
                                element_rule_id: Some(*rule_id),
                                will_accept_edges: rule.will_accept_edges(),
                            },
                            position: Default::default(),
                            size: Default::default(),
                            header: Some(project),
                        });

                        for id in &ids {
                            reassignments.insert(*id, group_id);
                        }
                        claimed.extend(ids);
                    }
                }
            }
            ElementRule::ByServiceCategory {
                categories, title, ..
            } => {
                for (parent_id, element_ids) in &elements_by_container {
                    let matched_ids: HashSet<Uuid> = element_ids
                        .iter()
                        .filter(|id| !claimed.contains(id))
                        .filter(|id| {
                            match_data.get(id).is_some_and(|d| {
                                categories.iter().any(|c| d.categories.contains(c))
                            })
                        })
                        .copied()
                        .collect();

                    if matched_ids.is_empty() {
                        continue;
                    }

                    let group_id = Uuid::new_v5(
                        &Uuid::NAMESPACE_OID,
                        format!("{parent_id}:{rule_id}").as_bytes(),
                    );

                    new_containers.push(Node {
                        id: group_id,
                        node_type: NodeType::Container {
                            container_type: ContainerType::NestedServiceCategory,
                            parent_container_id: Some(*parent_id),
                            entity_id: None,
                            icon: None,
                            color: None,
                            associated_service_definition: None,
                            element_rule_id: Some(*rule_id),
                            will_accept_edges: rule.will_accept_edges(),
                        },
                        position: Default::default(),
                        size: Default::default(),
                        header: title.clone(),
                    });

                    for id in &matched_ids {
                        reassignments.insert(*id, group_id);
                    }
                    claimed.extend(matched_ids);
                }
            }
            ElementRule::ByTrunkPort => {
                // Groups trunk ports (ports with tagged VLANs) into a "Trunk Ports" subcontainer.
                for (parent_id, element_ids) in &elements_by_container {
                    let matched_ids: Vec<Uuid> = element_ids
                        .iter()
                        .filter(|id| !claimed.contains(id))
                        .filter(|id| match_data.get(id).is_some_and(|d| d.is_trunk_port))
                        .copied()
                        .collect();

                    if matched_ids.is_empty() {
                        continue;
                    }

                    let group_key = format!("{parent_id}:{rule_id}:trunk");
                    let group_id = Uuid::new_v5(&Uuid::NAMESPACE_OID, group_key.as_bytes());

                    new_containers.push(Node {
                        id: group_id,
                        node_type: NodeType::Container {
                            container_type: ContainerType::TrunkPort,
                            parent_container_id: Some(*parent_id),
                            entity_id: None,
                            icon: None,
                            color: None,
                            associated_service_definition: None,
                            element_rule_id: Some(*rule_id),
                            will_accept_edges: rule.will_accept_edges(),
                        },
                        position: Default::default(),
                        size: Default::default(),
                        header: Some("Trunk Ports".to_string()),
                    });

                    for id in &matched_ids {
                        reassignments.insert(*id, group_id);
                    }
                    claimed.extend(matched_ids);
                }
            }
            ElementRule::ByVLAN => {
                // Groups access ports by native VLAN number into per-VLAN subcontainers.
                for (parent_id, element_ids) in &elements_by_container {
                    let unclaimed: Vec<Uuid> = element_ids
                        .iter()
                        .filter(|id| !claimed.contains(id))
                        .copied()
                        .collect();
                    if unclaimed.is_empty() {
                        continue;
                    }

                    // Group by vlan_number (u16) for consistent grouping
                    let mut by_vlan: HashMap<u16, Vec<Uuid>> = HashMap::new();
                    for id in &unclaimed {
                        if let Some(vlan_number) = match_data.get(id).and_then(|d| d.vlan_number) {
                            by_vlan.entry(vlan_number).or_default().push(*id);
                        }
                    }

                    for (vlan_number, ids) in by_vlan {
                        let group_key = format!("{parent_id}:{rule_id}:vlan:{vlan_number}");
                        let group_id = Uuid::new_v5(&Uuid::NAMESPACE_OID, group_key.as_bytes());

                        // Look up name from first element's match data
                        let vlan_name = ids
                            .first()
                            .and_then(|id| match_data.get(id))
                            .and_then(|d| d.vlan_name.as_deref());

                        let header = match vlan_name {
                            Some(name) => format!("VLAN {} ({})", vlan_number, name),
                            None => format!("VLAN {}", vlan_number),
                        };

                        new_containers.push(Node {
                            id: group_id,
                            node_type: NodeType::Container {
                                container_type: ContainerType::VLAN,
                                parent_container_id: Some(*parent_id),
                                entity_id: None,
                                icon: None,
                                color: None,
                                associated_service_definition: None,
                                element_rule_id: Some(*rule_id),
                                will_accept_edges: rule.will_accept_edges(),
                            },
                            position: Default::default(),
                            size: Default::default(),
                            header: Some(header),
                        });

                        for id in &ids {
                            reassignments.insert(*id, group_id);
                        }
                        claimed.extend(ids);
                    }
                }
            }
            ElementRule::ByPortOpStatus => {
                // Groups ports by operational status into per-status subcontainers.
                for (parent_id, element_ids) in &elements_by_container {
                    let unclaimed: Vec<Uuid> = element_ids
                        .iter()
                        .filter(|id| !claimed.contains(id))
                        .copied()
                        .collect();
                    if unclaimed.is_empty() {
                        continue;
                    }

                    // Group by oper_status
                    let mut by_status: HashMap<IfOperStatus, Vec<Uuid>> = HashMap::new();
                    for id in &unclaimed {
                        if let Some(status) = match_data.get(id).and_then(|d| d.oper_status) {
                            by_status.entry(status).or_default().push(*id);
                        }
                    }

                    for (status, ids) in by_status {
                        let status_name = format!("{:?}", status);
                        let group_key = format!("{parent_id}:{rule_id}:status:{}", status as i32);
                        let group_id = Uuid::new_v5(&Uuid::NAMESPACE_OID, group_key.as_bytes());

                        // Color per status for the filled circle icon
                        let color = match status {
                            IfOperStatus::Up => "Green",
                            IfOperStatus::Down | IfOperStatus::LowerLayerDown => "Red",
                            IfOperStatus::Testing => "Amber",
                            IfOperStatus::Dormant => "Blue",
                            IfOperStatus::Unknown => "Gray",
                            IfOperStatus::NotPresent => "Gray",
                        };

                        new_containers.push(Node {
                            id: group_id,
                            node_type: NodeType::Container {
                                container_type: ContainerType::PortOpStatus,
                                parent_container_id: Some(*parent_id),
                                entity_id: None,
                                icon: None,
                                color: Some(color.to_string()),
                                associated_service_definition: None,
                                element_rule_id: Some(*rule_id),
                                will_accept_edges: rule.will_accept_edges(),
                            },
                            position: Default::default(),
                            size: Default::default(),
                            header: Some(status_name),
                        });

                        for id in &ids {
                            reassignments.insert(*id, group_id);
                        }
                        claimed.extend(ids);
                    }
                }
            }
            ElementRule::ByTag { tag_ids, title } => {
                for (parent_id, element_ids) in &elements_by_container {
                    let matched_ids: HashSet<Uuid> = element_ids
                        .iter()
                        .filter(|id| !claimed.contains(id))
                        .filter(|id| {
                            match_data
                                .get(id)
                                .is_some_and(|d| tag_ids.iter().any(|t| d.tag_ids.contains(t)))
                        })
                        .copied()
                        .collect();

                    if matched_ids.is_empty() {
                        continue;
                    }

                    let group_id = Uuid::new_v5(
                        &Uuid::NAMESPACE_OID,
                        format!("{parent_id}:{rule_id}").as_bytes(),
                    );

                    new_containers.push(Node {
                        id: group_id,
                        node_type: NodeType::Container {
                            container_type: ContainerType::NestedTag,
                            parent_container_id: Some(*parent_id),
                            entity_id: None,
                            icon: None,
                            color: None,
                            associated_service_definition: None,
                            element_rule_id: Some(*rule_id),
                            will_accept_edges: rule.will_accept_edges(),
                        },
                        position: Default::default(),
                        size: Default::default(),
                        header: title.clone(),
                    });

                    for id in &matched_ids {
                        reassignments.insert(*id, group_id);
                    }
                    claimed.extend(matched_ids);
                }
            }
        }
    }

    // Apply reassignments
    for node in nodes.iter_mut() {
        if let NodeType::Element {
            ref mut container_id,
            ..
        } = node.node_type
            && let Some(new_id) = reassignments.get(&node.id)
        {
            *container_id = *new_id;
        }
    }

    nodes.extend(new_containers);

    ElementRuleResult { reassignments }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::topology::types::{grouping::IdentifiedRule, nodes::ElementEntityType};

    fn make_element(id: Uuid, container_id: Uuid) -> Node {
        Node::element(
            id,
            container_id,
            Uuid::new_v4(),
            ElementEntityType::Service {},
        )
    }

    fn make_match_data(compose_project: Option<&str>) -> ElementMatchData {
        ElementMatchData {
            categories: HashSet::new(),
            tag_ids: HashSet::new(),
            element_entity: EntityDiscriminants::Service,
            virtualizer_service_id: None,
            compose_project: compose_project.map(String::from),
            native_vlan_id: None,
            vlan_number: None,
            vlan_name: None,
            is_trunk_port: false,
            oper_status: None,
        }
    }

    #[test]
    fn by_stack_groups_same_compose_project() {
        let container_id = Uuid::new_v4();
        let svc1 = Uuid::new_v4();
        let svc2 = Uuid::new_v4();
        let mut nodes = vec![
            make_element(svc1, container_id),
            make_element(svc2, container_id),
        ];

        let match_map: HashMap<Uuid, ElementMatchData> = [
            (svc1, make_match_data(Some("media-stack"))),
            (svc2, make_match_data(Some("media-stack"))),
        ]
        .into();

        let rules = vec![IdentifiedRule::new(ElementRule::ByStack)];
        apply_element_rules(&mut nodes, &rules, |node| match_map.get(&node.id).cloned());

        // Both services should be in the same new container
        let svc1_container = nodes
            .iter()
            .find(|n| n.id == svc1)
            .map(|n| match &n.node_type {
                NodeType::Element { container_id, .. } => *container_id,
                _ => panic!("expected element"),
            })
            .unwrap();
        let svc2_container = nodes
            .iter()
            .find(|n| n.id == svc2)
            .map(|n| match &n.node_type {
                NodeType::Element { container_id, .. } => *container_id,
                _ => panic!("expected element"),
            })
            .unwrap();
        assert_eq!(svc1_container, svc2_container);
        assert_ne!(svc1_container, container_id); // moved out of original container

        // Verify the Stack subcontainer was created
        let stack_container = nodes.iter().find(|n| n.id == svc1_container).unwrap();
        assert!(matches!(
            stack_container.node_type,
            NodeType::Container {
                container_type: ContainerType::Stack,
                ..
            }
        ));
        assert_eq!(stack_container.header.as_deref(), Some("media-stack"));
    }

    #[test]
    fn by_stack_no_compose_project_stays_ungrouped() {
        let container_id = Uuid::new_v4();
        let svc1 = Uuid::new_v4();
        let mut nodes = vec![make_element(svc1, container_id)];

        let match_map: HashMap<Uuid, ElementMatchData> = [(svc1, make_match_data(None))].into();

        let rules = vec![IdentifiedRule::new(ElementRule::ByStack)];
        apply_element_rules(&mut nodes, &rules, |node| match_map.get(&node.id).cloned());

        // Should stay in original container
        let svc1_container = match &nodes[0].node_type {
            NodeType::Element { container_id, .. } => *container_id,
            _ => panic!("expected element"),
        };
        assert_eq!(svc1_container, container_id);

        // No new containers created
        assert_eq!(nodes.len(), 1);
    }

    #[test]
    fn by_stack_different_projects_get_different_containers() {
        let container_id = Uuid::new_v4();
        let svc1 = Uuid::new_v4();
        let svc2 = Uuid::new_v4();
        let svc3 = Uuid::new_v4();
        let mut nodes = vec![
            make_element(svc1, container_id),
            make_element(svc2, container_id),
            make_element(svc3, container_id),
        ];

        let match_map: HashMap<Uuid, ElementMatchData> = [
            (svc1, make_match_data(Some("media-stack"))),
            (svc2, make_match_data(Some("monitoring"))),
            (svc3, make_match_data(Some("media-stack"))),
        ]
        .into();

        let rules = vec![IdentifiedRule::new(ElementRule::ByStack)];
        apply_element_rules(&mut nodes, &rules, |node| match_map.get(&node.id).cloned());

        let get_container = |id: Uuid| -> Uuid {
            nodes
                .iter()
                .find(|n| n.id == id)
                .map(|n| match &n.node_type {
                    NodeType::Element { container_id, .. } => *container_id,
                    _ => panic!("expected element"),
                })
                .unwrap()
        };

        // svc1 and svc3 share media-stack
        assert_eq!(get_container(svc1), get_container(svc3));
        // svc2 is in a different container (monitoring)
        assert_ne!(get_container(svc1), get_container(svc2));
        // Both are moved out of original
        assert_ne!(get_container(svc1), container_id);
        assert_ne!(get_container(svc2), container_id);

        // Two Stack subcontainers created
        let stack_count = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::Stack,
                        ..
                    }
                )
            })
            .count();
        assert_eq!(stack_count, 2);
    }
}
