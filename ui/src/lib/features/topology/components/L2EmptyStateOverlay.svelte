<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import { openModal } from '$lib/shared/stores/modal-registry';
	import { Cable } from 'lucide-svelte';
	import {
		topology_l2EmptyTitle,
		topology_l2EmptyDescription,
		topology_l2EmptySnmpHint,
		home_nudges_snmpAction
	} from '$lib/paraglide/messages';

	let {
		hasSnmpCredential = false
	}: {
		hasSnmpCredential?: boolean;
	} = $props();
</script>

<!-- Shroud over the topology viewer -->
<div class="absolute inset-0 z-20 bg-black/60 backdrop-blur-sm"></div>

<div class="l2-empty-anchor">
	<GenericModal
		title={topology_l2EmptyTitle()}
		isOpen={true}
		showCloseButton={false}
		preventCloseOnClickOutside={true}
		showBackdrop={false}
		size="sm"
	>
		<div class="flex flex-col items-center gap-4 p-6 text-center">
			<div class="rounded-full bg-emerald-500/10 p-3">
				<Cable class="h-8 w-8 text-emerald-500" />
			</div>
			<p class="text-secondary text-sm">
				{topology_l2EmptyDescription()}
			</p>
			{#if !hasSnmpCredential}
				<div class="border-primary/10 w-full border-t pt-3">
					<p class="text-secondary/70 mb-2 text-xs">
						{topology_l2EmptySnmpHint()}
					</p>
					<button class="btn btn-sm btn-primary" onclick={() => openModal('credential-editor')}>
						{home_nudges_snmpAction()}
					</button>
				</div>
			{/if}
		</div>
	</GenericModal>
</div>

<style>
	.l2-empty-anchor :global(.modal-page) {
		position: absolute;
		z-index: 30;
	}
</style>
