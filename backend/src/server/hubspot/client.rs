use crate::server::hubspot::types::{
    CompanyProperties, ContactProperties, HubSpotAssociationInput, HubSpotAssociationObject,
    HubSpotAssociationRequest, HubSpotAssociationType, HubSpotFilter, HubSpotFilterGroup,
    HubSpotObjectResponse, HubSpotSearchRequest, HubSpotSearchResponse,
};
use anyhow::{Result, anyhow};
use backon::{ExponentialBuilder, Retryable};
use governor::{Quota, RateLimiter, clock::DefaultClock, state::InMemoryState};
use reqwest::Client;
use serde::Serialize;
use std::{num::NonZeroU32, sync::Arc};

const HUBSPOT_API_BASE: &str = "https://api.hubapi.com";

/// HubSpot CRM API client with rate limiting and retries
pub struct HubSpotClient {
    client: Client,
    api_key: String,
    rate_limiter: Arc<RateLimiter<governor::state::NotKeyed, InMemoryState, DefaultClock>>,
}

impl HubSpotClient {
    /// Create a new HubSpot client with rate limiting
    pub fn new(api_key: String) -> Self {
        // HubSpot free tier: 100 requests per 10 seconds = 10 req/sec
        // Use conservative limit of 8 req/sec with small burst
        let rate_limiter = Arc::new(RateLimiter::direct(
            Quota::per_second(NonZeroU32::new(8).unwrap()).allow_burst(NonZeroU32::new(3).unwrap()),
        ));

        Self {
            client: Client::new(),
            api_key,
            rate_limiter,
        }
    }

    /// Wait for rate limiter before making a request
    async fn wait_for_rate_limit(&self) {
        self.rate_limiter.until_ready().await;
    }

    /// Check if an error is retryable (429 or 5xx)
    fn is_retryable_error(status: reqwest::StatusCode) -> bool {
        status == reqwest::StatusCode::TOO_MANY_REQUESTS || status.is_server_error()
    }

    /// Make a POST request with rate limiting and retries
    async fn post<T: Serialize + ?Sized>(
        &self,
        path: &str,
        body: &T,
    ) -> Result<HubSpotObjectResponse> {
        let url = format!("{}{}", HUBSPOT_API_BASE, path);

        let operation = || async {
            self.wait_for_rate_limit().await;

            let response = self
                .client
                .post(&url)
                .header("Authorization", format!("Bearer {}", self.api_key))
                .header("Content-Type", "application/json")
                .json(body)
                .send()
                .await
                .map_err(|e| anyhow!("HubSpot request failed: {}", e))?;

            let status = response.status();

            if status.is_success() {
                let result: HubSpotObjectResponse = response
                    .json()
                    .await
                    .map_err(|e| anyhow!("Failed to parse HubSpot response: {}", e))?;
                return Ok(result);
            }

            // Parse error response
            let error_body = response
                .text()
                .await
                .unwrap_or_else(|_| "Unknown error".to_string());

            if Self::is_retryable_error(status) {
                return Err(anyhow!(
                    "HubSpot API error (retryable) {}: {}",
                    status,
                    error_body
                ));
            }

            // Non-retryable error
            Err(anyhow!("HubSpot API error {}: {}", status, error_body))
        };

        operation
            .retry(
                ExponentialBuilder::default()
                    .with_max_times(3)
                    .with_min_delay(std::time::Duration::from_millis(500))
                    .with_max_delay(std::time::Duration::from_secs(10)),
            )
            .when(|e| e.to_string().contains("retryable"))
            .await
    }

    /// Make a PATCH request with rate limiting and retries
    async fn patch<T: Serialize + ?Sized>(
        &self,
        path: &str,
        body: &T,
    ) -> Result<HubSpotObjectResponse> {
        let url = format!("{}{}", HUBSPOT_API_BASE, path);

        let operation = || async {
            self.wait_for_rate_limit().await;

            let response = self
                .client
                .patch(&url)
                .header("Authorization", format!("Bearer {}", self.api_key))
                .header("Content-Type", "application/json")
                .json(body)
                .send()
                .await
                .map_err(|e| anyhow!("HubSpot request failed: {}", e))?;

            let status = response.status();

            if status.is_success() {
                let result: HubSpotObjectResponse = response
                    .json()
                    .await
                    .map_err(|e| anyhow!("Failed to parse HubSpot response: {}", e))?;
                return Ok(result);
            }

            let error_body = response
                .text()
                .await
                .unwrap_or_else(|_| "Unknown error".to_string());

            if Self::is_retryable_error(status) {
                return Err(anyhow!(
                    "HubSpot API error (retryable) {}: {}",
                    status,
                    error_body
                ));
            }

            Err(anyhow!("HubSpot API error {}: {}", status, error_body))
        };

        operation
            .retry(
                ExponentialBuilder::default()
                    .with_max_times(3)
                    .with_min_delay(std::time::Duration::from_millis(500))
                    .with_max_delay(std::time::Duration::from_secs(10)),
            )
            .when(|e| e.to_string().contains("retryable"))
            .await
    }

    /// Search for objects with rate limiting and retries
    async fn search(
        &self,
        object_type: &str,
        request: &HubSpotSearchRequest,
    ) -> Result<HubSpotSearchResponse> {
        let url = format!("{}/crm/v3/objects/{}/search", HUBSPOT_API_BASE, object_type);

        let operation = || async {
            self.wait_for_rate_limit().await;

            let response = self
                .client
                .post(&url)
                .header("Authorization", format!("Bearer {}", self.api_key))
                .header("Content-Type", "application/json")
                .json(request)
                .send()
                .await
                .map_err(|e| anyhow!("HubSpot search failed: {}", e))?;

            let status = response.status();

            if status.is_success() {
                let result: HubSpotSearchResponse = response
                    .json()
                    .await
                    .map_err(|e| anyhow!("Failed to parse HubSpot search response: {}", e))?;
                return Ok(result);
            }

            let error_body = response
                .text()
                .await
                .unwrap_or_else(|_| "Unknown error".to_string());

            if Self::is_retryable_error(status) {
                return Err(anyhow!(
                    "HubSpot search error (retryable) {}: {}",
                    status,
                    error_body
                ));
            }

            Err(anyhow!("HubSpot search error {}: {}", status, error_body))
        };

        operation
            .retry(
                ExponentialBuilder::default()
                    .with_max_times(3)
                    .with_min_delay(std::time::Duration::from_millis(500))
                    .with_max_delay(std::time::Duration::from_secs(10)),
            )
            .when(|e| e.to_string().contains("retryable"))
            .await
    }

    /// Create a contact in HubSpot
    pub async fn create_contact(
        &self,
        properties: ContactProperties,
    ) -> Result<HubSpotObjectResponse> {
        #[derive(Serialize)]
        struct CreateRequest {
            properties: ContactProperties,
        }

        self.post("/crm/v3/objects/contacts", &CreateRequest { properties })
            .await
    }

    /// Update a contact in HubSpot
    pub async fn update_contact(
        &self,
        contact_id: &str,
        properties: ContactProperties,
    ) -> Result<HubSpotObjectResponse> {
        #[derive(Serialize)]
        struct UpdateRequest {
            properties: ContactProperties,
        }

        self.patch(
            &format!("/crm/v3/objects/contacts/{}", contact_id),
            &UpdateRequest { properties },
        )
        .await
    }

    /// Search for a contact by email
    pub async fn find_contact_by_email(
        &self,
        email: &str,
    ) -> Result<Option<HubSpotObjectResponse>> {
        let request = HubSpotSearchRequest {
            filter_groups: vec![HubSpotFilterGroup {
                filters: vec![HubSpotFilter {
                    property_name: "email".to_string(),
                    operator: "EQ".to_string(),
                    value: email.to_string(),
                }],
            }],
            properties: vec!["email".to_string(), "scanopy_user_id".to_string()],
            limit: 1,
        };

        let response = self.search("contacts", &request).await?;
        Ok(response.results.into_iter().next())
    }

    /// Upsert a contact - create if not exists, update if exists (by email)
    pub async fn upsert_contact(
        &self,
        properties: ContactProperties,
    ) -> Result<HubSpotObjectResponse> {
        let email = properties
            .email
            .clone()
            .ok_or_else(|| anyhow!("Email is required for contact upsert"))?;

        match self.find_contact_by_email(&email).await? {
            Some(existing) => {
                tracing::debug!(
                    contact_id = %existing.id,
                    email = %email,
                    "Updating existing HubSpot contact"
                );
                self.update_contact(&existing.id, properties).await
            }
            None => {
                tracing::debug!(
                    email = %email,
                    "Creating new HubSpot contact"
                );
                self.create_contact(properties).await
            }
        }
    }

    /// Create a company in HubSpot
    pub async fn create_company(
        &self,
        properties: CompanyProperties,
    ) -> Result<HubSpotObjectResponse> {
        #[derive(Serialize)]
        struct CreateRequest {
            properties: CompanyProperties,
        }

        self.post("/crm/v3/objects/companies", &CreateRequest { properties })
            .await
    }

    /// Update a company in HubSpot
    pub async fn update_company(
        &self,
        company_id: &str,
        properties: CompanyProperties,
    ) -> Result<HubSpotObjectResponse> {
        #[derive(Serialize)]
        struct UpdateRequest {
            properties: CompanyProperties,
        }

        self.patch(
            &format!("/crm/v3/objects/companies/{}", company_id),
            &UpdateRequest { properties },
        )
        .await
    }

    /// Search for a company by scanopy_org_id
    pub async fn find_company_by_org_id(
        &self,
        org_id: &str,
    ) -> Result<Option<HubSpotObjectResponse>> {
        let request = HubSpotSearchRequest {
            filter_groups: vec![HubSpotFilterGroup {
                filters: vec![HubSpotFilter {
                    property_name: "scanopy_org_id".to_string(),
                    operator: "EQ".to_string(),
                    value: org_id.to_string(),
                }],
            }],
            properties: vec!["name".to_string(), "scanopy_org_id".to_string()],
            limit: 1,
        };

        let response = self.search("companies", &request).await?;
        Ok(response.results.into_iter().next())
    }

    /// Upsert a company - create if not exists, update if exists (by scanopy_org_id)
    pub async fn upsert_company(
        &self,
        properties: CompanyProperties,
    ) -> Result<HubSpotObjectResponse> {
        let org_id = properties
            .scanopy_org_id
            .clone()
            .ok_or_else(|| anyhow!("scanopy_org_id is required for company upsert"))?;

        match self.find_company_by_org_id(&org_id).await? {
            Some(existing) => {
                tracing::debug!(
                    company_id = %existing.id,
                    org_id = %org_id,
                    "Updating existing HubSpot company"
                );
                self.update_company(&existing.id, properties).await
            }
            None => {
                tracing::debug!(
                    org_id = %org_id,
                    "Creating new HubSpot company"
                );
                self.create_company(properties).await
            }
        }
    }

    /// Associate a contact with a company
    pub async fn associate_contact_to_company(
        &self,
        contact_id: &str,
        company_id: &str,
    ) -> Result<()> {
        let url = format!(
            "{}/crm/v4/associations/contacts/companies/batch/create",
            HUBSPOT_API_BASE
        );

        let request = HubSpotAssociationRequest {
            inputs: vec![HubSpotAssociationInput {
                from: HubSpotAssociationObject {
                    id: contact_id.to_string(),
                },
                to: HubSpotAssociationObject {
                    id: company_id.to_string(),
                },
                types: vec![HubSpotAssociationType {
                    association_category: "HUBSPOT_DEFINED".to_string(),
                    // Contact to Company association type ID
                    association_type_id: 1,
                }],
            }],
        };

        let operation = || async {
            self.wait_for_rate_limit().await;

            let response = self
                .client
                .post(&url)
                .header("Authorization", format!("Bearer {}", self.api_key))
                .header("Content-Type", "application/json")
                .json(&request)
                .send()
                .await
                .map_err(|e| anyhow!("HubSpot association failed: {}", e))?;

            let status = response.status();

            if status.is_success() {
                return Ok(());
            }

            let error_body = response
                .text()
                .await
                .unwrap_or_else(|_| "Unknown error".to_string());

            if Self::is_retryable_error(status) {
                return Err(anyhow!(
                    "HubSpot association error (retryable) {}: {}",
                    status,
                    error_body
                ));
            }

            Err(anyhow!(
                "HubSpot association error {}: {}",
                status,
                error_body
            ))
        };

        operation
            .retry(
                ExponentialBuilder::default()
                    .with_max_times(3)
                    .with_min_delay(std::time::Duration::from_millis(500))
                    .with_max_delay(std::time::Duration::from_secs(10)),
            )
            .when(|e| e.to_string().contains("retryable"))
            .await
    }

    /// Create contact, company, and associate them together
    pub async fn upsert_contact_with_company(
        &self,
        contact_properties: ContactProperties,
        company_properties: CompanyProperties,
    ) -> Result<(HubSpotObjectResponse, HubSpotObjectResponse)> {
        // Upsert contact
        let contact = self.upsert_contact(contact_properties).await?;

        // Upsert company
        let company = self.upsert_company(company_properties).await?;

        // Associate contact to company
        self.associate_contact_to_company(&contact.id, &company.id)
            .await?;

        tracing::info!(
            contact_id = %contact.id,
            company_id = %company.id,
            "Successfully synced contact and company to HubSpot"
        );

        Ok((contact, company))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_contact_properties_builder() {
        let props = ContactProperties::new()
            .with_email("test@example.com")
            .with_user_id(uuid::Uuid::nil())
            .with_role("owner")
            .with_signup_source("organic");

        assert_eq!(props.email, Some("test@example.com".to_string()));
        assert_eq!(props.scanopy_user_id, Some(uuid::Uuid::nil().to_string()));
        assert_eq!(props.scanopy_role, Some("owner".to_string()));
        assert_eq!(props.scanopy_signup_source, Some("organic".to_string()));
    }

    #[test]
    fn test_company_properties_builder() {
        let props = CompanyProperties::new()
            .with_name("Acme Inc")
            .with_org_id(uuid::Uuid::nil())
            .with_org_type("company")
            .with_plan_type("pro");

        assert_eq!(props.name, Some("Acme Inc".to_string()));
        assert_eq!(props.scanopy_org_id, Some(uuid::Uuid::nil().to_string()));
        assert_eq!(props.scanopy_org_type, Some("company".to_string()));
        assert_eq!(props.scanopy_plan_type, Some("pro".to_string()));
    }

    #[test]
    fn test_is_retryable_error() {
        use reqwest::StatusCode;

        assert!(HubSpotClient::is_retryable_error(
            StatusCode::TOO_MANY_REQUESTS
        ));
        assert!(HubSpotClient::is_retryable_error(
            StatusCode::INTERNAL_SERVER_ERROR
        ));
        assert!(!HubSpotClient::is_retryable_error(StatusCode::BAD_REQUEST));
        assert!(!HubSpotClient::is_retryable_error(StatusCode::OK));
    }
}
