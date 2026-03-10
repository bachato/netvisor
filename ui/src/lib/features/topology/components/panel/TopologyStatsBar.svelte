<script lang="ts">
	import { entities } from '$lib/shared/stores/metadata';
	import type { Topology } from '../../types/base';

	let { topology }: { topology: Topology } = $props();

	const HostIcon = entities.getIconComponent('Host');
	const ServiceIcon = entities.getIconComponent('Service');
	const SubnetIcon = entities.getIconComponent('Subnet');
	const GroupIcon = entities.getIconComponent('Group');

	const hostColor = entities.getColorHelper('Host').icon;
	const serviceColor = entities.getColorHelper('Service').icon;
	const subnetColor = entities.getColorHelper('Subnet').icon;
	const groupColor = entities.getColorHelper('Group').icon;

	let hostCount = $derived(
		new Set(
			topology.nodes
				.filter((n) => n.node_type === 'InterfaceNode' && 'host_id' in n)
				.map((n) => (n as { host_id: string }).host_id)
		).size
	);
	let subnetCount = $derived(topology.nodes.filter((n) => n.node_type === 'SubnetNode').length);
	let serviceCount = $derived(topology.services.length);
	let groupCount = $derived(
		new Set(
			topology.edges.filter((e) => 'group_id' in e).map((e) => (e as { group_id: string }).group_id)
		).size
	);
	let totalCount = $derived(hostCount + serviceCount + subnetCount + groupCount);
</script>

{#if totalCount > 0}
	<div class="flex items-center gap-3">
		{#if hostCount > 0}
			<div class="flex items-center gap-1">
				<HostIcon class="h-3.5 w-3.5 flex-shrink-0 {hostColor}" />
				<span class="text-secondary text-xs">{hostCount}</span>
			</div>
		{/if}
		{#if serviceCount > 0}
			<div class="flex items-center gap-1">
				<ServiceIcon class="h-3.5 w-3.5 flex-shrink-0 {serviceColor}" />
				<span class="text-secondary text-xs">{serviceCount}</span>
			</div>
		{/if}
		{#if subnetCount > 0}
			<div class="flex items-center gap-1">
				<SubnetIcon class="h-3.5 w-3.5 flex-shrink-0 {subnetColor}" />
				<span class="text-secondary text-xs">{subnetCount}</span>
			</div>
		{/if}
		{#if groupCount > 0}
			<div class="flex items-center gap-1">
				<GroupIcon class="h-3.5 w-3.5 flex-shrink-0 {groupColor}" />
				<span class="text-secondary text-xs">{groupCount}</span>
			</div>
		{/if}
	</div>
{/if}
