<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import { inspector_elementSummary, inspector_elementCount } from '$lib/paraglide/messages';

	let {
		node,
		topology
	}: {
		node: Node;
		topology: Topology;
	} = $props();

	const { getNodes } = useSvelteFlow();

	// Count child element nodes inside this container
	let elementCount = $derived.by(() => {
		const allNodes = getNodes();
		return allNodes.filter((n) => n.type === 'Element' && n.parentId === node.id).length;
	});
</script>

<div>
	<span class="text-secondary mb-2 block text-sm font-medium">{inspector_elementSummary()}</span>
	<div class="card card-static text-sm">
		<span class="text-primary">{inspector_elementCount({ count: elementCount })}</span>
	</div>
</div>
