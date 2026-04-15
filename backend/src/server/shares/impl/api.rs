use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use uuid::Uuid;

use super::base::{Share, ShareOptions};
use crate::server::topology::types::views::TopologyView;

#[derive(Debug, Clone, Deserialize, ToSchema)]
pub struct CreateUpdateShareRequest {
    pub share: Share,
    pub password: Option<String>,
}

/// Public share metadata (returned without authentication)
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct PublicShareMetadata {
    pub id: Uuid,
    pub name: String,
    pub requires_password: bool,
    pub options: ShareOptions,
    /// Resolved list of available topology views for this share.
    /// Filtered by both share configuration and data availability.
    /// First element is the default view.
    pub enabled_views: Vec<TopologyView>,
}

impl PublicShareMetadata {
    pub fn new(share: &Share, enabled_views: Vec<TopologyView>) -> Self {
        Self {
            id: share.id,
            name: share.base.name.clone(),
            requires_password: share.requires_password(),
            options: share.base.options.clone(),
            enabled_views,
        }
    }
}

/// Export feature flags derived from the share creator's billing plan
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct ExportFeatures {
    pub png_export: bool,
    pub svg_export: bool,
    pub mermaid_export: bool,
    pub confluence_export: bool,
    pub pdf_export: bool,
    pub html_export: bool,
    pub remove_created_with: bool,
}

/// Share with topology data (returned after authentication/verification)
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct ShareWithTopology {
    pub share: PublicShareMetadata,
    pub topology: serde_json::Value,
    pub export_features: ExportFeatures,
}
