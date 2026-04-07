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

/// Generic wrapper that gives any rule type a stable UUID identity.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, ToSchema)]
pub struct GraphRule<T> {
    pub id: Uuid,
    pub rule: T,
}

impl<T> GraphRule<T> {
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
    ByApplicationGroup {
        #[serde(default)]
        tag_ids: Vec<Uuid>,
    },
    ByHost,
}

impl ContainerRule {
    pub fn applicable_views(&self) -> &'static [TopologyView] {
        match self {
            ContainerRule::BySubnet => &[TopologyView::L3Logical],
            ContainerRule::MergeDockerBridges => &[TopologyView::L3Logical],
            ContainerRule::ByApplicationGroup { .. } => &[TopologyView::Application],
            ContainerRule::ByHost => &[TopologyView::L2Physical],
        }
    }

    /// Whether edges targeting elements inside containers created by this rule
    /// should be elevated to target the container itself.
    pub fn will_accept_edges(&self) -> bool {
        matches!(self, ContainerRule::MergeDockerBridges)
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
            ContainerRule::ByApplicationGroup { .. } => Concept::Application.color(),
            ContainerRule::ByHost => Concept::L2.color(),
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ContainerRule::BySubnet => Icon::Network,
            ContainerRule::MergeDockerBridges => Icon::Boxes,
            ContainerRule::ByApplicationGroup { .. } => Concept::Application.icon(),
            ContainerRule::ByHost => Concept::L2.icon(),
        }
    }
}

impl TypeMetadataProvider for ContainerRule {
    fn name(&self) -> &'static str {
        match self {
            ContainerRule::BySubnet => "Subnet",
            ContainerRule::MergeDockerBridges => "Docker bridges",
            ContainerRule::ByApplicationGroup { .. } => "Application Group",
            ContainerRule::ByHost => "Host",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ContainerRule::BySubnet => "Group nodes by network subnet",
            ContainerRule::MergeDockerBridges => "Merge Docker bridge subnets under their host",
            ContainerRule::ByApplicationGroup { .. } => "Group services by application group tag",
            ContainerRule::ByHost => "Group ports by their host device",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "is_user_editable": matches!(self, ContainerRule::MergeDockerBridges),
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
    },
    ByTag {
        tag_ids: Vec<Uuid>,
        title: Option<String>,
    },
    ByVirtualizer,
    ByStack,
    /// Groups trunk ports (ports with tagged VLANs) into a "Trunk Ports" subcontainer.
    /// Higher priority than ByVLAN — prevents trunk ports from being grouped by VLAN.
    ByTrunkPort,
    /// Groups access ports by their native VLAN ID into per-VLAN subcontainers.
    ByVLAN,
}

impl ElementRule {
    /// Whether edges targeting elements inside subcontainers created by this rule
    /// should be elevated to target the subcontainer itself.
    pub fn will_accept_edges(&self) -> bool {
        matches!(self, ElementRule::ByStack | ElementRule::ByVirtualizer)
    }

    /// Whether this rule is locked (not user-removable) when applicable.
    pub fn is_locked(&self) -> bool {
        matches!(self, ElementRule::ByTrunkPort | ElementRule::ByVLAN)
    }

    pub fn applicable_views(&self) -> &'static [TopologyView] {
        match self {
            ElementRule::ByServiceCategory { .. } => {
                &[TopologyView::L3Logical, TopologyView::Application]
            }
            ElementRule::ByTag { .. } => &[
                TopologyView::L3Logical,
                TopologyView::L2Physical,
                TopologyView::Infrastructure,
                TopologyView::Application,
            ],
            ElementRule::ByVirtualizer => &[TopologyView::Infrastructure],
            ElementRule::ByStack => &[TopologyView::L3Logical, TopologyView::Application],
            ElementRule::ByTrunkPort => &[TopologyView::L2Physical],
            ElementRule::ByVLAN => &[TopologyView::L2Physical],
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
            ElementRule::ByVirtualizer => Concept::Infrastructure.color(),
            ElementRule::ByStack => Concept::Virtualization.color(),
            ElementRule::ByTrunkPort => Color::Amber,
            ElementRule::ByVLAN => Color::Teal,
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ElementRule::ByServiceCategory { .. } => Icon::Layers,
            ElementRule::ByTag { .. } => Icon::Tag,
            ElementRule::ByVirtualizer => Concept::Infrastructure.icon(),
            ElementRule::ByStack => Concept::Virtualization.icon(),
            ElementRule::ByTrunkPort => Icon::Network,
            ElementRule::ByVLAN => Icon::Network,
        }
    }
}

impl TypeMetadataProvider for ElementRule {
    fn name(&self) -> &'static str {
        match self {
            ElementRule::ByServiceCategory { .. } => "Service category",
            ElementRule::ByTag { .. } => "Tag",
            ElementRule::ByVirtualizer => "Virtualizer",
            ElementRule::ByStack => "Docker Stack",
            ElementRule::ByTrunkPort => "Trunk Ports",
            ElementRule::ByVLAN => "VLAN",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ElementRule::ByServiceCategory { .. } => {
                "Group nodes by service category within a container"
            }
            ElementRule::ByTag { .. } => "Group nodes by tag within a container",
            ElementRule::ByVirtualizer => "Group hosts by their virtualizer",
            ElementRule::ByStack => "Group by Docker Compose project",
            ElementRule::ByTrunkPort => "Group trunk ports (ports carrying multiple VLANs)",
            ElementRule::ByVLAN => "Group access ports by native VLAN ID",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "is_user_editable": !self.is_locked(),
            "views": self.applicable_views(),
            "will_accept_edges": self.will_accept_edges(),
        })
    }
}

#[derive(Debug, Clone)]
pub struct GroupingConfig {
    pub container_rules: Vec<GraphRule<ContainerRule>>,
    pub element_rules: Vec<GraphRule<ElementRule>>,
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

    pub fn has_application_group_rule(&self) -> bool {
        self.container_rules
            .iter()
            .any(|r| matches!(r.rule, ContainerRule::ByApplicationGroup { .. }))
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
    fn test_from_default_options() {
        // Default perspective is L3Logical, which gets BySubnet + MergeDockerBridges
        let options = TopologyRequestOptions::default();
        let config = GroupingConfig::from_request_options(&options);

        assert!(config.should_group_docker_bridges());
        assert_eq!(config.container_rules.len(), 2);
        // L3Logical gets ByServiceCategory + ByTag + ByStack (3 of the 4 default element rules)
        assert_eq!(config.element_rules.len(), 3);
    }

    #[test]
    fn test_no_docker_grouping() {
        let mut options = TopologyRequestOptions::default();
        options.container_rules.insert(
            TopologyView::L3Logical,
            vec![GraphRule::new(ContainerRule::BySubnet)],
        );
        let config = GroupingConfig::from_request_options(&options);

        assert!(!config.should_group_docker_bridges());
    }

    #[test]
    fn test_service_category_grouping() {
        let options = TopologyRequestOptions {
            element_rules: vec![GraphRule::new(ElementRule::ByServiceCategory {
                categories: vec![ServiceCategory::DNS],
                title: Some("Infra".into()),
            })],
            ..Default::default()
        };
        let config = GroupingConfig::from_request_options(&options);

        let has_category_rule = config.element_rules.iter().any(|r| match &r.rule {
            ElementRule::ByServiceCategory { categories, .. } => {
                categories.contains(&ServiceCategory::DNS)
            }
            _ => false,
        });
        assert!(has_category_rule);
    }

    #[test]
    fn test_serialization_round_trip_container_rules() {
        let rules = vec![
            GraphRule::new(ContainerRule::BySubnet),
            GraphRule::new(ContainerRule::MergeDockerBridges),
        ];

        let json = serde_json::to_string(&rules).unwrap();
        let deserialized: Vec<GraphRule<ContainerRule>> = serde_json::from_str(&json).unwrap();
        assert_eq!(rules, deserialized);
    }

    #[test]
    fn test_serialization_round_trip_element_rules() {
        let rules = vec![
            GraphRule::new(ElementRule::ByServiceCategory {
                categories: vec![ServiceCategory::DNS, ServiceCategory::ReverseProxy],
                title: Some("Infrastructure".into()),
            }),
            GraphRule::new(ElementRule::ByTag {
                tag_ids: vec![Uuid::new_v4(), Uuid::new_v4()],
                title: Some("Tagged".into()),
            }),
            GraphRule::new(ElementRule::ByStack),
        ];

        let json = serde_json::to_string(&rules).unwrap();
        let deserialized: Vec<GraphRule<ElementRule>> = serde_json::from_str(&json).unwrap();
        assert_eq!(rules, deserialized);
    }

    #[test]
    fn test_by_stack_serde_round_trip() {
        let rule = GraphRule::new(ElementRule::ByStack);
        let json = serde_json::to_string(&rule).unwrap();
        assert!(json.contains("ByStack"));
        let deserialized: GraphRule<ElementRule> = serde_json::from_str(&json).unwrap();
        assert_eq!(rule, deserialized);
    }
}
