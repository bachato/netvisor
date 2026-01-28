use crate::{
    daemon::discovery::types::base::DiscoveryPhase,
    server::{
        hubspot::service::HubSpotService,
        shared::events::{
            bus::{EventFilter, EventSubscriber},
            types::{AuthOperation, Event, TelemetryOperation},
        },
    },
};
use anyhow::Error;
use async_trait::async_trait;

/// HubSpot event subscriber - syncs telemetry and auth events to HubSpot CRM
#[async_trait]
impl EventSubscriber for HubSpotService {
    fn event_filter(&self) -> EventFilter {
        // Subscribe to telemetry events for lifecycle and engagement tracking
        // Also subscribe to LoginSuccess for last_login_date
        // Also subscribe to Discovery Scanning phase for last_discovery_date
        EventFilter {
            entity_operations: Some(std::collections::HashMap::new()),
            auth_operations: Some(vec![AuthOperation::LoginSuccess]),
            telemetry_operations: Some(vec![
                // Lifecycle events
                TelemetryOperation::OrgCreated,
                TelemetryOperation::CheckoutStarted,
                TelemetryOperation::CheckoutCompleted,
                TelemetryOperation::TrialStarted,
                TelemetryOperation::TrialEnded,
                TelemetryOperation::SubscriptionCancelled,
                // Activation milestones
                TelemetryOperation::FirstDaemonRegistered,
                TelemetryOperation::FirstTopologyRebuild,
                TelemetryOperation::FirstNetworkCreated,
                TelemetryOperation::FirstDiscoveryCompleted,
                TelemetryOperation::FirstHostDiscovered,
                TelemetryOperation::SecondNetworkCreated,
                // Engagement signals
                TelemetryOperation::FirstTagCreated,
                TelemetryOperation::FirstUserApiKeyCreated,
                TelemetryOperation::FirstSnmpCredentialCreated,
                TelemetryOperation::InviteSent,
                TelemetryOperation::InviteAccepted,
            ]),
            discovery_phases: Some(vec![DiscoveryPhase::Scanning]),
            network_ids: None,
        }
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        for event in events {
            if let Err(e) = self.handle_event(&event).await {
                // Log error but don't fail - HubSpot sync is non-critical
                tracing::warn!(
                    error = %e,
                    event_type = ?event.operation(),
                    "Failed to sync event to HubSpot"
                );
            }
        }
        Ok(())
    }

    fn name(&self) -> &str {
        "hubspot_crm"
    }

    /// Use a small debounce window to batch events together
    /// This helps reduce API calls while still being responsive
    fn debounce_window_ms(&self) -> u64 {
        // 2 second debounce - batch events that occur close together
        2000
    }
}
