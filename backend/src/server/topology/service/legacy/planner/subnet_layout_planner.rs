use itertools::Itertools;
use std::collections::{BTreeMap, HashMap, HashSet};
use uuid::Uuid;

use crate::server::{
    hosts::r#impl::base::Host,
    interfaces::r#impl::base::Interface,
    services::r#impl::base::Service,
    subnets::r#impl::types::SubnetType,
    topology::{
        service::{
            context::TopologyContext,
            legacy::planner::{
                anchor_planner::ChildAnchorPlanner,
                child_planner::ChildNodePlanner,
                utils::{NODE_PADDING, PlannerUtils, SUBNET_PADDING},
            },
        },
        types::{
            edges::Edge,
            grouping::{GraphRule, GroupingConfig, LeafRule},
            layout::{Ixy, NodeLayout, SubnetLayout, Uxy},
            nodes::{ContainerType, LeafEntityType, Node, NodeType, SubnetChild},
        },
    },
};

pub struct SubnetLayoutPlanner {
    consolidated_docker_subnets: HashMap<Uuid, Vec<Uuid>>,
}

impl Default for SubnetLayoutPlanner {
    fn default() -> Self {
        Self::new()
    }
}

impl SubnetLayoutPlanner {
    pub fn new() -> Self {
        Self {
            consolidated_docker_subnets: HashMap::new(),
        }
    }

    pub fn get_consolidated_docker_subnets(&self) -> &HashMap<Uuid, Vec<Uuid>> {
        &self.consolidated_docker_subnets
    }

    /// Main entry point: calculate subnet layouts and create all child nodes
    pub fn create_subnet_child_nodes(
        &mut self,
        ctx: &TopologyContext,
        all_edges: &mut [Edge],
        grouping: &GroupingConfig,
        docker_bridge_host_subnet_id_to_group_on: HashMap<Uuid, Uuid>,
    ) -> (HashMap<Uuid, SubnetLayout>, Vec<Node>) {
        let children_by_subnet = self.group_children_by_subnet(
            ctx,
            all_edges,
            grouping,
            docker_bridge_host_subnet_id_to_group_on,
        );
        let mut child_nodes = Vec::new();

        let subnet_sizes: HashMap<Uuid, SubnetLayout> = children_by_subnet
            .iter()
            .map(|(subnet_id, children)| {
                let size = self.calculate_subnet_size(*subnet_id, children, ctx, &mut child_nodes);
                (*subnet_id, SubnetLayout { size })
            })
            .collect();

        (subnet_sizes, child_nodes)
    }

    fn determine_subnet_child_header_text(
        &self,
        ctx: &TopologyContext,
        interface: &Interface,
        host: &Host,
        subnet_type: &SubnetType,
    ) -> Option<String> {
        // P1: Show virtualization provider, if any
        let host_interfaces = ctx.get_interfaces_for_host(host.id);
        if let Some(service) = ctx.get_host_is_virtualized_by(&host.id) {
            let virtualization_service_host = ctx.get_host_by_id(service.base.host_id);

            let host_interface_subnet_ids: Vec<Uuid> =
                host_interfaces.iter().map(|i| i.base.subnet_id).collect();
            let virtualization_service_interface_subnet_ids: Vec<Uuid> = service
                .base
                .bindings
                .iter()
                .filter_map(|b| ctx.get_interface_by_id(b.interface_id()))
                .map(|i| i.base.subnet_id)
                .collect();

            // Find shared subnets to determine which interface to use
            let host_interface_subnet_ids_hashset: HashSet<&Uuid> =
                host_interface_subnet_ids.iter().collect();
            let virtualization_service_interface_subnet_ids_hashset: HashSet<&Uuid> =
                virtualization_service_interface_subnet_ids.iter().collect();

            let intersection: Vec<&Uuid> = host_interface_subnet_ids_hashset
                .intersection(&virtualization_service_interface_subnet_ids_hashset)
                .cloned()
                .collect();

            let hide_docker_bridge_vm_header = *subnet_type == SubnetType::DockerBridge
                && ctx.options.request.hide_vm_title_on_docker_container;

            if !hide_docker_bridge_vm_header {
                // If they have at least one interface on a common subnet
                // Use the IP address from that interface in the header text
                match intersection.first() {
                    Some(first) => {
                        if let Some(interface) =
                            host_interfaces.iter().find(|i| i.base.subnet_id == **first)
                            && host_interface_subnet_ids
                                .iter()
                                .filter(|i| i == first)
                                .count()
                                == 1
                            && virtualization_service_interface_subnet_ids
                                .iter()
                                .filter(|i| i == first)
                                .count()
                                == 1
                        {
                            let on = virtualization_service_host
                                .map(|h| h.base.name.clone())
                                .unwrap_or(interface.base.ip_address.to_string());

                            if on == service.base.name {
                                return Some(format!("VM: {}", service.base.name));
                            } else {
                                return Some(format!("VM: {} on {}", service.base.name, on));
                            }
                        }
                        return Some(format!("VM: {}", service.base.name));
                    }
                    _ => return Some(format!("VM: {}", service.base.name)),
                }
            }
        }

        let host_has_name = host.base.name != "Unknown Device" && !host.base.name.is_empty();

        // P2: Show docker container header with host name
        if *subnet_type == SubnetType::DockerBridge {
            let header_text = if host_has_name {
                Some("Docker @ ".to_owned() + &host.base.name.clone())
            } else {
                // Generate a label from non-docker interface, if there is one
                host_interfaces
                    .iter()
                    .find(|i| {
                        ctx.get_subnet_from_interface_id(i.id)
                            .map(|s| s.base.subnet_type != SubnetType::DockerBridge)
                            .unwrap_or(false)
                    })
                    .map(|i| "Docker @ ".to_owned() + &i.base.ip_address.to_string())
            };

            return header_text;
        }

        // P3: Show host if it differs from the first service name + isn't shown via interface edges
        // and if it also isn't just the interface IP
        let host_services = ctx.get_services_for_host(host.id);
        let first_service_name_matches_host_name = match host_services.first() {
            Some(first_service) => first_service.base.name == host.base.name,
            None => false,
        };

        let host_name_is_interface_ip = interface.base.ip_address.to_string() == host.base.name;

        // Count of other interfaces that will actually have a node (ie services on that interface > 0)
        // so an interface edge will be created
        let interfaces_with_node: Vec<&&Interface> = host_interfaces
            .iter()
            .filter(|i| !ctx.get_services_bound_to_interface(i.id).is_empty())
            .collect();

        if !host_name_is_interface_ip
            && !first_service_name_matches_host_name
            && host_has_name
            && interfaces_with_node.len() < 2
        {
            return Some(host.base.name.clone());
        }

        None
    }

    /// Group host interfaces by subnet
    /// If group_docker_bridges_by_host is true, all DockerBridge interfaces for a given host
    /// are consolidated into one subnet
    fn group_children_by_subnet(
        &mut self,
        ctx: &TopologyContext,
        all_edges: &mut [Edge],
        grouping: &GroupingConfig,
        docker_bridge_host_subnet_id_to_group_on: HashMap<Uuid, Uuid>,
    ) -> HashMap<Uuid, Vec<SubnetChild>> {
        let mut children_by_subnet: HashMap<Uuid, Vec<SubnetChild>> = HashMap::new();

        // Track DockerBridge interfaces by host (only used if grouping is enabled)
        // Map: (host_id, primary_subnet_id) -> Vec<subnet_id>)
        let mut docker_subnets_by_host: HashMap<(Uuid, Uuid), Vec<Uuid>> = HashMap::new();

        for interface in ctx.interfaces {
            let Some(host) = ctx.get_host_by_id(interface.base.host_id) else {
                continue;
            };
            let subnet = ctx.get_subnet_by_id(interface.base.subnet_id);
            if subnet
                .map(|s| s.base.subnet_type.exclude_from_topology())
                .unwrap_or(false)
            {
                continue;
            }
            let subnet_type = subnet.map(|s| s.base.subnet_type).unwrap_or_default();
            let services = ctx.services;

            let interface_bound_services: Vec<&Service> = services
                .iter()
                .filter(|s| {
                    // Services with a binding to the interface
                    s.base.bindings.iter().any(|b| match b.interface_id() {
                        // Service is bound to interface if ID matches
                        Some(binding_interface_id) if binding_interface_id == interface.id => true,
                        // If there's no interface, it's an L4 binding bound to all interfaces
                        None => true,
                        _ => false,
                    })
                })
                .collect();

            // Update source/target handles for edges
            let edges = ChildAnchorPlanner::plan_anchors(interface.id, all_edges, ctx);

            let header_text =
                self.determine_subnet_child_header_text(ctx, interface, host, &subnet_type);

            let child = SubnetChild {
                id: interface.id,
                host_id: host.id,
                size: Uxy::subnet_child_size_from_service_count(
                    &interface_bound_services,
                    interface.id,
                    header_text.is_some(),
                    ctx.options.request.hide_ports,
                ),
                header: header_text,
                interface_id: Some(interface.id),
                edges,
            };

            // Special handling for DockerBridge (only if grouping is enabled)
            if grouping.should_group_docker_bridges()
                && matches!(subnet_type, SubnetType::DockerBridge)
            {
                if let Some(subnet_grouping_id) =
                    docker_bridge_host_subnet_id_to_group_on.get(&host.id)
                {
                    docker_subnets_by_host
                        .entry((host.id, *subnet_grouping_id))
                        .or_default()
                        .push(interface.base.subnet_id);

                    children_by_subnet
                        .entry(*subnet_grouping_id)
                        .or_default()
                        .push(child);
                }
            } else {
                children_by_subnet
                    .entry(interface.base.subnet_id)
                    .or_default()
                    .push(child);
            }
        }

        // Consolidate all DockerBridge children into their primary subnet (only if grouping is enabled)
        if grouping.should_group_docker_bridges() {
            for ((_, grouping_id), mut subnet_ids) in docker_subnets_by_host {
                // Remove duplicates and sort for consistency
                subnet_ids.sort();
                subnet_ids.dedup();

                // Store the consolidation mapping
                self.consolidated_docker_subnets
                    .insert(grouping_id, subnet_ids);
            }
        }

        children_by_subnet
    }

    /// Calculate the size and layout of a subnet, creating child nodes
    fn calculate_subnet_size(
        &mut self,
        subnet_id: Uuid,
        children: &[SubnetChild],
        ctx: &TopologyContext,
        child_nodes: &mut Vec<Node>,
    ) -> Uxy {
        if children.is_empty() {
            return Uxy { x: 0, y: 0 };
        }

        // All children laid out together (no infra partitioning)
        let positions =
            ChildNodePlanner::calculate_anchor_based_positions(children, &NODE_PADDING, ctx);

        let grid_size =
            PlannerUtils::calculate_container_size_from_layouts(&positions, &NODE_PADDING);

        // Create leaf nodes for all children
        for child in children.iter() {
            if let Some(layout) = positions.get(&child.id) {
                child_nodes.push(Node {
                    id: child.id,
                    node_type: NodeType::LeafNode {
                        container_id: subnet_id,
                        leaf_type: LeafEntityType::Interface,
                        subnet_id,
                        host_id: child.host_id,
                        interface_id: child.interface_id,
                    },
                    position: layout.position,
                    size: child.size,
                    header: child.header.clone(),
                    leaf_rule_id: None,
                });
            }
        }

        // Create nested group containers for ByServiceCategory and ByTag rules
        self.create_nested_group_containers(subnet_id, children, ctx, child_nodes);

        grid_size
    }

    /// Create nested ContainerNodes for ByServiceCategory and ByTag grouping rules (ClientSide mode only).
    /// First-match-wins: nodes already claimed by an earlier rule are not reassigned.
    fn create_nested_group_containers(
        &self,
        subnet_id: Uuid,
        children: &[SubnetChild],
        ctx: &TopologyContext,
        child_nodes: &mut Vec<Node>,
    ) {
        let grouping = GroupingConfig::from_request_options(&ctx.options.request);
        let mut claimed: HashSet<Uuid> = HashSet::new();

        for GraphRule { id: rule_id, rule } in &grouping.leaf_rules {
            match rule {
                LeafRule::ByServiceCategory { categories, title } => {
                    let matched_child_ids: HashSet<Uuid> = children
                        .iter()
                        .filter(|child| {
                            !claimed.contains(&child.id)
                                && ctx.services.iter().any(|s| {
                                    s.base.host_id == child.host_id
                                        && categories
                                            .contains(&s.base.service_definition.category())
                                })
                        })
                        .map(|c| c.id)
                        .collect();

                    if matched_child_ids.is_empty() {
                        continue;
                    }

                    let group_id = Uuid::new_v4();
                    child_nodes.push(Node {
                        id: group_id,
                        node_type: NodeType::ContainerNode {
                            container_type: ContainerType::ServiceCategoryGroup,
                            parent_container_id: Some(subnet_id),
                            layer_hint: None,
                        },
                        position: Ixy { x: 0, y: 0 },
                        size: Uxy { x: 0, y: 0 },
                        header: title.clone(),
                        leaf_rule_id: Some(*rule_id),
                    });

                    for node in child_nodes.iter_mut() {
                        if matched_child_ids.contains(&node.id)
                            && let NodeType::LeafNode {
                                ref mut container_id,
                                ..
                            } = node.node_type
                        {
                            *container_id = group_id;
                        }
                    }
                    claimed.extend(&matched_child_ids);
                }
                LeafRule::ByTag { tag_ids, title } => {
                    let matched_host_ids = ctx.get_host_ids_with_tags(tag_ids);
                    let matched_child_ids: HashSet<Uuid> = children
                        .iter()
                        .filter(|child| {
                            !claimed.contains(&child.id)
                                && matched_host_ids.contains(&child.host_id)
                        })
                        .map(|c| c.id)
                        .collect();

                    if matched_child_ids.is_empty() {
                        continue;
                    }

                    let group_id = Uuid::new_v4();
                    child_nodes.push(Node {
                        id: group_id,
                        node_type: NodeType::ContainerNode {
                            container_type: ContainerType::TagGroup,
                            parent_container_id: Some(subnet_id),
                            layer_hint: None,
                        },
                        position: Ixy { x: 0, y: 0 },
                        size: Uxy { x: 0, y: 0 },
                        header: title.clone(),
                        leaf_rule_id: Some(*rule_id),
                    });

                    for node in child_nodes.iter_mut() {
                        if matched_child_ids.contains(&node.id)
                            && let NodeType::LeafNode {
                                ref mut container_id,
                                ..
                            } = node.node_type
                        {
                            *container_id = group_id;
                        }
                    }
                    claimed.extend(&matched_child_ids);
                }
            }
        }
    }

    /// Create subnet container nodes with calculated positions
    pub fn create_subnet_nodes(
        &self,
        ctx: &TopologyContext,
        layouts: &HashMap<Uuid, SubnetLayout>,
    ) -> Vec<Node> {
        let subnet_grid_positions = self.calculate_subnet_grid_positions_by_layer(ctx, layouts);
        let (positions, _) =
            PlannerUtils::calculate_container_size(subnet_grid_positions, &SUBNET_PADDING);

        layouts
            .iter()
            .filter_map(|(subnet_id, layout)| {
                if let Some(position) = positions.get(subnet_id) {
                    if let Some(consolidated_subnet_ids) =
                        self.consolidated_docker_subnets.get(subnet_id)
                    {
                        let header = "Docker Bridge: (".to_owned()
                            + &ctx
                                .subnets
                                .iter()
                                .filter(|s| consolidated_subnet_ids.contains(&s.id))
                                .map(|s| s.base.cidr.to_string())
                                .join(", ")
                            + ")";

                        return Some(Node {
                            id: *subnet_id,
                            node_type: NodeType::ContainerNode {
                                container_type: ContainerType::Subnet,
                                parent_container_id: None,
                                layer_hint: None,
                            },
                            position: *position,
                            size: layout.size,
                            header: Some(header),
                            leaf_rule_id: None,
                        });
                    }

                    return Some(Node {
                        id: *subnet_id,
                        node_type: NodeType::ContainerNode {
                            container_type: ContainerType::Subnet,
                            parent_container_id: None,
                            layer_hint: None,
                        },
                        position: *position,
                        size: layout.size,
                        header: None,
                        leaf_rule_id: None,
                    });
                }
                None
            })
            .collect()
    }

    /// Calculate positions of subnets given layer values
    fn calculate_subnet_grid_positions_by_layer(
        &self,
        ctx: &TopologyContext,
        layouts: &HashMap<Uuid, SubnetLayout>,
    ) -> Vec<Vec<(Uuid, NodeLayout)>> {
        let sorted: Vec<_> = ctx
            .subnets
            .iter()
            .sorted_by_key(|s| {
                (
                    s.base.subnet_type.vertical_order(),
                    s.base.subnet_type.horizontal_order(),
                    s.base.name.clone(),
                )
            })
            .filter_map(|s| layouts.get(&s.id).map(|layout| (s, layout)))
            .collect();

        let mut subnets_by_layer: BTreeMap<usize, Vec<(&Uuid, &SubnetLayout)>> = BTreeMap::new();
        for (subnet, layout) in sorted {
            subnets_by_layer
                .entry(subnet.base.subnet_type.vertical_order())
                .or_default()
                .push((&subnet.id, layout));
        }

        subnets_by_layer
            .into_values()
            .map(|row| {
                row.into_iter()
                    .map(|(id, layout)| {
                        (
                            *id,
                            NodeLayout {
                                size: layout.size,
                                position: Ixy { x: 0, y: 0 },
                            },
                        )
                    })
                    .collect()
            })
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::hosts::r#impl::base::{Host, HostBase};
    use crate::server::services::r#impl::base::{Service, ServiceBase};
    use crate::server::services::r#impl::categories::ServiceCategory;
    use crate::server::services::r#impl::definitions::ServiceDefinition;
    use crate::server::services::r#impl::patterns::Pattern;
    use crate::server::shared::types::Color;
    use crate::server::tags::r#impl::base::{Tag, TagBase};
    use crate::server::topology::service::context::TopologyContext;
    use crate::server::topology::types::base::TopologyOptions;
    use crate::server::topology::types::grouping::LeafRule;
    use chrono::Utc;

    /// Test service definition that returns ReverseProxy category
    #[derive(PartialEq, Eq, Hash, Clone)]
    struct ReverseProxyServiceDef;

    impl ServiceDefinition for ReverseProxyServiceDef {
        fn name(&self) -> &'static str {
            "TestReverseProxy"
        }
        fn description(&self) -> &'static str {
            "Test"
        }
        fn category(&self) -> ServiceCategory {
            ServiceCategory::ReverseProxy
        }
        fn discovery_pattern(&self) -> Pattern<'_> {
            Pattern::None
        }
    }

    fn make_host(name: &str, tags: Vec<Uuid>) -> Host {
        Host {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: HostBase {
                name: name.to_string(),
                tags,
                ..Default::default()
            },
        }
    }

    fn make_service(host_id: Uuid, def: Box<dyn ServiceDefinition>) -> Service {
        Service {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                service_definition: def,
                ..Default::default()
            },
        }
    }

    fn make_tag(name: &str) -> Tag {
        Tag {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: TagBase {
                name: name.to_string(),
                description: None,
                color: Color::Yellow,
                organization_id: Uuid::new_v4(),
            },
        }
    }

    fn make_leaf_node(id: Uuid, host_id: Uuid, container_id: Uuid) -> Node {
        Node {
            id,
            node_type: NodeType::LeafNode {
                container_id,
                leaf_type: LeafEntityType::Interface,
                subnet_id: container_id,
                host_id,
                interface_id: Some(id),
            },
            position: Ixy { x: 0, y: 0 },
            size: Uxy { x: 100, y: 50 },
            header: None,
            leaf_rule_id: None,
        }
    }

    fn make_subnet_child(id: Uuid, host_id: Uuid) -> SubnetChild {
        SubnetChild {
            id,
            host_id,
            interface_id: Some(id),
            header: None,
            size: Uxy { x: 100, y: 50 },
            edges: vec![],
        }
    }

    #[test]
    fn test_nested_group_first_match_wins() {
        let tag = make_tag("MyTag");
        // Host that matches both ByServiceCategory(ReverseProxy) AND ByTag(tag)
        let host_both = make_host("host-both", vec![tag.id]);
        // Host that only matches the tag
        let host_tag_only = make_host("host-tag-only", vec![tag.id]);

        let svc = make_service(host_both.id, Box::new(ReverseProxyServiceDef));

        let subnet_id = Uuid::new_v4();
        let child_both_id = Uuid::new_v4();
        let child_tag_id = Uuid::new_v4();

        let children = vec![
            make_subnet_child(child_both_id, host_both.id),
            make_subnet_child(child_tag_id, host_tag_only.id),
        ];

        let mut child_nodes = vec![
            make_leaf_node(child_both_id, host_both.id, subnet_id),
            make_leaf_node(child_tag_id, host_tag_only.id, subnet_id),
        ];

        // Rules: ByServiceCategory first, then ByTag
        let mut options = TopologyOptions::default();
        options.request.leaf_rules = vec![
            GraphRule::new(LeafRule::ByServiceCategory {
                categories: vec![ServiceCategory::ReverseProxy],
                title: Some("Infra".to_string()),
            }),
            GraphRule::new(LeafRule::ByTag {
                tag_ids: vec![tag.id],
                title: None,
            }),
        ];

        let hosts = vec![host_both.clone(), host_tag_only.clone()];
        let services = vec![svc];
        let tags = vec![tag.clone()];

        let ctx = TopologyContext::new(
            &hosts,
            &[],
            &[],
            &services,
            &[],
            &[],
            &[],
            &[],
            &tags,
            &options,
        );

        let planner = SubnetLayoutPlanner::new();
        planner.create_nested_group_containers(subnet_id, &children, &ctx, &mut child_nodes);

        // Find group containers
        let groups: Vec<&Node> = child_nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::ContainerNode { .. }))
            .collect();
        assert_eq!(groups.len(), 2, "Should create two group containers");

        let cat_group = groups
            .iter()
            .find(|n| {
                matches!(
                    n.node_type,
                    NodeType::ContainerNode {
                        container_type: ContainerType::ServiceCategoryGroup,
                        ..
                    }
                )
            })
            .expect("Should have ServiceCategoryGroup");

        let tag_group = groups
            .iter()
            .find(|n| {
                matches!(
                    n.node_type,
                    NodeType::ContainerNode {
                        container_type: ContainerType::TagGroup,
                        ..
                    }
                )
            })
            .expect("Should have TagGroup");

        // First-match-wins: host_both should be in the category group (first rule)
        let both_node = child_nodes.iter().find(|n| n.id == child_both_id).unwrap();
        if let NodeType::LeafNode { container_id, .. } = &both_node.node_type {
            assert_eq!(
                *container_id, cat_group.id,
                "Overlapping host should be in first-match group (ServiceCategoryGroup)"
            );
        }

        // host_tag_only should be in the tag group (only matches tag rule)
        let tag_node = child_nodes.iter().find(|n| n.id == child_tag_id).unwrap();
        if let NodeType::LeafNode { container_id, .. } = &tag_node.node_type {
            assert_eq!(
                *container_id, tag_group.id,
                "Tag-only host should be in TagGroup"
            );
        }

        // Verify headers contain custom titles
        assert_eq!(
            cat_group.header.as_deref(),
            Some("Infra"),
            "Category group header should be custom title"
        );
        assert!(
            tag_group.header.is_none(),
            "Tag group with no custom title should have no header"
        );

        // Verify leaf_rule_id is set
        assert!(
            cat_group.leaf_rule_id.is_some(),
            "Category group should have leaf_rule_id"
        );
        assert!(
            tag_group.leaf_rule_id.is_some(),
            "Tag group should have leaf_rule_id"
        );
    }

    #[test]
    fn test_nested_group_reversed_order_flips_priority() {
        let tag = make_tag("TestTag");
        let host = make_host("overlap-host", vec![tag.id]);
        let svc = make_service(host.id, Box::new(ReverseProxyServiceDef));

        let subnet_id = Uuid::new_v4();
        let child_id = Uuid::new_v4();

        let children = vec![make_subnet_child(child_id, host.id)];

        // This time: ByTag FIRST, then ByServiceCategory
        let mut options = TopologyOptions::default();
        options.request.leaf_rules = vec![
            GraphRule::new(LeafRule::ByTag {
                tag_ids: vec![tag.id],
                title: Some("Tagged".to_string()),
            }),
            GraphRule::new(LeafRule::ByServiceCategory {
                categories: vec![ServiceCategory::ReverseProxy],
                title: Some("Infra".to_string()),
            }),
        ];

        let hosts = vec![host.clone()];
        let services = vec![svc];
        let tags = vec![tag.clone()];

        let ctx = TopologyContext::new(
            &hosts,
            &[],
            &[],
            &services,
            &[],
            &[],
            &[],
            &[],
            &tags,
            &options,
        );

        let mut child_nodes = vec![make_leaf_node(child_id, host.id, subnet_id)];

        let planner = SubnetLayoutPlanner::new();
        planner.create_nested_group_containers(subnet_id, &children, &ctx, &mut child_nodes);

        // Find the tag group (should be first match now)
        let tag_group = child_nodes
            .iter()
            .find(|n| {
                matches!(
                    n.node_type,
                    NodeType::ContainerNode {
                        container_type: ContainerType::TagGroup,
                        ..
                    }
                )
            })
            .expect("Should have TagGroup");

        // Host should be in tag group (first rule wins)
        let leaf = child_nodes.iter().find(|n| n.id == child_id).unwrap();
        if let NodeType::LeafNode { container_id, .. } = &leaf.node_type {
            assert_eq!(
                *container_id, tag_group.id,
                "When ByTag is first, overlapping host should be in TagGroup"
            );
        }

        // ServiceCategoryGroup should still be created but with no children
        // (since the only matching host was claimed by tag rule)
        let cat_group = child_nodes.iter().find(|n| {
            matches!(
                n.node_type,
                NodeType::ContainerNode {
                    container_type: ContainerType::ServiceCategoryGroup,
                    ..
                }
            )
        });
        assert!(
            cat_group.is_none(),
            "ServiceCategoryGroup should not be created when all its matches are already claimed"
        );
    }
}
