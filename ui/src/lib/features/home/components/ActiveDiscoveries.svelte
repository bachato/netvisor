<script lang="ts">
	import ProgressTrack from '$lib/shared/components/data/ProgressTrack.svelte';
	import AnimatedProgressBar from '$lib/features/discovery/components/cards/AnimatedProgressBar.svelte';
	import { formatEstimatedRemaining } from '$lib/features/discovery/utils/estimation';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import type { DiscoveryUpdatePayload } from '$lib/features/discovery/types/api';
	import DocsHint from '$lib/shared/components/feedback/DocsHint.svelte';
	import {
		home_docsDiscoveryTakesLong,
		home_docsDiscoveryTakesLongLinkText
	} from '$lib/paraglide/messages';

	let {
		sessions,
		onNavigate
	}: {
		sessions: DiscoveryUpdatePayload[];
		onNavigate: () => void;
	} = $props();

	const daemonsQuery = useDaemonsQuery();
	let daemons = $derived(daemonsQuery.data ?? []);

	// Only show sessions in Scanning phase
	let scanningSessions = $derived(sessions.filter((s) => s.phase === 'Scanning'));

	function getDaemonName(daemonId: string): string {
		return daemons.find((d) => d.id === daemonId)?.name ?? 'Unknown';
	}

	function getEstimationText(session: DiscoveryUpdatePayload): string | null {
		if (session.discovery_type?.type !== 'Network') return null;
		const hosts = session.hosts_discovered;
		const estimate = session.estimated_remaining_secs;

		if (!hosts) return 'Scanning for hosts...';
		if (estimate != null)
			return `Found ${hosts} hosts — ${formatEstimatedRemaining(estimate)} remaining`;
		return `Found ${hosts} hosts — estimating scan time...`;
	}
</script>

{#if scanningSessions.length > 0}
	<section>
		<h3 class="text-primary mb-3 text-base font-semibold">Active Discoveries</h3>
		<div class="grid grid-cols-[repeat(auto-fill,minmax(360px,1fr))] gap-4">
			{#each scanningSessions as session (session.session_id)}
				{@const estimation = getEstimationText(session)}
				<div
					class="card card-static cursor-pointer hover:ring-1 hover:ring-gray-700"
					onclick={onNavigate}
					onkeydown={(e) => {
						if (e.key === 'Enter' || e.key === ' ') onNavigate();
					}}
					role="button"
					tabindex={0}
				>
					<div class="mb-2 flex items-center justify-between">
						<span class="text-primary text-sm font-medium">
							{session.discovery_type.type} Discovery
						</span>
						<span class="text-tertiary text-xs">{getDaemonName(session.daemon_id)}</span>
					</div>
					<div class="mb-1 flex items-center gap-2">
						<ProgressTrack class="flex-1">
							<AnimatedProgressBar progress={session.progress} />
						</ProgressTrack>
						<span class="text-secondary text-xs">{session.progress}%</span>
					</div>
					{#if estimation}
						<p class="text-secondary text-xs">{estimation}</p>
						{#if session.estimated_remaining_secs != null && session.estimated_remaining_secs > 3600}
							<DocsHint
								text={home_docsDiscoveryTakesLong()}
								href="https://scanopy.net/docs/setting-up-daemons/troubleshooting-scans/#discovery-takes-hours"
								linkText={home_docsDiscoveryTakesLongLinkText()}
								class="mt-0.5"
							/>
						{/if}
					{/if}
				</div>
			{/each}
		</div>
	</section>
{/if}
