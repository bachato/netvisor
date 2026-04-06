use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use crate::server::{
    services::r#impl::categories::ServiceCategory,
    topology::types::{
        grouping::{ElementRule, GraphRule},
        nodes::{ContainerType, Node, NodeType},
    },
};

/// Data resolved from an element node for matching against element rules.
#[derive(Clone)]
pub struct ElementMatchData {
    pub categories: HashSet<ServiceCategory>,
    pub tag_ids: HashSet<Uuid>,
    /// The host ID of the virtualizer managing this element (for ByVirtualizer grouping).
    pub virtualizer_host_id: Option<Uuid>,
    /// The Docker Compose project name (for ByStack grouping).
    pub compose_project: Option<String>,
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
    element_rules: &[GraphRule<ElementRule>],
    resolve_element: impl Fn(&Node) -> Option<ElementMatchData>,
) {
    apply_element_rules_with_titles(nodes, element_rules, resolve_element, None);
}

/// Apply element rules with optional virtualizer title mapping.
/// `virtualizer_titles` maps virtualizer host IDs to display names (for ByVirtualizer subcontainers).
pub fn apply_element_rules_with_titles(
    nodes: &mut Vec<Node>,
    element_rules: &[GraphRule<ElementRule>],
    resolve_element: impl Fn(&Node) -> Option<ElementMatchData>,
    virtualizer_titles: Option<&HashMap<Uuid, String>>,
) {
    if element_rules.is_empty() {
        return;
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

    for GraphRule { id: rule_id, rule } in element_rules {
        match rule {
            ElementRule::ByVirtualizer => {
                // ByVirtualizer groups elements by their virtualizer_host_id.
                // Each unique virtualizer gets a Virtualizer subcontainer.
                // Unclaimed elements with no virtualizer get a BareMetal subcontainer.
                for (parent_id, element_ids) in &elements_by_container {
                    let unclaimed: Vec<Uuid> = element_ids
                        .iter()
                        .filter(|id| !claimed.contains(id))
                        .copied()
                        .collect();
                    if unclaimed.is_empty() {
                        continue;
                    }

                    // Group by virtualizer_host_id
                    let mut by_virtualizer: HashMap<Option<Uuid>, Vec<Uuid>> = HashMap::new();
                    for id in &unclaimed {
                        let virt_id = match_data.get(id).and_then(|d| d.virtualizer_host_id);
                        by_virtualizer.entry(virt_id).or_default().push(*id);
                    }

                    for (virt_host_id, ids) in by_virtualizer {
                        // Only create Virtualizer subcontainers for hosts that have a virtualizer.
                        // Hosts without a virtualizer (None) stay ungrouped in their parent.
                        let Some(vid) = virt_host_id else {
                            continue;
                        };

                        let group_key = format!("{parent_id}:{rule_id}:{vid}");
                        let group_id = Uuid::new_v5(&Uuid::NAMESPACE_OID, group_key.as_bytes());

                        new_containers.push(Node {
                            id: group_id,
                            node_type: NodeType::Container {
                                container_type: ContainerType::Virtualizer,
                                parent_container_id: Some(*parent_id),
                                layer_hint: None,
                                icon: None,
                                color: None,
                                associated_service_definition: None,
                            },
                            position: Default::default(),
                            size: Default::default(),
                            header: virtualizer_titles
                                .as_ref()
                                .and_then(|t| t.get(&vid).cloned()),
                            element_rule_id: Some(*rule_id),
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
                                layer_hint: None,
                                icon: None,
                                color: None,
                                associated_service_definition: None,
                            },
                            position: Default::default(),
                            size: Default::default(),
                            header: Some(project),
                            element_rule_id: Some(*rule_id),
                        });

                        for id in &ids {
                            reassignments.insert(*id, group_id);
                        }
                        claimed.extend(ids);
                    }
                }
            }
            ElementRule::ByServiceCategory { categories, title } => {
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
                            layer_hint: None,
                            icon: None,
                            color: None,
                            associated_service_definition: None,
                        },
                        position: Default::default(),
                        size: Default::default(),
                        header: title.clone(),
                        element_rule_id: Some(*rule_id),
                    });

                    for id in &matched_ids {
                        reassignments.insert(*id, group_id);
                    }
                    claimed.extend(matched_ids);
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
                            layer_hint: None,
                            icon: None,
                            color: None,
                            associated_service_definition: None,
                        },
                        position: Default::default(),
                        size: Default::default(),
                        header: title.clone(),
                        element_rule_id: Some(*rule_id),
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
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::topology::types::{grouping::GraphRule, nodes::ElementEntityType};

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
            virtualizer_host_id: None,
            compose_project: compose_project.map(String::from),
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

        let rules = vec![GraphRule::new(ElementRule::ByStack)];
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

        let rules = vec![GraphRule::new(ElementRule::ByStack)];
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

        let rules = vec![GraphRule::new(ElementRule::ByStack)];
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
