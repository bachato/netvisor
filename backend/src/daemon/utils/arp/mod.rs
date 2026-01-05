//! ARP scanning module with platform-specific implementations.
//!
//! ## Platform Behavior
//!
//! | Platform | Default Method       | Optional Method      | Fallback   |
//! |----------|---------------------|---------------------|------------|
//! | Linux    | Broadcast ARP (pnet) | -                   | Port scan  |
//! | macOS    | Broadcast ARP (pnet) | -                   | Port scan  |
//! | Windows  | SendARP (iphlpapi)   | Broadcast (Npcap)   | Port scan  |

pub mod broadcast;
pub mod sendarp;
pub mod types;

use std::net::Ipv4Addr;

use anyhow::Result;
use mac_address::MacAddress;
use pnet::datalink::NetworkInterface;

pub use types::ArpScanResult;

/// Scan a subnet using the platform-appropriate ARP method.
///
/// # Arguments
/// * `interface` - Network interface to use for scanning
/// * `source_ip` - Source IP address for ARP requests
/// * `source_mac` - Source MAC address for ARP requests
/// * `targets` - List of target IPs to scan
/// * `use_npcap` - (Windows only) Use Npcap broadcast ARP instead of SendARP
///
/// # Returns
/// List of responsive hosts with their MAC addresses
pub async fn scan_subnet(
    interface: &NetworkInterface,
    source_ip: Ipv4Addr,
    source_mac: MacAddress,
    targets: Vec<Ipv4Addr>,
    use_npcap: bool,
) -> Result<Vec<ArpScanResult>> {
    #[cfg(target_family = "windows")]
    {
        if use_npcap {
            match broadcast::scan_subnet(interface, source_ip, source_mac, targets.clone()).await {
                Ok(results) => {
                    tracing::debug!(
                        responsive = results.len(),
                        "Npcap broadcast ARP scan succeeded"
                    );
                    return Ok(results);
                }
                Err(e) => {
                    tracing::warn!(
                        error = %e,
                        "Npcap broadcast ARP failed, falling back to SendARP"
                    );
                    // Fall through to sendarp
                }
            }
        }
        return sendarp::scan_subnet(targets).await;
    }

    #[cfg(not(target_family = "windows"))]
    {
        let _ = use_npcap; // unused on non-Windows
        broadcast::scan_subnet(interface, source_ip, source_mac, targets).await
    }
}

/// Check if ARP scanning is available on this platform.
///
/// # Arguments
/// * `use_npcap` - (Windows only) Check for Npcap availability instead of SendARP
///
/// # Returns
/// `true` if the selected ARP method is available
pub fn is_available(use_npcap: bool) -> bool {
    #[cfg(target_family = "windows")]
    {
        if use_npcap {
            let available = broadcast::is_available();
            tracing::debug!(
                available = available,
                method = "Npcap broadcast",
                "Checking ARP availability"
            );
            available
        } else {
            // SendARP is always available on Windows
            tracing::debug!(
                available = true,
                method = "SendARP",
                "Checking ARP availability"
            );
            true
        }
    }

    #[cfg(not(target_family = "windows"))]
    {
        let _ = use_npcap;
        let available = broadcast::is_available();
        tracing::debug!(
            available = available,
            method = "broadcast",
            "Checking ARP availability"
        );
        available
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_available_returns_bool() {
        // Just verify it doesn't panic and returns a boolean
        let _result = is_available(false);
        let _result_npcap = is_available(true);
    }
}
