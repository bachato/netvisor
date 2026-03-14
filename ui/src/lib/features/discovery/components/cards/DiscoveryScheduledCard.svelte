<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { Edit, Play, Power, Trash2 } from 'lucide-svelte';
	import type { Discovery } from '../../types/base';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useSubnetsQuery } from '$lib/features/subnets/queries';
	import { formatScheduleDisplay } from '../../queries';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import { entityRef } from '$lib/shared/components/data/types';

	// Queries
	const daemonsQuery = useDaemonsQuery();
	const hostsQuery = useHostsQuery({ limit: 0 });
	const subnetsQuery = useSubnetsQuery();

	// Derived data
	let daemonsData = $derived(daemonsQuery.data ?? []);
	let hostsData = $derived(hostsQuery.data?.items ?? []);
	let subnetsData = $derived(subnetsQuery.data ?? []);

	let {
		viewMode,
		discovery,
		onEdit,
		onDelete,
		onRun,
		onToggleEnabled,
		selected,
		onSelectionChange = () => {}
	}: {
		viewMode: 'card' | 'list';
		discovery: Discovery;
		onEdit?: (discovery: Discovery) => void;
		onDelete?: (discovery: Discovery) => void;
		onRun?: (discovery: Discovery) => void;
		onToggleEnabled?: (discovery: Discovery) => void;
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	let failureCount = $derived(
		discovery.run_type.type === 'Scheduled' ? (discovery.run_type.consecutive_failures ?? 0) : 0
	);

	let failureStatus = $derived.by(() => {
		if (failureCount >= 3) {
			return {
				label: 'Auto-paused',
				color: 'Red' as const,
				title: `Automatically paused after ${failureCount} consecutive stall failures`,
				href: 'https://scanopy.net/docs/setting-up-daemons/troubleshooting-scans/auto-pause/'
			};
		}
		if (failureCount >= 1) {
			return {
				label: `${failureCount} failure${failureCount > 1 ? 's' : ''}`,
				color: 'Orange' as const,
				title: 'Will auto-pause after 3 consecutive failures',
				href: 'https://scanopy.net/docs/setting-up-daemons/troubleshooting-scans/auto-pause/'
			};
		}
		return null;
	});

	let cardData = $derived({
		title: discovery.name,
		iconColor: entities.getColorHelper('Discovery').icon,
		Icon: entities.getIconComponent('Discovery'),
		status: failureStatus,
		fields: [
			{
				label: 'Daemon',
				value: (() => {
					const daemon = daemonsData.find((d) => d.id == discovery.daemon_id);
					if (!daemon) return 'Unknown Daemon';
					return [
						{
							id: daemon.id,
							label: daemon.name,
							color: entities.getColorHelper('Daemon').color,
							entityRef: entityRef('Daemon', daemon.id, daemon, {
								hosts: hostsData,
								subnets: subnetsData
							})
						}
					];
				})()
			},
			{
				label: 'Type',
				value: discovery.discovery_type.type
			},
			{
				label: 'Schedule',
				value:
					discovery.run_type.type == 'Scheduled'
						? formatScheduleDisplay(discovery.run_type.cron_schedule, discovery.run_type.timezone)
						: 'Manual'
			},
			{
				label: 'Last Run',
				value:
					discovery.run_type.type != 'Historical' && discovery.run_type.last_run
						? formatTimestamp(discovery.run_type.last_run)
						: 'Never'
			},
			{ label: 'Tags', snippet: tagsSnippet }
		],
		actions: [
			...(onDelete
				? [{ label: 'Delete', icon: Trash2, class: `btn-icon`, onClick: () => onDelete(discovery) }]
				: []),
			...(onToggleEnabled && discovery.run_type.type === 'Scheduled'
				? [
						{
							label: discovery.run_type.enabled ? 'Disable' : 'Enable',
							icon: Power,
							class: discovery.run_type.enabled ? 'btn-icon-success' : 'btn-icon',
							onClick: () => onToggleEnabled(discovery)
						}
					]
				: []),
			...(onRun
				? [{ label: 'Run', icon: Play, class: `btn-icon`, onClick: () => onRun(discovery) }]
				: []),
			...(onEdit
				? [{ label: 'Edit', icon: Edit, class: `btn-icon`, onClick: () => onEdit(discovery) }]
				: [])
		]
	});
</script>

{#snippet tagsSnippet()}
	<div class="flex items-center gap-2">
		<span class="text-secondary text-sm">Tags:</span>
		<TagPickerInline
			selectedTagIds={discovery.tags}
			entityId={discovery.id}
			entityType="Discovery"
		/>
	</div>
{/snippet}

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
