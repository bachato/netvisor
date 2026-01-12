<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import type { Group } from '../types/base';
	import GroupCard from './GroupCard.svelte';
	import GroupEditModal from './GroupEditModal/GroupEditModal.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import { defineFields } from '$lib/shared/components/data/types';
	import { Plus } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		useGroupsQuery,
		useCreateGroupMutation,
		useUpdateGroupMutation,
		useDeleteGroupMutation,
		useBulkDeleteGroupsMutation
	} from '../queries';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';
	import type { TabProps } from '$lib/shared/types';
	import type { components } from '$lib/api/schema';

	type GroupOrderField = components['schemas']['GroupOrderField'];

	let { isReadOnly = false }: TabProps = $props();

	// Queries
	const tagsQuery = useTagsQuery();
	const groupsQuery = useGroupsQuery();
	const networksQuery = useNetworksQuery();
	useServicesQuery();

	// Mutations
	const createGroupMutation = useCreateGroupMutation();
	const updateGroupMutation = useUpdateGroupMutation();
	const deleteGroupMutation = useDeleteGroupMutation();
	const bulkDeleteGroupsMutation = useBulkDeleteGroupsMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let groupsData = $derived(groupsQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let isLoading = $derived(groupsQuery.isPending);

	let showGroupEditor = $state(false);
	let editingGroup = $state<Group | null>(null);

	function handleCreateGroup() {
		editingGroup = null;
		showGroupEditor = true;
	}

	function handleEditGroup(group: Group) {
		editingGroup = group;
		showGroupEditor = true;
	}

	function handleDeleteGroup(group: Group) {
		if (confirm(`Are you sure you want to delete "${group.name}"?`)) {
			deleteGroupMutation.mutate(group.id);
		}
	}

	async function handleGroupCreate(data: Group) {
		try {
			await createGroupMutation.mutateAsync(data);
			showGroupEditor = false;
			editingGroup = null;
		} catch {
			// Error handled by mutation
		}
	}

	async function handleGroupUpdate(id: string, data: Group) {
		try {
			await updateGroupMutation.mutateAsync(data);
			showGroupEditor = false;
			editingGroup = null;
		} catch {
			// Error handled by mutation
		}
	}

	function handleCloseGroupEditor() {
		showGroupEditor = false;
		editingGroup = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Groups?`)) {
			await bulkDeleteGroupsMutation.mutateAsync(ids);
		}
	}

	function getGroupTags(group: Group): string[] {
		return group.tags;
	}

	// Define field configuration for the DataTableControls
	// Uses defineFields to ensure all GroupOrderField values are covered
	let groupFields = $derived(
		defineFields<Group, GroupOrderField>(
			{
				name: { label: 'Name', type: 'string', searchable: true },
				group_type: { label: 'Group Type', type: 'string', searchable: true, filterable: true },
				network_id: {
					label: 'Network',
					type: 'string',
					filterable: true,
					groupable: true,
					getValue: (item) =>
						networksData.find((n) => n.id == item.network_id)?.name || 'Unknown Network'
				},
				created_at: { label: 'Created', type: 'date' },
				updated_at: { label: 'Updated', type: 'date' }
			},
			[
				{ key: 'description', label: 'Description', type: 'string', searchable: true },
				{
					key: 'tags',
					label: 'Tags',
					type: 'array',
					searchable: true,
					filterable: true,
					getValue: (entity) =>
						entity.tags
							.map((id) => tagsData.find((t) => t.id === id)?.name)
							.filter((name): name is string => !!name)
				}
			]
		)
	);
</script>

<div class="space-y-6">
	<TabHeader title="Groups" subtitle="Create custom groups to improve topology visualization">
		<svelte:fragment slot="actions">
			{#if !isReadOnly}
				<button class="btn-primary flex items-center" onclick={handleCreateGroup}
					><Plus class="h-5 w-5" />Create Group</button
				>
			{/if}
		</svelte:fragment>
	</TabHeader>

	{#if isLoading}
		<Loading />
	{:else if groupsData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No groups configured yet"
			subtitle="Groups define clusters or paths of nodes for visualization"
			onClick={handleCreateGroup}
			cta="Create your first group"
		/>
	{:else}
		<DataControls
			items={groupsData}
			fields={groupFields}
			storageKey="scanopy-groups-table-state"
			onBulkDelete={isReadOnly ? undefined : handleBulkDelete}
			entityType={isReadOnly ? undefined : 'Group'}
			getItemTags={getGroupTags}
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Group,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<GroupCard
					group={item}
					selected={isSelected}
					{onSelectionChange}
					{viewMode}
					onEdit={isReadOnly ? undefined : () => handleEditGroup(item)}
					onDelete={isReadOnly ? undefined : () => handleDeleteGroup(item)}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<!-- Modal -->
<GroupEditModal
	isOpen={showGroupEditor}
	group={editingGroup}
	onCreate={handleGroupCreate}
	onUpdate={handleGroupUpdate}
	onClose={handleCloseGroupEditor}
/>
