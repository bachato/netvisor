var TEST_PLANS = [
{
  "branch": "fix/category-tooltip-title",
  "tests": []
}
,
{
  "branch": "fix/edge-container-routing",
  "tests": [
    {
      "id": "app-view-bystack-edge-routing",
      "category": "Edge Routing",
      "description": "ServiceVirtualization edges in Application view route to ByStack subcontainer",
      "steps": [
        "Open topology in Application view",
        "Ensure a host with Docker services grouped by compose project is visible",
        "Verify ServiceVirtualization edges attach to the ByStack subcontainer boundary, not individual services inside"
      ],
      "setup": "Ensure at least one host has Docker services with compose_project values that trigger ByStack grouping.",
      "expected": "Edges connect to the Stack subcontainer boundary. Edge bundling shows count if multiple edges target the same container.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-view-merge-docker-bridges-routing",
      "category": "Edge Routing",
      "description": "ServiceVirtualization edges in L3 view route to MergeDockerBridges container",
      "steps": [
        "Open topology in L3 Logical view with MergeDockerBridges enabled (default)",
        "Find a host with Docker bridge subnets",
        "Verify ServiceVirtualization edges attach to the merged Docker Bridge container, not individual interfaces inside"
      ],
      "expected": "Edges connect to the consolidated Docker Bridge container boundary. Multiple edges are bundled with a count.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-view-bystack-inside-merge-routing",
      "category": "Edge Routing",
      "description": "ByStack subcontainer inside MergeDockerBridges — edges route to outer container",
      "steps": [
        "Open topology in L3 Logical view with both MergeDockerBridges and ByStack rules active",
        "Find a host with Docker compose services (ByStack groups visible inside merged Docker Bridge)",
        "Verify edges attach to the MergeDockerBridges container (outermost absorber), not the ByStack subcontainer"
      ],
      "expected": "Edges connect to the outer MergeDockerBridges container, not the inner ByStack subcontainer.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-no-merge-bystack-routing",
      "category": "Edge Routing",
      "description": "ByStack without MergeDockerBridges — edges route to ByStack subcontainer",
      "steps": [
        "Open topology in L3 Logical view",
        "Disable MergeDockerBridges rule via topology settings",
        "Find Docker compose services grouped by ByStack inside individual Docker bridge subnets",
        "Verify edges attach to the ByStack subcontainer, not the subnet"
      ],
      "expected": "Edges connect to the ByStack subcontainer within the regular subnet container.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "edge-bundling-after-elevation",
      "category": "Edge Bundling",
      "description": "Edge bundling still works with elevated edges",
      "steps": [
        "Open topology in Application view with edge bundling enabled",
        "Find a ByStack container with multiple ServiceVirtualization edges",
        "Verify the bundle shows the correct edge count",
        "Click the bundle to expand and verify individual edges are shown"
      ],
      "expected": "Bundled edge shows correct count. Expanding bundle reveals individual edges.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "infrastructure-view-no-regression",
      "category": "Regression",
      "description": "Infrastructure view edges still work correctly",
      "steps": [
        "Open topology in Infrastructure view",
        "Verify all edges render correctly (HostVirtualization, etc.)",
        "Check that no edges are misrouted or missing"
      ],
      "expected": "Infrastructure view renders edges as before with no visual regressions.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "non-absorbing-subcontainer-no-elevation",
      "category": "Edge Routing",
      "description": "Edges to elements in non-absorbing subcontainers are NOT elevated",
      "steps": [
        "Open topology in a view with ByTag or ByServiceCategory subcontainers",
        "Verify edges still target individual elements inside these subcontainers, not the subcontainer boundary"
      ],
      "expected": "Edges connect directly to elements, not to the ByTag/ByServiceCategory subcontainer boundary.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/topology-perspective-to-view",
  "tests": []
}
,
{
  "branch": "fix/collapsed-container-vanish",
  "tests": [
    {
      "id": "collapse-all-shows-summaries",
      "category": "Collapse All",
      "description": "Collapse All shows all containers as compact summary nodes",
      "steps": [
        "Open the topology view with multiple containers visible",
        "Click the 'Collapse All' button in the toolbar",
        "Verify all containers are visible as compact summary nodes showing header + element count"
      ],
      "expected": "All containers remain visible in their collapsed state with element counts displayed. No containers vanish.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "expand-after-collapse-all",
      "category": "Collapse All",
      "description": "Expanding a container after Collapse All restores its children",
      "steps": [
        "After 'Collapse All', click on a collapsed container to expand it",
        "Verify the container's children (host nodes) reappear inside it"
      ],
      "expected": "The expanded container shows all its child nodes. Other containers remain collapsed.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "expand-all-restores",
      "category": "Collapse All",
      "description": "Expand All restores all containers and children",
      "steps": [
        "Click 'Collapse All' to collapse all containers",
        "Click 'Expand All' to expand all containers",
        "Verify all containers show their children"
      ],
      "expected": "All containers are expanded with all child nodes visible, matching the original state.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "individual-collapse-expand",
      "category": "Individual Collapse",
      "description": "Individual container collapse and expand works correctly",
      "steps": [
        "Open topology with all containers expanded",
        "Click to collapse a single container",
        "Verify it shows as a compact summary node with element count",
        "Click to expand it again",
        "Verify its children reappear"
      ],
      "expected": "The container toggles between collapsed (compact summary) and expanded (children visible) states. Other containers are unaffected.",
      "status": null,
      "feedback": null
    },
    {
      "id": "collapse-all-individually",
      "category": "Individual Collapse",
      "description": "Collapsing every container one by one keeps all visible",
      "steps": [
        "Open topology with multiple containers",
        "Collapse each container individually, one at a time",
        "After each collapse, verify the container remains visible as a summary node"
      ],
      "expected": "After collapsing all containers individually, all are still visible as compact summary nodes. None vanish.",
      "status": null,
      "feedback": null
    },
    {
      "id": "collapse-with-hidden-services",
      "category": "Edge Cases",
      "description": "Collapsed containers remain visible when services are hidden",
      "steps": [
        "Open topology and hide some service categories via the filter panel",
        "Collapse a container whose children include hidden services",
        "Verify the container still shows as a collapsed summary node"
      ],
      "expected": "Collapsed containers are visible even when hidden service filtering has removed some of their child elements.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/subcontainer-service-icons",
  "tests": [
    {
      "id": "virtualizer-proxmox-logo",
      "category": "Virtualizer Subcontainer Icons",
      "description": "Proxmox Virtualizer subcontainer shows Proxmox VE logo next to hypervisor hostname",
      "steps": [
        "Navigate to the Infrastructure topology view",
        "Ensure ByVirtualizer element rule is active",
        "Locate a Virtualizer subcontainer for a Proxmox hypervisor"
      ],
      "setup": "Ensure at least one host is virtualized by a Proxmox VE service (host with Proxmox virtualization pointing to a Proxmox service on a hypervisor host).",
      "expected": "The Virtualizer subcontainer shows the Proxmox VE logo (brand SVG) next to the hypervisor hostname in the title area",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "virtualizer-docker-logo",
      "category": "Virtualizer Subcontainer Icons",
      "description": "Docker Virtualizer subcontainer shows Docker logo next to daemon host name",
      "steps": [
        "Navigate to the Infrastructure topology view",
        "Ensure ByVirtualizer element rule is active",
        "Locate a Virtualizer subcontainer for a Docker daemon host"
      ],
      "setup": "Ensure at least one host is virtualized by Docker (host with Docker daemon service that manages virtualization, virtualizing other hosts).",
      "expected": "The Virtualizer subcontainer shows the Docker whale logo next to the daemon hostname in the title area",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "stack-docker-logo",
      "category": "Stack Subcontainer Icons",
      "description": "Stack subcontainer shows Docker logo next to compose project name",
      "steps": [
        "Navigate to a topology view with ByStack element rule active (Infrastructure or L3)",
        "Locate a Stack subcontainer grouping Docker Compose services"
      ],
      "setup": "Ensure at least one host has Docker services with a compose_project set (Docker Compose stack).",
      "expected": "The Stack subcontainer shows the Docker whale logo next to the compose project name (e.g., Docker logo + 'media-stack')",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapsed-subcontainer-logo",
      "category": "Collapsed State",
      "description": "Logo persists when subcontainer is collapsed",
      "steps": [
        "Find a Virtualizer or Stack subcontainer with a logo visible",
        "Click the subcontainer to collapse it"
      ],
      "expected": "The collapsed subcontainer still shows the service logo next to the header text and element count",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "tag-subcontainer-unaffected",
      "category": "No Regression",
      "description": "ByTag and ByServiceCategory subcontainers are not affected",
      "steps": [
        "Navigate to a topology view with ByTag or ByServiceCategory element rules",
        "Inspect the subcontainer title area"
      ],
      "expected": "ByTag subcontainers show tag pills as before, ByServiceCategory subcontainers show category pills as before — no unexpected logo icons appear",
      "status": null,
      "feedback": null
    },
    {
      "id": "stack-logo-application-view",
      "category": "Stack Subcontainer Icons",
      "description": "Stack subcontainer shows Docker logo in the Application topology view",
      "steps": [
        "Navigate to the Application topology view",
        "Ensure ByStack element rule is active",
        "Locate a Stack subcontainer"
      ],
      "setup": "Ensure services with compose_project exist in an application group.",
      "expected": "The Stack subcontainer shows the Docker whale logo next to the compose project name in the Application view",
      "status": null,
      "feedback": null
    }
  ]
}
];
