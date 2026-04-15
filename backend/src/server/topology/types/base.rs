use crate::server::bindings::r#impl::base::Binding;
use crate::server::dependencies::r#impl::base::Dependency;
use crate::server::hosts::r#impl::base::Host;
use crate::server::interfaces::r#impl::base::Interface;
use crate::server::ip_addresses::r#impl::base::IPAddress;
use crate::server::ports::r#impl::base::Port;
use crate::server::services::r#impl::base::Service;
use crate::server::services::r#impl::categories::ServiceCategory;
use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use crate::server::subnets::r#impl::base::Subnet;
use crate::server::tags::r#impl::base::Tag;
use crate::server::topology::types::edges::{Edge, EdgeHandle, EdgeTypeDiscriminants};
use crate::server::topology::types::grouping::{
    ContainerRule, ElementRule, GraphRule, IdentifiedRule,
};
use crate::server::topology::types::layout::{Ixy, Uxy};
use crate::server::topology::types::nodes::Node;
use crate::server::topology::types::views::TopologyView;
use crate::server::vlans::r#impl::base::Vlan;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, fmt::Display};
use strum::IntoEnumIterator;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

pub struct SetEntitiesParams {
    pub hosts: Vec<Host>,
    pub services: Vec<Service>,
    pub subnets: Vec<Subnet>,
    pub dependencies: Vec<Dependency>,
    pub ports: Vec<Port>,
    pub bindings: Vec<Binding>,
    pub ip_addresses: Vec<IPAddress>,
    pub interfaces: Vec<Interface>,
    pub entity_tags: Vec<Tag>,
    pub vlans: Vec<Vlan>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Default, ToSchema, Validate)]
pub struct Topology {
    #[serde(default)]
    #[schema(read_only, required)]
    pub id: Uuid,
    #[serde(default)]
    #[schema(read_only, required)]
    pub created_at: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only, required)]
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    #[validate(nested)]
    pub base: TopologyBase,
}

impl Topology {
    pub fn lock(&mut self, locked_by: Uuid) {
        self.base.is_locked = true;
        self.base.locked_at = Some(Utc::now());
        self.base.locked_by = Some(locked_by)
    }

    pub fn unlock(&mut self) {
        self.base.is_locked = false;
        self.base.locked_at = None;
        self.base.locked_by = None;
    }

    pub fn clear_stale(&mut self) {
        self.base.removed_dependencies = vec![];
        self.base.removed_hosts = vec![];
        self.base.removed_ip_addresses = vec![];
        self.base.removed_services = vec![];
        self.base.removed_subnets = vec![];
        self.base.removed_bindings = vec![];
        self.base.removed_ports = vec![];
        self.base.removed_interfaces = vec![];
        self.base.is_stale = false;
        self.base.last_refreshed = Utc::now()
    }

    pub fn set_entities(&mut self, params: SetEntitiesParams) {
        self.base.hosts = params.hosts;
        self.base.services = params.services;
        self.base.subnets = params.subnets;
        self.base.dependencies = params.dependencies;
        self.base.ports = params.ports;
        self.base.bindings = params.bindings;
        self.base.ip_addresses = params.ip_addresses;
        self.base.interfaces = params.interfaces;
        self.base.entity_tags = params.entity_tags;
        self.base.vlans = params.vlans;
    }

    pub fn set_graph(&mut self, nodes: Vec<Node>, edges: Vec<Edge>) {
        self.base.nodes = nodes;
        self.base.edges = edges;
    }

    /// Whether this topology has enough data to render the L2 Physical view
    /// (requires physical link edges discovered via LLDP/CDP).
    pub fn supports_l2_view(&self) -> bool {
        self.base
            .edges
            .iter()
            .any(|e| matches!(e.edge_type, super::edges::EdgeType::PhysicalLink { .. }))
    }

    /// Whether this topology has enough data to render the Application view
    /// (requires at least one application group tag).
    pub fn supports_application_view(&self) -> bool {
        self.base.entity_tags.iter().any(|t| t.base.is_application)
    }

    /// Resolve the available views for a share, filtering by data availability.
    /// If `configured` is None, all data-supported views are returned.
    /// If `configured` is Some(list), returns the intersection preserving list order.
    pub fn resolve_available_views(
        &self,
        configured: &Option<Vec<TopologyView>>,
    ) -> Vec<TopologyView> {
        let data_supported: Vec<TopologyView> = TopologyView::iter()
            .filter(|v| match v {
                TopologyView::L2Physical => self.supports_l2_view(),
                TopologyView::Application => self.supports_application_view(),
                _ => true,
            })
            .collect();

        match configured {
            None => data_supported,
            Some(list) => list
                .iter()
                .filter(|v| data_supported.contains(v))
                .cloned()
                .collect(),
        }
    }
}

#[derive(Debug, Clone, Validate, Serialize, Deserialize, Eq, PartialEq, Default, ToSchema)]
pub struct TopologyBase {
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    pub options: TopologyOptions,
    pub network_id: Uuid,
    #[serde(default)]
    #[schema(required)]
    pub tags: Vec<Uuid>,
    pub parent_id: Option<Uuid>,

    // Graph
    pub nodes: Vec<Node>,
    pub edges: Vec<Edge>,

    // Entities
    pub hosts: Vec<Host>,
    pub ip_addresses: Vec<IPAddress>,
    pub ports: Vec<Port>,
    pub bindings: Vec<Binding>,
    pub subnets: Vec<Subnet>,
    pub services: Vec<Service>,
    pub dependencies: Vec<Dependency>,
    pub interfaces: Vec<Interface>,

    // Tag definitions for filtering
    pub entity_tags: Vec<Tag>,

    // VLAN definitions for name resolution
    #[serde(default)]
    pub vlans: Vec<Vlan>,

    // Build state
    pub is_stale: bool,
    pub last_refreshed: DateTime<Utc>,
    pub is_locked: bool,
    pub locked_at: Option<DateTime<Utc>>,
    pub locked_by: Option<Uuid>,

    pub removed_hosts: Vec<Uuid>,
    pub removed_ip_addresses: Vec<Uuid>,
    pub removed_subnets: Vec<Uuid>,
    pub removed_services: Vec<Uuid>,
    pub removed_dependencies: Vec<Uuid>,
    pub removed_ports: Vec<Uuid>,
    pub removed_bindings: Vec<Uuid>,
    pub removed_interfaces: Vec<Uuid>,
}

impl TopologyBase {
    pub fn new(name: String, network_id: Uuid) -> Self {
        Self {
            name,
            network_id,
            options: TopologyOptions::default(),
            nodes: vec![],
            edges: vec![],
            hosts: vec![],
            ports: vec![],
            ip_addresses: vec![],
            subnets: vec![],
            bindings: vec![],
            services: vec![],
            dependencies: vec![],
            interfaces: vec![],
            is_stale: true,
            last_refreshed: Utc::now(),
            is_locked: false,
            locked_at: None,
            locked_by: None,
            removed_hosts: vec![],
            removed_ip_addresses: vec![],
            removed_subnets: vec![],
            removed_services: vec![],
            removed_dependencies: vec![],
            removed_bindings: vec![],
            removed_ports: vec![],
            removed_interfaces: vec![],
            parent_id: None,
            tags: vec![],
            entity_tags: vec![],
            vlans: vec![],
        }
    }
}

impl ChangeTriggersTopologyStaleness<Topology> for Topology {
    fn triggers_staleness(&self, other: Option<Topology>) -> bool {
        if let Some(other_topology) = other {
            self.base.options.request != other_topology.base.options.request
        } else {
            false
        }
    }
}

impl Display for Topology {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "Topology {{ id: {}, name: {} }}",
            self.id, self.base.name
        )
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, Default, PartialEq, Eq, ToSchema)]
pub struct TopologyOptions {
    pub local: TopologyLocalOptions,
    pub request: TopologyRequestOptions,
}

/// Filter settings for hiding entities by tag in topology visualization.
#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash, Default, ToSchema)]
pub struct TopologyTagFilter {
    /// Host tag IDs to hide (hosts with these tags will fade out)
    #[serde(default)]
    pub hidden_host_tag_ids: Vec<Uuid>,
    /// Service tag IDs to hide (services with these tags will be hidden from nodes)
    #[serde(default)]
    pub hidden_service_tag_ids: Vec<Uuid>,
    /// Subnet tag IDs to hide (subnets with these tags will fade out)
    #[serde(default)]
    pub hidden_subnet_tag_ids: Vec<Uuid>,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash, ToSchema)]
pub struct TopologyLocalOptions {
    pub no_fade_edges: bool,
    pub hide_edge_types: Vec<EdgeTypeDiscriminants>,
    #[serde(default)]
    pub tag_filter: TopologyTagFilter,
    #[serde(default = "default_true")]
    pub show_minimap: bool,
    #[serde(default = "default_true")]
    pub bundle_edges: bool,
}

fn default_true() -> bool {
    true
}

impl Default for TopologyLocalOptions {
    fn default() -> Self {
        Self {
            no_fade_edges: false,
            hide_edge_types: vec![EdgeTypeDiscriminants::Hypervisor],
            tag_filter: TopologyTagFilter::default(),
            show_minimap: true,
            bundle_edges: true,
        }
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, ToSchema)]
pub struct TopologyRequestOptions {
    pub hide_ports: bool,
    #[serde(default = "default_hide_service_categories")]
    pub hide_service_categories: HashMap<TopologyView, Vec<ServiceCategory>>,
    #[serde(default = "default_container_rules")]
    pub container_rules: HashMap<TopologyView, Vec<IdentifiedRule<ContainerRule>>>,
    #[serde(default = "default_element_rules")]
    pub element_rules: Vec<IdentifiedRule<ElementRule>>,
    #[serde(default)]
    pub view: TopologyView,
}

fn default_hide_service_categories() -> HashMap<TopologyView, Vec<ServiceCategory>> {
    TopologyView::iter()
        .map(|p| (p, vec![ServiceCategory::OpenPorts]))
        .collect()
}

fn default_container_rules() -> HashMap<TopologyView, Vec<IdentifiedRule<ContainerRule>>> {
    use ContainerRule::*;

    // Build from applicable_views: for each rule type, add it to every view it applies to
    let all_rules: Vec<IdentifiedRule<ContainerRule>> = vec![
        IdentifiedRule::new(BySubnet),
        IdentifiedRule::new(MergeDockerBridges),
        IdentifiedRule::new(ByApplication { tag_ids: vec![] }),
        IdentifiedRule::new(ByHost),
    ];

    let mut map: HashMap<TopologyView, Vec<IdentifiedRule<ContainerRule>>> =
        TopologyView::iter().map(|p| (p, vec![])).collect();

    for gr in all_rules {
        for &view in gr.rule.applicable_views() {
            map.entry(view).or_default().push(gr.clone());
        }
    }

    map
}

fn default_element_rules() -> Vec<IdentifiedRule<ElementRule>> {
    vec![
        IdentifiedRule::new(ElementRule::ByTrunkPort),
        IdentifiedRule::new(ElementRule::ByVLAN),
        IdentifiedRule::new(ElementRule::ByPortOpStatus),
        IdentifiedRule::new(ElementRule::ByServiceCategory {
            categories: ServiceCategory::iter()
                .filter(|c| c.application_relevant_use_cases().is_empty())
                .collect(),
            title: Some("Infrastructure".into()),
            is_infra_rule: true,
        }),
        IdentifiedRule::new(ElementRule::ByTag {
            tag_ids: vec![],
            title: None,
        }),
        IdentifiedRule::new(ElementRule::ByHypervisor),
        IdentifiedRule::new(ElementRule::ByContainerRuntime),
        IdentifiedRule::new(ElementRule::ByStack),
    ]
}

impl Default for TopologyRequestOptions {
    fn default() -> Self {
        Self {
            hide_ports: false,
            hide_service_categories: default_hide_service_categories(),
            container_rules: default_container_rules(),
            element_rules: default_element_rules(),
            view: TopologyView::default(),
        }
    }
}

/// Lightweight request type for topology rebuild/refresh operations.
///
/// This type only includes the fields actually needed by the server - entity data
/// (hosts, ip_addresses, services, etc.) is fetched fresh from the database.
/// Using this instead of the full Topology dramatically reduces payload size
/// for large networks (from MBs to KBs), fixing HTTP 413 errors.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct TopologyRebuildRequest {
    /// Network ID for authorization and data fetching
    pub network_id: Uuid,
    /// Topology options for graph building
    pub options: TopologyOptions,
    /// Existing nodes for position preservation during rebuild
    #[serde(default)]
    pub nodes: Vec<Node>,
    /// Existing edges for reference during rebuild
    #[serde(default)]
    pub edges: Vec<Edge>,
}

/// Lightweight request type for updating a single node's position.
///
/// Used for drag operations - instead of sending the entire topology (which can be
/// several megabytes for large networks), only sends the node ID and new position.
/// Fixes HTTP 413 errors on drag operations.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct TopologyNodePositionUpdate {
    /// Network ID for authorization
    pub network_id: Uuid,
    /// ID of the node to update
    pub node_id: Uuid,
    /// New position for the node
    pub position: Ixy,
}

/// Lightweight request type for updating an edge's handles.
///
/// Used for edge reconnect operations - instead of sending the entire topology,
/// only sends the edge ID and new handle positions.
/// Fixes HTTP 413 errors on edge reconnect operations.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct TopologyEdgeHandleUpdate {
    /// Network ID for authorization
    pub network_id: Uuid,
    /// ID of the edge to update
    pub edge_id: Uuid,
    /// New source handle position
    pub source_handle: EdgeHandle,
    /// New target handle position
    pub target_handle: EdgeHandle,
}

/// Lightweight request type for updating a node's size and position.
///
/// Used for subnet resize operations - instead of sending the entire topology,
/// only sends the node ID, new size, and new position.
/// Fixes HTTP 413 errors on resize operations.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct TopologyNodeResizeUpdate {
    /// Network ID for authorization
    pub network_id: Uuid,
    /// ID of the node to update
    pub node_id: Uuid,
    /// New size for the node
    pub size: Uxy,
    /// New position for the node
    pub position: Ixy,
}

/// Lightweight request type for updating topology metadata.
///
/// Used for editing topology name/parent - instead of sending the entire topology
/// (which includes all hosts, ip_addresses, services, etc.), only sends the metadata fields.
/// Fixes HTTP 413 errors on metadata edit operations.
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct TopologyMetadataUpdate {
    /// Network ID for authorization
    pub network_id: Uuid,
    /// New name for the topology
    pub name: String,
    /// New parent topology ID (optional)
    pub parent_id: Option<Uuid>,
}
