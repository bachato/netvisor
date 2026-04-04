use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider};
use crate::server::shared::types::{Color, Icon};
use crate::server::topology::types::base::TopologyRequestOptions;
use crate::server::topology::types::edges::TopologyPerspective;
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
    Debug,
    Clone,
    Copy,
    PartialEq,
    Eq,
    Hash,
    Serialize,
    Deserialize,
    ToSchema,
    EnumIter,
    IntoStaticStr,
)]
pub enum ContainerRule {
    BySubnet,
    ByVirtualizingService,
}

impl ContainerRule {
    pub fn applicable_perspectives(&self) -> &'static [TopologyPerspective] {
        match self {
            ContainerRule::BySubnet => &[TopologyPerspective::L3Logical],
            ContainerRule::ByVirtualizingService => &[
                TopologyPerspective::L3Logical,
                TopologyPerspective::Infrastructure,
            ],
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
            ContainerRule::ByVirtualizingService => Color::Teal,
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ContainerRule::BySubnet => Icon::Network,
            ContainerRule::ByVirtualizingService => Icon::Boxes,
        }
    }
}

impl TypeMetadataProvider for ContainerRule {
    fn name(&self) -> &'static str {
        match self {
            ContainerRule::BySubnet => "Subnet",
            ContainerRule::ByVirtualizingService => "Docker bridges",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ContainerRule::BySubnet => "Group nodes by network subnet",
            ContainerRule::ByVirtualizingService => "Merge Docker bridge subnets under their host",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "is_user_editable": matches!(self, ContainerRule::ByVirtualizingService),
            "perspectives": self.applicable_perspectives(),
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
}

impl ElementRule {
    pub fn applicable_perspectives(&self) -> &'static [TopologyPerspective] {
        match self {
            ElementRule::ByServiceCategory { .. } => &[
                TopologyPerspective::L3Logical,
                TopologyPerspective::Application,
            ],
            ElementRule::ByTag { .. } => &[
                TopologyPerspective::L3Logical,
                TopologyPerspective::L2Physical,
                TopologyPerspective::Infrastructure,
                TopologyPerspective::Application,
            ],
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
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ElementRule::ByServiceCategory { .. } => Icon::Layers,
            ElementRule::ByTag { .. } => Icon::Tag,
        }
    }
}

impl TypeMetadataProvider for ElementRule {
    fn name(&self) -> &'static str {
        match self {
            ElementRule::ByServiceCategory { .. } => "Service category",
            ElementRule::ByTag { .. } => "Tag",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ElementRule::ByServiceCategory { .. } => {
                "Group nodes by service category within a container"
            }
            ElementRule::ByTag { .. } => "Group nodes by tag within a container",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "is_user_editable": true,
            "perspectives": self.applicable_perspectives(),
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
        let mut config = GroupingConfig {
            container_rules: options.container_rules.clone(),
            element_rules: options.element_rules.clone(),
        };

        // Apply perspective-specific overrides when present
        if let Some(ref overrides_map) = options.perspective_overrides
            && let Some(overrides) = overrides_map.get(&options.perspective)
        {
            if let Some(ref rules) = overrides.container_rules {
                config.container_rules = rules.clone();
            }
            if let Some(ref rules) = overrides.element_rules {
                config.element_rules = rules.clone();
            }
        }

        config
    }

    pub fn should_group_docker_bridges(&self) -> bool {
        self.container_rules
            .iter()
            .any(|r| matches!(r.rule, ContainerRule::ByVirtualizingService))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::topology::types::base::TopologyRequestOptions;

    #[test]
    fn test_from_default_options() {
        let options = TopologyRequestOptions::default();
        let config = GroupingConfig::from_request_options(&options);

        assert!(config.should_group_docker_bridges());
        assert_eq!(config.container_rules.len(), 2);
        assert_eq!(config.element_rules.len(), 1);
    }

    #[test]
    fn test_no_docker_grouping() {
        let options = TopologyRequestOptions {
            container_rules: vec![GraphRule::new(ContainerRule::BySubnet)],
            ..Default::default()
        };
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
            GraphRule::new(ContainerRule::ByVirtualizingService),
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
        ];

        let json = serde_json::to_string(&rules).unwrap();
        let deserialized: Vec<GraphRule<ElementRule>> = serde_json::from_str(&json).unwrap();
        assert_eq!(rules, deserialized);
    }
}
