<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { Discovery } from '../../types/base';
	import { discoveryFields } from '../../queries';
	import DiscoveryEditModal from '../DiscoveryModal/DiscoveryEditModal.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import DiscoveryHistoryCard from '../cards/DiscoveryHistoryCard.svelte';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import {
		useDiscoveriesQuery,
		useCreateDiscoveryMutation,
		useUpdateDiscoveryMutation,
		useBulkDeleteDiscoveriesMutation
	} from '../../queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import type { TabProps } from '$lib/shared/types';
	import { downloadCsv } from '$lib/shared/utils/csvExport';
	import {
		common_duration,
		common_unknown,
		discovery_confirmDeleteHistorical,
		discovery_finishedAt,
		discovery_historyTitle,
		discovery_noHistorySessions,
		discovery_startedAt
	} from '$lib/paraglide/messages';

	let { isReadOnly = false }: TabProps = $props();

	// Queries
	const discoveriesQuery = useDiscoveriesQuery();
	const daemonsQuery = useDaemonsQuery();
	// Use limit: 0 to get all hosts for modal dropdown
	const hostsQuery = useHostsQuery({ limit: 0 });

	// Mutations
	const createDiscoveryMutation = useCreateDiscoveryMutation();
	const updateDiscoveryMutation = useUpdateDiscoveryMutation();
	const bulkDeleteDiscoveriesMutation = useBulkDeleteDiscoveriesMutation();

	// Derived data
	let discoveriesData = $derived(discoveriesQuery.data ?? []);
	let daemonsData = $derived(daemonsQuery.data ?? []);
	let hostsData = $derived(hostsQuery.data?.items ?? []);
	let isLoading = $derived(
		discoveriesQuery.isPending || daemonsQuery.isPending || hostsQuery.isPending
	);

	let showDiscoveryModal = $state(false);
	let editingDiscovery: Discovery | null = $state(null);

	function handleEditDiscovery(discovery: Discovery) {
		editingDiscovery = discovery;
		showDiscoveryModal = true;
	}

	async function handleDiscoveryCreate(data: Discovery) {
		await createDiscoveryMutation.mutateAsync(data);
		showDiscoveryModal = false;
		editingDiscovery = null;
	}

	async function handleDiscoveryUpdate(id: string, data: Discovery) {
		await updateDiscoveryMutation.mutateAsync(data);
		showDiscoveryModal = false;
		editingDiscovery = null;
	}

	function handleCloseEditor() {
		showDiscoveryModal = false;
		editingDiscovery = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(discovery_confirmDeleteHistorical({ count: ids.length }))) {
			await bulkDeleteDiscoveriesMutation.mutateAsync(ids);
		}
	}

	// CSV export handler
	async function handleCsvExport() {
		await downloadCsv('Discovery', {});
	}

	let fields: FieldConfig<Discovery>[] = $derived([
		...discoveryFields(daemonsData),
		{
			key: 'started_at',
			label: discovery_startedAt(),
			type: 'string',
			searchable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				return results && results.started_at
					? formatTimestamp(results.started_at)
					: common_unknown();
			}
		},
		{
			key: 'finished_at',
			label: discovery_finishedAt(),
			type: 'string',
			searchable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				return results && results.finished_at
					? formatTimestamp(results.finished_at)
					: common_unknown();
			}
		},
		{
			key: 'duration',
			label: common_duration(),
			type: 'string',
			searchable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				if (results && results.finished_at && results.started_at) {
					return formatDuration(results.started_at, results.finished_at);
				}
				return common_unknown();
			}
		}
	]);
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title={discovery_historyTitle()} />

	{#if isLoading}
		<Loading />
	{:else if discoveriesData.length === 0}
		<!-- Empty state -->
		<EmptyState title={discovery_noHistorySessions()} subtitle="" />
	{:else}
		<DataControls
			items={discoveriesData.filter((d) => d.run_type.type == 'Historical')}
			{fields}
			onBulkDelete={isReadOnly ? undefined : handleBulkDelete}
			storageKey="scanopy-discovery-historical-table-state"
			getItemId={(item) => item.id}
			onCsvExport={handleCsvExport}
		>
			{#snippet children(
				item: Discovery,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<DiscoveryHistoryCard
					discovery={item}
					onView={handleEditDiscovery}
					{viewMode}
					selected={isSelected}
					{onSelectionChange}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<DiscoveryEditModal
	isOpen={showDiscoveryModal}
	hosts={hostsData}
	daemons={daemonsData}
	discovery={editingDiscovery}
	onCreate={handleDiscoveryCreate}
	onUpdate={handleDiscoveryUpdate}
	onClose={handleCloseEditor}
/>
