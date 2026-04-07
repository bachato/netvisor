//! SNMP Value Conversion Utilities
//!
//! Functions for extracting typed values from SNMP varbinds.

use mac_address::MacAddress;
use snmp2::Value;
use std::net::IpAddr;

/// Extract a string value from an SNMP varbind value
pub fn value_to_string(value: &Value) -> Option<String> {
    match value {
        Value::OctetString(bytes) => String::from_utf8(bytes.to_vec()).ok(),
        Value::ObjectIdentifier(oid) => oid.iter().map(|iter| {
            let parts: Vec<String> = iter.map(|n| n.to_string()).collect();
            parts.join(".")
        }),
        _ => None,
    }
}

/// Extract an integer value from an SNMP varbind value
pub fn value_to_i32(value: &Value) -> Option<i32> {
    match value {
        Value::Integer(n) => i32::try_from(*n).ok(),
        Value::Unsigned32(n) => i32::try_from(*n).ok(),
        Value::Counter32(n) => i32::try_from(*n).ok(),
        Value::Counter64(n) => i32::try_from(*n).ok(),
        Value::Timeticks(n) => i32::try_from(*n).ok(),
        _ => None,
    }
}

/// Extract a u64 value from an SNMP varbind value
pub fn value_to_u64(value: &Value) -> Option<u64> {
    match value {
        Value::Integer(n) => u64::try_from(*n).ok(),
        Value::Unsigned32(n) => Some(*n as u64),
        Value::Counter32(n) => Some(*n as u64),
        Value::Counter64(n) => Some(*n),
        Value::Timeticks(n) => Some(*n as u64),
        _ => None,
    }
}

/// Extract a MAC address from an SNMP varbind value
pub fn value_to_mac(value: &Value) -> Option<MacAddress> {
    match value {
        Value::OctetString(bytes) if bytes.len() == 6 => {
            let arr: [u8; 6] = [bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]];
            Some(MacAddress::new(arr))
        }
        _ => None,
    }
}

/// Extract an IP address from an SNMP varbind value.
/// Handles IpAddress (4-byte) and OctetString (4-byte) formats.
pub fn value_to_ip(value: &Value) -> Option<IpAddr> {
    match value {
        Value::IpAddress(bytes) => Some(IpAddr::from(*bytes)),
        Value::OctetString(bytes) if bytes.len() == 4 => {
            Some(IpAddr::from([bytes[0], bytes[1], bytes[2], bytes[3]]))
        }
        _ => None,
    }
}

/// Extract an unsigned 16-bit value from an SNMP varbind value
pub fn value_to_u16(value: &Value) -> Option<u16> {
    match value {
        Value::Integer(n) => u16::try_from(*n).ok(),
        Value::Unsigned32(n) => u16::try_from(*n).ok(),
        Value::Counter32(n) => u16::try_from(*n).ok(),
        _ => None,
    }
}

/// Parse a Q-BRIDGE PortList OCTET STRING into a Vec of bridge port numbers (1-based).
///
/// The PortList is an MSB-first bitmap: bit 0 (most significant) of octet 0 = port 1,
/// bit 1 of octet 0 = port 2, etc. This follows the BRIDGE-MIB PortList convention.
pub fn parse_portlist_bitmap(bytes: &[u8]) -> Vec<i32> {
    let mut ports = Vec::new();
    for (octet_idx, &byte) in bytes.iter().enumerate() {
        for bit in 0..8u32 {
            if byte & (0x80 >> bit) != 0 {
                let port_num = (octet_idx as i32) * 8 + (bit as i32) + 1;
                ports.push(port_num);
            }
        }
    }
    ports
}

/// Parse LLDP management address from raw SNMP bytes.
///
/// SNMP returns the address in one of these formats:
/// - Raw IPv4: 4 bytes
/// - Raw IPv6: 16 bytes
/// - With IANA address family prefix: 1 byte family + address bytes
///   (family 1 = IPv4, family 2 = IPv6 per IANA Address Family Numbers)
pub fn parse_lldp_mgmt_addr(bytes: &[u8]) -> Option<IpAddr> {
    match bytes.len() {
        // Raw IPv4
        4 => Some(IpAddr::from(<[u8; 4]>::try_from(bytes).ok()?)),
        // Raw IPv6
        16 => Some(IpAddr::from(<[u8; 16]>::try_from(bytes).ok()?)),
        // IANA family 1 (IPv4) + 4 address bytes
        5 if bytes[0] == 1 => Some(IpAddr::from(<[u8; 4]>::try_from(&bytes[1..5]).ok()?)),
        // IANA family 2 (IPv6) + 16 address bytes
        17 if bytes[0] == 2 => Some(IpAddr::from(<[u8; 16]>::try_from(&bytes[1..17]).ok()?)),
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_portlist_bitmap_empty() {
        assert_eq!(parse_portlist_bitmap(&[]), Vec::<i32>::new());
    }

    #[test]
    fn test_parse_portlist_bitmap_all_set() {
        assert_eq!(parse_portlist_bitmap(&[0xFF]), vec![1, 2, 3, 4, 5, 6, 7, 8]);
    }

    #[test]
    fn test_parse_portlist_bitmap_msb_only() {
        assert_eq!(parse_portlist_bitmap(&[0x80]), vec![1]);
    }

    #[test]
    fn test_parse_portlist_bitmap_lsb_only() {
        assert_eq!(parse_portlist_bitmap(&[0x01]), vec![8]);
    }

    #[test]
    fn test_parse_portlist_bitmap_multi_octet() {
        assert_eq!(parse_portlist_bitmap(&[0x80, 0x40]), vec![1, 10]);
    }

    #[test]
    fn test_parse_portlist_bitmap_all_zeros() {
        assert_eq!(parse_portlist_bitmap(&[0x00, 0x00]), Vec::<i32>::new());
    }

    #[test]
    fn test_value_to_u16_integer() {
        assert_eq!(value_to_u16(&Value::Integer(100)), Some(100));
    }

    #[test]
    fn test_value_to_u16_unsigned32() {
        assert_eq!(value_to_u16(&Value::Unsigned32(4094)), Some(4094));
    }

    #[test]
    fn test_value_to_u16_overflow() {
        assert_eq!(value_to_u16(&Value::Integer(70000)), None);
    }
}
