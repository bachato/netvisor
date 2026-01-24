use async_trait::async_trait;

use crate::daemon::discovery::types::base::DiscoveryPhase;
use crate::server::daemons::r#impl::base::DaemonMode;
use crate::server::hosts::service::HostService;
use crate::server::shared::events::bus::{EventFilter, EventSubscriber};
use crate::server::shared::events::types::Event;
use crate::server::shared::services::traits::CrudService;

#[async_trait]
impl EventSubscriber for HostService {
    fn event_filter(&self) -> EventFilter {
        // Subscribe to Discovery entity events with DiscoveryStarted/Cancelled operations
        EventFilter::discovery_only(Some(vec![DiscoveryPhase::Complete]))
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), anyhow::Error> {
        for event in events {
            if let Event::Discovery(discovery_event) = event {
                // Check if daemon is ServerPoll mode and reachable
                let Some(daemon) = self
                    .daemon_service
                    .get_by_id(&discovery_event.daemon_id)
                    .await?
                else {
                    tracing::debug!(
                        daemon_id = %discovery_event.daemon_id,
                        "Daemon not found for discovery event, skipping"
                    );
                    continue;
                };

                if daemon.base.mode != DaemonMode::ServerPoll || daemon.base.is_unreachable {
                    tracing::trace!(
                        daemon_id = %discovery_event.daemon_id,
                        mode = ?daemon.base.mode,
                        is_unreachable = daemon.base.is_unreachable,
                        "Daemon not eligible for discovery event handling, skipping"
                    );
                    continue;
                }

                if discovery_event.phase == DiscoveryPhase::Complete {
                    // Resolve LLDP links on successful completion
                    if let Err(e) = self.resolve_lldp_links(discovery_event.network_id).await {
                        tracing::warn!(
                            session_id = %discovery_event.session_id,
                            network_id = %discovery_event.network_id,
                            error = %e,
                            "Failed to resolve LLDP links after discovery completion"
                        );
                        // Non-fatal: discovery succeeded, link resolution is best-effort
                    }
                }
            }
        }
        Ok(())
    }

    fn name(&self) -> &str {
        "host-discovery-events"
    }
}
