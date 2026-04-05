<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import {
		useTopologiesQuery,
		selectedTopologyId,
		autoRebuild,
		activePerspective
	} from '$lib/features/topology/queries';
	import type { TopologyNode, Topology } from '$lib/features/topology/types/base';
	import { resolveContainerNode } from '$lib/features/topology/resolvers';
	import { getTopologyEditState } from '$lib/features/topology/state';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import { getInspectorConfig, getSectionComponent } from '../perspective-config';

	let { node }: { node: Node } = $props();

	// Try to get topology from context (for share/embed pages), fallback to query + selected topology
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext ? $topologyContext : topologiesData.find((t) => t.id === $selectedTopologyId)
	);

	// Unified edit state
	let isReadonly = $derived(!!topologyContext);
	let editState = $derived(getTopologyEditState(topology, $autoRebuild, isReadonly));

	let containerCtx = $derived(
		topology ? resolveContainerNode(node.id, node.data as TopologyNode, topology) : null
	);

	// Perspective-driven section config
	let config = $derived(getInspectorConfig($activePerspective));
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
