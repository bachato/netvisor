//! Server-side daemon poller for ServerPoll mode.
//!
//! In ServerPoll mode, the server is responsible for:
//! - Polling daemon status via GET /api/status
//! - Polling discovery progress and entities via GET /api/poll
//! - Initiating discovery via POST /api/discovery/initiate
//! - Cancelling discovery via POST /api/discovery/cancel
//!
//! This poller runs as a background task and polls all ServerPoll-mode daemons
//! at a configurable interval (default: 30 seconds).

use std::sync::Arc;
use std::time::Duration;

use anyhow::Result;
use secrecy::ExposeSecret;
use uuid::Uuid;

use crate::daemon::runtime::state::{DaemonStatus, DiscoveryPollResponse};
use crate::server::auth::middleware::auth::AuthenticatedEntity;
use crate::server::config::AppState;
use crate::server::daemons::r#impl::api::{
    DaemonDiscoveryRequest, DaemonDiscoveryResponse, DiscoveryUpdatePayload,
};
use crate::server::daemons::r#impl::base::{Daemon, DaemonMode};
use crate::server::daemons::processor::DaemonDataProcessor;
use crate::server::shared::services::traits::CrudService;
use crate::server::shared::storage::filter::StorableFilter;
use crate::server::shared::types::api::ApiResponse;

/// Default polling interval in seconds
const DEFAULT_POLL_INTERVAL_SECS: u64 = 30;

/// DaemonPoller handles background polling of ServerPoll-mode daemons.
pub struct DaemonPoller {
    state: Arc<AppState>,
    processor: Arc<dyn DaemonDataProcessor>,
    poll_interval: Duration,
    client: reqwest::Client,
}

impl DaemonPoller {
    /// Create a new DaemonPoller with default poll interval.
    pub fn new(state: Arc<AppState>, processor: Arc<dyn DaemonDataProcessor>) -> Self {
        Self {
            state,
            processor,
            poll_interval: Duration::from_secs(DEFAULT_POLL_INTERVAL_SECS),
            client: reqwest::Client::builder()
                .timeout(Duration::from_secs(10))
                .build()
                .expect("Failed to create HTTP client"),
        }
    }

    /// Create a new DaemonPoller with custom poll interval.
    pub fn with_interval(
        state: Arc<AppState>,
        processor: Arc<dyn DaemonDataProcessor>,
        poll_interval: Duration,
    ) -> Self {
        Self {
            state,
            processor,
            poll_interval,
            client: reqwest::Client::builder()
                .timeout(Duration::from_secs(10))
                .build()
                .expect("Failed to create HTTP client"),
        }
    }

    /// Run the polling loop. This should be spawned as a background task.
    pub async fn run_polling_loop(self: Arc<Self>) {
        let mut interval = tokio::time::interval(self.poll_interval);
        interval.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Skip);

        loop {
            interval.tick().await;

            if let Err(e) = self.poll_all_daemons().await {
                tracing::warn!("Daemon poller cycle failed: {}", e);
            }
        }
    }

    /// Poll all ServerPoll-mode daemons.
    async fn poll_all_daemons(&self) -> Result<()> {
        let daemons = self.get_server_poll_daemons().await?;

        if daemons.is_empty() {
            tracing::trace!("No ServerPoll daemons to poll");
            return Ok(());
        }

        tracing::debug!("Polling {} ServerPoll daemons", daemons.len());

        for daemon in daemons {
            if let Err(e) = self.poll_daemon(&daemon).await {
                tracing::warn!(
                    daemon_id = %daemon.id,
                    daemon_name = %daemon.base.name,
                    "Failed to poll daemon: {}",
                    e
                );
            }
        }

        Ok(())
    }

    /// Get all daemons in ServerPoll mode.
    async fn get_server_poll_daemons(&self) -> Result<Vec<Daemon>> {
        let filter = StorableFilter::<Daemon>::default();

        let all_daemons = self.state.services.daemon_service.get_all(filter).await?;

        // Filter to only ServerPoll mode daemons
        let server_poll_daemons: Vec<Daemon> = all_daemons
            .into_iter()
            .filter(|d| d.base.mode == DaemonMode::ServerPoll)
            .collect();

        Ok(server_poll_daemons)
    }

    /// Poll a single daemon for status and discovery data.
    async fn poll_daemon(&self, daemon: &Daemon) -> Result<()> {
        // Get the API key for this daemon
        let api_key = self.get_daemon_api_key(daemon).await?;

        // Poll status
        match self.poll_status(daemon, &api_key).await {
            Ok(status) => {
                // Process status update
                let status_data = crate::server::daemons::processor::DaemonStatusData {
                    url: status.url.clone(),
                    name: status.name.clone(),
                    mode: status.mode,
                    version: status.version.clone(),
                };

                // Create system auth for processing
                let auth = AuthenticatedEntity::System;

                if let Err(e) = self
                    .processor
                    .process_heartbeat(daemon.id, status_data, auth.clone())
                    .await
                {
                    tracing::warn!(
                        daemon_id = %daemon.id,
                        "Failed to process daemon status: {}",
                        e
                    );
                }

                // If daemon has a version and we haven't recorded it yet, process startup
                if let Some(version) = status.version
                    && daemon.base.version.is_none()
                    && let Err(e) = self
                        .processor
                        .process_startup(daemon.id, version, auth.clone())
                        .await
                {
                    tracing::warn!(
                        daemon_id = %daemon.id,
                        "Failed to process daemon startup: {}",
                        e
                    );
                }
            }
            Err(e) => {
                tracing::debug!(
                    daemon_id = %daemon.id,
                    url = %daemon.base.url,
                    "Failed to poll daemon status: {}",
                    e
                );
                return Err(e);
            }
        }

        // Poll discovery data
        match self.poll_discovery(daemon, &api_key).await {
            Ok(poll_response) => {
                let auth = AuthenticatedEntity::System;

                // Process progress update if available
                if let Some(progress) = poll_response.progress
                    && let Err(e) = self.processor.process_discovery_progress(progress).await
                {
                    tracing::warn!(
                        daemon_id = %daemon.id,
                        "Failed to process discovery progress: {}",
                        e
                    );
                }

                // Process entities if any
                if !poll_response.entities.is_empty()
                    && let Err(e) = self
                        .processor
                        .process_discovery_entities(poll_response.entities, auth.clone())
                        .await
                {
                    tracing::warn!(
                        daemon_id = %daemon.id,
                        "Failed to process discovery entities: {}",
                        e
                    );
                }
            }
            Err(e) => {
                tracing::debug!(
                    daemon_id = %daemon.id,
                    "Failed to poll daemon discovery: {}",
                    e
                );
            }
        }

        // Check for pending work and initiate if available
        if let Some(work) = self.processor.get_pending_work(daemon.id).await {
            if let Err(e) = self.initiate_discovery(daemon, &api_key, work).await {
                tracing::warn!(
                    daemon_id = %daemon.id,
                    "Failed to initiate discovery: {}",
                    e
                );
            }
        }

        // Check for pending cancellation
        if let Some(session_id) = self.processor.get_pending_cancellation(daemon.id).await {
            if let Err(e) = self.cancel_discovery(daemon, &api_key, session_id).await {
                tracing::warn!(
                    daemon_id = %daemon.id,
                    session_id = %session_id,
                    "Failed to cancel discovery: {}",
                    e
                );
            }
        }

        Ok(())
    }

    /// Get the API key for a daemon (from the linked api_key_id).
    async fn get_daemon_api_key(&self, daemon: &Daemon) -> Result<String> {
        let api_key_id = daemon
            .base
            .api_key_id
            .ok_or_else(|| anyhow::anyhow!("Daemon {} has no linked API key", daemon.id))?;

        let api_key = self
            .state
            .services
            .daemon_api_key_service
            .get_by_id(&api_key_id)
            .await?
            .ok_or_else(|| anyhow::anyhow!("API key {} not found", api_key_id))?;

        let plaintext = api_key.base.plaintext.as_ref().ok_or_else(|| {
            anyhow::anyhow!(
                "API key {} has no plaintext (not a ServerPoll key)",
                api_key_id
            )
        })?;

        Ok(plaintext.expose_secret().to_string())
    }

    /// Poll daemon status via GET /api/status.
    async fn poll_status(&self, daemon: &Daemon, api_key: &str) -> Result<DaemonStatus> {
        let url = format!("{}/api/status", daemon.base.url);

        let response = self
            .client
            .get(&url)
            .header("Authorization", format!("Bearer {}", api_key))
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!("Status poll failed: HTTP {}", response.status());
        }

        let api_response: ApiResponse<DaemonStatus> = response.json().await?;

        if !api_response.success {
            anyhow::bail!(
                "Status poll failed: {}",
                api_response
                    .error
                    .unwrap_or_else(|| "Unknown error".to_string())
            );
        }

        api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("Status response missing data"))
    }

    /// Poll daemon discovery via GET /api/poll.
    async fn poll_discovery(
        &self,
        daemon: &Daemon,
        api_key: &str,
    ) -> Result<DiscoveryPollResponse> {
        let url = format!("{}/api/poll", daemon.base.url);

        let response = self
            .client
            .get(&url)
            .header("Authorization", format!("Bearer {}", api_key))
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!("Discovery poll failed: HTTP {}", response.status());
        }

        let api_response: ApiResponse<DiscoveryPollResponse> = response.json().await?;

        if !api_response.success {
            anyhow::bail!(
                "Discovery poll failed: {}",
                api_response
                    .error
                    .unwrap_or_else(|| "Unknown error".to_string())
            );
        }

        api_response
            .data
            .ok_or_else(|| anyhow::anyhow!("Discovery poll response missing data"))
    }

    /// Initiate discovery on daemon via POST /api/discovery/initiate.
    async fn initiate_discovery(
        &self,
        daemon: &Daemon,
        api_key: &str,
        work: DiscoveryUpdatePayload,
    ) -> Result<()> {
        let url = format!("{}/api/discovery/initiate", daemon.base.url);

        let request = DaemonDiscoveryRequest {
            session_id: work.session_id,
            discovery_type: work.discovery_type,
        };

        let response = self
            .client
            .post(&url)
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&request)
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!("Discovery initiation failed: HTTP {}", response.status());
        }

        let api_response: ApiResponse<DaemonDiscoveryResponse> = response.json().await?;

        if !api_response.success {
            anyhow::bail!(
                "Discovery initiation failed: {}",
                api_response
                    .error
                    .unwrap_or_else(|| "Unknown error".to_string())
            );
        }

        tracing::info!(
            daemon_id = %daemon.id,
            session_id = %work.session_id,
            "Discovery initiated on ServerPoll daemon"
        );

        Ok(())
    }

    /// Cancel discovery on daemon via POST /api/discovery/cancel.
    async fn cancel_discovery(
        &self,
        daemon: &Daemon,
        api_key: &str,
        session_id: Uuid,
    ) -> Result<()> {
        let url = format!("{}/api/discovery/cancel", daemon.base.url);

        let response = self
            .client
            .post(&url)
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&session_id)
            .send()
            .await?;

        if !response.status().is_success() {
            anyhow::bail!("Discovery cancellation failed: HTTP {}", response.status());
        }

        tracing::info!(
            daemon_id = %daemon.id,
            session_id = %session_id,
            "Discovery cancelled on ServerPoll daemon"
        );

        Ok(())
    }
}
