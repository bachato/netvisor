<script lang="ts">
	import {
		SvelteFlow,
		SvelteFlowProvider,
		Background,
		BackgroundVariant,
		type NodeMouseHandler
	} from '@xyflow/svelte';
	import { writable } from 'svelte/store';
	import { setContext } from 'svelte';
	import '@xyflow/svelte/dist/style.css';
	import '../components/visualization/topology-viewer.css';
	import ChecklistItem from '$lib/shared/components/data/ChecklistItem.svelte';
	import ElementNode from './visualization/ElementNode.svelte';
	import { selectedNodes } from '../queries';
	import { dependencyTypes } from '$lib/shared/stores/metadata';
	import { browser } from '$app/environment';
	import {
		TUTORIAL_SERVICES,
		TUTORIAL_TOPOLOGY,
		TUTORIAL_XYFLOW_NODES
	} from './dependency-tutorial-data';
	import type { Node } from '@xyflow/svelte';
	import {
		topology_tutorialTitle,
		topology_tutorialStep1,
		topology_tutorialStep2,
		topology_tutorialStep3,
		topology_tutorialStep4,
		topology_tutorialSkip
	} from '$lib/paraglide/messages';

	let {
		onDismiss,
		dependencyTypeToggled = false
	}: {
		onDismiss: () => void;
		dependencyTypeToggled?: boolean;
	} = $props();

	const modifier = browser && navigator.platform.includes('Mac') ? '⌘' : 'Ctrl';

	// Provide tutorial topology via context so ElementNode can resolve services
	const topologyStore = writable(TUTORIAL_TOPOLOGY);
	setContext('topology', topologyStore);

	// Node types for the mini SvelteFlow
	const nodeTypes = { Element: ElementNode };

	// Xyflow nodes — use writable for SvelteFlow
	const nodes = writable<Node[]>(TUTORIAL_XYFLOW_NODES);

	// Track which nodes the user has clicked
	let clickedNodeIds = $state(new Set<string>());

	const handleNodeClick: NodeMouseHandler = (_event, node) => {
		if (clickedNodeIds.has(node.id)) return;
		const updated = new Set(clickedNodeIds);
		updated.add(node.id);
		clickedNodeIds = updated;

		// Find the full xyflow node and inject into selectedNodes store
		const xyNode = TUTORIAL_XYFLOW_NODES.find((n) => n.id === node.id);
		if (xyNode) {
			const current = [...$selectedNodes];
			current.push(xyNode);
			selectedNodes.set(current);
		}
	};

	// Step completion tracking
	let step1Done = $derived(clickedNodeIds.size >= 1);
	let step2Done = $derived(clickedNodeIds.size >= 3);
	let step3Done = $derived(dependencyTypeToggled);

	// Get dependency type icons from metadata
	const RequestPathIcon = dependencyTypes.getIconComponent('RequestPath');
	const HubAndSpokeIcon = dependencyTypes.getIconComponent('HubAndSpoke');

	// Selection progress dots
	let selectionDots = $derived(TUTORIAL_SERVICES.map((n) => clickedNodeIds.has(n.id)));
</script>

<!-- Mini topology viewer with tutorial nodes -->
<div class="relative flex h-full flex-col">
	<!-- SvelteFlow canvas showing real ElementNode components -->
	<div class="flex-1">
		<SvelteFlowProvider>
			<SvelteFlow
				{nodes}
				edges={writable([])}
				{nodeTypes}
				onnodeclick={handleNodeClick}
				fitView={true}
				minZoom={0.5}
				maxZoom={1.5}
				nodesDraggable={false}
				nodesConnectable={false}
				elementsSelectable={false}
				panOnDrag={false}
				zoomOnScroll={false}
				zoomOnDoubleClick={false}
				preventScrolling={false}
			>
				<Background
					variant={BackgroundVariant.Dots}
					bgColor="var(--color-topology-bg)"
					gap={50}
					size={1}
				/>
			</SvelteFlow>
		</SvelteFlowProvider>
	</div>

	<!-- Tutorial checklist overlay at the bottom -->
	<div
		class="absolute inset-x-0 bottom-0 z-10 bg-gradient-to-t from-black/80 to-transparent px-6 pb-6 pt-12"
	>
		<div class="mx-auto max-w-md">
			<h3 class="text-primary mb-3 text-base font-semibold">
				{topology_tutorialTitle()}
			</h3>

			<!-- Selection progress dots -->
			<div class="mb-3 flex items-center gap-0.5">
				{#each selectionDots as filled}
					<span
						class="inline-block h-1.5 w-1.5 rounded-full {filled
							? 'bg-green-400'
							: 'bg-gray-300 dark:bg-gray-600'}"
					></span>
				{/each}
			</div>

			<!-- Step checklist -->
			<div class="space-y-0">
				<ChecklistItem checked={step1Done} disabled={step1Done} label={topology_tutorialStep1()} />
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
				<ChecklistItem checked={false} disabled={!step3Done} label={topology_tutorialStep4()} />
			</div>

			<!-- Skip button -->
			<div class="mt-3 text-center">
				<button class="text-secondary hover:text-primary text-xs underline" onclick={onDismiss}>
					{topology_tutorialSkip()}
				</button>
			</div>
		</div>
	</div>
</div>
