use crate::server::snmp_credentials::r#impl::base::SnmpCredential;
use crate::server::snmp_credentials::r#impl::base::SnmpVersion;
use secrecy::ExposeSecret;
use serde::Deserialize;
use serde::Serialize;
use std::net::IpAddr;
use utoipa::ToSchema;

/// Minimal SNMP credential for daemon queries (version + community only)
/// Does not include organization_id, name, timestamps - just what's needed for SNMP queries
#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq, Hash, Default, ToSchema)]
pub struct SnmpQueryCredential {
    /// SNMP version (V2c or V3)
    #[serde(default)]
    pub version: SnmpVersion,
    /// SNMPv2c community string
    pub community: String,
}

impl From<SnmpCredential> for SnmpQueryCredential {
    fn from(value: SnmpCredential) -> Self {
        Self {
            version: value.base.version,
            community: value.base.community.expose_secret().to_string(),
        }
    }
}

/// IP-specific SNMP credential override
#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema)]
pub struct SnmpIpOverride {
    /// IP address for this override
    #[schema(value_type = String)]
    pub ip: IpAddr,
    /// Credential to use for this IP
    pub credential: SnmpQueryCredential,
}

/// SNMP credential mapping for network discovery
/// Server builds this before initiating discovery; daemon uses it during scan
#[derive(Debug, Clone, Default, Serialize, Deserialize, Eq, PartialEq, Hash, ToSchema)]
pub struct SnmpCredentialMapping {
    /// Network default credential (used when IP not in overrides)
    #[serde(default)]
    pub default_credential: Option<SnmpQueryCredential>,
    /// Per-IP overrides (from host.snmp_credential_id where host has known IPs)
    #[serde(default)]
    pub ip_overrides: Vec<SnmpIpOverride>,
}

impl SnmpCredentialMapping {
    /// Get credential for a specific IP, falling back to default
    pub fn get_credential_for_ip(&self, ip: &IpAddr) -> Option<SnmpQueryCredential> {
        self.ip_overrides
            .iter()
            .find(|o| &o.ip == ip)
            .map(|o| o.credential.clone())
            .or(self.default_credential.clone())
    }

    /// Check if SNMP is enabled (has at least a default or override)
    pub fn is_enabled(&self) -> bool {
        self.default_credential.is_some() || !self.ip_overrides.is_empty()
    }

    /// Create a sanitized copy with community strings redacted.
    /// Used when storing EntitySource to prevent credential leakage in API responses.
    pub fn sanitized(&self) -> Self {
        Self {
            default_credential: self
                .default_credential
                .as_ref()
                .map(|c| SnmpQueryCredential {
                    version: c.version,
                    community: "********".to_string(),
                }),
            ip_overrides: self
                .ip_overrides
                .iter()
                .map(|o| SnmpIpOverride {
                    ip: o.ip,
                    credential: SnmpQueryCredential {
                        version: o.credential.version,
                        community: "********".to_string(),
                    },
                })
                .collect(),
        }
    }
}
