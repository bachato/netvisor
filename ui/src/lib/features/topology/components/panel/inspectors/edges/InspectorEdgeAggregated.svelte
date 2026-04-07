<script lang="ts">
	import type { TopologyEdge, Topology } from '$lib/features/topology/types/base';
	import { useTopologiesQuery, selectedTopologyId } from '$lib/features/topology/queries';
	import { edgeTypes } from '$lib/shared/stores/metadata';
	import { topology_connectionsCount } from '$lib/paraglide/messages';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { InterfaceEdgeDisplay } from '$lib/shared/components/forms/selection/display/InterfaceEdgeDisplay.svelte';
	import { PhysicalLinkEdgeDisplay } from '$lib/shared/components/forms/selection/display/PhysicalLinkEdgeDisplay.svelte';
	import { HostVirtualizationEdgeDisplay } from '$lib/shared/components/forms/selection/display/HostVirtualizationEdgeDisplay.svelte';
	import { ServiceVirtualizationEdgeDisplay } from '$lib/shared/components/forms/selection/display/ServiceVirtualizationEdgeDisplay.svelte';
	import { DependencyDisplay } from '$lib/shared/components/forms/selection/display/DependencyDisplay.svelte';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import type { Dependency } from '$lib/features/dependencies/types/base';

	let { edges }: { edges: TopologyEdge[] } = $props();

	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext ? $topologyContext : topologiesData.find((t) => t.id === $selectedTopologyId)
	);

	// Group edges by type, deduplicating dependency edges by group_id
	let edgesByType = $derived.by(() => {
		const groups = new Map<string, TopologyEdge[]>();
		for (const edge of edges) {
			const type = edge.edge_type;
			const existing = groups.get(type);
			if (existing) {
				existing.push(edge);
			} else {
				groups.set(type, [edge]);
			}
		}
		return groups;
	});

	// For dependency edges, deduplicate by group_id and resolve to Dependency objects
	function getUniqueDependencies(typeEdges: TopologyEdge[]): Dependency[] {
		if (!topology) return [];
		const seen = new Set<string>();
		const deps: Dependency[] = [];
		for (const edge of typeEdges) {
			if (!('group_id' in edge)) continue;
			const groupId = edge.group_id as string;
			if (seen.has(groupId)) continue;
			seen.add(groupId);
			const dep = topology.dependencies.find((d) => d.id === groupId);
			if (dep) deps.push(dep);
		}
		return deps;
	}

	function getDisplayComponent(edgeType: string) {
		switch (edgeType) {
			case 'Interface':
				return InterfaceEdgeDisplay;
			case 'PhysicalLink':
				return PhysicalLinkEdgeDisplay;
			case 'HostVirtualization':
				return HostVirtualizationEdgeDisplay;
			case 'ServiceVirtualization':
				return ServiceVirtualizationEdgeDisplay;
			default:
				return null;
		}
	}

	function isDependencyEdge(edgeType: string) {
		return edgeType === 'HubAndSpoke' || edgeType === 'RequestPath';
	}
</script>

<div class="space-y-4">
	<span class="text-secondary block text-sm font-medium">
		{topology_connectionsCount({ count: edges.length })}
	</span>

	<div class="max-h-96 space-y-3 overflow-y-auto">
		{#each [...edgesByType.entries()] as [edgeType, typeEdges]}
			{@const typeName = edgeTypes.getName(edgeType)}
			{@const displayComponent = getDisplayComponent(edgeType)}

			{#if typeEdges.length > 1}
				<span class="text-tertiary block text-xs font-medium uppercase tracking-wide">
					{typeName} ({typeEdges.length})
				</span>
			{:else}
				<span class="text-tertiary block text-xs font-medium uppercase tracking-wide">
					{typeName}
				</span>
			{/if}

			{#if isDependencyEdge(edgeType)}
				{@const uniqueDeps = getUniqueDependencies(typeEdges)}
				{#each uniqueDeps as dep (dep.id)}
					<div class="card card-static">
						<EntityDisplayWrapper item={dep} context={{}} displayComponent={DependencyDisplay} />
					</div>
				{:else}
					<div class="card card-static">
						<div class="px-2 py-1">
							<span class="text-secondary text-sm">{typeName}</span>
						</div>
					</div>
				{/each}
			{:else}
				{#each typeEdges as edge (edge.id)}
					<div class="card card-static">
						{#if displayComponent}
							<EntityDisplayWrapper item={edge} context={{ topology }} {displayComponent} />
						{:else}
							<div class="px-2 py-1">
								<span class="text-secondary text-sm">{typeName}</span>
							</div>
						{/if}
					</div>
				{/each}
			{/if}
		{/each}
	</div>
</div>
