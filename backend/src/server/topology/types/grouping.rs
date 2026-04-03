use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::topology::types::base::TopologyRequestOptions;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, ToSchema)]
pub enum GroupingRule {
    BySubnet {
        title: Option<String>,
    },
    ByServiceCategory {
        categories: Vec<ServiceCategory>,
        title: Option<String>,
    },
    ByVirtualizingService {
        title: Option<String>,
    },
    ByTag {
        tag_ids: Vec<Uuid>,
        title: Option<String>,
    },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum NodeFilter {
    HideServiceCategories(Vec<ServiceCategory>),
}

#[derive(Debug, Clone)]
pub struct GroupingConfig {
    pub primary: Vec<GroupingRule>,
    pub cross_cutting: Vec<GroupingRule>,
    pub filters: Vec<NodeFilter>,
}

impl GroupingConfig {
    pub fn from_request_options(options: &TopologyRequestOptions) -> Self {
        let primary = options.grouping_rules.clone();

        let filters = if !options.hide_service_categories.is_empty() {
            vec![NodeFilter::HideServiceCategories(
                options.hide_service_categories.clone(),
            )]
        } else {
            vec![]
        };

        GroupingConfig {
            primary,
            cross_cutting: vec![],
            filters,
        }
    }

    pub fn should_group_docker_bridges(&self) -> bool {
        self.primary
            .iter()
            .any(|r| matches!(r, GroupingRule::ByVirtualizingService { .. }))
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
        assert_eq!(config.primary.len(), 3); // BySubnet + ByVirtualizingService + ByServiceCategory
        assert_eq!(config.cross_cutting.len(), 0);
        assert_eq!(config.filters.len(), 1); // HideServiceCategories(OpenPorts)
    }

    #[test]
    fn test_no_docker_grouping() {
        let options = TopologyRequestOptions {
            grouping_rules: vec![
                GroupingRule::BySubnet { title: None },
                GroupingRule::ByServiceCategory {
                    categories: vec![ServiceCategory::DNS, ServiceCategory::ReverseProxy],
                    title: None,
                },
            ],
            ..Default::default()
        };
        let config = GroupingConfig::from_request_options(&options);

        assert!(!config.should_group_docker_bridges());
        assert!(
            !config
                .primary
                .iter()
                .any(|r| matches!(r, GroupingRule::ByVirtualizingService { .. }))
        );
    }

    #[test]
    fn test_service_category_grouping() {
        let options = TopologyRequestOptions {
            grouping_rules: vec![
                GroupingRule::BySubnet { title: None },
                GroupingRule::ByServiceCategory {
                    categories: vec![ServiceCategory::DNS],
                    title: Some("Infra".into()),
                },
            ],
            ..Default::default()
        };
        let config = GroupingConfig::from_request_options(&options);

        let has_category_rule = config.primary.iter().any(|r| match r {
            GroupingRule::ByServiceCategory { categories, .. } => {
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
    fn test_serialization_round_trip_all_variants() {
        let rules = vec![
            GroupingRule::BySubnet {
                title: Some("Subnets".into()),
            },
            GroupingRule::ByVirtualizingService { title: None },
            GroupingRule::ByServiceCategory {
                categories: vec![ServiceCategory::DNS, ServiceCategory::ReverseProxy],
                title: Some("Infrastructure".into()),
            },
            GroupingRule::ByTag {
                tag_ids: vec![Uuid::new_v4(), Uuid::new_v4()],
                title: Some("Tagged".into()),
            },
        ];

        let json = serde_json::to_string(&rules).unwrap();
        let deserialized: Vec<GroupingRule> = serde_json::from_str(&json).unwrap();
        assert_eq!(rules, deserialized);
    }
}
