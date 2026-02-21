<script lang="ts">
	import { ArrowUpCircle } from 'lucide-svelte';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { openModal } from '$lib/shared/stores/modal-registry';

	let {
		feature
	}: {
		feature: string;
	} = $props();
</script>

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
