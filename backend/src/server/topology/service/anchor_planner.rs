use uuid::Uuid;

use crate::server::topology::{service::context::TopologyContext, types::edges::Edge};

pub struct ChildAnchorPlanner;

impl ChildAnchorPlanner {
    /// Return all edges for this interface. Edge handles are now computed
    /// frontend-only after layout, based on actual rendered node positions.
    pub fn plan_anchors(
        ip_address_id: Uuid,
        edges: &mut [Edge],
        _ctx: &TopologyContext,
    ) -> Vec<Edge> {
        edges
            .iter()
            .filter(|edge| edge.source == ip_address_id || edge.target == ip_address_id)
            .cloned()
            .collect()
    }
}
