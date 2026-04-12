<script lang="ts">
	import {
		optionsPanelExpanded,
		selectedNode,
		selectedEdge,
		selectedNodes,
		previewEdges,
		OPTIONS_PANEL_WIDTH_PX
	} from '../../queries';
	import { get } from 'svelte/store';
	import { ChevronLeft, ChevronRight, Filter, Group, Eye } from 'lucide-svelte';
	import OptionsContent from './options/OptionsContent.svelte';
	import InspectorNode from './inspectors/InspectorNode.svelte';
	import InspectorEdge from './inspectors/InspectorEdge.svelte';
	import InspectorMultiSelect from './inspectors/InspectorMultiSelect.svelte';
	import {
		topology_collapsePanel,
		topology_expandPanel,
		common_filters,
		common_groupsLabel,
		common_display
	} from '$lib/paraglide/messages';

	type OptionsTab = 'filter' | 'group' | 'visual';
	let activeTab = $state<OptionsTab>('filter');

	const tabs: { id: OptionsTab; label: string; icon: typeof Filter }[] = [
		{ id: 'filter', label: common_filters(), icon: Filter },
		{ id: 'group', label: common_groupsLabel(), icon: Group },
		{ id: 'visual', label: common_display(), icon: Eye }
	];

	let {
		isReadOnly = false,
		onClearSelection,
		onGroupCreated
	}: {
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

	let showingOptions = $derived(!$selectedNode && !$selectedEdge && multiSelectedNodes.length < 2);
</script>

<!-- Floating Panel -->
<div
	class="topology-options absolute left-4 top-4 z-10 duration-300 {$optionsPanelExpanded
		? ''
		: 'w-auto'}"
	style={$optionsPanelExpanded ? `width: ${OPTIONS_PANEL_WIDTH_PX}px` : ''}
>
	<div class="card card-static p-0 shadow-lg">
		{#if $optionsPanelExpanded}
			<!-- Header with collapse button and tabs -->
			<div class="flex items-end">
				<button
					class="btn-icon flex-shrink-0 rounded-xl p-3"
					onclick={() => optionsPanelExpanded.set(false)}
					aria-label={topology_collapsePanel()}
				>
					<ChevronLeft class="text-secondary h-5 w-5" />
				</button>
				{#if showingOptions}
					<div class="flex flex-1">
						{#each tabs as tab (tab.id)}
							<button
								class="flex flex-1 items-center justify-center gap-1.5 border-b-2 pb-2 pt-2.5 text-xs font-medium transition-colors {activeTab ===
								tab.id
									? 'border-blue-500 text-blue-400'
									: 'text-secondary hover:text-primary border-gray-700'}"
								onclick={() => (activeTab = tab.id)}
							>
								<tab.icon class="h-3.5 w-3.5" />
								{tab.label}
							</button>
						{/each}
					</div>
				{:else}
					<div class="flex-1 border-b-2 border-gray-700"></div>
				{/if}
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
					<OptionsContent {activeTab} />
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
