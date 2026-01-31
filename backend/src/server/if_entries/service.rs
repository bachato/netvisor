use anyhow::Result;
use std::{collections::HashMap, sync::Arc};
use uuid::Uuid;
use validator::ValidationError;

use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    if_entries::r#impl::base::{IfEntry, Neighbor},
    interfaces::service::InterfaceService,
    shared::{
        events::bus::EventBus,
        services::traits::{ChildCrudService, CrudService, EventBusService},
        storage::{filter::StorableFilter, generic::GenericPostgresStorage, traits::Storage},
    },
    tags::entity_tags::EntityTagService,
};

pub struct IfEntryService {
    storage: Arc<GenericPostgresStorage<IfEntry>>,
    event_bus: Arc<EventBus>,
    interface_service: Arc<InterfaceService>,
}

impl EventBusService<IfEntry> for IfEntryService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &IfEntry) -> Option<Uuid> {
        Some(entity.base.network_id)
    }

    fn get_organization_id(&self, _entity: &IfEntry) -> Option<Uuid> {
        None
    }
}

impl CrudService<IfEntry> for IfEntryService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<IfEntry>> {
        &self.storage
    }

    fn entity_tag_service(&self) -> Option<&Arc<EntityTagService>> {
        None
    }
}

impl ChildCrudService<IfEntry> for IfEntryService {}

impl IfEntryService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<IfEntry>>,
        event_bus: Arc<EventBus>,
        interface_service: Arc<InterfaceService>,
    ) -> Self {
        Self {
            storage,
            event_bus,
            interface_service,
        }
    }

    /// Get all if entries for a specific host, ordered by ifIndex
    pub async fn get_for_host(&self, host_id: &Uuid) -> Result<Vec<IfEntry>> {
        let filter = StorableFilter::<IfEntry>::new_from_host_ids(&[*host_id]);
        self.storage.get_all_ordered(filter, "if_index ASC").await
    }

    /// Get if entries for multiple hosts, ordered by ifIndex within each host
    pub async fn get_for_hosts(&self, host_ids: &[Uuid]) -> Result<HashMap<Uuid, Vec<IfEntry>>> {
        if host_ids.is_empty() {
            return Ok(HashMap::new());
        }

        let filter = StorableFilter::<IfEntry>::new_from_host_ids(host_ids);
        let entries = self
            .storage
            .get_all_ordered(filter, "host_id ASC, if_index ASC")
            .await?;

        let mut result: HashMap<Uuid, Vec<IfEntry>> = HashMap::new();
        for entry in entries {
            result.entry(entry.base.host_id).or_default().push(entry);
        }
        Ok(result)
    }

    /// Validate FK relationships for an IfEntry.
    ///
    /// Validates:
    /// - interface_id must reference an Interface on the same host
    /// - If both IfEntry and Interface have MAC addresses, they should match
    /// - neighbor (when IfEntry) must reference an IfEntry on a different host, same network
    ///
    /// Note: Neighbor::Host validation is done in handlers (requires access to HostService)
    pub async fn validate_relationships(&self, entry: &IfEntry) -> Result<()> {
        // 1. interface_id: must be on SAME host, and MAC addresses should match if both present
        if let Some(interface_id) = entry.base.interface_id {
            let interface = self
                .interface_service
                .get_by_id(&interface_id)
                .await?
                .ok_or_else(|| {
                    ValidationError::new("interface_id references a non-existent Interface")
                })?;

            if interface.base.host_id != entry.base.host_id {
                return Err(ValidationError::new(
                    "interface_id must reference an Interface on the same host",
                )
                .into());
            }

            // Validate MAC address consistency if both have MAC addresses
            if let (Some(if_entry_mac), Some(interface_mac)) =
                (&entry.base.mac_address, &interface.base.mac_address)
                && if_entry_mac != interface_mac
            {
                return Err(ValidationError::new(
                    "interface_id references an Interface with a different MAC address",
                )
                .into());
            }
        }

        // 2. neighbor (IfEntry variant): must be on DIFFERENT host, same network
        if let Some(Neighbor::IfEntry(neighbor_id)) = &entry.base.neighbor {
            // Cannot connect to self
            if *neighbor_id == entry.id {
                return Err(ValidationError::new("IfEntry cannot connect to itself").into());
            }

            // Get the neighbor IfEntry
            let neighbor_entry = self.get_by_id(neighbor_id).await?.ok_or_else(|| {
                ValidationError::new("neighbor IfEntry references a non-existent IfEntry")
            })?;

            // Must be different host
            if neighbor_entry.base.host_id == entry.base.host_id {
                return Err(
                    ValidationError::new("neighbor IfEntry must be on a different host").into(),
                );
            }

            // Must be same network
            if neighbor_entry.base.network_id != entry.base.network_id {
                return Err(
                    ValidationError::new("neighbor IfEntry must be in the same network").into(),
                );
            }
        }

        // Note: Neighbor::Host validation is handled in handlers which have access to HostService

        Ok(())
    }

    /// Create or update an if_entry based on host_id + if_index (unique identifier)
    /// Used during SNMP discovery to upsert interface table entries.
    /// Skips validation for discovery flow (data comes from trusted SNMP source).
    pub async fn create_or_update_by_if_index(
        &self,
        entry: IfEntry,
        authentication: AuthenticatedEntity,
    ) -> Result<IfEntry> {
        // Check for existing entry with same host_id and if_index
        let existing = self
            .get_for_host(&entry.base.host_id)
            .await?
            .into_iter()
            .find(|e| e.base.if_index == entry.base.if_index);

        if let Some(existing_entry) = existing {
            // Update existing entry, preserving the ID
            let mut updated = entry;
            updated.id = existing_entry.id;
            updated.created_at = existing_entry.created_at;
            self.update(&mut updated, authentication).await
        } else {
            // Create new entry
            self.create(entry, authentication).await
        }
    }
}
