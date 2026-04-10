<script lang="ts">
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import { useTopologiesQuery, selectedTopologyId } from '$lib/features/topology/queries';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import Tag from '$lib/shared/components/data/Tag.svelte';

	let {
		sourceEntityId,
		targetEntityId,
		protocol
	}: {
		sourceEntityId?: string;
		targetEntityId?: string;
		protocol?: 'LLDP' | 'CDP';
	} = $props();

	// Try to get topology from context (for share/embed pages), fallback to query + selected topology
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext ? $topologyContext : topologiesData.find((t) => t.id === $selectedTopologyId)
	);

	// Derive Interface and Host data
	let sourceInterface = $derived(topology?.interfaces.find((e) => e.id === sourceEntityId));
	let targetInterface = $derived(topology?.interfaces.find((e) => e.id === targetEntityId));
	let sourceHost = $derived(
		sourceInterface ? topology?.hosts.find((h) => h.id === sourceInterface.host_id) : null
	);
	let targetHost = $derived(
		targetInterface ? topology?.hosts.find((h) => h.id === targetInterface.host_id) : null
	);
</script>

<div class="space-y-3">
	{#if protocol}
		<div class="flex items-center gap-2">
			<Tag label={protocol} color={protocol == 'CDP' ? 'Blue' : 'Green'} />
		</div>
	{/if}

	{#if sourceHost || sourceInterface}
		<span class="text-secondary mb-2 block text-sm font-medium">Source</span>
		{#if sourceHost}
			<div class="card card-static">
				<EntityDisplayWrapper
					context={{
						services: topology?.services.filter((s) => s.host_id === sourceHost.id) ?? []
					}}
					item={sourceHost}
					displayComponent={HostDisplay}
				/>
			</div>
		{/if}
		{#if sourceInterface}
			<div class="card card-static">
				<EntityDisplayWrapper
					context={undefined}
					item={sourceInterface}
					displayComponent={InterfaceDisplay}
				/>
			</div>
		{/if}
	{/if}

	{#if targetHost || targetInterface}
		<span class="text-secondary mb-2 block text-sm font-medium">Target</span>
		{#if targetHost}
			<div class="card card-static">
				<EntityDisplayWrapper
					context={{
						services: topology?.services.filter((s) => s.host_id === targetHost.id) ?? []
					}}
					item={targetHost}
					displayComponent={HostDisplay}
				/>
			</div>
		{/if}
		{#if targetInterface}
			<div class="card card-static">
				<EntityDisplayWrapper
					context={undefined}
					item={targetInterface}
					displayComponent={InterfaceDisplay}
				/>
			</div>
		{/if}
	{/if}
</div>
