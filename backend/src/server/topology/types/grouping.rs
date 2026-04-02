use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::topology::types::base::TopologyRequestOptions;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum GroupingRule {
    BySubnet,
    ByServiceCategory(Vec<ServiceCategory>),
    ByVirtualizingService,
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
        let mut primary = vec![GroupingRule::BySubnet];

        if options.group_docker_bridges_by_host {
            primary.push(GroupingRule::ByVirtualizingService);
        }

        if !options.left_zone_service_categories.is_empty() {
            let categories = options.left_zone_service_categories.clone();
            primary.push(GroupingRule::ByServiceCategory(categories));
        }

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
            .any(|r| matches!(r, GroupingRule::ByVirtualizingService))
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
            group_docker_bridges_by_host: false,
            ..Default::default()
        };
        let config = GroupingConfig::from_request_options(&options);

        assert!(!config.should_group_docker_bridges());
        assert!(
            !config
                .primary
                .iter()
                .any(|r| matches!(r, GroupingRule::ByVirtualizingService))
        );
    }

    #[test]
    fn test_service_category_grouping() {
        let options = TopologyRequestOptions {
            left_zone_service_categories: vec![ServiceCategory::DNS],
            show_gateway_in_left_zone: true,
            ..Default::default()
        };
        let config = GroupingConfig::from_request_options(&options);

        let has_category_rule = config.primary.iter().any(|r| match r {
            GroupingRule::ByServiceCategory(cats) => cats.contains(&ServiceCategory::DNS),
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
}
