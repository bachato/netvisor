use crate::server::{
    dependencies::r#impl::types::DependencyTypeDiscriminants,
    shared::{
        concepts::Concept,
        entities::EntityDiscriminants,
        types::{
            Color, Icon,
            metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
        },
    },
    topology::types::layout::Ixy,
};
use serde::{Deserialize, Serialize};
use strum::IntoEnumIterator;
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use utoipa::ToSchema;
use uuid::Uuid;

/// Protocol that discovered the physical link between network devices
#[derive(Debug, Clone, Copy, Serialize, Deserialize, Eq, PartialEq, Hash, Default, ToSchema)]
pub enum DiscoveryProtocol {
    /// Link Layer Discovery Protocol (IEEE 802.1AB)
    #[default]
    LLDP,
    /// Cisco Discovery Protocol (Cisco proprietary)
    CDP,
}

/// Whether an edge affects layout (primary) or is drawn after layout (overlay)
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum EdgeClassification {
    #[default]
    Primary,
    /// Overlay edge, visible by default in UI toggle
    Overlay,
    /// Overlay edge, hidden by default in UI toggle
    OverlayHidden,
    Disabled,
}

/// Which topology perspective is being rendered
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
pub enum TopologyPerspective {
    L2Physical,
    #[default]
    L3Logical,
    Infrastructure,
    Application,
}

impl HasId for TopologyPerspective {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for TopologyPerspective {
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

impl TypeMetadataProvider for TopologyPerspective {
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
        let edge_classifications: serde_json::Map<String, serde_json::Value> =
            EdgeTypeDiscriminants::iter()
                .map(|et| {
                    (
                        et.to_string(),
                        serde_json::to_value(self.classify_edge(et)).unwrap(),
                    )
                })
                .collect();

        serde_json::json!({
            "element_label": match self {
                Self::L2Physical => "ports",
                Self::L3Logical => "host interfaces",
                Self::Infrastructure => "hosts",
                Self::Application => "services",
            },
            "element_label_singular": match self {
                Self::L2Physical => "port",
                Self::L3Logical => "host interface",
                Self::Infrastructure => "host",
                Self::Application => "service",
            },
            "services_are_elements": matches!(self, Self::Application),
            "category_filter": matches!(self, Self::Application | Self::L3Logical | Self::Infrastructure),
            "tag_filter_categories": match self {
                Self::L3Logical => vec!["host", "service", "subnet"],
                Self::Application => vec!["service"],
                Self::L2Physical => vec!["host", "subnet"],
                Self::Infrastructure => vec!["host", "service"],
            },
            "edge_classifications": edge_classifications,
            "inspector_config": self.inspector_config()
        })
    }
}

impl TopologyPerspective {
    /// Classify an edge type for this perspective.
    /// All match arms are exhaustive — adding a new EdgeTypeDiscriminants variant
    /// will cause a compile error here, forcing a classification decision.
    pub fn classify_edge(&self, edge_type: EdgeTypeDiscriminants) -> EdgeClassification {
        use EdgeClassification::*;
        use EdgeTypeDiscriminants::*;
        match self {
            Self::L3Logical => match edge_type {
                Interface => Primary,
                ServiceVirtualization => Primary,
                HostVirtualization => OverlayHidden,
                PhysicalLink => OverlayHidden,
                RequestPath => Overlay,
                HubAndSpoke => Overlay,
            },
            Self::L2Physical => match edge_type {
                PhysicalLink => Primary,
                Interface => Overlay,
                HostVirtualization => OverlayHidden,
                ServiceVirtualization => OverlayHidden,
                RequestPath => OverlayHidden,
                HubAndSpoke => OverlayHidden,
            },
            Self::Infrastructure => match edge_type {
                HostVirtualization => Primary,
                ServiceVirtualization => Primary,
                Interface => Overlay,
                RequestPath => OverlayHidden,
                HubAndSpoke => OverlayHidden,
                PhysicalLink => OverlayHidden,
            },
            Self::Application => match edge_type {
                RequestPath => Primary,
                HubAndSpoke => Primary,
                Interface => OverlayHidden,
                HostVirtualization => OverlayHidden,
                ServiceVirtualization => OverlayHidden,
                PhysicalLink => OverlayHidden,
            },
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash, ToSchema)]
pub struct Edge {
    pub id: Uuid,
    pub source: Uuid,
    pub target: Uuid,
    #[serde(flatten)]
    pub edge_type: EdgeType,
    #[schema(required)]
    pub label: Option<String>,
    pub source_handle: EdgeHandle,
    pub target_handle: EdgeHandle,
    pub is_multi_hop: bool,
    #[serde(default)]
    pub classification: EdgeClassification,
}

#[derive(
    Serialize,
    Copy,
    Deserialize,
    Debug,
    Clone,
    Eq,
    PartialEq,
    Hash,
    PartialOrd,
    Ord,
    Default,
    ToSchema,
)]
pub enum EdgeHandle {
    #[default]
    Top,
    Bottom,
    Left,
    Right,
}

#[derive(
    Serialize,
    Copy,
    Deserialize,
    Debug,
    Clone,
    Eq,
    PartialEq,
    Hash,
    Default,
    IntoStaticStr,
    Display,
    ToSchema,
)]
pub enum EdgeStyle {
    Straight,
    #[default]
    SmoothStep,
    Step,
    Bezier,
    SimpleBezier,
}

impl EdgeHandle {
    pub fn layout_priority(&self) -> u8 {
        match self {
            EdgeHandle::Top => 0,
            EdgeHandle::Bottom => 1,
            EdgeHandle::Left => 2,
            EdgeHandle::Right => 3,
        }
    }

    pub fn direction(&self) -> Ixy {
        match self {
            EdgeHandle::Top => Ixy { x: 0, y: 1 },
            EdgeHandle::Bottom => Ixy { x: 0, y: -1 },
            EdgeHandle::Left => Ixy { x: -1, y: 0 },
            EdgeHandle::Right => Ixy { x: 1, y: 0 },
        }
    }

    pub fn is_horizontal(&self) -> bool {
        matches!(self, EdgeHandle::Left | EdgeHandle::Right)
    }

    pub fn is_vertical(&self) -> bool {
        matches!(self, EdgeHandle::Top | EdgeHandle::Bottom)
    }
}

#[derive(
    Debug,
    Clone,
    PartialEq,
    Eq,
    Hash,
    Serialize,
    Deserialize,
    EnumDiscriminants,
    IntoStaticStr,
    EnumIter,
    ToSchema,
)]
#[strum_discriminants(derive(Display, Hash, Serialize, Deserialize, EnumIter, ToSchema))]
#[serde(tag = "edge_type")]
pub enum EdgeType {
    Interface {
        host_id: Uuid,
    }, // Connecting hosts with interfaces in multiple subnets
    HostVirtualization {
        vm_service_id: Uuid,
    },
    ServiceVirtualization {
        host_id: Uuid,
        containerizing_service_id: Uuid,
    },
    RequestPath {
        group_id: Uuid,
        source_binding_id: Uuid,
        target_binding_id: Uuid,
    },
    HubAndSpoke {
        group_id: Uuid,
        source_binding_id: Uuid,
        target_binding_id: Uuid,
    },
    /// Physical link discovered via LLDP/CDP neighbor discovery
    PhysicalLink {
        source_if_entry_id: Uuid,
        target_if_entry_id: Uuid,
        protocol: DiscoveryProtocol,
    },
}

impl HasId for EdgeType {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for EdgeType {
    fn color(&self) -> Color {
        match self {
            EdgeType::RequestPath { .. } => EntityDiscriminants::Dependency.color(),
            EdgeType::HubAndSpoke { .. } => EntityDiscriminants::Dependency.color(),
            EdgeType::Interface { .. } => EntityDiscriminants::Host.color(),
            EdgeType::HostVirtualization { .. } => Concept::Virtualization.color(),
            EdgeType::ServiceVirtualization { .. } => Concept::Virtualization.color(),
            EdgeType::PhysicalLink { .. } => EntityDiscriminants::IfEntry.color(),
        }
    }

    fn icon(&self) -> Icon {
        match self {
            EdgeType::RequestPath { .. } => DependencyTypeDiscriminants::RequestPath.icon(),
            EdgeType::HubAndSpoke { .. } => DependencyTypeDiscriminants::HubAndSpoke.icon(),
            EdgeType::Interface { .. } => EntityDiscriminants::Host.icon(),
            EdgeType::HostVirtualization { .. } => Concept::Virtualization.icon(),
            EdgeType::ServiceVirtualization { .. } => Concept::Virtualization.icon(),
            EdgeType::PhysicalLink { .. } => EntityDiscriminants::IfEntry.icon(),
        }
    }
}

impl TypeMetadataProvider for EdgeType {
    fn name(&self) -> &'static str {
        match self {
            EdgeType::RequestPath { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::HubAndSpoke { .. } => DependencyTypeDiscriminants::HubAndSpoke.name(),
            EdgeType::Interface { .. } => "Host Interface",
            EdgeType::HostVirtualization { .. } => "Virtualized Host",
            EdgeType::ServiceVirtualization { .. } => "Virtualized Service",
            EdgeType::PhysicalLink { .. } => "Physical Link",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let edge_style: &str = match &self {
            EdgeType::RequestPath { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::HubAndSpoke { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::Interface { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::HostVirtualization { .. } => EdgeStyle::Straight.into(),
            EdgeType::ServiceVirtualization { .. } => EdgeStyle::SmoothStep.into(),
            EdgeType::PhysicalLink { .. } => EdgeStyle::SmoothStep.into(),
        };

        let is_dashed = match &self {
            EdgeType::RequestPath { .. } => false,
            EdgeType::HubAndSpoke { .. } => false,
            EdgeType::Interface { .. } => true,
            EdgeType::HostVirtualization { .. } => true,
            EdgeType::ServiceVirtualization { .. } => true,
            EdgeType::PhysicalLink { .. } => false, // Solid line for physical links
        };

        let has_start_marker = false;

        let has_end_marker = match &self {
            EdgeType::RequestPath { .. } => true,
            EdgeType::HubAndSpoke { .. } => true,
            EdgeType::Interface { .. } => false,
            EdgeType::HostVirtualization { .. } => false,
            EdgeType::ServiceVirtualization { .. } => false,
            EdgeType::PhysicalLink { .. } => false, // No markers - bidirectional link
        };

        let is_host_edge = matches!(
            self,
            EdgeType::Interface { .. } | EdgeType::ServiceVirtualization { .. }
        );
        let is_dependency_edge = matches!(
            self,
            EdgeType::RequestPath { .. } | EdgeType::HubAndSpoke { .. }
        );
        let is_physical_edge = matches!(self, EdgeType::PhysicalLink { .. });

        serde_json::json!({
            "is_dashed": is_dashed,
            "has_start_marker": has_start_marker,
            "has_end_marker": has_end_marker,
            "edge_style": edge_style,
            "is_host_edge": is_host_edge,
            "is_dependency_edge": is_dependency_edge,
            "is_physical_edge": is_physical_edge
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::dependencies::r#impl::types::DependencyTypeDiscriminants;
    use strum::IntoEnumIterator;

    #[test]
    fn edge_type_matches_dependency_type() {
        // This will fail to compile if DependencyType adds/removes variants
        // without updating EdgeType
        let dependency_types: Vec<DependencyTypeDiscriminants> =
            DependencyTypeDiscriminants::iter().collect();

        assert_eq!(
            dependency_types.len(),
            2,
            "Update EdgeType to match DependencyType variants!"
        );
        assert!(dependency_types.contains(&DependencyTypeDiscriminants::RequestPath));
        assert!(dependency_types.contains(&DependencyTypeDiscriminants::HubAndSpoke));
    }

    #[test]
    fn classify_edge_l3() {
        use EdgeClassification::*;
        use EdgeTypeDiscriminants::*;
        let p = TopologyPerspective::L3Logical;
        assert_eq!(p.classify_edge(Interface), Primary);
        assert_eq!(p.classify_edge(ServiceVirtualization), Primary);
        assert_eq!(p.classify_edge(HostVirtualization), OverlayHidden);
        assert_eq!(p.classify_edge(PhysicalLink), OverlayHidden);
        assert_eq!(p.classify_edge(RequestPath), Overlay);
        assert_eq!(p.classify_edge(HubAndSpoke), Overlay);
    }

    #[test]
    fn classify_edge_l2() {
        use EdgeClassification::*;
        use EdgeTypeDiscriminants::*;
        let p = TopologyPerspective::L2Physical;
        assert_eq!(p.classify_edge(PhysicalLink), Primary);
        assert_eq!(p.classify_edge(Interface), Overlay);
        assert_eq!(p.classify_edge(HostVirtualization), OverlayHidden);
        assert_eq!(p.classify_edge(ServiceVirtualization), OverlayHidden);
        assert_eq!(p.classify_edge(RequestPath), OverlayHidden);
        assert_eq!(p.classify_edge(HubAndSpoke), OverlayHidden);
    }

    #[test]
    fn classify_edge_infrastructure() {
        use EdgeClassification::*;
        use EdgeTypeDiscriminants::*;
        let p = TopologyPerspective::Infrastructure;
        assert_eq!(p.classify_edge(HostVirtualization), Primary);
        assert_eq!(p.classify_edge(ServiceVirtualization), Primary);
        assert_eq!(p.classify_edge(Interface), Overlay);
        assert_eq!(p.classify_edge(RequestPath), OverlayHidden);
        assert_eq!(p.classify_edge(HubAndSpoke), OverlayHidden);
        assert_eq!(p.classify_edge(PhysicalLink), OverlayHidden);
    }

    #[test]
    fn classify_edge_application() {
        use EdgeClassification::*;
        use EdgeTypeDiscriminants::*;
        let p = TopologyPerspective::Application;
        assert_eq!(p.classify_edge(RequestPath), Primary);
        assert_eq!(p.classify_edge(HubAndSpoke), Primary);
        assert_eq!(p.classify_edge(Interface), OverlayHidden);
        assert_eq!(p.classify_edge(HostVirtualization), OverlayHidden);
        assert_eq!(p.classify_edge(ServiceVirtualization), OverlayHidden);
        assert_eq!(p.classify_edge(PhysicalLink), OverlayHidden);
    }

    #[test]
    fn edge_classification_serde_round_trips() {
        // All variants round-trip correctly
        for (classification, expected_str) in [
            (EdgeClassification::Primary, "primary"),
            (EdgeClassification::Overlay, "overlay"),
            (EdgeClassification::OverlayHidden, "overlay_hidden"),
            (EdgeClassification::Disabled, "disabled"),
        ] {
            let json = serde_json::to_value(classification).unwrap();
            assert_eq!(json, expected_str);
            let deserialized: EdgeClassification = serde_json::from_value(json).unwrap();
            assert_eq!(deserialized, classification);
        }
    }

    #[test]
    fn classification_default_is_primary() {
        assert_eq!(EdgeClassification::default(), EdgeClassification::Primary);
    }

    #[test]
    fn topology_perspective_serde_round_trip() {
        let json = serde_json::to_value(TopologyPerspective::L2Physical).unwrap();
        assert_eq!(json, "L2Physical");
        let deserialized: TopologyPerspective = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, TopologyPerspective::L2Physical);
    }
}
