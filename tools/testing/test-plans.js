var TEST_PLANS = [
{
  "branch": "fix/layout-debug-harness",
  "tests": []
}
,
{
  "branch": "fix/dynamic-spacing-animation",
  "tests": [
    {
      "id": "collapse-root-reduces-gaps",
      "category": "Gap Reduction",
      "description": "Collapsing root containers reduces gaps between them",
      "steps": [
        "Open the topology view with multiple root containers expanded",
        "Note the spacing between containers",
        "Collapse one root container using the chevron icon",
        "Observe the spacing between containers after collapse"
      ],
      "setup": "Ensure the topology has at least 3 root containers with varying sizes, some containing many hosts.",
      "expected": "After collapsing, the collapsed container should be compact and gaps between containers should be proportional to the collapsed size, not the previous expanded size.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapse-subcontainer-reduces-gaps",
      "category": "Gap Reduction",
      "description": "Collapsing subcontainers reduces gaps within parent container",
      "steps": [
        "Open the topology view with an expanded root container containing multiple subcontainers",
        "Collapse one subcontainer",
        "Observe the parent container size and sibling positions"
      ],
      "setup": "Ensure the topology has a root container with at least 2 subcontainers, each containing multiple hosts.",
      "expected": "After collapsing a subcontainer, the parent container should shrink both vertically and horizontally (if the collapsed subcontainer was the widest). Siblings below should shift up to fill the gap.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "expand-no-overlap",
      "category": "Gap Reduction",
      "description": "Expanding a collapsed container does not cause overlap",
      "steps": [
        "From the collapsed state (after previous tests), expand the previously collapsed root container",
        "Verify no containers overlap each other"
      ],
      "expected": "The expanded container should grow to its full size and the layout should recompute correctly with no overlapping containers.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapse-animates-smoothly",
      "category": "Animation",
      "description": "Container collapse animates size and position changes",
      "steps": [
        "Open the topology view with containers expanded",
        "Collapse a container and watch carefully for animation"
      ],
      "expected": "The container should shrink smoothly over ~300ms (not snap instantly). Sibling containers should slide into new positions smoothly.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "expand-animates-smoothly",
      "category": "Animation",
      "description": "Container expand animates size and position changes",
      "steps": [
        "From a state with collapsed containers, expand one container",
        "Watch carefully for animation"
      ],
      "expected": "The container should grow smoothly over ~300ms. Sibling containers should slide to make room smoothly.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "view-switch-no-animation",
      "category": "Animation",
      "description": "Switching views does not trigger collapse/expand animation",
      "steps": [
        "Open the topology view",
        "Switch to a different view (e.g., from Application to Infrastructure)",
        "Observe the layout transition"
      ],
      "expected": "The layout should update without the 300ms collapse/expand animation. Nodes should snap to new positions immediately (no sliding/resizing transitions).",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapse-level-stepper-animates",
      "category": "Animation",
      "description": "Using the collapse level stepper triggers animation",
      "steps": [
        "Open the topology view at full expand (level 4)",
        "Step down to level 1 (all collapsed) using the collapse stepper",
        "Step back up to level 2"
      ],
      "expected": "Each level change should animate the container size and position changes smoothly.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "rapid-collapse-expand-stable",
      "category": "Edge Cases",
      "description": "Rapid collapse/expand does not break layout",
      "steps": [
        "Rapidly click collapse/expand on a container several times in quick succession",
        "Wait for animations to settle"
      ],
      "expected": "The final state should be correct (collapsed or expanded based on final click). No visual glitches, stuck animations, or layout corruption.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/physical-link-fields",
  "tests": [
    {
      "id": "physical-link-inspector-details",
      "category": "PhysicalLink Inspector",
      "description": "Verify PhysicalLink edge inspector shows correct port details after field rename",
      "steps": [
        "Open the topology view",
        "Switch to L2 Physical perspective",
        "Click on a PhysicalLink edge (cable between two hosts)",
        "Verify the inspector panel shows source host, source interface, target host, and target interface details",
        "Verify the protocol tag (LLDP/CDP) is displayed"
      ],
      "setup": "Ensure at least two hosts with SNMP interfaces have LLDP/CDP neighbor discovery data creating a physical link between them.",
      "expected": "The inspector panel should display the correct host and interface details for both ends of the physical link, with the discovery protocol tag shown.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "physical-link-aggregated-edge",
      "category": "PhysicalLink Inspector",
      "description": "Verify aggregated PhysicalLink edges display correctly",
      "steps": [
        "Open the topology view",
        "Switch to L3 Logical perspective where PhysicalLink edges may be aggregated",
        "Click on an aggregated edge that contains PhysicalLink sub-edges",
        "Expand the PhysicalLink section in the aggregated edge inspector",
        "Verify each PhysicalLink sub-edge shows the correct host names in its label (e.g. 'HostA <-> HostB')"
      ],
      "setup": "Ensure at least two hosts with multiple physical links between them exist, so edges aggregate in the L3 view.",
      "expected": "Each PhysicalLink sub-edge in the aggregated display should show correct host-to-host labels derived from the interface/entity data.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "physical-link-cross-view-consistency",
      "category": "PhysicalLink Inspector",
      "description": "Verify PhysicalLink inspector works across different topology perspectives",
      "steps": [
        "Open the topology view in L2 Physical perspective",
        "Click a PhysicalLink edge and note the source/target interface details",
        "Switch to Workloads perspective",
        "If the same PhysicalLink edge is visible, click it and verify the same interface details appear",
        "Switch to L3 Logical perspective and check if PhysicalLink edges (if visible) show correct details"
      ],
      "expected": "The PhysicalLink edge inspector should show the same entity details regardless of which perspective/view the edge appears in.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/workloads-container-sort",
  "tests": [
    {
      "id": "workloads-sort-by-count",
      "category": "Workloads Container Sorting",
      "description": "Containers are sorted by workload count (most workloads first)",
      "steps": [
        "Navigate to Topology > Workloads view",
        "Observe the container order"
      ],
      "setup": "Ensure at least 3 hosts exist with different numbers of services: one with 5+ services, one with 2-3, and one with 1. All hosts should be on the default network.",
      "expected": "Containers appear sorted with the host having the most workloads (services, VMs, containers) first, and the host with fewest workloads last.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-sort-stable-expand",
      "category": "Workloads Container Sorting",
      "description": "Container order stays consistent when expanding collapse levels",
      "steps": [
        "Navigate to Topology > Workloads view at collapse level 1 (fully collapsed)",
        "Note the container order",
        "Expand to collapse level 2",
        "Verify container order is the same",
        "Expand to collapse level 3 (fully expanded)",
        "Verify container order is still the same"
      ],
      "setup": "Ensure at least 3 hosts exist with different numbers of services.",
      "expected": "Containers remain in the same relative positions at all collapse levels. They get bigger when expanded but do not rearrange.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-sort-collapse-toggle",
      "category": "Workloads Container Sorting",
      "description": "Expanding and collapsing individual containers doesn't rearrange others",
      "steps": [
        "Navigate to Topology > Workloads view",
        "Note the container order",
        "Click to expand the first container",
        "Verify other containers didn't move relative to each other",
        "Collapse it back",
        "Verify order is restored"
      ],
      "expected": "Expanding/collapsing a single container does not change the relative order of other containers.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-sort-equal-count-alpha",
      "category": "Workloads Container Sorting",
      "description": "Hosts with equal workload counts are sorted alphabetically",
      "steps": [
        "Navigate to Topology > Workloads view",
        "Look at hosts that have the same number of workloads"
      ],
      "setup": "Create 2+ hosts with the same number of services (e.g., 2 services each). Give them names that sort clearly (e.g., 'alpha-host' and 'zulu-host').",
      "expected": "Hosts with equal workload counts appear in alphabetical order by name.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/license-keys",
  "tests": [
    {
      "id": "community-build-no-key",
      "category": "License Validation",
      "description": "Community build runs normally without a license key",
      "steps": [
        "Start the server without the 'commercial' feature flag and without SCANOPY_LICENSE_KEY",
        "Log in and navigate around the app",
        "Create a host, edit it, delete it"
      ],
      "setup": "Build the server without --features commercial. Do not set SCANOPY_LICENSE_KEY env var.",
      "expected": "Server starts with 'License: not required (community)' in startup log. All operations work normally. No license banner visible.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "commercial-valid-key",
      "category": "License Validation",
      "description": "Commercial build with valid license key operates normally",
      "steps": [
        "Start the server with commercial feature and a valid license key",
        "Log in and navigate around the app",
        "Create a host, edit it, delete it"
      ],
      "setup": "Build with --features commercial. Generate a valid key: SCANOPY_LICENSE_SIGNING_KEY='<private_key>' cargo run --bin license -- create --days 365. Set SCANOPY_LICENSE_KEY to the output.",
      "expected": "Server starts with 'License: valid (expires YYYY-MM-DD)' in startup log. All operations work normally. No license banner visible.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "commercial-no-key-locked",
      "category": "License Locked State",
      "description": "Commercial build without license key enters read-only mode",
      "steps": [
        "Start the server with commercial feature but no SCANOPY_LICENSE_KEY",
        "Log in and navigate around the app",
        "Attempt to create a host",
        "Attempt to edit an existing host",
        "Verify the license banner is visible"
      ],
      "setup": "Build with --features commercial. Do not set SCANOPY_LICENSE_KEY.",
      "expected": "Server starts with 'License: INVALID (No license key provided)' in startup log. Read operations work (can view pages). Mutation attempts fail with 403 'license_locked' error. Red license banner appears at top of page.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "commercial-expired-key-locked",
      "category": "License Locked State",
      "description": "Commercial build with expired license key enters read-only mode",
      "steps": [
        "Start the server with an expired license key",
        "Log in and navigate around the app",
        "Attempt to create a host",
        "Verify the expired license banner is visible"
      ],
      "setup": "Build with --features commercial. Generate an expired key: SCANOPY_LICENSE_SIGNING_KEY='<private_key>' cargo run --bin license -- create --days 0. Set SCANOPY_LICENSE_KEY to the output.",
      "expected": "Server starts with 'License: EXPIRED' warning. Reads work, mutations fail with 403. Red banner says 'Your Scanopy license has expired.'",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "commercial-invalid-key-locked",
      "category": "License Locked State",
      "description": "Commercial build with garbage license key enters read-only mode",
      "steps": [
        "Start the server with SCANOPY_LICENSE_KEY set to 'not-a-real-key'",
        "Log in and navigate around the app",
        "Attempt to create a host"
      ],
      "setup": "Build with --features commercial. Set SCANOPY_LICENSE_KEY=not-a-real-key.",
      "expected": "Server starts with 'License: INVALID' error. Reads work, mutations fail with 403. Red banner says 'Your Scanopy license key is invalid.'",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "locked-auth-still-works",
      "category": "License Locked State",
      "description": "Authentication endpoints work in locked state",
      "steps": [
        "Start the server in locked state (no key, commercial build)",
        "Navigate to login page",
        "Log in with valid credentials",
        "Log out",
        "Log in again"
      ],
      "setup": "Build with --features commercial. Do not set SCANOPY_LICENSE_KEY.",
      "expected": "Login, logout, and re-login all work normally despite locked state.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "existing-banners-unchanged",
      "category": "Banner Refactor",
      "description": "Demo and email verification banners still render correctly after refactor",
      "steps": [
        "Log into the demo instance",
        "Verify the demo banner appears (blue, with Rocket icon and 'Create Account' link)",
        "Log into an account with unverified email",
        "Verify the email verification banner appears (yellow, with 'Resend' button)"
      ],
      "expected": "Both banners render identically to before — same colors, icons, text, and interactive elements.",
      "status": null,
      "feedback": null
    },
    {
      "id": "license-cli-create-verify",
      "category": "License CLI",
      "description": "CLI can create and verify license keys",
      "steps": [
        "Run license create command with private key",
        "Run license verify command with the output",
        "Run license verify with a garbage key"
      ],
      "setup": "Export SCANOPY_LICENSE_SIGNING_KEY with the private key PEM content.",
      "expected": "Create outputs a JWT and prints expiry to stderr. Verify shows VALID with correct dates. Garbage key shows INVALID.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/application-layout-density",
  "tests": [
    {
      "id": "application-disconnected-density",
      "category": "Application View Layout",
      "description": "Disconnected containers pack densely in Application view",
      "steps": [
        "Navigate to the Application perspective in Topology",
        "Observe containers that have no dependency edges to other containers (e.g., 'DevOps Pipeline', 'Messaging')",
        "Verify these small containers are packed beside other containers, not floating in their own row with large vertical gaps"
      ],
      "expected": "Disconnected containers are positioned adjacent to or beside connected containers, not stacked far below with wasted vertical space",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "application-connected-layout-preserved",
      "category": "Application View Layout",
      "description": "Connected containers still maintain dependency-driven layering",
      "steps": [
        "Navigate to the Application perspective in Topology",
        "Find containers that have dependency edges between them",
        "Verify that connected containers are still laid out in layers (source above target) as expected"
      ],
      "expected": "Containers with dependency edges maintain their layered top-to-bottom ordering",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-layout-no-regression",
      "category": "L3 View Regression",
      "description": "L3 (Network) view layout is unchanged",
      "steps": [
        "Switch to the L3 / Network perspective in Topology",
        "Verify subnets are still layered by type (Internet/Remote at top, LAN/WiFi in middle, Docker/Management at bottom)"
      ],
      "expected": "L3 subnet ordering matches previous behavior — no visual change",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-layout-no-regression",
      "category": "Workloads View Regression",
      "description": "Workloads view layout is unchanged",
      "steps": [
        "Switch to the Workloads perspective in Topology",
        "Verify containers are still packed in a grid with highest-workload containers in the top-left"
      ],
      "expected": "Workloads layout matches previous behavior — no visual change",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "l2-layout-no-regression",
      "category": "L2 View Regression",
      "description": "L2 Physical view layout is unchanged",
      "steps": [
        "Switch to the L2 Physical perspective in Topology",
        "Verify hosts are arranged horizontally with port-based crossing minimization"
      ],
      "expected": "L2 Physical layout matches previous behavior — no visual change",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/demo-data-fixes",
  "tests": [
    {
      "id": "service-definitions-no-fake",
      "category": "Service Definitions",
      "description": "Verify no fake service definitions are used in demo data",
      "steps": [
        "Create a new demo organization",
        "Navigate to the Services page",
        "Look for any service named 'Web Application'",
        "Verify app servers show 'Tomcat' as their service definition"
      ],
      "setup": "Create a demo organization via the organization creation flow (select 'Use demo data').",
      "expected": "No 'Web Application' services exist. App servers show 'Tomcat' with the correct Tomcat logo.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "mac-addresses-on-ips",
      "category": "MAC Addresses",
      "description": "Verify IP addresses have MAC addresses populated",
      "steps": [
        "Navigate to Hosts page in the demo organization",
        "Click on a server host (e.g., 'proxmox-hv01')",
        "Check the IP address details for a MAC address",
        "Repeat for a network device (e.g., 'pfsense-fw01') and an IoT device (e.g., 'hue-bridge')"
      ],
      "expected": "Each IP address shows a MAC address. Servers show Dell OUI (f8:bc:12), network gear shows manufacturer OUI, IoT shows device-specific OUI.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "mac-addresses-on-interfaces",
      "category": "MAC Addresses",
      "description": "Verify SNMP interfaces have MAC addresses populated",
      "steps": [
        "Navigate to a host with SNMP interfaces (e.g., 'pfsense-fw01')",
        "View the interfaces tab/section",
        "Check that interfaces show MAC addresses",
        "Verify the loopback interface on 'proxmox-hv01' does NOT show a MAC"
      ],
      "expected": "Physical interfaces show MAC addresses. Loopback interface correctly shows no MAC.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-groups-reduced-ungrouped",
      "category": "Application Groups",
      "description": "Verify most app-relevant services are in application groups",
      "steps": [
        "Navigate to the Topology page",
        "Switch to the Application perspective",
        "Check the 'Ungrouped' section",
        "Verify 'Storage' and 'Messaging' app groups appear",
        "Check that TrueNAS, MinIO, Ceph are in 'Storage'",
        "Check that RabbitMQ, mailcow are in 'Messaging'",
        "Check that Vaultwarden is in 'DevOps Pipeline'"
      ],
      "expected": "Storage and Messaging groups visible with correct members. Ungrouped only contains infrastructure-adjacent services (Proxmox VE, Docker, OpenVPN). Vaultwarden appears under DevOps Pipeline.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "dependencies-app-relevant-only",
      "category": "Dependencies",
      "description": "Verify dependencies only connect application-relevant services",
      "steps": [
        "Navigate to the Topology page, Application perspective",
        "Locate the 'Reverse Proxy Path' dependency (Traefik → Gitea)",
        "Verify pfSense is NOT part of any dependency",
        "Locate the 'Backup Flow' dependency (Proxmox VE → TrueNAS)",
        "Verify it still exists and connects correctly"
      ],
      "expected": "'Reverse Proxy Path' shows Traefik → Gitea (no pfSense). 'Backup Flow' (Proxmox VE → TrueNAS) still present. No dependency includes infrastructure-only services like SSH, SNMP, or pfSense.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/workloads-dependencies",
  "tests": [
    {
      "id": "workloads-create-dependency-multiselect",
      "category": "Dependency Creation",
      "description": "Create a dependency via multi-select in Workloads view",
      "steps": [
        "Navigate to the Workloads topology view",
        "Multi-select two or more host containers",
        "In the inspector panel, enter a dependency name and select RequestPath type",
        "Click Create to create the dependency"
      ],
      "setup": "Ensure at least 3 hosts exist on the network, each with at least one service.",
      "expected": "Dependency is created successfully. Dependency edges appear automatically connecting the selected host containers with dashed lines.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-dependency-edges-hidden-by-default",
      "category": "Edge Visibility",
      "description": "Dependency edges are hidden by default in Workloads view",
      "steps": [
        "Navigate to the Workloads topology view (fresh load or switch away and back)",
        "Open the edge visibility options panel",
        "Check the state of RequestPath and HubAndSpoke edge type toggles"
      ],
      "setup": "Create at least one dependency that spans hosts visible in Workloads view.",
      "expected": "RequestPath and HubAndSpoke edge types appear in the options but are toggled off (hidden) by default. No dependency edges are visible on the canvas.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-dependency-auto-show-on-create",
      "category": "Edge Visibility",
      "description": "Creating a dependency auto-shows dependency edges",
      "steps": [
        "Navigate to the Workloads topology view",
        "Verify dependency edges are hidden (check options panel)",
        "Multi-select hosts and create a new dependency",
        "Check the edge visibility options panel after creation"
      ],
      "setup": "Ensure at least 2 hosts with services exist.",
      "expected": "After creating the dependency, RequestPath/HubAndSpoke edges become visible automatically without manual toggle.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-dependency-edges-connect-hosts",
      "category": "Edge Routing",
      "description": "Dependency edges connect host containers, not IP addresses or services",
      "steps": [
        "Navigate to the Workloads topology view with visible dependency edges",
        "Inspect the dependency edge endpoints visually"
      ],
      "setup": "Create a dependency between services on different hosts. Toggle dependency edges visible.",
      "expected": "Dependency edges connect at the host container level, not individual service elements or IP addresses within the containers.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-hub-and-spoke-dependency",
      "category": "Dependency Creation",
      "description": "Create a Hub and Spoke dependency in Workloads view",
      "steps": [
        "Navigate to the Workloads topology view",
        "Multi-select three or more host containers",
        "Create a HubAndSpoke dependency with the first selected as hub"
      ],
      "setup": "Ensure at least 3 hosts with services exist on the network.",
      "expected": "Hub and Spoke dependency is created. Edges radiate from the hub host container to each spoke host container.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-dependency-same-host-dedup",
      "category": "Edge Routing",
      "description": "No self-loop edges when dependency services are on the same host",
      "steps": [
        "Navigate to the Workloads topology view",
        "Toggle dependency edges visible",
        "Inspect the topology for self-loop edges on any host"
      ],
      "setup": "Create a RequestPath dependency where two consecutive services are on the same host.",
      "expected": "No self-loop edge appears on the host container. Consecutive same-host services are deduplicated in the edge chain.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "application-auto-show-dependency-edges",
      "category": "Edge Visibility",
      "description": "Auto-show works in Application view too",
      "steps": [
        "Navigate to the Application topology view",
        "Hide dependency edges via the options panel",
        "Multi-select services and create a new dependency",
        "Check edge visibility after creation"
      ],
      "expected": "Dependency edges become visible automatically after creating a dependency, even though they were manually hidden.",
      "flow": null,
      "sequence": null,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-auto-show-dependency-edges",
      "category": "Edge Visibility",
      "description": "Auto-show works in L3 view too",
      "steps": [
        "Navigate to the L3 topology view",
        "Hide dependency edges via the options panel",
        "Multi-select IP addresses and create a new dependency",
        "Check edge visibility after creation"
      ],
      "expected": "Dependency edges become visible automatically after creating a dependency, even though they were manually hidden.",
      "flow": null,
      "sequence": null,
      "status": null,
      "feedback": null
    }
  ]
}
];
