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
pub struct ElementMatchData {
    pub categories: HashSet<ServiceCategory>,
    pub tag_ids: HashSet<Uuid>,
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
        for (parent_id, element_ids) in &elements_by_container {
            let matched_ids: HashSet<Uuid> = element_ids
                .iter()
                .filter(|id| !claimed.contains(id))
                .filter(|id| {
                    let Some(data) = match_data.get(id) else {
                        return false;
                    };
                    match rule {
                        ElementRule::ByServiceCategory { categories, .. } => {
                            categories.iter().any(|c| data.categories.contains(c))
                        }
                        ElementRule::ByTag { tag_ids, .. } => {
                            tag_ids.iter().any(|t| data.tag_ids.contains(t))
                        }
                    }
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

            let (container_type, title) = match rule {
                ElementRule::ByServiceCategory { title, .. } => {
                    (ContainerType::NestedServiceCategory, title.clone())
                }
                ElementRule::ByTag { title, .. } => (ContainerType::NestedTag, title.clone()),
            };

            new_containers.push(Node {
                id: group_id,
                node_type: NodeType::Container {
                    container_type,
                    parent_container_id: Some(*parent_id),
                    layer_hint: None,
                    icon: None,
                    color: None,
                },
                position: Default::default(),
                size: Default::default(),
                header: title,
                element_rule_id: Some(*rule_id),
            });

            for id in &matched_ids {
                reassignments.insert(*id, group_id);
            }
            claimed.extend(matched_ids);
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
