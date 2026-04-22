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
    /// Hard expiry (unix timestamp). The verifier rejects the key once
    /// `now > exp`. This is always 7 days past `intended_exp` for keys
    /// issued after the grace-period feature; the extra week is a silent
    /// runway during which the UI warns the user to rotate keys.
    pub exp: i64,
    /// User-visible expiry (unix timestamp). CLI output and the UI show
    /// this as the license "expires on" date. When `intended_exp < now <= exp`
    /// the key is in its grace window.
    ///
    /// Optional only to stay compatible with keys issued before this field
    /// existed; all newly-issued keys populate it.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub intended_exp: Option<i64>,
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

    /// Hard expiry date as ISO date string (e.g. "2027-04-11"), if available.
    pub fn expiry_date(&self) -> Option<String> {
        let claims = match self {
            LicenseStatus::Valid(c) | LicenseStatus::Expired(c) => c,
            _ => return None,
        };
        chrono::DateTime::from_timestamp(claims.exp, 0).map(|d| d.format("%Y-%m-%d").to_string())
    }

    /// User-visible expiry date as ISO date string, if available. Falls back
    /// to `exp` for legacy keys issued before `intended_exp` existed.
    pub fn intended_expiry_date(&self) -> Option<String> {
        let claims = match self {
            LicenseStatus::Valid(c) | LicenseStatus::Expired(c) => c,
            _ => return None,
        };
        let ts = claims.intended_exp.unwrap_or(claims.exp);
        chrono::DateTime::from_timestamp(ts, 0).map(|d| d.format("%Y-%m-%d").to_string())
    }

    /// Whether the license is currently in its grace window —
    /// `intended_exp < now <= exp`. The server still accepts the key
    /// but the UI should warn the user to rotate it.
    pub fn in_grace_period(&self) -> bool {
        self.in_grace_period_at(chrono::Utc::now().timestamp())
    }

    /// Grace-period check against a caller-supplied `now`, for tests.
    pub fn in_grace_period_at(&self, now: i64) -> bool {
        let LicenseStatus::Valid(claims) = self else {
            return false;
        };
        let Some(intended_exp) = claims.intended_exp else {
            return false;
        };
        intended_exp < now && now <= claims.exp
    }
}
