use axum::{
    extract::State,
    http::{HeaderMap, StatusCode, header},
    response::IntoResponse,
};
use std::sync::Arc;

use crate::server::config::AppState;

pub async fn get_metrics(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
) -> impl IntoResponse {
    let Some(expected_token) = &state.config.metrics_token else {
        return (StatusCode::NOT_FOUND, "Metrics not enabled").into_response();
    };

    let provided = headers
        .get("Authorization")
        .and_then(|v| v.to_str().ok())
        .and_then(|v| v.strip_prefix("Bearer "));

    match provided {
        Some(token) if token == expected_token => {
            let metrics = state.services.metrics_service.handle.render();
            (
                StatusCode::OK,
                [(header::CONTENT_TYPE, "text/plain; version=0.0.4")],
                metrics,
            )
                .into_response()
        }
        _ => (StatusCode::UNAUTHORIZED, "Invalid or missing token").into_response(),
    }
}
