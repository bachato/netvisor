var TEST_PLANS = [
{
  "branch": "feat/topo-app-wizard",
  "tests": [
    {
      "id": "wizard-appears-no-app-groups",
      "category": "Wizard Gate",
      "description": "Wizard appears when switching to Application perspective with no app-group tags",
      "steps": [
        "Navigate to the topology tab",
        "Select 'Application' from the perspective dropdown"
      ],
      "setup": "Ensure no tags with is_application_group=true exist for the organization. Delete any existing app-group tags via the API.",
      "expected": "A modal wizard appears with 'Application Perspective Setup' title and step 1 'Define Groups' active. The wizard cannot be closed or dismissed.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "wizard-not-skippable",
      "category": "Wizard Gate",
      "description": "Wizard cannot be skipped or dismissed",
      "steps": [
        "With the wizard open, try clicking outside the modal",
        "Try pressing Escape",
        "Verify there is no close (X) button"
      ],
      "expected": "The wizard remains open. No close button visible, clicking outside and Escape do nothing.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "step1-suggestions-homelab",
      "category": "Step 1 - Define Groups",
      "description": "Correct suggestions shown for homelab use case",
      "steps": [
        "With wizard on Step 1, observe the suggested groups section"
      ],
      "setup": "Set organization use_case to 'homelab' via the API.",
      "expected": "Suggestions include: Media Stack, Home Automation, Monitoring, Network Infrastructure, Development, Smart Home",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "step1-suggestions-company",
      "category": "Step 1 - Define Groups",
      "description": "Correct suggestions shown for company use case",
      "steps": [
        "With wizard on Step 1, observe the suggested groups section"
      ],
      "setup": "Set organization use_case to 'company' via the API.",
      "expected": "Suggestions include: Production, Staging, Internal Tools, Monitoring, CI/CD, Shared Services",
      "status": null,
      "feedback": null
    },
    {
      "id": "step1-suggestions-msp",
      "category": "Step 1 - Define Groups",
      "description": "MSP use case shows client name input",
      "steps": [
        "With wizard on Step 1 for an MSP org, observe the UI",
        "Type a client name (e.g. 'Acme Corp') and click 'Add client'"
      ],
      "setup": "Set organization use_case to 'msp' via the API.",
      "expected": "Shows Shared Infrastructure and Monitoring suggestions, plus a client name input with explanation text. Typing a client name and clicking 'Add client' creates an app-group tag named 'Acme Corp'.",
      "status": null,
      "feedback": null
    },
    {
      "id": "step1-one-click-add",
      "category": "Step 1 - Define Groups",
      "description": "One-click suggestion adds app-group tag",
      "steps": [
        "Click a suggestion chip (e.g. 'Monitoring')"
      ],
      "expected": "The suggestion disappears from the chip list. A tag pill labeled 'Monitoring' appears in the created groups area below. The tag has is_application_group=true.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "step1-custom-group",
      "category": "Step 1 - Define Groups",
      "description": "Custom group creation works",
      "steps": [
        "Type 'My Custom App' in the custom group name input",
        "Click 'Add' or press Enter"
      ],
      "expected": "A new app-group tag pill labeled 'My Custom App' appears in the created groups area.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "step1-remove-group",
      "category": "Step 1 - Define Groups",
      "description": "Removing a created group works",
      "steps": [
        "Click the X button on one of the created group pills"
      ],
      "expected": "The tag pill is removed. If it was from a suggestion, the suggestion chip reappears.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "step1-next-disabled-no-groups",
      "category": "Step 1 - Define Groups",
      "description": "Next button disabled when no groups exist",
      "steps": [
        "Remove all created groups",
        "Check the Next button state"
      ],
      "expected": "Next button is disabled. Message 'Add at least one application group to continue.' is visible.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "step2-host-list-inline-picker",
      "category": "Step 2 - Assign Hosts",
      "description": "Host list shows with inline app-group tag pickers",
      "steps": [
        "Create at least 2 groups in Step 1",
        "Click Next to go to Step 2",
        "Observe the host list"
      ],
      "setup": "Create at least 3 hosts on the default network via the API.",
      "expected": "All hosts are listed with inline tag pickers. The tag pickers only show app-group tags (not regular tags).",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    },
    {
      "id": "step2-inline-tag-assign",
      "category": "Step 2 - Assign Hosts",
      "description": "Inline tag picker assigns app-group to host",
      "steps": [
        "Click the tag picker on a host row",
        "Select an app-group tag"
      ],
      "expected": "The app-group tag appears on the host. Only app-group tags are shown in the picker dropdown.",
      "flow": "setup",
      "sequence": 9,
      "status": null,
      "feedback": null
    },
    {
      "id": "step2-expandable-services",
      "category": "Step 2 - Assign Hosts",
      "description": "Host rows expand to show services for override tagging",
      "steps": [
        "Find a host that has services",
        "Observe if services are shown below the host"
      ],
      "setup": "Ensure at least one host has services discovered.",
      "expected": "Services for the host are shown in an expanded section below the host row, each with their own inline tag picker for override tagging.",
      "flow": "setup",
      "sequence": 10,
      "status": null,
      "feedback": null
    },
    {
      "id": "step2-multi-select-bulk-assign",
      "category": "Step 2 - Assign Hosts",
      "description": "Multi-select and bulk assign works",
      "steps": [
        "Select checkboxes on 3+ hosts",
        "In the bulk assign bar that appears, click an app-group tag"
      ],
      "expected": "A bottom bar appears showing '{count} selected' and app-group tag buttons. Clicking a tag assigns it to all selected hosts. Selection clears after assignment.",
      "flow": "setup",
      "sequence": 11,
      "status": null,
      "feedback": null
    },
    {
      "id": "step2-inheritance-note",
      "category": "Step 2 - Assign Hosts",
      "description": "Tag inheritance note is visible",
      "steps": [
        "On Step 2, observe the text above the host list"
      ],
      "expected": "Text reads: 'Services inherit their host's application group. Override individual services by tagging them directly.'",
      "flow": "setup",
      "sequence": 12,
      "status": null,
      "feedback": null
    },
    {
      "id": "wizard-completion",
      "category": "Wizard Completion",
      "description": "Completing wizard creates container rule and renders topology",
      "steps": [
        "On Step 2, click 'Complete Setup'"
      ],
      "expected": "The wizard closes. The Application perspective renders with app groups as containers and services as elements inside them.",
      "flow": "setup",
      "sequence": 13,
      "status": null,
      "feedback": null
    },
    {
      "id": "wizard-back-button",
      "category": "Navigation",
      "description": "Back button on Step 2 returns to Step 1",
      "steps": [
        "On Step 2, click 'Back'"
      ],
      "expected": "Returns to Step 1 with previously created groups still visible.",
      "flow": "setup",
      "sequence": 14,
      "status": null,
      "feedback": null
    },
    {
      "id": "wizard-reappears-on-delete",
      "category": "Wizard Gate",
      "description": "Wizard reappears if all app-group tags are deleted",
      "steps": [
        "After completing the wizard, navigate to Tags tab",
        "Delete all app-group tags",
        "Navigate back to topology and select Application perspective"
      ],
      "expected": "The wizard reappears, requiring setup again.",
      "status": null,
      "feedback": null
    },
    {
      "id": "perspective-switch-no-wizard",
      "category": "Wizard Gate",
      "description": "L3 perspective works normally without wizard",
      "steps": [
        "Select L3 Logical perspective"
      ],
      "expected": "Topology renders normally without any wizard appearing.",
      "flow": "setup",
      "sequence": 15,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/topo-fixes-and-polish",
  "tests": [
    {
      "id": "disabled-edge-not-in-toggles",
      "category": "Edge Classification",
      "description": "ServiceVirtualization edges should not appear in edge type toggles or render on canvas when viewing L3 perspective",
      "steps": [
        "Open a topology in L3 perspective",
        "Open the Options panel and check edge type toggles",
        "Look at the topology canvas for ServiceVirtualization edges"
      ],
      "setup": "Ensure topology has at least one Docker container service (produces ServiceVirtualization edges)",
      "expected": "ServiceVirtualization should NOT appear in the toggle list AND should NOT render on the canvas at all.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "dependency-edges-visible-l3",
      "category": "Edge Classification",
      "description": "RequestPath and HubAndSpoke edges should be visible by default in L3",
      "steps": [
        "Open a topology in L3 perspective (fresh options or after reset)",
        "Look at the edge type toggles in Options panel"
      ],
      "setup": "Ensure topology has dependency edges (RequestPath or HubAndSpoke). Reset topology options to defaults.",
      "expected": "RequestPath and HubAndSpoke should be enabled (not in hidden list) by default. Dependency edges should be visible on the canvas.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "collapsed-root-width",
      "category": "Collapse State",
      "description": "Collapsed root containers have reasonable width; subcontainers resize properly on membership change",
      "steps": [
        "Collapse a root container — check width is compact",
        "Change service category or tag membership for a node",
        "Trigger a rebuild",
        "Verify subcontainer resized appropriately with correct node layout"
      ],
      "setup": "Ensure topology has both root subnet containers and nested subcontainers with element rules",
      "expected": "Root containers collapse to compact width. After membership change + rebuild, subcontainers resize correctly and nodes don't stack.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "unambiguous-element-counts",
      "category": "Container Labels",
      "description": "Collapsed element counts show total, ungrouped, and subgroup breakdown",
      "steps": [
        "Open a topology with subnet containers that have nested subcontainers",
        "Collapse a root container that has subcontainers"
      ],
      "expected": "Total count underlined at top (e.g. '26 host interfaces'). 'Ungrouped: 23 host interfaces' row below. Subgroup lines show just '(3 host interfaces)'.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "perspective-aware-count-label",
      "category": "Container Labels",
      "description": "Count label matches perspective",
      "steps": [
        "Open a topology in L3 perspective, collapse a container",
        "Note the count label",
        "Switch to Application perspective, collapse a container",
        "Note the count label"
      ],
      "expected": "In L3: count says 'N host interfaces'. In Application: count says 'N services'.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "no-layout-flicker",
      "category": "Layout",
      "description": "No layout flicker on topology rebuild",
      "steps": [
        "Open a topology",
        "Trigger a rebuild (Cmd+R or rebuild button)",
        "Watch carefully for any flash of unpositioned nodes"
      ],
      "expected": "Topology should transition smoothly from hidden to visible. No flash of nodes at origin (0,0) or unpositioned layout.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "perspective-switching-rebuild",
      "category": "Layout",
      "description": "Switching perspectives triggers a reliable rebuild",
      "steps": [
        "Clear localStorage and reload",
        "Open a topology in L3 perspective",
        "Switch to Application perspective",
        "Switch back to L3"
      ],
      "setup": "Clear localStorage to remove stale snake_case options",
      "expected": "Each perspective switch should trigger a rebuild automatically without needing to hit rebuild manually.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "edge-handles-correct",
      "category": "Layout",
      "description": "Edge handles computed correctly based on node positions",
      "steps": [
        "Open a topology with multiple subnets at different vertical layers",
        "Observe edge connection points on nodes"
      ],
      "expected": "Edges connect at sensible handle positions based on relative node positions.",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/topo-app-group-backend",
  "tests": [
    {
      "id": "app-group-tag-creation",
      "category": "Tag Management",
      "description": "Create a tag with is_application_group=true and verify it appears with AppWindow icon and sheen animation",
      "steps": [
        "Navigate to Tags tab in asset management",
        "Create a new tag, enable the 'Application Group' toggle",
        "Verify the tag displays with the AppWindow icon and a subtle sheen animation"
      ],
      "expected": "Tag shows with AppWindow icon and diagonal gradient sheen animation on mount",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-group-tag-one-per-host",
      "category": "Tag Validation",
      "description": "Verify only one application group tag can be assigned to a host",
      "steps": [
        "Navigate to a host card",
        "Add the first app-group tag — should succeed",
        "Try to add a second app-group tag to the same host"
      ],
      "setup": "Create two tags with is_application_group=true via API (e.g., 'ERP' and 'CRM'). Ensure at least one host exists.",
      "expected": "Second app-group tag assignment returns 400 error with message about only one application group tag allowed and inheritance model",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-group-tag-one-per-service",
      "category": "Tag Validation",
      "description": "Verify only one application group tag can be assigned to a service",
      "steps": [
        "Navigate to a service in a host edit modal",
        "Add the first app-group tag — should succeed",
        "Try to add a second app-group tag to the same service"
      ],
      "setup": "Create two tags with is_application_group=true. Ensure at least one host with a service exists.",
      "expected": "Second app-group tag assignment returns 400 error",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-group-tag-sheen-visual",
      "category": "Visual",
      "description": "Verify sheen animation on application group tags",
      "steps": [
        "View a host card that has an app-group tag assigned",
        "Observe the tag pill — should show sheen animation on page load",
        "Hover over the tag — should show a subtle hover sheen"
      ],
      "setup": "Assign an app-group tag to a host via API.",
      "expected": "Diagonal gradient sweep animation plays once on mount; subtler animation on hover",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-group-topology-grouping",
      "category": "Topology Application Perspective",
      "description": "Verify services are grouped by application group tags in Application perspective",
      "steps": [
        "Open a topology in Application perspective",
        "Verify services with app-group tags are grouped into containers named after the tags",
        "Verify services without app-group tags (and whose hosts also lack them) appear in 'Ungrouped' container"
      ],
      "setup": "Create app-group tags 'ERP' and 'CRM'. Assign 'ERP' tag to host A and 'CRM' tag to host B. Ensure hosts have services with bindings. Leave at least one service/host untagged. Rebuild topology.",
      "expected": "Services on host A appear in 'ERP' container, services on host B appear in 'CRM' container, untagged services appear in 'Ungrouped' container",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-group-host-inheritance",
      "category": "Topology Application Perspective",
      "description": "Verify services inherit app-group tag from their host",
      "steps": [
        "Open topology in Application perspective",
        "Verify that a service on a host with an app-group tag is grouped under that tag's container",
        "Assign a different app-group tag directly to that service",
        "Rebuild topology and verify the service now uses its own tag, not the host's"
      ],
      "setup": "Create two app-group tags 'ERP' and 'CRM'. Assign 'ERP' to a host. The host should have services with bindings.",
      "expected": "Services inherit host's app-group initially; direct service tag overrides inheritance after rebuild",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "generic-service-filter-default",
      "category": "Topology Filters",
      "description": "Verify generic services are hidden by default in Application perspective and the filter works",
      "steps": [
        "Open topology in Application perspective",
        "Open the Filters panel — verify 'Generic Services' section shows with 'Show' label",
        "Verify generic services (e.g., Open Ports, SSH) are NOT visible in the topology",
        "Click 'Show' to toggle generic services on",
        "Verify generic services now appear in the topology and label changes to 'Hide'"
      ],
      "setup": "Ensure the network has hosts with both branded services (e.g., PostgreSQL, Nginx) and generic services (e.g., Open Ports, SSH).",
      "expected": "Generic services hidden by default in Application perspective; clicking Show reveals them; label toggles between Show/Hide",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "generic-filter-all-perspectives",
      "category": "Topology Filters",
      "description": "Verify 'Generic Services' filter appears in all perspectives with correct default state",
      "steps": [
        "Open topology in L3 Logical perspective",
        "Open Filters panel — verify 'Generic Services' section is visible with 'Hide' label (not hidden by default)",
        "Switch to Application perspective — verify 'Generic Services' shows 'Show' label (hidden by default)",
        "Switch to Infrastructure perspective — verify 'Generic Services' section is visible"
      ],
      "expected": "Generic Services filter visible in all perspectives. Default hidden only in Application perspective.",
      "status": null,
      "feedback": null
    },
    {
      "id": "tag-edit-modal-app-group-checkbox",
      "category": "Tag Management",
      "description": "Verify tag create/edit modal has Application Group checkbox",
      "steps": [
        "Open tag create modal",
        "Verify 'Application Group' checkbox is present with help text explaining what it does",
        "Check the checkbox and create the tag",
        "Edit the tag — verify checkbox reflects the saved state"
      ],
      "expected": "Checkbox present with description, persists correctly on create and edit",
      "status": null,
      "feedback": null
    },
    {
      "id": "staleness-on-app-group-change",
      "category": "Topology Staleness",
      "description": "Verify topology becomes stale when a tag's is_application_group changes",
      "steps": [
        "Open a topology that has services",
        "Edit a tag and toggle its is_application_group status",
        "Verify the topology shows as stale"
      ],
      "setup": "Create a tag and assign it to a host. Open the topology so it's built.",
      "expected": "Changing is_application_group triggers topology staleness indicator",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/topo-inspector-refactor",
  "tests": [
    {
      "id": "application-element-inspector-sections",
      "category": "Inspector Sections",
      "description": "Application perspective element inspector shows correct sections",
      "steps": [
        "Switch to Application perspective",
        "Click on a service element node",
        "Verify inspector panel shows sections: Identity (service), Dependencies (inbound+outbound), Port Bindings, Tags"
      ],
      "setup": "Ensure the topology has services with dependencies (both inbound and outbound) and port bindings.",
      "expected": "Inspector shows Identity with service name/category/host, Dependencies section with inbound/outbound lists, Port Bindings with port numbers, and Tags.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-container-inspector-sections",
      "category": "Inspector Sections",
      "description": "L3 perspective container inspector shows subnet detail and element summary",
      "steps": [
        "In L3 Logical perspective, click on a subnet container node",
        "Verify inspector shows: Subnet Detail (CIDR, gateway), Element Summary (element count)"
      ],
      "expected": "Subnet detail shows with tag picker and editable description. Element summary shows count of interfaces in the container.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "application-container-inspector-sections",
      "category": "Inspector Sections",
      "description": "Application perspective container inspector shows identity and dependency summary",
      "steps": [
        "In Application perspective, click on an app group or category container",
        "Verify inspector shows: Identity (group name), Dependency Summary (cross-boundary deps)"
      ],
      "expected": "Container identity shows the group name. Dependency summary lists dependencies that cross the container boundary.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "multiselect-422-fix",
      "category": "Bug Fix",
      "description": "Multi-select dependency creation no longer returns 422",
      "steps": [
        "In L3 perspective, multi-select 3+ interface nodes",
        "Enter a group name in the dependency creation section",
        "Select bindings for each interface",
        "Click Create Dependency"
      ],
      "setup": "Ensure the topology has at least 3 hosts with services that have bindings on their interfaces.",
      "expected": "Dependency is created successfully without a 422 error. The topology rebuilds with the new dependency edge.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "multiselect-bulk-tag-entity-perspective",
      "category": "Multi-Select",
      "description": "Bulk tag entity type changes with perspective",
      "steps": [
        "In L3 perspective, multi-select nodes and check the tag entity toggle",
        "Switch to Application perspective and multi-select nodes",
        "Check the tag entity toggle default"
      ],
      "expected": "In L3, the tag entity toggle defaults to 'Host'. In Application, it defaults to 'Service'.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "multiselect-app-group-picker",
      "category": "Multi-Select",
      "description": "App-group picker appears in Application perspective multi-select",
      "steps": [
        "In Application perspective, multi-select service nodes",
        "Verify the 'Application Group' tag picker section appears",
        "Switch to L3 perspective and multi-select",
        "Verify the app-group picker is NOT shown"
      ],
      "expected": "App-group picker section visible only in Application perspective.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "multiselect-create-grouping-rule",
      "category": "Multi-Select",
      "description": "Create grouping rule from tag action appears after bulk tagging",
      "steps": [
        "Multi-select nodes in L3 perspective",
        "Add a tag via the tag picker",
        "Verify a 'Create grouping rule from this tag' button appears",
        "Click the button"
      ],
      "expected": "After adding a non-app-group tag, the create grouping rule button appears. Clicking it adds a ByTag element rule to the topology options.",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    },
    {
      "id": "dependency-edit-modal-works",
      "category": "DependencyMemberSelector",
      "description": "DependencyEditModal still works after DependencyMemberSelector extraction",
      "steps": [
        "Open the dependency edit modal (create new dependency)",
        "Fill in details, go to services tab",
        "Add 2+ services, toggle to With Ports mode, select bindings",
        "Create the dependency"
      ],
      "setup": "Ensure services exist with port bindings on the network.",
      "expected": "The services tab works identically to before: mode toggle, service search, binding selection, reordering all function correctly.",
      "status": null,
      "feedback": null
    },
    {
      "id": "multiselect-no-dependency-infra-l2",
      "category": "Multi-Select",
      "description": "Dependency creation hidden in Infrastructure and L2 perspectives",
      "steps": [
        "Switch to Infrastructure perspective (if available) and multi-select",
        "Verify the dependency creation section is NOT shown",
        "Repeat for L2 Physical perspective"
      ],
      "expected": "Dependency creation section is hidden in perspectives where dependency_creation is null.",
      "status": null,
      "feedback": null
    }
  ]
}
];
