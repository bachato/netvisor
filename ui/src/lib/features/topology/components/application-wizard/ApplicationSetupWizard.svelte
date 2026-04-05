<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import type { ModalTab } from '$lib/shared/components/layout/GenericModal.svelte';
	import DefineGroupsStep from './steps/DefineGroupsStep.svelte';
	import AssignEntitiesStep from './steps/AssignEntitiesStep.svelte';
	import type { Tag } from '$lib/features/tags/types/base';
	import {
		appWizard_title,
		appWizard_defineGroups,
		appWizard_assignEntities,
		appWizard_complete,
		common_back,
		common_next
	} from '$lib/paraglide/messages';

	let {
		appGroupTags,
		onComplete,
		onClose
	}: {
		appGroupTags: Tag[];
		onComplete: () => void;
		onClose: () => void;
	} = $props();

	let activeTab = $state('define');

	let tabs: ModalTab[] = $derived([
		{ id: 'define', label: appWizard_defineGroups() },
		{ id: 'assign', label: appWizard_assignEntities(), disabled: appGroupTags.length === 0 }
	]);

	function handleTabChange(tabId: string) {
		activeTab = tabId;
	}
</script>

<GenericModal
	title={appWizard_title()}
	isOpen={true}
	{onClose}
	showBackdrop={false}
	size="xl"
	{tabs}
	{activeTab}
	tabStyle="stepper"
	onTabChange={handleTabChange}
	fixedHeight={true}
>
	<div class="overflow-y-auto p-6">
		{#if activeTab === 'define'}
			<DefineGroupsStep {appGroupTags} />
		{:else if activeTab === 'assign'}
			<AssignEntitiesStep {appGroupTags} />
		{/if}
	</div>

	{#snippet footer()}
		<div class="modal-footer flex items-center justify-between">
			<div>
				{#if activeTab === 'assign'}
					<button type="button" class="btn-secondary" onclick={() => (activeTab = 'define')}>
						{common_back()}
					</button>
				{/if}
			</div>
			<div>
				{#if activeTab === 'define'}
					<button
						type="button"
						class="btn-primary"
						disabled={appGroupTags.length === 0}
						onclick={() => (activeTab = 'assign')}
					>
						{common_next()}
					</button>
				{:else}
					<button type="button" class="btn-primary" onclick={onComplete}>
						{appWizard_complete()}
					</button>
				{/if}
			</div>
		</div>
	{/snippet}
</GenericModal>
