<script lang="ts">
	import { optionsPanelExpanded, selectedNode, selectedEdge } from '../../queries';
	import { ChevronLeft, ChevronRight } from 'lucide-svelte';
	import OptionsContent from './options/OptionsContent.svelte';
	import InspectorNode from './inspectors/InspectorNode.svelte';
	import InspectorEdge from './inspectors/InspectorEdge.svelte';
	import { topology_collapsePanel, topology_expandPanel } from '$lib/paraglide/messages';
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
			<div class="flex items-center border-b border-gray-700">
				<button
					class="btn-icon rounded-xl p-3"
					onclick={() => optionsPanelExpanded.set(false)}
					aria-label={topology_collapsePanel()}
				>
					<ChevronLeft class="text-secondary h-5 w-5" />
				</button>
			</div>

			<!-- Content area -->
			<div class="overflow-y-auto p-3" style="max-height: calc(100vh - 250px);">
				{#if $selectedNode}
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
