<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { toColor } from '$lib/shared/utils/styling';
	import { Info } from 'lucide-svelte';
	import type { Discovery } from '../../types/base';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';
	import type { TagProps } from '$lib/shared/components/data/types';

	// Queries
	const daemonsQuery = useDaemonsQuery();
	const networksQuery = useNetworksQuery();

	// Derived data
	let daemonsData = $derived(daemonsQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);

	let {
		viewMode,
		discovery,
		onView = () => {},
		selected,
		onSelectionChange = () => {}
	}: {
		viewMode: 'card' | 'list';
		discovery: Discovery;
		onView?: (discovery: Discovery) => void;
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	let results = $derived(
		discovery.run_type.type == 'Historical' ? discovery.run_type.results : null
	);

	let status = $derived.by((): TagProps | null => {
		const phase = results?.phase ?? null;
		if (!phase) return null;
		switch (phase) {
			case 'Complete':
				return { label: 'Complete', color: toColor('green') };
			case 'Failed':
				return { label: 'Failed', color: toColor('red') };
			case 'Cancelled':
				return { label: 'Cancelled', color: toColor('yellow') };
			default:
				return { label: phase, color: toColor('blue') };
		}
	});

	let cardData = $derived({
		title: discovery.name,
		iconColor: entities.getColorHelper('Discovery').icon,
		Icon: entities.getIconComponent('Discovery'),
		status,
		fields: [
			{
				label: 'Network',
				value: networksData.find((n) => n.id == discovery.network_id)?.name || 'Unknown Network'
			},
			{
				label: 'Daemon',
				value: daemonsData.find((d) => d.id == discovery.daemon_id)?.name || 'Unknown Daemon'
			},
			{
				label: 'Started',
				value: results && results.started_at ? formatTimestamp(results.started_at) : 'Unknown'
			},
			{
				label: 'Finished',
				value: results && results.finished_at ? formatTimestamp(results.finished_at) : 'Unknown'
			},
			{
				label: 'Duration',
				value: (() => {
					const results =
						discovery.run_type.type == 'Historical' ? discovery.run_type.results : null;
					if (results && results.finished_at && results.started_at) {
						return formatDuration(results.started_at, results.finished_at);
					}
					return 'Unknown';
				})()
			}
		],
		actions: [
			{
				label: 'Details',
				icon: Info,
				class: `btn-icon`,
				onClick: () => onView(discovery)
			}
		]
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
