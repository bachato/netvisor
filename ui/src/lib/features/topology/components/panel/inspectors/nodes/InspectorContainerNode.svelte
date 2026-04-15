<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { autoRebuild, activeView } from '$lib/features/topology/queries';
	import type { TopologyNode } from '$lib/features/topology/types/base';
	import { resolveContainerNode } from '$lib/features/topology/resolvers';
	import { useTopology } from '$lib/features/topology/context';
	import { getTopologyEditState } from '$lib/features/topology/state';
	import { getInspectorConfig, getSectionComponent } from '../view-config';

	let { node }: { node: Node } = $props();

	const { topology: topologyStore, isReadonly } = useTopology();
	let topology = $derived($topologyStore);

	let editState = $derived(getTopologyEditState(topology, $autoRebuild, isReadonly));

	let containerCtx = $derived(
		topology ? resolveContainerNode(node.id, node.data as TopologyNode, topology) : null
	);

	// View-driven section config
	let config = $derived(getInspectorConfig($activeView));
	let sections = $derived(config.container_sections);
</script>

{#if topology && containerCtx}
	<div class="space-y-4">
		{#each sections as section (section)}
			{@const SectionComponent = getSectionComponent(section)}
			<SectionComponent {node} {topology} {editState} containerContext={containerCtx} />
		{/each}
	</div>
{/if}
