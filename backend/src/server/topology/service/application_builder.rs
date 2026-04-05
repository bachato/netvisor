use std::collections::HashMap;
use uuid::Uuid;

use super::{context::TopologyContext, perspective::PerspectiveBuilder};
use crate::server::{
    dependencies::r#impl::{base::DependencyMembers, types::DependencyType},
    services::r#impl::{categories::ServiceCategory, virtualization::ServiceVirtualization},
    shared::types::metadata::EntityMetadataProvider,
    topology::types::{
        edges::{Edge, EdgeClassification, EdgeHandle, EdgeType},
        grouping::GroupingConfig,
        nodes::{ContainerType, ElementEntityType, Node, NodeType},
    },
};

pub struct ApplicationBuilder;

impl PerspectiveBuilder for ApplicationBuilder {
    fn build(&self, ctx: &TopologyContext, _grouping: &GroupingConfig) -> (Vec<Node>, Vec<Edge>) {
        let mut nodes = Vec::new();
        let mut edges = Vec::new();

        // Collect services with at least one binding, grouped by category
        let mut services_by_category: HashMap<
            ServiceCategory,
            Vec<&crate::server::services::r#impl::base::Service>,
        > = HashMap::new();
        for service in ctx.services {
            if service.base.bindings.is_empty() {
                continue;
            }
            let category = service.base.service_definition.category();
            services_by_category
                .entry(category)
                .or_default()
                .push(service);
        }

        // Create container + element nodes per category
        // category → container node ID
        let mut category_container_ids: HashMap<ServiceCategory, Uuid> = HashMap::new();
        // service_id → node exists (for edge creation)
        let mut service_node_ids: HashMap<Uuid, bool> = HashMap::new();

        for (category, services) in &services_by_category {
            let container_id = Uuid::new_v5(
                &Uuid::NAMESPACE_OID,
                format!("app-category:{category}").as_bytes(),
            );
            category_container_ids.insert(*category, container_id);

            nodes.push(Node {
                id: container_id,
                node_type: NodeType::Container {
                    container_type: ContainerType::ServiceCategory,
                    parent_container_id: None,
                    layer_hint: None,
                    icon: Some(category.icon().to_string()),
                    color: Some(category.color().to_string()),
                },
                position: Default::default(),
                size: Default::default(),
                header: Some(format!("{}", category)),
                element_rule_id: None,
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

        // Build binding_id → service_id lookup (for Bindings variant backward compat)
        let binding_to_service: HashMap<Uuid, Uuid> = ctx
            .services
            .iter()
            .flat_map(|s| s.base.bindings.iter().map(move |b| (b.id, s.id)))
            .collect();

        // Create service-level flow edges from dependencies
        for dep in ctx.dependencies {
            // Resolve to ordered service IDs based on member type
            let service_ids: Vec<Uuid> = match &dep.base.members {
                DependencyMembers::Services { service_ids } => service_ids.clone(),
                DependencyMembers::Bindings { binding_ids } => {
                    // Backward compat: resolve binding_ids to deduplicated service IDs
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

            // Only create edges between services that have nodes
            match dep.base.dependency_type {
                DependencyType::RequestPath => {
                    for window in service_ids.windows(2) {
                        let (source_id, target_id) = (window[0], window[1]);
                        if service_node_ids.contains_key(&source_id)
                            && service_node_ids.contains_key(&target_id)
                        {
                            edges.push(Edge {
                                id: Uuid::new_v4(),
                                source: source_id,
                                target: target_id,
                                edge_type: EdgeType::RequestPath {
                                    group_id: dep.id,
                                    source_binding_id: Uuid::nil(),
                                    target_binding_id: Uuid::nil(),
                                },
                                label: Some(dep.base.name.clone()),
                                source_handle: EdgeHandle::Bottom,
                                target_handle: EdgeHandle::Top,
                                is_multi_hop: false,
                                classification: EdgeClassification::default(),
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
                                        group_id: dep.id,
                                        source_binding_id: Uuid::nil(),
                                        target_binding_id: Uuid::nil(),
                                    },
                                    label: Some(dep.base.name.clone()),
                                    source_handle: EdgeHandle::Bottom,
                                    target_handle: EdgeHandle::Top,
                                    is_multi_hop: false,
                                    classification: EdgeClassification::default(),
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
                    classification: EdgeClassification::default(),
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
        services::r#impl::{
            base::{Service, ServiceBase},
            categories::ServiceCategory,
            definitions::ServiceDefinition,
            patterns::Pattern,
        },
        topology::{
            service::context::TopologyContext,
            types::{base::TopologyOptions, grouping::GroupingConfig, nodes::NodeType},
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

        // 3 containers + 3 elements
        assert_eq!(nodes.len(), 6);

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
}
