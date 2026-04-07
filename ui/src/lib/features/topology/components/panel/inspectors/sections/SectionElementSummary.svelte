<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContainerContents } from '$lib/features/topology/resolvers';
	import { views } from '$lib/shared/stores/metadata';
	import { activeView } from '$lib/features/topology/queries';
	import { inspector_elementSummary, common_services, common_hosts } from '$lib/paraglide/messages';

	/* eslint-disable @typescript-eslint/no-unused-vars -- component contract props */
	let {
		node,
		topology
	}: {
		node: Node;
		topology: Topology;
	} = $props();
	/* eslint-enable @typescript-eslint/no-unused-vars */

	const { getNodes } = useSvelteFlow();

	let elementLabel = $derived(
		(views.getMetadata($activeView) as { element_label?: string } | undefined)?.element_label ??
			'elements'
	);

	// Count child elements and unique hosts inside this container (including subcontainers)
	let summary = $derived.by(() => {
		const contents = getContainerContents(node.id, getNodes());
		return {
			elementCount: contents.elementNodeIds.size,
			hostCount: contents.hostIds.size,
			serviceCount: contents.serviceIds.size,
			hasServices: contents.serviceIds.size > 0
		};
	});
</script>

<div>
	<span class="text-secondary mb-2 block text-sm font-medium">{inspector_elementSummary()}</span>
	<div class="card card-static space-y-1 text-sm">
		<div class="flex justify-between">
			<span class="text-tertiary capitalize">{elementLabel}</span>
			<span class="text-primary">{summary.elementCount}</span>
		</div>
		{#if summary.hostCount > 0}
			<div class="flex justify-between">
				<span class="text-tertiary">{common_hosts()}</span>
				<span class="text-primary">{summary.hostCount}</span>
			</div>
		{/if}
		{#if summary.hasServices}
			<div class="flex justify-between">
				<span class="text-tertiary">{common_services()}</span>
				<span class="text-primary">{summary.serviceCount}</span>
			</div>
		{/if}
	</div>
</div>
