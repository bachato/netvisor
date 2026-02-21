use std::collections::HashMap;

use anyhow::Error;
use async_trait::async_trait;

use crate::server::{
    email::traits::EmailService,
    shared::{
        entities::EntityDiscriminants,
        events::{
            bus::{EventFilter, EventSubscriber},
            types::{EntityOperation, Event, TelemetryOperation},
        },
        services::traits::CrudService,
    },
};

#[async_trait]
impl EventSubscriber for EmailService {
    fn event_filter(&self) -> EventFilter {
        EventFilter {
            entity_operations: Some(HashMap::from([
                (
                    EntityDiscriminants::Host,
                    Some(vec![EntityOperation::Created]),
                ),
                (
                    EntityDiscriminants::Network,
                    Some(vec![EntityOperation::Created]),
                ),
                (
                    EntityDiscriminants::User,
                    Some(vec![EntityOperation::Created]),
                ),
            ])),
            telemetry_operations: Some(vec![
                TelemetryOperation::FirstDaemonRegistered,
                TelemetryOperation::FirstDiscoveryCompleted,
            ]),
            auth_operations: Some(vec![]),
            discovery_phases: Some(vec![]),
            network_ids: None,
        }
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        if events.is_empty() {
            return Ok(());
        }

        for event in events {
            match event {
                Event::Entity(e) => {
                    let org_id = if let Some(org_id) = e.organization_id {
                        Some(org_id)
                    } else if let Some(network_id) = e.network_id {
                        self.network_service
                            .get_by_id(&network_id)
                            .await?
                            .map(|n| n.base.organization_id)
                    } else {
                        None
                    };

                    if let Some(org_id) = org_id
                        && let Err(e) = self.check_plan_limits(org_id).await
                    {
                        tracing::warn!(
                            organization_id = %org_id,
                            error = %e,
                            "Failed to check plan limits"
                        );
                    }
                }
                Event::Telemetry(t) => match t.operation {
                    TelemetryOperation::FirstDaemonRegistered => {
                        let daemon_name = t
                            .metadata
                            .get("daemon_name")
                            .and_then(|v| v.as_str())
                            .unwrap_or("your daemon");
                        let network_name = t
                            .metadata
                            .get("network_name")
                            .and_then(|v| v.as_str())
                            .unwrap_or("your network");

                        if let Err(e) = self
                            .send_discovery_guide_for_org(
                                t.organization_id,
                                daemon_name,
                                network_name,
                            )
                            .await
                        {
                            tracing::warn!(
                                organization_id = %t.organization_id,
                                error = %e,
                                "Failed to send discovery guide email"
                            );
                        }
                    }
                    TelemetryOperation::FirstDiscoveryCompleted => {
                        if let Err(e) = self.send_topology_ready_for_org(t.organization_id).await {
                            tracing::warn!(
                                organization_id = %t.organization_id,
                                error = %e,
                                "Failed to send topology ready email"
                            );
                        }
                    }
                    _ => {}
                },
                _ => {}
            }
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "email_onboarding_and_plan_limits"
    }
}
