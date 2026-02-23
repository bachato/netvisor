<script lang="ts">
	import { ArrowUpCircle } from 'lucide-svelte';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { openModal } from '$lib/shared/stores/modal-registry';
	import { useConfigQuery } from '$lib/shared/stores/config-query';

	let {
		feature
	}: {
		feature: string;
	} = $props();

	const configQuery = useConfigQuery();
	const billingEnabled = $derived(configQuery.data?.billing_enabled ?? true);
</script>

{#if billingEnabled}
	<button
		title={`Upgrade your plan to access ${feature}`}
		class="btn-primary inline-flex items-center gap-1.5 border-amber-400 bg-amber-500 hover:border-amber-300 hover:bg-amber-600"
		onclick={() => {
			trackEvent('upgrade_button_clicked', { feature });
			openModal('billing-plan');
		}}
	>
		<ArrowUpCircle class="h-4 w-4" />
		<span>Upgrade</span>
	</button>
{:else}
	<a
		href="https://scanopy.net/pricing"
		target="_blank"
		rel="noopener noreferrer"
		title={`Upgrade your plan to access ${feature}`}
		class="btn-primary inline-flex items-center gap-1.5 border-amber-400 bg-amber-500 hover:border-amber-300 hover:bg-amber-600"
		onclick={() => {
			trackEvent('upgrade_button_clicked', { feature, external: true });
		}}
	>
		<ArrowUpCircle class="h-4 w-4" />
		<span>Upgrade</span>
	</a>
{/if}
