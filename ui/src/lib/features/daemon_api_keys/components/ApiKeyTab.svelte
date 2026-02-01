<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import CreateApiKeyModal from './ApiKeyModal.svelte';
	import type { ApiKey } from '../types/base';
	import ApiKeyCard from './ApiKeyCard.svelte';
	import { Plus } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		useApiKeysQuery,
		useUpdateApiKeyMutation,
		useDeleteApiKeyMutation,
		useBulkDeleteApiKeysMutation
	} from '../queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import type { TabProps } from '$lib/shared/types';
	import { downloadCsv } from '$lib/shared/utils/csvExport';
	import {
		common_create,
		common_name,
		common_network,
		common_tags,
		common_unknownNetwork,
		daemonApiKeys_confirmBulkDelete,
		daemonApiKeys_confirmDelete,
		daemonApiKeys_noApiKeysYet,
		daemonApiKeys_title
	} from '$lib/paraglide/messages';

	let { isReadOnly = false }: TabProps = $props();

	// Queries
	const tagsQuery = useTagsQuery();
	const apiKeysQuery = useApiKeysQuery();
	const networksQuery = useNetworksQuery();
	// Daemons query to ensure data is loaded (needed for API key display)
	useDaemonsQuery();

	// Mutations
	const updateApiKeyMutation = useUpdateApiKeyMutation();
	const deleteApiKeyMutation = useDeleteApiKeyMutation();
	const bulkDeleteApiKeysMutation = useBulkDeleteApiKeysMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let apiKeysData = $derived(apiKeysQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let isLoading = $derived(apiKeysQuery.isPending);

	let showCreateApiKeyModal = $state(false);
	let editingApiKey = $state<ApiKey | null>(null);

	async function handleDeleteApiKey(apiKey: ApiKey) {
		if (confirm(daemonApiKeys_confirmDelete({ name: apiKey.name }))) {
			deleteApiKeyMutation.mutate(apiKey.id);
		}
	}

	async function handleUpdateApiKey(apiKey: ApiKey) {
		await updateApiKeyMutation.mutateAsync(apiKey);
		showCreateApiKeyModal = false;
		editingApiKey = null;
	}

	function handleCreateApiKey() {
		showCreateApiKeyModal = true;
		editingApiKey = null;
	}

	function handleCloseCreateApiKey() {
		showCreateApiKeyModal = false;
		editingApiKey = null;
	}

	function handleEditApiKey(apiKey: ApiKey) {
		showCreateApiKeyModal = true;
		editingApiKey = apiKey;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(daemonApiKeys_confirmBulkDelete({ count: ids.length }))) {
			await bulkDeleteApiKeysMutation.mutateAsync(ids);
		}
	}

	function getApiKeyTags(apiKey: ApiKey): string[] {
		return apiKey.tags;
	}

	// CSV export handler
	async function handleCsvExport() {
		await downloadCsv('DaemonApiKey', {});
	}

	const apiKeyFields: FieldConfig<ApiKey>[] = [
		{
			key: 'name',
			label: common_name(),
			type: 'string',
			searchable: true
		},
		{
			key: 'network_id',
			type: 'string',
			label: common_network(),
			filterable: true,
			getValue(item) {
				return networksData.find((n) => n.id == item.network_id)?.name || common_unknownNetwork();
			}
		},
		{
			key: 'tags',
			label: common_tags(),
			type: 'array',
			searchable: true,
			filterable: true,
			getValue: (entity) => {
				// Return tag names for search/filter display
				return entity.tags
					.map((id) => tagsData.find((t) => t.id === id)?.name)
					.filter((name): name is string => !!name);
			}
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title={daemonApiKeys_title()}>
		<svelte:fragment slot="actions">
			{#if !isReadOnly}
				<button class="btn-primary flex items-center" onclick={handleCreateApiKey}
					><Plus class="h-5 w-5" />{common_create()}</button
				>
			{/if}
		</svelte:fragment>
	</TabHeader>
	<!-- Loading state -->
	{#if isLoading}
		<Loading />
	{:else if apiKeysData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title={daemonApiKeys_noApiKeysYet()}
			subtitle=""
			onClick={handleCreateApiKey}
			cta={common_create()}
		/>
	{:else}
		<DataControls
			items={apiKeysData}
			fields={apiKeyFields}
			onBulkDelete={isReadOnly ? undefined : handleBulkDelete}
			entityType={isReadOnly ? undefined : 'DaemonApiKey'}
			getItemTags={getApiKeyTags}
			storageKey="scanopy-api-keys-table-state"
			getItemId={(item) => item.id}
			onCsvExport={handleCsvExport}
		>
			{#snippet children(
				item: ApiKey,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<ApiKeyCard
					apiKey={item}
					{viewMode}
					selected={isSelected}
					{onSelectionChange}
					onDelete={isReadOnly ? undefined : handleDeleteApiKey}
					onEdit={isReadOnly ? undefined : handleEditApiKey}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<CreateApiKeyModal
	isOpen={showCreateApiKeyModal}
	onClose={handleCloseCreateApiKey}
	onUpdate={handleUpdateApiKey}
	apiKey={editingApiKey}
/>
