var TEST_PLANS = [
{
  "branch": "feat/application-builder",
  "tests": [
    {
      "id": "application-perspective-shows-services",
      "category": "Application Perspective",
      "description": "Application perspective shows services grouped by category",
      "steps": [
        "Navigate to the topology view",
        "Switch to the Application perspective using the perspective selector",
        "Verify that services are displayed as nodes grouped inside category containers (e.g., Database, Monitoring, ReverseProxy)",
        "Verify each container shows the category name as its header",
        "Verify each service node shows its service name"
      ],
      "setup": "Ensure the network has at least 3 services across different categories (e.g., a PostgreSQL database service, a Traefik reverse proxy, and a Grafana monitoring service), each with at least one binding.",
      "expected": "Services appear as element nodes inside their respective category containers. Each container has the category name as header and uses the category's icon/color.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "application-perspective-request-path-edges",
      "category": "Application Perspective",
      "description": "Request path dependency edges connect services in order",
      "steps": [
        "In the Application perspective, verify that request path group edges are visible between service nodes",
        "Verify edges follow the order defined in the group (e.g., Nginx → App → Database)"
      ],
      "setup": "Create a RequestPath group with bindings from 3 different services (e.g., Nginx binding → App binding → Database binding). Each service must have at least one binding.",
      "expected": "Edges connect service nodes in chain order (Nginx→App, App→Database). Edges are displayed as primary edges with arrows.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "application-perspective-hub-spoke-edges",
      "category": "Application Perspective",
      "description": "Hub and spoke dependency edges connect hub to spokes",
      "steps": [
        "In the Application perspective, verify that hub-and-spoke group edges are visible",
        "Verify the first service in the group acts as the hub with edges to all other services"
      ],
      "setup": "Create a HubAndSpoke group with bindings from 3 services (e.g., Load Balancer, App1, App2). The first binding's service should be the hub.",
      "expected": "Hub service has edges to each spoke service. No edges between spokes.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "application-perspective-no-unbound-services",
      "category": "Application Perspective",
      "description": "Services without bindings are excluded from the topology",
      "steps": [
        "In the Application perspective, verify that services without any bindings do not appear as nodes"
      ],
      "setup": "Ensure at least one service exists without any bindings alongside services that have bindings.",
      "expected": "Only services with bindings appear in the topology. The unbound service is not shown.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "application-perspective-docker-virtualization-edges",
      "category": "Application Perspective",
      "description": "Docker virtualization edges show containerization relationships",
      "steps": [
        "In the Application perspective, verify that dashed edges connect Docker engine services to their containerized services"
      ],
      "setup": "Ensure a host has a Docker service that containerizes other services (e.g., Docker → Nginx, Docker → Redis). All services must have bindings.",
      "expected": "ServiceVirtualization edges (dashed) connect the Docker service to each containerized service.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-perspective-unaffected",
      "category": "Regression",
      "description": "L3 perspective continues to work correctly after refactor",
      "steps": [
        "Navigate to the topology view in L3 Logical perspective (default)",
        "Verify hosts appear as element nodes inside subnet containers",
        "Verify interface edges, group edges, and virtualization edges display correctly"
      ],
      "expected": "L3 perspective renders identically to before the changes. No visual regressions.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/topology-perspective-frontend",
  "tests": [
    {
      "id": "l3-topology-unchanged",
      "category": "Visual Regression",
      "description": "L3 topology renders identically after refactoring",
      "steps": [
        "Navigate to the topology page",
        "Select a network with hosts/subnets",
        "Verify the topology renders with correct node positions, edge routing, and container layout",
        "Toggle edge visibility options (e.g., hide/show HostVirtualization edges)",
        "Collapse and expand containers",
        "Verify minimap, controls, and zoom work correctly"
      ],
      "setup": "Ensure at least one network has a topology with multiple subnets, hosts, and edges.",
      "expected": "Topology should render identically to before the refactoring. No visual differences in node placement, edge routing, container sizing, or UI controls.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "options-persist-across-sessions",
      "category": "Options Store",
      "description": "Topology options persist in localStorage and survive page reload",
      "steps": [
        "Open the topology options panel",
        "Toggle some options (e.g., hide minimap, change edge visibility, add/remove a grouping rule)",
        "Refresh the page",
        "Open the options panel again"
      ],
      "expected": "All toggled options should be preserved after page reload.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "localstorage-migration",
      "category": "Options Store",
      "description": "Existing flat localStorage options migrate to per-perspective format",
      "steps": [
        "Navigate to the topology page",
        "Open browser DevTools > Application > Local Storage",
        "Check the value of scanopy_topology_options"
      ],
      "setup": "Before navigating, manually set localStorage key 'scanopy_topology_options' to a flat TopologyOptions JSON object (e.g., {\"local\":{\"hide_edge_types\":[\"RequestPath\"],\"no_fade_edges\":true,\"hide_resize_handles\":false,\"bundle_edges\":true,\"show_minimap\":false},\"request\":{\"hide_ports\":false,\"hide_vm_title_on_docker_container\":false,\"hide_service_categories\":[\"OpenPorts\"],\"container_rules\":[],\"element_rules\":[]}})",
      "expected": "After page load, the localStorage value should be a per-perspective object with 'l2_physical', 'l3_logical', 'infrastructure', 'application' keys. The l3_logical entry should contain the migrated flat options (e.g., no_fade_edges: true, show_minimap: false). Other perspectives should have default values.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "grouping-rules-available",
      "category": "Grouping Rules",
      "description": "All grouping rules are available in L3 perspective",
      "steps": [
        "Open the topology options panel",
        "In Container Grouping, click the add button",
        "Verify BySubnet and ByVirtualizingService are available (if not already added)",
        "In Element Grouping, click the add button",
        "Verify ByServiceCategory and ByTag are available"
      ],
      "expected": "All container and element rule types should be visible for the L3 perspective. No rules should be filtered out.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "option-toggles-work",
      "category": "Options Panel",
      "description": "Option toggles (edge types, categories, tags) function correctly",
      "steps": [
        "Open the topology options panel",
        "Toggle edge type visibility (e.g., show PhysicalLink edges)",
        "Toggle a service category visibility",
        "Toggle bundle edges on/off",
        "Toggle minimap on/off"
      ],
      "expected": "Each toggle should take effect immediately on the topology visualization. Edge visibility, category visibility, bundling, and minimap all respond to changes.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "reset-options",
      "category": "Options Store",
      "description": "Reset options restores all defaults",
      "steps": [
        "Open topology options panel",
        "Change several options",
        "Trigger options reset (if reset button exists in UI)",
        "Verify options return to defaults"
      ],
      "expected": "All options should return to their default values for all perspectives.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/topology-perspective-backend",
  "tests": [
    {
      "id": "l3-topology-unchanged",
      "category": "Topology Rendering",
      "description": "L3 topology renders identically after refactoring",
      "steps": [
        "Navigate to a network with discovered hosts and services",
        "Open the topology view",
        "Verify all subnet containers, element nodes, and edges render correctly",
        "Verify nested group containers (service category groups) appear correctly",
        "Verify Docker bridge consolidation works if applicable"
      ],
      "expected": "Topology looks identical to before the refactor — same nodes, edges, containers, and layout",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "rebuild-preserves-edge-handles",
      "category": "Handle Preservation",
      "description": "Edge handles are preserved when rebuilding with same perspective",
      "steps": [
        "Open topology view",
        "Drag an edge handle to a different connection point on a node",
        "Trigger a topology rebuild (e.g., refresh or modify options)",
        "Verify the edge handle position is preserved after rebuild"
      ],
      "expected": "Edge handles remain at the user-edited positions after rebuild",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "grouping-rules-metadata-perspectives",
      "category": "Grouping Rules",
      "description": "Rule metadata endpoint includes perspectives field",
      "steps": [
        "Open the topology rule configuration UI (grouping rules panel)",
        "Inspect the rule metadata (via browser devtools network tab or UI display)"
      ],
      "setup": "Ensure the topology metadata endpoint is accessible. Check the response payload for container and element rule metadata.",
      "expected": "Each rule's metadata JSON includes a 'perspectives' array listing applicable perspectives",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/service-flow-rework",
  "tests": [
    {
      "id": "dependencies-tab-loads",
      "category": "Dependencies Tab",
      "description": "Dependencies tab renders correctly with renamed labels",
      "steps": [
        "Navigate to the Dependencies tab in the sidebar",
        "Verify the tab header says 'Dependencies' not 'Groups'",
        "Verify the subtitle text references dependencies"
      ],
      "expected": "Tab loads with 'Dependencies' title and correct subtitle text",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "dependency-create-modal",
      "category": "Dependencies Tab",
      "description": "Create Dependency modal opens and has renamed labels",
      "steps": [
        "Click 'Create' button on Dependencies tab",
        "Verify modal title says 'Create Dependency'",
        "Verify the type selector says 'Dependency Type' not 'Group Type'",
        "Verify the name field label says 'Dependency Name'",
        "Navigate through all wizard steps (Details, Service Bindings, Edge Appearance)"
      ],
      "expected": "All modal labels use 'Dependency' terminology, wizard steps work correctly",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "dependency-card-display",
      "category": "Dependencies Tab",
      "description": "Dependency cards display correctly with renamed type labels",
      "steps": [
        "View existing dependencies in the Dependencies tab",
        "Verify cards show 'Dependency Type' label (not 'Group Type')",
        "Verify service members are displayed correctly"
      ],
      "setup": "Create at least one dependency with services via the API",
      "expected": "Cards render with correct dependency terminology and show service members",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-dependency-edges",
      "category": "Topology",
      "description": "Dependency edges render correctly on topology view",
      "steps": [
        "Navigate to the Topology tab",
        "Verify dependency edges are visible (if dependencies exist)",
        "Click on a dependency edge to open the inspector",
        "Verify inspector shows 'Dependency' label (not 'Group')"
      ],
      "setup": "Create a dependency with at least 2 service members and rebuild topology",
      "expected": "Dependency edges render and inspector shows correct terminology",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-multiselect-create-dependency",
      "category": "Topology",
      "description": "Multi-select action bar allows creating dependencies",
      "steps": [
        "Select multiple nodes on the topology",
        "Verify the action bar shows 'Create Dependency' button (not 'Create Group')",
        "Click 'Create Dependency' and fill in the name",
        "Confirm creation"
      ],
      "setup": "Ensure topology has at least 2 hosts with services",
      "expected": "Dependency is created successfully from multi-select, button labels say 'Dependency'",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "sidebar-dependencies-navigation",
      "category": "Navigation",
      "description": "Sidebar shows 'Dependencies' tab with correct icon and navigation",
      "steps": [
        "Look at the sidebar navigation",
        "Verify 'Dependencies' appears as a tab (not 'Groups')",
        "Click the Dependencies tab",
        "Verify it navigates to the dependencies view"
      ],
      "expected": "Sidebar shows 'Dependencies' label and navigates correctly",
      "status": null,
      "feedback": null
    },
    {
      "id": "feature-nudge-dependency",
      "category": "Home",
      "description": "Feature nudge for dependency creation uses correct labels",
      "steps": [
        "Navigate to the Home tab",
        "If the dependency creation nudge is visible, verify it says 'Create a Dependency' (not 'Create a Group')",
        "Click the nudge action button",
        "Verify it navigates to dependencies tab and opens the editor"
      ],
      "setup": "Ensure a topology has been rebuilt but no dependency has been created yet (FirstDependencyCreated onboarding step not completed)",
      "expected": "Nudge shows 'Dependency' terminology and navigates to dependency editor",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/l3-ui-bugs",
  "tests": [
    {
      "id": "grid-snapping-uniform-padding",
      "category": "Bug 1: Grid Snapping",
      "description": "Verify all nodes have uniform padding within containers",
      "steps": [
        "Open the L3 topology view",
        "Trigger a rebuild",
        "Inspect container boundaries and node spacing visually",
        "Verify no nodes have 2x padding gaps compared to their neighbors"
      ],
      "expected": "All nodes within containers have consistent, uniform spacing. No visible 2x padding gaps between some nodes.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "tags-show-on-reload",
      "category": "Bug 2: Tags on Subcontainer Titles",
      "description": "Verify tags appear on subcontainer titles immediately after page reload",
      "setup": "Ensure topology has element rules with ByServiceCategory or ByTag grouping configured.",
      "steps": [
        "Open L3 topology and verify tags show next to subcontainer titles",
        "Hard-reload the page (Cmd+Shift+R)",
        "Observe the subcontainer titles immediately after reload"
      ],
      "expected": "Tags (e.g., 'DNS', 'ReverseProxy') appear next to subcontainer titles immediately after reload, possibly with gray colors initially that update to correct colors once data loads. No rebuild needed.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapse-expand-position-stable",
      "category": "Bug 3: Collapse/Expand Position",
      "description": "Verify collapsing then expanding a subcontainer restores its position without overlap",
      "steps": [
        "Open L3 topology with nested subcontainers visible",
        "Note the position and size of a subcontainer",
        "Collapse the subcontainer",
        "Expand the same subcontainer",
        "Compare position and size to the original"
      ],
      "expected": "The subcontainer returns to approximately the same position and size. No overlap with neighboring nodes or containers.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapse-expand-with-children",
      "category": "Bug 3: Collapse/Expand Position",
      "description": "Verify collapse/expand works correctly when subcontainer has nested children",
      "steps": [
        "Open L3 topology with a container that has nested subcontainers",
        "Collapse a parent subcontainer (children should cascade-collapse)",
        "Expand the parent subcontainer",
        "Verify children remain collapsed and parent is correctly sized"
      ],
      "expected": "Parent expands to correct size based on collapsed children. No overlap or position shift.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "subcontainer-drag-constrained",
      "category": "Bug 4: Subcontainer Drag Constraint",
      "description": "Verify subcontainers cannot be dragged outside their parent container",
      "steps": [
        "Open L3 topology with nested subcontainers",
        "Try to drag a subcontainer outside its parent container boundary",
        "Try to drag an element node outside its container for comparison"
      ],
      "expected": "Both subcontainers and element nodes are constrained to their parent container. Neither can be dragged outside.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "element-rules-persist-reload",
      "category": "Bug 5: Element Rules Persistence",
      "description": "Verify element rules persist across page reloads",
      "steps": [
        "Open L3 topology options panel",
        "Note the current element rules",
        "Reload the page",
        "Open options panel again and verify element rules are still present"
      ],
      "expected": "Element rules are preserved across page reloads. No rules disappear.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "element-rules-persist-perspective-switch",
      "category": "Bug 5: Element Rules Persistence",
      "description": "Verify element rules persist when switching perspectives",
      "steps": [
        "Open L3 topology and note element rules in options",
        "Switch to a different perspective (if available)",
        "Switch back to L3",
        "Verify element rules are intact"
      ],
      "expected": "Element rules are preserved after perspective round-trip. Default rules are not lost.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/perspective-selector",
  "tests": [
    {
      "id": "perspective-selector-visible",
      "category": "Perspective Selector",
      "description": "Perspective selector appears in topology toolbar",
      "steps": [
        "Navigate to Topology tab",
        "Verify a segmented control with 'L3 Logical' and 'Application' options appears in the toolbar after the topology dropdown"
      ],
      "expected": "Segmented control is visible with two options. L3 Logical is selected by default. Both options have icons.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "switch-to-application",
      "category": "Perspective Selector",
      "description": "Switching to Application perspective triggers rebuild",
      "steps": [
        "On the Topology tab with L3 Logical selected",
        "Click 'Application' in the perspective selector"
      ],
      "expected": "Application becomes highlighted in the selector. The topology rebuilds (layout changes). The toolbar bottom border color changes from blue to purple.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "switch-back-to-l3",
      "category": "Perspective Selector",
      "description": "Switching back to L3 preserves L3 options",
      "steps": [
        "With Application perspective active",
        "Click 'L3 Logical' in the perspective selector"
      ],
      "expected": "L3 Logical becomes highlighted. Topology rebuilds back to L3 layout. Toolbar border returns to blue. Previously set L3 options (e.g., hidden edge types) are preserved.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "color-cue-changes",
      "category": "Perspective Selector",
      "description": "Toolbar color accent reflects active perspective",
      "steps": [
        "Toggle between L3 Logical and Application perspectives",
        "Observe the toolbar bottom border color"
      ],
      "expected": "L3 Logical shows a blue bottom border accent. Application shows a purple bottom border accent. The color transition is smooth (0.3s ease).",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    }
  ]
}
];
