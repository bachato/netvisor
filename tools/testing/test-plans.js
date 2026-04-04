var TEST_PLANS = [
{
  "branch": "refactor/naming-normalization",
  "tests": [
    {
      "id": "topology-loads-with-new-types",
      "category": "Topology Rendering",
      "description": "Topology view renders correctly with renamed node types",
      "steps": [
        "Navigate to the topology page for a network with hosts and subnets",
        "Verify container (subnet) nodes render with headers, icons, and resize handles",
        "Verify element (host/interface) nodes render with services, headers, and footer IPs",
        "Verify edges connect between nodes correctly"
      ],
      "setup": "Ensure at least one topology exists with multiple subnets and hosts via normal discovery or manual creation.",
      "expected": "All nodes and edges render identically to before the rename. No visual differences.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "element-grouping-rules-work",
      "category": "Grouping Rules",
      "description": "Element grouping rules (renamed from leaf rules) function correctly",
      "steps": [
        "Open topology options panel",
        "In the 'Element grouping' section, add a ByServiceCategory rule",
        "Configure it with a service category that exists in the topology",
        "Verify nested sub-group containers appear within subnet containers",
        "Add a ByTag rule and verify it creates a separate group"
      ],
      "expected": "Element grouping rules create nested containers within subnets. First-match-wins priority applies. Rule titles display correctly.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "node-inspector-panels",
      "category": "Inspector",
      "description": "Node inspector panels display for both node types",
      "steps": [
        "Click on an element (host/interface) node in the topology",
        "Verify the inspector panel shows host details, services, and focus button",
        "Click on a container (subnet) node label to select it",
        "Verify the inspector panel shows subnet details"
      ],
      "expected": "Inspector panels display correctly for both Container and Element node types.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapse-expand-containers",
      "category": "Collapse/Expand",
      "description": "Container collapse and expand works with renamed types",
      "steps": [
        "Click the collapse chevron on a subnet container",
        "Verify the container collapses to show host count badge",
        "Click the collapse-all button in the top-right panel",
        "Verify all containers collapse",
        "Click the expand-all button",
        "Verify all containers expand back"
      ],
      "expected": "Collapse/expand works identically to before.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "multi-select-element-nodes",
      "category": "Multi-Select",
      "description": "Multi-select works with renamed element nodes",
      "steps": [
        "Ctrl+click two element nodes to multi-select them",
        "Verify the multi-select action bar appears with correct count",
        "Verify host details resolve correctly for selected nodes"
      ],
      "expected": "Multi-select works correctly with Element node type.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/grouping-ui-polish",
  "tests": [
    {
      "id": "subgroup-header-inside-bounds",
      "category": "Subgroup Layout",
      "description": "Subgroup headers render inside container bounds, not above them",
      "steps": [
        "Open a topology that has TagGroup or ServiceCategoryGroup containers",
        "Observe the subgroup header (chevron + title + tag pills) position"
      ],
      "setup": "Ensure the topology has hosts grouped by tags or service categories so that subgroup containers are visible.",
      "expected": "Subgroup headers appear inside the top padding of the container, not floating above the container's border",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "no-overlap-between-subgroups",
      "category": "Subgroup Layout",
      "description": "No visual overlap between adjacent subgroups or between subgroups and ungrouped nodes",
      "steps": [
        "Open a topology with multiple sibling subgroups inside a parent container",
        "Observe spacing between adjacent subgroup containers"
      ],
      "setup": "Ensure the topology has a parent container with at least 2 sibling TagGroup or ServiceCategoryGroup subgroups.",
      "expected": "Adjacent subgroups have clear spacing (30px nodeNode) with no header or border overlap",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "subgroup-padding-balanced",
      "category": "Subgroup Layout",
      "description": "Subgroup padding is balanced (20px on non-header sides)",
      "steps": [
        "Open a topology with expanded subgroup containers containing leaf nodes",
        "Visually inspect the padding on left, right, and bottom sides of subgroup containers"
      ],
      "setup": "Ensure subgroups have multiple leaf nodes so padding is visually apparent.",
      "expected": "Left, right, and bottom padding appear equal (20px each), with 30px top for the header area",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "subgroup-header-click-target",
      "category": "Click Targets",
      "description": "Clicking anywhere on subgroup header bar toggles collapse",
      "steps": [
        "Open a topology with visible subgroup containers",
        "Click on the tag pill in the subgroup header",
        "Click on the title text in the subgroup header",
        "Click on the chevron icon"
      ],
      "expected": "Each click location toggles the subgroup between collapsed and expanded state. Cursor shows pointer on hover over the entire header bar.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "subnet-header-click-target",
      "category": "Click Targets",
      "description": "Clicking anywhere on subnet header bar toggles collapse",
      "steps": [
        "Open a topology with visible subnet containers",
        "Click on the subnet label text in the header",
        "Click on the subnet icon in the header",
        "Click on the chevron icon"
      ],
      "expected": "Each click location toggles the subnet between collapsed and expanded state. Cursor shows pointer on hover over the entire header bar.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapsed-subgroup-compact",
      "category": "Collapsed State",
      "description": "Collapsed subgroups show compact inline representation",
      "steps": [
        "Open a topology with expanded subgroup containers",
        "Collapse a subgroup by clicking its header",
        "Observe the collapsed representation"
      ],
      "setup": "Ensure subgroups have multiple hosts so the count is meaningful.",
      "expected": "Collapsed subgroup shows a compact inline header with chevron, title, tag pills, and host count (e.g., '(3 hosts)') — no large 200x80 dashed box. The representation is small (~120x36px).",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "open-ports-expansion-relayout",
      "category": "Port Expansion",
      "description": "Expanding open ports triggers re-layout so neighbors move",
      "steps": [
        "Open a topology where leaf nodes have hidden open ports ('+N open ports' button visible)",
        "Click the '+N open ports' button on a node that has neighbors nearby",
        "Observe if neighboring nodes reposition"
      ],
      "setup": "Ensure topology has nodes with open ports that are hidden by default, and those nodes have nearby neighbors that would overlap if the node grew without re-layout.",
      "expected": "After clicking to expand open ports, the topology re-layouts and neighboring nodes move to accommodate the expanded node height. No overlapping occurs.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "open-ports-collapse-relayout",
      "category": "Port Expansion",
      "description": "Collapsing open ports triggers re-layout to reclaim space",
      "steps": [
        "With open ports expanded on a node, click 'Hide open ports'",
        "Observe if the layout compacts back"
      ],
      "expected": "After collapsing open ports, the topology re-layouts and neighbors move back to a compact arrangement.",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    }
  ]
}
];
