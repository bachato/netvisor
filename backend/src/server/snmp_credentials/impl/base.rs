use crate::server::shared::entities::ChangeTriggersTopologyStaleness;
use chrono::{DateTime, Utc};
use secrecy::{ExposeSecret, SecretString};
use serde::{Deserialize, Serialize, Serializer};
use std::fmt::Display;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

fn default_tags() -> Vec<Uuid> {
    Vec::new()
}

/// Serializer that redacts the secret value
fn redact_secret<S>(_secret: &SecretString, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serializer.serialize_str("********")
}

/// SNMP protocol version
#[derive(Debug, Clone, Copy, Serialize, Deserialize, Eq, PartialEq, Hash, Default, ToSchema)]
pub enum SnmpVersion {
    /// SNMPv2c (MVP - community string based)
    #[default]
    V2c,
    /// SNMPv3 (future - authentication + privacy)
    V3,
}

impl Display for SnmpVersion {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SnmpVersion::V2c => write!(f, "V2c"),
            SnmpVersion::V3 => write!(f, "V3"),
        }
    }
}

impl std::str::FromStr for SnmpVersion {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_uppercase().as_str() {
            "V2C" | "2C" | "2" => Ok(SnmpVersion::V2c),
            "V3" | "3" => Ok(SnmpVersion::V3),
            _ => Err(anyhow::anyhow!("Invalid SNMP version: {}", s)),
        }
    }
}

#[derive(Debug, Clone, Validate, Serialize, Deserialize, ToSchema)]
pub struct SnmpCredentialBase {
    pub organization_id: Uuid,
    #[validate(length(
        min = 1,
        max = 100,
        message = "Credential name must be between 1 and 100 characters"
    ))]
    pub name: String,
    /// SNMP version (V2c or V3)
    #[serde(default)]
    pub version: SnmpVersion,
    /// SNMPv2c community string (stored encrypted)
    /// For V3, this would be extended with auth/priv credentials
    /// Redacted in API responses for security
    #[validate(skip)]
    #[serde(serialize_with = "redact_secret")]
    #[schema(value_type = String)]
    pub community: SecretString,
    #[serde(default = "default_tags")]
    #[schema(required)]
    pub tags: Vec<Uuid>,
}

impl Default for SnmpCredentialBase {
    fn default() -> Self {
        Self {
            organization_id: Uuid::nil(),
            name: "New SNMP Credential".to_string(),
            version: SnmpVersion::V2c,
            community: SecretString::from(String::new()),
            tags: Vec::new(),
        }
    }
}

impl PartialEq for SnmpCredentialBase {
    fn eq(&self, other: &Self) -> bool {
        self.organization_id == other.organization_id
            && self.name == other.name
            && self.version == other.version
            && self.community.expose_secret() == other.community.expose_secret()
            && self.tags == other.tags
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, ToSchema, Validate)]
pub struct SnmpCredential {
    #[serde(default)]
    #[schema(read_only, required)]
    pub id: Uuid,
    #[serde(default)]
    #[schema(read_only, required)]
    pub created_at: DateTime<Utc>,
    #[serde(default)]
    #[schema(read_only, required)]
    pub updated_at: DateTime<Utc>,
    #[serde(flatten)]
    #[validate(nested)]
    pub base: SnmpCredentialBase,
}

impl PartialEq for SnmpCredential {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
            && self.created_at == other.created_at
            && self.updated_at == other.updated_at
            && self.base == other.base
    }
}

impl ChangeTriggersTopologyStaleness<SnmpCredential> for SnmpCredential {
    fn triggers_staleness(&self, _other: Option<SnmpCredential>) -> bool {
        false
    }
}

impl Display for SnmpCredential {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "SnmpCredential {}: {} ({})",
            self.id, self.base.name, self.base.version
        )
    }
}

impl SnmpCredential {
    pub fn new(base: SnmpCredentialBase) -> Self {
        let now = Utc::now();
        Self {
            id: Uuid::new_v4(),
            created_at: now,
            updated_at: now,
            base,
        }
    }
}
