use crate::server::shared::types::metadata::{EntityMetadataProvider, HasId, TypeMetadataProvider};
use crate::server::shared::types::{Color, Icon};
use crate::server::subnets::r#impl::types::SubnetType;
// Note: Icon and Color are used by ContainerType's EntityMetadataProvider impl,
// but the Node struct stores icon/color as String to avoid derive constraint issues.
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
    /// ID of the element rule that created this container (for TagContainer/ServiceCategoryContainer)
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub element_rule_id: Option<Uuid>,
}

/// How the container's title is rendered in the topology viewer.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema)]
pub enum TitleStyle {
    /// Card/pill positioned above the container (subnets)
    External,
    /// Inside the container's top padding area (subcontainers)
    Inline,
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
    #[serde(alias = "TagGroup")]
    TagContainer,
    #[serde(alias = "ServiceCategoryGroup")]
    ServiceCategoryContainer,
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
            ContainerType::TagContainer => Color::Orange,
            ContainerType::ServiceCategoryContainer => Color::Purple,
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ContainerType::Subnet => Icon::Network,
            ContainerType::TagContainer => Icon::Tag,
            ContainerType::ServiceCategoryContainer => Icon::Layers,
        }
    }
}

impl TypeMetadataProvider for ContainerType {
    fn name(&self) -> &'static str {
        match self {
            ContainerType::Subnet => "Subnet",
            ContainerType::TagContainer => "Tag container",
            ContainerType::ServiceCategoryContainer => "Service category container",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ContainerType::Subnet => "Network subnet container",
            ContainerType::TagContainer => "Elements grouped by tag",
            ContainerType::ServiceCategoryContainer => "Elements grouped by service category",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let title_style = match self {
            ContainerType::Subnet => TitleStyle::External,
            ContainerType::TagContainer | ContainerType::ServiceCategoryContainer => {
                TitleStyle::Inline
            }
        };
        let is_subcontainer = !matches!(self, ContainerType::Subnet);
        let (padding_top, padding_side) = match self {
            ContainerType::Subnet => (25, 25),
            ContainerType::TagContainer | ContainerType::ServiceCategoryContainer => (35, 20),
        };
        let (collapsed_width, collapsed_height) = match self {
            ContainerType::Subnet => (200, 80),
            _ => (250, 40),
        };
        serde_json::json!({
            "title_style": title_style,
            "is_subcontainer": is_subcontainer,
            "is_collapsible": true,
            "has_border": true,
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
        /// Display icon name (set by graph builder from the source entity, e.g. subnet type)
        #[serde(default, skip_serializing_if = "Option::is_none")]
        icon: Option<String>,
        /// Display color name (set by graph builder from the source entity, e.g. subnet type)
        #[serde(default, skip_serializing_if = "Option::is_none")]
        color: Option<String>,
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
            icon: None,
            color: None,
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
            container_type: ContainerType::ServiceCategoryContainer,
            parent_container_id: Some(parent_id),
            layer_hint: None,
            icon: None,
            color: None,
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["container_type"], "ServiceCategoryContainer");
        assert_eq!(json["parent_container_id"], parent_id.to_string());

        let deserialized: NodeType = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, node_type);
    }

    #[test]
    fn test_backward_compat_old_container_type_names() {
        let json = serde_json::json!({ "container_type": "TagGroup" });
        let ct: ContainerType = serde_json::from_value(json["container_type"].clone()).unwrap();
        assert_eq!(ct, ContainerType::TagContainer);

        let json = serde_json::json!({ "container_type": "ServiceCategoryGroup" });
        let ct: ContainerType = serde_json::from_value(json["container_type"].clone()).unwrap();
        assert_eq!(ct, ContainerType::ServiceCategoryContainer);
    }

    #[test]
    fn test_container_no_layer_hint_omitted_in_json() {
        let node_type = NodeType::Container {
            container_type: ContainerType::Subnet,
            parent_container_id: None,
            layer_hint: None,
            icon: None,
            color: None,
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
        let tag = NodeType::Container {
            container_type: ContainerType::TagContainer,
            parent_container_id: Some(Uuid::new_v4()),
            layer_hint: None,
            icon: None,
            color: None,
        };
        let json = serde_json::to_value(&tag).unwrap();
        assert_eq!(json["container_type"], "TagContainer");

        let svc = NodeType::Container {
            container_type: ContainerType::ServiceCategoryContainer,
            parent_container_id: Some(Uuid::new_v4()),
            layer_hint: None,
            icon: None,
            color: None,
        };
        let json = serde_json::to_value(&svc).unwrap();
        assert_eq!(json["container_type"], "ServiceCategoryContainer");
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
