var TEST_PLANS = [
{
  "branch": "research/nudge-alignment",
  "tests": [
    {
      "id": "nudge-explore-perspectives-shown",
      "category": "Feature Nudges",
      "description": "Explore Perspectives nudge appears after first topology rebuild",
      "steps": [
        "Navigate to the Home tab",
        "Look at the Suggestions section"
      ],
      "setup": "Ensure the org has completed FirstTopologyRebuild milestone. Clear localStorage for nudge-dismissed:explore-perspectives.",
      "expected": "The 'Explore Topology Views' nudge appears as one of the first 2 suggestions",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-application-tags-shown",
      "category": "Feature Nudges",
      "description": "Application Tags nudge appears after topology rebuild when no app tags exist",
      "steps": [
        "Navigate to the Home tab",
        "Look at the Suggestions section"
      ],
      "setup": "Ensure the org has completed FirstTopologyRebuild but NOT FirstApplicationTagCreated. Clear localStorage for nudge-dismissed:application-tags.",
      "expected": "The 'Set Up Applications' nudge appears in the Suggestions section",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-application-tags-action",
      "category": "Feature Nudges",
      "description": "Clicking Application Tags nudge navigates to topology Application view",
      "steps": [
        "Click the action button on the 'Set Up Applications' nudge"
      ],
      "setup": "Ensure the org has completed FirstTopologyRebuild but NOT FirstApplicationTagCreated. No application tags should exist.",
      "expected": "User is taken to the topology tab with the Application view active. The Application Setup Wizard auto-opens.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-application-tags-dismissed-after-creation",
      "category": "Feature Nudges",
      "description": "Application Tags nudge disappears after creating an application tag",
      "steps": [
        "Complete the Application Setup Wizard (create at least one application tag)",
        "Navigate back to the Home tab",
        "Check the Suggestions section"
      ],
      "expected": "The 'Set Up Applications' nudge is no longer shown",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-dependencies-navigates-topology",
      "category": "Feature Nudges",
      "description": "Dependencies nudge navigates to topology (not broken tab)",
      "steps": [
        "On the Home tab, find the 'Create a Dependency' nudge",
        "Click its action button"
      ],
      "setup": "Ensure org has FirstTopologyRebuild but NOT FirstDependencyCreated. Clear localStorage for nudge-dismissed:dependencies.",
      "expected": "User is taken to the topology tab (not a broken/empty page)",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-snmp-gated-behind-discovery",
      "category": "Feature Nudges",
      "description": "SNMP nudge does not appear before first discovery",
      "steps": [
        "Navigate to Home tab",
        "Check the Suggestions section"
      ],
      "setup": "Ensure org has FirstDaemonRegistered but NOT FirstDiscoveryCompleted. Clear all nudge-dismissed localStorage keys.",
      "expected": "The 'Enable SNMP Discovery' nudge is NOT shown. It should only appear after FirstDiscoveryCompleted.",
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-snmp-shown-after-discovery",
      "category": "Feature Nudges",
      "description": "SNMP nudge appears after first discovery when no SNMP credential exists",
      "steps": [
        "Navigate to Home tab after first discovery completes",
        "Check the Suggestions section"
      ],
      "setup": "Ensure org has FirstDiscoveryCompleted but NOT FirstSnmpCredentialCreated. Clear localStorage for nudge-dismissed:snmp.",
      "expected": "The 'Enable SNMP Discovery' nudge appears in the Suggestions section",
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-removed-unclaimed-ports",
      "category": "Feature Nudges",
      "description": "Unclaimed Open Ports nudge no longer appears",
      "steps": [
        "Navigate to Home tab",
        "Check the Suggestions section"
      ],
      "setup": "Run a discovery that produces unclaimed open ports on some hosts. Clear all nudge-dismissed localStorage keys.",
      "expected": "No 'Unclaimed Open Ports' nudge appears anywhere in the Suggestions section",
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-removed-scheduled-free",
      "category": "Feature Nudges",
      "description": "Schedule Automatic Scans upsell nudge no longer appears",
      "steps": [
        "Navigate to Home tab on a free plan org",
        "Check the Suggestions section"
      ],
      "setup": "Use an org on the free plan. Clear all nudge-dismissed localStorage keys.",
      "expected": "No 'Schedule Automatic Scans' nudge appears",
      "status": null,
      "feedback": null
    },
    {
      "id": "nudge-ordering-value-based",
      "category": "Feature Nudges",
      "description": "Nudges appear in activation-value order",
      "steps": [
        "Navigate to Home tab",
        "Observe which 2 nudges are shown",
        "Dismiss first nudge, observe next one",
        "Continue dismissing to verify order"
      ],
      "setup": "Ensure org has FirstTopologyRebuild. Clear ALL nudge-dismissed localStorage keys. Ensure no app tags, no dependencies, no SNMP credential, no invites sent.",
      "expected": "Nudges appear in order: Explore Topology Views, Set Up Applications, Create a Dependency, Enable SNMP Discovery, Organize with Tags, Invite Your Team, etc.",
      "status": null,
      "feedback": null
    },
    {
      "id": "l2-empty-snmp-hint",
      "category": "Topology",
      "description": "L2 empty state shows SNMP credential hint when no SNMP credential exists",
      "steps": [
        "Navigate to the topology tab",
        "Switch to the L2 Physical view"
      ],
      "setup": "Ensure org has no SNMP credentials and no L2 neighbor data discovered. Org must have at least one topology.",
      "expected": "The L2 empty state overlay shows 'No Physical Connections' title, the standard description, AND a hint about adding SNMP credentials enabling neighbor discovery.",
      "status": null,
      "feedback": null
    },
    {
      "id": "l2-empty-no-snmp-hint-when-credential-exists",
      "category": "Topology",
      "description": "L2 empty state does not show SNMP hint when credential already exists",
      "steps": [
        "Navigate to the topology tab",
        "Switch to the L2 Physical view"
      ],
      "setup": "Add an SNMP credential to the org (triggering FirstSnmpCredentialCreated milestone). Ensure no L2 neighbor data.",
      "expected": "The L2 empty state overlay shows the standard description but NOT the SNMP credential hint.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/topology-node-model",
  "tests": [
    {
      "id": "topology-l3-renders",
      "category": "Topology Views",
      "description": "L3 Infrastructure view renders correctly after node model changes",
      "steps": [
        "Navigate to Topology page",
        "Select the L3 Infrastructure view",
        "Verify subnet containers render with correct icons and colors",
        "Verify elements (IP addresses) appear inside their subnet containers",
        "Verify edges connect between elements correctly"
      ],
      "expected": "L3 view renders identically to before the refactor — no visual regressions",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-l2-renders",
      "category": "Topology Views",
      "description": "L2 Physical view renders correctly",
      "steps": [
        "Select the L2 Physical view",
        "Verify Host containers appear with device names",
        "Verify Interface elements appear inside Host containers",
        "Verify physical link edges connect between hosts"
      ],
      "expected": "L2 view renders correctly with Host containers and Interface elements",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-application-renders",
      "category": "Topology Views",
      "description": "Application view renders correctly",
      "steps": [
        "Select the Application view",
        "Verify Application containers appear with tag names and colors",
        "Verify Service elements appear inside their application containers",
        "Verify dependency edges connect services"
      ],
      "expected": "Application view renders with correct grouping and styling",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-workloads-renders",
      "category": "Topology Views",
      "description": "Workloads view renders correctly with Hypervisor/ContainerRuntime subcontainers",
      "steps": [
        "Select the Workloads view",
        "Verify Host containers appear for bare metal hosts",
        "Verify Hypervisor subcontainers nest inside host containers",
        "Verify VM elements appear inside Hypervisor subcontainers",
        "Verify ContainerRuntime subcontainers appear for Docker hosts"
      ],
      "setup": "Requires hosts with Proxmox VMs and/or Docker containers discovered",
      "expected": "Workloads view shows correct nesting hierarchy with subcontainers",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-element-rules-subcontainers",
      "category": "Element Rules",
      "description": "Element rules create subcontainers with correct element_rule_id and will_accept_edges",
      "steps": [
        "Open topology with ByTag or ByServiceCategory element rules configured",
        "Verify NestedTag or NestedServiceCategory subcontainers appear",
        "Verify elements are grouped inside the subcontainers",
        "Collapse a subcontainer and verify it collapses correctly"
      ],
      "setup": "Configure element rules (ByTag with a tag, or ByServiceCategory) on a perspective that has matching elements",
      "expected": "Subcontainers render, elements are grouped, collapse/expand works",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-edge-elevation",
      "category": "Edge Behavior",
      "description": "Edges with will_target_container still elevate to container boundaries",
      "steps": [
        "Open L3 view with Docker bridge grouping enabled",
        "Verify edges targeting consolidated Docker bridge subnets attach at the container boundary, not at individual elements"
      ],
      "setup": "Requires a topology with Docker bridge subnets that are consolidated (multiple Docker bridges on one host)",
      "expected": "Edges visually attach to the consolidated subnet container, not individual elements inside",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    },
    {
      "id": "topology-container-metadata",
      "category": "Container Metadata",
      "description": "Container type metadata renders correctly (icons, colors, title styles)",
      "steps": [
        "Open any topology view",
        "Verify top-level containers have External title style (title above container)",
        "Verify subcontainers have Inline title style (title inside container)",
        "Verify PortOpStatus containers are collapsed by default with filled circle icon"
      ],
      "expected": "All container types display with correct visual styling from metadata",
      "flow": "setup",
      "sequence": 7,
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "refactor/edge-naming-audit",
  "tests": [
    {
      "id": "edge-names-in-inspector-panel",
      "category": "Edge Display",
      "description": "Verify edge type names display correctly in the inspector panel when clicking edges",
      "steps": [
        "Open the L3 Logical topology view",
        "Click on a SameHost edge (connecting IPs on the same host)",
        "Verify the inspector panel shows correct edge details",
        "Click on a ContainerRuntime edge (connecting Docker service to containers)",
        "Verify the inspector panel shows Docker host, service, and containerized services",
        "Click on a Hypervisor edge (connecting hypervisor to VM) if Proxmox data exists",
        "Verify the inspector panel shows VM service and hypervisor host"
      ],
      "setup": "Ensure the topology has hosts with Docker containers and at least one Proxmox hypervisor with VMs.",
      "expected": "All edge types display their correct inspector panels with proper labels. No 'SmoothStep' or 'Virtualized Service' text should appear anywhere.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "edge-type-labels-in-metadata",
      "category": "Edge Display",
      "description": "Verify edge type metadata (names, icons, colors) display correctly throughout the UI",
      "steps": [
        "Open any topology view with visible edges",
        "Hover over different edge types",
        "Check that edge type names in tooltips/panels show 'Container Runtime' and 'Hypervisor' instead of 'Virtualized Service' and 'Virtualized Host'",
        "Check the edge visibility toggles if available"
      ],
      "expected": "Edge type display names should be 'Same Host', 'Container Runtime', 'Hypervisor', 'Physical Link', 'Request Path', 'Hub and Spoke'. No references to old names.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "aggregated-edges-display",
      "category": "Edge Display",
      "description": "Verify aggregated/bundled edges display correctly with new names",
      "steps": [
        "Open a topology view where edges are bundled",
        "Click on a bundled edge group",
        "Verify the aggregated edge inspector shows correct edge type groupings with new names"
      ],
      "expected": "Aggregated edge groups use 'Container Runtime' and 'Hypervisor' labels, not old names.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "edge-highlighting-container-runtime",
      "category": "Edge Interactions",
      "description": "Verify ContainerRuntime edge highlighting includes all container nodes",
      "steps": [
        "Open the L3 Logical view with Docker containers visible",
        "Click on a ContainerRuntime edge",
        "Verify that the Docker host node, target container node, and all related container interface nodes are highlighted"
      ],
      "setup": "Ensure topology has a Docker host with multiple containers on Docker bridge subnets.",
      "expected": "Selecting a ContainerRuntime edge highlights the source node, target node, and all virtualized container nodes on Docker bridge subnets.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "backward-compat-stored-topology",
      "category": "Backward Compatibility",
      "description": "Verify topologies with old edge type names still load correctly",
      "steps": [
        "Load a topology that was saved before this change (with HostVirtualization/ServiceVirtualization edge types in stored data)",
        "Verify the topology renders correctly",
        "Verify edges display with the new names in the UI"
      ],
      "expected": "Old topology data with 'HostVirtualization' and 'ServiceVirtualization' edge types deserializes correctly and displays with new names.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "feat/starter-trial",
  "tests": [
    {
      "id": "onboarding-free-hidden",
      "category": "Plan Selection",
      "description": "Free plan is not shown during new user onboarding",
      "steps": [
        "Create a new account and complete the use-case selection step",
        "Observe the plan selection modal that appears (non-dismissible)"
      ],
      "setup": "Ensure a fresh org with no plan set (new registration flow).",
      "expected": "The Free plan card should NOT appear in the plan selection. Only Starter, Pro, Business, and Enterprise should be visible.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "starter-trial-messaging",
      "category": "Plan Selection",
      "description": "Starter plan shows 14-day trial messaging and no credit card required",
      "steps": [
        "On the onboarding plan selection modal, look at the Starter plan card"
      ],
      "expected": "Starter should show: (1) '14-day free trial' badge in green, (2) 'No credit card required' text below it, (3) 'Start 14-day free trial' as the CTA button text.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "starter-trial-activation",
      "category": "Trial Flow",
      "description": "Selecting Starter activates a 14-day trial without requiring payment",
      "steps": [
        "On the onboarding plan selection, click 'Start 14-day free trial' on the Starter card",
        "Observe the result — should NOT redirect to Stripe checkout"
      ],
      "expected": "User lands in the app with an active trial. No Stripe checkout redirect. Organization should have plan_status='trialing' and trial_end_date set ~14 days in the future.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "settings-free-visible",
      "category": "Plan Selection",
      "description": "Free plan is visible in the settings billing modal for existing users",
      "steps": [
        "As an existing user with an active plan, open Settings > Billing",
        "Click 'Change your plan' to open the plan selection modal"
      ],
      "expected": "The Free plan card SHOULD appear in the plan selection (available for downgrade). The modal should be dismissible.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "returning-customer-no-trial",
      "category": "Trial Flow",
      "description": "Returning customers do not see trial offers on Starter",
      "steps": [
        "As a user who previously had a paid plan or has trial_end_date set, open the billing modal",
        "Look at the Starter plan card"
      ],
      "setup": "Set trial_end_date to a past date for the org, or ensure the org previously had a non-Free plan.",
      "expected": "Starter should NOT show '14-day free trial' badge or 'No credit card required'. CTA should say 'Get Started' instead of 'Start 14-day free trial'.",
      "status": null,
      "feedback": null
    },
    {
      "id": "scheduled-discovery-skipped-on-free",
      "category": "Discovery",
      "description": "Scheduled discoveries are silently skipped for Free plan orgs",
      "steps": [
        "Create a scheduled discovery with a short interval (e.g., every minute)",
        "Downgrade the org to Free plan",
        "Wait for the cron job to fire"
      ],
      "setup": "Create an org on a paid plan with a scheduled discovery. Then downgrade to Free via the billing flow.",
      "expected": "The scheduled discovery should NOT run. Check server logs for 'Skipping scheduled discovery — org is on Free plan'. The discovery's run_type should still be Scheduled (not converted to AdHoc).",
      "status": null,
      "feedback": null
    },
    {
      "id": "discovery-resumes-on-upgrade",
      "category": "Discovery",
      "description": "Scheduled discoveries resume after upgrading from Free to paid",
      "steps": [
        "With a Free plan org that has a scheduled discovery (preserved from before downgrade), upgrade to Starter or Pro",
        "Wait for the cron job to fire"
      ],
      "setup": "Use the org from the previous test that was downgraded to Free with a preserved scheduled discovery.",
      "expected": "The scheduled discovery should run normally after upgrade. The schedule config should be unchanged from what the user originally configured.",
      "status": null,
      "feedback": null
    },
    {
      "id": "existing-free-users-unaffected",
      "category": "Existing Users",
      "description": "Existing Free plan users retain full access",
      "steps": [
        "Log in as an existing user on the Free plan",
        "Navigate around the app, view topology, run an ad-hoc discovery"
      ],
      "setup": "Ensure an existing org is on the Free plan with some hosts and a discovery configured.",
      "expected": "Everything works as before. User can view data, run ad-hoc discoveries, and access all features within Free plan limits. No read-only restrictions.",
      "status": null,
      "feedback": null
    }
  ]
}
,
{
  "branch": "fix/workloads-empty-hosts-openports",
  "tests": [
    {
      "id": "workloads-empty-host-hidden",
      "category": "Workloads View",
      "description": "Host containers with zero services/VMs should not appear",
      "steps": [
        "Navigate to the Topology page and select the Workloads view",
        "Look for any host containers that have no service or VM elements inside them"
      ],
      "setup": "Ensure at least one host exists in the network that has no discovered services (or only has OpenPorts services).",
      "expected": "Only host containers with at least one service or VM element are visible. Empty hosts do not appear.",
      "flow": "setup",
      "sequence": 1,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-populated-host-shown",
      "category": "Workloads View",
      "description": "Host containers with services still appear normally",
      "steps": [
        "Navigate to the Topology page and select the Workloads view",
        "Verify that hosts with services (e.g., nginx, Docker containers, VMs) are visible with their elements"
      ],
      "expected": "All host containers with workload elements are displayed with their services, VMs, and subcontainers intact.",
      "flow": "setup",
      "sequence": 2,
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-open-ports-excluded",
      "category": "Workloads View",
      "description": "OpenPorts services should not appear as elements",
      "steps": [
        "Navigate to the Topology page and select the Workloads view",
        "Look for any 'Open Ports' service elements inside host containers"
      ],
      "setup": "Ensure at least one host has an OpenPorts service discovered alongside other regular services.",
      "expected": "No OpenPorts elements appear. Regular services on the same host are still visible.",
      "flow": "setup",
      "sequence": 3,
      "status": null,
      "feedback": null
    },
    {
      "id": "application-open-ports-excluded",
      "category": "Application View",
      "description": "OpenPorts services should not appear as elements",
      "steps": [
        "Navigate to the Topology page and select the Application view",
        "Look for any 'Open Ports' service elements"
      ],
      "setup": "Ensure at least one OpenPorts service with bindings exists.",
      "expected": "No OpenPorts elements appear in the Application view.",
      "flow": "setup",
      "sequence": 4,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-open-ports-faded",
      "category": "L3 View",
      "description": "OpenPorts should still show as faded in L3 (existing behavior)",
      "steps": [
        "Navigate to the Topology page and select the L3 Logical view",
        "Look for OpenPorts elements — they should appear with faded/dimmed styling"
      ],
      "expected": "OpenPorts elements are visible but faded in L3 view, matching previous behavior.",
      "flow": "setup",
      "sequence": 5,
      "status": null,
      "feedback": null
    },
    {
      "id": "l3-docker-bridge-positioning",
      "category": "L3 View",
      "description": "Docker Bridge containers should be positioned near their host's subnet",
      "steps": [
        "Navigate to the Topology page and select the L3 Logical view",
        "Find a host running Docker with the MergeDockerBridges grouping rule enabled",
        "Observe the Docker Bridge container's position relative to the subnet containing the host's IP"
      ],
      "setup": "Ensure a host with Docker and containerized services exists, and the MergeDockerBridges container rule is active in L3 grouping.",
      "expected": "The Docker Bridge container is positioned adjacent to or near the subnet containing the Docker host, not far away in a disconnected position.",
      "status": null,
      "feedback": null
    },
    {
      "id": "workloads-no-orphaned-edges",
      "category": "Workloads View",
      "description": "No orphaned edges after empty host removal",
      "steps": [
        "Navigate to the Topology page and select the Workloads view",
        "Open browser DevTools console",
        "Check for any SvelteFlow errors about missing nodes or orphaned edges"
      ],
      "expected": "No console errors related to missing nodes or edge references. All visible edges connect to existing containers/elements.",
      "flow": "setup",
      "sequence": 6,
      "status": null,
      "feedback": null
    }
  ]
}
];
