use serde::{Deserialize, Serialize};

/// JWT claims encoded in a Scanopy license key.
///
/// The license key is purely an authorization gate — it proves the server
/// is licensed to run. Plan entitlements come from the CommercialSelfHosted
/// plan, not from the key itself.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LicenseClaims {
    /// Subject — always "scanopy-license"
    pub sub: String,
    /// Issuer — always "scanopy"
    pub iss: String,
    /// Issued-at (unix timestamp)
    pub iat: i64,
    /// Expiry (unix timestamp)
    pub exp: i64,
    /// Organization ID — populated when Cloud-provisioned (future)
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub org_id: Option<String>,
}

/// Runtime license state, checked by middleware on every request.
#[derive(Debug, Clone)]
pub enum LicenseStatus {
    /// License validation not required (community build)
    NotRequired,
    /// Valid commercial license
    Valid(LicenseClaims),
    /// Valid signature but past expiry date
    Expired(LicenseClaims),
    /// Invalid key (bad signature, malformed, or missing when required)
    Invalid(String),
}

impl LicenseStatus {
    /// Whether the server should be in read-only locked state.
    pub fn is_locked(&self) -> bool {
        matches!(self, LicenseStatus::Expired(_) | LicenseStatus::Invalid(_))
    }

    /// Status string for the public config API response.
    pub fn as_api_string(&self) -> Option<&'static str> {
        match self {
            LicenseStatus::NotRequired => None,
            LicenseStatus::Valid(_) => Some("valid"),
            LicenseStatus::Expired(_) => Some("expired"),
            LicenseStatus::Invalid(_) => Some("invalid"),
        }
    }
}
