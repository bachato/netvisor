<script lang="ts">
	import SectionPanel from '$lib/shared/components/layout/SectionPanel.svelte';
	import ProgressTrack from '$lib/shared/components/data/ProgressTrack.svelte';
	import AnimatedProgressBar from '$lib/features/discovery/components/cards/AnimatedProgressBar.svelte';
	import { formatEstimatedRemaining } from '$lib/features/discovery/utils/estimation';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import type { DiscoveryUpdatePayload } from '$lib/features/discovery/types/api';

	let {
		sessions,
		onNavigate
	}: {
		sessions: DiscoveryUpdatePayload[];
		onNavigate: () => void;
	} = $props();

	const daemonsQuery = useDaemonsQuery();
	let daemons = $derived(daemonsQuery.data ?? []);

	function getDaemonName(daemonId: string): string {
		return daemons.find((d) => d.id === daemonId)?.name ?? 'Unknown';
	}

	function getEstimationText(session: DiscoveryUpdatePayload): string {
		const hosts = session.hosts_discovered;
		const estimate = session.estimated_remaining_secs;

		if (!hosts) return 'Scanning for hosts...';
		if (estimate != null)
			return `Found ${hosts} hosts — ~${formatEstimatedRemaining(estimate)} remaining`;
		return `Found ${hosts} hosts — estimating...`;
	}
</script>

<section>
	<SectionPanel>
		<h3 class="text-primary mb-3 text-base font-semibold">Active Discoveries</h3>
		<div class="space-y-3">
			{#each sessions as session (session.session_id)}
				<button
					class="w-full rounded-lg bg-gray-50 p-3 text-left transition-colors hover:bg-gray-100 dark:bg-gray-800/50 dark:hover:bg-gray-700/50"
					onclick={onNavigate}
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
					<p class="text-secondary text-xs">{getEstimationText(session)}</p>
				</button>
			{/each}
		</div>
	</SectionPanel>
</section>
