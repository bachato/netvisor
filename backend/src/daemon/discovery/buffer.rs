use std::sync::Arc;
use tokio::sync::RwLock;

use crate::{
    daemon::runtime::state::BufferedEntities,
    server::{hosts::r#impl::api::DiscoveryHostRequest, subnets::r#impl::base::Subnet},
};

/// Thread-safe buffer for accumulating discovered entities.
/// Used in ServerPoll mode where entities are polled by the server rather than
/// pushed immediately by the daemon.
pub struct EntityBuffer {
    hosts: Arc<RwLock<Vec<DiscoveryHostRequest>>>,
    subnets: Arc<RwLock<Vec<Subnet>>>,
}

impl EntityBuffer {
    pub fn new() -> Self {
        Self {
            hosts: Arc::new(RwLock::new(Vec::new())),
            subnets: Arc::new(RwLock::new(Vec::new())),
        }
    }

    /// Add a discovered host with its children (interfaces, ports, services).
    pub async fn push_host(&self, host: DiscoveryHostRequest) {
        let mut hosts = self.hosts.write().await;
        hosts.push(host);
    }

    /// Add a discovered subnet.
    pub async fn push_subnet(&self, subnet: Subnet) {
        let mut subnets = self.subnets.write().await;
        subnets.push(subnet);
    }

    /// Drain all buffered entities and return them.
    /// Clears the buffer after returning.
    pub async fn drain(&self) -> BufferedEntities {
        let hosts = {
            let mut hosts = self.hosts.write().await;
            std::mem::take(&mut *hosts)
        };

        let subnets = {
            let mut subnets = self.subnets.write().await;
            std::mem::take(&mut *subnets)
        };

        BufferedEntities { hosts, subnets }
    }

    /// Check if the buffer is empty.
    pub async fn is_empty(&self) -> bool {
        let hosts = self.hosts.read().await;
        let subnets = self.subnets.read().await;
        hosts.is_empty() && subnets.is_empty()
    }

    /// Get the count of buffered items without draining.
    pub async fn count(&self) -> (usize, usize) {
        let hosts = self.hosts.read().await;
        let subnets = self.subnets.read().await;
        (hosts.len(), subnets.len())
    }
}

impl Default for EntityBuffer {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::{
        hosts::r#impl::base::{Host, HostBase},
        shared::types::entities::EntitySource,
    };
    use uuid::Uuid;

    #[tokio::test]
    async fn test_entity_buffer_push_and_drain() {
        let buffer = EntityBuffer::new();

        // Push a host
        let host = DiscoveryHostRequest {
            host: Host::new(HostBase {
                name: "test-host".to_string(),
                hostname: None,
                tags: vec![],
                network_id: Uuid::new_v4(),
                description: None,
                source: EntitySource::Manual,
                virtualization: None,
                hidden: false,
            }),
            interfaces: vec![],
            ports: vec![],
            services: vec![],
        };
        buffer.push_host(host).await;

        // Verify buffer has content
        assert!(!buffer.is_empty().await);
        assert_eq!(buffer.count().await, (1, 0));

        // Drain and verify
        let entities = buffer.drain().await;
        assert_eq!(entities.hosts.len(), 1);
        assert!(entities.subnets.is_empty());

        // Verify buffer is empty after drain
        assert!(buffer.is_empty().await);
    }

    #[tokio::test]
    async fn test_entity_buffer_concurrent_access() {
        let buffer = Arc::new(EntityBuffer::new());

        let handles: Vec<_> = (0..10)
            .map(|i| {
                let buf = buffer.clone();
                tokio::spawn(async move {
                    let host = DiscoveryHostRequest {
                        host: Host::new(HostBase {
                            name: format!("host-{}", i),
                            hostname: None,
                            tags: vec![],
                            network_id: Uuid::new_v4(),
                            description: None,
                            source: EntitySource::Manual,
                            virtualization: None,
                            hidden: false,
                        }),
                        interfaces: vec![],
                        ports: vec![],
                        services: vec![],
                    };
                    buf.push_host(host).await;
                })
            })
            .collect();

        for handle in handles {
            handle.await.unwrap();
        }

        let entities = buffer.drain().await;
        assert_eq!(entities.hosts.len(), 10);
    }
}
