use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::server::topology::service::legacy::planner::utils::NODE_PADDING;

/// 2D unsigned coordinate. Used for node positions and sizes.
/// Leaf node sizes are computed by the frontend (elkjs); the backend
/// sets `Uxy::default()` for leaf nodes.
#[derive(Serialize, Deserialize, Debug, Clone, Copy, Default, PartialEq, Eq, Hash, ToSchema)]
pub struct Uxy {
    pub x: usize,
    pub y: usize,
}

#[derive(Serialize, Deserialize, Debug, Clone, Copy, Default, PartialEq, Eq, Hash, ToSchema)]
pub struct Ixy {
    pub x: isize,
    pub y: isize,
}

// CHANGED: NodeLayout now stores actual position instead of grid position
#[derive(Debug, Copy, Clone)]
pub struct NodeLayout {
    pub size: Uxy,
    pub position: Ixy, // Changed from grid_position: Uxy
}

#[derive(Debug, Copy, Clone)]
pub struct SubnetLayout {
    pub size: Uxy,
}

// Helper struct for tracking node bounds
#[derive(Debug, Copy, Clone)]
pub struct NodeBounds {
    pub x: isize,
    pub y: isize,
    pub width: usize,
    pub height: usize,
}

impl NodeBounds {
    pub fn new(position: Ixy, size: Uxy) -> Self {
        Self {
            x: position.x,
            y: position.y,
            width: size.x,
            height: size.y,
        }
    }

    pub fn right(&self) -> isize {
        self.x + self.width as isize
    }

    pub fn bottom(&self) -> isize {
        self.y + self.height as isize
    }

    /// Check if this node overlaps with another node
    pub fn overlaps(&self, other: &NodeBounds) -> bool {
        // Consider nodes overlapping if they're within padding distance
        !(self.right() + NODE_PADDING.x as isize <= other.x
            || self.x >= other.right() + NODE_PADDING.x as isize
            || self.bottom() + NODE_PADDING.y as isize <= other.y
            || self.y >= other.bottom() + NODE_PADDING.y as isize)
    }

    /// Calculate the minimum shift needed to resolve overlap with another node
    /// Returns (dx, dy) to move this node to avoid overlap
    pub fn resolve_overlap(&self, other: &NodeBounds) -> (isize, isize) {
        if !self.overlaps(other) {
            return (0, 0);
        }

        // Calculate raw overlap amounts (without padding)
        let overlap_left = other.right() - self.x;
        let overlap_right = self.right() - other.x;
        let overlap_top = other.bottom() - self.y;
        let overlap_bottom = self.bottom() - other.y;

        // Find the minimum overlap direction
        let min_horizontal = overlap_left.min(overlap_right);
        let min_vertical = overlap_top.min(overlap_bottom);

        if min_horizontal < min_vertical {
            // Move horizontally
            if overlap_left < overlap_right {
                // Move left: add padding to separation
                (-(overlap_left + NODE_PADDING.x as isize), 0)
            } else {
                // Move right: add padding to separation
                (overlap_right + NODE_PADDING.x as isize, 0)
            }
        } else {
            // Move vertically
            if overlap_top < overlap_bottom {
                // Move up: add padding to separation
                (0, -(overlap_top + NODE_PADDING.y as isize))
            } else {
                // Move down: add padding to separation
                (0, overlap_bottom + NODE_PADDING.y as isize)
            }
        }
    }
}
