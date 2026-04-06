use chrono::{DateTime, Utc};
use serde::{Deserialize, Deserializer, Serialize};
use std::fmt::Display;
use strum_macros::EnumIter;
use utoipa::ToSchema;
use uuid::Uuid;
use validator::Validate;

use crate::server::{
    billing::types::base::BillingPlan,
    shared::{entities::ChangeTriggersTopologyStaleness, events::types::OnboardingOperation},
};

#[derive(
    Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize, Default, EnumIter, ToSchema,
)]
#[serde(rename_all = "lowercase")]
pub enum UseCase {
    Homelab,
    Company,
    Msp,
    #[default]
    Other,
}

/// Deserialize UseCase from an Option<String>, mapping null to UseCase::Other.
fn deserialize_use_case_from_option<'de, D>(deserializer: D) -> Result<UseCase, D::Error>
where
    D: Deserializer<'de>,
{
    let opt: Option<String> = Option::deserialize(deserializer)?;
    match opt.as_deref() {
        Some("homelab") => Ok(UseCase::Homelab),
        Some("company") => Ok(UseCase::Company),
        Some("msp") => Ok(UseCase::Msp),
        Some("other") => Ok(UseCase::Other),
        _ => Ok(UseCase::Other),
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq, Hash)]
pub enum LimitNotificationLevel {
    #[default]
    None,
    Approaching,
    Reached,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq, Hash)]
pub struct PlanLimitNotifications {
    pub hosts: LimitNotificationLevel,
    pub networks: LimitNotificationLevel,
    pub seats: LimitNotificationLevel,
}

#[derive(
    Debug, Clone, Serialize, Validate, Deserialize, Default, PartialEq, Eq, Hash, ToSchema,
)]
pub struct OrganizationBase {
    /// Stripe customer ID - internal, not exposed to API
    #[serde(default, skip_serializing)]
    pub stripe_customer_id: Option<String>,
    #[validate(length(min = 0, max = 100))]
    pub name: String,
    #[serde(default)]
    #[schema(read_only, required)]
    pub plan: Option<BillingPlan>,
    #[serde(default)]
    #[schema(read_only, required)]
    pub plan_status: Option<String>,
    #[schema(read_only, required)]
    pub onboarding: Vec<OnboardingOperation>,
    #[serde(default)]
    #[schema(read_only)]
    pub has_payment_method: bool,
    #[serde(default)]
    #[schema(read_only)]
    pub trial_end_date: Option<DateTime<Utc>>,
    /// Brevo company ID - internal, not exposed to API
    #[serde(default, skip_serializing)]
    pub brevo_company_id: Option<String>,
    /// Tracks which plan limit notification levels have been sent
    #[serde(default, skip_serializing)]
    pub plan_limit_notifications: PlanLimitNotifications,
    /// Use case selection (homelab, company, msp, other)
    #[serde(default, deserialize_with = "deserialize_use_case_from_option")]
    pub use_case: UseCase,
}

#[derive(
    Debug, Clone, Validate, Serialize, Deserialize, PartialEq, Eq, Hash, Default, ToSchema,
)]
pub struct Organization {
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
    pub base: OrganizationBase,
}

impl Organization {
    pub fn not_onboarded(&self, step: &OnboardingOperation) -> bool {
        !self.base.onboarding.contains(step)
    }

    pub fn has_onboarded(&self, step: &OnboardingOperation) -> bool {
        self.base.onboarding.contains(step)
    }
}

impl Display for Organization {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}: {:?}", self.base.name, self.id)
    }
}

impl ChangeTriggersTopologyStaleness<Organization> for Organization {
    fn triggers_staleness(&self, _other: Option<Organization>) -> bool {
        false
    }
}
