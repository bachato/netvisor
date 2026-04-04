use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider};
use crate::server::shared::types::{Color, Icon};
use crate::server::subnets::r#impl::types::SubnetType;
use crate::server::topology::types::edges::Edge;
use crate::server::topology::types::layout::{Ixy, Uxy};
use serde::{Deserialize, Serialize};
use strum_macros::{Display, EnumDiscriminants, EnumIter, IntoStaticStr};
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash, ToSchema)]
pub struct Node {
    #[serde(flatten)]
    pub node_type: NodeType,
    pub id: Uuid,
    pub position: Ixy,
    pub size: Uxy,
    pub header: Option<String>,
    /// ID of the element rule that created this group container (for TagGroup/ServiceCategoryGroup)
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub element_rule_id: Option<Uuid>,
}

#[derive(
    Debug,
    Clone,
    Copy,
    Default,
    Serialize,
    Deserialize,
    Eq,
    PartialEq,
    Hash,
    ToSchema,
    EnumIter,
    IntoStaticStr,
)]
pub enum ContainerType {
    #[default]
    Subnet,
    TagGroup,
    ServiceCategoryGroup,
    Ungrouped,
}

impl HasId for ContainerType {
    fn id(&self) -> &'static str {
        self.into()
    }
}

impl EntityMetadataProvider for ContainerType {
    fn color(&self) -> Color {
        match self {
            ContainerType::Subnet => Color::Blue,
            ContainerType::TagGroup => Color::Orange,
            ContainerType::ServiceCategoryGroup => Color::Purple,
            ContainerType::Ungrouped => Color::Gray,
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ContainerType::Subnet => Icon::Network,
            ContainerType::TagGroup => Icon::Tag,
            ContainerType::ServiceCategoryGroup => Icon::Layers,
            ContainerType::Ungrouped => Icon::Box,
        }
    }
}

impl TypeMetadataProvider for ContainerType {
    fn name(&self) -> &'static str {
        match self {
            ContainerType::Subnet => "Subnet",
            ContainerType::TagGroup => "Tag group",
            ContainerType::ServiceCategoryGroup => "Service category group",
            ContainerType::Ungrouped => "Ungrouped",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ContainerType::Subnet => "Network subnet container",
            ContainerType::TagGroup => "Nodes grouped by tag",
            ContainerType::ServiceCategoryGroup => "Nodes grouped by service category",
            ContainerType::Ungrouped => "Nodes not in any group",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let (padding_top, padding_side) = match self {
            ContainerType::Subnet => (25, 25),
            // All subgroup types use the same padding for grid alignment
            ContainerType::TagGroup | ContainerType::ServiceCategoryGroup | ContainerType::Ungrouped => (30, 20),
        };
        let (collapsed_width, collapsed_height) = match self {
            ContainerType::Subnet => (200, 80),
            _ => (250, 40),
        };
        serde_json::json!({
            "is_collapsible": matches!(self, ContainerType::Subnet | ContainerType::TagGroup | ContainerType::ServiceCategoryGroup),
            "has_border": !matches!(self, ContainerType::Ungrouped),
            "has_header": matches!(self, ContainerType::TagGroup | ContainerType::ServiceCategoryGroup),
            "has_subnet": matches!(self, ContainerType::Subnet),
            "padding": { "top": padding_top, "left": padding_side, "bottom": padding_side, "right": padding_side },
            "collapsed_size": { "width": collapsed_width, "height": collapsed_height },
        })
    }
}

#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema)]
pub enum ElementEntityType {
    #[default]
    Interface,
}

#[derive(
    Debug,
    Clone,
    Serialize,
    Deserialize,
    Eq,
    PartialEq,
    Hash,
    EnumDiscriminants,
    IntoStaticStr,
    ToSchema,
)]
#[serde(tag = "node_type")]
#[strum_discriminants(derive(Display, Hash, Serialize, Deserialize, EnumIter))]
pub enum NodeType {
    Container {
        #[serde(default)]
        container_type: ContainerType,
        #[serde(default, skip_serializing_if = "Option::is_none")]
        parent_container_id: Option<Uuid>,
        /// Sugiyama layer assignment for compound layout (from SubnetType::vertical_order)
        #[serde(default, skip_serializing_if = "Option::is_none")]
        layer_hint: Option<i32>,
    },
    Element {
        #[serde(default)]
        container_id: Uuid,
        #[serde(default)]
        element_type: ElementEntityType,
        subnet_id: Uuid,
        host_id: Uuid,
        interface_id: Option<Uuid>,
    },
}

#[derive(Debug, Clone)]
pub struct ContainerChild {
    pub id: Uuid,
    pub header: Option<String>,
    pub host_id: Uuid,
    pub interface_id: Option<Uuid>,
    pub size: Uxy,
    pub edges: Vec<Edge>,
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_container_round_trip() {
        let node_type = NodeType::Container {
            container_type: ContainerType::Subnet,
            parent_container_id: None,
            layer_hint: Some(2),
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["node_type"], "Container");
        assert_eq!(json["container_type"], "Subnet");
        assert_eq!(json["layer_hint"], 2);
        assert!(json.get("parent_container_id").is_none());

        let deserialized: NodeType = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, node_type);
    }

    #[test]
    fn test_container_with_parent() {
        let parent_id = Uuid::new_v4();
        let node_type = NodeType::Container {
            container_type: ContainerType::ServiceCategoryGroup,
            parent_container_id: Some(parent_id),
            layer_hint: None,
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["container_type"], "ServiceCategoryGroup");
        assert_eq!(json["parent_container_id"], parent_id.to_string());

        let deserialized: NodeType = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, node_type);
    }

    #[test]
    fn test_container_no_layer_hint_omitted_in_json() {
        let node_type = NodeType::Container {
            container_type: ContainerType::Subnet,
            parent_container_id: None,
            layer_hint: None,
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert!(json.get("layer_hint").is_none());
    }

    #[test]
    fn test_element_round_trip() {
        let id = Uuid::new_v4();
        let host_id = Uuid::new_v4();
        let iface_id = Uuid::new_v4();
        let node_type = NodeType::Element {
            container_id: id,
            element_type: ElementEntityType::Interface,
            subnet_id: id,
            host_id,
            interface_id: Some(iface_id),
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["node_type"], "Element");
        assert_eq!(json["element_type"], "Interface");

        let deserialized: NodeType = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, node_type);
    }

    #[test]
    fn test_container_types() {
        let tag_group = NodeType::Container {
            container_type: ContainerType::TagGroup,
            parent_container_id: Some(Uuid::new_v4()),
            layer_hint: None,
        };
        let json = serde_json::to_value(&tag_group).unwrap();
        assert_eq!(json["container_type"], "TagGroup");

        let svc_group = NodeType::Container {
            container_type: ContainerType::ServiceCategoryGroup,
            parent_container_id: Some(Uuid::new_v4()),
            layer_hint: None,
        };
        let json = serde_json::to_value(&svc_group).unwrap();
        assert_eq!(json["container_type"], "ServiceCategoryGroup");
    }
}

impl SubnetType {
    pub fn vertical_order(&self) -> usize {
        match self {
            // Layer 0: External
            SubnetType::Internet => 0,
            SubnetType::Remote => 0,

            // Layer 1: Gateway/DMZ
            SubnetType::Gateway => 1,
            SubnetType::Dmz => 1, // Same layer as Gateway
            SubnetType::VpnTunnel => 1,

            // Layer 2: Internal
            SubnetType::Lan => 2,
            SubnetType::WiFi => 2,
            SubnetType::Guest => 2,
            SubnetType::IoT => 2,

            // Layer 3: Infrastructure
            SubnetType::DockerBridge => 3,
            SubnetType::MacVlan => 3,
            SubnetType::IpVlan => 3,
            SubnetType::Management => 3,
            SubnetType::Storage => 3,

            // Special
            SubnetType::Loopback => 999,
            SubnetType::Unknown => 999,
        }
    }

    pub fn horizontal_order(&self) -> usize {
        match self {
            // Layer 0
            SubnetType::Internet => 0,
            SubnetType::Remote => 1,

            // Layer 1 - Gateway is central, DMZ to the side
            SubnetType::Gateway => 0,   // Center/left
            SubnetType::Dmz => 1,       // Right of gateway
            SubnetType::VpnTunnel => 2, // Further right

            // Layer 2
            SubnetType::Lan => 0,
            SubnetType::WiFi => 1,
            SubnetType::IoT => 2,
            SubnetType::Guest => 3,

            // Layer 3
            SubnetType::Storage => 0,
            SubnetType::Management => 1,
            SubnetType::DockerBridge => 2,
            SubnetType::MacVlan => 3,
            SubnetType::IpVlan => 4,

            // Special
            SubnetType::Loopback => 999,
            SubnetType::Unknown => 999,
        }
    }
}
