use crate::server::{
    auth::middleware::{
        features::{BlockedInDemoMode, RequireFeature},
        permissions::{Authorized, IsUser},
    },
    config::AppState,
    shared::{
        api_key_common::{ApiKeyService, ApiKeyType, generate_api_key_for_storage},
        services::traits::CrudService,
        storage::traits::StorableEntity,
        types::api::{ApiError, ApiErrorResponse, ApiResponse, ApiResult},
    },
    user_api_keys::{
        r#impl::{api::UserApiKeyResponse, base::UserApiKey},
        service::UserApiKeyService,
    },
};
use axum::{
    Json,
    extract::{Path, State},
};
use axum_client_ip::ClientIp;
use axum_extra::{TypedHeader, headers::UserAgent};
use std::sync::Arc;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

mod generated {
    use super::*;
    crate::crud_get_by_id_handler!(UserApiKey, "user_api_keys", "user_api_key");
    crate::crud_delete_handler!(UserApiKey, "user_api_keys", "user_api_key");
    crate::crud_bulk_delete_handler!(UserApiKey, "user_api_keys");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all, create_user_api_key))
        .routes(routes!(generated::get_by_id, generated::delete))
        .routes(routes!(update_user_api_key))
        .routes(routes!(rotate_key_handler))
        .routes(routes!(generated::bulk_delete))
}

/// Get all user API keys for the current user
#[utoipa::path(
    get,
    path = "",
    tag = "user_api_keys",
    operation_id = "get_all_user_api_keys",
    responses(
        (status = 200, description = "List of user API keys", body = ApiResponse<Vec<UserApiKey>>),
        (status = 401, description = "Not authenticated", body = ApiErrorResponse),
        (status = 500, description = "Internal server error", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
pub async fn get_all(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsUser>,
) -> ApiResult<Json<ApiResponse<Vec<UserApiKey>>>> {
    let user_id = auth.require_user_id()?;
    let service = &state.services.user_api_key_service;

    let keys = service.get_for_user(&user_id).await.map_err(|e| {
        tracing::error!(
            user_id = %user_id,
            error = %e,
            "Failed to fetch user API keys"
        );
        ApiError::internal_error(&e.to_string())
    })?;

    Ok(Json(ApiResponse::success(keys)))
}

/// Create a new user API key
#[utoipa::path(
    post,
    path = "",
    tag = "user_api_keys",
    operation_id = "create_user_api_key",
    responses(
        (status = 200, description = "API key created", body = ApiResponse<UserApiKeyResponse>),
        (status = 400, description = "Bad request", body = ApiErrorResponse),
        (status = 403, description = "Invalid permissions or network access", body = ApiErrorResponse),
        (status = 500, description = "Internal server error", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
pub async fn create_user_api_key(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsUser>,
    _demo_check: RequireFeature<BlockedInDemoMode>,
    Json(mut api_key): Json<UserApiKey>,
) -> ApiResult<Json<ApiResponse<UserApiKeyResponse>>> {
    let user_id = auth.require_user_id()?;
    let organization_id = auth.require_organization_id()?;
    let user_permissions = auth.require_permissions()?;
    let user_network_ids = auth.network_ids();

    tracing::debug!(
        api_key_name = %api_key.base.name,
        permissions = %api_key.base.permissions,
        user_id = %user_id,
        "User API key create request received"
    );

    // Validate permissions don't exceed user's permissions
    UserApiKeyService::validate_permissions(api_key.base.permissions, user_permissions)
        .map_err(|e| ApiError::forbidden(&e))?;

    // Validate network access is a subset of user's access
    UserApiKeyService::validate_network_access(&api_key.base.network_ids, &user_network_ids)
        .map_err(|e| ApiError::forbidden(&e))?;

    // Set user_id and organization_id from authenticated user
    api_key.base.user_id = user_id;
    api_key.base.organization_id = organization_id;

    let (plaintext, hashed) = generate_api_key_for_storage(ApiKeyType::User);
    api_key.base.key = hashed;

    let network_ids = api_key.base.network_ids.clone();

    let service = &state.services.user_api_key_service;
    let api_key = service
        .create_with_networks(api_key, network_ids, auth.entity.clone())
        .await
        .map_err(|e| {
            tracing::error!(
                error = %e,
                user_id = %user_id,
                "Failed to create user API key"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(UserApiKeyResponse {
        key: plaintext,
        api_key,
    })))
}

/// Update a user API key
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "user_api_keys",
    operation_id = "update_user_api_key",
    params(("id" = Uuid, Path, description = "API key ID")),
    responses(
        (status = 200, description = "API key updated", body = ApiResponse<UserApiKey>),
        (status = 403, description = "Not authorized to update this key", body = ApiErrorResponse),
        (status = 404, description = "API key not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
pub async fn update_user_api_key(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsUser>,
    Path(id): Path<Uuid>,
    Json(mut request): Json<UserApiKey>,
) -> ApiResult<Json<ApiResponse<UserApiKey>>> {
    let user_id = auth.require_user_id()?;
    let user_permissions = auth.require_permissions()?;
    let user_network_ids = auth.network_ids();

    let service = &state.services.user_api_key_service;

    // Fetch existing to verify ownership
    let existing = service
        .get_by_id(&id)
        .await?
        .ok_or_else(|| ApiError::not_found(format!("API key '{}' not found", id)))?;

    // Verify the user owns this key
    if existing.base.user_id != user_id {
        return Err(ApiError::forbidden("You don't own this API key"));
    }

    // Validate permissions don't exceed user's permissions
    UserApiKeyService::validate_permissions(request.base.permissions, user_permissions)
        .map_err(|e| ApiError::forbidden(&e))?;

    // Validate network access is a subset of user's access
    UserApiKeyService::validate_network_access(&request.base.network_ids, &user_network_ids)
        .map_err(|e| ApiError::forbidden(&e))?;

    // Preserve immutable fields
    request.base.key = existing.base.key.clone();
    request.base.last_used = existing.base.last_used;
    request.base.user_id = existing.base.user_id;
    request.base.organization_id = existing.base.organization_id;
    request.set_id(existing.id());
    request.set_created_at(existing.created_at());

    // Update network access
    let network_ids = request.base.network_ids.clone();
    service.update_network_access(&id, &network_ids).await?;

    // Update the entity
    let updated = service
        .update(&mut request, auth.into_entity())
        .await
        .map_err(|e| ApiError::internal_error(&e.to_string()))?;

    // Return with hydrated network_ids
    let mut result = updated;
    result.base.network_ids = network_ids;

    Ok(Json(ApiResponse::success(result)))
}

/// Rotate a user API key
#[utoipa::path(
    post,
    path = "/{id}/rotate",
    tag = "user_api_keys",
    operation_id = "rotate_user_api_key",
    params(("id" = Uuid, Path, description = "API key ID")),
    responses(
        (status = 200, description = "API key rotated, returns new key", body = ApiResponse<String>),
        (status = 403, description = "Not authorized to rotate this key", body = ApiErrorResponse),
        (status = 404, description = "API key not found", body = ApiErrorResponse),
    ),
    security(("session" = []))
)]
pub async fn rotate_key_handler(
    State(state): State<Arc<AppState>>,
    auth: Authorized<IsUser>,
    _demo_check: RequireFeature<BlockedInDemoMode>,
    ClientIp(ip): ClientIp,
    user_agent: Option<TypedHeader<UserAgent>>,
    Path(api_key_id): Path<Uuid>,
) -> ApiResult<Json<ApiResponse<String>>> {
    let user_id = auth.require_user_id()?;
    let user_agent = user_agent.map(|u| u.to_string());

    let service = &state.services.user_api_key_service;
    let key = service
        .rotate_key(api_key_id, ip, user_agent, auth.into_entity())
        .await
        .map_err(|e| {
            tracing::error!(
                api_key_id = %api_key_id,
                user_id = %user_id,
                error = %e,
                "Failed to rotate user API key"
            );
            ApiError::internal_error(&e.to_string())
        })?;

    Ok(Json(ApiResponse::success(key)))
}
