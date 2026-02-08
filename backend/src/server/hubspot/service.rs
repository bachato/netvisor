use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    daemons::{r#impl::base::Daemon, service::DaemonService},
    hosts::{r#impl::base::Host, service::HostService},
    hubspot::{
        client::HubSpotClient,
        freemail::is_work_email,
        types::{CompanyProperties, ContactProperties},
    },
    networks::{r#impl::Network, service::NetworkService},
    organizations::{r#impl::base::Organization, service::OrganizationService},
    shared::{
        events::types::{AuthOperation, Event, TelemetryEvent, TelemetryOperation},
        services::traits::CrudService,
        storage::filter::StorableFilter,
    },
    snmp_credentials::{r#impl::base::SnmpCredential, service::SnmpCredentialService},
    tags::{r#impl::base::Tag, service::TagService},
    user_api_keys::{r#impl::base::UserApiKey, service::UserApiKeyService},
    users::{r#impl::base::User, r#impl::permissions::UserOrgPermissions, service::UserService},
};
use anyhow::Result;
use chrono::Utc;
use email_address::EmailAddress;
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
    // Additional services for telemetry backfill
    daemon_service: Arc<DaemonService>,
    tag_service: Arc<TagService>,
    user_api_key_service: Arc<UserApiKeyService>,
    snmp_credential_service: Arc<SnmpCredentialService>,
}

impl HubSpotService {
    /// Create a new HubSpot service
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        api_key: String,
        network_service: Arc<NetworkService>,
        host_service: Arc<HostService>,
        user_service: Arc<UserService>,
        organization_service: Arc<OrganizationService>,
        daemon_service: Arc<DaemonService>,
        tag_service: Arc<TagService>,
        user_api_key_service: Arc<UserApiKeyService>,
        snmp_credential_service: Arc<SnmpCredentialService>,
    ) -> Self {
        Self {
            client: Arc::new(HubSpotClient::new(api_key)),
            network_service,
            host_service,
            user_service,
            organization_service,
            daemon_service,
            tag_service,
            user_api_key_service,
            snmp_credential_service,
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

    /// Check if an organization should be synced to HubSpot.
    /// Only sync organizations with commercial plans OR business email domains.
    fn should_sync_to_hubspot(&self, org: &Organization, owner_email: &EmailAddress) -> bool {
        // Commercial plans always sync
        if let Some(plan) = &org.base.plan
            && plan.is_commercial()
        {
            return true;
        }
        // Work/business email domains sync (not Gmail, Yahoo, etc.)
        is_work_email(owner_email)
    }

    /// Handle org created - create contact and company, store company ID on org
    async fn handle_org_created(&self, event: &TelemetryEvent) -> Result<()> {
        let (email, user_id) = match &event.authentication {
            AuthenticatedEntity::User { email, user_id, .. } => (email.clone(), *user_id),
            _ => return Ok(()),
        };

        // Get the organization to check eligibility
        let org = match self
            .organization_service
            .get_by_id(&event.organization_id)
            .await?
        {
            Some(org) => org,
            None => return Ok(()),
        };

        // Check if this org should be synced to HubSpot
        if !self.should_sync_to_hubspot(&org, &email) {
            tracing::debug!(
                organization_id = %event.organization_id,
                email = %email,
                "Skipping HubSpot sync - non-commercial org with free email domain"
            );
            return Ok(());
        }

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
        let referral_source = event
            .metadata
            .get("referral_source")
            .and_then(|v| v.as_str())
            .map(|s| s.to_string());
        let referral_source_other = event
            .metadata
            .get("referral_source_other")
            .and_then(|v| v.as_str())
            .map(|s| s.to_string());

        // Format referral source for HubSpot (combine "other" with free text)
        let formatted_referral_source = referral_source.map(|source| {
            if source == "other" {
                if let Some(ref other_text) = referral_source_other {
                    format!("other: {}", other_text)
                } else {
                    source
                }
            } else {
                source
            }
        });

        // Build contact properties
        let mut contact_props = ContactProperties::new()
            .with_email(email.to_string())
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
        if let Some(ref source) = formatted_referral_source {
            contact_props = contact_props.with_referral_source(source);
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
        if let Some(source) = formatted_referral_source {
            company_props = company_props.with_referral_source(source);
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

    /// Sync all organizations to HubSpot on server startup.
    /// This performs two operations:
    /// 1. Flag and clear non-commercial orgs that were already synced (before filtering)
    /// 2. Sync eligible orgs that don't have HubSpot IDs yet (with backfilled telemetry)
    pub async fn sync_existing_organizations(&self) -> Result<()> {
        tracing::info!("Starting HubSpot organization sync");

        // Step 1: Flag and clear non-commercial orgs that were already synced
        self.cleanup_non_commercial_hubspot_records().await?;

        // Step 2: Sync eligible orgs without HubSpot IDs
        self.sync_eligible_organizations().await?;

        tracing::info!("HubSpot organization sync complete");

        Ok(())
    }

    /// Flag non-commercial orgs in HubSpot and clear their hubspot_company_id.
    /// This allows bulk-deleting these records in HubSpot.
    async fn cleanup_non_commercial_hubspot_records(&self) -> Result<()> {
        let filter = StorableFilter::<Organization>::new_with_hubspot_company_id();
        let orgs = self.organization_service.get_all(filter).await?;

        let mut flagged_count = 0;

        for org in orgs {
            // Get the owner user for this org
            let filter = StorableFilter::<User>::new_from_org_id(&org.id)
                .user_permissions(&UserOrgPermissions::Owner);
            let owners = self.user_service.get_all(filter).await?;

            let owner = match owners.first() {
                Some(owner) => owner,
                None => {
                    tracing::warn!(
                        organization_id = %org.id,
                        "No owner found for organization during cleanup"
                    );
                    continue;
                }
            };

            // Check if this is a non-commercial org that should not be synced
            if self.should_sync_to_hubspot(&org, &owner.base.email) {
                // This org is eligible - skip cleanup
                continue;
            }

            // Flag the HubSpot record as non-commercial
            if let Some(hubspot_id) = &org.base.hubspot_company_id {
                let company_props = CompanyProperties::new().with_non_commercial(true);

                if let Err(e) = self.client.update_company(hubspot_id, company_props).await {
                    tracing::warn!(
                        organization_id = %org.id,
                        hubspot_company_id = %hubspot_id,
                        error = %e,
                        "Failed to flag non-commercial org in HubSpot"
                    );
                    continue;
                }

                // Clear the hubspot_company_id from the org so it won't be synced again
                let mut org = org.clone();
                org.base.hubspot_company_id = None;
                if let Err(e) = self
                    .organization_service
                    .update(&mut org, AuthenticatedEntity::System)
                    .await
                {
                    tracing::error!(
                        organization_id = %org.id,
                        error = %e,
                        "Failed to clear hubspot_company_id from non-commercial org"
                    );
                    continue;
                }

                tracing::info!(
                    organization_id = %org.id,
                    hubspot_company_id = %hubspot_id,
                    email = %owner.base.email,
                    "Flagged non-commercial org in HubSpot and cleared ID"
                );
                flagged_count += 1;
            }
        }

        if flagged_count > 0 {
            tracing::info!(
                count = flagged_count,
                "Flagged and cleared non-commercial orgs from HubSpot"
            );
        }

        Ok(())
    }

    /// Sync eligible organizations (commercial plan OR work email) that don't have HubSpot IDs.
    async fn sync_eligible_organizations(&self) -> Result<()> {
        let filter = StorableFilter::<Organization>::new_without_hubspot_company_id();
        let orgs = self.organization_service.get_all(filter).await?;

        if orgs.is_empty() {
            tracing::info!("All eligible organizations have HubSpot company IDs");
            return Ok(());
        }

        let mut synced_count = 0;
        let mut skipped_count = 0;

        for org in orgs {
            // Get the owner user for this org
            let filter = StorableFilter::<User>::new_from_org_id(&org.id)
                .user_permissions(&UserOrgPermissions::Owner);
            let owners = self.user_service.get_all(filter).await?;

            let owner = match owners.first() {
                Some(owner) => owner,
                None => {
                    tracing::warn!(
                        organization_id = %org.id,
                        "No owner found for organization"
                    );
                    continue;
                }
            };

            // Check if this org should be synced to HubSpot
            if !self.should_sync_to_hubspot(&org, &owner.base.email) {
                tracing::debug!(
                    organization_id = %org.id,
                    email = %owner.base.email,
                    "Skipping non-commercial org with free email domain"
                );
                skipped_count += 1;
                continue;
            }

            tracing::info!(
                organization_id = %org.id,
                org_name = %org.base.name,
                "Syncing organization to HubSpot with backfilled telemetry"
            );

            if let Err(e) = self.sync_organization_with_backfill(org, owner).await {
                tracing::error!(
                    error = %e,
                    "Failed to sync organization to HubSpot"
                );
                // Continue with other orgs
            } else {
                synced_count += 1;
            }
        }

        tracing::info!(
            synced = synced_count,
            skipped = skipped_count,
            "Completed syncing eligible organizations"
        );

        Ok(())
    }

    /// Sync a single organization to HubSpot with backfilled telemetry data.
    async fn sync_organization_with_backfill(
        &self,
        mut org: Organization,
        owner: &User,
    ) -> Result<()> {
        // Build contact properties
        let contact_props = ContactProperties::new()
            .with_email(owner.base.email.to_string())
            .with_user_id(owner.id)
            .with_org_id(org.id)
            .with_role("owner")
            .with_signup_date(owner.created_at);

        // Build company properties with backfilled telemetry
        let mut company_props = CompanyProperties::new()
            .with_name(&org.base.name)
            .with_org_id(org.id)
            .with_created_date(org.created_at);

        // Backfill telemetry data
        company_props = self
            .backfill_company_telemetry(org.id, company_props)
            .await?;

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
            "Synced organization to HubSpot with backfilled telemetry"
        );

        Ok(())
    }

    /// Backfill telemetry/onboarding fields for an organization's HubSpot company.
    async fn backfill_company_telemetry(
        &self,
        org_id: Uuid,
        mut props: CompanyProperties,
    ) -> Result<CompanyProperties> {
        // Get networks for this org
        let network_filter = StorableFilter::<Network>::new_from_org_id(&org_id);
        let networks = self.network_service.get_all(network_filter).await?;
        let network_ids: Vec<Uuid> = networks.iter().map(|n| n.id).collect();
        let network_count = networks.len() as i64;

        // First network date
        if let Some(first_network) = networks.iter().min_by_key(|n| n.created_at) {
            props = props.with_first_network_date(first_network.created_at);
        }

        // Get hosts count
        let host_filter = StorableFilter::<Host>::new_from_network_ids(&network_ids);
        let hosts = self.host_service.get_all(host_filter).await?;
        let host_count = hosts.len() as i64;

        // Get users count
        let user_filter = StorableFilter::<User>::new_from_org_id(&org_id);
        let users = self.user_service.get_all(user_filter).await?;
        let user_count = users.len() as i64;

        props = props
            .with_network_count(network_count)
            .with_host_count(host_count)
            .with_user_count(user_count);

        // First daemon date
        let daemon_filter = StorableFilter::<Daemon>::new_from_network_ids(&network_ids);
        let daemons = self.daemon_service.get_all(daemon_filter).await?;
        if let Some(first_daemon) = daemons.iter().min_by_key(|d| d.created_at) {
            props = props.with_first_daemon_date(first_daemon.created_at);
        }

        // First tag date
        let tag_filter = StorableFilter::<Tag>::new_from_org_id(&org_id);
        let tags = self.tag_service.get_all(tag_filter).await?;
        if let Some(first_tag) = tags.iter().min_by_key(|t| t.created_at) {
            props = props.with_first_tag_date(first_tag.created_at);
        }

        // First API key date (user API keys)
        let api_key_filter = StorableFilter::<UserApiKey>::new_from_org_id(&org_id);
        let api_keys = self.user_api_key_service.get_all(api_key_filter).await?;
        if let Some(first_api_key) = api_keys.iter().min_by_key(|k| k.created_at) {
            props = props.with_first_api_key_date(first_api_key.created_at);
        }

        // First SNMP credential date
        let snmp_filter = StorableFilter::<SnmpCredential>::new_from_network_ids(&network_ids);
        let snmp_creds = self.snmp_credential_service.get_all(snmp_filter).await?;
        if let Some(first_snmp) = snmp_creds.iter().min_by_key(|s| s.created_at) {
            props = props.with_first_snmp_credential_date(first_snmp.created_at);
        }

        Ok(props)
    }
}
