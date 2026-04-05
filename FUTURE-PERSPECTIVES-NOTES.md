# Future Perspective Implementation Notes

## L2 Physical

- **Element (interface port):** SectionIdentity shows the IfEntry data (physical port name, MAC, ifIndex). SectionIfEntryData shows full SNMP status, speed, and LLDP/CDP neighbor details. SectionTags for host tags.
- **Container:** SectionIdentity shows the VLAN or broadcast domain name. SectionElementSummary shows port count.
- **Edge inspector:** PhysicalLink edges should show source/target IfEntry details, discovery protocol (LLDP/CDP), and neighbor resolution details. The InspectorEdgePhysicalLink component already handles this.
- **ElementEntityType:** Would likely be `Interface` (same as L3) but resolved differently — matching IfEntry rather than IP interface.

## Infrastructure

- **Element (host/VM):** SectionIdentity shows the host with virtualization info. SectionServices shows services running on the host. SectionTags for host tags.
- **Container (hypervisor/cluster):** SectionIdentity shows the hypervisor service name and host. SectionElementSummary shows VM count.
- **Edge inspector:** HostVirtualization and ServiceVirtualization edges already have dedicated inspectors. These work well for Infrastructure perspective.
- **ElementEntityType:** May need a new `Host` variant or reuse `Interface` with different resolution logic. Alternatively, use `Service` where the element represents a VM service.
- **Key difference from L3:** Grouping is by virtualization hierarchy (hypervisor → VMs) rather than by subnet.
