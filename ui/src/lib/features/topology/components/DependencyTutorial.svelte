<script lang="ts">
	import {
		SvelteFlow,
		SvelteFlowProvider,
		Background,
		BackgroundVariant
	} from '@xyflow/svelte';
	import { writable } from 'svelte/store';
	import { setContext } from 'svelte';
	import '@xyflow/svelte/dist/style.css';
	import './visualization/topology-viewer.css';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ChecklistItem from '$lib/shared/components/data/ChecklistItem.svelte';
	import ElementNode from './visualization/ElementNode.svelte';
	import CustomEdge from './visualization/CustomEdge.svelte';
	import {
		selectedNodes,
		previewEdges,
		OPTIONS_PANEL_WIDTH_PX,
		OPTIONS_PANEL_LEFT_OFFSET_PX
	} from '../queries';
	import { dependencyTypes } from '$lib/shared/stores/metadata';
	import { browser } from '$app/environment';
	import {
		TUTORIAL_SERVICES,
		TUTORIAL_TOPOLOGY,
		TUTORIAL_XYFLOW_NODES
	} from './dependency-tutorial-data';
	import type { Node, Edge } from '@xyflow/svelte';
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
	const modalLeftOffset = OPTIONS_PANEL_WIDTH_PX + OPTIONS_PANEL_LEFT_OFFSET_PX + 16;

	// Provide tutorial topology via context so ElementNode resolves services
	const topologyStore = writable(TUTORIAL_TOPOLOGY);
	setContext('topology', topologyStore);

	// Also provide isolated selection context so ElementNode doesn't highlight from global state
	const localSelectedNode = writable<Node | null>(null);
	const localSelectedEdge = writable<Edge | null>(null);
	setContext('selectedNode', localSelectedNode);
	setContext('selectedEdge', localSelectedEdge);

	// Node/edge types for mini SvelteFlow
	const nodeTypes = { Element: ElementNode };
	const edgeTypes = { custom: CustomEdge };

	// Xyflow stores — must be writable stores (same as BaseTopologyViewer)
	const tutorialNodes = writable<Node[]>([...TUTORIAL_XYFLOW_NODES]);
	const tutorialEdges = writable<Edge[]>([]);
	previewEdges.subscribe((value) => {
		tutorialEdges.set(value);
	});

	// Track clicked nodes
	let clickedNodeIds = $state(new Set<string>());

	function handleNodeClick({ node }: { node: Node; event: MouseEvent | TouchEvent }) {
		if (clickedNodeIds.has(node.id)) return;
		const updated = new Set(clickedNodeIds);
		updated.add(node.id);
		clickedNodeIds = updated;

		const xyNode = TUTORIAL_XYFLOW_NODES.find((n) => n.id === node.id);
		if (xyNode) {
			selectedNodes.set([...$selectedNodes, xyNode]);
		}
	}

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
<div class="tutorial-anchor" style="--tutorial-offset: {modalLeftOffset}px;">
	<GenericModal
		title={topology_tutorialTitle()}
		isOpen={true}
		showCloseButton={false}
		preventCloseOnClickOutside={true}
		showBackdrop={false}
		size="lg"
		fixedHeight={true}
	>
		<div class="flex min-h-0 flex-1 flex-col">
			<!-- Mini SvelteFlow canvas with real ElementNode + edge rendering -->
			<div class="min-h-0 flex-1">
				<SvelteFlowProvider>
					<SvelteFlow
						nodes={$tutorialNodes}
						edges={$tutorialEdges}
						{nodeTypes}
						{edgeTypes}
						onnodeclick={handleNodeClick}
						fitView={true}
						fitViewOptions={{ padding: 0.3 }}
						minZoom={0.5}
						maxZoom={1.5}
						nodesDraggable={false}
						nodesConnectable={false}
						elementsSelectable={true}
						selectionOnDrag={false}
						panOnDrag={true}
						zoomOnScroll={false}
						zoomOnDoubleClick={false}
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
			<div class="border-primary/10 flex-shrink-0 border-t p-4">
				<div class="mb-2 flex items-center gap-0.5">
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
		z-index: 20;
		left: var(--tutorial-offset);
		right: 0;
		top: 0;
		bottom: 0;
	}
</style>
