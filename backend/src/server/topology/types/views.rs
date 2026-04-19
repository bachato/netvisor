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
    Workloads,
    Application,
}

impl HasId for TopologyView {
    fn id(&self) -> &'static str {
        self.into()
    }
}

// ---------------------------------------------------------------------------
// TopologyViewSupport — per-view data-availability flags
// ---------------------------------------------------------------------------

/// Per-view data-availability flags, computed from raw entity tables at
/// share-read time. Decoupled from the persisted topology graph because
/// that graph is view-specific — rebuilt under one view doesn't contain
/// the other views' nodes/edges.
///
/// Add a field per view-specific data requirement. Views that always
/// have the data they need (L3Logical / Workloads today) don't get a
/// field — `TopologyView::is_supported` just returns `true` for them.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TopologyViewSupport {
    /// L2Physical requires interface-level neighbor discovery (LLDP/CDP).
    pub l2_physical: bool,
    /// Application requires at least one application-flagged tag to be
    /// assigned to an entity in the topology's network.
    pub application: bool,
}

impl TopologyView {
    /// Whether a topology with the given support flags has enough data to
    /// render this view. Exhaustive by design — adding a new `TopologyView`
    /// variant will fail compilation here until its eligibility rule is
    /// declared.
    pub fn is_supported(&self, support: &TopologyViewSupport) -> bool {
        match self {
            Self::L3Logical => true,
            Self::L2Physical => support.l2_physical,
            Self::Workloads => true,
            Self::Application => support.application,
        }
    }
}

// ---------------------------------------------------------------------------
// ViewElementConfig — defines how a view structures its elements
// ---------------------------------------------------------------------------

/// Defines the entity hierarchy for a topology view:
/// container (grouping box) → element (rendered as nodes) → inline (shown inside nodes)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, ToSchema)]
pub struct ViewElementConfig {
    /// Entity rendered as the container/grouping box (e.g. Subnet in L3, Host in L2/Workloads)
    pub container_entity: Option<EntityDiscriminants>,
    /// Per-element-entity config: the entity types rendered as element nodes and
    /// (for each) which other entity types are shown *inside* those cards.
    /// Replaces the old flat `inline_entities` so views like Workloads — where
    /// Host elements inline services but Service elements inline nothing — can
    /// be expressed correctly.
    pub element_entities: Vec<ViewElementEntityConfig>,
    /// Single noun spanning all element entities. Used in summaries when the
    /// per-entity breakdown would be confusing (e.g. mixed Host+Service in
    /// Workloads, where everything is conceptually a "workload"). Singular;
    /// the UI pluralizes as needed.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub collective_noun: Option<String>,
}

/// An element-entity slot inside a view, plus the set of entity types that
/// render inline on that element's card. Card rendering (what services/ports
/// show up inside an element) and layout re-trigger fingerprinting both read
/// from this list.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, ToSchema)]
pub struct ViewElementEntityConfig {
    pub entity_type: EntityDiscriminants,
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
    Virtualization,
    OtherInterfaces,
    PortBindings,
    SubnetDetail,
    ElementSummary,
    DependencySummary,
    Application,
}

/// View-specific inspector panel configuration.
/// Determines which sections appear and in what order for each view.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, ToSchema)]
pub struct ViewInspectorConfig {
    pub element_sections: Vec<InspectorSection>,
    pub container_sections: Vec<InspectorSection>,
    pub dependency_creation: Option<DependencyMemberType>,
    pub show_application_picker: bool,
}

// ---------------------------------------------------------------------------
// TopologyView — metadata impls
// ---------------------------------------------------------------------------

impl EntityMetadataProvider for TopologyView {
    fn color(&self) -> Color {
        match self {
            Self::L2Physical => Concept::L2.color(),
            Self::L3Logical => Concept::L3.color(),
            Self::Workloads => Concept::Workloads.color(),
            Self::Application => Concept::Application.color(),
        }
    }

    fn icon(&self) -> Icon {
        match self {
            Self::L2Physical => Concept::L2.icon(),
            Self::L3Logical => Concept::L3.icon(),
            Self::Workloads => Concept::Workloads.icon(),
            Self::Application => Concept::Application.icon(),
        }
    }
}

impl TypeMetadataProvider for TopologyView {
    fn name(&self) -> &'static str {
        match self {
            Self::L2Physical => "L2 Physical",
            Self::L3Logical => "L3 Logical",
            Self::Workloads => "Workloads",
            Self::Application => "Applications",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            Self::L2Physical => "Interfaces and physical links between hosts",
            Self::L3Logical => "IP addresses and connectivity across subnets",
            Self::Workloads => "Services, VMs, and containers per host",
            Self::Application => "Services per application",
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
                container_entity: Some(EntityDiscriminants::Subnet),
                element_entities: vec![ViewElementEntityConfig {
                    entity_type: EntityDiscriminants::IPAddress,
                    inline_entities: vec![EntityDiscriminants::Service, EntityDiscriminants::Port],
                }],
                collective_noun: None,
            },
            Self::L2Physical => ViewElementConfig {
                container_entity: Some(EntityDiscriminants::Host),
                element_entities: vec![ViewElementEntityConfig {
                    entity_type: EntityDiscriminants::Interface,
                    inline_entities: vec![],
                }],
                collective_noun: None,
            },
            Self::Workloads => ViewElementConfig {
                container_entity: Some(EntityDiscriminants::Host),
                element_entities: vec![
                    ViewElementEntityConfig {
                        entity_type: EntityDiscriminants::Service,
                        inline_entities: vec![],
                    },
                    ViewElementEntityConfig {
                        entity_type: EntityDiscriminants::Host,
                        inline_entities: vec![EntityDiscriminants::Service],
                    },
                ],
                collective_noun: Some("workload".to_string()),
            },
            Self::Application => ViewElementConfig {
                container_entity: None,
                element_entities: vec![ViewElementEntityConfig {
                    entity_type: EntityDiscriminants::Service,
                    inline_entities: vec![],
                }],
                collective_noun: None,
            },
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

        let active = |affects_layout,
                      visibility,
                      stroke,
                      highlight,
                      will_target_container,
                      show_directionality| {
            EdgeViewConfig::Active {
                affects_layout,
                default_visibility: visibility,
                stroke,
                highlight_behavior: highlight,
                will_target_container,
                show_directionality,
            }
        };

        match self {
            Self::L3Logical => match edge_type {
                SameHost => active(true, Visible, Solid, WhenVisible, false, false),
                ContainerRuntime => active(true, Visible, Solid, WhenVisible, true, false),
                RequestPath => active(false, Visible, Dashed, WhenVisible, false, true),
                HubAndSpoke => active(false, Visible, Dashed, WhenVisible, false, true),
                Hypervisor => active(false, Hidden, Dashed, WhenVisible, true, false),
                PhysicalLink => active(false, Hidden, Dashed, WhenVisible, false, false),
            },
            Self::L2Physical => match edge_type {
                PhysicalLink => active(true, Visible, Solid, WhenVisible, false, false),
                SameHost => active(false, Hidden, Dashed, WhenVisible, false, false),
                Hypervisor | ContainerRuntime | RequestPath | HubAndSpoke => {
                    EdgeViewConfig::Disabled
                }
            },
            Self::Workloads => match edge_type {
                PhysicalLink => active(false, Hidden, Dashed, WhenVisible, false, false),
                RequestPath | HubAndSpoke => {
                    active(false, Hidden, Dashed, WhenVisible, false, true)
                }
                Hypervisor | ContainerRuntime | SameHost => EdgeViewConfig::Disabled,
            },
            Self::Application => match edge_type {
                RequestPath => active(true, Visible, Solid, WhenVisible, false, true),
                HubAndSpoke => active(true, Visible, Solid, WhenVisible, false, true),
                ContainerRuntime => active(true, Hidden, Dashed, Always, true, false),
                SameHost | Hypervisor | PhysicalLink => EdgeViewConfig::Disabled,
            },
        }
    }

    /// Inspector panel configuration for this view
    pub fn inspector_config(&self) -> ViewInspectorConfig {
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
                dependency_creation: Some(DependencyMemberType::Bindings),
                show_application_picker: false,
            },
            Self::Application => ViewInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::Dependencies,
                    InspectorSection::Application,
                ],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::ElementSummary,
                    InspectorSection::DependencySummary,
                ],
                dependency_creation: Some(DependencyMemberType::Services),
                show_application_picker: true,
            },
            Self::Workloads => ViewInspectorConfig {
                element_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::HostDetail,
                    InspectorSection::Virtualization,
                    InspectorSection::Services,
                    InspectorSection::OtherInterfaces,
                ],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::ElementSummary,
                ],
                dependency_creation: Some(DependencyMemberType::Services),
                show_application_picker: false,
            },
            Self::L2Physical => ViewInspectorConfig {
                element_sections: vec![InspectorSection::Identity, InspectorSection::IfEntryData],
                container_sections: vec![
                    InspectorSection::Identity,
                    InspectorSection::ElementSummary,
                ],
                dependency_creation: None,
                show_application_picker: false,
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
