<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import { Crosshair } from 'lucide-svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import {
		useTopologiesQuery,
		selectedTopologyId,
		autoRebuild
	} from '$lib/features/topology/queries';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getTopologyEditState } from '$lib/features/topology/state';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import { useUpdateSubnetMutation } from '$lib/features/subnets/queries';
	import { topology_focusNode } from '$lib/paraglide/messages';

	let { node }: { node: Node } = $props();

	const { fitView } = useSvelteFlow();

	function handleFocus() {
		fitView({ nodes: [{ id: node.id }], padding: 0.5, duration: 300 });
	}

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

	const updateSubnetMutation = useUpdateSubnetMutation();

	let subnet = $derived(topology ? topology.subnets.find((s) => s.id == node.id) : null);

	// Context for subnet display with description
	let subnetContext = $derived({
		showEntityTagPicker: true,
		tagPickerDisabled: !editState.isEditable,
		entityTags: isReadonly ? (topology?.entity_tags ?? []) : undefined,
		showEditableEntityDescription: true,
		entityDescription: subnet?.description ?? null,
		entityDescriptionDisabled: !editState.isEditable,
		onEntityDescriptionSave: (desc: string | null) => {
			if (subnet) {
				updateSubnetMutation.mutate({ ...subnet, description: desc });
			}
		}
	});
</script>

<div class="space-y-4">
	{#if subnet}
		<div>
			<div class="mb-2 flex items-center gap-2">
				<span class="text-secondary text-sm font-medium">This Subnet</span>
				<button class="btn-icon p-0.5" onclick={handleFocus} title={topology_focusNode()}>
					<Crosshair class="h-3.5 w-3.5" />
				</button>
			</div>
			<div class="card card-static">
				<EntityDisplayWrapper
					context={subnetContext}
					item={subnet}
					displayComponent={SubnetDisplay}
				/>
			</div>
		</div>
	{/if}
</div>
