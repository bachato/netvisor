<script lang="ts" context="module">
	import { edgeTypes, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Topology, TopologyEdge } from '$lib/features/topology/types/base';

	export const ServiceVirtualizationEdgeDisplay: EntityDisplayComponent<
		TopologyEdge,
		EdgeDisplayContext
	> = {
		getId: (edge) => edge.id,
		getLabel: (edge, context) => {
			if (!context?.topology || !('containerizing_service_id' in edge))
				return 'Service Virtualization';
			// Find containerized services (services whose virtualization points to this containerizer)
			const containerizingId = edge.containerizing_service_id;
			const containerized = context.topology.services.filter(
				(s) =>
					s.virtualization &&
					s.virtualization.type === 'Docker' &&
					s.virtualization.details.service_id === containerizingId
			);
			if (containerized.length === 0) return 'Service Virtualization';
			if (containerized.length === 1) return containerized[0].name;
			return `${containerized.length} containerized services`;
		},
		getDescription: (edge, context) => {
			if (!context?.topology || !('containerizing_service_id' in edge)) return '';
			const containerizer = context.topology.services.find(
				(s) => s.id === edge.containerizing_service_id
			);
			const host =
				'host_id' in edge ? context.topology.hosts.find((h) => h.id === edge.host_id) : null;
			const parts: string[] = [];
			if (containerizer) parts.push(containerizer.name);
			if (host) parts.push(host.name);
			return parts.join(' · ');
		},
		getIcon: () => edgeTypes.getIconComponent('ServiceVirtualization'),
		getIconColor: () => edgeTypes.getColorHelper('ServiceVirtualization').icon,
		getTags: (edge, context) => {
			if (!context?.topology || !('containerizing_service_id' in edge)) return [];
			const containerizer = context.topology.services.find(
				(s) => s.id === edge.containerizing_service_id
			);
			if (!containerizer) return [];
			const defName = serviceDefinitions.getName(containerizer.service_definition);
			return defName
				? [{ label: defName, color: edgeTypes.getColorHelper('ServiceVirtualization').color }]
				: [];
		}
	};

	export interface EdgeDisplayContext {
		topology?: Topology;
	}
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import type { TagProps } from '$lib/shared/components/data/types';
	import ListSelectItem from '../ListSelectItem.svelte';

	interface Props {
		item: TopologyEdge;
		context: EdgeDisplayContext;
	}

	let { item, context }: Props = $props();
</script>

<ListSelectItem {item} {context} displayComponent={ServiceVirtualizationEdgeDisplay} />
