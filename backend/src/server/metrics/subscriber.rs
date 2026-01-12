use anyhow::Error;
use async_trait::async_trait;
use strum::IntoDiscriminant;

use crate::server::{
    metrics::service::MetricsService,
    shared::events::{
        bus::{EventFilter, EventSubscriber},
        types::Event,
    },
};

#[async_trait]
impl EventSubscriber for MetricsService {
    fn event_filter(&self) -> EventFilter {
        EventFilter::all()
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        for event in events {
            let entity = match &event {
                Event::Entity(e) => e.entity_type.discriminant().to_string(),
                Event::Auth(_) => "auth".to_string(),
                Event::Telemetry(_) => "telemetry".to_string(),
            };

            metrics::counter!(
                "scanopy_events_total",
                "entity" => entity,
                "operation" => event.operation().to_string()
            )
            .increment(1);
        }

        Ok(())
    }

    fn name(&self) -> &str {
        "metrics"
    }
}
