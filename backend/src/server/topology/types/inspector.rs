use crate::server::shared::entities::EntityDiscriminants;
use serde::{Deserialize, Serialize};
use strum_macros::{EnumIter, IntoStaticStr};
use utoipa::ToSchema;

use super::edges::TopologyPerspective;

/// Whether dependencies are tracked by service or by specific binding
#[derive(
    Debug,
    Clone,
    Copy,
    Serialize,
    Deserialize,
    PartialEq,
    Eq,
    Hash,
    ToSchema,
    EnumIter,
    IntoStaticStr,
)]
pub enum DependencyMemberType {
    Services,
    Bindings,
}

/// A section that can appear in the inspector panel
#[derive(
    Debug,
    Clone,
    Copy,
    Serialize,
    Deserialize,
    PartialEq,
    Eq,
    Hash,
    ToSchema,
    EnumIter,
    IntoStaticStr,
)]
pub enum InspectorSection {
    Identity,
    IfEntryData,
    Services,
    Dependencies,
    HostDetail,
    OtherInterfaces,
    Tags,
    PortBindings,
    SubnetDetail,
    ElementSummary,
    DependencySummary,
}

/// Perspective-specific inspector panel configuration.
/// Determines which sections appear and in what order for each perspective.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, ToSchema)]
pub struct PerspectiveInspectorConfig {
    pub element_sections: Vec<InspectorSection>,
    pub container_sections: Vec<InspectorSection>,
    pub bulk_tag_entity: EntityDiscriminants,
    pub dependency_creation: Option<DependencyMemberType>,
    pub show_application_group_picker: bool,
}

impl TopologyPerspective {
    pub fn inspector_config(&self) -> PerspectiveInspectorConfig {
        match self {
            Self::L3Logical => PerspectiveInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::IfEntryData,
                    InspectorSection::Services,
                    InspectorSection::HostDetail,
                    InspectorSection::OtherInterfaces,
                    InspectorSection::Tags,
                ],
                container_sections: vec![
                    InspectorSection::SubnetDetail,
                    InspectorSection::ElementSummary,
                ],
                bulk_tag_entity: EntityDiscriminants::Host,
                dependency_creation: Some(DependencyMemberType::Bindings),
                show_application_group_picker: false,
            },
            Self::Application => PerspectiveInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::Dependencies,
                    InspectorSection::PortBindings,
                    InspectorSection::Tags,
                ],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::DependencySummary,
                ],
                bulk_tag_entity: EntityDiscriminants::Service,
                dependency_creation: Some(DependencyMemberType::Services),
                show_application_group_picker: true,
            },
            Self::Infrastructure => PerspectiveInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::Services,
                    InspectorSection::Tags,
                ],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::ElementSummary,
                ],
                bulk_tag_entity: EntityDiscriminants::Host,
                dependency_creation: None,
                show_application_group_picker: false,
            },
            Self::L2Physical => PerspectiveInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::IfEntryData,
                    InspectorSection::Tags,
                ],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::ElementSummary,
                ],
                bulk_tag_entity: EntityDiscriminants::Host,
                dependency_creation: None,
                show_application_group_picker: false,
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use strum::IntoEnumIterator;

    #[test]
    fn all_perspectives_have_non_empty_sections() {
        for perspective in TopologyPerspective::iter() {
            let config = perspective.inspector_config();
            assert!(
                !config.element_sections.is_empty(),
                "{:?} has no element sections",
                perspective
            );
            assert!(
                !config.container_sections.is_empty(),
                "{:?} has no container sections",
                perspective
            );
        }
    }

    #[test]
    fn l3_config_uses_bindings_and_host_tags() {
        let config = TopologyPerspective::L3Logical.inspector_config();
        assert_eq!(
            config.dependency_creation,
            Some(DependencyMemberType::Bindings)
        );
        assert_eq!(config.bulk_tag_entity, EntityDiscriminants::Host);
        assert!(!config.show_application_group_picker);
    }

    #[test]
    fn application_config_uses_services_and_service_tags() {
        let config = TopologyPerspective::Application.inspector_config();
        assert_eq!(
            config.dependency_creation,
            Some(DependencyMemberType::Services)
        );
        assert_eq!(config.bulk_tag_entity, EntityDiscriminants::Service);
        assert!(config.show_application_group_picker);
    }

    #[test]
    fn infrastructure_and_l2_have_no_dependency_creation() {
        assert_eq!(
            TopologyPerspective::Infrastructure
                .inspector_config()
                .dependency_creation,
            None
        );
        assert_eq!(
            TopologyPerspective::L2Physical
                .inspector_config()
                .dependency_creation,
            None
        );
    }

    #[test]
    fn serde_roundtrip_inspector_section() {
        let section = InspectorSection::Dependencies;
        let json = serde_json::to_string(&section).unwrap();
        let deserialized: InspectorSection = serde_json::from_str(&json).unwrap();
        assert_eq!(section, deserialized);
    }

    #[test]
    fn serde_roundtrip_config() {
        let config = TopologyPerspective::Application.inspector_config();
        let json = serde_json::to_string(&config).unwrap();
        let deserialized: PerspectiveInspectorConfig = serde_json::from_str(&json).unwrap();
        assert_eq!(config, deserialized);
    }
}
