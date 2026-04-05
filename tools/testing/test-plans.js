var TEST_PLANS = [
{
  "branch": "fix/topo-crosscutting-fixes",
  "tests": [
    {
      "id": "app-group-inherited-indicator",
      "category": "App Group Bulk Tagger",
      "description": "Inherited app-group tag shows static badge with 'Inherited from host' label (single and multi-select)",
      "steps": [
        "Open topology in Application perspective",
        "Click a single service that inherits its app-group from its host",
        "Check the Application Group section — should show static badge with 'Inherited from host'",
        "Multi-select services that inherit their app-group from their host",
        "Check the Application Group section — should show same badge + message"
      ],
      "setup": "Tag a host with an app-group tag (not the individual services). Ensure the services on that host appear in the Application perspective under that group.",
      "expected": "Both single and multi-select show the inherited tag as a static badge (not in the picker). 'Inherited from host' text shown. Tagging directly will override hint shown. No picker shown when inherited (can't remove inherited tag from service).",
      "status": null,
      "feedback": null
    },
    {
      "id": "app-group-override-indicator",
      "category": "App Group Bulk Tagger",
      "description": "Direct app-group tag on service shows override message when host has different tag",
      "steps": [
        "Open topology in Application perspective",
        "Click a service that has a direct app-group tag different from its host's app-group tag",
        "Check the Application Group section"
      ],
      "setup": "Tag a host with one app-group tag, then directly tag a service on that host with a different app-group tag.",
      "expected": "Shows the service's direct tag in the picker (removable). Shows 'Overrides {host tag} from host' message. No 'Unknown' in the regular tags section.",
      "status": null,
      "feedback": null
    },
    {
      "id": "multiselect-create-grouping-rule",
      "category": "Multi-Select",
      "description": "'Create grouping rule from tag' button shows tag badges, hides when rule exists, rebuilds topology",
      "steps": [
        "Open topology, multi-select nodes",
        "Add a non-app-group tag via the Tags section tag picker",
        "Observe the button that appears below the tag picker",
        "Click the button to create a grouping rule",
        "Verify topology rebuilds automatically"
      ],
      "expected": "Button shows with tag badge inline. Clicking creates a ByTag element rule and triggers topology rebuild. After creation, adding same tag again does NOT show the button.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/topo-perspective-audit",
  "tests": [
    {
      "id": "container-fading-application",
      "category": "Bug 1: Container Selection Fading",
      "description": "Selecting an ApplicationGroup container should fade other containers but un-fade its child service elements",
      "steps": [
        "Switch to Application perspective",
        "Click on an ApplicationGroup container node",
        "Observe fading behavior"
      ],
      "setup": "Ensure at least 2 application groups exist with services assigned to each. Create via the Application Setup Wizard if needed.",
      "expected": "The selected ApplicationGroup stays fully visible. Service element nodes inside it stay fully visible. Other ApplicationGroup containers and their contents fade out.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "container-fading-l3",
      "category": "Bug 1: Container Selection Fading",
      "description": "L3 container selection fading still works correctly after refactor",
      "steps": [
        "Switch to L3 Logical perspective",
        "Click on a subnet container node",
        "Observe fading behavior"
      ],
      "expected": "The selected subnet stays fully visible. Interface element nodes inside it stay fully visible. Other subnets and their contents fade out.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "container-fading-subcontainer",
      "category": "Bug 1: Container Selection Fading",
      "description": "Selecting a parent container un-fades elements in subcontainers too",
      "steps": [
        "Find a topology with nested containers (e.g., a subnet that contains a Docker bridge subnet)",
        "Click on the parent container",
        "Observe fading behavior"
      ],
      "expected": "Both the parent container and its child subcontainer stay visible. All element nodes in both the parent and child containers remain un-faded.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "tag-hiding-service-application",
      "category": "Bug 2: Tag-Based Hiding",
      "description": "Hiding a service tag in Application perspective hides the service element nodes",
      "steps": [
        "Switch to Application perspective",
        "Open the options/filter panel",
        "Toggle a service tag to hidden",
        "Observe the topology"
      ],
      "setup": "Ensure services exist with at least one tag assigned.",
      "expected": "Service element nodes with the hidden tag disappear from the topology. Other service nodes remain visible.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "tag-filter-categories-application",
      "category": "Bug 2: Tag-Based Hiding",
      "description": "Application perspective only shows service tag filters, not host or subnet",
      "steps": [
        "Switch to Application perspective",
        "Open the options/filter panel",
        "Look at the Filters section"
      ],
      "expected": "Only the Services filter group is visible. Hosts and Subnets filter groups are not shown.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "tag-filter-categories-l3",
      "category": "Bug 2: Tag-Based Hiding",
      "description": "L3 perspective shows all tag filter groups",
      "steps": [
        "Switch to L3 Logical perspective",
        "Open the options/filter panel",
        "Look at the Filters section"
      ],
      "expected": "All three filter groups are visible: Hosts, Services, and Subnets.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "perspective-selector-all-perspectives",
      "category": "Task 3: Perspective Generalization",
      "description": "Perspective selector shows all 4 perspectives from fixture data",
      "steps": [
        "Look at the perspective selector in the topology toolbar"
      ],
      "expected": "Four perspective buttons are shown: L2 Physical, L3 Logical, Infrastructure, and Application. Each has the correct icon and tooltip.",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    },
    {
      "id": "edge-defaults-per-perspective",
      "category": "Task 3: Perspective Generalization",
      "description": "Default hidden edge types change when switching perspectives",
      "steps": [
        "Switch to L3 Logical perspective and open edge toggles in options",
        "Note which edge types are hidden by default",
        "Switch to Application perspective",
        "Note which edge types are hidden by default"
      ],
      "expected": "L3: HostVirtualization and PhysicalLink hidden by default. Application: Interface, HostVirtualization, ServiceVirtualization, and PhysicalLink hidden by default. The defaults differ per perspective.",
      "flow": "setup",
      "sequence": 8,
      "status": null,
      "feedback": null
    },
    {
      "id": "element-summary-label",
      "category": "Task 4: SectionElementSummary",
      "description": "Container inspector element summary uses perspective-aware label",
      "steps": [
        "In L3 perspective, click a subnet container and open its inspector",
        "Note the label in the Element Summary section",
        "Switch to Application perspective, click an ApplicationGroup container",
        "Note the label in the Element Summary section"
      ],
      "expected": "L3: label says 'host interfaces'. Application: label says 'services'. The label comes from perspective metadata, not hardcoded.",
      "flow": "setup",
      "sequence": 9,
      "status": null,
      "feedback": null
    },
    {
      "id": "app-wizard-auto-open",
      "category": "Task 3: Perspective Generalization",
      "description": "Application wizard auto-opens based on metadata, not hardcoded check",
      "steps": [
        "Delete all application group tags (if any exist)",
        "Switch to Application perspective"
      ],
      "setup": "Remove all application group tags via the API so none exist.",
      "expected": "The Application Setup Wizard automatically opens when switching to Application perspective with no app-group tags.",
      "flow": "setup",
      "sequence": 10,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/topo-element-rules",
  "tests": [
    {
      "id": "element-rules-shared-across-perspectives",
      "category": "Element Rules",
      "description": "Adding a ByTag element rule in L3 perspective is visible in Application perspective",
      "steps": [
        "Open topology in L3 Logical perspective",
        "Open the grouping options panel",
        "Add a new ByTag element rule and select some tags",
        "Close the rule editor (click checkmark)",
        "Switch to Application perspective",
        "Open the grouping options panel"
      ],
      "expected": "The ByTag rule added in L3 appears in the element grouping section of Application perspective with the same tags selected",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "element-rules-persist-on-reload",
      "category": "Element Rules",
      "description": "Shared element rules persist across page reloads",
      "steps": [
        "Open topology and add a new ByServiceCategory element rule with some categories",
        "Close the rule editor",
        "Reload the page",
        "Open the grouping options panel"
      ],
      "expected": "The element rule persists with the same categories after reload",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "container-rules-remain-per-perspective",
      "category": "Container Rules",
      "description": "Container rules are still perspective-specific",
      "steps": [
        "Open topology in L3 Logical perspective",
        "Note the container rules in the grouping panel (e.g., BySubnet)",
        "Switch to Application perspective",
        "Note the container rules"
      ],
      "expected": "Container rules differ between perspectives (e.g., L3 has BySubnet, Application has ByApplicationGroup). They are NOT shared.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "element-rules-rebuild-triggers",
      "category": "Element Rules",
      "description": "Editing element rules triggers topology rebuild",
      "steps": [
        "Open topology with auto-rebuild enabled",
        "Add a new ByServiceCategory element rule",
        "Select DNS category and close the editor"
      ],
      "expected": "Topology rebuilds and DNS services are grouped into a nested container within their parent container",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "inspector-create-grouping-rule",
      "category": "Element Rules",
      "description": "Creating a grouping rule from tag inspector works with shared store",
      "steps": [
        "Select multiple nodes in the topology",
        "In the inspector panel, add a tag to the selected nodes",
        "Click the 'Create grouping rule' button that appears"
      ],
      "setup": "Ensure at least 2 hosts exist on the topology with services",
      "expected": "A ByTag element rule is created with the recently added tag. The rule appears in the grouping panel and persists when switching perspectives.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "reset-options-clears-element-rules",
      "category": "Element Rules",
      "description": "Resetting topology options also resets shared element rules to defaults",
      "steps": [
        "Add several custom element rules (ByTag, ByServiceCategory)",
        "Reset topology options (if reset button available, or clear localStorage manually)",
        "Open the grouping options panel"
      ],
      "expected": "Element rules are reset to the default (single ByServiceCategory rule with DNS and ReverseProxy)",
      "status": null,
      "feedback": null
    }
  ]
}
];
