use crate::server::shared::types::metadata::EntityMetadataProvider;
use crate::server::shared::types::metadata::HasId;
use crate::server::shared::types::metadata::TypeMetadataProvider;
use crate::server::shared::types::{Color, Icon};
use serde::Deserialize;
use serde::Serialize;
use strum::Display;
use strum::EnumIter;
use strum::IntoStaticStr;

#[derive(Debug, Clone, Serialize, Deserialize, EnumIter, IntoStaticStr, Display, Default)]
pub enum Feature {
    #[default]
    ShareViews,
    OnboardingCall,
    AuditLogs,
    Webhooks,
    RemoveCreatedWith,
    ApiAccess,
    CustomSso,
    ManagedDeployment,
    Whitelabeling,
    CommunitySupport,
    EmailSupport,
    LiveChatSupport,
    PrioritySupport,
    Embeds,
    // Core features
    NetworkDiscovery,
    TopologyVisualization,
    DiagramExport,
    HostInventory,
    ScheduledDiscovery,
    DaemonPoll,
    ServiceDefinitions,
    DockerIntegration,
    SnmpIntegration,
}

impl HasId for Feature {
    fn id(&self) -> &'static str {
        match self {
            Feature::Webhooks => "webhooks",
            Feature::AuditLogs => "audit_logs",
            Feature::ShareViews => "share_views",
            Feature::OnboardingCall => "onboarding_call",
            Feature::RemoveCreatedWith => "remove_created_with",
            Feature::CustomSso => "custom_sso",
            Feature::ManagedDeployment => "managed_deployment",
            Feature::Whitelabeling => "whitelabeling",
            Feature::LiveChatSupport => "live_chat_support",
            Feature::Embeds => "embeds",
            Feature::EmailSupport => "email_support",
            Feature::CommunitySupport => "community_support",
            Feature::PrioritySupport => "priority_support",
            Feature::ApiAccess => "api_access",
            Feature::NetworkDiscovery => "network_discovery",
            Feature::TopologyVisualization => "topology_visualization",
            Feature::DiagramExport => "diagram_export",
            Feature::HostInventory => "host_inventory",
            Feature::ScheduledDiscovery => "scheduled_discovery",
            Feature::DaemonPoll => "daemon_poll",
            Feature::ServiceDefinitions => "service_definitions",
            Feature::DockerIntegration => "docker_integration",
            Feature::SnmpIntegration => "snmp_integration",
        }
    }
}

impl Feature {
    pub fn is_coming_soon(&self) -> bool {
        matches!(self, Feature::Webhooks | Feature::AuditLogs)
    }

    /// Returns the ID of the lowest-tier cloud plan that includes this feature.
    pub fn minimum_plan(&self) -> Option<&'static str> {
        use super::base::{BillingPlan, BillingPlanDiscriminants};

        let feature_id = self.id();
        let cloud_tiers = [
            BillingPlanDiscriminants::Free,
            BillingPlanDiscriminants::Starter,
            BillingPlanDiscriminants::Pro,
            BillingPlanDiscriminants::Business,
            BillingPlanDiscriminants::Enterprise,
        ];

        for disc in &cloud_tiers {
            if let Some(plan) = BillingPlan::default_for_discriminant(*disc)
                && plan.has_feature(feature_id)
            {
                return Some(plan.id());
            }
        }
        None
    }
}

impl EntityMetadataProvider for Feature {
    fn color(&self) -> Color {
        Color::Gray
    }

    fn icon(&self) -> Icon {
        Icon::Sparkle
    }
}

impl TypeMetadataProvider for Feature {
    fn category(&self) -> &'static str {
        match self {
            Feature::NetworkDiscovery
            | Feature::TopologyVisualization
            | Feature::DiagramExport
            | Feature::HostInventory
            | Feature::ScheduledDiscovery
            | Feature::DaemonPoll
            | Feature::ServiceDefinitions
            | Feature::DockerIntegration
            | Feature::SnmpIntegration => "Core",

            Feature::CommunitySupport
            | Feature::EmailSupport
            | Feature::LiveChatSupport
            | Feature::PrioritySupport
            | Feature::OnboardingCall => "Support",

            Feature::CustomSso
            | Feature::ManagedDeployment
            | Feature::Whitelabeling
            | Feature::AuditLogs => "Enterprise",

            Feature::Webhooks | Feature::ApiAccess => "Integrations",

            Feature::Embeds | Feature::ShareViews | Feature::RemoveCreatedWith => "Sharing",
        }
    }

    fn name(&self) -> &'static str {
        match self {
            Feature::AuditLogs => "Audit Logs",
            Feature::Webhooks => "Webhooks",
            Feature::ShareViews => "Shareable Diagrams",
            Feature::OnboardingCall => "Onboarding Call",
            Feature::RemoveCreatedWith => "Remove Watermark",
            Feature::CustomSso => "Custom SSO",
            Feature::ManagedDeployment => "Managed Deployment",
            Feature::Whitelabeling => "White Labeling",
            Feature::LiveChatSupport => "Live Chat Support",
            Feature::Embeds => "Embeddable Diagrams",
            Feature::ApiAccess => "API Access",
            Feature::EmailSupport => "Email Support",
            Feature::CommunitySupport => "Community Support",
            Feature::PrioritySupport => "Priority Support",
            Feature::NetworkDiscovery => "Network Discovery",
            Feature::TopologyVisualization => "Topology Visualization",
            Feature::DiagramExport => "Diagram Export",
            Feature::HostInventory => "Host Inventory",
            Feature::ScheduledDiscovery => "Scheduled Discovery",
            Feature::DaemonPoll => "No Port Forwarding",
            Feature::ServiceDefinitions => "200+ Service Definitions",
            Feature::DockerIntegration => "Docker Integration",
            Feature::SnmpIntegration => "SNMP Integration",
        }
    }

    fn description(&self) -> &'static str {
        match self {
            Feature::AuditLogs => {
                "Track all user actions and data changes for compliance and security"
            }
            Feature::Webhooks => {
                "Push real-time events to external systems when hosts, services, or topology changes"
            }
            Feature::ShareViews => "Share live network diagrams with others",
            Feature::OnboardingCall => {
                "30 minute onboarding call to ensure you're getting the most out of Scanopy"
            }
            Feature::RemoveCreatedWith => {
                "Remove 'Created using scanopy.net' in bottom right corner of exported images"
            }
            Feature::ApiAccess => "Programmatic access to your data in Scanopy via API",
            Feature::PrioritySupport => "Prioritized email support with faster response times",
            Feature::Embeds => "Embed live network diagrams in wikis, dashboards, or documentation",
            Feature::CustomSso => {
                "Use your own identity provider (Okta, Azure AD, etc.) for single sign-on"
            }
            Feature::ManagedDeployment => {
                "We deploy, configure, and manage Scanopy for you on a dedicated instance"
            }
            Feature::EmailSupport => "Access to the Scanopy team via email support tickets",
            Feature::Whitelabeling => "We deploy Scanopy to a custom domain with your branding",
            Feature::LiveChatSupport => "Access to the Scanopy team via live chat",
            Feature::CommunitySupport => "Community support via GitHub issues and discussions",
            Feature::NetworkDiscovery => {
                "Automatically discover hosts, services, and connections on your network"
            }
            Feature::TopologyVisualization => {
                "Interactive network topology maps with automatic layout"
            }
            Feature::DiagramExport => {
                "Export network diagrams as high-resolution PNG or SVG images"
            }
            Feature::HostInventory => {
                "Searchable inventory of all discovered hosts and their details"
            }
            Feature::ScheduledDiscovery => "Schedule automatic network discovery scans",
            Feature::DaemonPoll => {
                "Run network scans without opening inbound ports or configuring port forwarding"
            }
            Feature::ServiceDefinitions => {
                "Auto-detect databases, containers, web servers, and more"
            }
            Feature::DockerIntegration => "Automatic discovery of containerized services",
            Feature::SnmpIntegration => {
                "Query network devices for hardware, port, and performance details via SNMP"
            }
        }
    }

    fn metadata(&self) -> serde_json::Value {
        serde_json::json!({
            "is_coming_soon": self.is_coming_soon(),
            "minimum_plan": self.minimum_plan()
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::server::billing::types::base::BillingPlan;
    use std::collections::HashSet;
    use strum::IntoEnumIterator;

    #[test]
    fn test_feature_ids_match_billing_plan_features_fields() {
        // Get all Feature IDs
        let feature_ids: HashSet<&str> = Feature::iter().map(|f| f.id()).collect();

        // Get all keys from BillingPlanFeatures by serializing an instance
        let features = BillingPlan::default().features();
        let features_json = serde_json::to_value(&features).expect("Failed to serialize features");
        let features_map = features_json
            .as_object()
            .expect("Features should be an object");

        let billing_plan_features: HashSet<&str> =
            features_map.keys().map(|s| s.as_str()).collect();

        // Check that every Feature ID exists in BillingPlanFeatures
        for feature_id in &feature_ids {
            assert!(
                billing_plan_features.contains(feature_id),
                "Feature ID '{}' does not exist in BillingPlanFeatures",
                feature_id
            );
        }

        // Check that every BillingPlanFeatures field has a corresponding Feature
        for feature in &billing_plan_features {
            assert!(
                feature_ids.contains(feature),
                "BillingPlanFeatures field '{}' does not have a corresponding Feature variant",
                feature
            );
        }

        // Verify they have the same count
        assert_eq!(
            feature_ids.len(),
            billing_plan_features.len(),
            "Feature enum has {} variants but BillingPlanFeatures has {} fields",
            feature_ids.len(),
            billing_plan_features.len()
        );
    }
}
