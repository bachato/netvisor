<script lang="ts">
	import { formatEstimatedRemaining } from '$lib/features/discovery/utils/estimation';
	import DocsHint from '$lib/shared/components/feedback/DocsHint.svelte';
	import {
		home_docsDiscoveryTakesLong,
		home_docsDiscoveryTakesLongLinkText
	} from '$lib/paraglide/messages';

	interface Props {
		hosts_discovered?: number | null;
		estimated_remaining_secs?: number | null;
		class?: string;
	}

	let { hosts_discovered, estimated_remaining_secs, class: className = '' }: Props = $props();

	let text = $derived.by(() => {
		if (!hosts_discovered) return 'Scanning for hosts...';
		if (estimated_remaining_secs != null)
			return `Found ${hosts_discovered} hosts — ${formatEstimatedRemaining(estimated_remaining_secs)} remaining`;
		return `Found ${hosts_discovered} hosts — estimating scan time...`;
	});
</script>

<div class={className}>
	<p class="text-secondary text-xs">{text}</p>
	{#if estimated_remaining_secs != null && estimated_remaining_secs > 600}
		<DocsHint
			text={home_docsDiscoveryTakesLong()}
			href="https://scanopy.net/docs/setting-up-daemons/troubleshooting-scans/#discovery-takes-hours"
			linkText={home_docsDiscoveryTakesLongLinkText()}
			class="mt-0.5"
		/>
	{/if}
</div>
