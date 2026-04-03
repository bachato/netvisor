use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

/// 2D unsigned coordinate. Used for node positions and sizes.
/// Element node sizes are computed by the frontend (elkjs); the backend
/// sets `Uxy::default()` for element nodes.
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
