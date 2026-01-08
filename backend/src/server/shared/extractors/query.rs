//! Re-export axum_extra's Query extractor.
//!
//! This extractor uses serde_html_form which supports repeated query parameters
//! for arrays (e.g., `ids=a&ids=b` deserializes to `ids: vec!["a", "b"]`).

pub use axum_extra::extract::Query;
