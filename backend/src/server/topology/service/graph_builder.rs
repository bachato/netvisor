use itertools::Itertools;
use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use crate::server::{
    hosts::r#impl::base::Host,
    interfaces::r#impl::base::Interface,
    subnets::r#impl::types::SubnetType,
    topology::{
        service::{anchor_planner::ChildAnchorPlanner, context::TopologyContext},
        types::{
            edges::Edge,
            grouping::{ElementRule, GraphRule, GroupingConfig},
            layout::{Ixy, Uxy},
            nodes::{ContainerChild, ContainerType, ElementEntityType, Node, NodeType},
        },
    },
};

pub struct GraphBuilder {
    consolidated_docker_subnets: HashMap<Uuid, Vec<Uuid>>,
}

impl Default for GraphBuilder {
    fn default() -> Self {
        Self::new()
    }
}

impl GraphBuilder {
    pub fn new() -> Self {
        Self {
            consolidated_docker_subnets: HashMap::new(),
        }
    }

    /// Main entry point: group children by subnet and create all child nodes
    pub fn create_subnet_child_nodes(
        &mut self,
        ctx: &TopologyContext,
        all_edges: &mut [Edge],
        grouping: &GroupingConfig,
        docker_bridge_host_subnet_id_to_group_on: HashMap<Uuid, Uuid>,
    ) -> (HashSet<Uuid>, Vec<Node>) {
        let children_by_subnet = self.group_children_by_subnet(
            ctx,
            all_edges,
            grouping,
            docker_bridge_host_subnet_id_to_group_on,
        );
        let mut child_nodes = Vec::new();

        let subnet_ids: HashSet<Uuid> = children_by_subnet
            .iter()
            .map(|(subnet_id, children)| {
                self.create_child_nodes(*subnet_id, children, ctx, &mut child_nodes);
                *subnet_id
            })
            .collect();

        (subnet_ids, child_nodes)
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

            // Always include VM header text — frontend handles suppression
            // via hide_vm_title_on_docker_container option
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
    ) -> HashMap<Uuid, Vec<ContainerChild>> {
        let mut children_by_subnet: HashMap<Uuid, Vec<ContainerChild>> = HashMap::new();

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

            // Update source/target handles for edges
            let edges = ChildAnchorPlanner::plan_anchors(interface.id, all_edges, ctx);

            let header_text =
                self.determine_subnet_child_header_text(ctx, interface, host, &subnet_type);

            let child = ContainerChild {
                id: interface.id,
                host_id: host.id,
                size: Uxy::default(),
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

    /// Create child (element) nodes for a subnet
    fn create_child_nodes(
        &mut self,
        subnet_id: Uuid,
        children: &[ContainerChild],
        ctx: &TopologyContext,
        child_nodes: &mut Vec<Node>,
    ) {
        // Create element nodes for all children
        // Positions are zeroed — the frontend computes layout via elkjs
        for child in children.iter() {
            child_nodes.push(Node {
                id: child.id,
                node_type: NodeType::Element {
                    container_id: subnet_id,
                    element_type: ElementEntityType::Interface,
                    subnet_id,
                    host_id: child.host_id,
                    interface_id: child.interface_id,
                },
                position: Ixy { x: 0, y: 0 },
                size: child.size,
                header: child.header.clone(),
                element_rule_id: None,
            });
        }

        // Create nested group containers for ByServiceCategory and ByTag rules
        self.create_nested_group_containers(subnet_id, children, ctx, child_nodes);
    }

    /// Create nested Container nodes for ByServiceCategory and ByTag grouping rules (ClientSide mode only).
    /// First-match-wins: nodes already claimed by an earlier rule are not reassigned.
    fn create_nested_group_containers(
        &self,
        subnet_id: Uuid,
        children: &[ContainerChild],
        ctx: &TopologyContext,
        child_nodes: &mut Vec<Node>,
    ) {
        let grouping = GroupingConfig::from_request_options(&ctx.options.request);
        let mut claimed: HashSet<Uuid> = HashSet::new();

        for GraphRule { id: rule_id, rule } in &grouping.element_rules {
            match rule {
                ElementRule::ByServiceCategory { categories, title } => {
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
                        node_type: NodeType::Container {
                            container_type: ContainerType::ServiceCategoryGroup,
                            parent_container_id: Some(subnet_id),
                            layer_hint: None,
                        },
                        position: Ixy { x: 0, y: 0 },
                        size: Uxy { x: 0, y: 0 },
                        header: title.clone(),
                        element_rule_id: Some(*rule_id),
                    });

                    for node in child_nodes.iter_mut() {
                        if matched_child_ids.contains(&node.id)
                            && let NodeType::Element {
                                ref mut container_id,
                                ..
                            } = node.node_type
                        {
                            *container_id = group_id;
                        }
                    }
                    claimed.extend(&matched_child_ids);
                }
                ElementRule::ByTag { tag_ids, title } => {
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
                        node_type: NodeType::Container {
                            container_type: ContainerType::TagGroup,
                            parent_container_id: Some(subnet_id),
                            layer_hint: None,
                        },
                        position: Ixy { x: 0, y: 0 },
                        size: Uxy { x: 0, y: 0 },
                        header: title.clone(),
                        element_rule_id: Some(*rule_id),
                    });

                    for node in child_nodes.iter_mut() {
                        if matched_child_ids.contains(&node.id)
                            && let NodeType::Element {
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

    /// Create subnet container nodes
    /// Positions and sizes are zeroed — the frontend computes layout via elkjs
    pub fn create_subnet_nodes(
        &self,
        ctx: &TopologyContext,
        subnet_ids: &HashSet<Uuid>,
    ) -> Vec<Node> {
        subnet_ids
            .iter()
            .map(|subnet_id| {
                let header = self.consolidated_docker_subnets.get(subnet_id).map(
                    |consolidated_subnet_ids| {
                        "Docker Bridge: (".to_owned()
                            + &ctx
                                .subnets
                                .iter()
                                .filter(|s| consolidated_subnet_ids.contains(&s.id))
                                .map(|s| s.base.cidr.to_string())
                                .join(", ")
                            + ")"
                    },
                );

                Node {
                    id: *subnet_id,
                    node_type: NodeType::Container {
                        container_type: ContainerType::Subnet,
                        parent_container_id: None,
                        layer_hint: None,
                    },
                    position: Ixy { x: 0, y: 0 },
                    size: Uxy { x: 0, y: 0 },
                    header,
                    element_rule_id: None,
                }
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
    use crate::server::topology::types::grouping::ElementRule;
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

    fn make_element_node(id: Uuid, host_id: Uuid, container_id: Uuid) -> Node {
        Node {
            id,
            node_type: NodeType::Element {
                container_id,
                element_type: ElementEntityType::Interface,
                subnet_id: container_id,
                host_id,
                interface_id: Some(id),
            },
            position: Ixy { x: 0, y: 0 },
            size: Uxy { x: 100, y: 50 },
            header: None,
            element_rule_id: None,
        }
    }

    fn make_container_child(id: Uuid, host_id: Uuid) -> ContainerChild {
        ContainerChild {
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
            make_container_child(child_both_id, host_both.id),
            make_container_child(child_tag_id, host_tag_only.id),
        ];

        let mut child_nodes = vec![
            make_element_node(child_both_id, host_both.id, subnet_id),
            make_element_node(child_tag_id, host_tag_only.id, subnet_id),
        ];

        // Rules: ByServiceCategory first, then ByTag
        let mut options = TopologyOptions::default();
        options.request.element_rules = vec![
            GraphRule::new(ElementRule::ByServiceCategory {
                categories: vec![ServiceCategory::ReverseProxy],
                title: Some("Infra".to_string()),
            }),
            GraphRule::new(ElementRule::ByTag {
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

        let planner = GraphBuilder::new();
        planner.create_nested_group_containers(subnet_id, &children, &ctx, &mut child_nodes);

        // Find group containers
        let groups: Vec<&Node> = child_nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Container { .. }))
            .collect();
        assert_eq!(groups.len(), 2, "Should create two group containers");

        let cat_group = groups
            .iter()
            .find(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
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
                    NodeType::Container {
                        container_type: ContainerType::TagGroup,
                        ..
                    }
                )
            })
            .expect("Should have TagGroup");

        // First-match-wins: host_both should be in the category group (first rule)
        let both_node = child_nodes.iter().find(|n| n.id == child_both_id).unwrap();
        if let NodeType::Element { container_id, .. } = &both_node.node_type {
            assert_eq!(
                *container_id, cat_group.id,
                "Overlapping host should be in first-match group (ServiceCategoryGroup)"
            );
        }

        // host_tag_only should be in the tag group (only matches tag rule)
        let tag_node = child_nodes.iter().find(|n| n.id == child_tag_id).unwrap();
        if let NodeType::Element { container_id, .. } = &tag_node.node_type {
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

        // Verify element_rule_id is set
        assert!(
            cat_group.element_rule_id.is_some(),
            "Category group should have element_rule_id"
        );
        assert!(
            tag_group.element_rule_id.is_some(),
            "Tag group should have element_rule_id"
        );
    }

    #[test]
    fn test_nested_group_reversed_order_flips_priority() {
        let tag = make_tag("TestTag");
        let host = make_host("overlap-host", vec![tag.id]);
        let svc = make_service(host.id, Box::new(ReverseProxyServiceDef));

        let subnet_id = Uuid::new_v4();
        let child_id = Uuid::new_v4();

        let children = vec![make_container_child(child_id, host.id)];

        // This time: ByTag FIRST, then ByServiceCategory
        let mut options = TopologyOptions::default();
        options.request.element_rules = vec![
            GraphRule::new(ElementRule::ByTag {
                tag_ids: vec![tag.id],
                title: Some("Tagged".to_string()),
            }),
            GraphRule::new(ElementRule::ByServiceCategory {
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

        let mut child_nodes = vec![make_element_node(child_id, host.id, subnet_id)];

        let planner = GraphBuilder::new();
        planner.create_nested_group_containers(subnet_id, &children, &ctx, &mut child_nodes);

        // Find the tag group (should be first match now)
        let tag_group = child_nodes
            .iter()
            .find(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::TagGroup,
                        ..
                    }
                )
            })
            .expect("Should have TagGroup");

        // Host should be in tag group (first rule wins)
        let element = child_nodes.iter().find(|n| n.id == child_id).unwrap();
        if let NodeType::Element { container_id, .. } = &element.node_type {
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
                NodeType::Container {
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
