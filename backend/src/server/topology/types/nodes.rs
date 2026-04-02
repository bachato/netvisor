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
}

#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema)]
pub enum ContainerType {
    #[default]
    Subnet,
}

#[derive(Debug, Clone, Copy, Default, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema)]
pub enum LeafEntityType {
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
    #[serde(alias = "SubnetNode")]
    ContainerNode {
        #[serde(default)]
        container_type: ContainerType,
        infra_width: usize,
    },
    #[serde(alias = "InterfaceNode")]
    LeafNode {
        #[serde(default)]
        container_id: Uuid,
        #[serde(default)]
        leaf_type: LeafEntityType,
        #[serde(alias = "subnet_id")]
        subnet_id: Uuid,
        host_id: Uuid,
        interface_id: Option<Uuid>,
        is_infra: bool,
    },
}

#[derive(Debug, Clone)]
pub struct SubnetChild {
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
    fn test_container_node_round_trip() {
        let node_type = NodeType::ContainerNode {
            container_type: ContainerType::Subnet,
            infra_width: 3,
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["node_type"], "ContainerNode");
        assert_eq!(json["container_type"], "Subnet");
        assert_eq!(json["infra_width"], 3);

        let deserialized: NodeType = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, node_type);
    }

    #[test]
    fn test_leaf_node_round_trip() {
        let id = Uuid::new_v4();
        let host_id = Uuid::new_v4();
        let iface_id = Uuid::new_v4();
        let node_type = NodeType::LeafNode {
            container_id: id,
            leaf_type: LeafEntityType::Interface,
            subnet_id: id,
            host_id,
            interface_id: Some(iface_id),
            is_infra: true,
        };
        let json = serde_json::to_value(&node_type).unwrap();
        assert_eq!(json["node_type"], "LeafNode");
        assert_eq!(json["leaf_type"], "Interface");

        let deserialized: NodeType = serde_json::from_value(json).unwrap();
        assert_eq!(deserialized, node_type);
    }

    #[test]
    fn test_backward_compat_subnet_node() {
        let json = json!({
            "node_type": "SubnetNode",
            "infra_width": 2
        });
        let node_type: NodeType = serde_json::from_value(json).unwrap();
        match node_type {
            NodeType::ContainerNode {
                container_type,
                infra_width,
            } => {
                assert_eq!(container_type, ContainerType::Subnet);
                assert_eq!(infra_width, 2);
            }
            _ => panic!("Expected ContainerNode"),
        }
    }

    #[test]
    fn test_backward_compat_interface_node() {
        let subnet_id = Uuid::new_v4();
        let host_id = Uuid::new_v4();
        let json = json!({
            "node_type": "InterfaceNode",
            "subnet_id": subnet_id,
            "host_id": host_id,
            "interface_id": null,
            "is_infra": false
        });
        let node_type: NodeType = serde_json::from_value(json).unwrap();
        match node_type {
            NodeType::LeafNode {
                container_id,
                leaf_type,
                subnet_id: sid,
                host_id: hid,
                interface_id,
                is_infra,
            } => {
                assert_eq!(container_id, Uuid::default()); // default since not in old JSON
                assert_eq!(leaf_type, LeafEntityType::Interface);
                assert_eq!(sid, subnet_id);
                assert_eq!(hid, host_id);
                assert_eq!(interface_id, None);
                assert!(!is_infra);
            }
            _ => panic!("Expected LeafNode"),
        }
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
