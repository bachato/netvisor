//! Standalone test for generating billing plan fixtures.
//! Run with: cargo test generate_billing_fixtures -- --nocapture

use scanopy::server::billing::plans::get_website_fixture_plans;
use scanopy::server::billing::types::features::Feature;
use scanopy::server::shared::types::metadata::{MetadataProvider, TypeMetadata};
use strum::IntoEnumIterator;

/// Generate billing-plans.json and features.json fixtures for the frontend.
/// Run with: cargo test generate_billing_fixtures -- --nocapture
#[test]
fn generate_billing_fixtures() {
    let plans = get_website_fixture_plans();
    let plan_metadata: Vec<TypeMetadata> = plans.iter().map(|p| p.to_metadata()).collect();
    let feature_metadata: Vec<TypeMetadata> = Feature::iter().map(|f| f.to_metadata()).collect();

    let json_string =
        serde_json::to_string_pretty(&plan_metadata).expect("Failed to serialize plans");
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("Failed to get parent directory")
        .join("ui/src/lib/data/billing-plans-next.json");
    std::fs::write(&path, json_string).expect("Failed to write billing-plans-next.json");

    let json_string =
        serde_json::to_string_pretty(&feature_metadata).expect("Failed to serialize features");
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("Failed to get parent directory")
        .join("ui/src/lib/data/features-next.json");
    std::fs::write(&path, json_string).expect("Failed to write features-next.json");

    println!("✅ Generated billing-plans-next.json and features-next.json in ui/src/lib/data/");
}
