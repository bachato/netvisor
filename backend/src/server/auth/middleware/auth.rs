use std::fmt::Display;

use crate::server::{
    config::AppState,
    shared::{
        api_key_common::{check_key_validity, hash_api_key, ApiKeyCommon, ApiKeyType},
        services::traits::CrudService,
        storage::filter::EntityFilter,
        types::api::ApiError,
    },
    users::r#impl::{base::User, permissions::UserOrgPermissions},
};
use axum::{
    extract::FromRequestParts,
    http::request::Parts,
    response::{IntoResponse, Response},
};
use chrono::Utc;
use email_address::EmailAddress;
use serde::Deserialize;
use serde::Serialize;
use tower_sessions::Session;
use uuid::Uuid;

pub struct AuthError(pub ApiError);

impl IntoResponse for AuthError {
    fn into_response(self) -> Response {
        self.0.into_response()
    }
}

/// Represents either an authenticated user, daemon, or user API key
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum AuthenticatedEntity {
    User {
        user_id: Uuid,
        organization_id: Uuid,
        permissions: UserOrgPermissions,
        network_ids: Vec<Uuid>,
        email: EmailAddress,
    },
    Daemon {
        network_id: Uuid,
        api_key_id: Uuid,
        daemon_id: Uuid,
    },
    /// User API key authentication - acts on behalf of a user with potentially restricted permissions
    ApiKey {
        api_key_id: Uuid,
        user_id: Uuid,
        organization_id: Uuid,
        permissions: UserOrgPermissions,
        network_ids: Vec<Uuid>,
    },
    System,
    Anonymous,
}

impl Display for AuthenticatedEntity {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AuthenticatedEntity::Anonymous => write!(f, "Anonymous"),
            AuthenticatedEntity::System => write!(f, "System"),
            AuthenticatedEntity::Daemon { .. } => write!(f, "Daemon"),
            AuthenticatedEntity::User {
                user_id,
                permissions,
                ..
            } => write!(
                f,
                "User {{ user_id: {}, permissions: {} }}",
                user_id, permissions
            ),
            AuthenticatedEntity::ApiKey {
                api_key_id,
                user_id,
                permissions,
                ..
            } => write!(
                f,
                "ApiKey {{ api_key_id: {}, user_id: {}, permissions: {} }}",
                api_key_id, user_id, permissions
            ),
        }
    }
}

impl AuthenticatedEntity {
    /// Get the user_id if this is a User or ApiKey, otherwise None
    pub fn user_id(&self) -> Option<Uuid> {
        match self {
            AuthenticatedEntity::User { user_id, .. } => Some(*user_id),
            AuthenticatedEntity::ApiKey { user_id, .. } => Some(*user_id),
            _ => None,
        }
    }

    /// Get the organization_id if this is a User or ApiKey, otherwise None
    pub fn organization_id(&self) -> Option<Uuid> {
        match self {
            AuthenticatedEntity::User {
                organization_id, ..
            } => Some(*organization_id),
            AuthenticatedEntity::ApiKey {
                organization_id, ..
            } => Some(*organization_id),
            _ => None,
        }
    }

    /// Get permissions if this is a User or ApiKey, otherwise None
    pub fn permissions(&self) -> Option<UserOrgPermissions> {
        match self {
            AuthenticatedEntity::User { permissions, .. } => Some(*permissions),
            AuthenticatedEntity::ApiKey { permissions, .. } => Some(*permissions),
            _ => None,
        }
    }

    pub fn entity_id(&self) -> String {
        match self {
            AuthenticatedEntity::User { user_id, .. } => user_id.to_string(),
            AuthenticatedEntity::Daemon { daemon_id, .. } => daemon_id.to_string(),
            AuthenticatedEntity::ApiKey { api_key_id, .. } => api_key_id.to_string(),
            AuthenticatedEntity::System => "System".to_string(),
            AuthenticatedEntity::Anonymous => "Anonymous".to_string(),
        }
    }

    /// Get network_ids that daemon / user / API key have access to
    pub fn network_ids(&self) -> Vec<Uuid> {
        match self {
            AuthenticatedEntity::Daemon { network_id, .. } => vec![*network_id],
            AuthenticatedEntity::User { network_ids, .. } => network_ids.clone(),
            AuthenticatedEntity::ApiKey { network_ids, .. } => network_ids.clone(),
            AuthenticatedEntity::System => vec![],
            AuthenticatedEntity::Anonymous => vec![],
        }
    }

    /// Check if this is a user (session-based authentication)
    pub fn is_user(&self) -> bool {
        matches!(self, AuthenticatedEntity::User { .. })
    }

    /// Check if this is a daemon
    pub fn is_daemon(&self) -> bool {
        matches!(self, AuthenticatedEntity::Daemon { .. })
    }

    /// Check if this is a user API key
    pub fn is_api_key(&self) -> bool {
        matches!(self, AuthenticatedEntity::ApiKey { .. })
    }

    /// Check if this is a user or API key (has user-level permissions)
    pub fn is_user_or_api_key(&self) -> bool {
        matches!(
            self,
            AuthenticatedEntity::User { .. } | AuthenticatedEntity::ApiKey { .. }
        )
    }
}

impl From<User> for AuthenticatedEntity {
    fn from(value: User) -> Self {
        AuthenticatedEntity::User {
            user_id: value.id,
            organization_id: value.base.organization_id,
            permissions: value.base.permissions,
            network_ids: vec![],
            email: value.base.email,
        }
    }
}

// Generic authenticated entity extractor - accepts users, daemons, and user API keys
impl<S> FromRequestParts<S> for AuthenticatedEntity
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let app_state = state.as_ref();

        // Check for Bearer token in Authorization header
        if let Some(auth_header) = parts.headers.get(axum::http::header::AUTHORIZATION)
            && let Ok(auth_str) = auth_header.to_str()
            && let Some(api_key_raw) = auth_str.strip_prefix("Bearer ")
        {
            let hashed_key = hash_api_key(api_key_raw);

            // Detect key type from prefix
            let (key_type, _is_prefixed) = ApiKeyType::from_key(api_key_raw);

            match key_type {
                ApiKeyType::User => {
                    // User API key authentication
                    if let Ok(Some(mut user_api_key)) = app_state
                        .services
                        .user_api_key_service
                        .get_by_key(&hashed_key)
                        .await
                    {
                        let api_key_id = user_api_key.id;
                        let user_id = user_api_key.base.user_id;
                        let organization_id = user_api_key.base.organization_id;
                        let permissions = user_api_key.base.permissions;
                        let service = app_state.services.user_api_key_service.clone();

                        // Check validity using shared trait
                        if let Err(e) = check_key_validity(&user_api_key) {
                            // Auto-disable expired keys
                            if user_api_key.is_expired() {
                                user_api_key.set_is_enabled(false);
                                tokio::spawn(async move {
                                    let _ = service
                                        .update(&mut user_api_key, AuthenticatedEntity::System)
                                        .await;
                                });
                            }
                            return Err(AuthError(e));
                        }

                        // Get network access from junction table
                        let network_ids = app_state
                            .services
                            .user_api_key_service
                            .get_network_ids(&api_key_id)
                            .await
                            .unwrap_or_default();

                        // Update last used asynchronously (don't block auth)
                        user_api_key.set_last_used(Some(Utc::now()));
                        tokio::spawn(async move {
                            let _ = service
                                .update(&mut user_api_key, AuthenticatedEntity::System)
                                .await;
                        });

                        return Ok(AuthenticatedEntity::ApiKey {
                            api_key_id,
                            user_id,
                            organization_id,
                            permissions,
                            network_ids,
                        });
                    }

                    return Err(AuthError(ApiError::unauthorized(
                        "Invalid API key".to_string(),
                    )));
                }
                ApiKeyType::Daemon => {
                    // Daemon API key authentication - requires X-Daemon-ID header
                    let daemon_id = parts
                        .headers
                        .get("X-Daemon-ID")
                        .and_then(|h| h.to_str().ok())
                        .and_then(|s| Uuid::parse_str(s).ok())
                        .ok_or_else(|| {
                            AuthError(ApiError::unauthorized(
                                "X-Daemon-ID header required for daemon API keys".to_string(),
                            ))
                        })?;

                    let api_key_filter = EntityFilter::unfiltered().api_key(hashed_key);
                    if let Ok(Some(mut api_key)) = app_state
                        .services
                        .daemon_api_key_service
                        .get_one(api_key_filter)
                        .await
                    {
                        let network_id = api_key.base.network_id;
                        let service = app_state.services.daemon_api_key_service.clone();
                        let api_key_id = api_key.id;

                        // Check validity using shared trait
                        if let Err(e) = check_key_validity(&api_key) {
                            // Auto-disable expired keys
                            if api_key.is_expired() {
                                api_key.set_is_enabled(false);
                                tokio::spawn(async move {
                                    let _ = service
                                        .update(&mut api_key, AuthenticatedEntity::System)
                                        .await;
                                });
                            }
                            return Err(AuthError(e));
                        }

                        // Update last used asynchronously (don't block auth)
                        api_key.set_last_used(Some(Utc::now()));
                        tokio::spawn(async move {
                            let _ = service
                                .update(&mut api_key, AuthenticatedEntity::System)
                                .await;
                        });

                        return Ok(AuthenticatedEntity::Daemon {
                            network_id,
                            api_key_id,
                            daemon_id,
                        });
                    }

                    return Err(AuthError(ApiError::unauthorized(
                        "Invalid API key".to_string(),
                    )));
                }
            }
        }

        // Try user authentication (session cookie)
        let session = Session::from_request_parts(parts, state)
            .await
            .map_err(|_| AuthError(ApiError::unauthorized("Not authenticated".to_string())))?;

        let user_id: Uuid = session
            .get("user_id")
            .await
            .map_err(|_| AuthError(ApiError::unauthorized("Not authenticated".to_string())))?
            .ok_or_else(|| AuthError(ApiError::unauthorized("Not authenticated".to_string())))?;

        let user = app_state
            .services
            .user_service
            .get_by_id(&user_id)
            .await
            .map_err(|_| AuthError(ApiError::unauthorized("User not found".to_string())))?
            .ok_or_else(|| AuthError(ApiError::unauthorized("User not found".to_string())))?;

        let network_ids: Vec<Uuid> = if matches!(
            user.base.permissions,
            UserOrgPermissions::Owner | UserOrgPermissions::Admin
        ) {
            let org_filter = EntityFilter::unfiltered().organization_id(&user.base.organization_id);

            app_state
                .services
                .network_service
                .get_all(org_filter)
                .await
                .map_err(|_| AuthError(ApiError::internal_error("Failed to load networks")))?
                .iter()
                .map(|n| n.id)
                .collect()
        } else {
            // Load network_ids from junction table for non-admin users
            app_state
                .services
                .user_service
                .get_network_ids(&user.id)
                .await
                .map_err(|_| AuthError(ApiError::internal_error("Failed to load user networks")))?
        };

        Ok(AuthenticatedEntity::User {
            user_id: user.id,
            organization_id: user.base.organization_id,
            permissions: user.base.permissions,
            network_ids,
            email: user.base.email,
        })
    }
}

/// Extractor that only accepts authenticated users (rejects daemons)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct AuthenticatedUser {
    pub user_id: Uuid,
    pub organization_id: Uuid,
    pub permissions: UserOrgPermissions,
    pub network_ids: Vec<Uuid>,
    pub email: EmailAddress,
}

impl From<AuthenticatedUser> for AuthenticatedEntity {
    fn from(value: AuthenticatedUser) -> Self {
        AuthenticatedEntity::User {
            user_id: value.user_id,
            organization_id: value.organization_id,
            permissions: value.permissions,
            network_ids: value.network_ids,
            email: value.email,
        }
    }
}

impl<S> FromRequestParts<S> for AuthenticatedUser
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let entity = AuthenticatedEntity::from_request_parts(parts, state).await?;

        match entity {
            AuthenticatedEntity::User {
                user_id,
                organization_id,
                permissions,
                network_ids,
                email,
            } => Ok(AuthenticatedUser {
                user_id,
                organization_id,
                permissions,
                network_ids,
                email,
            }),
            _ => Err(AuthError(ApiError::unauthorized(
                "User authentication required".to_string(),
            ))),
        }
    }
}

/// Extractor that only accepts authenticated daemons (rejects users)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Copy)]
pub struct AuthenticatedDaemon {
    pub network_id: Uuid,
    pub api_key_id: Uuid,
    pub daemon_id: Uuid,
}

impl From<AuthenticatedDaemon> for AuthenticatedEntity {
    fn from(value: AuthenticatedDaemon) -> Self {
        AuthenticatedEntity::Daemon {
            network_id: value.network_id,
            api_key_id: value.api_key_id,
            daemon_id: value.daemon_id,
        }
    }
}

impl<S> FromRequestParts<S> for AuthenticatedDaemon
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let entity = AuthenticatedEntity::from_request_parts(parts, state).await?;

        match entity {
            AuthenticatedEntity::Daemon {
                network_id,
                api_key_id,
                daemon_id,
            } => Ok(AuthenticatedDaemon {
                network_id,
                api_key_id,
                daemon_id,
            }),
            _ => Err(AuthError(ApiError::unauthorized(
                "Daemon authentication required".to_string(),
            ))),
        }
    }
}

/// Extractor that only accepts user API key authentication (rejects users and daemons)
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct AuthenticatedApiKey {
    pub api_key_id: Uuid,
    pub user_id: Uuid,
    pub organization_id: Uuid,
    pub permissions: UserOrgPermissions,
    pub network_ids: Vec<Uuid>,
}

impl From<AuthenticatedApiKey> for AuthenticatedEntity {
    fn from(value: AuthenticatedApiKey) -> Self {
        AuthenticatedEntity::ApiKey {
            api_key_id: value.api_key_id,
            user_id: value.user_id,
            organization_id: value.organization_id,
            permissions: value.permissions,
            network_ids: value.network_ids,
        }
    }
}

impl<S> FromRequestParts<S> for AuthenticatedApiKey
where
    S: Send + Sync + AsRef<AppState>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let entity = AuthenticatedEntity::from_request_parts(parts, state).await?;

        match entity {
            AuthenticatedEntity::ApiKey {
                api_key_id,
                user_id,
                organization_id,
                permissions,
                network_ids,
            } => Ok(AuthenticatedApiKey {
                api_key_id,
                user_id,
                organization_id,
                permissions,
                network_ids,
            }),
            _ => Err(AuthError(ApiError::unauthorized(
                "API key authentication required".to_string(),
            ))),
        }
    }
}
