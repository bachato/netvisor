<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import { useTopologiesQuery, selectedTopologyId } from '$lib/features/topology/queries';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import { subnetTypes } from '$lib/shared/stores/metadata';
	import OptionToggle from '../../options/OptionToggle.svelte';
	import OptionsCard from '../../options/OptionsCard.svelte';
	import {
		topology_showGatewayInLeftZone,
		topology_showGatewayInLeftZoneHelp,
		topology_groupDockerBridges,
		topology_groupDockerBridgesHelp
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

	let isContainerSubnet = $derived(
		subnet ? subnetTypes.getMetadata(subnet.subnet_type).is_for_containers : false
	);
</script>

<div class="space-y-4">
	<OptionsCard>
		<OptionToggle
			label={topology_showGatewayInLeftZone()}
			helpText={topology_showGatewayInLeftZoneHelp()}
			path="request"
			optionKey="show_gateway_in_left_zone"
		/>
		{#if isContainerSubnet}
			<OptionToggle
				label={topology_groupDockerBridges()}
				helpText={topology_groupDockerBridgesHelp()}
				path="request"
				optionKey="group_docker_bridges_by_host"
			/>
		{/if}
	</OptionsCard>

	{#if subnet}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">Subnet</span>
			<div class="card card-static">
				<EntityDisplayWrapper context={{}} item={subnet} displayComponent={SubnetDisplay} />
			</div>
		</div>
	{/if}
</div>
