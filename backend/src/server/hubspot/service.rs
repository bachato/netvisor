use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    hosts::{r#impl::base::Host, service::HostService},
    hubspot::{
        client::HubSpotClient,
        types::{CompanyProperties, ContactProperties},
    },
    networks::{r#impl::Network, service::NetworkService},
    organizations::{r#impl::base::Organization, service::OrganizationService},
    shared::{
        events::types::{AuthOperation, Event, TelemetryEvent, TelemetryOperation},
        services::traits::CrudService,
        storage::filter::StorableFilter,
    },
    users::{r#impl::base::User, r#impl::permissions::UserOrgPermissions, service::UserService},
};
use anyhow::Result;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

/// Service for syncing data to HubSpot CRM
pub struct HubSpotService {
    pub client: Arc<HubSpotClient>,
    // Entity services for metrics sync and org updates
    network_service: Arc<NetworkService>,
    host_service: Arc<HostService>,
    user_service: Arc<UserService>,
    organization_service: Arc<OrganizationService>,
}

impl HubSpotService {
    /// Create a new HubSpot service
    pub fn new(
        api_key: String,
        network_service: Arc<NetworkService>,
        host_service: Arc<HostService>,
        user_service: Arc<UserService>,
        organization_service: Arc<OrganizationService>,
    ) -> Self {
        Self {
            client: Arc::new(HubSpotClient::new(api_key)),
            network_service,
            host_service,
            user_service,
            organization_service,
        }
    }

    /// Handle events and sync to HubSpot
    pub async fn handle_event(&self, event: &Event) -> Result<()> {
        match event {
            Event::Telemetry(telemetry) => self.handle_telemetry_event(telemetry).await,
            Event::Auth(auth) => {
                // Handle LoginSuccess for last_login_date tracking
                if auth.operation == AuthOperation::LoginSuccess
                    && let AuthenticatedEntity::User { email, user_id, .. } = &auth.authentication
                {
                    self.update_contact_last_login(email.to_string(), *user_id)
                        .await?;
                }
                Ok(())
            }
            Event::Discovery(discovery) => {
                // Handle discovery phase scanning for last_discovery_date tracking
                if discovery.phase
                    == crate::daemon::discovery::types::base::DiscoveryPhase::Scanning
                {
                    // Get org_id from metadata if available
                    if let Some(org_id) = discovery.metadata.get("organization_id")
                        && let Some(org_id_str) = org_id.as_str()
                        && let Ok(org_id) = Uuid::parse_str(org_id_str)
                    {
                        self.update_company_last_discovery(org_id).await?;
                    }
                }
                Ok(())
            }
            _ => Ok(()),
        }
    }

    /// Handle telemetry events
    async fn handle_telemetry_event(&self, event: &TelemetryEvent) -> Result<()> {
        match &event.operation {
            TelemetryOperation::OrgCreated => {
                self.handle_org_created(event).await?;
            }
            TelemetryOperation::CheckoutStarted => {
                self.handle_checkout_started(event).await?;
            }
            TelemetryOperation::CheckoutCompleted => {
                self.handle_checkout_completed(event).await?;
            }
            TelemetryOperation::TrialStarted => {
                self.handle_trial_started(event).await?;
            }
            TelemetryOperation::TrialEnded => {
                self.handle_trial_ended(event).await?;
            }
            TelemetryOperation::SubscriptionCancelled => {
                self.handle_subscription_cancelled(event).await?;
            }
            TelemetryOperation::FirstDaemonRegistered => {
                self.handle_first_daemon_registered(event).await?;
            }
            TelemetryOperation::FirstTopologyRebuild => {
                self.handle_first_topology_rebuild(event).await?;
            }
            TelemetryOperation::FirstNetworkCreated
            | TelemetryOperation::SecondNetworkCreated
            | TelemetryOperation::FirstDiscoveryCompleted
            | TelemetryOperation::FirstHostDiscovered
            | TelemetryOperation::FirstTagCreated
            | TelemetryOperation::FirstUserApiKeyCreated
            | TelemetryOperation::FirstSnmpCredentialCreated
            | TelemetryOperation::InviteSent
            | TelemetryOperation::InviteAccepted => {
                // These events update engagement metrics on the company
                self.handle_engagement_event(event).await?;
            }
            _ => {}
        }
        Ok(())
    }

    /// Handle org created - create contact and company, store company ID on org
    async fn handle_org_created(&self, event: &TelemetryEvent) -> Result<()> {
        let (email, user_id) = match &event.authentication {
            AuthenticatedEntity::User { email, user_id, .. } => (email.to_string(), *user_id),
            _ => return Ok(()),
        };

        // Extract metadata
        let org_name = event
            .metadata
            .get("org_name")
            .and_then(|v| v.as_str())
            .unwrap_or("Unknown");
        let use_case = event
            .metadata
            .get("use_case")
            .and_then(|v| v.as_str())
            .map(|s| s.to_string());
        let company_size = event
            .metadata
            .get("company_size")
            .and_then(|v| v.as_str())
            .map(|s| s.to_string());
        let job_title = event
            .metadata
            .get("job_title")
            .and_then(|v| v.as_str())
            .map(|s| s.to_string());
        let marketing_opt_in = event
            .metadata
            .get("marketing_opt_in")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);

        // Build contact properties
        let mut contact_props = ContactProperties::new()
            .with_email(&email)
            .with_user_id(user_id)
            .with_org_id(event.organization_id)
            .with_role("owner")
            .with_signup_source("organic")
            .with_signup_date(event.timestamp)
            .with_marketing_opt_in(marketing_opt_in);

        if let Some(use_case) = &use_case {
            contact_props = contact_props.with_use_case(use_case);
        }
        if let Some(title) = job_title {
            contact_props = contact_props.with_jobtitle(title);
        }

        let org_filter = StorableFilter::<Network>::new_from_org_id(&event.organization_id);

        let network_count = self.network_service.get_all(org_filter).await?.len();

        // Build company properties
        let mut company_props = CompanyProperties::new()
            .with_name(org_name)
            .with_org_id(event.organization_id)
            .with_created_date(event.timestamp)
            .with_network_count(network_count as i64)
            .with_host_count(0)
            .with_user_count(1);

        if let Some(use_case) = use_case {
            company_props = company_props.with_org_type(use_case);
        }
        if let Some(size) = company_size {
            company_props = company_props.with_company_size(size);
        }

        // Sync to HubSpot and get the company ID
        let (_contact, company_id) = self
            .client
            .sync_contact_and_company(contact_props, company_props)
            .await?;

        // Store the company ID on the organization
        if let Some(mut org) = self
            .organization_service
            .get_by_id(&event.organization_id)
            .await?
        {
            org.base.hubspot_company_id = Some(company_id.clone());
            self.organization_service
                .update(&mut org, event.authentication.clone())
                .await?;
        }

        tracing::info!(
            organization_id = %event.organization_id,
            hubspot_company_id = %company_id,
            email = %email,
            "Synced new organization to HubSpot"
        );

        Ok(())
    }

    /// Get stored HubSpot company ID for an org, if it exists
    async fn get_hubspot_company_id(&self, org_id: Uuid) -> Result<Option<String>> {
        let org = self.organization_service.get_by_id(&org_id).await?;
        Ok(org.and_then(|o| o.base.hubspot_company_id))
    }

    /// Update HubSpot company using stored ID. Skips if no ID stored.
    async fn update_company_by_org(&self, org_id: Uuid, props: CompanyProperties) -> Result<()> {
        match self.get_hubspot_company_id(org_id).await? {
            Some(id) => {
                self.client.update_company(&id, props).await?;
                Ok(())
            }
            None => {
                tracing::debug!(
                    organization_id = %org_id,
                    "No HubSpot company ID stored - skipping update"
                );
                Ok(())
            }
        }
    }

    /// Handle checkout started
    async fn handle_checkout_started(&self, event: &TelemetryEvent) -> Result<()> {
        // Update company with checkout_started status
        let plan_name = event
            .metadata
            .get("plan_name")
            .and_then(|v| v.as_str())
            .unwrap_or("unknown");

        let company_props = CompanyProperties::new().with_plan_status("checkout_started");

        self.update_company_by_org(event.organization_id, company_props)
            .await?;

        tracing::debug!(
            organization_id = %event.organization_id,
            plan = %plan_name,
            "Updated HubSpot company: checkout started"
        );

        Ok(())
    }

    /// Handle checkout completed
    async fn handle_checkout_completed(&self, event: &TelemetryEvent) -> Result<()> {
        let plan_name = event
            .metadata
            .get("plan_name")
            .and_then(|v| v.as_str())
            .unwrap_or("unknown");
        let has_trial = event
            .metadata
            .get("has_trial")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);

        // Update company with plan info and conversion date
        let company_props = CompanyProperties::new()
            .with_plan_type(plan_name)
            .with_plan_status(if has_trial { "trialing" } else { "active" })
            .with_checkout_completed_date(event.timestamp);

        self.update_company_by_org(event.organization_id, company_props)
            .await?;

        // Sync plan limits to HubSpot
        let network_limit = event
            .metadata
            .get("included_networks")
            .and_then(|v| v.as_u64())
            .map(|n| n as i64);
        let seat_limit = event
            .metadata
            .get("included_seats")
            .and_then(|v| v.as_u64())
            .map(|n| n as i64);

        if network_limit.is_some() || seat_limit.is_some() {
            self.sync_plan_limits(event.organization_id, network_limit, seat_limit)
                .await?;
        }

        tracing::info!(
            organization_id = %event.organization_id,
            plan = %plan_name,
            "Updated HubSpot: checkout completed"
        );

        Ok(())
    }

    /// Handle trial started
    async fn handle_trial_started(&self, event: &TelemetryEvent) -> Result<()> {
        // Update company with trial start date and status
        let company_props = CompanyProperties::new()
            .with_plan_status("trialing")
            .with_trial_started_date(event.timestamp);

        self.update_company_by_org(event.organization_id, company_props)
            .await?;

        tracing::debug!(
            organization_id = %event.organization_id,
            "Updated HubSpot: trial started"
        );

        Ok(())
    }

    /// Handle trial ended
    async fn handle_trial_ended(&self, event: &TelemetryEvent) -> Result<()> {
        let converted = event
            .metadata
            .get("converted")
            .and_then(|v| v.as_bool())
            .unwrap_or(false);

        let company_props = CompanyProperties::new().with_plan_status(if converted {
            "active"
        } else {
            "trial_ended"
        });

        self.update_company_by_org(event.organization_id, company_props)
            .await?;

        tracing::debug!(
            organization_id = %event.organization_id,
            converted = %converted,
            "Updated HubSpot: trial ended"
        );

        Ok(())
    }

    /// Handle subscription cancelled
    async fn handle_subscription_cancelled(&self, event: &TelemetryEvent) -> Result<()> {
        let company_props = CompanyProperties::new().with_plan_status("cancelled");

        self.update_company_by_org(event.organization_id, company_props)
            .await?;

        tracing::debug!(
            organization_id = %event.organization_id,
            "Updated HubSpot: subscription cancelled"
        );

        Ok(())
    }

    /// Handle first daemon registered
    async fn handle_first_daemon_registered(&self, event: &TelemetryEvent) -> Result<()> {
        let company_props = CompanyProperties::new().with_first_daemon_date(event.timestamp);

        self.update_company_by_org(event.organization_id, company_props)
            .await?;

        tracing::debug!(
            organization_id = %event.organization_id,
            "Updated HubSpot: first daemon registered"
        );

        Ok(())
    }

    /// Handle first topology rebuild (first discovery completed)
    async fn handle_first_topology_rebuild(&self, event: &TelemetryEvent) -> Result<()> {
        let company_props = CompanyProperties::new().with_first_discovery_date(event.timestamp);

        self.update_company_by_org(event.organization_id, company_props)
            .await?;

        tracing::debug!(
            organization_id = %event.organization_id,
            "Updated HubSpot: first discovery completed"
        );

        Ok(())
    }

    /// Handle engagement events (update company milestone dates)
    async fn handle_engagement_event(&self, event: &TelemetryEvent) -> Result<()> {
        let mut company_props = CompanyProperties::new();

        // Set the appropriate milestone date based on event type
        match &event.operation {
            TelemetryOperation::FirstNetworkCreated => {
                company_props = company_props.with_first_network_date(event.timestamp);
            }
            TelemetryOperation::FirstTagCreated => {
                company_props = company_props.with_first_tag_date(event.timestamp);
            }
            TelemetryOperation::FirstUserApiKeyCreated => {
                company_props = company_props.with_first_api_key_date(event.timestamp);
            }
            TelemetryOperation::FirstSnmpCredentialCreated => {
                company_props = company_props.with_first_snmp_credential_date(event.timestamp);
            }
            TelemetryOperation::InviteSent => {
                company_props = company_props.with_first_invite_sent_date(event.timestamp);
            }
            TelemetryOperation::InviteAccepted => {
                company_props = company_props.with_first_invite_accepted_date(event.timestamp);
            }
            // These events are tracked but don't have dedicated date properties
            TelemetryOperation::SecondNetworkCreated
            | TelemetryOperation::FirstDiscoveryCompleted
            | TelemetryOperation::FirstHostDiscovered => {
                tracing::debug!(
                    organization_id = %event.organization_id,
                    operation = %event.operation,
                    "HubSpot: engagement event received (no dedicated property)"
                );
                return Ok(());
            }
            _ => return Ok(()),
        }

        self.update_company_by_org(event.organization_id, company_props)
            .await?;

        tracing::debug!(
            organization_id = %event.organization_id,
            operation = %event.operation,
            "Updated HubSpot company: engagement milestone"
        );

        Ok(())
    }

    /// Update contact's last login date
    async fn update_contact_last_login(&self, email: String, user_id: Uuid) -> Result<()> {
        let contact_props = ContactProperties::new()
            .with_email(&email)
            .with_user_id(user_id)
            .with_last_login_date(Utc::now());

        self.client.upsert_contact(contact_props).await?;

        tracing::debug!(
            email = %email,
            "Updated HubSpot contact: last login"
        );

        Ok(())
    }

    /// Update company's last discovery date
    async fn update_company_last_discovery(&self, org_id: Uuid) -> Result<()> {
        let company_props = CompanyProperties::new().with_last_discovery_date(Utc::now());

        self.update_company_by_org(org_id, company_props).await?;

        tracing::debug!(
            organization_id = %org_id,
            "Updated HubSpot company: last discovery"
        );

        Ok(())
    }

    /// Sync organization metrics to HubSpot company
    pub async fn sync_organization_metrics(
        &self,
        org_id: Uuid,
        network_count: i64,
        host_count: i64,
        user_count: i64,
    ) -> Result<()> {
        let company_props = CompanyProperties::new()
            .with_network_count(network_count)
            .with_host_count(host_count)
            .with_user_count(user_count);

        self.update_company_by_org(org_id, company_props).await?;

        tracing::debug!(
            organization_id = %org_id,
            networks = %network_count,
            hosts = %host_count,
            users = %user_count,
            "Synced organization metrics to HubSpot"
        );

        Ok(())
    }

    /// Sync plan limits to HubSpot for computed metrics
    pub async fn sync_plan_limits(
        &self,
        org_id: Uuid,
        network_limit: Option<i64>,
        seat_limit: Option<i64>,
    ) -> Result<()> {
        let mut company_props = CompanyProperties::new();

        if let Some(limit) = network_limit {
            company_props = company_props.with_network_limit(limit);
        }
        if let Some(limit) = seat_limit {
            company_props = company_props.with_seat_limit(limit);
        }

        self.update_company_by_org(org_id, company_props).await?;

        tracing::debug!(
            organization_id = %org_id,
            network_limit = ?network_limit,
            seat_limit = ?seat_limit,
            "Synced plan limits to HubSpot"
        );

        Ok(())
    }

    /// Sync entity counts for an organization to HubSpot
    /// Called when networks, hosts, or users are created/deleted
    pub async fn sync_org_entity_metrics(&self, org_id: Uuid) -> Result<()> {
        // Check if we have a stored HubSpot company ID - skip if not synced yet
        if self.get_hubspot_company_id(org_id).await?.is_none() {
            tracing::debug!(
                organization_id = %org_id,
                "Skipping HubSpot metrics sync - no company ID stored"
            );
            return Ok(());
        }

        // Count entities using service layer
        let network_filter = StorableFilter::<Network>::new_from_org_id(&org_id);
        let networks = self.network_service.get_all(network_filter).await?;
        let network_ids: Vec<Uuid> = networks.iter().map(|n| n.id).collect();
        let network_count = networks.len() as i64;

        let host_filter = StorableFilter::<Host>::new_from_network_ids(&network_ids);
        let hosts = self.host_service.get_all(host_filter).await?;
        let host_count = hosts.len() as i64;

        let user_filter = StorableFilter::new_from_org_id(&org_id);
        let users = self.user_service.get_all(user_filter).await?;
        let user_count = users.len() as i64;

        // Sync to HubSpot
        self.sync_organization_metrics(org_id, network_count, host_count, user_count)
            .await?;

        Ok(())
    }

    /// Get org_id from a network_id by looking up the network
    pub async fn get_org_id_from_network(&self, network_id: &Uuid) -> Option<Uuid> {
        if let Ok(Some(network)) = self.network_service.get_by_id(network_id).await {
            Some(network.base.organization_id)
        } else {
            None
        }
    }

    /// Sync all organizations that don't have a HubSpot company ID.
    /// Called on server startup.
    pub async fn sync_existing_organizations(&self) -> Result<()> {
        tracing::info!("Starting HubSpot organization sync check");

        let filter = StorableFilter::<Organization>::new_without_hubspot_company_id();
        let orgs = self.organization_service.get_all(filter).await?;

        if orgs.is_empty() {
            tracing::info!("All organizations have HubSpot company IDs");
            return Ok(());
        }

        tracing::info!(
            count = orgs.len(),
            "Syncing existing organizations to HubSpot"
        );

        for org in orgs {
            tracing::info!(
                organization_id = %org.id,
                org_name = %org.base.name,
                "Syncing organization to HubSpot"
            );
            if let Err(e) = self.sync_organization(org).await {
                tracing::error!(
                    error = %e,
                    "Failed to sync organization to HubSpot"
                );
                // Continue with other orgs
            }
        }

        tracing::info!("HubSpot organization sync check complete");

        Ok(())
    }

    /// Sync a single organization to HubSpot
    async fn sync_organization(&self, mut org: Organization) -> Result<()> {
        // Get the owner user for this org
        let filter = StorableFilter::<User>::new_from_org_id(&org.id)
            .user_permissions(&UserOrgPermissions::Owner);
        let owners = self.user_service.get_all(filter).await?;
        let owner = owners
            .first()
            .ok_or_else(|| anyhow::anyhow!("No owner found for organization {}", org.id))?;

        // Build properties
        let contact_props = ContactProperties::new()
            .with_email(owner.base.email.to_string())
            .with_user_id(owner.id)
            .with_org_id(org.id)
            .with_role("owner");

        let company_props = CompanyProperties::new()
            .with_name(&org.base.name)
            .with_org_id(org.id)
            .with_created_date(org.created_at);

        // Sync and get company ID
        let (_contact, company_id) = self
            .client
            .sync_contact_and_company(contact_props, company_props)
            .await?;

        // Store the company ID
        org.base.hubspot_company_id = Some(company_id.clone());
        self.organization_service
            .update(&mut org, AuthenticatedEntity::System)
            .await?;

        tracing::info!(
            organization_id = %org.id,
            hubspot_company_id = %company_id,
            "Synced existing organization to HubSpot"
        );

        Ok(())
    }
}
