<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import InspectorLeafNode from './nodes/InspectorLeafNode.svelte';
	import InspectorContainerNode from './nodes/InspectorContainerNode.svelte';

	let { node }: { node: Node } = $props();

	let isInterfaceNode = $derived(node.type === 'LeafNode');
	let isSubnetNode = $derived(node.type === 'ContainerNode');
</script>

<div class="w-full space-y-4">
	{#if isInterfaceNode}
		<InspectorLeafNode {node} />
	{:else if isSubnetNode}
		<InspectorContainerNode {node} />
	{:else}
		<div class="space-y-3">
			<p class="text-tertiary text-sm">Unable to display node details</p>
		</div>
	{/if}
</div>
