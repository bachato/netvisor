use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::shared::concepts::Concept;
use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider};
use crate::server::shared::types::{Color, Icon};
use crate::server::topology::types::base::TopologyRequestOptions;
use crate::server::topology::types::views::TopologyView;
use serde::{Deserialize, Serialize};
use strum_macros::{EnumIter, IntoStaticStr};
use utoipa::ToSchema;
use uuid::Uuid;

/// Controls how users can interact with a grouping rule.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, ToSchema)]
pub enum RuleEditability {
    /// System-managed rule. Cannot be added, removed, or reordered by users.
    System,
    /// User can add/edit/remove, but only one instance allowed.
    Singleton,
    /// User can add/edit/remove multiple instances with different configs.
    Multi,
}

pub trait GraphRule {
    /// Whether edges targeting elements inside containers created by this rule
    /// should be elevated to target the container itself.
    fn will_accept_edges(&self) -> bool;

    /// How users can interact with this rule type.
    fn editability(&self) -> RuleEditability;

    fn applicable_views(&self) -> &'static [TopologyView];
}

/// Generic wrapper that gives any rule type a stable UUID identity.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, ToSchema)]
pub struct IdentifiedRule<T: GraphRule> {
    pub id: Uuid,
    pub rule: T,
}

impl<T: GraphRule> IdentifiedRule<T> {
    pub fn new(rule: T) -> Self {
        Self {
            id: Uuid::new_v4(),
            rule,
        }
    }
}

/// Rules that change which containers exist and how they nest.
/// Container titles are data-driven (subnet CIDR, host names), not user-configurable.
#[derive(
    Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, ToSchema, EnumIter, IntoStaticStr,
)]
pub enum ContainerRule {
    BySubnet,
    MergeDockerBridges,
    ByApplication {
        #[serde(default)]
        tag_ids: Vec<Uuid>,
    },
    ByHost,
}

impl GraphRule for ContainerRule {
    fn applicable_views(&self) -> &'static [TopologyView] {
        match self {
            ContainerRule::BySubnet => &[TopologyView::L3Logical],
            ContainerRule::MergeDockerBridges => &[TopologyView::L3Logical],
            ContainerRule::ByApplication { .. } => &[TopologyView::Application],
            ContainerRule::ByHost => &[TopologyView::L2Physical, TopologyView::Workloads],
        }
    }

    fn will_accept_edges(&self) -> bool {
        matches!(self, ContainerRule::MergeDockerBridges)
    }

    fn editability(&self) -> RuleEditability {
        match self {
            ContainerRule::MergeDockerBridges => RuleEditability::Singleton,
            _ => RuleEditability::System,
        }
    }
}

impl HasId for ContainerRule {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for ContainerRule {
    fn color(&self) -> Color {
        match self {
            ContainerRule::BySubnet => Color::Blue,
            ContainerRule::MergeDockerBridges => Color::Teal,
            ContainerRule::ByApplication { .. } => Concept::Application.color(),
            ContainerRule::ByHost => Concept::L2.color(),
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ContainerRule::BySubnet => Icon::Network,
            ContainerRule::MergeDockerBridges => Icon::Boxes,
            ContainerRule::ByApplication { .. } => Concept::Application.icon(),
            ContainerRule::ByHost => Concept::L2.icon(),
        }
    }
}

impl TypeMetadataProvider for ContainerRule {
    fn name(&self) -> &'static str {
        match self {
            ContainerRule::BySubnet => "Subnet",
            ContainerRule::MergeDockerBridges => "Docker bridges",
            ContainerRule::ByApplication { .. } => "Application",
            ContainerRule::ByHost => "Host",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ContainerRule::BySubnet => "Group nodes by network subnet",
            ContainerRule::MergeDockerBridges => "Merge Docker bridge subnets under their host",
            ContainerRule::ByApplication { .. } => "Group services by application tag",
            ContainerRule::ByHost => "Group elements by host",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "editability": self.editability(),
            "views": self.applicable_views(),
            "will_accept_edges": self.will_accept_edges(),
        })
    }
}

/// Rules that organize nodes within a container into sub-groups.
#[derive(
    Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, ToSchema, EnumIter, IntoStaticStr,
)]
pub enum ElementRule {
    ByServiceCategory {
        categories: Vec<ServiceCategory>,
        title: Option<String>,
        /// Set by the backend on the default infrastructure rule.
        /// Frontend uses this to identify the infra container for auto-collapse.
        #[serde(default)]
        #[schema(read_only)]
        is_infra_rule: bool,
    },
    ByTag {
        tag_ids: Vec<Uuid>,
        title: Option<String>,
    },
    ByHypervisor,
    ByContainerRuntime,
    ByStack,
    /// Groups trunk ports (ports with tagged VLANs) into a "Trunk Ports" subcontainer.
    /// Higher priority than ByVLAN — prevents trunk ports from being grouped by VLAN.
    ByTrunkPort,
    /// Groups access ports by their native VLAN ID into per-VLAN subcontainers.
    ByVLAN,
    /// Groups ports by operational status (Up, Down, etc.) into per-status subcontainers.
    ByPortOpStatus,
}

impl GraphRule for ElementRule {
    fn will_accept_edges(&self) -> bool {
        matches!(
            self,
            ElementRule::ByStack | ElementRule::ByHypervisor | ElementRule::ByContainerRuntime
        )
    }

    fn editability(&self) -> RuleEditability {
        match self {
            ElementRule::ByTrunkPort | ElementRule::ByVLAN | ElementRule::ByPortOpStatus => {
                RuleEditability::System
            }
            ElementRule::ByHypervisor | ElementRule::ByContainerRuntime | ElementRule::ByStack => {
                RuleEditability::Singleton
            }
            ElementRule::ByServiceCategory { .. } | ElementRule::ByTag { .. } => {
                RuleEditability::Multi
            }
        }
    }

    fn applicable_views(&self) -> &'static [TopologyView] {
        match self {
            ElementRule::ByServiceCategory { .. } => {
                &[TopologyView::Application, TopologyView::Workloads]
            }
            ElementRule::ByTag { .. } => &[
                TopologyView::L3Logical,
                TopologyView::L2Physical,
                TopologyView::Workloads,
                TopologyView::Application,
            ],
            ElementRule::ByHypervisor => &[TopologyView::Workloads],
            ElementRule::ByContainerRuntime => &[TopologyView::Workloads],
            ElementRule::ByStack => &[TopologyView::L3Logical, TopologyView::Application],
            ElementRule::ByTrunkPort => &[TopologyView::L2Physical],
            ElementRule::ByVLAN => &[TopologyView::L2Physical],
            ElementRule::ByPortOpStatus => &[TopologyView::L2Physical],
        }
    }
}

impl HasId for ElementRule {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for ElementRule {
    fn color(&self) -> Color {
        match self {
            ElementRule::ByServiceCategory { .. } => Color::Purple,
            ElementRule::ByTag { .. } => Color::Orange,
            ElementRule::ByHypervisor => Concept::Virtualization.color(),
            ElementRule::ByContainerRuntime => Concept::Containerization.color(),
            ElementRule::ByStack => Concept::Containerization.color(),
            ElementRule::ByTrunkPort => Color::Amber,
            ElementRule::ByVLAN => Color::Teal,
            ElementRule::ByPortOpStatus => Color::Gray,
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ElementRule::ByServiceCategory { .. } => Icon::Layers,
            ElementRule::ByTag { .. } => Icon::Tag,
            ElementRule::ByHypervisor => Concept::Virtualization.icon(),
            ElementRule::ByContainerRuntime => Concept::Containerization.icon(),
            ElementRule::ByStack => Concept::Containerization.icon(),
            ElementRule::ByTrunkPort => Icon::Network,
            ElementRule::ByVLAN => Icon::Network,
            ElementRule::ByPortOpStatus => Icon::Circle,
        }
    }
}

impl TypeMetadataProvider for ElementRule {
    fn name(&self) -> &'static str {
        match self {
            ElementRule::ByServiceCategory { .. } => "Service category",
            ElementRule::ByTag { .. } => "Tag",
            ElementRule::ByHypervisor => "Hypervisor",
            ElementRule::ByContainerRuntime => "Container Runtime",
            ElementRule::ByStack => "Docker Stack",
            ElementRule::ByTrunkPort => "Trunk Ports",
            ElementRule::ByVLAN => "VLAN",
            ElementRule::ByPortOpStatus => "Port Status",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ElementRule::ByServiceCategory { .. } => "Group elements by service category",
            ElementRule::ByTag { .. } => "Group elements by tag",
            ElementRule::ByHypervisor => "Group VMs by hypervisor",
            ElementRule::ByContainerRuntime => "Group containers by runtime",
            ElementRule::ByStack => "Group by Docker Compose project",
            ElementRule::ByTrunkPort => "Group trunk ports (ports carrying multiple VLANs)",
            ElementRule::ByVLAN => "Group access ports by native VLAN ID",
            ElementRule::ByPortOpStatus => "Group ports by operational status",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "editability": self.editability(),
            "views": self.applicable_views(),
            "will_accept_edges": self.will_accept_edges(),
        })
    }
}

#[derive(Debug, Clone)]
pub struct GroupingConfig {
    pub container_rules: Vec<IdentifiedRule<ContainerRule>>,
    pub element_rules: Vec<IdentifiedRule<ElementRule>>,
}

impl GroupingConfig {
    pub fn from_request_options(options: &TopologyRequestOptions) -> Self {
        let view = options.view;

        // Container rules: look up current view directly (per-view HashMap)
        let container_rules = options
            .container_rules
            .get(&view)
            .cloned()
            .unwrap_or_default();

        // Element rules: filter shared set by applicable views
        let element_rules = options
            .element_rules
            .iter()
            .filter(|gr| gr.rule.applicable_views().contains(&view))
            .cloned()
            .collect();

        GroupingConfig {
            container_rules,
            element_rules,
        }
    }

    pub fn should_group_docker_bridges(&self) -> bool {
        self.container_rules
            .iter()
            .any(|r| matches!(r.rule, ContainerRule::MergeDockerBridges))
    }

    pub fn has_application_rule(&self) -> bool {
        self.container_rules
            .iter()
            .any(|r| matches!(r.rule, ContainerRule::ByApplication { .. }))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::shared::types::metadata::TypeMetadataProvider;
    use crate::server::topology::types::base::TopologyRequestOptions;

    #[test]
    fn test_will_accept_edges_in_metadata() {
        let merge = ContainerRule::MergeDockerBridges;
        assert!(merge.will_accept_edges());
        let meta = merge.metadata();
        assert_eq!(meta["will_accept_edges"], true);

        let by_subnet = ContainerRule::BySubnet;
        assert!(!by_subnet.will_accept_edges());
        assert_eq!(by_subnet.metadata()["will_accept_edges"], false);

        let by_stack = ElementRule::ByStack;
        assert!(by_stack.will_accept_edges());
        assert_eq!(by_stack.metadata()["will_accept_edges"], true);

        let by_tag = ElementRule::ByTag {
            tag_ids: vec![],
            title: None,
        };
        assert!(!by_tag.will_accept_edges());
        assert_eq!(by_tag.metadata()["will_accept_edges"], false);
    }

    #[test]
    fn test_no_docker_grouping() {
        let mut options = TopologyRequestOptions::default();
        options.container_rules.insert(
            TopologyView::L3Logical,
            vec![IdentifiedRule::new(ContainerRule::BySubnet)],
        );
        let config = GroupingConfig::from_request_options(&options);

        assert!(!config.should_group_docker_bridges());
    }

    #[test]
    fn test_serialization_round_trip_container_rules() {
        let rules = vec![
            IdentifiedRule::new(ContainerRule::BySubnet),
            IdentifiedRule::new(ContainerRule::MergeDockerBridges),
        ];

        let json = serde_json::to_string(&rules).unwrap();
        let deserialized: Vec<IdentifiedRule<ContainerRule>> = serde_json::from_str(&json).unwrap();
        assert_eq!(rules, deserialized);
    }

    #[test]
    fn test_serialization_round_trip_element_rules() {
        let rules = vec![
            IdentifiedRule::new(ElementRule::ByServiceCategory {
                categories: vec![ServiceCategory::DNS, ServiceCategory::ReverseProxy],
                title: Some("Infrastructure".into()),
                is_infra_rule: false,
            }),
            IdentifiedRule::new(ElementRule::ByTag {
                tag_ids: vec![Uuid::new_v4(), Uuid::new_v4()],
                title: Some("Tagged".into()),
            }),
            IdentifiedRule::new(ElementRule::ByStack),
        ];

        let json = serde_json::to_string(&rules).unwrap();
        let deserialized: Vec<IdentifiedRule<ElementRule>> = serde_json::from_str(&json).unwrap();
        assert_eq!(rules, deserialized);
    }

    #[test]
    fn test_by_stack_serde_round_trip() {
        let rule = IdentifiedRule::new(ElementRule::ByStack);
        let json = serde_json::to_string(&rule).unwrap();
        assert!(json.contains("ByStack"));
        let deserialized: IdentifiedRule<ElementRule> = serde_json::from_str(&json).unwrap();
        assert_eq!(rule, deserialized);
    }
}
