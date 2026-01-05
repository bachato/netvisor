use std::collections::{HashMap, HashSet};
use std::net::Ipv4Addr;
use std::time::{Duration, Instant};

use anyhow::{Result, anyhow};
use mac_address::MacAddress;
use pnet::datalink::{self, Channel, NetworkInterface};
use pnet::packet::Packet;
use pnet::packet::arp::{ArpHardwareTypes, ArpOperations, ArpPacket, MutableArpPacket};
use pnet::packet::ethernet::{EtherTypes, EthernetPacket, MutableEthernetPacket};
use pnet::util::MacAddr;

use super::types::ArpScanResult;

const ARP_TIMEOUT: Duration = Duration::from_secs(2);
const SEND_DELAY: Duration = Duration::from_micros(200);

/// Check if broadcast ARP is available (requires raw socket capability)
pub fn is_available() -> bool {
    let interfaces = datalink::interfaces();
    let suitable = interfaces
        .into_iter()
        .find(|iface| iface.is_up() && !iface.is_loopback() && iface.mac.is_some());

    let Some(interface) = suitable else {
        return false;
    };

    let config = pnet::datalink::Config {
        read_timeout: Some(Duration::from_millis(100)),
        ..Default::default()
    };

    datalink::channel(&interface, config).is_ok()
}

/// Scan subnet using broadcast ARP
/// Sends all ARP requests rapidly, then collects responses for ARP_TIMEOUT duration
pub async fn scan_subnet(
    interface: &NetworkInterface,
    source_ip: Ipv4Addr,
    source_mac: MacAddress,
    targets: Vec<Ipv4Addr>,
) -> Result<Vec<ArpScanResult>> {
    let interface = interface.clone();
    let target_set: HashSet<Ipv4Addr> = targets.iter().copied().collect();

    // Run blocking network I/O in spawn_blocking
    tokio::task::spawn_blocking(move || {
        scan_subnet_blocking(&interface, source_ip, source_mac, target_set)
    })
    .await?
}

fn scan_subnet_blocking(
    interface: &NetworkInterface,
    source_ip: Ipv4Addr,
    source_mac: MacAddress,
    targets: HashSet<Ipv4Addr>,
) -> Result<Vec<ArpScanResult>> {
    let config = pnet::datalink::Config {
        read_timeout: Some(Duration::from_millis(50)),
        ..Default::default()
    };

    let (mut tx, mut rx) = match datalink::channel(interface, config)? {
        Channel::Ethernet(tx, rx) => (tx, rx),
        _ => return Err(anyhow!("Unsupported channel type")),
    };

    let source_mac_pnet = MacAddr::new(
        source_mac.bytes()[0],
        source_mac.bytes()[1],
        source_mac.bytes()[2],
        source_mac.bytes()[3],
        source_mac.bytes()[4],
        source_mac.bytes()[5],
    );

    // Phase 1: Send all ARP requests
    tracing::debug!(
        interface = %interface.name,
        source_ip = %source_ip,
        targets = targets.len(),
        "Sending broadcast ARP requests"
    );

    for target_ip in &targets {
        let packet = build_arp_request(source_mac_pnet, source_ip, *target_ip);
        if let Some(Err(e)) = tx.send_to(&packet, None) {
            tracing::trace!(target = %target_ip, error = %e, "Failed to send ARP request");
        }
        std::thread::sleep(SEND_DELAY);
    }

    // Phase 2: Collect responses
    let mut results: HashMap<Ipv4Addr, MacAddress> = HashMap::new();
    let deadline = Instant::now() + ARP_TIMEOUT;

    tracing::debug!(
        timeout_secs = ARP_TIMEOUT.as_secs(),
        "Collecting ARP responses"
    );

    while Instant::now() < deadline {
        match rx.next() {
            Ok(packet) => {
                if let Some((ip, mac)) = parse_arp_reply(packet)
                    && targets.contains(&ip)
                    && !results.contains_key(&ip)
                {
                    tracing::trace!(ip = %ip, mac = %mac, "ARP response received");
                    results.insert(ip, mac);

                    // Early exit if we've found all targets
                    if results.len() == targets.len() {
                        tracing::debug!(
                            found = results.len(),
                            "All targets responded, exiting early"
                        );
                        break;
                    }
                }
            }
            Err(_) => {
                // Read timeout, continue waiting
                std::thread::sleep(Duration::from_millis(10));
            }
        }
    }

    tracing::debug!(
        targets = targets.len(),
        responsive = results.len(),
        "Broadcast ARP scan complete"
    );

    Ok(results
        .into_iter()
        .map(|(ip, mac)| ArpScanResult { ip, mac })
        .collect())
}

fn build_arp_request(source_mac: MacAddr, source_ip: Ipv4Addr, target_ip: Ipv4Addr) -> Vec<u8> {
    let mut ethernet_buffer = vec![0u8; 42]; // 14 (eth) + 28 (arp)
    let mut ethernet_packet = MutableEthernetPacket::new(&mut ethernet_buffer).unwrap();

    ethernet_packet.set_destination(MacAddr::broadcast());
    ethernet_packet.set_source(source_mac);
    ethernet_packet.set_ethertype(EtherTypes::Arp);

    let mut arp_buffer = vec![0u8; 28];
    let mut arp_packet = MutableArpPacket::new(&mut arp_buffer).unwrap();

    arp_packet.set_hardware_type(ArpHardwareTypes::Ethernet);
    arp_packet.set_protocol_type(EtherTypes::Ipv4);
    arp_packet.set_hw_addr_len(6);
    arp_packet.set_proto_addr_len(4);
    arp_packet.set_operation(ArpOperations::Request);
    arp_packet.set_sender_hw_addr(source_mac);
    arp_packet.set_sender_proto_addr(source_ip);
    arp_packet.set_target_hw_addr(MacAddr::zero());
    arp_packet.set_target_proto_addr(target_ip);

    ethernet_packet.set_payload(arp_packet.packet());
    ethernet_buffer
}

fn parse_arp_reply(packet: &[u8]) -> Option<(Ipv4Addr, MacAddress)> {
    let ethernet = EthernetPacket::new(packet)?;
    if ethernet.get_ethertype() != EtherTypes::Arp {
        return None;
    }

    let arp = ArpPacket::new(ethernet.payload())?;
    if arp.get_operation() != ArpOperations::Reply {
        return None;
    }

    let sender_ip = arp.get_sender_proto_addr();
    let sender_mac = MacAddress::new(arp.get_sender_hw_addr().octets());

    Some((sender_ip, sender_mac))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_build_arp_request_creates_valid_packet() {
        let source_mac = MacAddr::new(0x00, 0x11, 0x22, 0x33, 0x44, 0x55);
        let source_ip = Ipv4Addr::new(192, 168, 1, 100);
        let target_ip = Ipv4Addr::new(192, 168, 1, 1);

        let packet = build_arp_request(source_mac, source_ip, target_ip);

        // Verify packet size
        assert_eq!(packet.len(), 42);

        // Parse and verify ethernet header
        let eth = EthernetPacket::new(&packet).unwrap();
        assert_eq!(eth.get_destination(), MacAddr::broadcast());
        assert_eq!(eth.get_source(), source_mac);
        assert_eq!(eth.get_ethertype(), EtherTypes::Arp);

        // Parse and verify ARP packet
        let arp = ArpPacket::new(eth.payload()).unwrap();
        assert_eq!(arp.get_hardware_type(), ArpHardwareTypes::Ethernet);
        assert_eq!(arp.get_protocol_type(), EtherTypes::Ipv4);
        assert_eq!(arp.get_operation(), ArpOperations::Request);
        assert_eq!(arp.get_sender_hw_addr(), source_mac);
        assert_eq!(arp.get_sender_proto_addr(), source_ip);
        assert_eq!(arp.get_target_proto_addr(), target_ip);
    }

    #[test]
    fn test_parse_arp_reply_extracts_sender_info() {
        // Build a mock ARP reply packet
        let mut packet = vec![0u8; 42];

        // Ethernet header
        let mut eth = MutableEthernetPacket::new(&mut packet).unwrap();
        eth.set_destination(MacAddr::new(0x00, 0x11, 0x22, 0x33, 0x44, 0x55));
        eth.set_source(MacAddr::new(0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF));
        eth.set_ethertype(EtherTypes::Arp);

        // ARP payload
        let mut arp_buffer = vec![0u8; 28];
        {
            let mut arp = MutableArpPacket::new(&mut arp_buffer).unwrap();
            arp.set_hardware_type(ArpHardwareTypes::Ethernet);
            arp.set_protocol_type(EtherTypes::Ipv4);
            arp.set_hw_addr_len(6);
            arp.set_proto_addr_len(4);
            arp.set_operation(ArpOperations::Reply);
            arp.set_sender_hw_addr(MacAddr::new(0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF));
            arp.set_sender_proto_addr(Ipv4Addr::new(192, 168, 1, 1));
            arp.set_target_hw_addr(MacAddr::new(0x00, 0x11, 0x22, 0x33, 0x44, 0x55));
            arp.set_target_proto_addr(Ipv4Addr::new(192, 168, 1, 100));
        }
        eth.set_payload(&arp_buffer);

        let result = parse_arp_reply(&packet);
        assert!(result.is_some());

        let (ip, mac) = result.unwrap();
        assert_eq!(ip, Ipv4Addr::new(192, 168, 1, 1));
        assert_eq!(mac.bytes(), [0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]);
    }

    #[test]
    fn test_parse_arp_reply_rejects_non_arp() {
        // Build a non-ARP ethernet packet
        let mut packet = vec![0u8; 42];
        let mut eth = MutableEthernetPacket::new(&mut packet).unwrap();
        eth.set_ethertype(EtherTypes::Ipv4); // Not ARP

        let result = parse_arp_reply(&packet);
        assert!(result.is_none());
    }

    #[test]
    fn test_parse_arp_reply_rejects_arp_request() {
        // Build an ARP request (not reply)
        let mut packet = vec![0u8; 42];
        let mut eth = MutableEthernetPacket::new(&mut packet).unwrap();
        eth.set_ethertype(EtherTypes::Arp);

        let mut arp_buffer = vec![0u8; 28];
        {
            let mut arp = MutableArpPacket::new(&mut arp_buffer).unwrap();
            arp.set_hardware_type(ArpHardwareTypes::Ethernet);
            arp.set_protocol_type(EtherTypes::Ipv4);
            arp.set_hw_addr_len(6);
            arp.set_proto_addr_len(4);
            arp.set_operation(ArpOperations::Request); // Request, not Reply
        }
        eth.set_payload(&arp_buffer);

        let result = parse_arp_reply(&packet);
        assert!(result.is_none());
    }
}
