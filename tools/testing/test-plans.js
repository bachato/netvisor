var TEST_PLANS = [
{
  "branch": "feat/compute-perspective",
  "tests": [
    {
      "id": "workloads-bare-metal-host",
      "category": "Workloads Perspective",
      "description": "Bare metal host with services shows as container with service elements",
      "steps": [
        "Navigate to the topology view",
        "Switch to the Workloads perspective",
        "Find a bare metal host (no virtualization) that has services"
      ],
      "setup": "Ensure at least one host exists with non-virtualization services (e.g., Samba, NFS) and no hypervisor or Docker daemon.",
      "expected": "Host appears as a container (external title style). Services appear as elements directly inside the host container. No sub-containers.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-docker-host",
      "category": "Workloads Perspective",
      "description": "Docker host shows Docker sub-container with container elements",
      "steps": [
        "Navigate to the topology view",
        "Switch to the Workloads perspective",
        "Find a host running Docker with containers"
      ],
      "setup": "Ensure at least one host exists with a Docker daemon service and Docker containers discovered.",
      "expected": "Host appears as a container. Inside it, a 'Docker' Virtualizer sub-container (inline title style) contains the Docker container services as elements.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-proxmox-hypervisor",
      "category": "Workloads Perspective",
      "description": "Proxmox hypervisor shows VMs inside Virtualizer sub-container",
      "steps": [
        "Navigate to the topology view",
        "Switch to the Workloads perspective",
        "Find a Proxmox hypervisor host"
      ],
      "setup": "Ensure at least one host exists with a Proxmox VE service and VMs (hosts with HostVirtualization::Proxmox) assigned to it.",
      "expected": "Hypervisor host appears as a container. Inside it, a 'Proxmox VE' Virtualizer sub-container contains the VMs as Host{} elements.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-vm-not-container",
      "category": "Workloads Perspective",
      "description": "VMs do not appear as their own containers",
      "steps": [
        "Navigate to the topology view",
        "Switch to the Workloads perspective",
        "Verify VM hosts only appear as elements inside their hypervisor"
      ],
      "setup": "Ensure at least one Proxmox VM exists that also has services running on it.",
      "expected": "The VM appears only as an element inside the hypervisor's Proxmox sub-container. It does NOT appear as a separate top-level Host container.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-no-edges",
      "category": "Workloads Perspective",
      "description": "No edges are drawn in the Workloads perspective",
      "steps": [
        "Navigate to the topology view",
        "Switch to the Workloads perspective",
        "Observe the canvas"
      ],
      "expected": "No edges (lines) are drawn between any elements or containers. The nesting/containment is the only structural information.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-perspective-name-icon",
      "category": "Workloads Perspective",
      "description": "Perspective shows correct name, icon, and color",
      "steps": [
        "Open the perspective switcher in the topology view",
        "Find the Workloads perspective"
      ],
      "expected": "Perspective is named 'Workloads' with Amber color and Boxes icon.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-inspector-element",
      "category": "Workloads Perspective",
      "description": "Inspector panel shows correct sections for selected element",
      "steps": [
        "Switch to Workloads perspective",
        "Click on a workload element (VM or service)"
      ],
      "setup": "Ensure hosts with services exist.",
      "expected": "Inspector panel shows: Identity, Host Detail, Virtualization, Services, Other Interfaces, Tags sections.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-empty-host",
      "category": "Workloads Perspective",
      "description": "Host with no services still appears as container",
      "steps": [
        "Switch to Workloads perspective",
        "Find a host that has no services"
      ],
      "setup": "Ensure at least one host exists with no services discovered on it.",
      "expected": "Host appears as an empty container.",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/entity-naming",
  "tests": [
    {
      "id": "host-ip-addresses-tab",
      "category": "IP Address Management",
      "description": "Verify IP Addresses tab works in host editor",
      "steps": [
        "Open a host with IP addresses in the edit modal",
        "Navigate to the 'IP Addresses' tab",
        "Verify IP addresses are listed with correct data",
        "Select an IP address to view its config panel"
      ],
      "expected": "IP addresses display correctly with subnet, IP, MAC data. Tab is labeled 'IP Addresses'.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "host-interfaces-tab",
      "category": "Interface Management",
      "description": "Verify Interfaces tab (SNMP data) works in host editor",
      "steps": [
        "Open a host that has SNMP interface data in the edit modal",
        "Navigate to the 'Interfaces' tab (only visible for existing hosts)",
        "Verify SNMP interfaces are listed with if_descr, status, MAC",
        "Select an interface to view its details card"
      ],
      "setup": "Ensure at least one host has SNMP interface data (run an SNMP discovery scan).",
      "expected": "SNMP interfaces display correctly with operational status, speed, LLDP/CDP neighbor data. Tab is labeled 'Interfaces'.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-l2-interfaces",
      "category": "Topology Visualization",
      "description": "Verify L2 Physical view shows Interface elements (was Port/IfEntry)",
      "steps": [
        "Navigate to topology view",
        "Switch to L2 Physical perspective",
        "Click on a physical link between two devices",
        "Verify the inspector shows interface details"
      ],
      "setup": "Ensure SNMP discovery has run and L2 physical links exist.",
      "expected": "L2 view shows Interface elements with correct SNMP data. Inspector displays interface details card.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-l3-ip-addresses",
      "category": "Topology Visualization",
      "description": "Verify L3 Logical view shows IPAddress elements (was Interface)",
      "steps": [
        "Navigate to topology view",
        "Switch to L3 Logical perspective",
        "Click on a host's IP address element in the topology",
        "Verify the inspector shows IP address details"
      ],
      "expected": "L3 view shows IPAddress elements correctly grouped by subnet. Inspector shows IP address data.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "service-bindings-ip-address",
      "category": "Service Bindings",
      "description": "Verify service bindings reference IP addresses correctly",
      "steps": [
        "Open a service that has IP address bindings",
        "Verify binding displays show 'IP Address' type correctly",
        "Edit a binding and verify the IP address selector works",
        "Verify 'All IP Addresses' option works for port bindings"
      ],
      "expected": "Bindings display and edit correctly with IPAddress terminology.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "host-card-display",
      "category": "Host Display",
      "description": "Verify host cards show both IP Addresses and Interfaces sections",
      "steps": [
        "Navigate to the hosts list",
        "Find a host with both IP addresses and SNMP interfaces",
        "Expand the host card",
        "Verify separate 'IP Addresses' and 'Interfaces' sections exist"
      ],
      "setup": "Ensure at least one host has both IP addresses and SNMP interface data.",
      "expected": "Host card shows IP Addresses section with IPs and Interfaces section with SNMP data. Both sections are separate.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "api-paths-correct",
      "category": "API",
      "description": "Verify API paths are renamed correctly",
      "steps": [
        "Open browser dev tools network tab",
        "Navigate through the app to trigger API calls",
        "Verify /api/v1/ip-addresses is called for IP address data",
        "Verify /api/v1/interfaces is called for SNMP interface data"
      ],
      "expected": "API calls use the new paths. No 404s from old paths.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/topology-view-persist",
  "tests": []
}
,
{
  "branch": "feat/app-irrelevant-category-group",
  "tests": []
}
,
{
  "branch": "refactor/color-icon-compute",
  "tests": [
    {
      "id": "compute-perspective-tab",
      "category": "Perspective Rename",
      "description": "Verify the Infrastructure perspective is now labeled 'Compute' in the topology view selector",
      "steps": [
        "Navigate to the Topology page",
        "Open the perspective/view selector dropdown"
      ],
      "expected": "The tab formerly labeled 'Infrastructure' now shows 'Compute' with a CPU icon and orange color",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "compute-perspective-loads",
      "category": "Perspective Rename",
      "description": "Verify the Compute perspective loads and displays hosts correctly",
      "steps": [
        "Select the 'Compute' perspective in the topology view selector",
        "Observe the topology view"
      ],
      "setup": "Ensure at least 2 hosts exist with services on the default network",
      "expected": "Hosts appear as elements in the Compute view with their services shown inline. Layout renders without errors.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "entity-colors-l3",
      "category": "Entity Colors",
      "description": "Verify updated entity colors in L3 Logical view",
      "steps": [
        "Navigate to Topology > L3 Logical view",
        "Observe the IP address nodes, subnet containers, and service badges"
      ],
      "setup": "Ensure hosts with services exist across at least 2 subnets",
      "expected": "IP address nodes use blue color, subnet containers use indigo, service badges use fuchsia. Port badges (if visible) use sky blue.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "entity-colors-host-amber",
      "category": "Entity Colors",
      "description": "Verify Host entities use amber color consistently",
      "steps": [
        "Open the Compute perspective",
        "Note the host element color",
        "Switch to L3 Logical and observe host container color"
      ],
      "expected": "Hosts display in amber color in both Compute (as elements) and L3 (as containers/parent entities)",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-tab-visible",
      "category": "Host Modal",
      "description": "Verify the host modal Virtualization tab is renamed to Workloads",
      "steps": [
        "Open an existing host in the host editor modal",
        "Look at the tab navigation"
      ],
      "setup": "Ensure at least one host exists with a Docker or Proxmox service",
      "expected": "The tab formerly labeled 'Virtualization' now shows 'Workloads' with a Boxes icon",
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-tab-functional",
      "category": "Host Modal",
      "description": "Verify the Workloads tab still shows virtualization manager services",
      "steps": [
        "Open an existing host with Docker services in the host editor",
        "Click the 'Workloads' tab",
        "Observe the virtualization manager list"
      ],
      "setup": "Ensure a host exists with a Docker service managing containers",
      "expected": "The Workloads tab displays Docker service managers and their containers, identical functionality to the old Virtualization tab",
      "status": null,
      "feedback": null
    },
    {
      "id": "concept-colors-in-grouping",
      "category": "Topology Grouping",
      "description": "Verify concept colors appear correctly on grouping rule badges",
      "steps": [
        "Open Topology > Compute perspective",
        "Open the grouping rules panel",
        "Observe the ByVirtualizer rule badge color"
      ],
      "expected": "ByVirtualizer rule badge uses orange color (Compute concept color), ByStack rule badge uses fuchsia (Containerization concept color)",
      "status": null,
      "feedback": null
    },
    {
      "id": "vlan-color-in-l2",
      "category": "Entity Colors",
      "description": "Verify VLAN entities use violet color in L2 Physical view",
      "steps": [
        "Navigate to Topology > L2 Physical view",
        "Observe VLAN-related containers or badges if present"
      ],
      "setup": "Ensure hosts with VLAN-tagged interfaces exist",
      "expected": "VLAN elements display in violet color with CircleDashed icon",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/shares-modal",
  "tests": []
}
,
{
  "branch": "feat/vlan-entity",
  "tests": []
}
,
{
  "branch": "fix/topo-visual-consistency",
  "tests": []
}
,
{
  "branch": "fix/subcontainer-expand-sizing",
  "tests": [
    {
      "id": "collapsed-default-width",
      "category": "Collapsed Subcontainer Sizing",
      "description": "Collapsed-by-default subcontainers show correct width matching their content",
      "steps": [
        "Navigate to the topology page",
        "Select L2 Physical view for a network with hosts that have both Up and Down ports",
        "Observe the 'Down' subcontainer (collapsed by default)"
      ],
      "setup": "Ensure at least one host has multiple Down ports (10+) so the expanded width would be significantly wider than the default 250px collapsed_size.",
      "expected": "The collapsed 'Down' subcontainer should be approximately the same width as the 'Up' subcontainer (matching the width its children would occupy when expanded), not a narrow 250px box.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "expand-collapsed-default-layout",
      "category": "Collapsed Subcontainer Sizing",
      "description": "Expanding a collapsed-by-default subcontainer lays out children in a grid",
      "steps": [
        "From the previous test state, click to expand the 'Down' subcontainer"
      ],
      "expected": "Child port elements should be laid out in a proper grid/box layout (matching how ELK would arrange them), not piled up on top of each other or in a single narrow column.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "expand-after-page-refresh",
      "category": "Collapsed Subcontainer Sizing",
      "description": "Expanding works correctly after page refresh with localStorage-persisted collapse state",
      "steps": [
        "In L2 Physical view, observe the 'Down' subcontainer is collapsed",
        "Refresh the page (F5)",
        "After page loads, click to expand the 'Down' subcontainer"
      ],
      "setup": "Ensure the collapsed state is persisted to localStorage from a prior session.",
      "expected": "Child port elements should be laid out in a proper grid, same as a fresh expand. ELK should re-run for the expand since it never computed expanded layout.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "normal-collapse-expand-cycle",
      "category": "Collapse/Expand Regression",
      "description": "Normal collapse/expand cycle continues to work correctly",
      "steps": [
        "In the topology view, manually collapse an expanded container (e.g., a subnet)",
        "Expand the same container again"
      ],
      "expected": "Container collapses to its collapsed representation and re-expands to show all children with correct layout — no regressions from the fix.",
      "status": null,
      "feedback": null
    },
    {
      "id": "expand-after-data-refresh",
      "category": "Collapsed Subcontainer Sizing",
      "description": "Expanding a collapsed-by-default subcontainer works after topology data refresh",
      "steps": [
        "Navigate to L2 Physical view with Down ports",
        "Wait for a topology data refresh (or trigger a discovery scan)",
        "Click to expand the 'Down' subcontainer"
      ],
      "setup": "Ensure topology polling or a manual refresh triggers a data reload while the Down subcontainer is still collapsed.",
      "expected": "Children should be laid out correctly in a grid, not piled up. The expanded width should be correct.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/topology-url-params",
  "tests": []
}
,
{
  "branch": "fix/edge-label-deselect",
  "tests": []
}
];
