<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import { validateForm } from '$lib/shared/components/forms/form-context';
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
	import type { Share } from '../types/base';
	import { createEmptyShare } from '../types/base';
	import {
		useSharesQuery,
		useCreateShareMutation,
		useDeleteShareMutation,
		useUpdateShareMutation
	} from '../queries';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { useTopologiesQuery } from '$lib/features/topology/queries';
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
		common_validation_entityField,
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

	const topologiesQuery = useTopologiesQuery();
	let topologyName = $derived(topologiesQuery.data?.find((t) => t.id === topologyId)?.name ?? '');

	let modalTitle = $derived(shares_manageShares({ name: topologyName }));

	const organizationQuery = useOrganizationQuery();
	let hasShareViews = $derived.by(() => {
		const org = organizationQuery.data;
		if (!org?.plan) return true;
		return billingPlans.getMetadata(org.plan.type).features.share_views;
	});

	// Local reactive copy of shares for this topology
	let sharesData: Share[] = $state([]);

	// Sync from query when data changes
	$effect(() => {
		const queryShares = (sharesQuery.data ?? []).filter((s) => s.topology_id === topologyId);
		sharesData = queryShares;
	});

	// Mutations
	const createShareMutation = useCreateShareMutation();
	const deleteShareMutation = useDeleteShareMutation();
	const updateShareMutation = useUpdateShareMutation();

	let saving = $state(false);

	// Build form default values from current shares
	function getFormDefaults() {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		const defaults: Record<string, any> = {};
		for (let i = 0; i < sharesData.length; i++) {
			const s = sharesData[i];
			defaults[`shares[${i}].name`] = s.name || '';
			defaults[`shares[${i}].password`] = '';
			defaults[`shares[${i}].allowed_domains`] = s.allowed_domains?.join(', ') || '';
			defaults[`shares[${i}].expires_at`] = s.expires_at || '';
			defaults[`shares[${i}].is_enabled`] = s.is_enabled ?? true;
			defaults[`shares[${i}].show_zoom_controls`] = s.options?.show_zoom_controls ?? true;
			defaults[`shares[${i}].show_inspect_panel`] = s.options?.show_inspect_panel ?? true;
			defaults[`shares[${i}].show_export_button`] = s.options?.show_export_button ?? true;
			defaults[`shares[${i}].show_minimap`] = s.options?.show_minimap ?? true;
			defaults[`shares[${i}].embed_width`] = '800';
			defaults[`shares[${i}].embed_height`] = '600';
		}
		return defaults;
	}

	// Parent-owned form
	const form = createForm(() => ({
		defaultValues: getFormDefaults(),
		onSubmit: async () => {
			// Submission handled by handleSave
		}
	}));

	function handleShareChange(updatedShare: Share, index: number) {
		const updated = [...sharesData];
		updated[index] = updatedShare;
		sharesData = updated;
	}

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
		const share = sharesData[index];
		if (!share) return;
		try {
			await deleteShareMutation.mutateAsync(share.id);
		} catch (error) {
			pushError(error instanceof Error ? error.message : common_failedToSave());
		}
	}

	// Resolve field paths to human-readable names for validation errors
	function resolveFieldName(fieldPath: string): string {
		const match = fieldPath.match(/^shares\[(\d+)]\.(.+)$/);
		if (match) {
			const index = parseInt(match[1]);
			const field = match[2].replace(/_/g, ' ');
			const share = sharesData[index];
			const shareName = share?.name || `Share ${index + 1}`;
			return common_validation_entityField({ name: shareName, field });
		}
		return fieldPath.replace(/_/g, ' ');
	}

	async function handleSave() {
		const isValid = await validateForm(form, undefined, resolveFieldName);
		if (!isValid) return;

		saving = true;
		try {
			for (let i = 0; i < sharesData.length; i++) {
				const share = sharesData[i];
				const values = form.state.values;
				const formData = {
					id: share.id,
					name: (values[`shares[${i}].name`] as string)?.trim() || '',
					topology_id: share.topology_id,
					network_id: share.network_id,
					created_by: currentUser?.id || share.created_by,
					allowed_domains: (values[`shares[${i}].allowed_domains`] as string)?.trim()
						? (values[`shares[${i}].allowed_domains`] as string)
								.split(',')
								.map((d: string) => d.trim())
								.filter(Boolean)
						: null,
					expires_at: (values[`shares[${i}].expires_at`] as string) || null,
					is_enabled: values[`shares[${i}].is_enabled`] as boolean,
					options: {
						show_zoom_controls: values[`shares[${i}].show_zoom_controls`] as boolean,
						show_inspect_panel: values[`shares[${i}].show_inspect_panel`] as boolean,
						show_export_button: values[`shares[${i}].show_export_button`] as boolean,
						show_minimap: values[`shares[${i}].show_minimap`] as boolean
					}
				} as Share;

				const password = (values[`shares[${i}].password`] as string) || undefined;
				await updateShareMutation.mutateAsync({
					id: share.id,
					request: { share: formData, password }
				});
			}
		} catch (error) {
			pushError(error instanceof Error ? error.message : common_failedToSave());
		} finally {
			saving = false;
		}
	}
</script>

<GenericModal
	{isOpen}
	title={modalTitle}
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
				items={sharesData}
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

				<svelte:fragment slot="config" let:selectedItem let:selectedIndex>
					<!-- Render all config panels to register form fields, only show selected -->
					{#each sharesData as share, index (`${share.id}-${index}`)}
						<div class:hidden={selectedIndex !== index}>
							<ShareConfigPanel
								{share}
								{index}
								{form}
								onChange={(updatedShare) => handleShareChange(updatedShare, index)}
							/>
						</div>
					{/each}

					{#if !selectedItem}
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
				{#if sharesData.length > 0}
					<button type="button" disabled={saving} onclick={handleSave} class="btn-primary">
						{saving ? common_saving() : common_save()}
					</button>
				{/if}
			</div>
		</div>
	{/snippet}
</GenericModal>
