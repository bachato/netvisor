use crate::server::discovery::r#impl::types::DiscoveryType;
use crate::server::interfaces::r#impl::base::{Interface, InterfaceBase};
use crate::server::shared::storage::traits::Storable;
use crate::server::shared::types::entities::{DiscoveryMetadata, EntitySource};
use crate::server::subnets::r#impl::base::{Subnet, SubnetBase};
use crate::server::subnets::r#impl::types::{SubnetType, SubnetTypeDiscriminants};
use anyhow::Error;
use anyhow::anyhow;
use async_trait::async_trait;
use bollard::query_parameters::ListNetworksOptions;
use bollard::{API_DEFAULT_VERSION, Docker};
use cidr::IpCidr;
use local_ip_address::local_ip;
use mac_address::MacAddress;
use net_route::Handle;
use pnet::ipnetwork::IpNetwork;
use std::collections::{HashMap, HashSet};
use std::net::IpAddr;
use std::path::PathBuf;
use std::str::FromStr;
use std::time::Duration;
use strum::IntoDiscriminant;
use uuid::Uuid;

pub const SCAN_TIMEOUT: Duration = Duration::from_millis(800);

/// Parameters for scan concurrency, including both concurrent hosts and port batch size.
/// These values must be calculated together to ensure total FD usage stays within limits.
/// Previously, batch size was calculated independently which caused FD exhaustion when
/// concurrent_scans * port_batch_size exceeded available file descriptors.
#[derive(Debug, Clone)]
pub struct ScanConcurrencyParams {
    /// Number of hosts to scan concurrently
    pub concurrent_scans: usize,
    /// Port batch size per host (number of ports scanned in parallel per host)
    pub port_batch_size: usize,
}

/// Cross-platform system utilities trait
#[async_trait]
pub trait DaemonUtils {
    fn new() -> Self;

    /// Get MAC address for an IP from ARP table
    async fn get_mac_address_for_ip(&self, ip: IpAddr) -> Result<Option<MacAddress>, Error>;

    fn get_fd_limit() -> Result<usize, Error>;

    fn get_own_ip_address(&self) -> Result<IpAddr, Error> {
        match local_ip() {
            Ok(ip) => {
                tracing::info!(ip = %ip, "Detected local IP address");
                Ok(ip)
            }
            Err(e) => {
                tracing::warn!(
                    error = %e,
                    "Failed to detect local IP address. This may occur in MACVLAN containers \
                     or environments without a default route."
                );
                Err(anyhow!("Failed to get local IP address: {}", e))
            }
        }
    }

    fn get_own_mac_address(&self) -> Result<Option<MacAddress>, Error> {
        mac_address::get_mac_address().map_err(|e| anyhow!("Failed to get own MAC address: {}", e))
    }

    fn get_own_hostname(&self) -> Option<String> {
        hostname::get()
            .ok()
            .map(|os_str| os_str.to_string_lossy().into_owned())
    }

    async fn get_own_interfaces(
        &self,
        discovery_type: DiscoveryType,
        daemon_id: Uuid,
        network_id: Uuid,
        interface_filter: &[String],
    ) -> Result<
        (
            Vec<Interface>,
            Vec<Subnet>,
            HashMap<IpCidr, Option<MacAddress>>,
        ),
        Error,
    > {
        let all_interfaces = pnet::datalink::interfaces();

        // Apply interface filter if specified
        let interfaces: Vec<_> = if interface_filter.is_empty() {
            all_interfaces
        } else {
            let filtered: Vec<_> = all_interfaces
                .into_iter()
                .filter(|iface| interface_filter.iter().any(|f| f == &iface.name))
                .collect();

            if filtered.is_empty() {
                tracing::warn!(
                    filter = ?interface_filter,
                    "No interfaces matched the filter. Check --interface argument."
                );
            } else {
                tracing::debug!(
                    filter = ?interface_filter,
                    matched = filtered.len(),
                    "Filtered interfaces by --interfaces argument"
                );
            }

            filtered
        };

        tracing::debug!(
            interface_count = interfaces.len(),
            "Enumerating network interfaces"
        );

        for interface in &interfaces {
            tracing::debug!(
                name = %interface.name,
                index = interface.index,
                is_up = interface.is_up(),
                is_loopback = interface.is_loopback(),
                mac = ?interface.mac,
                ips = ?interface.ips,
                flags = interface.flags,
                "Found interface"
            );
        }

        // First pass: collect all interface data and potential subnets
        let mut potential_subnets: Vec<(String, IpNetwork)> = Vec::new();
        let mut interface_data: Vec<(String, IpAddr, Option<MacAddress>)> = Vec::new();

        for interface in interfaces.into_iter().filter(|i| !i.is_loopback()) {
            let name = interface.name.clone();
            let mac_address = match interface.mac {
                Some(mac) if !mac.octets().iter().all(|o| *o == 0) => {
                    Some(MacAddress::new(mac.octets()))
                }
                _ => None,
            };

            for ip in interface.ips.iter() {
                interface_data.push((name.clone(), ip.ip(), mac_address));
                potential_subnets.push((name.clone(), *ip));
            }
        }

        // Second pass: create unique subnets from valid networks
        let mut subnet_map: HashMap<IpCidr, Subnet> = HashMap::new();

        for (interface_name, ip_network) in potential_subnets {
            if let Some(subnet) = Subnet::from_discovery(
                interface_name,
                &ip_network,
                daemon_id,
                &discovery_type,
                network_id,
            ) {
                subnet_map.entry(subnet.base.cidr).or_insert(subnet);
            }
        }

        // Third pass: assign all interfaces to appropriate subnets
        let mut interfaces = Vec::new();
        let mut cidr_to_mac = HashMap::new();

        for (interface_name, ip_addr, mac_address) in interface_data {
            // Find which subnet this IP belongs to
            if let Some(subnet) = subnet_map
                .values()
                .filter(|s| s.base.cidr.contains(&ip_addr))
                .max_by_key(|s| s.base.cidr.network_length())
            {
                cidr_to_mac.insert(subnet.base.cidr, mac_address);

                interfaces.push(Interface::new(InterfaceBase {
                    network_id: subnet.base.network_id,
                    host_id: Uuid::nil(), // Placeholder - server will set correct host_id
                    name: Some(interface_name),
                    subnet_id: subnet.id,
                    ip_address: ip_addr,
                    mac_address,
                    position: interfaces.len() as i32,
                }));
            }
        }

        let subnets: Vec<Subnet> = subnet_map.into_values().collect();

        Ok((interfaces, subnets, cidr_to_mac))
    }

    async fn new_local_docker_client(
        &self,
        docker_proxy: Result<Option<String>, Error>,
        docker_proxy_ssl_info: Result<Option<(String, String, String)>, Error>,
    ) -> Result<Docker, Error> {
        use tokio::time::timeout;

        const DOCKER_CONNECT_TIMEOUT: Duration = Duration::from_secs(5);

        tracing::debug!("Creating Docker client connection");
        let start = std::time::Instant::now();

        let client = if let Ok(Some(docker_proxy)) = docker_proxy {
            tracing::debug!(proxy = %docker_proxy, "Using Docker proxy");
            if docker_proxy.contains("https://")
                && let Ok(Some((key, cert, chain))) = docker_proxy_ssl_info
            {
                let key_path = PathBuf::from(key);
                let cert_path = PathBuf::from(cert);
                let chain_path = PathBuf::from(chain);

                Docker::connect_with_ssl(
                    &docker_proxy,
                    &key_path,
                    &cert_path,
                    &chain_path,
                    4,
                    API_DEFAULT_VERSION,
                )
                .map_err(|e| anyhow::anyhow!("Failed to connect to Docker: {}", e))?
            } else {
                Docker::connect_with_http(&docker_proxy, 4, API_DEFAULT_VERSION)
                    .map_err(|e| anyhow::anyhow!("Failed to connect to Docker: {}", e))?
            }
        } else {
            tracing::debug!("Using Docker local defaults");
            Docker::connect_with_local_defaults()
                .map_err(|e| anyhow::anyhow!("Failed to connect to Docker: {}", e))?
        };

        // Add timeout to Docker ping to prevent indefinite blocking
        tracing::debug!(
            "Pinging Docker daemon (timeout: {:?})",
            DOCKER_CONNECT_TIMEOUT
        );
        match timeout(DOCKER_CONNECT_TIMEOUT, client.ping()).await {
            Ok(Ok(_)) => {
                tracing::info!(
                    elapsed_ms = start.elapsed().as_millis(),
                    "Docker client connected successfully"
                );
                Ok(client)
            }
            Ok(Err(e)) => {
                tracing::warn!(
                    elapsed_ms = start.elapsed().as_millis(),
                    error = %e,
                    "Docker ping failed"
                );
                Err(anyhow::anyhow!("Docker ping failed: {}", e))
            }
            Err(_) => {
                tracing::warn!(
                    elapsed_ms = start.elapsed().as_millis(),
                    "Docker ping timed out after {:?}",
                    DOCKER_CONNECT_TIMEOUT
                );
                Err(anyhow::anyhow!(
                    "Docker connection timed out after {:?}",
                    DOCKER_CONNECT_TIMEOUT
                ))
            }
        }
    }

    async fn get_subnets_from_docker_networks(
        &self,
        daemon_id: Uuid,
        network_id: Uuid,
        client: &Docker,
        discovery_type: DiscoveryType,
    ) -> Result<Vec<Subnet>, Error> {
        let subnets: Vec<Subnet> = client
            .list_networks(None::<ListNetworksOptions>)
            .await?
            .into_iter()
            .filter_map(|n| {
                let driver = n.driver.as_deref().unwrap_or("bridge");

                // Include Docker networks that can be scanned
                // Skip: host (no separate CIDR), none (no networking), null (invalid)
                let subnet_type = match driver {
                    "bridge" | "overlay" => SubnetType::DockerBridge,
                    "macvlan" => SubnetType::MacVlan,
                    "ipvlan" => SubnetType::IpVlan,
                    _ => {
                        tracing::trace!(
                            network_name = ?n.name,
                            driver = driver,
                            "Skipping unsupported Docker network driver"
                        );
                        return None;
                    }
                };

                let network_name = n.name.clone().unwrap_or("Unknown Network".to_string());
                n.ipam.clone().map(|ipam| (network_name, ipam, subnet_type))
            })
            .filter_map(|(network_name, ipam, subnet_type)| {
                ipam.config
                    .map(|config| (network_name, config, subnet_type))
            })
            .flat_map(|(network_name, configs, subnet_type)| {
                configs
                    .iter()
                    .filter_map(|c| {
                        if let Some(cidr) = &c.subnet {
                            return Some(Subnet::new(SubnetBase {
                                cidr: IpCidr::from_str(cidr).ok()?,
                                description: None,
                                tags: Vec::new(),
                                network_id,
                                name: network_name.clone(),
                                subnet_type,
                                source: EntitySource::Discovery {
                                    metadata: vec![DiscoveryMetadata::new(
                                        discovery_type.clone(),
                                        daemon_id,
                                    )],
                                },
                            }));
                        }
                        None
                    })
                    .collect::<Vec<Subnet>>()
            })
            .collect();

        Ok(subnets)
    }

    async fn get_own_routing_table_gateway_ips(&self) -> Result<Vec<IpAddr>, Error> {
        let routing_handle = Handle::new()?;
        let routes = routing_handle.list().await?;

        Ok(routes
            .into_iter()
            .filter_map(|r| match r.gateway {
                Some(gateway) if gateway != r.destination => Some(gateway),
                _ => None,
            })
            .collect())
    }

    /// Get optimal concurrency for ARP scanning (OS-specific due to BPF limits on macOS)
    fn get_optimal_arp_concurrency(&self) -> Result<usize, Error>;

    /// Get optimal concurrency for deep port scanning.
    ///
    /// # Arguments
    /// * `port_batch_size` - Number of ports scanned concurrently per host in deep scan
    /// * `arp_subnet_count` - Number of ARP datalink channels currently open (2 FDs each)
    fn get_optimal_deep_scan_concurrency(
        &self,
        port_batch_size: usize,
        arp_subnet_count: usize,
    ) -> Result<usize, Error>;

    /// Get optimal number of concurrent host scans and port batch size.
    /// Batch-prioritized: use configured batch size, then calculate concurrent hosts.
    /// Returns both values since they must be calculated together to stay within FD limits.
    async fn get_optimal_concurrent_scans(
        &self,
        concurrency_config_value: usize,
        port_batch_config_value: usize,
    ) -> Result<ScanConcurrencyParams, Error> {
        let fd_limit = Self::get_fd_limit()?;

        // Reserve FDs for daemon operations
        let reserved = 203;
        let available = fd_limit.saturating_sub(reserved);

        // FD usage per host (besides port batch)
        let endpoint_fds_per_host = 25;
        let overhead_per_host = 20;
        let fixed_fds_per_host = endpoint_fds_per_host + overhead_per_host;

        // Use configured batch size, clamped to reasonable bounds
        let port_batch_size = port_batch_config_value.clamp(16, 1000);

        // Calculate how many concurrent hosts we can afford with this batch size
        let fds_per_host = port_batch_size + fixed_fds_per_host;
        let calculated_concurrent = available / fds_per_host;

        // Bound concurrent hosts (min 1, max 50)
        let optimal_concurrent = calculated_concurrent.clamp(1, 50);

        let concurrent_scans = if concurrency_config_value != 15 {
            // User override - respect it but warn if it exceeds budget
            let max_safe = available / fds_per_host;
            if concurrency_config_value > max_safe {
                tracing::warn!(
                    configured = %concurrency_config_value,
                    max_safe = %max_safe,
                    fd_limit = %fd_limit,
                    "Configured concurrent_scans exceeds FD budget, may cause EMFILE errors"
                );
            }
            tracing::info!(
                "Using configured concurrent_scans={} (automatic would be {}, \
                 with port_batch={})",
                concurrency_config_value,
                optimal_concurrent,
                port_batch_size
            );
            concurrency_config_value
        } else {
            // Use automatic
            tracing::info!(
                concurrent_scans = %optimal_concurrent,
                port_batch = %port_batch_size,
                fd_limit = %fd_limit,
                fd_available = %available,
                fds_per_host = %fds_per_host,
                "Using automatic concurrent_scans",
            );
            optimal_concurrent
        };

        if concurrent_scans < 5 {
            tracing::warn!(
                fd_limit = %fd_limit,
                concurrent_scans = %concurrent_scans,
                port_batch = %port_batch_size,
                "Low concurrency due to FD limits. Consider increasing ulimit or reducing port_scan_batch_size.",
            );
        }

        Ok(ScanConcurrencyParams {
            concurrent_scans,
            port_batch_size,
        })
    }
}

/// Merge host (physical) and Docker subnets, giving host subnets precedence.
/// - Host subnets are always kept
/// - Docker subnets with CIDRs matching host subnets are dropped (host wins)
/// - DockerBridge subnets are dropped (handled by Docker discovery)
pub fn merge_host_and_docker_subnets(
    host_subnets: Vec<Subnet>,
    docker_subnets: Vec<Subnet>,
) -> Vec<Subnet> {
    let host_cidrs: HashSet<IpCidr> = host_subnets.iter().map(|s| s.base.cidr).collect();

    let filtered_docker: Vec<Subnet> = docker_subnets
        .into_iter()
        .filter(|s| {
            let dominated_by_host = host_cidrs.contains(&s.base.cidr);
            let is_docker_bridge =
                s.base.subnet_type.discriminant() == SubnetTypeDiscriminants::DockerBridge;
            let keep = !dominated_by_host && !is_docker_bridge;
            if !keep {
                tracing::debug!(
                    cidr = %s.base.cidr,
                    dominated_by_host,
                    is_docker_bridge,
                    "Filtering out Docker subnet (host takes precedence)"
                );
            }
            keep
        })
        .collect();

    [host_subnets, filtered_docker].concat()
}

#[cfg(target_os = "linux")]
use crate::daemon::utils::linux::LinuxDaemonUtils;
#[cfg(target_os = "linux")]
pub type PlatformDaemonUtils = LinuxDaemonUtils;

#[cfg(target_os = "macos")]
use crate::daemon::utils::macos::MacOsDaemonUtils;
#[cfg(target_os = "macos")]
pub type PlatformDaemonUtils = MacOsDaemonUtils;

#[cfg(target_family = "windows")]
use crate::daemon::utils::windows::WindowsDaemonUtils;
#[cfg(target_family = "windows")]
pub type PlatformDaemonUtils = WindowsDaemonUtils;

pub fn create_system_utils() -> PlatformDaemonUtils {
    PlatformDaemonUtils::new()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::shared::storage::traits::Storable;
    use crate::server::shared::types::entities::EntitySource;
    use std::str::FromStr;

    fn make_subnet(cidr: &str, subnet_type: SubnetType) -> Subnet {
        Subnet::new(SubnetBase {
            cidr: IpCidr::from_str(cidr).unwrap(),
            network_id: Uuid::nil(),
            name: String::new(),
            description: None,
            subnet_type,
            source: EntitySource::Manual,
            tags: Vec::new(),
        })
    }

    #[test]
    fn macvlan_overlap_keeps_physical_only() {
        let host = vec![make_subnet("192.168.1.0/24", SubnetType::Lan)];
        let docker = vec![make_subnet("192.168.1.0/24", SubnetType::MacVlan)];

        let result = merge_host_and_docker_subnets(host, docker);
        assert_eq!(result.len(), 1);
        assert_eq!(result[0].base.subnet_type, SubnetType::Lan);
    }

    #[test]
    fn docker_bridge_always_filtered() {
        let host = vec![];
        let docker = vec![make_subnet("172.17.0.0/16", SubnetType::DockerBridge)];

        let result = merge_host_and_docker_subnets(host, docker);
        assert!(result.is_empty());
    }

    #[test]
    fn no_overlap_keeps_both() {
        let host = vec![make_subnet("192.168.1.0/24", SubnetType::Lan)];
        let docker = vec![make_subnet("10.0.0.0/8", SubnetType::IpVlan)];

        let result = merge_host_and_docker_subnets(host, docker);
        assert_eq!(result.len(), 2);
    }

    #[test]
    fn mixed_keeps_physical_and_non_overlapping_non_bridge() {
        let host = vec![make_subnet("192.168.1.0/24", SubnetType::Lan)];
        let docker = vec![
            make_subnet("192.168.1.0/24", SubnetType::MacVlan),
            make_subnet("172.17.0.0/16", SubnetType::DockerBridge),
            make_subnet("10.0.0.0/8", SubnetType::IpVlan),
        ];

        let result = merge_host_and_docker_subnets(host, docker);
        assert_eq!(result.len(), 2);
        assert_eq!(result[0].base.subnet_type, SubnetType::Lan);
        assert_eq!(result[1].base.subnet_type, SubnetType::IpVlan);
    }

    /// Integration test: exercises real Docker API + real host interfaces.
    /// Requires Docker running with a macvlan network overlapping the host LAN CIDR.
    /// Run with: cargo test --lib -- daemon::utils::base::tests::real_docker --ignored
    #[tokio::test]
    #[ignore]
    async fn real_docker_macvlan_overlap_preserves_lan() {
        let utils = create_system_utils();
        let daemon_id = Uuid::nil();
        let network_id = Uuid::nil();

        // Get host subnets from real interfaces
        let (_, host_subnets, _) = utils
            .get_own_interfaces(
                crate::server::discovery::r#impl::types::DiscoveryType::SelfReport {
                    host_id: Uuid::nil(),
                },
                daemon_id,
                network_id,
                &[],
            )
            .await
            .expect("Failed to get own interfaces");

        // Get Docker subnets from real Docker daemon
        let docker_client = utils
            .new_local_docker_client(Ok(None), Ok(None))
            .await
            .expect("Docker not available — start Docker and create macvlan-lan-overlap network");

        let docker_subnets = utils
            .get_subnets_from_docker_networks(
                daemon_id,
                network_id,
                &docker_client,
                crate::server::discovery::r#impl::types::DiscoveryType::SelfReport {
                    host_id: Uuid::nil(),
                },
            )
            .await
            .expect("Failed to get Docker networks");

        // Find our LAN CIDR from host subnets
        let lan_cidrs: Vec<_> = host_subnets.iter().map(|s| s.base.cidr).collect();
        println!("Host subnet CIDRs: {:?}", lan_cidrs);

        // Verify Docker has at least one macvlan overlapping a host CIDR
        let overlapping_docker: Vec<_> = docker_subnets
            .iter()
            .filter(|s| {
                lan_cidrs.contains(&s.base.cidr) && s.base.subnet_type != SubnetType::DockerBridge
            })
            .collect();
        println!(
            "Docker subnets overlapping host CIDRs: {:?}",
            overlapping_docker
                .iter()
                .map(|s| format!("{} ({:?})", s.base.cidr, s.base.subnet_type))
                .collect::<Vec<_>>()
        );
        assert!(
            !overlapping_docker.is_empty(),
            "No Docker macvlan/ipvlan overlapping host CIDRs found. \
             Create one with: docker network create -d macvlan --subnet=<your-lan-cidr> macvlan-lan-overlap"
        );

        // THE FIX: merge should keep the host subnet, drop the Docker duplicate
        let merged = merge_host_and_docker_subnets(host_subnets.clone(), docker_subnets.clone());

        // Every host subnet CIDR must survive
        for host_subnet in &host_subnets {
            assert!(
                merged.iter().any(|s| s.base.cidr == host_subnet.base.cidr),
                "Host subnet {} was incorrectly filtered out!",
                host_subnet.base.cidr
            );
        }

        // No DockerBridge subnets should survive
        assert!(
            !merged
                .iter()
                .any(|s| s.base.subnet_type == SubnetType::DockerBridge),
            "DockerBridge subnets should be filtered out"
        );

        // The overlapping Docker macvlan should NOT appear as a separate entry
        // (host subnet with that CIDR already covers it)
        let merged_cidrs: Vec<_> = merged.iter().map(|s| s.base.cidr).collect();
        for ds in &overlapping_docker {
            let count = merged_cidrs.iter().filter(|c| **c == ds.base.cidr).count();
            assert_eq!(
                count, 1,
                "CIDR {} appears {} times — should appear exactly once (host version only)",
                ds.base.cidr, count
            );
        }

        println!(
            "PASS: {} host subnets preserved, {} docker subnets filtered, {} total merged",
            host_subnets.len(),
            docker_subnets.len() - (merged.len() - host_subnets.len()),
            merged.len()
        );
    }
}
