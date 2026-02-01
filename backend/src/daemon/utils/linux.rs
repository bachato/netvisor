#[cfg(target_os = "linux")]
use crate::daemon::utils::base::DaemonUtils;

#[cfg(target_os = "linux")]
pub struct LinuxDaemonUtils;

#[cfg(target_os = "linux")]
use anyhow::{Error, Result, anyhow};
#[cfg(target_os = "linux")]
use async_trait::async_trait;
#[cfg(target_os = "linux")]
use mac_address::MacAddress;
#[cfg(target_os = "linux")]
use std::net::IpAddr;
#[cfg(target_os = "linux")]
#[async_trait]
impl DaemonUtils for LinuxDaemonUtils {
    fn new() -> Self {
        Self {}
    }

    fn get_fd_limit() -> Result<usize, Error> {
        use libc::{RLIMIT_NOFILE, getrlimit, rlimit};

        let mut rlim = rlimit {
            rlim_cur: 0,
            rlim_max: 0,
        };

        let result = unsafe { getrlimit(RLIMIT_NOFILE, &mut rlim as *mut rlimit) };

        if result == 0 {
            Ok(rlim.rlim_cur as usize)
        } else {
            Err(anyhow!("Failed to get file descriptor limit"))
        }
    }

    fn get_optimal_arp_concurrency(&self) -> Result<usize, Error> {
        // Linux doesn't have the same BPF limitations as macOS
        // Can run more concurrent ARP scans, but still bound by fd limit
        let fd_limit = Self::get_fd_limit()?;
        let reserved = 203;
        let available = fd_limit.saturating_sub(reserved);

        // Each ARP scan holds a raw socket briefly
        // Allow up to 50 concurrent or 10% of available fds, whichever is smaller
        let concurrency = std::cmp::min(50, available / 10);
        let concurrency = std::cmp::max(1, concurrency);

        tracing::debug!(
            fd_limit = fd_limit,
            available = available,
            concurrency = concurrency,
            "Calculated ARP concurrency"
        );

        Ok(concurrency)
    }

    fn get_optimal_deep_scan_concurrency(
        &self,
        port_batch_size: usize,
        arp_subnet_count: usize,
    ) -> Result<usize, Error> {
        let fd_limit = Self::get_fd_limit()?;

        // Base reserved file descriptors:
        // - stdin, stdout, stderr (3)
        // - HTTP client connections for endpoints (50)
        // - Docker socket and other daemon operations (50)
        // - Async channels and miscellaneous (50)
        // - Safety buffer (50)
        let base_reserved = 203;

        // FDs consumed by ARP channels (2 FDs per subnet: tx + rx)
        let arp_fds = arp_subnet_count * 2;

        let total_reserved = base_reserved + arp_fds;
        let available = fd_limit.saturating_sub(total_reserved);

        // Calculate FDs consumed per deep-scanned host:
        // - TCP port scanning: port_batch_size concurrent connections
        // - Endpoint HTTP: min(port_batch_size/2, 50) concurrent requests
        // - UDP probes: ~10 concurrent (SNMP, DNS, NTP, DHCP, BACnet)
        let endpoint_batch = (port_batch_size / 2).min(50);
        let udp_probes = 10;
        let fds_per_deep_host = port_batch_size + endpoint_batch + udp_probes;

        let concurrency = std::cmp::max(1, available / fds_per_deep_host);

        tracing::debug!(
            fd_limit,
            base_reserved,
            arp_fds,
            total_reserved,
            available,
            port_batch_size,
            fds_per_deep_host,
            concurrency,
            arp_subnet_count,
            "Calculated deep scan concurrency"
        );

        Ok(concurrency)
    }

    async fn get_mac_address_for_ip(&self, ip: IpAddr) -> Result<Option<MacAddress>, Error> {
        use procfs::net;

        let ipv4_addr = match ip {
            IpAddr::V4(addr) => addr,
            IpAddr::V6(_) => return Ok(None), // IPv6 ARP not supported yet
        };

        let arp_table = net::arp()
            .map_err(|e| anyhow!("Failed to read ARP table from /proc/net/arp: {}", e))?;

        for entry in arp_table {
            if entry.ip_address == ipv4_addr
                && let Some(hw_addr) = entry.hw_address
            {
                let mac = MacAddress::new(hw_addr);
                return Ok(Some(mac));
            }
        }

        Ok(None)
    }
}
