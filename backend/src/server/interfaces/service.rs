use anyhow::Result;
use std::{collections::HashMap, sync::Arc};
use uuid::Uuid;
use validator::ValidationError;

use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    interfaces::r#impl::base::{Interface, Neighbor},
    ip_addresses::service::IPAddressService,
    shared::{
        events::bus::EventBus,
        services::traits::{ChildCrudService, CrudService, EventBusService},
        storage::{filter::StorableFilter, generic::GenericPostgresStorage, traits::Storage},
    },
    tags::entity_tags::EntityTagService,
};

pub struct InterfaceService {
    storage: Arc<GenericPostgresStorage<Interface>>,
    event_bus: Arc<EventBus>,
    ip_address_service: Arc<IPAddressService>,
}

impl EventBusService<Interface> for InterfaceService {
    fn event_bus(&self) -> &Arc<EventBus> {
        &self.event_bus
    }

    fn get_network_id(&self, entity: &Interface) -> Option<Uuid> {
        Some(entity.base.network_id)
    }

    fn get_organization_id(&self, _entity: &Interface) -> Option<Uuid> {
        None
    }
}

impl CrudService<Interface> for InterfaceService {
    fn storage(&self) -> &Arc<GenericPostgresStorage<Interface>> {
        &self.storage
    }

    fn entity_tag_service(&self) -> Option<&Arc<EntityTagService>> {
        None
    }
}

impl ChildCrudService<Interface> for InterfaceService {}

impl InterfaceService {
    pub fn new(
        storage: Arc<GenericPostgresStorage<Interface>>,
        event_bus: Arc<EventBus>,
        ip_address_service: Arc<IPAddressService>,
    ) -> Self {
        Self {
            storage,
            event_bus,
            ip_address_service,
        }
    }

    /// Get all if entries for a specific host, ordered by ifIndex
    pub async fn get_for_host(&self, host_id: &Uuid) -> Result<Vec<Interface>> {
        let filter = StorableFilter::<Interface>::new_from_host_ids(&[*host_id]);
        self.storage.get_all_ordered(filter, "if_index ASC").await
    }

    /// Get if entries for multiple hosts, ordered by ifIndex within each host
    pub async fn get_for_hosts(&self, host_ids: &[Uuid]) -> Result<HashMap<Uuid, Vec<Interface>>> {
        if host_ids.is_empty() {
            return Ok(HashMap::new());
        }

        let filter = StorableFilter::<Interface>::new_from_host_ids(host_ids);
        let entries = self
            .storage
            .get_all_ordered(filter, "host_id ASC, if_index ASC")
            .await?;

        let mut result: HashMap<Uuid, Vec<Interface>> = HashMap::new();
        for entry in entries {
            result.entry(entry.base.host_id).or_default().push(entry);
        }
        Ok(result)
    }

    /// Validate FK relationships for an Interface.
    ///
    /// Validates:
    /// - ip_address_id must reference an Interface on the same host
    /// - If both Interface and Interface have MAC addresses, they should match
    /// - neighbor (when Interface) must reference an Interface on a different host, same network
    ///
    /// Note: Neighbor::Host validation is done in handlers (requires access to HostService)
    pub async fn validate_relationships(&self, entry: &Interface) -> Result<()> {
        // 1. ip_address_id: must be on SAME host, and MAC addresses should match if both present
        if let Some(ip_address_id) = entry.base.ip_address_id {
            let ip_address = self
                .ip_address_service
                .get_by_id(&ip_address_id)
                .await?
                .ok_or_else(|| {
                    ValidationError::new("ip_address_id references a non-existent Interface")
                })?;

            if ip_address.base.host_id != entry.base.host_id {
                return Err(ValidationError::new(
                    "ip_address_id must reference an Interface on the same host",
                )
                .into());
            }

            // Validate MAC address consistency if both have MAC addresses
            if let (Some(if_entry_mac), Some(ip_address_mac)) =
                (&entry.base.mac_address, &ip_address.base.mac_address)
                && if_entry_mac != ip_address_mac
            {
                return Err(ValidationError::new(
                    "ip_address_id references an Interface with a different MAC address",
                )
                .into());
            }
        }

        // 2. neighbor (Interface variant): must be on DIFFERENT host, same network
        if let Some(Neighbor::Interface(neighbor_id)) = &entry.base.neighbor {
            // Cannot connect to self
            if *neighbor_id == entry.id {
                return Err(ValidationError::new("Interface cannot connect to itself").into());
            }

            // Get the neighbor Interface
            let neighbor_interface = self.get_by_id(neighbor_id).await?.ok_or_else(|| {
                ValidationError::new("neighbor Interface references a non-existent Interface")
            })?;

            // Must be different host
            if neighbor_interface.base.host_id == entry.base.host_id {
                return Err(
                    ValidationError::new("neighbor Interface must be on a different host").into(),
                );
            }

            // Must be same network
            if neighbor_interface.base.network_id != entry.base.network_id {
                return Err(
                    ValidationError::new("neighbor Interface must be in the same network").into(),
                );
            }
        }

        // Note: Neighbor::Host validation is handled in handlers which have access to HostService

        Ok(())
    }

    /// Create or update an interface based on host_id + if_index (unique identifier)
    /// Used during SNMP discovery to upsert interface table entries.
    /// Skips validation for discovery flow (data comes from trusted SNMP source).
    pub async fn create_or_update_by_if_index(
        &self,
        entry: Interface,
        authentication: AuthenticatedEntity,
    ) -> Result<Interface> {
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
