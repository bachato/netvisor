use std::collections::HashMap;

use crate::server::{
    auth::middleware::auth::AuthenticatedEntity,
    shared::{
        entities::{Entity, EntityDiscriminants},
        events::{
            bus::{EventFilter, EventSubscriber},
            types::{EntityOperation, Event},
        },
        services::traits::CrudService,
        storage::filter::StorableFilter as StorageFilter,
    },
    topology::{service::main::TopologyService, types::base::Topology},
};
use anyhow::Error;
use async_trait::async_trait;
use std::collections::HashSet;
use uuid::Uuid;

#[derive(Default)]
struct TopologyChanges {
    updated_hosts: bool,
    updated_ip_addresses: bool,
    updated_services: bool,
    updated_subnets: bool,
    updated_dependencies: bool,
    updated_ports: bool,
    updated_bindings: bool,
    updated_if_entries: bool,
    removed_hosts: HashSet<Uuid>,
    removed_ip_addresses: HashSet<Uuid>,
    removed_services: HashSet<Uuid>,
    removed_subnets: HashSet<Uuid>,
    removed_dependencies: HashSet<Uuid>,
    removed_ports: HashSet<Uuid>,
    removed_bindings: HashSet<Uuid>,
    removed_interfaces: HashSet<Uuid>,
    should_mark_stale: bool,
    clear_stale: bool,
}

#[async_trait]
impl EventSubscriber for TopologyService {
    fn event_filter(&self) -> EventFilter {
        EventFilter::entity_only(HashMap::from([
            (EntityDiscriminants::Host, None),
            (EntityDiscriminants::IPAddress, None),
            (EntityDiscriminants::Service, None),
            (EntityDiscriminants::Subnet, None),
            (EntityDiscriminants::Dependency, None),
            (EntityDiscriminants::Port, None),
            (EntityDiscriminants::Binding, None),
            (EntityDiscriminants::Interface, None), // LLDP neighbor changes trigger edge rebuild
            (EntityDiscriminants::Tag, None),       // App-group tag changes trigger staleness
            (
                EntityDiscriminants::Topology,
                Some(vec![EntityOperation::Created, EntityOperation::Updated]),
            ),
        ]))
    }

    async fn handle_events(&self, events: Vec<Event>) -> Result<(), Error> {
        if events.is_empty() {
            return Ok(());
        }

        // Collect all affected network IDs
        let mut network_ids = std::collections::HashSet::new();

        // Group events by network_id -> topology changes
        let mut topology_updates: HashMap<Uuid, TopologyChanges> = HashMap::new();

        // Track org-level staleness triggers (e.g., tag is_application_group changes)
        let mut stale_org_ids: HashSet<Uuid> = HashSet::new();

        for event in events {
            if let Event::Entity(entity_event) = event {
                // Handle org-level entities without network_id (e.g., Tags)
                if entity_event.network_id.is_none() {
                    if let Some(org_id) = entity_event.organization_id {
                        let trigger_stale = entity_event
                            .metadata
                            .get("trigger_stale")
                            .and_then(|v| serde_json::from_value::<bool>(v.clone()).ok())
                            .unwrap_or(false);
                        if trigger_stale {
                            stale_org_ids.insert(org_id);
                        }
                    }
                    continue;
                }

                if let Some(network_id) = entity_event.network_id {
                    // Check if any event triggers staleness
                    let trigger_stale = entity_event
                        .metadata
                        .get("trigger_stale")
                        .and_then(|v| serde_json::from_value::<bool>(v.clone()).ok())
                        .unwrap_or(false);

                    // Check if any event clears staleness (only set on topology create to avoid showing topology as stale on first load)
                    let clear_stale = entity_event
                        .metadata
                        .get("clear_stale")
                        .and_then(|v| serde_json::from_value::<bool>(v.clone()).ok())
                        .unwrap_or(false);

                    // Topology updates from changes to options should be applied immediately and not processed alongside
                    // other changes, otherwise another call to topology_service.update will be made which will trigger
                    // an infinite loop
                    if let Entity::Topology(boxed_topology) = entity_event.entity_type.clone()
                        && entity_event.operation == EntityOperation::Updated
                    {
                        let topology = *boxed_topology;
                        // Don't override is_stale — the handler already set the correct
                        // value (rebuild clears it, refresh marks it).
                        // Services were already set by the handler — no need to re-fetch.

                        let _ = self.staleness_tx.send(topology).inspect_err(|e| {
                            tracing::debug!("Staleness notification skipped (no receivers): {}", e)
                        });
                        continue;
                    }

                    network_ids.insert(network_id);

                    let changes = topology_updates.entry(network_id).or_default();

                    // Track removed entities
                    if entity_event.operation == EntityOperation::Deleted {
                        match entity_event.entity_type {
                            Entity::Host(_) => changes.removed_hosts.insert(entity_event.entity_id),
                            Entity::IPAddress(_) => {
                                changes.removed_ip_addresses.insert(entity_event.entity_id)
                            }
                            Entity::Service(_) => {
                                changes.removed_services.insert(entity_event.entity_id)
                            }
                            Entity::Subnet(_) => {
                                changes.removed_subnets.insert(entity_event.entity_id)
                            }
                            Entity::Dependency(_) => {
                                changes.removed_dependencies.insert(entity_event.entity_id)
                            }
                            Entity::Port(_) => changes.removed_ports.insert(entity_event.entity_id),
                            Entity::Binding(_) => {
                                changes.removed_bindings.insert(entity_event.entity_id)
                            }
                            Entity::Interface(_) => {
                                changes.removed_interfaces.insert(entity_event.entity_id)
                            }
                            _ => false,
                        };
                    }

                    if trigger_stale {
                        // User will be prompted to update entities
                        changes.should_mark_stale = true;
                    } else if clear_stale {
                        changes.clear_stale = true;
                    } else {
                        // It's safe to automatically update entities
                        match entity_event.entity_type {
                            Entity::Host(_) => changes.updated_hosts = true,
                            Entity::IPAddress(_) => changes.updated_ip_addresses = true,
                            Entity::Service(_) => changes.updated_services = true,
                            Entity::Subnet(_) => changes.updated_subnets = true,
                            Entity::Dependency(_) => changes.updated_dependencies = true,
                            Entity::Port(_) => changes.updated_ports = true,
                            Entity::Binding(_) => changes.updated_bindings = true,
                            Entity::Interface(_) => changes.updated_if_entries = true,
                            _ => (),
                        };
                    }
                }
            }
        }

        // Mark all topologies in affected orgs as stale (for org-level entities like tags)
        for org_id in &stale_org_ids {
            // Tags are org-indexed but topologies are network-indexed — find networks in this org first
            let network_filter =
                StorageFilter::<crate::server::networks::r#impl::Network>::new_from_org_id(org_id);
            let networks = self.network_service.get_all(network_filter).await?;
            for network in &networks {
                let topo_filter = StorageFilter::<Topology>::new_from_network_ids(&[network.id]);
                let topologies = self.get_all(topo_filter).await?;
                for mut topology in topologies {
                    if !topology.base.is_stale {
                        topology.base.is_stale = true;
                        let updated = self
                            .update(&mut topology, AuthenticatedEntity::System)
                            .await?;
                        let _ = self.staleness_tx.send(updated).inspect_err(|e| {
                            tracing::debug!("Staleness notification skipped (no receivers): {}", e)
                        });
                    }
                }
            }
        }

        // Apply changes to all topologies in affected networks
        for network_id in network_ids {
            let network_filter = StorageFilter::<Topology>::new_from_network_ids(&[network_id]);
            let topologies = self.get_all(network_filter).await?;

            let (hosts, ip_addresses, subnets, dependencies, ports, bindings, interfaces) =
                self.get_entity_data(network_id).await?;

            if let Some(changes) = topology_updates.get(&network_id) {
                for mut topology in topologies {
                    let services = self.get_service_data(network_id).await?;

                    // Apply removed entities
                    for host_id in &changes.removed_hosts {
                        if !topology.base.removed_hosts.contains(host_id) {
                            topology.base.removed_hosts.push(*host_id);
                        }
                    }
                    for ip_address_id in &changes.removed_ip_addresses {
                        if !topology.base.removed_ip_addresses.contains(ip_address_id) {
                            topology.base.removed_ip_addresses.push(*ip_address_id);
                        }
                    }
                    for service_id in &changes.removed_services {
                        if !topology.base.removed_services.contains(service_id) {
                            topology.base.removed_services.push(*service_id);
                        }
                    }
                    for subnet_id in &changes.removed_subnets {
                        if !topology.base.removed_subnets.contains(subnet_id) {
                            topology.base.removed_subnets.push(*subnet_id);
                        }
                    }
                    for dependency_id in &changes.removed_dependencies {
                        if !topology.base.removed_dependencies.contains(dependency_id) {
                            topology.base.removed_dependencies.push(*dependency_id);
                        }
                    }
                    for port_id in &changes.removed_ports {
                        if !topology.base.removed_ports.contains(port_id) {
                            topology.base.removed_ports.push(*port_id);
                        }
                    }
                    for binding_id in &changes.removed_bindings {
                        if !topology.base.removed_bindings.contains(binding_id) {
                            topology.base.removed_bindings.push(*binding_id);
                        }
                    }
                    for interface_id in &changes.removed_interfaces {
                        if !topology.base.removed_interfaces.contains(interface_id) {
                            topology.base.removed_interfaces.push(*interface_id);
                        }
                    }

                    // Mark stale if needed
                    if changes.should_mark_stale && !changes.clear_stale {
                        topology.base.is_stale = true;
                    }

                    // Clear stale - this only happens on topology create to avoid a stale state when loading app for the first time
                    if changes.clear_stale {
                        topology.base.is_stale = false;
                    }

                    // Only refresh entity arrays if there are no pending removals for that type.
                    // This preserves deleted entity data so the conflict modal can display names.
                    if changes.updated_hosts && changes.removed_hosts.is_empty() {
                        topology.base.hosts = hosts.clone()
                    }

                    if changes.updated_ip_addresses && changes.removed_ip_addresses.is_empty() {
                        topology.base.ip_addresses = ip_addresses.clone()
                    }

                    if changes.updated_services && changes.removed_services.is_empty() {
                        topology.base.services = services
                    }

                    if changes.updated_subnets && changes.removed_subnets.is_empty() {
                        topology.base.subnets = subnets.clone()
                    }

                    if changes.updated_dependencies && changes.removed_dependencies.is_empty() {
                        topology.base.dependencies = dependencies.clone();
                    }

                    if changes.updated_ports && changes.removed_ports.is_empty() {
                        topology.base.ports = ports.clone();
                    }

                    if changes.updated_bindings && changes.removed_bindings.is_empty() {
                        topology.base.bindings = bindings.clone();
                    }

                    if changes.updated_if_entries && changes.removed_interfaces.is_empty() {
                        topology.base.interfaces = interfaces.clone();
                    }

                    // Update topology in database
                    let updated = self
                        .update(&mut topology, AuthenticatedEntity::System)
                        .await?;

                    // Send the UPDATED topology to SSE
                    let _ = self.staleness_tx.send(updated).inspect_err(|e| {
                        tracing::debug!("Staleness notification skipped (no receivers): {}", e)
                    });
                }
            }
        }

        Ok(())
    }

    fn debounce_window_ms(&self) -> u64 {
        200 // Batch events within 200ms window
    }

    fn name(&self) -> &str {
        "topology_stale"
    }
}
