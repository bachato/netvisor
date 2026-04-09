<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import ListConfigEditor from '$lib/shared/components/forms/selection/ListConfigEditor.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import EntityConfigEmpty from '$lib/shared/components/forms/EntityConfigEmpty.svelte';
	import ShareConfigPanel from './ShareConfigPanel.svelte';
	import {
		ShareDisplay,
		type ShareDisplayContext
	} from '$lib/shared/components/forms/selection/display/ShareDisplay.svelte';
	import { Share2 } from 'lucide-svelte';
	import { createEmptyShare } from '../types/base';
	import { useSharesQuery, useCreateShareMutation, useDeleteShareMutation } from '../queries';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { billingPlans, entities } from '$lib/shared/stores/metadata';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import UpgradeButton from '$lib/shared/components/UpgradeButton.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import {
		common_cancel,
		common_failedToSave,
		common_save,
		common_saving,
		common_shares,
		shares_manageShares,
		shares_noShareSelected,
		shares_noSharesSubtitle,
		shares_noSharesYet,
		shares_selectToEdit
	} from '$lib/paraglide/messages';

	let {
		isOpen = false,
		onClose,
		topologyId = '',
		networkId = '',
		name = undefined
	}: {
		isOpen?: boolean;
		onClose: () => void;
		topologyId?: string;
		networkId?: string;
		name?: string;
	} = $props();

	// Queries
	const sharesQuery = useSharesQuery();
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const organizationQuery = useOrganizationQuery();
	let hasShareViews = $derived.by(() => {
		const org = organizationQuery.data;
		if (!org?.plan) return true;
		return billingPlans.getMetadata(org.plan.type).features.share_views;
	});

	// Filter shares for current topology
	let topologyShares = $derived(
		(sharesQuery.data ?? []).filter((s) => s.topology_id === topologyId)
	);

	// Mutations
	const createShareMutation = useCreateShareMutation();
	const deleteShareMutation = useDeleteShareMutation();

	// Reference to config panel for save
	let configPanel: ShareConfigPanel | null = $state(null);
	let saving = $state(false);

	async function handleCreateNew() {
		const newShare = createEmptyShare(topologyId, networkId);
		newShare.created_by = currentUser?.id || newShare.created_by;

		try {
			await createShareMutation.mutateAsync({
				share: newShare,
				password: undefined
			});
		} catch (error) {
			pushError(error instanceof Error ? error.message : common_failedToSave());
		}
	}

	async function handleRemove(index: number) {
		const share = topologyShares[index];
		if (!share) return;
		try {
			await deleteShareMutation.mutateAsync(share.id);
		} catch (error) {
			pushError(error instanceof Error ? error.message : common_failedToSave());
		}
	}

	async function handleSave() {
		if (!configPanel) return;
		saving = true;
		try {
			await configPanel.save();
		} finally {
			saving = false;
		}
	}
</script>

<GenericModal
	{isOpen}
	title={shares_manageShares()}
	{name}
	size="xl"
	{onClose}
	showCloseButton={true}
	fixedHeight={true}
>
	{#snippet headerIcon()}
		<ModalHeaderIcon Icon={Share2} color={entities.getColorHelper('Share').color} />
	{/snippet}

	{#if !hasShareViews}
		<div class="flex min-h-0 flex-1 flex-col items-center justify-center p-6">
			<EmptyState title={shares_noSharesYet()} subtitle={shares_noSharesSubtitle()}>
				<UpgradeButton feature="share_views" />
			</EmptyState>
		</div>
	{:else}
		<div class="flex min-h-0 flex-1 flex-col">
			<ListConfigEditor
				items={topologyShares}
				loading={sharesQuery.isPending}
				onReorder={() => {}}
				onChange={() => {}}
			>
				<svelte:fragment
					slot="list"
					let:items
					let:onEdit
					let:highlightedIndex
					let:onMoveUp
					let:onMoveDown
				>
					<ListManager
						label={common_shares()}
						emptyMessage={shares_noSharesSubtitle()}
						allowAddFromOptions={false}
						allowCreateNew={true}
						allowReorder={false}
						itemClickAction="edit"
						optionDisplayComponent={ShareDisplay}
						itemDisplayComponent={ShareDisplay}
						getItemContext={() => ({}) as ShareDisplayContext}
						{items}
						onCreateNew={handleCreateNew}
						onRemove={handleRemove}
						{onEdit}
						{onMoveUp}
						{onMoveDown}
						{highlightedIndex}
					/>
				</svelte:fragment>

				<svelte:fragment slot="config" let:selectedItem>
					{#if selectedItem}
						{#key selectedItem.id}
							<ShareConfigPanel bind:this={configPanel} share={selectedItem} />
						{/key}
					{:else}
						<EntityConfigEmpty title={shares_noShareSelected()} subtitle={shares_selectToEdit()} />
					{/if}
				</svelte:fragment>
			</ListConfigEditor>
		</div>
	{/if}

	{#snippet footer()}
		<div class="modal-footer">
			<div class="flex items-center justify-end gap-3">
				<button type="button" onclick={onClose} class="btn-secondary">
					{common_cancel()}
				</button>
				{#if configPanel}
					<button type="button" disabled={saving} onclick={handleSave} class="btn-primary">
						{saving ? common_saving() : common_save()}
					</button>
				{/if}
			</div>
		</div>
	{/snippet}
</GenericModal>
