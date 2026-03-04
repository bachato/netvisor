<script lang="ts">
	import { ArrowUpCircle } from 'lucide-svelte';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { openModal } from '$lib/shared/stores/modal-registry';
	import { useConfigQuery } from '$lib/shared/stores/config-query';
	import { upgradeContext } from '$lib/features/billing/stores';
	import type { UpgradeFeature } from '$lib/shared/stores/metadata';

	let {
		feature
	}: {
		feature: UpgradeFeature;
	} = $props();

	const configQuery = useConfigQuery();
	const billingEnabled = $derived(configQuery.data?.billing_enabled ?? true);

	function handleClick() {
		trackEvent('upgrade_button_clicked', { feature });
		upgradeContext.set({ feature });
		openModal('billing-plan');
	}
</script>

{#if billingEnabled}
	<button
		title={`Upgrade your plan to access ${feature}`}
		class="btn-primary inline-flex items-center gap-1.5 border-amber-400 bg-amber-500 hover:border-amber-300 hover:bg-amber-600"
		onclick={handleClick}
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
