use crate::{
    daemon::{
        discovery::handlers as discovery_handlers,
        runtime::{
            state::{DaemonStateProvider, DaemonStatus, DiscoveryPollResponse},
            types::{DaemonAppState, InitializeDaemonRequest},
        },
        shared::auth::server_auth_middleware,
    },
    server::shared::types::api::{ApiResponse, ApiResult},
};
use axum::{
    Json, Router,
    extract::State,
    middleware,
    routing::{get, post},
};
use std::sync::Arc;

/// Create daemon HTTP router.
/// The `state` parameter is required for applying authentication middleware
/// to ServerPoll mode endpoints.
pub fn create_router(state: Arc<DaemonAppState>) -> Router<Arc<DaemonAppState>> {
    // Public routes (no auth required)
    let public_routes = Router::new()
        .nest("/api/discovery", discovery_handlers::create_router())
        .route("/api/health", get(get_health))
        .route("/api/initialize", post(initialize));

    // Authenticated routes (ServerPoll mode - server must provide valid API key)
    let authenticated_routes = Router::new()
        .route("/api/status", get(get_status))
        .route("/api/poll", get(get_discovery_poll))
        .route_layer(middleware::from_fn_with_state(
            state,
            server_auth_middleware,
        ));

    public_routes.merge(authenticated_routes)
}

async fn get_health() -> ApiResult<Json<ApiResponse<String>>> {
    tracing::info!("Received healthcheck request");

    Ok(Json(ApiResponse::success(
        "Scanopy Daemon Running".to_string(),
    )))
}

async fn initialize(
    State(state): State<Arc<DaemonAppState>>,
    Json(request): Json<InitializeDaemonRequest>,
) -> ApiResult<Json<ApiResponse<String>>> {
    // Check if daemon is already initialized (once-only guard)
    // Prevents re-initialization attacks - if both network_id and api_key are set,
    // return success without modifying the configuration
    let existing_network_id = state.config.get_network_id().await.ok().flatten();
    let existing_api_key = state.config.get_api_key().await.ok().flatten();

    if existing_network_id.is_some() && existing_api_key.is_some() {
        tracing::warn!(
            network_id = %request.network_id,
            "Received initialization request but daemon is already initialized - ignoring"
        );
        return Ok(Json(ApiResponse::success(
            "Daemon already initialized".to_string(),
        )));
    }

    tracing::info!(
        network_id = %request.network_id,
        api_key = %request.api_key,
        "Received initialization signal",
    );

    state
        .services
        .runtime_service
        .initialize_services(request.network_id, request.api_key)
        .await?;

    Ok(Json(ApiResponse::success(
        "Daemon initialized successfully".to_string(),
    )))
}

/// Get daemon status (for ServerPoll mode).
/// Returns lightweight status: url, name, mode, version.
async fn get_status(
    State(state): State<Arc<DaemonAppState>>,
) -> ApiResult<Json<ApiResponse<DaemonStatus>>> {
    let status = state.services.daemon_state.get_status().await;
    Ok(Json(ApiResponse::success(status)))
}

/// Get discovery poll data (for ServerPoll mode).
/// Returns current progress and any buffered entities since last poll.
async fn get_discovery_poll(
    State(state): State<Arc<DaemonAppState>>,
) -> ApiResult<Json<ApiResponse<DiscoveryPollResponse>>> {
    let progress = state.services.daemon_state.get_progress().await;
    let entities = state.services.daemon_state.drain_entities().await;

    Ok(Json(ApiResponse::success(DiscoveryPollResponse {
        progress,
        entities,
    })))
}
