/// Legacy daemon response transformations.
/// Legacy cleanup: remove this entire module once minimum_supported >= 0.16.0

/// Rewrite response JSON for pre-0.16.0 daemons to use old entity/field names.
/// - BindingType "IPAddress" → "Interface", "ip_address_id" → "interface_id"
/// - HostResponse field "ip_addresses" → "interfaces", "interfaces" → "if_entries"
/// Legacy cleanup: remove once minimum_supported >= 0.16.0
pub fn rewrite_response_for_legacy_daemon(value: &mut serde_json::Value) {
    match value {
        serde_json::Value::Object(map) => {
            // Rename HostResponse child entity fields:
            // current "ip_addresses" → old "interfaces", current "interfaces" → old "if_entries"
            // Order matters: rename interfaces→if_entries first, then ip_addresses→interfaces
            if let Some(val) = map.remove("interfaces") {
                map.insert("if_entries".to_string(), val);
            }
            if let Some(val) = map.remove("ip_addresses") {
                map.insert("interfaces".to_string(), val);
            }

            // Rewrite BindingType: "IPAddress" → "Interface"
            if map.get("type").and_then(|v| v.as_str()) == Some("IPAddress") {
                map.insert(
                    "type".to_string(),
                    serde_json::Value::String("Interface".to_string()),
                );
            }

            // Rewrite ip_address_id → interface_id in bindings (IPAddress and Port variants)
            if map.contains_key("type") {
                if let Some(val) = map.remove("ip_address_id") {
                    map.insert("interface_id".to_string(), val);
                }
            }

            // Recurse into all values
            for v in map.values_mut() {
                rewrite_response_for_legacy_daemon(v);
            }
        }
        serde_json::Value::Array(arr) => {
            for v in arr {
                rewrite_response_for_legacy_daemon(v);
            }
        }
        _ => {}
    }
}
