use std::collections::{HashMap, HashSet};
use uuid::Uuid;

use super::{
    context::TopologyContext,
    element_rules::{ElementMatchData, apply_element_rules},
    view::ViewBuilder,
};
use crate::server::{
    dependencies::r#impl::{base::DependencyMembers, types::DependencyType},
    services::r#impl::virtualization::ServiceVirtualization,
    shared::{concepts::Concept, types::metadata::EntityMetadataProvider},
    tags::r#impl::base::Tag,
    topology::types::{
        edges::{Edge, EdgeHandle, EdgeType, EdgeViewConfig},
        grouping::GroupingConfig,
        nodes::{ContainerType, ElementEntityType, Node, NodeType},
    },
};

/// Fixed UUID for the "Ungrouped" container
const UNGROUPED_CONTAINER_ID: Uuid = Uuid::from_bytes([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
]);

/// Namespace for deterministic topology container UUIDs.
pub const TOPOLOGY_CONTAINER_NAMESPACE: Uuid = Uuid::from_bytes([
    0xa1, 0xb2, 0xc3, 0xd4, 0xe5, 0xf6, 0x47, 0x89, 0x9a, 0xbc, 0xde, 0xf0, 0x12, 0x34, 0x56, 0x78,
]);

/// Create a deterministic container UUID from a tag UUID.
fn container_id_for_tag(tag_id: &Uuid) -> Uuid {
    Uuid::new_v5(&TOPOLOGY_CONTAINER_NAMESPACE, tag_id.as_bytes())
}

pub struct ApplicationBuilder;

impl ApplicationBuilder {
    /// Find the application group tag for a service: direct tag first, then inherit from host.
    fn find_app_group_tag<'a>(
        service: &crate::server::services::r#impl::base::Service,
        hosts: &[crate::server::hosts::r#impl::base::Host],
        app_group_tags: &'a HashMap<Uuid, &'a Tag>,
    ) -> Option<&'a Tag> {
        // Check service's own tags first
        for tag_id in &service.base.tags {
            if let Some(tag) = app_group_tags.get(tag_id) {
                return Some(tag);
            }
        }
        // Inherit from host
        if let Some(host) = hosts.iter().find(|h| h.id == service.base.host_id) {
            for tag_id in &host.base.tags {
                if let Some(tag) = app_group_tags.get(tag_id) {
                    return Some(tag);
                }
            }
        }
        None
    }
}

impl ViewBuilder for ApplicationBuilder {
    fn build(&self, ctx: &TopologyContext, grouping: &GroupingConfig) -> (Vec<Node>, Vec<Edge>) {
        let mut nodes = Vec::new();
        let mut edges = Vec::new();

        // Build app-group tag lookup from entity_tags
        let app_group_tags: HashMap<Uuid, &Tag> = ctx
            .entity_tags
            .iter()
            .filter(|t| t.base.is_application_group)
            .map(|t| (t.id, t))
            .collect();

        // Collect services with at least one binding
        let eligible_services: Vec<&crate::server::services::r#impl::base::Service> = ctx
            .services
            .iter()
            .filter(|s| !s.base.bindings.is_empty())
            .collect();

        // service_id → node exists (for edge creation)
        let mut service_node_ids: HashMap<Uuid, bool> = HashMap::new();

        if grouping.has_application_group_rule() && !app_group_tags.is_empty() {
            // Group by application group tag with host inheritance
            let mut services_by_tag: HashMap<
                Uuid,
                Vec<&crate::server::services::r#impl::base::Service>,
            > = HashMap::new();
            let mut ungrouped_services: Vec<&crate::server::services::r#impl::base::Service> =
                Vec::new();

            for service in &eligible_services {
                match Self::find_app_group_tag(service, ctx.hosts, &app_group_tags) {
                    Some(tag) => {
                        services_by_tag.entry(tag.id).or_default().push(service);
                    }
                    None => {
                        ungrouped_services.push(service);
                    }
                }
            }

            // Create containers for each app-group tag
            for (tag_id, services) in &services_by_tag {
                let container_id = container_id_for_tag(tag_id);
                let tag = app_group_tags[tag_id];

                nodes.push(Node {
                    id: container_id,
                    node_type: NodeType::Container {
                        container_type: ContainerType::ApplicationGroup,
                        parent_container_id: None,
                        layer_hint: None,
                        icon: Some(Concept::Application.icon().to_string()),
                        color: Some(tag.base.color.to_string()),
                        associated_service_definition: None,
                    },
                    position: Default::default(),
                    size: Default::default(),
                    header: Some(tag.base.name.clone()),
                    element_rule_id: None,
                    will_accept_edges: false,
                });

                for service in services {
                    let mut node = Node::element(
                        service.id,
                        container_id,
                        service.base.host_id,
                        ElementEntityType::Service {},
                    );
                    node.header = Some(service.base.name.clone());
                    nodes.push(node);
                    service_node_ids.insert(service.id, true);
                }
            }

            // Create "Ungrouped" container if needed
            if !ungrouped_services.is_empty() {
                nodes.push(Node {
                    id: UNGROUPED_CONTAINER_ID,
                    node_type: NodeType::Container {
                        container_type: ContainerType::ApplicationGroup,
                        parent_container_id: None,
                        layer_hint: None,
                        icon: Some(Concept::Application.icon().to_string()),
                        color: Some(Concept::Application.color().to_string()),
                        associated_service_definition: None,
                    },
                    position: Default::default(),
                    size: Default::default(),
                    header: Some("Ungrouped".to_string()),
                    element_rule_id: None,
                    will_accept_edges: false,
                });

                for service in &ungrouped_services {
                    let mut node = Node::element(
                        service.id,
                        UNGROUPED_CONTAINER_ID,
                        service.base.host_id,
                        ElementEntityType::Service {},
                    );
                    node.header = Some(service.base.name.clone());
                    nodes.push(node);
                    service_node_ids.insert(service.id, true);
                }
            }
        } else {
            // Fallback: group by service category (no app-group tags exist)
            use crate::server::services::r#impl::categories::ServiceCategory;

            let mut services_by_category: HashMap<
                ServiceCategory,
                Vec<&crate::server::services::r#impl::base::Service>,
            > = HashMap::new();
            for service in &eligible_services {
                let category = service.base.service_definition.category();
                services_by_category
                    .entry(category)
                    .or_default()
                    .push(service);
            }

            for (category, services) in &services_by_category {
                let container_id = Uuid::new_v5(
                    &TOPOLOGY_CONTAINER_NAMESPACE,
                    format!("app-category:{category}").as_bytes(),
                );

                nodes.push(Node {
                    id: container_id,
                    node_type: NodeType::Container {
                        container_type: ContainerType::ServiceCategory,
                        parent_container_id: None,
                        layer_hint: None,
                        icon: Some(category.icon().to_string()),
                        color: Some(category.color().to_string()),
                        associated_service_definition: None,
                    },
                    position: Default::default(),
                    size: Default::default(),
                    header: Some(format!("{}", category)),
                    element_rule_id: None,
                    will_accept_edges: false,
                });

                for service in services {
                    let mut node = Node::element(
                        service.id,
                        container_id,
                        service.base.host_id,
                        ElementEntityType::Service {},
                    );
                    node.header = Some(service.base.name.clone());
                    nodes.push(node);
                    service_node_ids.insert(service.id, true);
                }
            }
        }

        // Apply element rules (ByServiceCategory, ByTag) to create nested subcontainers
        let service_lookup: HashMap<Uuid, &crate::server::services::r#impl::base::Service> =
            eligible_services.iter().map(|s| (s.id, *s)).collect();
        apply_element_rules(&mut nodes, &grouping.element_rules, |node| {
            let service = service_lookup.get(&node.id)?;
            let categories = HashSet::from([service.base.service_definition.category()]);
            let mut tag_ids: HashSet<Uuid> = service.base.tags.iter().copied().collect();
            // Inherit host tags for ByTag matching
            if let Some(host) = ctx.hosts.iter().find(|h| h.id == service.base.host_id) {
                tag_ids.extend(host.base.tags.iter().copied());
            }
            let compose_project = service.base.virtualization.as_ref().and_then(|v| match v {
                ServiceVirtualization::Docker(dv) => dv.compose_project.clone(),
            });
            Some(ElementMatchData {
                categories,
                tag_ids,
                virtualizer_host_id: None,
                compose_project,
            })
        });

        // Post-process: set associated_service_definition on Stack subcontainers (always Docker)
        for node in nodes.iter_mut() {
            if let NodeType::Container {
                container_type: ContainerType::Stack,
                associated_service_definition,
                ..
            } = &mut node.node_type
            {
                *associated_service_definition = Some("Docker".to_string());
            }
        }

        // Build binding_id → service_id lookup (for Bindings variant backward compat)
        let binding_to_service: HashMap<Uuid, Uuid> = ctx
            .services
            .iter()
            .flat_map(|s| s.base.bindings.iter().map(move |b| (b.id, s.id)))
            .collect();

        // Create service-level flow edges from dependencies
        for dep in ctx.dependencies {
            // Resolve to ordered service IDs based on member type
            let is_bindings = matches!(dep.base.members, DependencyMembers::Bindings { .. });
            let service_ids: Vec<Uuid> = match &dep.base.members {
                DependencyMembers::Services { service_ids } => service_ids.clone(),
                DependencyMembers::Bindings { binding_ids } => {
                    let mut ids = Vec::new();
                    for binding_id in binding_ids {
                        if let Some(&service_id) = binding_to_service.get(binding_id)
                            && ids.last() != Some(&service_id)
                        {
                            ids.push(service_id);
                        } else if !binding_to_service.contains_key(binding_id) {
                            tracing::warn!(
                                dep_id = %dep.id, dep_name = %dep.base.name,
                                binding_id = %binding_id,
                                "Binding ID not found in any service's bindings"
                            );
                        }
                    }
                    ids
                }
            };

            if is_bindings && service_ids.len() < 2 {
                tracing::warn!(
                    dep_id = %dep.id, dep_name = %dep.base.name,
                    resolved = service_ids.len(),
                    member_type = "Bindings",
                    "Dependency resolved to < 2 services — no edges will be created"
                );
            }

            // Only create edges between services that have nodes
            match dep.base.dependency_type {
                DependencyType::RequestPath => {
                    for window in service_ids.windows(2) {
                        let (source_id, target_id) = (window[0], window[1]);
                        let source_has_node = service_node_ids.contains_key(&source_id);
                        let target_has_node = service_node_ids.contains_key(&target_id);
                        if !source_has_node || !target_has_node {
                            tracing::warn!(
                                dep_id = %dep.id, dep_name = %dep.base.name,
                                source_id = %source_id, source_has_node,
                                target_id = %target_id, target_has_node,
                                "RequestPath edge dropped — service missing from graph"
                            );
                        }
                        if source_has_node && target_has_node {
                            edges.push(Edge {
                                id: Uuid::new_v4(),
                                source: source_id,
                                target: target_id,
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
                }
                DependencyType::HubAndSpoke => {
                    if let Some((&hub_id, spokes)) = service_ids.split_first()
                        && service_node_ids.contains_key(&hub_id)
                    {
                        for &spoke_id in spokes {
                            if service_node_ids.contains_key(&spoke_id) {
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
        }

        // Create ServiceVirtualization overlay edges
        for service in ctx.services {
            if let Some(ServiceVirtualization::Docker(docker)) = &service.base.virtualization
                && service_node_ids.contains_key(&service.id)
                && service_node_ids.contains_key(&docker.service_id)
            {
                edges.push(Edge {
                    id: Uuid::new_v4(),
                    source: docker.service_id,
                    target: service.id,
                    edge_type: EdgeType::ServiceVirtualization {
                        containerizing_service_id: docker.service_id,
                        host_id: service.base.host_id,
                    },
                    label: None,
                    source_handle: EdgeHandle::Bottom,
                    target_handle: EdgeHandle::Top,
                    is_multi_hop: false,
                    view_config: EdgeViewConfig::default(),
                });
            }
        }

        (nodes, edges)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::{
        bindings::r#impl::base::{Binding, BindingBase, BindingType},
        dependencies::r#impl::base::{Dependency, DependencyBase, DependencyMembers},
        hosts::r#impl::base::{Host, HostBase},
        services::r#impl::{
            base::{Service, ServiceBase},
            categories::ServiceCategory,
            definitions::ServiceDefinition,
            patterns::Pattern,
        },
        shared::types::Color,
        tags::r#impl::base::{Tag, TagBase},
        topology::{
            service::context::TopologyContext,
            types::{
                base::TopologyOptions,
                grouping::{ContainerRule, ElementRule, GraphRule, GroupingConfig},
                nodes::NodeType,
                views::TopologyView,
            },
        },
    };
    use chrono::Utc;

    #[derive(PartialEq, Eq, Hash, Clone)]
    struct TestServiceDef {
        category: ServiceCategory,
        name: &'static str,
    }

    impl ServiceDefinition for TestServiceDef {
        fn name(&self) -> &'static str {
            self.name
        }
        fn description(&self) -> &'static str {
            "Test"
        }
        fn category(&self) -> ServiceCategory {
            self.category
        }
        fn discovery_pattern(&self) -> Pattern<'_> {
            Pattern::None
        }
    }

    fn make_service(
        host_id: Uuid,
        category: ServiceCategory,
        name: &'static str,
        bindings: Vec<Binding>,
    ) -> Service {
        Service {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: ServiceBase {
                host_id,
                service_definition: Box::new(TestServiceDef { category, name }),
                name: name.to_string(),
                bindings,
                ..Default::default()
            },
        }
    }

    fn make_binding(service_id: Uuid) -> Binding {
        Binding {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: BindingBase {
                service_id,
                network_id: Uuid::new_v4(),
                binding_type: BindingType::Interface {
                    interface_id: Uuid::new_v4(),
                },
            },
        }
    }

    fn make_dependency(dep_type: DependencyType, members: DependencyMembers) -> Dependency {
        Dependency {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: DependencyBase {
                name: "Test Dependency".to_string(),
                dependency_type: dep_type,
                members,
                ..Default::default()
            },
        }
    }

    #[test]
    fn test_creates_category_containers() {
        let host_id = Uuid::new_v4();
        let binding = make_binding(Uuid::nil());
        let svc = make_service(
            host_id,
            ServiceCategory::Database,
            "PostgreSQL",
            vec![binding],
        );
        let services = vec![svc];
        let options = TopologyOptions::default();

        let ctx = TopologyContext::new(&[], &[], &[], &services, &[], &[], &[], &[], &[], &options);

        let builder = ApplicationBuilder;
        let (nodes, _edges) = builder.build(
            &ctx,
            &GroupingConfig::from_request_options(&options.request),
        );

        // Should have one container (Database) + one element (PostgreSQL)
        let containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Container { .. }))
            .collect();
        assert_eq!(containers.len(), 1);
        assert_eq!(containers[0].header.as_deref(), Some("Database"));

        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 1);
        assert_eq!(elements[0].header.as_deref(), Some("PostgreSQL"));
    }

    #[test]
    fn test_skips_services_without_bindings() {
        let host_id = Uuid::new_v4();
        let svc_no_bindings =
            make_service(host_id, ServiceCategory::Database, "NoBindings", vec![]);
        let services = vec![svc_no_bindings];
        let options = TopologyOptions::default();

        let ctx = TopologyContext::new(&[], &[], &[], &services, &[], &[], &[], &[], &[], &options);

        let builder = ApplicationBuilder;
        let (nodes, _edges) = builder.build(
            &ctx,
            &GroupingConfig::from_request_options(&options.request),
        );
        assert!(nodes.is_empty());
    }

    #[test]
    fn test_request_path_edges() {
        let host_id = Uuid::new_v4();

        let b1 = make_binding(Uuid::nil());
        let b2 = make_binding(Uuid::nil());
        let b3 = make_binding(Uuid::nil());
        let b1_id = b1.id;
        let b2_id = b2.id;
        let b3_id = b3.id;

        let svc1 = make_service(host_id, ServiceCategory::ReverseProxy, "Nginx", vec![b1]);
        let svc2 = make_service(host_id, ServiceCategory::Development, "App", vec![b2]);
        let svc3 = make_service(host_id, ServiceCategory::Database, "Postgres", vec![b3]);

        let dep = make_dependency(
            DependencyType::RequestPath,
            DependencyMembers::Bindings {
                binding_ids: vec![b1_id, b2_id, b3_id],
            },
        );

        let services = vec![svc1, svc2, svc3];
        let deps = vec![dep];
        let options = TopologyOptions::default();

        let ctx = TopologyContext::new(
            &[],
            &[],
            &[],
            &services,
            &deps,
            &[],
            &[],
            &[],
            &[],
            &options,
        );

        let builder = ApplicationBuilder;
        let (nodes, edges) = builder.build(
            &ctx,
            &GroupingConfig::from_request_options(&options.request),
        );

        // 3 containers + 3 elements + 1 nested subcontainer (ReverseProxy matches default ByServiceCategory rule)
        assert_eq!(nodes.len(), 7);

        // 2 request path edges: svc1→svc2, svc2→svc3
        let flow_edges: Vec<&Edge> = edges
            .iter()
            .filter(|e| matches!(e.edge_type, EdgeType::RequestPath { .. }))
            .collect();
        assert_eq!(flow_edges.len(), 2);
    }

    #[test]
    fn test_hub_and_spoke_edges() {
        let host_id = Uuid::new_v4();

        let b1 = make_binding(Uuid::nil());
        let b2 = make_binding(Uuid::nil());
        let b3 = make_binding(Uuid::nil());
        let b1_id = b1.id;
        let b2_id = b2.id;
        let b3_id = b3.id;

        let svc1 = make_service(host_id, ServiceCategory::ReverseProxy, "LB", vec![b1]);
        let svc2 = make_service(host_id, ServiceCategory::Development, "App1", vec![b2]);
        let svc3 = make_service(host_id, ServiceCategory::Development, "App2", vec![b3]);

        let dep = make_dependency(
            DependencyType::HubAndSpoke,
            DependencyMembers::Bindings {
                binding_ids: vec![b1_id, b2_id, b3_id],
            },
        );

        let services = vec![svc1, svc2, svc3];
        let deps = vec![dep];
        let options = TopologyOptions::default();

        let ctx = TopologyContext::new(
            &[],
            &[],
            &[],
            &services,
            &deps,
            &[],
            &[],
            &[],
            &[],
            &options,
        );

        let builder = ApplicationBuilder;
        let (_nodes, edges) = builder.build(
            &ctx,
            &GroupingConfig::from_request_options(&options.request),
        );

        // Hub (svc1) → svc2, svc1 → svc3
        let spoke_edges: Vec<&Edge> = edges
            .iter()
            .filter(|e| matches!(e.edge_type, EdgeType::HubAndSpoke { .. }))
            .collect();
        assert_eq!(spoke_edges.len(), 2);
    }

    #[test]
    fn test_deduplicates_bindings_to_services() {
        let host_id = Uuid::new_v4();

        // Service with 2 bindings in the same dependency
        let b1 = make_binding(Uuid::nil());
        let b2 = make_binding(Uuid::nil());
        let b3 = make_binding(Uuid::nil());
        let b1_id = b1.id;
        let b2_id = b2.id;
        let b3_id = b3.id;

        let svc1 = make_service(
            host_id,
            ServiceCategory::ReverseProxy,
            "Nginx",
            vec![b1, b2],
        );
        let svc2 = make_service(host_id, ServiceCategory::Database, "DB", vec![b3]);

        // Dependency: b1 (svc1) → b2 (svc1) → b3 (svc2)
        // Should deduplicate to: svc1 → svc2
        let dep = make_dependency(
            DependencyType::RequestPath,
            DependencyMembers::Bindings {
                binding_ids: vec![b1_id, b2_id, b3_id],
            },
        );

        let services = vec![svc1, svc2];
        let deps = vec![dep];
        let options = TopologyOptions::default();

        let ctx = TopologyContext::new(
            &[],
            &[],
            &[],
            &services,
            &deps,
            &[],
            &[],
            &[],
            &[],
            &options,
        );

        let builder = ApplicationBuilder;
        let (_nodes, edges) = builder.build(
            &ctx,
            &GroupingConfig::from_request_options(&options.request),
        );

        let flow_edges: Vec<&Edge> = edges
            .iter()
            .filter(|e| matches!(e.edge_type, EdgeType::RequestPath { .. }))
            .collect();
        assert_eq!(
            flow_edges.len(),
            1,
            "Should deduplicate consecutive same-service bindings"
        );
    }

    #[test]
    fn test_element_rules_across_app_groups() {
        // 2 hosts with different app-group tags → 2 ApplicationGroup containers
        // Both services have a shared non-app-group tag "monitoring"
        // ByTag element rule should create subcontainers in BOTH containers
        let monitoring_tag_id = Uuid::new_v4();
        let app_tag_a_id = Uuid::new_v4();
        let app_tag_b_id = Uuid::new_v4();

        let host_a = Host {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: HostBase {
                name: "host-a".to_string(),
                tags: vec![app_tag_a_id],
                ..Default::default()
            },
        };
        let host_b = Host {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: HostBase {
                name: "host-b".to_string(),
                tags: vec![app_tag_b_id],
                ..Default::default()
            },
        };

        let b1 = make_binding(Uuid::nil());
        let b2 = make_binding(Uuid::nil());

        let mut svc_a = make_service(host_a.id, ServiceCategory::Development, "AppA", vec![b1]);
        svc_a.base.tags = vec![monitoring_tag_id];

        let mut svc_b = make_service(host_b.id, ServiceCategory::Development, "AppB", vec![b2]);
        svc_b.base.tags = vec![monitoring_tag_id];

        let app_tag_a = Tag {
            id: app_tag_a_id,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: TagBase {
                name: "Group A".to_string(),
                description: None,
                color: Color::Blue,
                organization_id: Uuid::new_v4(),
                is_application_group: true,
            },
        };
        let app_tag_b = Tag {
            id: app_tag_b_id,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: TagBase {
                name: "Group B".to_string(),
                description: None,
                color: Color::Green,
                organization_id: Uuid::new_v4(),
                is_application_group: true,
            },
        };

        let services = vec![svc_a, svc_b];
        let hosts = vec![host_a, host_b];
        let tags = vec![app_tag_a, app_tag_b];

        let mut options = TopologyOptions::default();
        options.request.view = TopologyView::Application;
        options.request.container_rules.insert(
            TopologyView::Application,
            vec![GraphRule::new(ContainerRule::ByApplicationGroup {
                tag_ids: vec![],
            })],
        );
        options.request.element_rules = vec![GraphRule::new(ElementRule::ByTag {
            tag_ids: vec![monitoring_tag_id],
            title: Some("Monitored".to_string()),
        })];

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

        let builder = ApplicationBuilder;
        let (nodes, _edges) = builder.build(
            &ctx,
            &GroupingConfig::from_request_options(&options.request),
        );

        // 2 AppGroup containers + 2 NestedTag subcontainers + 2 element nodes = 6
        let containers: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Container { .. }))
            .collect();
        let nested: Vec<&Node> = containers
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::NestedTag,
                        ..
                    }
                )
            })
            .copied()
            .collect();
        assert_eq!(
            containers.len(),
            4,
            "Should have 2 AppGroup + 2 NestedTag containers"
        );
        assert_eq!(nested.len(), 2, "Should have 2 NestedTag subcontainers");

        // Both services should be inside their respective NestedTag subcontainers
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        assert_eq!(elements.len(), 2);

        for element in &elements {
            if let NodeType::Element { container_id, .. } = &element.node_type {
                assert!(
                    nested.iter().any(|n| n.id == *container_id),
                    "Element {} should be inside a NestedTag subcontainer, but container_id is {}",
                    element.id,
                    container_id
                );
            }
        }
    }

    #[test]
    fn test_element_rules_with_host_inherited_tags() {
        // Scenario from tester: 2 hosts with different app-group tags,
        // both hosts also have a shared non-app-group tag used in ByTag rule.
        // Tags are on the HOST, not on the services — tests host tag inheritance.
        // Also includes default ByServiceCategory rule (matches DNS/ReverseProxy).
        let monitoring_tag_id = Uuid::new_v4();
        let app_tag_a_id = Uuid::new_v4();
        let app_tag_b_id = Uuid::new_v4();

        // Both hosts have the monitoring tag AND their app-group tag
        let host_a = Host {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: HostBase {
                name: "host-a".to_string(),
                tags: vec![app_tag_a_id, monitoring_tag_id],
                ..Default::default()
            },
        };
        let host_b = Host {
            id: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: HostBase {
                name: "host-b".to_string(),
                tags: vec![app_tag_b_id, monitoring_tag_id],
                ..Default::default()
            },
        };

        let b1 = make_binding(Uuid::nil());
        let b2 = make_binding(Uuid::nil());

        // Services do NOT have the monitoring tag — they inherit from hosts
        let svc_a = make_service(host_a.id, ServiceCategory::Development, "AppA", vec![b1]);
        let svc_b = make_service(host_b.id, ServiceCategory::Development, "AppB", vec![b2]);

        let app_tag_a = Tag {
            id: app_tag_a_id,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: TagBase {
                name: "Group A".to_string(),
                description: None,
                color: Color::Blue,
                organization_id: Uuid::new_v4(),
                is_application_group: true,
            },
        };
        let app_tag_b = Tag {
            id: app_tag_b_id,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            base: TagBase {
                name: "Group B".to_string(),
                description: None,
                color: Color::Green,
                organization_id: Uuid::new_v4(),
                is_application_group: true,
            },
        };

        let services = vec![svc_a, svc_b];
        let hosts = vec![host_a, host_b];
        let tags = vec![app_tag_a, app_tag_b];

        let mut options = TopologyOptions::default();
        options.request.view = TopologyView::Application;
        options.request.container_rules.insert(
            TopologyView::Application,
            vec![GraphRule::new(ContainerRule::ByApplicationGroup {
                tag_ids: vec![],
            })],
        );
        // Default ByServiceCategory PLUS a ByTag rule
        options.request.element_rules = vec![
            GraphRule::new(ElementRule::ByServiceCategory {
                categories: vec![ServiceCategory::DNS, ServiceCategory::ReverseProxy],
                title: Some("Infrastructure".to_string()),
            }),
            GraphRule::new(ElementRule::ByTag {
                tag_ids: vec![monitoring_tag_id],
                title: Some("Monitored".to_string()),
            }),
        ];

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

        let builder = ApplicationBuilder;
        let (nodes, _edges) = builder.build(
            &ctx,
            &GroupingConfig::from_request_options(&options.request),
        );

        // Neither service is DNS/ReverseProxy, so ByServiceCategory creates nothing.
        // ByTag should create 2 NestedTag subcontainers (one per AppGroup).
        let nested_tags: Vec<&Node> = nodes
            .iter()
            .filter(|n| {
                matches!(
                    n.node_type,
                    NodeType::Container {
                        container_type: ContainerType::NestedTag,
                        ..
                    }
                )
            })
            .collect();
        assert_eq!(
            nested_tags.len(),
            2,
            "Should have 2 NestedTag subcontainers (one per AppGroup)"
        );

        // Both services should be in NestedTag subcontainers
        let elements: Vec<&Node> = nodes
            .iter()
            .filter(|n| matches!(n.node_type, NodeType::Element { .. }))
            .collect();
        for element in &elements {
            if let NodeType::Element { container_id, .. } = &element.node_type {
                assert!(
                    nested_tags.iter().any(|n| n.id == *container_id),
                    "Service {} should be in a NestedTag, but container_id is {}",
                    element.header.as_deref().unwrap_or("?"),
                    container_id
                );
            }
        }
    }
}
