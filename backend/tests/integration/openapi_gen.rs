//! OpenAPI spec generation.
//!
//! This module provides OpenAPI spec generation that can be run:
//! 1. Standalone full spec: `cargo test generate_openapi_spec -- --nocapture`
//! 2. As part of fixture generation (public API only, no internal endpoints)
//!
//! No Docker containers are required - this is purely compile-time.

use scanopy::server::openapi::{build_openapi, export_openapi_spec_to_file, filter_internal_paths};
use scanopy::server::shared::handlers::factory::collect_all_openapi_routes;
use utoipa::openapi::OpenApi;

/// Collect all OpenAPI routes from the single source of truth in factory.rs.
fn collect_all_routes() -> OpenApi {
    collect_all_openapi_routes()
}

/// Generate the full OpenAPI spec (including internal endpoints) and save to ui/static/openapi.json.
///
/// Used by `make generate-types` for TypeScript client generation.
pub fn generate() -> Result<(), Box<dyn std::error::Error>> {
    let merged = collect_all_routes();
    let final_spec = build_openapi(merged.clone());

    // Export to ui/static/openapi.json
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .ok_or("Failed to get parent directory")?
        .join("ui/static/openapi.json");

    export_openapi_spec_to_file(merged, &path)?;

    println!("✅ Generated openapi.json (full) at {}", path.display());
    println!("   Paths: {}", final_spec.paths.paths.len());
    if let Some(components) = &final_spec.components {
        println!("   Schemas: {}", components.schemas.len());
    }

    Ok(())
}

/// Generate the public OpenAPI spec (excluding internal endpoints) for external distribution.
///
/// Used by fixture generation for committing to external repos.
/// Filters out any endpoints tagged with "internal".
pub fn generate_public(output_path: &std::path::Path) -> Result<(), Box<dyn std::error::Error>> {
    let merged = collect_all_routes();
    let full_spec = build_openapi(merged);
    let public_spec = filter_internal_paths(&full_spec);

    let json = serde_json::to_string_pretty(&public_spec)?;
    std::fs::write(output_path, json)?;

    println!(
        "✅ Generated openapi.json (public) at {}",
        output_path.display()
    );
    println!("   Paths: {}", public_spec.paths.paths.len());
    if let Some(components) = &public_spec.components {
        println!("   Schemas: {}", components.schemas.len());
    }

    Ok(())
}

/// Standalone test for full OpenAPI spec generation.
/// Run with: cargo test generate_openapi_spec -- --nocapture
#[test]
fn generate_openapi_spec() {
    generate().expect("Failed to generate OpenAPI spec");
}

/// Test for public OpenAPI spec generation (excludes internal endpoints).
/// Run with: cargo test generate_openapi_spec_public -- --nocapture
#[test]
fn generate_openapi_spec_public() {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("Failed to get parent directory")
        .join("ui/static/openapi-public.json");
    generate_public(&path).expect("Failed to generate public OpenAPI spec");
}
