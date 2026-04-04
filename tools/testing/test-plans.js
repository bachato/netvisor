var TEST_PLANS = [
{
  "branch": "refactor/topology-legacy-cleanup",
  "tests": []
}
,
{
  "branch": "feat/topology-filter-unification",
  "tests": []
}
,
{
  "branch": "feat/topology-open-ports-summary",
  "tests": [
    {
      "id": "no-measurement-flash",
      "category": "Page Load",
      "description": "Verify no flash of unstyled/piled-up nodes on page load",
      "steps": [
        "Hard-refresh the topology page",
        "Watch for any brief flash of nodes at wrong positions"
      ],
      "expected": "Topology renders smoothly without a visible flash of nodes piled at the top-left.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/topology-container-layout",
  "tests": [
    {
      "id": "columnar-layout-basic",
      "category": "Container Layout",
      "description": "Verify leaf nodes within subnet containers are arranged in columns instead of rows",
      "steps": [
        "Navigate to the Topology page",
        "Observe the layout of leaf nodes within subnet containers (especially LAN subnets with 5+ nodes)",
        "Verify nodes are arranged in vertical columns rather than horizontal rows",
        "Verify similarly-sized nodes are grouped together within columns"
      ],
      "expected": "Leaf nodes within containers should be in columnar layout. Nodes of similar height should be visually grouped together in clean columns.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "edge-aware-placement",
      "category": "Edge Awareness",
      "description": "Verify nodes with external edges are positioned near container boundaries",
      "steps": [
        "Navigate to the Topology page",
        "Identify nodes that have edges connecting to other subnets (cross-container edges)",
        "For nodes with ONLY upward edges (to subnets higher like Gateway): check they are near the top of their column",
        "For nodes with ONLY downward edges (to subnets lower like DockerBridge): check they are near the bottom of their column",
        "For bridge nodes (edges BOTH up and down): check they are at the left or right edge column of the container",
        "For bridge nodes: verify their edge handles point outward (Left or Right) from the container boundary, not Top/Bottom"
      ],
      "expected": "Upward-only nodes near top, downward-only near bottom, bridge nodes at left/right container edge with outward-facing handles. No node overlaps from swaps.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "subgroup-consistent-position",
      "category": "Sub-group Placement",
      "description": "Verify sub-group containers (TagGroup, ServiceCategoryGroup) have consistent placement",
      "steps": [
        "Navigate to the Topology page",
        "Enable leaf rules that create sub-groups (e.g., Infrastructure service category grouping)",
        "Observe where sub-group containers appear within their parent subnet containers",
        "Refresh the page and verify sub-groups appear in the same position"
      ],
      "setup": "Ensure the topology has at least one subnet with both sub-group containers and regular leaf nodes. Default leaf rules (Infrastructure ByServiceCategory) should produce sub-groups if DNS or ReverseProxy services exist.",
      "expected": "Sub-group containers should appear in a consistent, deterministic position within their parent container across page loads.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "single-node-container",
      "category": "Edge Cases",
      "description": "Verify containers with a single node render correctly",
      "steps": [
        "Navigate to the Topology page",
        "Find a subnet container with only 1 leaf node",
        "Verify it renders correctly with proper padding and sizing"
      ],
      "expected": "Single-node containers should render cleanly with the node properly padded inside the container.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "large-container-layout",
      "category": "Container Layout",
      "description": "Verify large containers (20+ nodes) pack well",
      "steps": [
        "Navigate to the Topology page",
        "Find or set up a subnet with 20+ leaf nodes",
        "Verify the columnar layout produces a compact, visually balanced container",
        "Verify no excessive whitespace or overflow"
      ],
      "setup": "Create at least 20 hosts on a single LAN subnet via the API to produce a large container.",
      "expected": "Large containers should produce a balanced multi-column layout without excessive whitespace. Columns should have roughly similar heights.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "inter-container-layout-preserved",
      "category": "No Regression",
      "description": "Verify inter-container layout (root graph) still works correctly",
      "steps": [
        "Navigate to the Topology page",
        "Verify containers are still arranged in vertical layers by subnet type (Internet/Remote at top, Gateway/VPN below, LAN in middle, Docker at bottom)",
        "Verify edges between containers route properly",
        "Verify collapsed containers still work"
      ],
      "expected": "Root-level container layout should be unchanged. Containers should respect their layer ordering and edges should route correctly between containers.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapsed-container",
      "category": "Edge Cases",
      "description": "Verify collapsed containers still render correctly",
      "steps": [
        "Navigate to the Topology page",
        "Collapse a subnet container by clicking its collapse toggle",
        "Verify it collapses to the minimum size (200x80)",
        "Expand it again and verify children reappear with columnar layout"
      ],
      "expected": "Collapsed containers should render as compact boxes. Expanding should restore the columnar layout.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/topology-grouping-split",
  "tests": [
    {
      "id": "group-headers-show-names",
      "category": "Visual",
      "description": "Leaf group container headers show category/tag names as Tag components",
      "steps": [
        "Create a ByServiceCategory rule with DNS and ReverseProxy, title 'Infrastructure'",
        "Create a ByTag rule with 2 tags selected, no custom title",
        "Click checkmark to confirm, wait for rebuild"
      ],
      "setup": "Ensure hosts exist with DNS/ReverseProxy services and tags.",
      "expected": "Service category group header shows 'Infrastructure:' followed by colored Tag pills for DNS and ReverseProxy. Tag group header shows colored Tag pills for each tag.",
      "status": null,
      "feedback": null
    }
  ]
}
];
