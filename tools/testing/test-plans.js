var TEST_PLANS = [
{
  "branch": "fix/grouping-rule-rich-select",
  "tests": [
    {
      "id": "rich-select-container-rule-descriptions",
      "category": "Grouping Rules",
      "description": "Container rule add dropdown shows name and description",
      "steps": [
        "Open a topology in a perspective that has container rules (e.g., L3 Logical)",
        "Open the grouping panel",
        "Click the 'Add container rule' dropdown"
      ],
      "expected": "Each option in the dropdown shows the rule name in primary text and the rule description in smaller secondary text below it",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "rich-select-element-rule-descriptions",
      "category": "Grouping Rules",
      "description": "Element rule add dropdown shows name and description",
      "steps": [
        "Open a topology in a perspective that has element rules (e.g., L3 Logical or Application)",
        "Open the grouping panel",
        "Click the 'Add element rule' dropdown"
      ],
      "expected": "Each option in the dropdown shows the rule name in primary text and the rule description in smaller secondary text below it",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "container-rule-card-description",
      "category": "Grouping Rules",
      "description": "Container rule cards show description text",
      "steps": [
        "Open a topology with container rules already applied (e.g., L3 Logical with Subnet rule)",
        "Look at the container rules list in the grouping panel"
      ],
      "expected": "Each container rule card shows the rule name on the first line and a smaller muted description on the second line",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "element-rule-card-description",
      "category": "Grouping Rules",
      "description": "Element rule cards show description text",
      "steps": [
        "Open a topology and add an element rule (e.g., 'Service category' or 'Tag')",
        "Look at the element rules list in the grouping panel"
      ],
      "expected": "Each element rule card shows the rule name on the first line and a smaller muted description on the second line",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "add-rule-from-rich-select",
      "category": "Grouping Rules",
      "description": "Adding a rule via RichSelect dropdown works correctly",
      "steps": [
        "Open a topology grouping panel",
        "Click the element rule add dropdown",
        "Select a rule (e.g., 'Service category')",
        "Verify the rule is added to the list with its description"
      ],
      "expected": "The selected rule is added to the element rules list, showing both name and description. The rule editor opens if applicable.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/ui-polish-categories-tooltips",
  "tests": [
    {
      "id": "perspective-selector-tooltips",
      "category": "Perspective Tooltips",
      "description": "Perspective selector icons show description tooltips on hover",
      "steps": [
        "Open a topology view",
        "Hover over each perspective icon in the segmented control (L2, L3, Infrastructure, Application)"
      ],
      "expected": "Each icon shows a styled tooltip (dark background, positioned above) with the perspective description, e.g. 'Physical layer 2 network topology'. Should NOT show a native browser title tooltip.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "category-filter-display-names",
      "category": "Service Category Names",
      "description": "Service category filter pills show human-readable names",
      "steps": [
        "Open a topology view with services",
        "Open the Options panel",
        "Look at the service category filter section"
      ],
      "setup": "Ensure the topology has services in multiple categories (e.g., DNS, Reverse Proxy, Remote Access).",
      "expected": "Category filter pills show human-readable names like 'Network Core', 'Remote Access', 'Reverse Proxy' instead of 'NetworkCore', 'RemoteAccess', 'ReverseProxy'.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "category-filter-tooltips",
      "category": "Service Category Names",
      "description": "Service category filter pills show description tooltips on hover",
      "steps": [
        "Open a topology view with services",
        "Open the Options panel",
        "Hover over a service category filter pill"
      ],
      "setup": "Ensure the topology has services in multiple categories.",
      "expected": "Hovering shows a styled tooltip with the category description, e.g. 'DNS servers and resolvers' for the DNS category.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "grouping-rule-category-names",
      "category": "Service Category Names",
      "description": "ByServiceCategory grouping rule shows human-readable category names",
      "steps": [
        "Open a topology view",
        "Open the Options panel",
        "Add a ByServiceCategory element grouping rule",
        "Look at the category pills in the rule editor"
      ],
      "expected": "Category pills show human-readable names like 'Network Core' instead of 'NetworkCore'.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "service-config-panel-category-tag",
      "category": "Service Config Panel",
      "description": "Service Config Panel shows colored category tag in header",
      "steps": [
        "Open a host edit modal",
        "Switch to the Services tab",
        "Click a service in the list"
      ],
      "setup": "Ensure a host exists with at least one service.",
      "expected": "The config panel header shows the service name on the left and a colored category tag (e.g., 'DNS' in the DNS color) on the upper right. Hovering the tag shows a description tooltip.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "service-panel-selection-updates",
      "category": "Service Config Panel",
      "description": "Clicking different services updates the config panel",
      "steps": [
        "Open a host edit modal",
        "Switch to the Services tab",
        "Click the first service in the list",
        "Click a different service in the list",
        "Click back to the first service"
      ],
      "setup": "Ensure a host exists with at least 3 services.",
      "expected": "Each click shows the correct service's details in the config panel. The panel updates immediately — it does not stay stuck on the first service.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "entity-ref-popover-category",
      "category": "EntityRef Popover",
      "description": "Service EntityRef popover shows category tag",
      "steps": [
        "Find a service reference in the UI (e.g., in the topology inspector or a service list)",
        "Hover over the service EntityRef tag to open the popover"
      ],
      "setup": "Ensure services exist in the topology.",
      "expected": "The popover shows the service with a category tag (e.g., 'DNS' colored pill) next to the service name. Hovering the category tag shows its description.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "hidden-category-names-after-toggle",
      "category": "Service Category Names",
      "description": "Hidden categories still show human-readable names when re-shown",
      "steps": [
        "Open a topology view",
        "Open Options panel",
        "Hide a service category by clicking its pill",
        "Observe the pill is faded but still shows the readable name"
      ],
      "setup": "Ensure the topology has services in multiple categories.",
      "expected": "Hidden (faded) category pills still show human-readable names like 'Remote Access', not raw IDs.",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/elk-container-aspect-ratio",
  "tests": []
}
,
{
  "branch": "fix/app-perspective-generic-filter",
  "tests": [
    {
      "id": "app-hides-infra-services",
      "category": "Application Perspective Filtering",
      "description": "Application perspective hides infrastructure-noise services by default",
      "steps": [
        "Navigate to Topology page",
        "Switch to Application perspective",
        "Observe which services are visible in the topology"
      ],
      "setup": "Ensure the network has hosts with SSH, DHCP, NTP, Gateway, and WiFi AP services discovered.",
      "expected": "SSH, DHCP, NTP, Gateway, Switch, SNMP, WiFi APs, printers, workstations, and mobile devices should NOT be visible. Infrastructure services are hidden by default.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-shows-app-services",
      "category": "Application Perspective Filtering",
      "description": "Application-relevant services (databases, Docker, message brokers) remain visible",
      "steps": [
        "In Application perspective, observe which services are visible"
      ],
      "setup": "Ensure the network has hosts with MySQL/PostgreSQL, Docker containers, Redis, Kafka/RabbitMQ services discovered.",
      "expected": "Database services (MySQL, PostgreSQL, Redis), Docker containers, message queues (Kafka, RabbitMQ), monitoring tools (Grafana, Prometheus), media servers (Plex), and other application services should be visible.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-msp-shows-appliances",
      "category": "Application Perspective Filtering",
      "description": "MSP use case shows network appliances in Application perspective",
      "steps": [
        "Switch to Application perspective",
        "Observe whether pfSense/OPNsense/FortiGate/MikroTik are visible"
      ],
      "setup": "Set the organization's use_case to 'msp' in the database. Ensure the network has hosts with pfSense, OPNsense, or MikroTik services.",
      "expected": "Network appliances (pfSense, OPNsense, FortiGate, MikroTik, Firewall) should be visible in the Application perspective for MSP organizations.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "category-override-via-options",
      "category": "Category Filter Override",
      "description": "Users can override default hidden categories via the options panel",
      "steps": [
        "Switch to Application perspective",
        "Open the topology options panel",
        "In the Services section, find the category filter",
        "Toggle a hidden category (e.g., NetworkCore) to make it visible",
        "Observe the topology updates to show previously hidden services"
      ],
      "setup": "Ensure the network has hosts with services in NetworkCore category (DHCP, NTP).",
      "expected": "After toggling NetworkCore to visible, DHCP and NTP services should appear in the topology. The category filter checkboxes should reflect the current state.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "other-perspectives-unaffected",
      "category": "Perspective Isolation",
      "description": "L3, Infrastructure, and L2 perspectives are not affected by category filtering",
      "steps": [
        "Switch to L3 Logical perspective and observe services",
        "Switch to Infrastructure perspective and observe services",
        "Switch to L2 Physical perspective and observe"
      ],
      "expected": "All three non-Application perspectives should show the same services as before (no category-based hiding). Only OpenPorts should be hidden by default.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "generic-filter-removed",
      "category": "UI Cleanup",
      "description": "The old 'Show generic services' toggle is removed from the options panel",
      "steps": [
        "Open topology options panel in Application perspective",
        "Look for a 'Show generic services' checkbox in the Services filter section"
      ],
      "expected": "The 'Show generic services' checkbox should NOT be present. Only the category filter toggles should be available.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "category-restructure-visible",
      "category": "Category Restructuring",
      "description": "New categories (NetworkAppliance, RemoteAccess) appear correctly in the UI",
      "steps": [
        "Open topology options panel",
        "Look at the category filter list"
      ],
      "setup": "Ensure the network has hosts with SSH, pfSense, and MikroTik services.",
      "expected": "The category filter should show 'NetworkAppliance' (containing pfSense, MikroTik, etc.) and 'RemoteAccess' (containing SSH, Telnet, RDP) instead of the old 'NetworkSecurity' and 'SNMP' categories.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/topo-by-stack-rule-v2",
  "tests": []
}
,
{
  "branch": "fix/perspective-switch-flicker-v2",
  "tests": []
}
,
{
  "branch": "feat/topo-infrastructure-perspective",
  "tests": [
    {
      "id": "infra-perspective-shows-hosts",
      "category": "Infrastructure Perspective",
      "description": "Switching to Infrastructure perspective shows all hosts as elements",
      "steps": [
        "Open a topology that has hosts",
        "Switch to Infrastructure perspective using the perspective selector"
      ],
      "setup": "Ensure the topology has at least 3 hosts with different names on the default network.",
      "expected": "All hosts appear as element nodes in the topology. Each node shows the host name as its header.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "infra-by-virtualizer-groups-vms",
      "category": "Infrastructure Perspective",
      "description": "ByVirtualizer element rule groups VMs under their hypervisor subcontainer",
      "steps": [
        "Open a topology with Proxmox VMs",
        "Switch to Infrastructure perspective"
      ],
      "setup": "Create a host 'pve-01' with a Proxmox VE service. Create 2 additional hosts with HostVirtualization::Proxmox pointing to the Proxmox service. This simulates VMs managed by the hypervisor.",
      "expected": "A 'pve-01' Virtualizer subcontainer appears containing the 2 VM host elements. The hypervisor host itself appears outside the Virtualizer container (in BareMetal).",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "infra-bare-metal-container",
      "category": "Infrastructure Perspective",
      "description": "Bare metal hosts appear in a BareMetal subcontainer",
      "steps": [
        "View the Infrastructure perspective with mixed hosts"
      ],
      "setup": "Create hosts with no virtualization relationship (no Proxmox VM, not a hypervisor).",
      "expected": "Hosts without any virtualization relationship are grouped in a BareMetal subcontainer.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "infra-no-virtualization-edges",
      "category": "Infrastructure Perspective",
      "description": "No edges drawn for virtualization — subcontainer nesting IS the relationship",
      "steps": [
        "In Infrastructure perspective, inspect the edge list"
      ],
      "expected": "No HostVirtualization or ServiceVirtualization edges are visible. Virtualization relationships are expressed through container nesting only.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "infra-inspector-element-sections",
      "category": "Infrastructure Perspective",
      "description": "Inspector shows correct sections for host elements",
      "steps": [
        "In Infrastructure perspective, click on a host element node",
        "Inspect the inspector panel sections"
      ],
      "expected": "Inspector shows sections in order: Identity, HostDetail, Services, OtherInterfaces, Tags.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "infra-inspector-container-sections",
      "category": "Infrastructure Perspective",
      "description": "Inspector shows container summary for virtualizer subcontainers",
      "steps": [
        "In Infrastructure perspective, click on a Virtualizer subcontainer"
      ],
      "expected": "Inspector shows Identity and ElementSummary sections for the container.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "infra-bulk-tagging-targets-hosts",
      "category": "Infrastructure Perspective",
      "description": "Bulk tagging targets hosts",
      "steps": [
        "In Infrastructure perspective, select multiple host elements",
        "Open the bulk tag action"
      ],
      "expected": "Bulk tagging targets Host entities (not services or interfaces).",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "infra-no-dependency-creation",
      "category": "Infrastructure Perspective",
      "description": "No dependency creation available",
      "steps": [
        "In Infrastructure perspective, check for dependency creation UI"
      ],
      "expected": "No dependency creation button or wizard is available. The perspective config has dependency_creation = None.",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/grouping-rules-state",
  "tests": [
    {
      "id": "remove-bystack-removes-subcontainer",
      "category": "Element Rule Removal",
      "description": "Removing ByStack element rule removes its subcontainer after rebuild",
      "steps": [
        "Switch to Infrastructure perspective",
        "In the element grouping section, verify ByStack (Docker Stack) is listed",
        "Click the remove button on ByStack",
        "Observe the topology rebuilds"
      ],
      "expected": "The Docker Stack subcontainer disappears from the topology after rebuild. ByStack is no longer listed in the element rules.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "remove-bystack-persists-after-reload",
      "category": "Element Rule Removal",
      "description": "Removed ByStack stays removed after page reload",
      "steps": [
        "After removing ByStack in the previous test, reload the page",
        "Switch to Infrastructure perspective",
        "Check the element grouping rules list"
      ],
      "expected": "ByStack is still not listed. The removal was persisted to the backend.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "tag-rules-persist-across-switches",
      "category": "Tag Rule Persistence",
      "description": "ByTag element rules with configured tags persist across perspective switches",
      "steps": [
        "On L3 perspective, edit the ByTag element rule",
        "Select 2-3 tags, set a custom title",
        "Click the checkmark to close the editor",
        "Switch to Infrastructure perspective",
        "Switch back to L3 perspective",
        "Verify the ByTag rule still has the same tags and title"
      ],
      "setup": "Ensure at least 3 tags exist in the system.",
      "expected": "The ByTag rule retains its configured tags and title after switching perspectives and back.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "tag-rules-persist-after-reload",
      "category": "Tag Rule Persistence",
      "description": "ByTag rules with configured tags persist after page reload",
      "steps": [
        "After configuring the ByTag rule in the previous test, reload the page",
        "Navigate to the topology and check the ByTag element rule"
      ],
      "expected": "The ByTag rule still has the same tags and title. Rules are loaded from the backend.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "perspective-switch-correct-container-rules",
      "category": "Perspective Switching",
      "description": "Switching perspectives shows correct container rules for each perspective",
      "steps": [
        "Start on L3 perspective, note the container rules (should include Subnet and Docker bridges)",
        "Switch to Infrastructure perspective, note the container rules",
        "Switch to Application perspective, note the container rules",
        "Switch back to L3 perspective"
      ],
      "expected": "L3: Subnet (locked) + Docker bridges. Infrastructure: Docker bridges only. Application: Application Group (locked) only. Each perspective shows only its applicable container rules.",
      "status": null,
      "feedback": null
    },
    {
      "id": "remove-container-rule-per-perspective",
      "category": "Container Rule Management",
      "description": "Removing Docker bridges on Infrastructure doesn't affect L3",
      "steps": [
        "Switch to Infrastructure perspective",
        "Remove Docker bridges container rule",
        "Switch to L3 perspective",
        "Verify Docker bridges is still present on L3"
      ],
      "expected": "Docker bridges removed from Infrastructure only. L3 still shows Docker bridges. Container rules are per-perspective.",
      "status": null,
      "feedback": null
    },
    {
      "id": "element-rules-filtered-by-perspective",
      "category": "Perspective Filtering",
      "description": "Element rules not applicable to current perspective don't appear",
      "steps": [
        "Switch to L3 perspective — note element rules shown",
        "Switch to Infrastructure perspective — note element rules shown",
        "Verify ByServiceCategory is NOT shown on Infrastructure",
        "Verify ByVirtualizer is NOT shown on L3"
      ],
      "expected": "Each perspective only shows element rules applicable to it.",
      "status": null,
      "feedback": null
    },
    {
      "id": "remove-rule-while-editing-another",
      "category": "Edge Cases",
      "description": "Removing a rule while editing another rule doesn't corrupt state",
      "steps": [
        "On L3 perspective, ensure ByServiceCategory and ByTag rules exist",
        "Click edit on ByTag to open its editor",
        "While the ByTag editor is open, remove ByServiceCategory",
        "Click the checkmark on ByTag to close its editor",
        "Verify the topology rebuilds correctly"
      ],
      "expected": "ByServiceCategory is removed. ByTag retains any edits made. No state corruption.",
      "status": null,
      "feedback": null
    },
    {
      "id": "new-topology-has-backend-defaults",
      "category": "New Topology",
      "description": "A newly created topology has correct per-perspective default rules from the backend",
      "steps": [
        "Create a new topology",
        "Check container rules on L3 (Subnet + Docker bridges expected)",
        "Switch to Infrastructure, check container rules (Docker bridges expected)",
        "Switch to Application, check container rules (Application Group expected)",
        "Check element rules on L3 (ByServiceCategory + ByTag expected)"
      ],
      "expected": "Each perspective has the correct default rules, all provided by the backend. No frontend-computed defaults.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/app-wizard-suggestions-v2",
  "tests": []
}
,
{
  "branch": "fix/fieldless-rule-edit-state",
  "tests": []
}
,
{
  "branch": "refactor/backend-rules-sot",
  "tests": [
    {
      "id": "load-topology-rules-from-backend",
      "category": "Topology Rules",
      "description": "Loading a topology shows container rules and element rules from backend, not frontend defaults",
      "steps": [
        "Navigate to topology view",
        "Open the options panel",
        "Verify container rules section shows rules (e.g. BySubnet, ByVirtualizingService for L3)",
        "Verify element rules section shows all 4 rule types"
      ],
      "expected": "Rules displayed match what the backend stored, not hardcoded frontend defaults",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "switch-perspective-container-rules",
      "category": "Topology Rules",
      "description": "Switching perspectives shows different container rules per perspective",
      "steps": [
        "Open options panel on L3 perspective",
        "Note container rules (should include BySubnet, ByVirtualizingService)",
        "Switch to Infrastructure perspective",
        "Check container rules (should show ByVirtualizingService only)",
        "Switch to Application perspective",
        "Check container rules (should show ByApplicationGroup)"
      ],
      "expected": "Each perspective shows its own container rules. Switching back preserves previous perspective's rules.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "element-rules-shared-across-perspectives",
      "category": "Topology Rules",
      "description": "Element rules are shared across perspectives",
      "steps": [
        "In L3 perspective, add a ByTag element rule with some tags",
        "Switch to Infrastructure perspective",
        "Open element rules section",
        "Verify the ByTag rule with same tags is visible"
      ],
      "expected": "Element rules persist across perspective switches — they are shared, not per-perspective",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "add-remove-container-rule",
      "category": "Topology Rules",
      "description": "Adding and removing container rules works correctly",
      "steps": [
        "In L3 perspective, open options panel",
        "Remove ByVirtualizingService container rule",
        "Verify topology rebuilds without virtualizing service grouping",
        "Add ByVirtualizingService back",
        "Verify topology rebuilds with grouping restored"
      ],
      "expected": "Container rule changes trigger rebuild and affect topology visualization",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "hide-service-categories-per-perspective",
      "category": "Topology Rules",
      "description": "Hidden service categories are per-perspective",
      "steps": [
        "In Application perspective, open category filter",
        "Hide a service category (e.g. DNS)",
        "Switch to L3 perspective",
        "Open category filter",
        "Verify DNS is NOT hidden in L3 (only in Application)"
      ],
      "expected": "Hidden categories are stored per-perspective — hiding in Application doesn't affect L3",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "sse-update-preserves-perspective",
      "category": "Topology Rules",
      "description": "SSE topology updates don't reset the user's perspective",
      "steps": [
        "Select a topology in L3 perspective",
        "Switch to Infrastructure perspective",
        "Wait for an SSE update (or trigger a network scan that marks topology stale)",
        "Verify perspective remains on Infrastructure"
      ],
      "setup": "Have a daemon running that will trigger topology staleness updates via SSE",
      "expected": "SSE updates do not reset the user's active perspective",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "create-new-topology-default-rules",
      "category": "Topology Rules",
      "description": "Creating a new topology gets correct default rules from backend",
      "steps": [
        "Click create new topology",
        "Fill in name and submit",
        "Open options panel on the new topology",
        "Verify container rules match defaults for L3 (BySubnet, ByVirtualizingService)",
        "Verify element rules include all 4 types",
        "Switch perspectives and verify each has correct default container rules"
      ],
      "expected": "New topology has backend-defined default rules for all perspectives",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "reset-topology-options",
      "category": "Topology Rules",
      "description": "Resetting topology options restores defaults",
      "steps": [
        "Modify some rules (add/remove container rules, edit element rules)",
        "Reset topology options (via the reset action)",
        "Verify all rules return to defaults"
      ],
      "expected": "Reset restores default container rules per perspective, default element rules, and default hidden categories",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/docker-compose-project",
  "tests": []
}
];
