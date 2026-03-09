<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import {
		useTopologiesQuery,
		selectedTopologyId,
		topologyOptions,
		selectedNode,
		selectedEdge
	} from '$lib/features/topology/queries';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import { subnetTypes } from '$lib/shared/stores/metadata';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import { Settings } from 'lucide-svelte';
	import {
		topology_showGatewayInLeftZone,
		topology_groupDockerBridges
	} from '$lib/paraglide/messages';

	let { node }: { node: Node } = $props();

	// Try to get topology from context (for share/embed pages), fallback to query + selected topology
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext ? $topologyContext : topologiesData.find((t) => t.id === $selectedTopologyId)
	);

	let subnet = $derived(topology ? topology.subnets.find((s) => s.id == node.id) : null);

	// Contextual hint state
	let isGatewayInLeftZone = $derived($topologyOptions.request.show_gateway_in_left_zone);
	let isGrouped = $derived($topologyOptions.request.group_docker_bridges_by_host);
	let isContainerSubnet = $derived(
		subnet ? subnetTypes.getMetadata(subnet.subnet_type).is_for_containers : false
	);

	function deselect() {
		selectedNode.set(null);
		selectedEdge.set(null);
	}
</script>

<div class="space-y-4">
	{#if subnet}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">Subnet</span>
			<div class="card card-static">
				<EntityDisplayWrapper context={{}} item={subnet} displayComponent={SubnetDisplay} />
			</div>
		</div>
	{/if}

	<!-- Contextual setting hints -->
	<div class="flex flex-wrap gap-1 pt-2">
		<button onclick={deselect} title="Open settings">
			<Tag
				label={topology_showGatewayInLeftZone()}
				color={isGatewayInLeftZone ? 'Blue' : null}
				disabled={!isGatewayInLeftZone}
				pill
				icon={Settings}
			/>
		</button>
		{#if isContainerSubnet}
			<button onclick={deselect} title="Open settings">
				<Tag
					label={topology_groupDockerBridges()}
					color={isGrouped ? 'Blue' : null}
					disabled={!isGrouped}
					pill
					icon={Settings}
				/>
			</button>
		{/if}
	</div>
</div>
