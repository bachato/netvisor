use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider};
use crate::server::shared::types::{Color, Icon};
use crate::server::topology::types::base::TopologyRequestOptions;
use serde::{Deserialize, Serialize};
use strum_macros::{EnumIter, IntoStaticStr};
use utoipa::ToSchema;
use uuid::Uuid;

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
        })
    }
}

/// Rules that organize nodes within a container into sub-groups.
#[derive(
    Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, ToSchema, EnumIter, IntoStaticStr,
)]
pub enum LeafRule {
    ByServiceCategory {
        categories: Vec<ServiceCategory>,
        title: Option<String>,
    },
    ByTag {
        tag_ids: Vec<Uuid>,
        title: Option<String>,
    },
}

impl HasId for LeafRule {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for LeafRule {
    fn color(&self) -> Color {
        match self {
            LeafRule::ByServiceCategory { .. } => Color::Purple,
            LeafRule::ByTag { .. } => Color::Orange,
        }
    }

    fn icon(&self) -> Icon {
        match self {
            LeafRule::ByServiceCategory { .. } => Icon::Layers,
            LeafRule::ByTag { .. } => Icon::Tag,
        }
    }
}

impl TypeMetadataProvider for LeafRule {
    fn name(&self) -> &'static str {
        match self {
            LeafRule::ByServiceCategory { .. } => "Service category",
            LeafRule::ByTag { .. } => "Tag",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            LeafRule::ByServiceCategory { .. } => {
                "Group nodes by service category within a container"
            }
            LeafRule::ByTag { .. } => "Group nodes by tag within a container",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "is_user_editable": true,
        })
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum NodeFilter {
    HideServiceCategories(Vec<ServiceCategory>),
}

#[derive(Debug, Clone)]
pub struct GroupingConfig {
    pub container_rules: Vec<ContainerRule>,
    pub leaf_rules: Vec<LeafRule>,
    pub filters: Vec<NodeFilter>,
}

impl GroupingConfig {
    pub fn from_request_options(options: &TopologyRequestOptions) -> Self {
        let container_rules = options.container_rules.clone();
        let leaf_rules = options.leaf_rules.clone();

        let filters = if !options.hide_service_categories.is_empty() {
            vec![NodeFilter::HideServiceCategories(
                options.hide_service_categories.clone(),
            )]
        } else {
            vec![]
        };

        GroupingConfig {
            container_rules,
            leaf_rules,
            filters,
        }
    }

    pub fn should_group_docker_bridges(&self) -> bool {
        self.container_rules
            .iter()
            .any(|r| matches!(r, ContainerRule::ByVirtualizingService))
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
        assert_eq!(config.container_rules.len(), 2); // BySubnet + ByVirtualizingService
        assert_eq!(config.leaf_rules.len(), 1); // ByServiceCategory
        assert_eq!(config.filters.len(), 1); // HideServiceCategories(OpenPorts)
    }

    #[test]
    fn test_no_docker_grouping() {
        let options = TopologyRequestOptions {
            container_rules: vec![ContainerRule::BySubnet],
            ..Default::default()
        };
        let config = GroupingConfig::from_request_options(&options);

        assert!(!config.should_group_docker_bridges());
    }

    #[test]
    fn test_service_category_grouping() {
        let options = TopologyRequestOptions {
            leaf_rules: vec![LeafRule::ByServiceCategory {
                categories: vec![ServiceCategory::DNS],
                title: Some("Infra".into()),
            }],
            ..Default::default()
        };
        let config = GroupingConfig::from_request_options(&options);

        let has_category_rule = config.leaf_rules.iter().any(|r| match r {
            LeafRule::ByServiceCategory { categories, .. } => {
                categories.contains(&ServiceCategory::DNS)
            }
            _ => false,
        });
        assert!(has_category_rule);
    }

    #[test]
    fn test_no_filters_when_empty() {
        let options = TopologyRequestOptions {
            hide_service_categories: vec![],
            ..Default::default()
        };
        let config = GroupingConfig::from_request_options(&options);
        assert!(config.filters.is_empty());
    }

    #[test]
    fn test_serialization_round_trip_container_rules() {
        let rules = vec![
            ContainerRule::BySubnet,
            ContainerRule::ByVirtualizingService,
        ];

        let json = serde_json::to_string(&rules).unwrap();
        let deserialized: Vec<ContainerRule> = serde_json::from_str(&json).unwrap();
        assert_eq!(rules, deserialized);
    }

    #[test]
    fn test_serialization_round_trip_leaf_rules() {
        let rules = vec![
            LeafRule::ByServiceCategory {
                categories: vec![ServiceCategory::DNS, ServiceCategory::ReverseProxy],
                title: Some("Infrastructure".into()),
            },
            LeafRule::ByTag {
                tag_ids: vec![Uuid::new_v4(), Uuid::new_v4()],
                title: Some("Tagged".into()),
            },
        ];

        let json = serde_json::to_string(&rules).unwrap();
        let deserialized: Vec<LeafRule> = serde_json::from_str(&json).unwrap();
        assert_eq!(rules, deserialized);
    }
}
