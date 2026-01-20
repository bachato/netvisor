use crate::server::auth::middleware::permissions::{Authorized, IsDaemon, Member, Viewer};
use crate::server::billing::types::base::BillingPlan;
use crate::server::daemon_api_keys::r#impl::base::{DaemonApiKey, DaemonApiKeyBase};
use crate::server::daemons::r#impl::api::DaemonHeartbeatPayload;
use crate::server::daemons::processor::DaemonStatusData;
use crate::server::shared::api_key_common::{ApiKeyType, generate_api_key_for_storage};
use crate::server::shared::entities::EntityDiscriminants;
use crate::server::shared::events::types::TelemetryOperation;
use crate::server::shared::extractors::Query;
use crate::server::shared::handlers::ordering::OrderField;
use crate::server::shared::handlers::query::{
    FilterQueryExtractor, OrderDirection, PaginationParams,
};
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::StorableFilter;
use crate::server::shared::storage::traits::Storable;
use crate::server::shared::types::api::ApiErrorResponse;
use crate::server::shared::validation::validate_network_access;
use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    config::AppState,
    daemons::r#impl::{
        api::{
            DaemonCapabilities, DaemonRegistrationRequest, DaemonRegistrationResponse,
            DaemonResponse, DaemonStartupRequest, DiscoveryUpdatePayload, ServerCapabilities,
        },
        base::{Daemon, DaemonBase, DaemonMode},
        version::DaemonVersionPolicy,
    },
    discovery::r#impl::{
        base::{Discovery, DiscoveryBase},
        types::{DiscoveryType, HostNamingFallback, RunType},
    },
    hosts::r#impl::base::{Host, HostBase},
    shared::{
        events::types::TelemetryEvent,
        services::traits::EventBusService,
        types::{
            api::{ApiError, ApiResponse, ApiResult, EmptyApiResponse, PaginatedApiResponse},
            entities::EntitySource,
        },
    },
};
use axum::{
    extract::{Path, State},
    response::Json,
};
use chrono::Utc;
use secrecy::SecretString;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use utoipa::IntoParams;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

// ============================================================================
// Daemon Ordering
// ============================================================================

/// Fields that daemons can be ordered/grouped by.
#[derive(Serialize, Deserialize, Debug, Clone, Copy, Default, utoipa::ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum DaemonOrderField {
    #[default]
    CreatedAt,
    Name,
    LastSeen,
    UpdatedAt,
    NetworkId,
}

impl OrderField for DaemonOrderField {
    fn to_sql(&self) -> &'static str {
        match self {
            Self::CreatedAt => "daemons.created_at",
            Self::Name => "daemons.name",
            Self::LastSeen => "daemons.last_seen",
            Self::UpdatedAt => "daemons.updated_at",
            Self::NetworkId => "daemons.network_id",
        }
    }
}

// ============================================================================
// Daemon Filter Query
// ============================================================================

/// Query parameters for filtering and ordering daemons.
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct DaemonFilterQuery {
    /// Filter by network ID
    pub network_id: Option<Uuid>,
    /// Primary ordering field (used for grouping). Always sorts ASC to keep groups together.
    pub group_by: Option<DaemonOrderField>,
    /// Secondary ordering field (sorting within groups or standalone sort).
    pub order_by: Option<DaemonOrderField>,
    /// Direction for order_by field (group_by always uses ASC).
    pub order_direction: Option<OrderDirection>,
    /// Maximum number of results to return (1-1000, default: 50). Use 0 for no limit.
    #[param(minimum = 0, maximum = 1000)]
    pub limit: Option<u32>,
    /// Number of results to skip. Default: 0.
    #[param(minimum = 0)]
    pub offset: Option<u32>,
}

impl DaemonFilterQuery {
    /// Build the ORDER BY clause.
    pub fn apply_ordering(
        &self,
        filter: StorableFilter<Daemon>,
    ) -> (StorableFilter<Daemon>, String) {
        crate::server::shared::handlers::ordering::apply_ordering(
            self.group_by,
            self.order_by,
            self.order_direction,
            filter,
            "daemons.created_at ASC",
        )
    }
}

impl FilterQueryExtractor for DaemonFilterQuery {
    fn apply_to_filter<T: Storable>(
        &self,
        filter: StorableFilter<T>,
        user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> StorableFilter<T> {
        match self.network_id {
            Some(id) if user_network_ids.contains(&id) => filter.network_ids(&[id]),
            Some(_) => filter.network_ids(&[]), // User doesn't have access - return empty
            None => filter.network_ids(user_network_ids),
        }
    }

    fn pagination(&self) -> PaginationParams {
        PaginationParams {
            limit: self.limit,
            offset: self.offset,
        }
    }
}

// Generated handlers for operations that use generic CRUD logic
mod generated {
    use super::*;
    crate::crud_delete_handler!(Daemon, "daemons", "daemon");
    crate::crud_bulk_delete_handler!(Daemon, "daemons");
}

/// User-facing daemon management endpoints (versioned at /api/v1/daemons)
pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all))
        .routes(routes!(get_by_id, generated::delete))
        .routes(routes!(generated::bulk_delete))
        .routes(routes!(provision_daemon))
}

/// Daemon-internal endpoints (unversioned at /api/daemon)
/// These are called by daemons themselves, not by users.
pub fn create_internal_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(register_daemon))
        .routes(routes!(daemon_startup))
        .routes(routes!(receive_heartbeat))
        .routes(routes!(update_capabilities))
        .routes(routes!(receive_work_request))
}

/// Get all daemons
///
/// Returns all daemons accessible to the user.
/// Supports pagination via `limit` and `offset` query parameters,
/// and ordering via `group_by`, `order_by`, and `order_direction`.
#[utoipa::path(
    get,
    path = "",
    tag = "daemons",
    operation_id = "get_daemons",
    summary = "Get all daemons",
    params(DaemonFilterQuery),
    responses(
        (status = 200, description = "List of daemons", body = PaginatedApiResponse<DaemonResponse>),
    ),
     security(("user_api_key" = []), ("session" = []))
)]
async fn get_all(
    State(state): State<Arc<AppState>>,
    auth: Authorized<Viewer>,
    query: Query<DaemonFilterQuery>,
) -> ApiResult<Json<PaginatedApiResponse<DaemonResponse>>> {
    let network_ids = auth.network_ids();
    let organization_id = auth
        .organization_id()
        .ok_or_else(ApiError::organization_required)?;

    // Apply network filter and pagination
    let base_filter = StorableFilter::<Daemon>::new().network_ids(&network_ids);
    let filter = query.apply_to_filter(base_filter, &network_ids, organization_id);
    let pagination = query.pagination();
    let filter = pagination.apply_to_filter(filter);

    // Apply ordering
    let (filter, order_by) = query.apply_ordering(filter);

    let result = state
        .services
        .daemon_service
        .get_paginated_ordered(filter, &order_by)
        .await?;

    let policy = DaemonVersionPolicy::default();
    let responses: Vec<DaemonResponse> = result
        .items
        .into_iter()
        .map(|d| {
            let version_status = policy.evaluate(d.base.version.as_ref());
            DaemonResponse {
                id: d.id,
                created_at: d.created_at,
                updated_at: d.updated_at,
                base: d.base,
                version_status,
            }
        })
        .collect();

    let limit = pagination.effective_limit().unwrap_or(0);
    let offset = pagination.effective_offset();

    Ok(Json(PaginatedApiResponse::success(
        responses,
        result.total_count,
        limit,
        offset,
    )))
}

/// Get daemon by ID
///
/// Returns a specific daemon with computed version status.
#[utoipa::path(
    get,
    path = "/{id}",
    tag = "daemons",
    operation_id = "get_daemon_by_id",
    summary = "Get daemon by ID",
    params(("id" = Uuid, Path, description = "Daemon ID")),
    responses(
        (status = 200, description = "Daemon found", body = ApiResponse<DaemonResponse>),
        (status = 404, description = "Daemon not found", body = ApiErrorResponse),
        (status = 403, description = "Access denied", body = ApiErrorResponse),
    ),
     security(("user_api_key" = []), ("session" = []))
)]
async fn get_by_id(
    State(state): State<Arc<AppState>>,
    auth: Authorized<Viewer>,
    Path(id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<DaemonResponse>>> {
    let network_ids = auth.network_ids();

    let mut daemon = state
        .services
        .daemon_service
        .get_by_id(&id)
        .await?
        .ok_or_else(|| ApiError::entity_not_found::<Daemon>(id))?;

    // Validate user has access to this daemon's network
    if !network_ids.contains(&daemon.base.network_id) {
        return Err(ApiError::entity_access_denied::<Daemon>(id));
    }

    // Hydrate tags from junction table
    let tags_map = state
        .services
        .entity_tag_service
        .get_tags_map(&[daemon.id], EntityDiscriminants::Daemon)
        .await?;
    if let Some(tags) = tags_map.get(&daemon.id) {
        daemon.base.tags = tags.clone();
    }

    let policy = DaemonVersionPolicy::default();
    let version_status = policy.evaluate(daemon.base.version.as_ref());

    Ok(Json(ApiResponse::success(DaemonResponse {
        id: daemon.id,
        created_at: daemon.created_at,
        updated_at: daemon.updated_at,
        base: daemon.base,
        version_status,
    })))
}

const DAILY_MIDNIGHT_CRON: &str = "0 0 0 * * *";

/// Register a new daemon
///
/// Internal endpoint for daemon self-registration. Creates a host entry
/// and sets up default discovery jobs for the daemon.
#[utoipa::path(
    post,
    path = "/register",
    tags = ["daemons", "internal"],
    request_body = DaemonRegistrationRequest,
    responses(
        (status = 200, description = "Daemon registered successfully", body = ApiResponse<DaemonRegistrationResponse>),
        (status = 403, description = "Daemon registration disabled in demo mode", body = ApiErrorResponse),
    ),
    security(("daemon_api_key" = []))
)]
async fn register_daemon(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsDaemon>,
    Json(request): Json<DaemonRegistrationRequest>,
) -> ApiResult<Json<ApiResponse<DaemonRegistrationResponse>>> {
    // Check if this is a demo organization - block daemon registration
    let network = state
        .services
        .network_service
        .get_by_id(&request.network_id)
        .await?
        .ok_or_else(|| ApiError::not_found("Network not found".to_string()))?;

    let org = state
        .services
        .organization_service
        .get_by_id(&network.base.organization_id)
        .await?
        .ok_or_else(|| ApiError::not_found("Organization not found".to_string()))?;

    if matches!(org.base.plan, Some(BillingPlan::Demo(_))) {
        return Err(ApiError::forbidden(
            "Daemon registration is disabled in demo mode",
        ));
    }

    let service = &state.services.daemon_service;

    tracing::info!("{:?}", request);

    // Parse version early for use in server_capabilities
    let daemon_version = request
        .version
        .as_ref()
        .and_then(|v| semver::Version::parse(v).ok());

    // Compute server_capabilities if version was provided
    let policy = DaemonVersionPolicy::default();
    let server_capabilities = daemon_version.as_ref().map(|v| {
        let status = policy.evaluate(Some(v));
        ServerCapabilities {
            server_version: policy.latest.clone(),
            minimum_daemon_version: policy.minimum_supported.clone(),
            deprecation_warnings: status.warnings,
        }
    });

    // Check if daemon already exists (re-registration scenario)
    // This handles cases where a previous registration partially succeeded
    if let Some(mut existing_daemon) = service.get_by_id(&request.daemon_id).await? {
        tracing::info!(
            daemon_id = %request.daemon_id,
            host_id = %existing_daemon.base.host_id,
            "Daemon already registered, updating registration"
        );

        // Update daemon with current info
        existing_daemon.base.url = request.url;
        existing_daemon.base.capabilities = request.capabilities;
        existing_daemon.base.last_seen = Utc::now();
        existing_daemon.base.mode = request.mode;
        existing_daemon.base.name = request.name;
        if let Some(v) = daemon_version.clone() {
            existing_daemon.base.version = Some(v);
        }

        let updated_daemon = service
            .update(&mut existing_daemon, auth.into_entity())
            .await
            .map_err(|e| ApiError::internal_error(&format!("Failed to update daemon: {}", e)))?;

        // Return early - host and discoveries already exist from initial registration
        return Ok(Json(ApiResponse::success(DaemonRegistrationResponse {
            daemon: updated_daemon,
            host_id: existing_daemon.base.host_id,
            server_capabilities,
        })));
    }

    // New registration - create host and daemon
    let dummy_host = Host::new(HostBase {
        network_id: request.network_id,
        name: request.name.clone(),
        hostname: None,
        description: None,
        source: EntitySource::Discovery { metadata: vec![] },
        virtualization: None,
        hidden: false,
        tags: Vec::new(),
    });

    let host_response = state
        .services
        .host_service
        .discover_host(dummy_host, vec![], vec![], vec![], auth.entity.clone())
        .await?;

    // If user_id is nil (old daemon), fall back to org owner
    let user_id = if request.user_id.is_nil() {
        state
            .services
            .user_service
            .get_organization_owners(&org.id)
            .await?
            .first()
            .map(|u| u.id)
            .unwrap_or(request.user_id)
    } else {
        request.user_id
    };

    let mut daemon = Daemon::new(DaemonBase {
        host_id: host_response.id,
        network_id: request.network_id,
        url: request.url.clone(),
        capabilities: request.capabilities.clone(),
        last_seen: Utc::now(),
        mode: request.mode,
        name: request.name,
        tags: Vec::new(),
        version: daemon_version,
        user_id,
        api_key_id: None,
    });

    daemon.id = request.daemon_id;

    let registered_daemon = service
        .create(daemon, auth.entity.clone())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to register daemon: {}", e)))?;

    let org_id = state
        .services
        .network_service
        .get_by_id(&request.network_id)
        .await?
        .map(|n| n.base.organization_id)
        .unwrap_or_default();
    let organization = state
        .services
        .organization_service
        .get_by_id(&org_id)
        .await?;

    if let Some(organization) = organization
        && organization.not_onboarded(&TelemetryOperation::FirstDaemonRegistered)
    {
        let authentication: AuthenticatedEntity = auth.into_entity();
        state
            .services
            .daemon_service
            .event_bus()
            .publish_telemetry(TelemetryEvent {
                id: Uuid::new_v4(),
                organization_id: organization.id,
                operation: TelemetryOperation::FirstDaemonRegistered,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "is_onboarding_step": true
                }),

                authentication,
            })
            .await?;
    }

    let discovery_service = state.services.discovery_service.clone();

    let self_report_discovery_type = DiscoveryType::SelfReport {
        host_id: host_response.id,
    };

    let self_report_discovery = discovery_service
        .create_discovery(
            Discovery::new(DiscoveryBase {
                run_type: RunType::Scheduled {
                    cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                    last_run: None,
                    enabled: true,
                },
                discovery_type: self_report_discovery_type.clone(),
                name: self_report_discovery_type.to_string(),
                daemon_id: request.daemon_id,
                network_id: request.network_id,
                tags: Vec::new(),
            }),
            AuthenticatedEntity::System,
        )
        .await?;

    discovery_service
        .start_session(self_report_discovery, AuthenticatedEntity::System)
        .await?;

    if request.capabilities.has_docker_socket {
        let docker_discovery_type = DiscoveryType::Docker {
            host_id: host_response.id,
            host_naming_fallback: HostNamingFallback::BestService,
        };

        let docker_discovery = discovery_service
            .create_discovery(
                Discovery::new(DiscoveryBase {
                    run_type: RunType::Scheduled {
                        cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                        last_run: None,
                        enabled: true,
                    },
                    discovery_type: docker_discovery_type.clone(),
                    name: docker_discovery_type.to_string(),
                    daemon_id: request.daemon_id,
                    network_id: request.network_id,
                    tags: Vec::new(),
                }),
                AuthenticatedEntity::System,
            )
            .await?;

        discovery_service
            .start_session(docker_discovery, AuthenticatedEntity::System)
            .await?;
    }

    let network_discovery_type = DiscoveryType::Network {
        subnet_ids: None,
        host_naming_fallback: HostNamingFallback::BestService,
    };

    let network_discovery = discovery_service
        .create_discovery(
            Discovery::new(DiscoveryBase {
                run_type: RunType::Scheduled {
                    cron_schedule: DAILY_MIDNIGHT_CRON.to_string(),
                    last_run: None,
                    enabled: true,
                },
                discovery_type: network_discovery_type.clone(),
                name: network_discovery_type.to_string(),
                daemon_id: request.daemon_id,
                network_id: request.network_id,
                tags: Vec::new(),
            }),
            AuthenticatedEntity::System,
        )
        .await?;

    discovery_service
        .start_session(network_discovery, AuthenticatedEntity::System)
        .await?;

    Ok(Json(ApiResponse::success(DaemonRegistrationResponse {
        daemon: registered_daemon,
        host_id: host_response.id,
        server_capabilities,
    })))
}

/// Daemon startup handshake
///
/// Internal endpoint for daemons to report their version on startup.
/// Updates the daemon's version and last_seen timestamp, returns server capabilities.
#[utoipa::path(
    post,
    path = "/{id}/startup",
    tags = ["daemons", "internal"],
    params(("id" = Uuid, Path, description = "Daemon ID")),
    request_body = DaemonStartupRequest,
    responses(
        (status = 200, description = "Startup acknowledged", body = ApiResponse<ServerCapabilities>),
        (status = 404, description = "Daemon not found", body = ApiErrorResponse),
    ),
    security(("daemon_api_key" = []))
)]
async fn daemon_startup(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsDaemon>,
    Path(id): Path<Uuid>,
    Json(request): Json<DaemonStartupRequest>,
) -> ApiResult<Json<ApiResponse<ServerCapabilities>>> {
    let daemon_network_id = auth.network_ids()[0];

    // Validate daemon exists and belongs to the authenticated daemon's network
    let daemon = state
        .services
        .daemon_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::entity_not_found::<Daemon>(id))?;

    if daemon.base.network_id != daemon_network_id {
        return Err(ApiError::entity_access_denied::<Daemon>(id));
    }

    // Use processor for shared startup logic
    let capabilities = state
        .services
        .daemon_processor
        .process_startup(id, request.daemon_version, auth.into_entity())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to process startup: {}", e)))?;

    Ok(Json(ApiResponse::success(capabilities)))
}

/// Update daemon capabilities
///
/// Internal endpoint for daemons to report their current capabilities.
#[utoipa::path(
    post,
    path = "/{id}/update-capabilities",
    tags = ["daemons", "internal"],
    params(("id" = Uuid, Path, description = "Daemon ID")),
    request_body = DaemonCapabilities,
    responses(
        (status = 200, description = "Capabilities updated", body = EmptyApiResponse),
        (status = 404, description = "Daemon not found", body = ApiErrorResponse),
    ),
    security(("daemon_api_key" = []))
)]
async fn update_capabilities(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsDaemon>,
    Path(id): Path<Uuid>,
    Json(updated_capabilities): Json<DaemonCapabilities>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let daemon_network_id = auth.network_ids()[0];

    // Validate daemon exists and belongs to the authenticated daemon's network
    let daemon = state
        .services
        .daemon_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::entity_not_found::<Daemon>(id))?;

    if daemon.base.network_id != daemon_network_id {
        return Err(ApiError::entity_access_denied::<Daemon>(id));
    }

    // Use processor for shared capabilities update logic
    state
        .services
        .daemon_processor
        .process_capabilities(id, updated_capabilities, auth.into_entity())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to update capabilities: {}", e)))?;

    Ok(Json(ApiResponse::success(())))
}

/// Receive daemon heartbeat
///
/// Internal endpoint for daemons to send periodic heartbeats.
/// Updates the daemon's last_seen timestamp and current status.
#[utoipa::path(
    post,
    path = "/{id}/heartbeat",
    tags = ["daemons", "internal"],
    params(("id" = Uuid, Path, description = "Daemon ID")),
    request_body = DaemonHeartbeatPayload,
    responses(
        (status = 200, description = "Heartbeat received", body = EmptyApiResponse),
        (status = 404, description = "Daemon not found", body = ApiErrorResponse),
    ),
    security(("daemon_api_key" = []))
)]
async fn receive_heartbeat(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsDaemon>,
    Path(id): Path<Uuid>,
    Json(request): Json<DaemonHeartbeatPayload>,
) -> ApiResult<Json<ApiResponse<()>>> {
    let daemon_network_id = auth.network_ids()[0];

    // Validate daemon exists and belongs to the authenticated daemon's network
    let daemon = state
        .services
        .daemon_service
        .get_by_id(&id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::entity_not_found::<Daemon>(id))?;

    if daemon.base.network_id != daemon_network_id {
        return Err(ApiError::entity_access_denied::<Daemon>(id));
    }

    // Use processor for shared heartbeat logic
    let status_data = DaemonStatusData::from(request);
    state
        .services
        .daemon_processor
        .process_heartbeat(id, status_data, auth.into_entity())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to process heartbeat: {}", e)))?;

    Ok(Json(ApiResponse::success(())))
}

/// Request work from server
///
/// Internal endpoint for daemons to poll for pending discovery sessions.
/// Also updates heartbeat and returns any pending cancellation requests.
/// Returns tuple of (next_session, should_cancel).
#[utoipa::path(
    post,
    path = "/{id}/request-work",
    tags = ["daemons", "internal"],
    params(("id" = Uuid, Path, description = "Daemon ID")),
    request_body = DaemonHeartbeatPayload,
    responses(
        (status = 200, description = "Work request processed - returns (Option<DiscoveryUpdatePayload>, bool)"),
        (status = 404, description = "Daemon not found", body = ApiErrorResponse),
    ),
    security(("daemon_api_key" = []))
)]
async fn receive_work_request(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsDaemon>,
    Path(daemon_id): Path<Uuid>,
    Json(request): Json<DaemonHeartbeatPayload>,
) -> ApiResult<Json<ApiResponse<(Option<DiscoveryUpdatePayload>, bool)>>> {
    let daemon_network_id = auth.network_ids()[0];

    // Validate daemon exists and belongs to the authenticated daemon's network
    let daemon = state
        .services
        .daemon_service
        .get_by_id(&daemon_id)
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to get daemon: {}", e)))?
        .ok_or_else(|| ApiError::entity_not_found::<Daemon>(daemon_id))?;

    if daemon.base.network_id != daemon_network_id {
        return Err(ApiError::entity_access_denied::<Daemon>(daemon_id));
    }

    // Use processor for shared heartbeat logic
    let status_data = DaemonStatusData::from(request);
    state
        .services
        .daemon_processor
        .process_heartbeat(daemon_id, status_data, auth.entity.clone())
        .await
        .map_err(|e| ApiError::internal_error(&format!("Failed to process heartbeat: {}", e)))?;

    // Use processor to get pending work and cancellation
    let next_session = state
        .services
        .daemon_processor
        .get_pending_work(daemon_id)
        .await;
    let cancellation = state
        .services
        .daemon_processor
        .get_pending_cancellation(daemon_id)
        .await;

    let has_cancellation = cancellation.is_some();

    // Log work request for tracing/debugging (previously done in service.receive_work_request)
    if next_session.is_some() || has_cancellation {
        tracing::debug!(
            daemon_id = %daemon_id,
            has_work = next_session.is_some(),
            has_cancellation = has_cancellation,
            "Daemon work request processed"
        );
    }

    Ok(Json(ApiResponse::success((next_session, has_cancellation))))
}

// ============================================================================
// Pre-provisioning (ServerPoll mode only)
// ============================================================================

/// Request to pre-provision a ServerPoll mode daemon.
/// This creates the daemon record on the server before the daemon is installed.
#[derive(Debug, Clone, Serialize, Deserialize, utoipa::ToSchema)]
pub struct ProvisionDaemonRequest {
    /// Human-readable name for the daemon.
    pub name: String,
    /// Network this daemon will be associated with.
    pub network_id: Uuid,
    /// URL where the server can reach the daemon (required for ServerPoll mode).
    pub url: String,
}

/// Response from provisioning a daemon.
/// Contains the daemon record and the API key (shown only once).
#[derive(Debug, Clone, Serialize, Deserialize, utoipa::ToSchema)]
pub struct ProvisionDaemonResponse {
    /// The created daemon record.
    pub daemon: Daemon,
    /// The API key (plaintext) for daemon authentication.
    /// This is shown only once - store it securely.
    pub daemon_api_key: String,
}

/// Pre-provision a ServerPoll mode daemon
///
/// Creates a daemon record on the server before the daemon is installed.
/// This is only for ServerPoll mode where the server initiates connections to the daemon.
/// For DaemonPoll mode, daemons self-register on startup.
///
/// Returns the daemon record and an API key that must be configured on the daemon.
#[utoipa::path(
    post,
    path = "/provision",
    tag = "daemons",
    operation_id = "provision_daemon",
    summary = "Pre-provision a ServerPoll mode daemon",
    request_body = ProvisionDaemonRequest,
    responses(
        (status = 201, description = "Daemon provisioned successfully", body = ApiResponse<ProvisionDaemonResponse>),
        (status = 400, description = "Invalid request", body = ApiErrorResponse),
        (status = 403, description = "Forbidden", body = ApiErrorResponse),
    ),
    security(("user_api_key" = []), ("session" = []))
)]
async fn provision_daemon(
    State(state): State<Arc<AppState>>,
    auth: Authorized<Member>,
    Json(request): Json<ProvisionDaemonRequest>,
) -> ApiResult<Json<ApiResponse<ProvisionDaemonResponse>>> {
    let network_ids = auth.network_ids();
    let user_id = auth.user_id().ok_or_else(ApiError::user_required)?;

    // Validate network access
    validate_network_access(Some(request.network_id), &network_ids, "provision daemon")?;

    // Generate API key (plaintext + hash)
    let (plaintext, hashed) = generate_api_key_for_storage(ApiKeyType::Daemon);

    // Create API key record with plaintext stored (for ServerPoll mode)
    let api_key = DaemonApiKey::new(DaemonApiKeyBase {
        key: hashed,
        name: format!("{} API Key", request.name),
        last_used: None,
        expires_at: None,
        network_id: request.network_id,
        is_enabled: true,
        tags: Vec::new(),
        plaintext: Some(SecretString::from(plaintext.clone())),
    });

    let created_api_key = state
        .services
        .daemon_api_key_service
        .create(api_key, auth.entity.clone())
        .await
        .map_err(|e| {
            tracing::error!(error = %e, "Failed to create API key for provisioned daemon");
            ApiError::internal_error(&format!("Failed to create API key: {}", e))
        })?;

    // Create host record for the daemon
    let host = Host::new(HostBase {
        name: request.name.clone(),
        network_id: request.network_id,
        hostname: None,
        description: None,
        source: EntitySource::System,
        virtualization: None,
        hidden: false,
        tags: Vec::new(),
    });

    let created_host = state
        .services
        .host_service
        .create(host, auth.entity.clone())
        .await
        .map_err(|e| {
            tracing::error!(error = %e, "Failed to create host for provisioned daemon");
            ApiError::internal_error(&format!("Failed to create host: {}", e))
        })?;

    // Create daemon record with mode=ServerPoll and linked API key
    let daemon = Daemon::new(DaemonBase {
        host_id: created_host.id,
        network_id: request.network_id,
        url: request.url,
        last_seen: Utc::now(),
        capabilities: DaemonCapabilities::default(),
        mode: DaemonMode::ServerPoll,
        name: request.name,
        tags: Vec::new(),
        version: None,
        user_id,
        api_key_id: Some(created_api_key.id),
    });

    let created_daemon = state
        .services
        .daemon_service
        .create(daemon, auth.entity.clone())
        .await
        .map_err(|e| {
            tracing::error!(error = %e, "Failed to create provisioned daemon");
            ApiError::internal_error(&format!("Failed to create daemon: {}", e))
        })?;

    tracing::info!(
        daemon_id = %created_daemon.id,
        network_id = %request.network_id,
        user_id = %user_id,
        "Daemon provisioned for ServerPoll mode"
    );

    Ok(Json(ApiResponse::success(ProvisionDaemonResponse {
        daemon: created_daemon,
        daemon_api_key: plaintext,
    })))
}
