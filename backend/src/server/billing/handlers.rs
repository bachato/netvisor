use crate::server::auth::middleware::permissions::{Authorized, Owner};
use crate::server::billing::types::api::CreateCheckoutRequest;
use crate::server::billing::types::base::BillingPlan;
use crate::server::config::AppState;
use crate::server::hubspot::types::{CompanyProperties, ContactProperties};
use crate::server::shared::types::ErrorCode;
use crate::server::shared::types::api::{ApiError, ApiResult};
use crate::server::shared::types::api::{ApiErrorResponse, ApiResponse, EmptyApiResponse};
use axum::Json;
use axum::extract::State;
use axum::http::HeaderMap;
use axum::http::header::CACHE_CONTROL;
use axum::response::IntoResponse;
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use utoipa::ToSchema;
use utoipa_axum::{router::OpenApiRouter, routes};

/// Enterprise plan inquiry request
#[derive(Debug, Clone, Serialize, Deserialize, ToSchema)]
pub struct EnterpriseInquiryRequest {
    /// Contact email
    pub email: String,
    /// Contact name
    pub name: String,
    /// Company name
    pub company: String,
    /// Team/company size: 1-10, 11-25, 26-50, 51-100, 101-250, 251-500, 501-1000, 1001+
    pub team_size: String,
    /// Use case description
    pub use_case: String,
    /// Urgency: immediately, 1-3 months, 3-6 months, exploring
    #[serde(default)]
    pub urgency: Option<String>,
    /// Network count: 1-5, 6-20, 21-50, 50+
    #[serde(default)]
    pub network_count: Option<String>,
    /// Plan type being inquired about
    #[serde(default)]
    pub plan_type: Option<String>,
}

pub fn create_router() -> OpenApiRouter<Arc<AppState>> {
    OpenApiRouter::new()
        .routes(routes!(get_billing_plans))
        .routes(routes!(create_checkout_session))
        .routes(routes!(handle_webhook))
        .routes(routes!(create_portal_session))
        .routes(routes!(submit_enterprise_inquiry))
}

/// Get available billing plans
#[utoipa::path(
    get,
    path = "/plans",
    tags = ["billing", "internal"],
    responses(
        (status = 200, description = "List of available billing plans", body = ApiResponse<Vec<BillingPlan>>),
        (status = 400, description = "Billing not enabled", body = ApiErrorResponse),
    ),
     security(("user_api_key" = []), ("session" = []))
)]
async fn get_billing_plans(
    State(state): State<Arc<AppState>>,
    _auth: Authorized<Owner>,
) -> Result<impl IntoResponse, ApiError> {
    if let Some(billing_service) = state.services.billing_service.clone() {
        let plans = billing_service.get_plans();
        Ok((
            [(CACHE_CONTROL, "no-store, no-cache, must-revalidate")],
            Json(ApiResponse::success(plans)),
        ))
    } else {
        Err(ApiError::billing_setup_incomplete())
    }
}

/// Create a checkout session
#[utoipa::path(
    post,
    path = "/checkout",
    tags = ["billing", "internal"],
    request_body = CreateCheckoutRequest,
    responses(
        (status = 200, description = "Checkout session URL", body = ApiResponse<String>),
        (status = 400, description = "Invalid plan or billing not enabled", body = ApiErrorResponse),
    ),
     security(("user_api_key" = []), ("session" = []))
)]
async fn create_checkout_session(
    State(state): State<Arc<AppState>>,
    auth: Authorized<Owner>,
    Json(request): Json<CreateCheckoutRequest>,
) -> ApiResult<Json<ApiResponse<String>>> {
    let organization_id = auth
        .organization_id()
        .ok_or_else(ApiError::organization_required)?;

    // Build success/cancel URLs
    let success_url = format!("{}?session_id={{CHECKOUT_SESSION_ID}}", request.url);
    let cancel_url = format!("{}/billing", request.url);

    if let Some(billing_service) = state.services.billing_service.clone() {
        let current_plans = billing_service.get_plans();

        if !current_plans.contains(&request.plan) {
            return Err(ApiError::validation(ErrorCode::ValidationInvalidFormat {
                field: "plan".to_string(),
            }));
        }

        let session = billing_service
            .create_checkout_session(
                organization_id,
                request.plan,
                success_url,
                cancel_url,
                auth.into_entity(),
            )
            .await?;

        Ok(Json(ApiResponse::success(session.url.unwrap())))
    } else {
        Err(ApiError::billing_setup_incomplete())
    }
}

/// Handle Stripe webhook
///
/// Internal endpoint for Stripe webhook callbacks.
#[utoipa::path(
    post,
    path = "/webhooks",
    tags = ["billing", "internal"],
    responses(
        (status = 200, description = "Webhook processed", body = EmptyApiResponse),
        (status = 400, description = "Invalid signature or billing not enabled", body = ApiErrorResponse),
    )
)]
async fn handle_webhook(
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    body: String,
) -> ApiResult<Json<ApiResponse<()>>> {
    let signature = headers
        .get("stripe-signature")
        .and_then(|v| v.to_str().ok())
        .ok_or_else(|| {
            ApiError::validation(ErrorCode::ValidationRequired {
                field: "stripe-signature".to_string(),
            })
        })?;

    if let Some(billing_service) = &state.services.billing_service {
        billing_service.handle_webhook(&body, signature).await?;
        Ok(Json(ApiResponse::success(())))
    } else {
        Err(ApiError::billing_setup_incomplete())
    }
}

/// Create a billing portal session
#[utoipa::path(
    post,
    path = "/portal",
    tags = ["billing", "internal"],
    request_body = String,
    responses(
        (status = 200, description = "Portal session URL", body = ApiResponse<String>),
        (status = 400, description = "Billing not enabled", body = ApiErrorResponse),
    ),
     security(("user_api_key" = []), ("session" = []))
)]
async fn create_portal_session(
    State(state): State<Arc<AppState>>,
    auth: Authorized<Owner>,
    Json(return_url): Json<String>,
) -> ApiResult<Json<ApiResponse<String>>> {
    let organization_id = auth
        .organization_id()
        .ok_or_else(ApiError::organization_required)?;

    if let Some(billing_service) = &state.services.billing_service {
        let session_url = billing_service
            .create_portal_session(organization_id, return_url)
            .await?;

        Ok(Json(ApiResponse::success(session_url)))
    } else {
        Err(ApiError::billing_setup_incomplete())
    }
}

/// Submit enterprise plan inquiry
///
/// Creates a contact and company in HubSpot for sales follow-up.
/// This endpoint does not require authentication.
#[utoipa::path(
    post,
    path = "/inquiry",
    tags = ["billing", "internal"],
    request_body = EnterpriseInquiryRequest,
    responses(
        (status = 200, description = "Inquiry submitted successfully", body = EmptyApiResponse),
        (status = 400, description = "Invalid request or HubSpot not configured", body = ApiErrorResponse),
    )
)]
async fn submit_enterprise_inquiry(
    State(state): State<Arc<AppState>>,
    Json(request): Json<EnterpriseInquiryRequest>,
) -> ApiResult<Json<ApiResponse<()>>> {
    // Validate required fields
    if request.email.is_empty() || request.name.is_empty() || request.company.is_empty() {
        return Err(ApiError::validation(ErrorCode::ValidationRequired {
            field: "email, name, company".to_string(),
        }));
    }

    // Check if HubSpot is configured
    let hubspot_service = state
        .services
        .hubspot_service
        .as_ref()
        .ok_or_else(|| ApiError::bad_request("Enterprise inquiries are not enabled"))?;

    // Build contact properties
    let mut contact_props = ContactProperties::new()
        .with_email(&request.email)
        .with_signup_source("enterprise_inquiry");

    // Split name into first/last if possible
    let name_parts: Vec<&str> = request.name.split_whitespace().collect();
    if let Some(first) = name_parts.first() {
        contact_props.firstname = Some(first.to_string());
    }
    if name_parts.len() > 1 {
        contact_props.lastname = Some(name_parts[1..].join(" "));
    }

    // Build company properties
    let mut company_props = CompanyProperties::new()
        .with_name(&request.company)
        .with_company_size(&request.team_size);

    // Add optional fields to metadata
    if let Some(urgency) = &request.urgency {
        // Store urgency in a note or custom property
        company_props = company_props.with_org_type(format!("inquiry_urgency:{}", urgency));
    }

    // Sync to HubSpot
    hubspot_service
        .client
        .upsert_contact_with_company(contact_props, company_props)
        .await
        .map_err(|e| {
            tracing::error!(error = %e, "Failed to sync enterprise inquiry to HubSpot");
            ApiError::internal_error("Failed to submit inquiry")
        })?;

    tracing::info!(
        email = %request.email,
        company = %request.company,
        plan_type = ?request.plan_type,
        "Enterprise inquiry submitted to HubSpot"
    );

    Ok(Json(ApiResponse::success(())))
}
