//! SNMP Session Management
//!
//! Functions for creating and managing SNMP sessions.

use anyhow::{Result, anyhow};
use snmp2::AsyncSession;
use std::net::IpAddr;
use std::time::Duration;

use crate::server::snmp_credentials::r#impl::base::SnmpVersion;
use crate::server::snmp_credentials::r#impl::discovery::SnmpQueryCredential;

/// Default timeout for SNMP operations
pub const SNMP_TIMEOUT: Duration = Duration::from_secs(5);

/// Default timeout for table walks (longer since they involve multiple requests)
pub const SNMP_WALK_TIMEOUT: Duration = Duration::from_secs(30);

/// Maximum number of varbinds to process in a single walk
pub const MAX_WALK_ENTRIES: usize = 10000;

/// Create an SNMP session with the given credentials
pub async fn create_session(ip: IpAddr, credential: &SnmpQueryCredential) -> Result<AsyncSession> {
    let target = format!("{}:161", ip);

    match credential.version {
        SnmpVersion::V2c => AsyncSession::new_v2c(&target, credential.community.as_bytes(), 0)
            .await
            .map_err(|e| anyhow!("Failed to create SNMPv2c session to {}: {:?}", ip, e)),
        SnmpVersion::V3 => {
            // V3 support would require additional auth/priv parameters
            Err(anyhow!("SNMPv3 not yet implemented"))
        }
    }
}
