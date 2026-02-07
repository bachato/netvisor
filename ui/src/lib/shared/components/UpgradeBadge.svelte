<script lang="ts">
	import { ArrowUpCircle } from 'lucide-svelte';
	import { trackEvent } from '$lib/shared/utils/analytics';

	let {
		feature,
		tooltip = `Upgrade your plan to access ${feature}`
	}: {
		feature: string;
		tooltip?: string;
	} = $props();
</script>

<button
	title={tooltip}
	class="inline-flex items-center gap-1 rounded-full bg-amber-500/10 px-2 py-0.5 text-xs font-medium text-amber-400 transition-colors hover:bg-amber-500/20"
	onclick={() => {
		trackEvent('upgrade_badge_clicked', { feature });
		window.dispatchEvent(new CustomEvent('open-settings', { detail: { tab: 'billing' } }));
	}}
>
	<ArrowUpCircle size={12} />
	<span>Upgrade</span>
</button>
