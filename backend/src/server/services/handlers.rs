use crate::server::auth::middleware::permissions::{Authorized, Member, Viewer};
use crate::server::shared::handlers::query::{
    FilterQueryExtractor, OrderDirection, PaginationParams,
};
use crate::server::shared::handlers::traits::update_handler;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::EntityFilter;
use crate::server::shared::storage::traits::Storage;
use crate::server::shared::types::api::{
    ApiError, ApiErrorResponse, ApiResponse, ApiResult, PaginatedApiResponse,
};
use crate::server::shared::types::entities::EntitySource;
use crate::server::shared::validation::validate_network_access;
use crate::server::{
    config::AppState,
    services::r#impl::{api::CreateServiceRequest, base::Service},
};
use axum::Json;
use axum::extract::{Path, State};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use utoipa::IntoParams;
use utoipa_axum::{router::OpenApiRouter, routes};
use uuid::Uuid;

// ============================================================================
// Service Ordering
// ============================================================================

/// Fields that services can be ordered/grouped by.
#[derive(Serialize, Deserialize, Debug, Clone, Copy, Default, utoipa::ToSchema)]
#[serde(rename_all = "snake_case")]
pub enum ServiceOrderField {
    #[default]
    CreatedAt,
    Name,
    UpdatedAt,
    /// Sort by host name. Requires JOIN to hosts table.
    Host,
    NetworkId,
    Position,
}

impl ServiceOrderField {
    /// Returns the SQL ORDER BY expression for this field.
    pub fn to_sql(&self) -> &'static str {
        match self {
            Self::CreatedAt => "services.created_at",
            Self::Name => "services.name",
            Self::UpdatedAt => "services.updated_at",
            Self::NetworkId => "services.network_id",
            Self::Position => "services.position",
            Self::Host => "COALESCE(service_host.name, '')",
        }
    }

    /// Returns the JOIN clause if this field requires one, None otherwise.
    pub fn join_sql(&self) -> Option<&'static str> {
        match self {
            Self::Host => {
                Some("LEFT JOIN hosts AS service_host ON services.host_id = service_host.id")
            }
            _ => None,
        }
    }
}

// ============================================================================
// Service Filter Query
// ============================================================================

/// Query parameters for filtering and ordering services.
#[derive(Deserialize, Default, Debug, Clone, IntoParams)]
pub struct ServiceFilterQuery {
    /// Filter by network ID
    pub network_id: Option<Uuid>,
    /// Filter by host ID
    pub host_id: Option<Uuid>,
    /// Filter by specific entity IDs (for selective loading)
    pub ids: Option<Vec<Uuid>>,
    /// Primary ordering field (used for grouping). Always sorts ASC to keep groups together.
    pub group_by: Option<ServiceOrderField>,
    /// Secondary ordering field (sorting within groups or standalone sort).
    pub order_by: Option<ServiceOrderField>,
    /// Direction for order_by field (group_by always uses ASC).
    pub order_direction: Option<OrderDirection>,
    /// Maximum number of results to return (1-1000, default: 50). Use 0 for no limit.
    #[param(minimum = 0, maximum = 1000)]
    pub limit: Option<u32>,
    /// Number of results to skip. Default: 0.
    #[param(minimum = 0)]
    pub offset: Option<u32>,
}

impl ServiceFilterQuery {
    /// Build the ORDER BY clause and apply any required JOINs to the filter.
    /// Returns: (modified_filter, order_by_sql)
    pub fn apply_ordering(&self, mut filter: EntityFilter) -> (EntityFilter, String) {
        let mut order_parts = Vec::new();

        // Primary: group_by field (always ASC to keep groups together)
        if let Some(group_field) = &self.group_by {
            if let Some(join) = group_field.join_sql() {
                filter = filter.join(join);
            }
            order_parts.push(format!("{} ASC", group_field.to_sql()));
        }

        // Secondary: order_by field with specified direction
        if let Some(order_field) = &self.order_by {
            // Only add JOIN if not already added by group_by
            let group_join = self.group_by.and_then(|g| g.join_sql());
            let order_join = order_field.join_sql();
            if group_join != order_join
                && let Some(join) = order_join
            {
                filter = filter.join(join);
            }
            let direction = self.order_direction.unwrap_or_default().to_sql();
            order_parts.push(format!("{} {}", order_field.to_sql(), direction));
        }

        // Default: created_at ASC if nothing specified
        let order_by = if order_parts.is_empty() {
            "services.created_at ASC".to_string()
        } else {
            order_parts.join(", ")
        };

        (filter, order_by)
    }
}

impl FilterQueryExtractor for ServiceFilterQuery {
    fn apply_to_filter(
        &self,
        filter: EntityFilter,
        user_network_ids: &[Uuid],
        _user_organization_id: Uuid,
    ) -> EntityFilter {
        // Apply IDs filter first if provided
        let filter = match &self.ids {
            Some(ids) if !ids.is_empty() => filter.entity_ids(ids),
            _ => filter,
        };
        // Apply host filter if provided
        let filter = match self.host_id {
            Some(id) => filter.host_id(&id),
            None => filter,
        };
        // Then apply network filter
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
    crate::crud_get_by_id_handler!(Service, "services", "service");
    crate::crud_delete_handler!(Service, "services", "service");
    crate::crud_bulk_delete_handler!(Service, "services");
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_all_services, create_service))
        .routes(routes!(
            generated::get_by_id,
            update_service,
            generated::delete
        ))
        .routes(routes!(generated::bulk_delete))
}

/// List all services
///
/// Returns all services the authenticated user has access to.
/// Supports pagination via `limit` and `offset` query parameters,
/// and ordering via `group_by`, `order_by`, and `order_direction`.
#[utoipa::path(
    get,
    path = "",
    tag = "services",
    params(ServiceFilterQuery),
    responses(
        (status = 200, description = "List of services", body = PaginatedApiResponse<Service>),
    ),
    security(("user_api_key" = []), ("session" = []))
)]
async fn get_all_services(
    State(state): State<Arc<AppState>>,
    auth: Authorized<Viewer>,
    crate::server::shared::extractors::Query(query): crate::server::shared::extractors::Query<
        ServiceFilterQuery,
    >,
) -> ApiResult<Json<PaginatedApiResponse<Service>>> {
    let network_ids = auth.network_ids();
    let organization_id = auth
        .organization_id()
        .ok_or_else(|| ApiError::forbidden("Organization context required"))?;

    let base_filter = EntityFilter::unfiltered().network_ids(&network_ids);
    let filter = query.apply_to_filter(base_filter, &network_ids, organization_id);

    // Apply pagination
    let pagination = query.pagination();
    let filter = pagination.apply_to_filter(filter);

    // Apply ordering and JOINs
    let (filter, order_by) = query.apply_ordering(filter);

    let result = state
        .services
        .service_service
        .storage()
        .get_paginated(filter, &order_by)
        .await?;

    // Hydrate tags
    let entity_ids: Vec<Uuid> = result.items.iter().map(|s| s.id).collect();
    let tags_map = state
        .services
        .entity_tag_service
        .get_tags_map(
            &entity_ids,
            crate::server::shared::entities::EntityDiscriminants::Service,
        )
        .await?;

    let items: Vec<Service> = result
        .items
        .into_iter()
        .map(|mut service| {
            if let Some(tags) = tags_map.get(&service.id) {
                service.base.tags = tags.clone();
            }
            service
        })
        .collect();

    // Get effective pagination values for response metadata
    let limit = pagination.effective_limit().unwrap_or(0);
    let offset = pagination.effective_offset();

    Ok(Json(PaginatedApiResponse::success(
        items,
        result.total_count,
        limit,
        offset,
    )))
}

/// Create a new service
///
/// Creates a service with optional bindings to interfaces or ports.
/// The `id`, `created_at`, `updated_at`, and `source` fields are generated server-side.
/// Bindings are specified without `service_id` or `network_id` - these are assigned automatically.
///
/// ### Binding Validation Rules
///
/// - **Cross-host validation**: All bindings must reference ports/interfaces that belong to the
///   service's host. Bindings referencing entities from other hosts will be rejected.
/// - **Deduplication**: Duplicate bindings in the same request are automatically deduplicated.
/// - **All-interfaces precedence**: If a port binding with `interface_id: null` (all interfaces)
///   is included, any specific-interface bindings for the same port are automatically removed.
/// - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
///   A port binding on all interfaces conflicts with any interface binding.
#[utoipa::path(
    post,
    path = "",
    tag = "services",
    request_body = CreateServiceRequest,
    responses(
        (status = 200, description = "Service created successfully", body = ApiResponse<Service>),
        (status = 400, description = "Validation error: host network mismatch, cross-host binding, or binding conflict", body = ApiErrorResponse),
    ),
     security(("user_api_key" = []), ("session" = []))
)]
pub async fn create_service(
    State(state): State<Arc<AppState>>,
    auth: Authorized<Member>,
    Json(request): Json<CreateServiceRequest>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    // Validate user has access to the network
    validate_network_access(Some(request.network_id()), &auth.network_ids(), "create")?;

    // Custom validation: Check host network matches service network
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&request.host_id())
        .await?
        && host.base.network_id != request.network_id()
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, Service can't be on a different network ({}).",
            host.base.network_id,
            request.network_id()
        )));
    }

    // Convert request to Service entity
    let service = request.into_service(EntitySource::Manual);

    // Create the service
    let created = state
        .services
        .service_service
        .create(service, auth.into_entity())
        .await?;

    Ok(Json(ApiResponse::success(created)))
}

/// Update a service
///
/// Updates an existing service. All binding validation rules from service creation apply here as well.
///
/// ## Binding Validation Rules
///
/// - **Cross-host validation**: All bindings must reference ports/interfaces that belong to the
///   service's host. Bindings referencing entities from other hosts will be rejected.
/// - **Deduplication**: Duplicate bindings are automatically deduplicated.
/// - **All-interfaces precedence**: If a port binding with `interface_id: null` (all interfaces)
///   is included, any specific-interface bindings for the same port are automatically removed.
/// - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
#[utoipa::path(
    put,
    path = "/{id}",
    tag = "services",
    params(("id" = Uuid, Path, description = "Service ID")),
    request_body = Service,
    responses(
        (status = 200, description = "Service updated", body = ApiResponse<Service>),
        (status = 400, description = "Validation error: host network mismatch, cross-host binding, or binding conflict", body = ApiErrorResponse),
        (status = 404, description = "Service not found", body = ApiErrorResponse),
    ),
     security(("user_api_key" = []), ("session" = []))
)]
pub async fn update_service(
    State(state): State<Arc<AppState>>,
    auth: Authorized<Member>,
    Path(id): Path<Uuid>,
    Json(service): Json<Service>,
) -> ApiResult<Json<ApiResponse<Service>>> {
    // Custom validation: Check host network matches service network
    if let Some(host) = state
        .services
        .host_service
        .get_by_id(&service.base.host_id)
        .await?
        && host.base.network_id != service.base.network_id
    {
        return Err(ApiError::bad_request(&format!(
            "Host is on network {}, Service \"{}\" can't be on a different network ({}).",
            host.base.network_id, service.base.name, service.base.network_id
        )));
    }

    // Delegate to generic handler (handles validation, auth checks, update)
    update_handler::<Service>(State(state), auth, Path(id), Json(service)).await
}
