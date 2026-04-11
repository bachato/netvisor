use std::sync::Arc;
use tokio::sync::RwLock;

use jsonwebtoken::{Algorithm, Validation};

use super::{
    keys::decoding_key,
    types::{LicenseClaims, LicenseStatus},
};

pub struct LicenseService {
    status: Arc<RwLock<LicenseStatus>>,
    license_key_raw: Option<String>,
}

impl LicenseService {
    /// Create a new license service.
    ///
    /// - `license_key`: the raw JWT string from `SCANOPY_LICENSE_KEY`
    /// - `is_commercial`: whether the server was built with `--features commercial`
    pub fn new(license_key: Option<String>, is_commercial: bool) -> Self {
        let status = if !is_commercial {
            LicenseStatus::NotRequired
        } else {
            match &license_key {
                None => LicenseStatus::Invalid("No license key provided".to_string()),
                Some(key) => Self::validate_key(key),
            }
        };

        Self {
            status: Arc::new(RwLock::new(status)),
            license_key_raw: license_key,
        }
    }

    /// Validate a license key JWT and return the resulting status.
    pub fn validate_key(key: &str) -> LicenseStatus {
        let mut validation = Validation::new(Algorithm::EdDSA);
        validation.set_issuer(&["scanopy"]);
        validation.set_required_spec_claims(&["sub", "iss", "iat", "exp"]);
        // Don't auto-validate exp — we check manually to distinguish Expired vs Invalid
        validation.validate_exp = false;

        match jsonwebtoken::decode::<LicenseClaims>(key, &decoding_key(), &validation) {
            Ok(token_data) => {
                if token_data.claims.sub != "scanopy-license" {
                    return LicenseStatus::Invalid("Invalid subject claim".to_string());
                }

                let now = chrono::Utc::now().timestamp();
                if token_data.claims.exp < now {
                    LicenseStatus::Expired(token_data.claims)
                } else {
                    LicenseStatus::Valid(token_data.claims)
                }
            }
            Err(e) => LicenseStatus::Invalid(e.to_string()),
        }
    }

    /// Get the current license status.
    pub async fn current_status(&self) -> LicenseStatus {
        self.status.read().await.clone()
    }

    /// Re-validate the license key. Called by the periodic background task
    /// to catch time-based expiry transitions without requiring a restart.
    pub async fn revalidate(&self) {
        if let Some(key) = &self.license_key_raw {
            let new_status = Self::validate_key(key);
            let mut status = self.status.write().await;

            let was_locked = status.is_locked();
            let now_locked = new_status.is_locked();

            if was_locked != now_locked {
                if now_locked {
                    tracing::warn!(
                        target: "server",
                        "License status changed to locked: {}",
                        new_status.as_api_string().unwrap_or("unknown")
                    );
                } else {
                    tracing::info!(
                        target: "server",
                        "License status changed to valid"
                    );
                }
            }

            *status = new_status;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn community_build_not_required() {
        let service = LicenseService::new(None, false);
        let status = service.status.blocking_read();
        assert!(!status.is_locked());
        assert_eq!(status.as_api_string(), None);
    }

    #[test]
    fn commercial_build_no_key_is_invalid() {
        let service = LicenseService::new(None, true);
        let status = service.status.blocking_read();
        assert!(status.is_locked());
        assert_eq!(status.as_api_string(), Some("invalid"));
    }

    #[test]
    fn commercial_build_garbage_key_is_invalid() {
        let service = LicenseService::new(Some("not-a-jwt".to_string()), true);
        let status = service.status.blocking_read();
        assert!(status.is_locked());
        assert_eq!(status.as_api_string(), Some("invalid"));
    }
}
