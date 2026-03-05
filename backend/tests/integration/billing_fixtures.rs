//! Standalone test for generating metadata fixtures as static JSON files.
//! Run with: cargo test generate_billing_fixtures -- --nocapture

use scanopy::server::billing::plans::get_website_fixture_plans;
use scanopy::server::billing::types::base::BillingPlan;
use scanopy::server::billing::types::features::Feature;
use scanopy::server::discovery::r#impl::types::DiscoveryType;
use scanopy::server::groups::r#impl::types::GroupType;
use scanopy::server::ports::r#impl::base::PortType;
use scanopy::server::services::definitions::ServiceDefinitionRegistry;
use scanopy::server::shared::concepts::Concept;
use scanopy::server::shared::entities::EntityDiscriminants;
use scanopy::server::shared::types::metadata::{EntityMetadata, MetadataProvider, TypeMetadata};
use scanopy::server::subnets::r#impl::types::SubnetType;
use scanopy::server::topology::types::edges::EdgeType;
use scanopy::server::users::r#impl::permissions::UserOrgPermissions;
use strum::{IntoDiscriminant, IntoEnumIterator};

fn write_fixture<T: serde::Serialize>(items: &[T], filename: &str) {
    let json = serde_json::to_string_pretty(items).expect("Failed to serialize");
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("Failed to get parent directory")
        .join(format!("ui/src/lib/data/{filename}"));
    std::fs::write(&path, json).unwrap_or_else(|_| panic!("Failed to write {filename}"));
}

/// Generate all metadata JSON fixtures for the frontend.
/// Run with: cargo test generate_billing_fixtures -- --nocapture
#[test]
fn generate_billing_fixtures() {
    // Billing fixtures — website plans (curated, for billing modal)
    let plan_metadata: Vec<TypeMetadata> = get_website_fixture_plans()
        .iter()
        .map(|p| p.to_metadata())
        .collect();
    write_fixture(&plan_metadata, "billing-plans.json");

    // All billing plan variants (for metadata store, matches old /api/metadata)
    let all_plan_metadata: Vec<TypeMetadata> =
        BillingPlan::iter().map(|p| p.to_metadata()).collect();
    write_fixture(&all_plan_metadata, "billing-plans-all.json");

    let feature_metadata: Vec<TypeMetadata> = Feature::iter().map(|f| f.to_metadata()).collect();
    write_fixture(&feature_metadata, "features.json");

    // TypeMetadata categories
    let service_defs: Vec<TypeMetadata> = ServiceDefinitionRegistry::all_service_definitions()
        .iter()
        .map(|t| t.to_metadata())
        .collect();
    write_fixture(&service_defs, "service-definitions.json");

    let subnet_types: Vec<TypeMetadata> = SubnetType::iter().map(|t| t.to_metadata()).collect();
    write_fixture(&subnet_types, "subnet-types.json");

    let edge_types: Vec<TypeMetadata> = EdgeType::iter().map(|t| t.to_metadata()).collect();
    write_fixture(&edge_types, "edge-types.json");

    let group_types: Vec<TypeMetadata> = GroupType::iter()
        .map(|t| t.discriminant().to_metadata())
        .collect();
    write_fixture(&group_types, "group-types.json");

    let ports: Vec<TypeMetadata> = PortType::iter().map(|p| p.to_metadata()).collect();
    write_fixture(&ports, "ports.json");

    let discovery_types: Vec<TypeMetadata> =
        DiscoveryType::iter().map(|d| d.to_metadata()).collect();
    write_fixture(&discovery_types, "discovery-types.json");

    let permissions: Vec<TypeMetadata> = UserOrgPermissions::iter()
        .map(|p| p.to_metadata())
        .collect();
    write_fixture(&permissions, "permissions.json");

    // EntityMetadata categories
    let entities: Vec<EntityMetadata> = EntityDiscriminants::iter()
        .map(|e| e.to_metadata())
        .collect();
    write_fixture(&entities, "entities.json");

    let concepts: Vec<EntityMetadata> = Concept::iter().map(|e| e.to_metadata()).collect();
    write_fixture(&concepts, "concepts.json");

    println!("✅ Generated all metadata fixtures in ui/src/lib/data/");
}
