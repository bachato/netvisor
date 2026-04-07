<script lang="ts">
	import { entities } from '$lib/shared/stores/metadata';
	import type { Topology, TopologyNode } from '../../types/base';
	import { resolveElementNode } from '../../resolvers';

	let { topology }: { topology: Topology } = $props();

	const HostIcon = entities.getIconComponent('Host');
	const ServiceIcon = entities.getIconComponent('Service');
	const SubnetIcon = entities.getIconComponent('Subnet');
	const DependencyIcon = entities.getIconComponent('Dependency');

	const hostColor = entities.getColorHelper('Host').icon;
	const serviceColor = entities.getColorHelper('Service').icon;
	const subnetColor = entities.getColorHelper('Subnet').icon;
	const dependencyColor = entities.getColorHelper('Dependency').icon;

	let hostCount = $derived(
		new Set(
			topology.nodes
				.filter((n) => n.node_type === 'Element')
				.map((n) => resolveElementNode(n.id, n as TopologyNode, topology).hostId)
				.filter((id) => id !== undefined)
		).size
	);
	let subnetCount = $derived(topology.nodes.filter((n) => n.node_type === 'Container').length);
	let serviceCount = $derived(topology.services.length);
	let dependencyCount = $derived(
		new Set(
			topology.edges
				.filter((e) => 'dependency_id' in e)
				.map((e) => (e as { dependency_id: string }).dependency_id)
		).size
	);
	let totalCount = $derived(hostCount + serviceCount + subnetCount + dependencyCount);
</script>

{#if totalCount > 0}
	<div class="flex min-w-0 items-center gap-3 overflow-hidden">
		{#if hostCount > 0}
			<div class="flex items-center gap-1">
				<HostIcon class="h-3.5 w-3.5 flex-shrink-0 {hostColor}" />
				<span class="text-secondary text-xs">{hostCount} host{hostCount > 1 ? 's' : ''}</span>
			</div>
		{/if}
		{#if serviceCount > 0}
			<div class="flex items-center gap-1">
				<ServiceIcon class="h-3.5 w-3.5 flex-shrink-0 {serviceColor}" />
				<span class="text-secondary text-xs"
					>{serviceCount} service{serviceCount > 1 ? 's' : ''}</span
				>
			</div>
		{/if}
		{#if subnetCount > 0}
			<div class="flex items-center gap-1">
				<SubnetIcon class="h-3.5 w-3.5 flex-shrink-0 {subnetColor}" />
				<span class="text-secondary text-xs">{subnetCount} subnet{subnetCount > 1 ? 's' : ''}</span>
			</div>
		{/if}
		{#if dependencyCount > 0}
			<div class="flex items-center gap-1">
				<DependencyIcon class="h-3.5 w-3.5 flex-shrink-0 {dependencyColor}" />
				<span class="text-secondary text-xs"
					>{dependencyCount} dependenc{dependencyCount > 1 ? 'ies' : 'y'}</span
				>
			</div>
		{/if}
	</div>
{/if}
