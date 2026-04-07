use crate::server::shared::{
    concepts::Concept,
    entities::EntityDiscriminants,
    types::{
        Color, Icon,
        metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
    },
};
use serde::{Deserialize, Serialize};
use strum::IntoEnumIterator;
use strum_macros::{EnumIter, IntoStaticStr};
use utoipa::ToSchema;

use super::edges::{
    EdgeDefaultVisibility, EdgeHighlightBehavior, EdgeStroke, EdgeTypeDiscriminants, EdgeViewConfig,
};

// ---------------------------------------------------------------------------
// TopologyView enum
// ---------------------------------------------------------------------------

/// Which topology view is being rendered
#[derive(
    Debug,
    Clone,
    Copy,
    Serialize,
    Deserialize,
    PartialEq,
    Eq,
    Hash,
    Default,
    ToSchema,
    EnumIter,
    IntoStaticStr,
)]
pub enum TopologyView {
    L2Physical,
    #[default]
    L3Logical,
    Infrastructure,
    Application,
}

impl HasId for TopologyView {
    fn id(&self) -> &'static str {
        self.into()
    }
}

// ---------------------------------------------------------------------------
// ViewElementConfig — defines how a view structures its elements
// ---------------------------------------------------------------------------

/// Defines the entity hierarchy for a topology view:
/// parent (owns elements) → element (rendered as nodes) → inline (shown inside nodes)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, ToSchema)]
pub struct ViewElementConfig {
    /// Entity that owns elements (e.g. Host owns Interfaces in L3)
    pub parent_entity: Option<EntityDiscriminants>,
    /// Entity rendered as element nodes
    pub element_entity: EntityDiscriminants,
    /// Entities shown inside element nodes (e.g. Services displayed as cards)
    pub inline_entities: Vec<EntityDiscriminants>,
}

// ---------------------------------------------------------------------------
// Inspector types
// ---------------------------------------------------------------------------

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
    ApplicationGroup,
}

/// View-specific inspector panel configuration.
/// Determines which sections appear and in what order for each view.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, ToSchema)]
pub struct ViewInspectorConfig {
    pub element_sections: Vec<InspectorSection>,
    pub container_sections: Vec<InspectorSection>,
    pub bulk_tag_entity: EntityDiscriminants,
    pub dependency_creation: Option<DependencyMemberType>,
    pub show_application_group_picker: bool,
}

// ---------------------------------------------------------------------------
// TopologyView — metadata impls
// ---------------------------------------------------------------------------

impl EntityMetadataProvider for TopologyView {
    fn color(&self) -> Color {
        match self {
            Self::L2Physical => Concept::L2.color(),
            Self::L3Logical => Concept::L3.color(),
            Self::Infrastructure => Concept::Infrastructure.color(),
            Self::Application => Concept::Application.color(),
        }
    }

    fn icon(&self) -> Icon {
        match self {
            Self::L2Physical => Concept::L2.icon(),
            Self::L3Logical => Concept::L3.icon(),
            Self::Infrastructure => Concept::Infrastructure.icon(),
            Self::Application => Concept::Application.icon(),
        }
    }
}

impl TypeMetadataProvider for TopologyView {
    fn name(&self) -> &'static str {
        match self {
            Self::L2Physical => "L2 Physical",
            Self::L3Logical => "L3 Logical",
            Self::Infrastructure => "Infrastructure",
            Self::Application => "Application",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            Self::L2Physical => "Physical layer 2 network topology",
            Self::L3Logical => "Logical layer 3 network topology",
            Self::Infrastructure => "Infrastructure and virtualization topology",
            Self::Application => "Application and service dependency topology",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let edge_view_configs: serde_json::Map<String, serde_json::Value> =
            EdgeTypeDiscriminants::iter()
                .map(|et| {
                    (
                        et.to_string(),
                        serde_json::to_value(self.edge_view_config(et)).unwrap(),
                    )
                })
                .collect();

        serde_json::json!({
            "element_config": self.element_config(),
            "element_label": self.element_label(),
            "element_label_singular": self.element_label_singular(),
            "edge_view_configs": edge_view_configs,
            "inspector_config": self.inspector_config()
        })
    }
}

// ---------------------------------------------------------------------------
// TopologyView — typed methods
// ---------------------------------------------------------------------------

impl TopologyView {
    /// The entity hierarchy for this view: parent → element → inline
    pub fn element_config(&self) -> ViewElementConfig {
        match self {
            Self::L3Logical => ViewElementConfig {
                parent_entity: Some(EntityDiscriminants::Host),
                element_entity: EntityDiscriminants::Interface,
                inline_entities: vec![EntityDiscriminants::Service],
            },
            Self::L2Physical => ViewElementConfig {
                parent_entity: Some(EntityDiscriminants::Host),
                element_entity: EntityDiscriminants::IfEntry,
                inline_entities: vec![],
            },
            Self::Infrastructure => ViewElementConfig {
                parent_entity: None,
                element_entity: EntityDiscriminants::Host,
                inline_entities: vec![EntityDiscriminants::Service],
            },
            Self::Application => ViewElementConfig {
                parent_entity: None,
                element_entity: EntityDiscriminants::Service,
                inline_entities: vec![],
            },
        }
    }

    /// Human-friendly plural label for element nodes (e.g. "host interfaces")
    pub fn element_label(&self) -> &'static str {
        match self {
            Self::L2Physical => "ports",
            Self::L3Logical => "host interfaces",
            Self::Infrastructure => "hosts",
            Self::Application => "services",
        }
    }

    /// Human-friendly singular label for element nodes (e.g. "host interface")
    pub fn element_label_singular(&self) -> &'static str {
        match self {
            Self::L2Physical => "port",
            Self::L3Logical => "host interface",
            Self::Infrastructure => "host",
            Self::Application => "service",
        }
    }

    /// Per-view configuration for each edge type.
    /// All match arms are exhaustive — adding a new EdgeTypeDiscriminants variant
    /// will cause a compile error here, forcing a configuration decision.
    pub fn edge_view_config(&self, edge_type: EdgeTypeDiscriminants) -> EdgeViewConfig {
        use EdgeDefaultVisibility::*;
        use EdgeHighlightBehavior::*;
        use EdgeStroke::*;
        use EdgeTypeDiscriminants::*;

        let active = |affects_layout, visibility, stroke, highlight, will_target_container| {
            EdgeViewConfig::Active {
                affects_layout,
                default_visibility: visibility,
                stroke,
                highlight_behavior: highlight,
                will_target_container,
            }
        };

        match self {
            Self::L3Logical => match edge_type {
                Interface => active(true, Visible, Solid, WhenVisible, false),
                ServiceVirtualization => active(true, Visible, Solid, WhenVisible, true),
                RequestPath => active(false, Visible, Dashed, WhenVisible, false),
                HubAndSpoke => active(false, Visible, Dashed, WhenVisible, false),
                HostVirtualization => active(false, Hidden, Dashed, WhenVisible, true),
                PhysicalLink => active(false, Hidden, Dashed, WhenVisible, false),
            },
            Self::L2Physical => match edge_type {
                PhysicalLink => active(true, Visible, Solid, WhenVisible, false),
                Interface => active(false, Hidden, Dashed, WhenVisible, false),
                HostVirtualization | ServiceVirtualization | RequestPath | HubAndSpoke => {
                    EdgeViewConfig::Disabled
                }
            },
            Self::Infrastructure => match edge_type {
                HostVirtualization => active(true, Hidden, Dashed, Always, true),
                ServiceVirtualization => active(true, Hidden, Dashed, Always, true),
                Interface | PhysicalLink | RequestPath | HubAndSpoke => EdgeViewConfig::Disabled,
            },
            Self::Application => match edge_type {
                RequestPath => active(true, Visible, Solid, WhenVisible, false),
                HubAndSpoke => active(true, Visible, Solid, WhenVisible, false),
                ServiceVirtualization => active(true, Hidden, Dashed, Always, true),
                Interface | HostVirtualization | PhysicalLink => EdgeViewConfig::Disabled,
            },
        }
    }

    /// Inspector panel configuration for this view
    pub fn inspector_config(&self) -> ViewInspectorConfig {
        let element_config = self.element_config();
        let bulk_tag_entity = element_config
            .parent_entity
            .unwrap_or(element_config.element_entity);

        match self {
            Self::L3Logical => ViewInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::HostDetail,
                    InspectorSection::IfEntryData,
                    InspectorSection::Services,
                    InspectorSection::OtherInterfaces,
                ],
                container_sections: vec![
                    InspectorSection::SubnetDetail,
                    InspectorSection::ElementSummary,
                ],
                bulk_tag_entity,
                dependency_creation: Some(DependencyMemberType::Bindings),
                show_application_group_picker: false,
            },
            Self::Application => ViewInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::Dependencies,
                    InspectorSection::ApplicationGroup,
                ],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::DependencySummary,
                ],
                bulk_tag_entity,
                dependency_creation: Some(DependencyMemberType::Services),
                show_application_group_picker: true,
            },
            Self::Infrastructure => ViewInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::HostDetail,
                    InspectorSection::Services,
                    InspectorSection::OtherInterfaces,
                ],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::ElementSummary,
                ],
                bulk_tag_entity,
                dependency_creation: None,
                show_application_group_picker: false,
            },
            Self::L2Physical => ViewInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::IfEntryData,
                    InspectorSection::Tags,
                ],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::ElementSummary,
                ],
                bulk_tag_entity,
                dependency_creation: None,
                show_application_group_picker: false,
            },
        }
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;
    use strum::IntoEnumIterator;

    #[test]
    fn topology_view_serde_round_trip() {
        let json = serde_json::to_value(TopologyView::L2Physical).unwrap();
        assert_eq!(json, "L2Physical");
        let deserialized: TopologyView = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, TopologyView::L2Physical);
    }

    #[test]
    fn all_views_have_non_empty_sections() {
        for view in TopologyView::iter() {
            let config = view.inspector_config();
            assert!(
                !config.element_sections.is_empty(),
                "{:?} has no element sections",
                view
            );
            assert!(
                !config.container_sections.is_empty(),
                "{:?} has no container sections",
                view
            );
        }
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
        let config = TopologyView::Application.inspector_config();
        let json = serde_json::to_string(&config).unwrap();
        let deserialized: ViewInspectorConfig = serde_json::from_str(&json).unwrap();
        assert_eq!(config, deserialized);
    }
}
