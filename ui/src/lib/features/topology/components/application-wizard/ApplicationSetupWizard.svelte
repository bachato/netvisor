<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import DefineGroupsStep from './steps/DefineGroupsStep.svelte';
	import AssignEntitiesStep from './steps/AssignEntitiesStep.svelte';
	import type { Tag } from '$lib/features/tags/types/base';
	import {
		appWizard_title,
		appWizard_complete,
		common_back,
		common_next
	} from '$lib/paraglide/messages';

	let {
		appGroupTags,
		onComplete
	}: {
		appGroupTags: Tag[];
		onComplete: () => void;
	} = $props();

	let activeTab = $state<'define' | 'assign'>('define');
</script>

<!-- Shroud over the topology viewer -->
<div class="absolute inset-0 z-20 bg-black/60 backdrop-blur-sm"></div>

<!-- Modal anchored to topology view -->
<div class="app-wizard-anchor">
	<GenericModal
		title={appWizard_title()}
		isOpen={true}
		showCloseButton={false}
		preventCloseOnClickOutside={true}
		showBackdrop={false}
		size="xl"
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
</div>

<style>
	/* Override GenericModal's fixed viewport positioning to anchor within the topology view */
	.app-wizard-anchor :global(.modal-page) {
		position: absolute;
		z-index: 30;
	}
</style>
