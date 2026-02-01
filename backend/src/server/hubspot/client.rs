use crate::server::hubspot::types::{
    CompanyProperties, ContactProperties, HubSpotAssociationInput, HubSpotAssociationObject,
    HubSpotAssociationRequest, HubSpotAssociationType, HubSpotFilter, HubSpotFilterGroup,
    HubSpotFormContext, HubSpotFormField, HubSpotObjectResponse, HubSpotSearchRequest,
    HubSpotSearchResponse,
};
use anyhow::{Result, anyhow};
use backon::{ExponentialBuilder, Retryable};
use governor::{Quota, RateLimiter, clock::DefaultClock, state::InMemoryState};
use reqwest::Client;
use serde::Serialize;
use std::{num::NonZeroU32, sync::Arc};

const HUBSPOT_API_BASE: &str = "https://api.hubapi.com";
const HUBSPOT_PORTAL_ID: &str = "50956550";
const HUBSPOT_ENTERPRISE_FORM_ID: &str = "96ece46e-04cb-47fc-bb17-2a8b196f8986";

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

    /// Get companies associated with a contact
    ///
    /// HubSpot may auto-create companies from email domains when contacts are created.
    /// This method retrieves those associations so we can update the existing company
    /// instead of creating duplicates.
    pub async fn get_contact_associated_companies(&self, contact_id: &str) -> Result<Vec<String>> {
        let url = format!(
            "{}/crm/v3/objects/contacts/{}/associations/companies",
            HUBSPOT_API_BASE, contact_id
        );

        let operation = || async {
            self.wait_for_rate_limit().await;

            let response = self
                .client
                .get(&url)
                .header("Authorization", format!("Bearer {}", self.api_key))
                .send()
                .await
                .map_err(|e| anyhow!("HubSpot get associations failed: {}", e))?;

            let status = response.status();

            if status.is_success() {
                #[derive(serde::Deserialize)]
                struct AssociationResult {
                    id: String,
                }
                #[derive(serde::Deserialize)]
                struct AssociationsResponse {
                    results: Vec<AssociationResult>,
                }

                let result: AssociationsResponse = response
                    .json()
                    .await
                    .map_err(|e| anyhow!("Failed to parse HubSpot associations response: {}", e))?;

                return Ok(result.results.into_iter().map(|r| r.id).collect());
            }

            let error_body = response
                .text()
                .await
                .unwrap_or_else(|_| "Unknown error".to_string());

            if Self::is_retryable_error(status) {
                return Err(anyhow!(
                    "HubSpot get associations error (retryable) {}: {}",
                    status,
                    error_body
                ));
            }

            Err(anyhow!(
                "HubSpot get associations error {}: {}",
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

    /// Create or update contact, then ensure company exists and is associated.
    /// Returns the HubSpot company ID to be stored on the organization record.
    ///
    /// This method handles HubSpot's automatic company creation feature:
    /// when a contact is created, HubSpot may auto-create a company based on
    /// the email domain. We retry fetching associated companies to handle
    /// eventual consistency, then either update the auto-created company
    /// or create a new one.
    pub async fn sync_contact_and_company(
        &self,
        contact_properties: ContactProperties,
        company_properties: CompanyProperties,
    ) -> Result<(HubSpotObjectResponse, String)> {
        // Upsert contact
        let contact = self.upsert_contact(contact_properties).await?;

        // Check for auto-created company with retries for eventual consistency.
        // HubSpot may not have indexed the association immediately after contact creation.
        let contact_id = contact.id.clone();
        let get_associated = || async {
            let associated = self.get_contact_associated_companies(&contact_id).await?;
            if let Some(id) = associated.first() {
                Ok(id.clone())
            } else {
                // Return error to trigger retry
                Err(anyhow!("No associated company found yet"))
            }
        };

        let company_id: Option<String> = get_associated
            .retry(
                ExponentialBuilder::default()
                    .with_max_times(3)
                    .with_min_delay(std::time::Duration::from_millis(500))
                    .with_max_delay(std::time::Duration::from_secs(2)),
            )
            .await
            .ok(); // Convert final error to None

        // Update existing or create new company
        let final_company_id = match company_id {
            Some(ref id) => {
                tracing::debug!(
                    contact_id = %contact.id,
                    company_id = %id,
                    "Updating auto-created HubSpot company"
                );
                self.update_company(id, company_properties).await?;
                id.clone()
            }
            None => {
                tracing::debug!(
                    contact_id = %contact.id,
                    "Creating new HubSpot company"
                );
                let company = self.create_company(company_properties).await?;
                self.associate_contact_to_company(&contact.id, &company.id)
                    .await?;
                company.id
            }
        };

        tracing::debug!(
            contact_id = %contact.id,
            company_id = %final_company_id,
            "Successfully synced contact and company to HubSpot"
        );

        Ok((contact, final_company_id))
    }

    /// Submit enterprise inquiry form to HubSpot
    ///
    /// This triggers form submission workflows and email notifications,
    /// unlike the CRM API which only creates/updates records.
    ///
    /// The context includes:
    /// - `hutk`: HubSpot tracking cookie (links submission to visitor)
    /// - `ip_address`: Client IP for analytics
    /// - Legal consent options to mark contact as marketable
    pub async fn submit_enterprise_inquiry_form(
        &self,
        fields: Vec<HubSpotFormField>,
        form_context: HubSpotFormContext,
    ) -> Result<()> {
        let url = format!(
            "https://api.hsforms.com/submissions/v3/integration/submit/{}/{}",
            HUBSPOT_PORTAL_ID, HUBSPOT_ENTERPRISE_FORM_ID
        );

        let mut context = serde_json::json!({
            "pageUri": form_context.page_uri,
            "pageName": form_context.page_name
        });
        if let Some(hutk) = &form_context.hutk {
            context["hutk"] = serde_json::Value::String(hutk.clone());
        }
        if let Some(ip) = &form_context.ip_address {
            context["ipAddress"] = serde_json::Value::String(ip.clone());
        }

        // Legal consent options - marks contact as marketable regardless of hutk
        // This is appropriate because form submission is explicit consent to be contacted
        let legal_consent = serde_json::json!({
            "consent": {
                "consentToProcess": true,
                "text": "I agree to be contacted regarding my inquiry."
            }
        });

        let request_body = serde_json::json!({
            "fields": fields,
            "context": context,
            "legalConsentOptions": legal_consent
        });

        let operation = || async {
            self.wait_for_rate_limit().await;

            let response = self
                .client
                .post(&url)
                .header("Content-Type", "application/json")
                .json(&request_body)
                .send()
                .await
                .map_err(|e| anyhow!("HubSpot form submission failed: {}", e))?;

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
                    "HubSpot form submission error (retryable) {}: {}",
                    status,
                    error_body
                ));
            }

            Err(anyhow!(
                "HubSpot form submission error {}: {}",
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
