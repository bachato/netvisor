use anyhow::{anyhow, Result};
use async_trait::async_trait;
use chrono::Utc;
use std::sync::Arc;
use uuid::Uuid;

use crate::server::{
    auth::middleware::auth::{AuthenticatedEntity, AuthenticatedUser},
    daemon_api_keys::r#impl::base::DaemonApiKey,
    shared::{
        api_key_common::ApiKeyService,
        entities::ChangeTriggersTopologyStaleness,
        events::{
            bus::EventBus,
            types::{EntityEvent, EntityOperation},
        },
        services::traits::{CrudService, EventBusService},
        storage::{
            generic::GenericPostgresStorage,
            traits::{StorableEntity, Storage},
        },
    },
};

pub struct DaemonApiKeyService {
    storage: Arc<GenericPostgresStorage<DaemonApiKey>>,
    event_bus: Arc<EventBus>,
}

impl EventBusService<DaemonApiKey> for DaemonApiKeyService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &DaemonApiKey) -> Option<Uuid> {
        Some(entity.base.network_id)
    }
    fn get_organization_id(&self, _entity: &DaemonApiKey) -> Option<Uuid> {
        None
    }
}

#[async_trait]
impl CrudService<DaemonApiKey> for DaemonApiKeyService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<DaemonApiKey>> {
        &self.storage
    }

    /// Update entity
    async fn update(
        &self,
        entity: &mut DaemonApiKey,
        authentication: AuthenticatedEntity,
    ) -> Result<DaemonApiKey, anyhow::Error> {
        let current = self
            .get_by_id(&entity.id())
            .await?
            .ok_or_else(|| anyhow!("Could not find {}", entity))?;
        let updated = self.storage().update(entity).await?;

        let suppress_logs = updated.suppress_logs(&current);
        let trigger_stale = updated.triggers_staleness(Some(current));

        self.event_bus()
            .publish_entity(EntityEvent {
                id: Uuid::new_v4(),
                entity_id: updated.id(),
                network_id: self.get_network_id(&updated),
                organization_id: self.get_organization_id(&updated),
                entity_type: updated.clone().into(),
                operation: EntityOperation::Updated,
                timestamp: Utc::now(),
                metadata: serde_json::json!({
                    "trigger_stale": trigger_stale,
                    "suppress_logs": suppress_logs
                }),
                authentication,
            })
            .await?;

        Ok(updated)
    }
}

// Re-export shared API key functions for backwards compatibility
pub use crate::server::shared::api_key_common::{hash_api_key, ApiKeyType};

impl DaemonApiKeyService {
    pub fn new(storage: Arc<GenericPostgresStorage<DaemonApiKey>>, event_bus: Arc<EventBus>) -> Self {
        Self { storage, event_bus }
    }
}

impl ApiKeyService for DaemonApiKeyService {
    type Key = DaemonApiKey;

    fn api_key_event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn validate_access(&self, key: &DaemonApiKey, user: &AuthenticatedUser) -> Result<()> {
        // User must have access to the network this key belongs to
        if !user.network_ids.contains(&key.base.network_id) {
            return Err(anyhow!(
                "You don't have access to the network for this daemon API key"
            ));
        }
        Ok(())
    }
}
