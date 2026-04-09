<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContainerContents } from '$lib/features/topology/resolvers';
	import {
		inspector_dependencySummary,
		inspector_crossBoundaryDeps,
		inspector_noDependencies
	} from '$lib/paraglide/messages';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { DependencyDisplay } from '$lib/shared/components/forms/selection/display/DependencyDisplay.svelte';

	let {
		node,
		topology
	}: {
		node: Node;
		topology: Topology;
	} = $props();

	const { getNodes } = useSvelteFlow();

	// Find all element nodes in this container (including subcontainers)
	let descendantNodeIds = $derived.by(() => {
		return getContainerContents(node.id, getNodes()).elementNodeIds;
	});

	// Find dependencies that cross this container boundary
	// (have members both inside and outside)
	let crossBoundaryDeps = $derived.by(() => {
		const childSet = descendantNodeIds;
		return topology.dependencies.filter((d) => {
			const members = d.members;
			let memberServiceIds: string[] = [];
			if (members.type === 'Services') {
				memberServiceIds = members.service_ids;
			} else if (members.type === 'Bindings') {
				memberServiceIds = members.binding_ids
					.map((bid) => {
						const svc = topology.services.find((s) => s.bindings.some((b) => b.id === bid));
						return svc?.id ?? '';
					})
					.filter(Boolean);
			}
			const hasInside = memberServiceIds.some((id) => childSet.has(id));
			const hasOutside = memberServiceIds.some((id) => !childSet.has(id));
			return hasInside && hasOutside;
		});
	});
</script>

<div>
	<span class="text-secondary mb-2 block text-sm font-medium">{inspector_dependencySummary()}</span>
	{#if crossBoundaryDeps.length === 0}
		<p class="text-tertiary text-sm">{inspector_noDependencies()}</p>
	{:else}
		<div>
			<span class="text-tertiary mb-1 block text-xs font-medium uppercase">
				{inspector_crossBoundaryDeps()}
			</span>
			<div class="space-y-1">
				{#each crossBoundaryDeps as dep (dep.id)}
					<div class="card card-static">
						<EntityDisplayWrapper item={dep} context={{}} displayComponent={DependencyDisplay} />
					</div>
				{/each}
			</div>
		</div>
	{/if}
</div>
