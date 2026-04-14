<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ChecklistItem from '$lib/shared/components/data/ChecklistItem.svelte';
	import { selectedNodes } from '../queries';
	import { dependencyTypes } from '$lib/shared/stores/metadata';
	import { browser } from '$app/environment';
	import type { Topology } from '../types/base';
	import type { Node } from '@xyflow/svelte';
	import {
		topology_tutorialTitle,
		topology_tutorialStep1,
		topology_tutorialStep2,
		topology_tutorialStep3,
		topology_tutorialStep4,
		topology_tutorialSkip
	} from '$lib/paraglide/messages';

	let { onDismiss }: { onDismiss: () => void } = $props();

	const modifier = browser && navigator.platform.includes('Mac') ? '⌘' : 'Ctrl';

	// Synthetic IDs
	const HOST_IDS = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];
	const SERVICE_IDS = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];

	const TUTORIAL_NODES = [
		{ id: SERVICE_IDS[0], label: 'Web App', hostId: HOST_IDS[0] },
		{ id: SERVICE_IDS[1], label: 'API Server', hostId: HOST_IDS[1] },
		{ id: SERVICE_IDS[2], label: 'Database', hostId: HOST_IDS[2] }
	];

	// Build synthetic topology with minimal required fields
	export const tutorialTopology: Topology = {
		id: crypto.randomUUID(),
		name: 'Tutorial',
		network_id: crypto.randomUUID(),
		is_locked: false,
		is_stale: false,
		last_refreshed: new Date().toISOString(),
		locked_at: null,
		locked_by: null,
		parent_id: null,
		created_at: new Date().toISOString(),
		updated_at: new Date().toISOString(),
		nodes: [],
		edges: [],
		dependencies: [],
		entity_tags: [],
		bindings: [],
		ports: [],
		ip_addresses: [],
		interfaces: [],
		removed_bindings: [],
		removed_dependencies: [],
		removed_hosts: [],
		removed_interfaces: [],
		removed_ip_addresses: [],
		removed_ports: [],
		removed_services: [],
		removed_subnets: [],
		options: {
			request: { element_rules: [], container_rules: [] },
			local: {
				hide_edge_types: [],
				edge_color_mode: 'ByType',
				hide_ports: false,
				expand_level: 'ContainersExpanded'
			}
		},
		hosts: TUTORIAL_NODES.map((n) => ({
			id: n.hostId,
			name: n.label,
			hostname: null,
			description: null,
			hidden: false,
			chassis_id: null,
			management_url: null,
			manufacturer: null,
			model: null,
			os: null,
			serial: null,
			credential_assignments: [],
			network_id: '',
			tags: [],
			source: { type: 'Manual' },
			created_at: new Date().toISOString(),
			updated_at: new Date().toISOString()
		})),
		services: TUTORIAL_NODES.map((n) => ({
			id: n.id,
			name: n.label,
			host_id: n.hostId,
			network_id: '',
			position: 0,
			service_definition: 'Generic',
			source: { type: 'Manual' },
			bindings: [],
			tags: [],
			created_at: new Date().toISOString(),
			updated_at: new Date().toISOString()
		})),
		subnets: []
	} as unknown as Topology;

	// Build xyflow Node objects for injection into selectedNodes store
	function makeFakeNode(tutorialNode: (typeof TUTORIAL_NODES)[number]): Node {
		return {
			id: tutorialNode.id,
			position: { x: 0, y: 0 },
			data: {
				id: tutorialNode.id,
				node_type: 'Element',
				element_type: 'Service',
				host_id: tutorialNode.hostId,
				header: tutorialNode.label,
				position: { x: 0, y: 0 },
				size: { x: 150, y: 40 }
			},
			type: 'Element'
		};
	}

	// Track which pseudo-nodes the user has clicked
	let clickedNodeIds = $state(new Set<string>());

	function handleNodeClick(tutorialNode: (typeof TUTORIAL_NODES)[number]) {
		if (clickedNodeIds.has(tutorialNode.id)) return;
		const updated = new Set(clickedNodeIds);
		updated.add(tutorialNode.id);
		clickedNodeIds = updated;

		// Inject into selectedNodes store incrementally
		const fakeNode = makeFakeNode(tutorialNode);
		const current = [...$selectedNodes];
		current.push(fakeNode);
		selectedNodes.set(current);
	}

	// Step completion tracking
	let hasToggledType = $state(false);

	export function handleDependencyTypeChange() {
		hasToggledType = true;
	}

	let step1Done = $derived(clickedNodeIds.size >= 1);
	let step2Done = $derived(clickedNodeIds.size >= 3);
	let step3Done = $derived(hasToggledType);

	// Get dependency type icons from metadata
	const RequestPathIcon = dependencyTypes.getIconComponent('RequestPath');
	const HubAndSpokeIcon = dependencyTypes.getIconComponent('HubAndSpoke');

	// Selection progress dots
	let selectionDots = $derived(TUTORIAL_NODES.map((n) => clickedNodeIds.has(n.id)));
</script>

<!-- Shroud over the topology viewer -->
<div class="absolute inset-0 z-20 bg-black/60 backdrop-blur-sm"></div>

<!-- Modal anchored to topology view -->
<div class="tutorial-anchor">
	<GenericModal
		title={topology_tutorialTitle()}
		isOpen={true}
		showCloseButton={false}
		preventCloseOnClickOutside={true}
		showBackdrop={false}
		size="md"
	>
		<div class="flex flex-col gap-6 p-6">
			<!-- Pseudo-nodes -->
			<div class="flex items-center justify-center gap-4">
				{#each TUTORIAL_NODES as node (node.id)}
					<button
						class="card flex min-w-[120px] items-center justify-center gap-2 px-4 py-3 text-sm font-medium transition-all
							{clickedNodeIds.has(node.id)
							? 'ring-accent/60 bg-accent/10 text-accent ring-2'
							: 'card-static text-secondary hover:text-primary hover:ring-accent/30 cursor-pointer hover:ring-1'}"
						onclick={() => handleNodeClick(node)}
						disabled={clickedNodeIds.has(node.id)}
					>
						{node.label}
					</button>
				{/each}
			</div>

			<!-- Selection progress dots (sidebar checklist pattern) -->
			<div class="flex items-center justify-center gap-0.5">
				{#each selectionDots as filled}
					<span
						class="inline-block h-1.5 w-1.5 rounded-full {filled
							? 'bg-green-400'
							: 'bg-gray-300 dark:bg-gray-600'}"
					></span>
				{/each}
			</div>

			<!-- Step checklist using ChecklistItem -->
			<div>
				<ChecklistItem
					checked={step1Done}
					disabled={step1Done}
					label={topology_tutorialStep1()}
				/>
				<ChecklistItem
					checked={step2Done}
					disabled={step2Done}
					label={topology_tutorialStep2({ modifier })}
				/>
				<ChecklistItem
					checked={step3Done}
					disabled={step3Done || !step2Done}
					label={topology_tutorialStep3()}
				>
					{#snippet labelExtra()}
						<svelte:component this={RequestPathIcon} class="h-3.5 w-3.5" />
						<svelte:component this={HubAndSpokeIcon} class="h-3.5 w-3.5" />
					{/snippet}
				</ChecklistItem>
				<ChecklistItem
					checked={false}
					disabled={!step3Done}
					label={topology_tutorialStep4()}
				/>
			</div>

			<!-- Skip button -->
			<div class="text-center">
				<button
					class="text-secondary hover:text-primary text-xs underline"
					onclick={onDismiss}
				>
					{topology_tutorialSkip()}
				</button>
			</div>
		</div>
	</GenericModal>
</div>

<style>
	/* Override GenericModal's fixed viewport positioning to anchor within the topology view */
	.tutorial-anchor :global(.modal-page) {
		position: absolute;
		z-index: 30;
	}
</style>
