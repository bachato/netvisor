use crate::server::shared::entities::EntityDiscriminants;
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
    /// ID of the element rule that created this container (for NestedTag/NestedServiceCategory)
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub element_rule_id: Option<Uuid>,
}

impl Node {
    pub fn element(
        id: Uuid,
        container_id: Uuid,
        host_id: Uuid,
        element: ElementEntityType,
    ) -> Self {
        Self {
            id,
            node_type: NodeType::Element {
                container_id,
                host_id,
                element,
            },
            position: Ixy::default(),
            size: Uxy::default(),
            header: None,
            element_rule_id: None,
        }
    }
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
    // Top-level containers
    #[default]
    Subnet,
    ServiceCategory,

    // Subcontainers (nested inside a top-level container)
    NestedTag,
    NestedServiceCategory,
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
            ContainerType::ServiceCategory => EntityDiscriminants::Service.color(),
            ContainerType::NestedTag => Color::Orange,
            ContainerType::NestedServiceCategory => Color::Purple,
        }
    }

    fn icon(&self) -> Icon {
        match self {
            ContainerType::Subnet => Icon::Network,
            ContainerType::ServiceCategory => EntityDiscriminants::Service.icon(),
            ContainerType::NestedTag => Icon::Tag,
            ContainerType::NestedServiceCategory => Icon::Layers,
        }
    }
}

impl TypeMetadataProvider for ContainerType {
    fn name(&self) -> &'static str {
        match self {
            ContainerType::Subnet => "Subnet",
            ContainerType::ServiceCategory => "Service category",
            ContainerType::NestedTag => "Tag container",
            ContainerType::NestedServiceCategory => "Service category container",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            ContainerType::Subnet => "Network subnet container",
            ContainerType::ServiceCategory => "Services grouped by category",
            ContainerType::NestedTag => "Elements grouped by tag",
            ContainerType::NestedServiceCategory => "Elements grouped by service category",
        }
    }

    fn metadata(&self) -> serde_json::Value {
        let title_style = match self {
            ContainerType::Subnet | ContainerType::ServiceCategory => TitleStyle::External,
            ContainerType::NestedTag | ContainerType::NestedServiceCategory => TitleStyle::Inline,
        };
        let is_subcontainer = matches!(
            self,
            ContainerType::NestedTag | ContainerType::NestedServiceCategory
        );
        let (padding_top, padding_side) = match self {
            ContainerType::Subnet | ContainerType::ServiceCategory => (25, 25),
            ContainerType::NestedTag | ContainerType::NestedServiceCategory => (45, 20),
        };
        let (collapsed_width, collapsed_height) = match self {
            ContainerType::Subnet | ContainerType::ServiceCategory => (200, 80),
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

#[derive(Debug, Clone, Copy, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema)]
#[serde(tag = "element_type")]
pub enum ElementEntityType {
    Interface {
        subnet_id: Uuid,
        #[serde(default, skip_serializing_if = "Option::is_none")]
        interface_id: Option<Uuid>,
    },
    Service {},
}

impl Default for ElementEntityType {
    fn default() -> Self {
        Self::Interface {
            subnet_id: Uuid::nil(),
            interface_id: None,
        }
    }
}

impl From<&ElementEntityType> for EntityDiscriminants {
    fn from(eet: &ElementEntityType) -> Self {
        match eet {
            ElementEntityType::Interface { .. } => EntityDiscriminants::Interface,
            ElementEntityType::Service {} => EntityDiscriminants::Service,
        }
    }
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
        host_id: Uuid,
        #[serde(flatten)]
        element: ElementEntityType,
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
            container_type: ContainerType::NestedServiceCategory,
            parent_container_id: Some(parent_id),
            layer_hint: None,
            icon: None,
            color: None,
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["container_type"], "NestedServiceCategory");
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
            icon: None,
            color: None,
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert!(json.get("layer_hint").is_none());
    }

    #[test]
    fn test_element_interface_round_trip() {
        let container_id = Uuid::new_v4();
        let host_id = Uuid::new_v4();
        let subnet_id = Uuid::new_v4();
        let iface_id = Uuid::new_v4();
        let node_type = NodeType::Element {
            container_id,
            host_id,
            element: ElementEntityType::Interface {
                subnet_id,
                interface_id: Some(iface_id),
            },
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["node_type"], "Element");
        assert_eq!(json["element_type"], "Interface");
        assert_eq!(json["subnet_id"], subnet_id.to_string());
        assert_eq!(json["host_id"], host_id.to_string());
        assert_eq!(json["interface_id"], iface_id.to_string());

        let deserialized: NodeType = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, node_type);
    }

    #[test]
    fn test_element_service_round_trip() {
        let container_id = Uuid::new_v4();
        let host_id = Uuid::new_v4();
        let node_type = NodeType::Element {
            container_id,
            host_id,
            element: ElementEntityType::Service {},
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["node_type"], "Element");
        assert_eq!(json["element_type"], "Service");
        // Service elements don't have subnet_id or interface_id
        assert!(json.get("subnet_id").is_none());
        assert!(json.get("interface_id").is_none());

        let deserialized: NodeType = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, node_type);
    }

    #[test]
    fn test_element_interface_backward_compat() {
        // Verify that Interface elements serialize the same as before the restructure
        let container_id = Uuid::new_v4();
        let host_id = Uuid::new_v4();
        let subnet_id = Uuid::new_v4();
        let node_type = NodeType::Element {
            container_id,
            host_id,
            element: ElementEntityType::Interface {
                subnet_id,
                interface_id: None,
            },
        };
        let json = serde_json::to_value(&node_type).unwrap();
        // All fields should be at the top level (flattened)
        assert_eq!(json["container_id"], container_id.to_string());
        assert_eq!(json["host_id"], host_id.to_string());
        assert_eq!(json["subnet_id"], subnet_id.to_string());
        assert!(json.get("interface_id").is_none());
    }

    #[test]
    fn test_container_types() {
        let tag = NodeType::Container {
            container_type: ContainerType::NestedTag,
            parent_container_id: Some(Uuid::new_v4()),
            layer_hint: None,
            icon: None,
            color: None,
        };
        let json = serde_json::to_value(&tag).unwrap();
        assert_eq!(json["container_type"], "NestedTag");

        let svc = NodeType::Container {
            container_type: ContainerType::NestedServiceCategory,
            parent_container_id: Some(Uuid::new_v4()),
            layer_hint: None,
            icon: None,
            color: None,
        };
        let json = serde_json::to_value(&svc).unwrap();
        assert_eq!(json["container_type"], "NestedServiceCategory");
    }

    #[test]
    fn test_service_category_container() {
        let node_type = NodeType::Container {
            container_type: ContainerType::ServiceCategory,
            parent_container_id: None,
            layer_hint: None,
            icon: Some("Zap".to_string()),
            color: Some("Purple".to_string()),
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["container_type"], "ServiceCategory");
        assert!(json.get("parent_container_id").is_none());
    }

    #[test]
    fn test_node_element_constructor() {
        let id = Uuid::new_v4();
        let container_id = Uuid::new_v4();
        let host_id = Uuid::new_v4();
        let node = Node::element(id, container_id, host_id, ElementEntityType::Service {});
        assert_eq!(node.id, id);
        assert!(node.header.is_none());
        assert!(matches!(node.node_type, NodeType::Element { .. }));
    }

    #[test]
    fn test_entity_discriminant_mapping() {
        assert_eq!(
            EntityDiscriminants::from(&ElementEntityType::Interface {
                subnet_id: Uuid::nil(),
                interface_id: None,
            }),
            EntityDiscriminants::Interface
        );
        assert_eq!(
            EntityDiscriminants::from(&ElementEntityType::Service {}),
            EntityDiscriminants::Service
        );
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
