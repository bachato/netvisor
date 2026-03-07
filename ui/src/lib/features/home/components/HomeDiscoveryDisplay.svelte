<script lang="ts" module>
	import { entities } from '$lib/shared/stores/metadata';
	import { toColor } from '$lib/shared/utils/styling';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import type { Discovery } from '$lib/features/discovery/types/base';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import type { components } from '$lib/api/schema';

	type NetworkSummary = components['schemas']['NetworkSummary'];

	export interface HomeDiscoveryContext {
		daemons: Daemon[];
		networks: NetworkSummary[];
	}

	export const HomeDiscoveryDisplay: EntityDisplayComponent<Discovery, HomeDiscoveryContext> = {
		getId: (discovery) => discovery.id,
		getLabel: (discovery, context) => {
			// New records already have enriched names ("Type — Network").
			// Old records missing the separator get enriched client-side.
			if (discovery.name.includes(' \u2014 ')) return discovery.name;
			const network = context?.networks.find((n) => n.id === discovery.network_id);
			if (network) return `${discovery.name} \u2014 ${network.name}`;
			return discovery.name;
		},
		getDescription: (discovery, context) => {
			const daemon = context.daemons.find((d) => d.id === discovery.daemon_id);
			const daemonName = daemon?.name ?? 'Unknown Daemon';
			return `${daemonName} \u00b7 ${formatTimestamp(discovery.created_at)}`;
		},
		getIcon: () => entities.getIconComponent('Discovery'),
		getIconColor: () => entities.getColorHelper('Discovery').icon,
		getTags: (discovery) => {
			const phase =
				discovery.run_type.type === 'Historical' && discovery.run_type.results
					? (discovery.run_type.results.phase ?? null)
					: null;

			if (!phase) return [];

			switch (phase) {
				case 'Complete':
					return [{ label: 'Complete', color: toColor('green') }];
				case 'Failed':
					return [{ label: 'Failed', color: toColor('red') }];
				case 'Cancelled':
					return [{ label: 'Cancelled', color: toColor('yellow') }];
				default:
					return [{ label: phase, color: toColor('blue') }];
			}
		}
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '$lib/shared/components/forms/selection/types';
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';

	let {
		item,
		context = { daemons: [], networks: [] }
	}: { item: Discovery; context?: HomeDiscoveryContext } = $props();
</script>

<ListSelectItem {item} {context} displayComponent={HomeDiscoveryDisplay} />
