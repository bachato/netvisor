<script lang="ts" context="module">
	import { edgeTypes } from '$lib/shared/stores/metadata';
	import type { Topology, TopologyEdge } from '$lib/features/topology/types/base';

	export const IPAddressEdgeDisplay: EntityDisplayComponent<TopologyEdge, EdgeDisplayContext> = {
		getId: (edge) => edge.id,
		getLabel: (edge, context) => {
			if (!context?.topology || !('host_id' in edge)) return 'Interface';
			const host = context.topology.hosts.find((h) => h.id === edge.host_id);
			return host?.name ?? 'Unknown Host';
		},
		getDescription: (edge, context) => {
			if (!context?.topology) return '';
			const sourceIf = context.topology.interfaces.find((i) => i.id === edge.source);
			const targetIf = context.topology.interfaces.find((i) => i.id === edge.target);
			const parts: string[] = [];
			if (sourceIf?.ip_address) parts.push(sourceIf.ip_address);
			if (targetIf?.ip_address) parts.push(targetIf.ip_address);
			return parts.join(' ↔ ') || '';
		},
		getIcon: () => edgeTypes.getIconComponent('Interface'),
		getIconColor: () => edgeTypes.getColorHelper('Interface').icon
	};

	export interface EdgeDisplayContext {
		topology?: Topology;
	}
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';

	interface Props {
		item: TopologyEdge;
		context: EdgeDisplayContext;
	}

	let { item, context }: Props = $props();
</script>

<ListSelectItem {item} {context} displayComponent={IPAddressEdgeDisplay} />
