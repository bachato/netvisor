use crate::server::snmp_credentials::r#impl::base::SnmpCredential;
use crate::server::snmp_credentials::r#impl::base::SnmpVersion;
use redact::Secret;
use secrecy::ExposeSecret;
use serde::Deserialize;
use serde::Serialize;
use std::net::IpAddr;
use utoipa::ToSchema;

/// Minimal SNMP credential for daemon queries (version + community only)
/// Does not include organization_id, name, timestamps - just what's needed for SNMP queries
///
/// The community string is wrapped in `Secret` to prevent accidental exposure in logs,
/// debug output, and API responses. Use `community.expose_secret()` for explicit access
/// (e.g. daemon SNMP sessions).
#[derive(Clone, Serialize, Deserialize, Eq, PartialEq, Hash, Default, ToSchema)]
pub struct SnmpQueryCredential {
    /// SNMP version (V2c or V3)
    #[serde(default)]
    pub version: SnmpVersion,
    /// SNMPv2c community string — redacted in serialization/debug by default
    #[serde(serialize_with = "redact::serde::redact_secret")]
    #[schema(value_type = String)]
    pub community: Secret<String>,
}

impl std::fmt::Debug for SnmpQueryCredential {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SnmpQueryCredential")
            .field("version", &self.version)
            .field("community", &"[REDACTED]")
            .finish()
    }
}

impl From<SnmpCredential> for SnmpQueryCredential {
    fn from(value: SnmpCredential) -> Self {
        Self {
            version: value.base.version,
            community: Secret::from(value.base.community.expose_secret().to_string()),
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

    /// Serialize with community strings exposed as plaintext.
    /// Used ONLY for daemon transmission where the daemon needs actual credentials.
    pub fn to_exposed_value(&self) -> serde_json::Value {
        serde_json::json!({
            "default_credential": self.default_credential.as_ref().map(|c| serde_json::json!({
                "version": c.version,
                "community": c.community.expose_secret()
            })),
            "ip_overrides": self.ip_overrides.iter().map(|o| serde_json::json!({
                "ip": o.ip,
                "credential": {
                    "version": o.credential.version,
                    "community": o.credential.community.expose_secret()
                }
            })).collect::<Vec<_>>()
        })
    }
}
