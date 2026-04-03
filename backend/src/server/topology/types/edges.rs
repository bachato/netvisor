use crate::server::{
    groups::r#impl::types::GroupTypeDiscriminants,
    shared::{
        concepts::Concept,
        entities::EntityDiscriminants,
        types::{
            Color, Icon,
            metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider},
        },
    },
    subnets::r#impl::base::Subnet,
    topology::types::layout::Ixy,
};
use serde::{Deserialize, Serialize};
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
    Overlay,
}

/// Which topology perspective is being rendered
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum TopologyPerspective {
    L2Physical,
    #[default]
    L3Logical,
    Infrastructure,
    Application,
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

    /// Determine edge handle orientations based on subnet layer and priority
    pub fn from_subnet_layers(
        source_subnet: &Subnet,
        target_subnet: &Subnet,
        is_multi_hop: bool,
    ) -> (EdgeHandle, EdgeHandle) {
        // Special case: edges within the same subnet
        if source_subnet.id == target_subnet.id {
            return Self::from_same_subnet();
        }

        let source_vertical_order = source_subnet.base.subnet_type.vertical_order();
        let source_horizontal_order = source_subnet.base.subnet_type.horizontal_order();
        let target_vertical_order = target_subnet.base.subnet_type.vertical_order();
        let target_horizontal_order = target_subnet.base.subnet_type.horizontal_order();

        match source_vertical_order.cmp(&target_vertical_order) {
            // Different layers - vertical flow
            std::cmp::Ordering::Less => {
                if is_multi_hop {
                    (EdgeHandle::Left, EdgeHandle::Left)
                } else {
                    (EdgeHandle::Bottom, EdgeHandle::Top)
                }
            }
            std::cmp::Ordering::Greater => {
                if is_multi_hop {
                    (EdgeHandle::Left, EdgeHandle::Left)
                } else {
                    (EdgeHandle::Top, EdgeHandle::Bottom)
                }
            }
            // Same layer - horizontal flow based on priority
            std::cmp::Ordering::Equal => {
                match source_horizontal_order.cmp(&target_horizontal_order) {
                    std::cmp::Ordering::Less => (EdgeHandle::Right, EdgeHandle::Left),
                    std::cmp::Ordering::Greater => (EdgeHandle::Left, EdgeHandle::Right),
                    std::cmp::Ordering::Equal => (EdgeHandle::Right, EdgeHandle::Left),
                }
            }
        }
    }

    /// Handle edges within the same subnet - defer to anchor analysis
    fn from_same_subnet() -> (EdgeHandle, EdgeHandle) {
        // For intra-subnet edges, use Top as a neutral default
        // The anchor analyzer will determine the actual optimal placement
        // based on the node's actual position and all its edges
        (EdgeHandle::Top, EdgeHandle::Top)
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

impl EdgeType {
    /// Returns whether this edge is primary (affects layout) or overlay for a given perspective
    pub fn classification(&self, perspective: TopologyPerspective) -> EdgeClassification {
        match perspective {
            TopologyPerspective::L3Logical => match self {
                EdgeType::Interface { .. } => EdgeClassification::Primary,
                _ => EdgeClassification::Overlay,
            },
            TopologyPerspective::L2Physical => match self {
                EdgeType::PhysicalLink { .. } => EdgeClassification::Primary,
                _ => EdgeClassification::Overlay,
            },
            TopologyPerspective::Infrastructure => match self {
                EdgeType::HostVirtualization { .. } | EdgeType::ServiceVirtualization { .. } => {
                    EdgeClassification::Primary
                }
                _ => EdgeClassification::Overlay,
            },
            TopologyPerspective::Application => match self {
                EdgeType::RequestPath { .. } | EdgeType::HubAndSpoke { .. } => {
                    EdgeClassification::Primary
                }
                _ => EdgeClassification::Overlay,
            },
        }
    }
}

impl EntityMetadataProvider for EdgeType {
    fn color(&self) -> Color {
        match self {
            EdgeType::RequestPath { .. } => EntityDiscriminants::Group.color(),
            EdgeType::HubAndSpoke { .. } => EntityDiscriminants::Group.color(),
            EdgeType::Interface { .. } => EntityDiscriminants::Host.color(),
            EdgeType::HostVirtualization { .. } => Concept::Virtualization.color(),
            EdgeType::ServiceVirtualization { .. } => Concept::Virtualization.color(),
            EdgeType::PhysicalLink { .. } => EntityDiscriminants::IfEntry.color(),
        }
    }

    fn icon(&self) -> Icon {
        match self {
            EdgeType::RequestPath { .. } => GroupTypeDiscriminants::RequestPath.icon(),
            EdgeType::HubAndSpoke { .. } => GroupTypeDiscriminants::HubAndSpoke.icon(),
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
            EdgeType::HubAndSpoke { .. } => GroupTypeDiscriminants::HubAndSpoke.name(),
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
        let is_group_edge = matches!(
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
            "is_group_edge": is_group_edge,
            "is_physical_edge": is_physical_edge
        })
    }
}

#[cfg(test)]
mod tests {
    use strum::IntoEnumIterator;
    use uuid::Uuid;

    use super::*;
    use crate::server::groups::r#impl::types::GroupTypeDiscriminants;

    #[test]
    fn edge_type_matches_group_type() {
        // This will fail to compile if GroupType adds/removes variants
        // without updating EdgeType
        let group_types: Vec<GroupTypeDiscriminants> = GroupTypeDiscriminants::iter().collect();

        assert_eq!(
            group_types.len(),
            2,
            "Update EdgeType to match GroupType variants!"
        );
        assert!(group_types.contains(&GroupTypeDiscriminants::RequestPath));
        assert!(group_types.contains(&GroupTypeDiscriminants::HubAndSpoke));
    }

    fn dummy_id() -> Uuid {
        Uuid::nil()
    }

    fn all_edge_types() -> Vec<EdgeType> {
        vec![
            EdgeType::Interface {
                host_id: dummy_id(),
            },
            EdgeType::PhysicalLink {
                source_if_entry_id: dummy_id(),
                target_if_entry_id: dummy_id(),
                protocol: DiscoveryProtocol::LLDP,
            },
            EdgeType::HostVirtualization {
                vm_service_id: dummy_id(),
            },
            EdgeType::ServiceVirtualization {
                host_id: dummy_id(),
                containerizing_service_id: dummy_id(),
            },
            EdgeType::RequestPath {
                group_id: dummy_id(),
                source_binding_id: dummy_id(),
                target_binding_id: dummy_id(),
            },
            EdgeType::HubAndSpoke {
                group_id: dummy_id(),
                source_binding_id: dummy_id(),
                target_binding_id: dummy_id(),
            },
        ]
    }

    #[test]
    fn classification_l3_interface_is_primary() {
        let edge = EdgeType::Interface {
            host_id: dummy_id(),
        };
        assert_eq!(
            edge.classification(TopologyPerspective::L3Logical),
            EdgeClassification::Primary
        );
    }

    #[test]
    fn classification_l3_others_are_overlay() {
        for edge in all_edge_types() {
            if matches!(edge, EdgeType::Interface { .. }) {
                continue;
            }
            assert_eq!(
                edge.classification(TopologyPerspective::L3Logical),
                EdgeClassification::Overlay,
                "Expected Overlay for {:?} in L3",
                edge
            );
        }
    }

    #[test]
    fn classification_l2_physical_link_is_primary() {
        let edge = EdgeType::PhysicalLink {
            source_if_entry_id: dummy_id(),
            target_if_entry_id: dummy_id(),
            protocol: DiscoveryProtocol::LLDP,
        };
        assert_eq!(
            edge.classification(TopologyPerspective::L2Physical),
            EdgeClassification::Primary
        );
    }

    #[test]
    fn classification_infrastructure_virtualization_is_primary() {
        let host_virt = EdgeType::HostVirtualization {
            vm_service_id: dummy_id(),
        };
        let svc_virt = EdgeType::ServiceVirtualization {
            host_id: dummy_id(),
            containerizing_service_id: dummy_id(),
        };
        assert_eq!(
            host_virt.classification(TopologyPerspective::Infrastructure),
            EdgeClassification::Primary
        );
        assert_eq!(
            svc_virt.classification(TopologyPerspective::Infrastructure),
            EdgeClassification::Primary
        );
    }

    #[test]
    fn classification_application_group_edges_are_primary() {
        let req = EdgeType::RequestPath {
            group_id: dummy_id(),
            source_binding_id: dummy_id(),
            target_binding_id: dummy_id(),
        };
        let hub = EdgeType::HubAndSpoke {
            group_id: dummy_id(),
            source_binding_id: dummy_id(),
            target_binding_id: dummy_id(),
        };
        assert_eq!(
            req.classification(TopologyPerspective::Application),
            EdgeClassification::Primary
        );
        assert_eq!(
            hub.classification(TopologyPerspective::Application),
            EdgeClassification::Primary
        );
    }

    #[test]
    fn classification_default_is_primary() {
        assert_eq!(EdgeClassification::default(), EdgeClassification::Primary);
    }

    #[test]
    fn edge_classification_serde_round_trip() {
        let json = serde_json::to_value(EdgeClassification::Overlay).unwrap();
        assert_eq!(json, "overlay");
        let deserialized: EdgeClassification = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, EdgeClassification::Overlay);
    }

    #[test]
    fn topology_perspective_serde_round_trip() {
        let json = serde_json::to_value(TopologyPerspective::L2Physical).unwrap();
        assert_eq!(json, "l2_physical");
        let deserialized: TopologyPerspective = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, TopologyPerspective::L2Physical);
    }
}
