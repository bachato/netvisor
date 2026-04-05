<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import type { Topology, TopologyNode } from '$lib/features/topology/types/base';
	import { inspector_elementSummary } from '$lib/paraglide/messages';
	import { entities } from '$lib/shared/stores/metadata';

	let {
		node,
		topology
	}: {
		node: Node;
		topology: Topology;
	} = $props();

	const { getNodes } = useSvelteFlow();

	// Count child elements and unique hosts inside this container
	let summary = $derived.by(() => {
		const allNodes = getNodes();
		const children = allNodes.filter((n) => n.type === 'Element' && n.parentId === node.id);
		const hostIds = new Set<string>();
		const serviceIds = new Set<string>();
		for (const child of children) {
			const data = child.data as TopologyNode | undefined;
			if (data && 'host_id' in data && data.host_id) {
				hostIds.add(data.host_id as string);
			}
			if (data && data.element_type === 'Service') {
				serviceIds.add(child.id);
			}
		}
		return {
			elementCount: children.length,
			hostCount: hostIds.size,
			serviceCount: serviceIds.size,
			hasServices: serviceIds.size > 0
		};
	});

	let hostLabel = $derived(entities.getName('Host'));
	let serviceLabel = $derived(entities.getName('Service'));
	let interfaceLabel = $derived(entities.getName('Interface'));
</script>

<div>
	<span class="text-secondary mb-2 block text-sm font-medium">{inspector_elementSummary()}</span>
	<div class="card card-static space-y-1 text-sm">
		{#if summary.hasServices}
			<div class="flex justify-between">
				<span class="text-tertiary">{serviceLabel}s</span>
				<span class="text-primary">{summary.serviceCount}</span>
			</div>
		{:else}
			<div class="flex justify-between">
				<span class="text-tertiary">{hostLabel}s</span>
				<span class="text-primary">{summary.hostCount}</span>
			</div>
			<div class="flex justify-between">
				<span class="text-tertiary">{interfaceLabel}s</span>
				<span class="text-primary">{summary.elementCount}</span>
			</div>
		{/if}
	</div>
</div>
