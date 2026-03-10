<script lang="ts">
	import {
		optionsPanelExpanded,
		selectedNode,
		selectedEdge,
		selectedNodes,
		previewEdges
	} from '../../queries';
	import { get } from 'svelte/store';
	import { ChevronLeft, ChevronRight } from 'lucide-svelte';
	import OptionsContent from './options/OptionsContent.svelte';
	import InspectorNode from './inspectors/InspectorNode.svelte';
	import InspectorEdge from './inspectors/InspectorEdge.svelte';
	import InspectorMultiSelect from './inspectors/InspectorMultiSelect.svelte';
	import ShortcutsHelpOverlay from '../visualization/ShortcutsHelpOverlay.svelte';
	import {
		topology_collapsePanel,
		topology_expandPanel,
		topology_shortcutsTitle
	} from '$lib/paraglide/messages';
	import TopologyStatsBar from './TopologyStatsBar.svelte';
	import type { Topology } from '../../types/base';

	let {
		topology,
		isReadOnly = false,
		onClearSelection,
		onGroupCreated
	}: {
		topology: Topology;
		isReadOnly?: boolean;
		onClearSelection?: () => void;
		onGroupCreated?: (groupId: string) => void;
	} = $props();

	let multiSelectedNodes = $state(get(selectedNodes));
	selectedNodes.subscribe((value) => {
		multiSelectedNodes = value;
	});

	// Auto-expand panel when something is selected
	$effect(() => {
		if ($selectedNode || $selectedEdge || multiSelectedNodes.length >= 2) {
			optionsPanelExpanded.set(true);
		}
	});

	// Clear preview edges when multi-selection drops below 2
	$effect(() => {
		if (multiSelectedNodes.length < 2) {
			previewEdges.set([]);
		}
	});
</script>

<!-- Floating Panel -->
<div
	class="topology-options absolute left-4 top-4 z-10 duration-300 {$optionsPanelExpanded
		? 'w-96'
		: 'w-auto'}"
>
	<div class="card card-static p-0 shadow-lg">
		{#if $optionsPanelExpanded}
			<!-- Header with collapse button -->
			<div class="flex items-center justify-end border-b border-gray-700">
				<button
					class="btn-icon flex-shrink-0 rounded-xl p-3"
					onclick={() => optionsPanelExpanded.set(false)}
					aria-label={topology_collapsePanel()}
				>
					<ChevronLeft class="text-secondary h-5 w-5" />
				</button>
				<TopologyStatsBar {topology} />
			</div>

			<!-- Content area -->
			<div class="overflow-y-auto p-3" style="max-height: calc(100vh - 250px);">
				{#if multiSelectedNodes.length >= 2}
					<InspectorMultiSelect
						{isReadOnly}
						onClearSelection={onClearSelection ?? (() => selectedNodes.set([]))}
						{onGroupCreated}
					/>
				{:else if $selectedNode}
					{#key $selectedNode.id}
						<InspectorNode node={$selectedNode} />
					{/key}
				{:else if $selectedEdge}
					{#key $selectedEdge.id}
						<InspectorEdge edge={$selectedEdge} />
					{/key}
				{:else}
					<OptionsContent />
				{/if}
			</div>
		{:else}
			<!-- Collapsed toggle button - just the chevron -->
			<button
				class="btn-icon rounded-2xl p-3"
				onclick={() => optionsPanelExpanded.set(true)}
				aria-label={topology_expandPanel()}
			>
				<ChevronRight class="text-secondary h-5 w-5" />
			</button>
		{/if}
	</div>
</div>
