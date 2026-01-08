<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import type { Service } from '../types/base';
	import ServiceCard from './ServiceCard.svelte';
	import { matchConfidenceLabel } from '$lib/shared/types';
	import ServiceEditModal from './ServiceEditModal.svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		useServicesQuery,
		useUpdateServiceMutation,
		useDeleteServiceMutation,
		useBulkDeleteServicesMutation
	} from '../queries';
	import { useHostsByIds } from '$lib/features/hosts/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';
	import type { TabProps } from '$lib/shared/types';

	let { isReadOnly = false }: TabProps = $props();

	// Pagination state
	const PAGE_SIZE = 20;
	let currentPage = $state(1);

	// Queries
	const tagsQuery = useTagsQuery();
	// Paginated services with server-side pagination
	const servicesQuery = useServicesQuery(() => ({
		limit: PAGE_SIZE,
		offset: (currentPage - 1) * PAGE_SIZE
	}));
	const networksQuery = useNetworksQuery();

	// Selective host lookup - only fetches hosts needed for service display
	// Extract host IDs from visible services for host name display
	const hostsQuery = useHostsByIds(() => {
		return (servicesQuery.data?.items ?? [])
			.filter((s) => s.host_id)
			.map((s) => s.host_id)
			.filter((id, idx, arr) => arr.indexOf(id) === idx);
	});

	// Mutations
	const updateServiceMutation = useUpdateServiceMutation();
	const deleteServiceMutation = useDeleteServiceMutation();
	const bulkDeleteServicesMutation = useBulkDeleteServicesMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let servicesData = $derived(servicesQuery.data?.items ?? []);
	let servicesPagination = $derived(servicesQuery.data?.pagination ?? null);
	let hostsData = $derived(hostsQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	// Only show full loading on initial load (no data yet)
	let isInitialLoading = $derived(servicesQuery.isPending && !servicesQuery.data);

	// Page change handler for server-side pagination
	function handlePageChange(page: number) {
		currentPage = page;
	}

	let showServiceEditor = $state(false);
	let editingService = $state<Service | null>(null);

	function handleEditService(service: Service) {
		editingService = service;
		showServiceEditor = true;
	}
	function handleCloseServiceEditor() {
		showServiceEditor = false;
		editingService = null;
	}

	let serviceHosts = $derived(
		new Map(
			servicesData.map((service) => {
				const foundHost = hostsData.find((h) => {
					return h.id == service.host_id;
				});

				return [service.id, foundHost];
			})
		)
	);

	function handleDeleteService(service: Service) {
		if (confirm(`Are you sure you want to delete "${service.name}"?`)) {
			deleteServiceMutation.mutate(service.id);
		}
	}

	async function handleServiceUpdate(id: string, data: Service) {
		try {
			await updateServiceMutation.mutateAsync(data);
			showServiceEditor = false;
			editingService = null;
		} catch {
			// Error handled by mutation
		}
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Services?`)) {
			await bulkDeleteServicesMutation.mutateAsync(ids);
		}
	}

	function getServiceTags(service: Service): string[] {
		return service.tags;
	}

	// Define field configuration for the DataTableControls
	const serviceFields: FieldConfig<Service>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
		{
			key: 'host',
			label: 'Host',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (service) => serviceHosts.get(service.id)?.name || 'Unknown Host'
		},
		{
			key: 'created_at',
			label: 'Created',
			type: 'date',
			searchable: false,
			filterable: false,
			sortable: true
		},
		{
			key: 'network_id',
			type: 'string',
			label: 'Network',
			searchable: false,
			filterable: true,
			sortable: false,
			getValue(item) {
				return networksData.find((n) => n.id == item.network_id)?.name || 'Unknown Network';
			}
		},
		{
			key: 'containerized_by',
			type: 'string',
			label: 'Containerized',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue(item) {
				return (
					servicesData.find((s) => s.id == item.virtualization?.details.service_id)?.name ||
					'Not Containerized'
				);
			}
		},
		{
			key: 'confidence',
			label: 'Match Confidence',
			type: 'string',
			searchable: false,
			filterable: true,
			sortable: true,
			getValue(item) {
				return item.source.type == 'DiscoveryWithMatch'
					? matchConfidenceLabel(item.source.details.confidence)
					: 'N/A (Not a discovered service)';
			}
		},
		{
			key: 'tags',
			label: 'Tags',
			type: 'array',
			searchable: true,
			filterable: true,
			sortable: false,
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
	<TabHeader title="Services" subtitle="To create a service, add it to a host in the Hosts tab." />

	<!-- Loading state (only on initial load) -->
	{#if isInitialLoading}
		<Loading />
	{:else if servicesData.length === 0 && !servicesPagination}
		<!-- Empty state -->
		<EmptyState title="No services configured yet" subtitle="" />
	{:else}
		<DataControls
			items={servicesData}
			fields={serviceFields}
			storageKey="scanopy-services-table-state"
			onBulkDelete={isReadOnly ? undefined : handleBulkDelete}
			entityType={isReadOnly ? undefined : 'Service'}
			getItemTags={getServiceTags}
			getItemId={(item) => item.id}
			serverPagination={servicesPagination}
			onPageChange={handlePageChange}
		>
			{#snippet children(
				item: Service,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				{@const host = serviceHosts.get(item.id)}
				{#if host}
					<ServiceCard
						service={item}
						selected={isSelected}
						{host}
						{onSelectionChange}
						{viewMode}
						onDelete={isReadOnly ? undefined : handleDeleteService}
						onEdit={isReadOnly ? undefined : handleEditService}
					/>
				{/if}
			{/snippet}
		</DataControls>
	{/if}
</div>

{#if editingService}
	{@const editingServiceHost = serviceHosts.get(editingService.id)}
	{#if editingServiceHost}
		<ServiceEditModal
			service={editingService}
			host={editingServiceHost}
			isOpen={showServiceEditor}
			onUpdate={handleServiceUpdate}
			onClose={handleCloseServiceEditor}
		/>
	{/if}
{/if}
