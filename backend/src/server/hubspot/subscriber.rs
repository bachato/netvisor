use crate::{
    daemon::discovery::types::base::DiscoveryPhase,
    server::{
        hubspot::service::HubSpotService,
        shared::{
            entities::EntityDiscriminants,
            events::{
                bus::{EventFilter, EventSubscriber},
                types::{AuthOperation, EntityOperation, Event},
            },
        },
    },
};
use anyhow::Error;
use async_trait::async_trait;
use std::collections::{HashMap, HashSet};
use uuid::Uuid;

/// HubSpot event subscriber - syncs telemetry, auth, and entity events to HubSpot CRM
#[async_trait]
impl EventSubscriber for HubSpotService {
    fn event_filter(&self) -> EventFilter {
        // Subscribe to telemetry events for lifecycle and engagement tracking
        // Also subscribe to LoginSuccess for last_login_date
        // Also subscribe to Discovery Scanning phase for last_discovery_date
        // Also subscribe to entity create/delete for metrics sync

        let mut entity_ops = HashMap::new();
        entity_ops.insert(
            EntityDiscriminants::Network,
            Some(vec![EntityOperation::Created, EntityOperation::Deleted]),
        );
        entity_ops.insert(
            EntityDiscriminants::Host,
            Some(vec![EntityOperation::Created, EntityOperation::Deleted]),
        );
        entity_ops.insert(
            EntityDiscriminants::User,
            Some(vec![EntityOperation::Created, EntityOperation::Deleted]),
        );

        EventFilter {
            entity_operations: Some(entity_ops),
            auth_operations: Some(vec![AuthOperation::LoginSuccess]),
            // All telemetry operations
            telemetry_operations: None,
            discovery_phases: Some(vec![DiscoveryPhase::Scanning]),
            // All networks
            network_ids: None,
        }
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        // Collect org_ids from entity events for metrics sync
        let mut org_ids_for_metrics: HashSet<Uuid> = HashSet::new();

        for event in &events {
            match event {
                Event::Entity(entity_event) => {
                    // Get org_id (directly or via network lookup)
                    if let Some(org_id) = entity_event.organization_id {
                        org_ids_for_metrics.insert(org_id);
                    } else if let Some(network_id) = entity_event.network_id
                        && let Some(org_id) = self.get_org_id_from_network(&network_id).await
                    {
                        org_ids_for_metrics.insert(org_id);
                    }
                }
                _ => {
                    // Handle other events (telemetry, auth, discovery)
                    if let Err(e) = self.handle_event(event).await {
                        // Log error but don't fail - HubSpot sync is non-critical
                        tracing::warn!(
                            error = %e,
                            event_type = ?event.operation(),
                            "Failed to sync event to HubSpot"
                        );
                    }
                }
            }
        }

        // Sync metrics for affected orgs
        for org_id in org_ids_for_metrics {
            if let Err(e) = self.sync_org_entity_metrics(org_id).await {
                tracing::warn!(
                    error = %e,
                    organization_id = %org_id,
                    "Failed to sync organization metrics to HubSpot"
                );
            }
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "hubspot_crm"
    }

    /// Use a debounce window to batch events together
    /// This helps reduce API calls while still being responsive
    fn debounce_window_ms(&self) -> u64 {
        // 5 second debounce - batch events that occur close together
        5000
    }
}
