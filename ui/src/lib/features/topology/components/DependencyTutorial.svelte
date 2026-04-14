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
	import './visualization/topology-viewer.css';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
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

	// Xyflow nodes
	const nodes = writable<Node[]>(TUTORIAL_XYFLOW_NODES);

	// Track which nodes the user has clicked
	let clickedNodeIds = $state(new Set<string>());

	const handleNodeClick: NodeMouseHandler = (_event, node) => {
		if (clickedNodeIds.has(node.id)) return;
		const updated = new Set(clickedNodeIds);
		updated.add(node.id);
		clickedNodeIds = updated;

		const xyNode = TUTORIAL_XYFLOW_NODES.find((n) => n.id === node.id);
		if (xyNode) {
			const current = [...$selectedNodes];
			current.push(xyNode);
			selectedNodes.set(current);
		}
	};

	// Step completion
	let step1Done = $derived(clickedNodeIds.size >= 1);
	let step2Done = $derived(clickedNodeIds.size >= 3);
	let step3Done = $derived(dependencyTypeToggled);

	const RequestPathIcon = dependencyTypes.getIconComponent('RequestPath');
	const HubAndSpokeIcon = dependencyTypes.getIconComponent('HubAndSpoke');

	let selectionDots = $derived(TUTORIAL_SERVICES.map((n) => clickedNodeIds.has(n.id)));
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
		size="xl"
		fixedHeight={true}
	>
		<div class="flex min-h-0 flex-1 flex-col">
			<!-- Mini topology canvas with real ElementNode components -->
			<div class="h-64">
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
						preventScrolling={true}
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

			<!-- Checklist below the canvas -->
			<div class="border-primary/10 border-t p-6">
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

				<div class="space-y-0">
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

				<div class="mt-3 text-center">
					<button
						class="text-secondary hover:text-primary text-xs underline"
						onclick={onDismiss}
					>
						{topology_tutorialSkip()}
					</button>
				</div>
			</div>
		</div>
	</GenericModal>
</div>

<style>
	.tutorial-anchor :global(.modal-page) {
		position: absolute;
		z-index: 30;
	}
</style>
