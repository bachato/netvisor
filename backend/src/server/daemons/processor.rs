use std::sync::Arc;

use anyhow::Result;
use async_trait::async_trait;
use chrono::Utc;
use semver::Version;
use uuid::Uuid;

use crate::{
    daemon::runtime::state::BufferedEntities,
    server::{
        auth::middleware::auth::AuthenticatedEntity,
        daemons::{
            r#impl::{
                api::{
                    DaemonCapabilities, DaemonHeartbeatPayload, DaemonRegistrationRequest,
                    DaemonRegistrationResponse, DiscoveryUpdatePayload, ServerCapabilities,
                },
                base::DaemonMode,
                version::DaemonVersionPolicy,
            },
            service::DaemonService,
        },
        discovery::service::DiscoveryService,
        hosts::service::HostService,
        shared::services::traits::CrudService,
        subnets::service::SubnetService,
    },
};

/// Status data received from a daemon (for ServerPoll mode).
/// Mirrors DaemonHeartbeatPayload with added version field.
#[derive(Debug, Clone)]
pub struct DaemonStatusData {
    pub url: String,
    pub name: String,
    pub mode: DaemonMode,
    pub version: Option<Version>,
}

impl From<DaemonHeartbeatPayload> for DaemonStatusData {
    fn from(payload: DaemonHeartbeatPayload) -> Self {
        Self {
            url: payload.url,
            name: payload.name,
            mode: payload.mode,
            version: None,
        }
    }
}

/// Trait for processing data received from daemons.
/// Used by both incoming handlers (DaemonPoll mode) and the server poller (ServerPoll mode).
///
/// This abstraction allows the same business logic to be used regardless of whether
/// the daemon pushes data to the server or the server polls the daemon.
#[async_trait]
pub trait DaemonDataProcessor: Send + Sync {
    /// Process a heartbeat from a daemon.
    /// Updates the daemon's last_seen timestamp, url, name, and mode.
    async fn process_heartbeat(
        &self,
        daemon_id: Uuid,
        status: DaemonStatusData,
        auth: AuthenticatedEntity,
    ) -> Result<()>;

    /// Process a daemon startup announcement.
    /// Updates the daemon's version and last_seen timestamp.
    /// Returns server capabilities.
    async fn process_startup(
        &self,
        daemon_id: Uuid,
        version: Version,
        auth: AuthenticatedEntity,
    ) -> Result<ServerCapabilities>;

    /// Process a daemon registration request.
    /// Creates the daemon record, host entry, and default discovery jobs.
    async fn process_registration(
        &self,
        request: DaemonRegistrationRequest,
        auth: AuthenticatedEntity,
    ) -> Result<DaemonRegistrationResponse>;

    /// Process a capabilities update from a daemon.
    /// Updates the daemon's capabilities (docker socket, interfaced subnets).
    async fn process_capabilities(
        &self,
        daemon_id: Uuid,
        capabilities: DaemonCapabilities,
        auth: AuthenticatedEntity,
    ) -> Result<()>;

    /// Process a discovery progress update.
    /// Updates the discovery session state and broadcasts to subscribers.
    async fn process_discovery_progress(&self, update: DiscoveryUpdatePayload) -> Result<()>;

    /// Process discovered entities from a daemon.
    /// Creates hosts, subnets, etc. in the database.
    async fn process_discovery_entities(
        &self,
        entities: BufferedEntities,
        auth: AuthenticatedEntity,
    ) -> Result<()>;

    /// Get pending discovery work for a daemon.
    /// Returns the next discovery session to execute, if any.
    async fn get_pending_work(&self, daemon_id: Uuid) -> Option<DiscoveryUpdatePayload>;

    /// Get pending cancellation request for a daemon.
    /// Returns the session ID to cancel, if any.
    async fn get_pending_cancellation(&self, daemon_id: Uuid) -> Option<Uuid>;
}

/// Concrete implementation of DaemonDataProcessor.
/// Delegates to existing services to process daemon data.
pub struct DaemonProcessor {
    daemon_service: Arc<DaemonService>,
    discovery_service: Arc<DiscoveryService>,
    host_service: Arc<HostService>,
    subnet_service: Arc<SubnetService>,
}

impl DaemonProcessor {
    pub fn new(
        daemon_service: Arc<DaemonService>,
        discovery_service: Arc<DiscoveryService>,
        host_service: Arc<HostService>,
        subnet_service: Arc<SubnetService>,
    ) -> Self {
        Self {
            daemon_service,
            discovery_service,
            host_service,
            subnet_service,
        }
    }
}

#[async_trait]
impl DaemonDataProcessor for DaemonProcessor {
    async fn process_heartbeat(
        &self,
        daemon_id: Uuid,
        status: DaemonStatusData,
        auth: AuthenticatedEntity,
    ) -> Result<()> {
        let mut daemon = self
            .daemon_service
            .get_by_id(&daemon_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Daemon {} not found", daemon_id))?;

        daemon.base.last_seen = Utc::now();
        daemon.base.url = status.url;
        daemon.base.name = status.name;
        daemon.base.mode = status.mode;

        // Update version if provided (for ServerPoll mode status responses)
        if let Some(version) = status.version {
            daemon.base.version = Some(version);
        }

        self.daemon_service.update(&mut daemon, auth).await?;
        Ok(())
    }

    async fn process_startup(
        &self,
        daemon_id: Uuid,
        version: Version,
        auth: AuthenticatedEntity,
    ) -> Result<ServerCapabilities> {
        let mut daemon = self
            .daemon_service
            .get_by_id(&daemon_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Daemon {} not found", daemon_id))?;

        daemon.base.version = Some(version.clone());
        daemon.base.last_seen = Utc::now();

        self.daemon_service.update(&mut daemon, auth).await?;

        tracing::info!(
            daemon_id = %daemon_id,
            version = %version,
            "Daemon startup"
        );

        let policy = DaemonVersionPolicy::default();
        let status = policy.evaluate(Some(&version));

        Ok(ServerCapabilities {
            server_version: policy.latest.clone(),
            minimum_daemon_version: policy.minimum_supported.clone(),
            deprecation_warnings: status.warnings,
        })
    }

    async fn process_registration(
        &self,
        _request: DaemonRegistrationRequest,
        _auth: AuthenticatedEntity,
    ) -> Result<DaemonRegistrationResponse> {
        // Registration is complex and involves multiple services (network, org, host, discovery).
        // For now, this is a placeholder - the full implementation will be done in Phase 1.6
        // when we refactor the handlers to use the processor.
        // The register_daemon handler will continue to work directly until then.
        unimplemented!(
            "process_registration should be implemented when refactoring handlers in Phase 1.6"
        )
    }

    async fn process_capabilities(
        &self,
        daemon_id: Uuid,
        capabilities: DaemonCapabilities,
        auth: AuthenticatedEntity,
    ) -> Result<()> {
        tracing::debug!(
            daemon_id = %daemon_id,
            capabilities = %capabilities,
            "Updating daemon capabilities",
        );

        let mut daemon = self
            .daemon_service
            .get_by_id(&daemon_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Daemon {} not found", daemon_id))?;

        daemon.base.capabilities = capabilities;

        self.daemon_service.update(&mut daemon, auth).await?;
        Ok(())
    }

    async fn process_discovery_progress(&self, update: DiscoveryUpdatePayload) -> Result<()> {
        self.discovery_service.update_session(update).await?;
        Ok(())
    }

    async fn process_discovery_entities(
        &self,
        entities: BufferedEntities,
        auth: AuthenticatedEntity,
    ) -> Result<()> {
        // Process each discovered host
        for host_request in entities.hosts {
            self.host_service
                .discover_host(
                    host_request.host,
                    host_request.interfaces,
                    host_request.ports,
                    host_request.services,
                    auth.clone(),
                )
                .await?;
        }

        // Process discovered subnets
        for subnet in entities.subnets {
            self.subnet_service.create(subnet, auth.clone()).await?;
        }

        Ok(())
    }

    async fn get_pending_work(&self, daemon_id: Uuid) -> Option<DiscoveryUpdatePayload> {
        let sessions = self
            .discovery_service
            .get_sessions_for_daemon(&daemon_id)
            .await;
        sessions.first().cloned()
    }

    async fn get_pending_cancellation(&self, daemon_id: Uuid) -> Option<Uuid> {
        let (has_cancellation, session_id) = self
            .discovery_service
            .pull_cancellation_for_daemon(&daemon_id)
            .await;

        if has_cancellation {
            Some(session_id)
        } else {
            None
        }
    }
}
