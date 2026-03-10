<script lang="ts">
	import ProgressTrack from '$lib/shared/components/data/ProgressTrack.svelte';
	import AnimatedProgressBar from '$lib/features/discovery/components/cards/AnimatedProgressBar.svelte';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import type { DiscoveryUpdatePayload } from '$lib/features/discovery/types/api';
	import DiscoveryEstimation from '$lib/features/discovery/components/DiscoveryEstimation.svelte';

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
</script>

{#if scanningSessions.length > 0}
	<section>
		<h3 class="text-primary mb-3 text-base font-semibold">Active Discoveries</h3>
		<div class="grid grid-cols-[repeat(auto-fill,minmax(360px,1fr))] gap-4">
			{#each scanningSessions as session (session.session_id)}
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
					{#if session.discovery_type?.type === 'Network'}
						<DiscoveryEstimation
							hosts_discovered={session.hosts_discovered}
							estimated_remaining_secs={session.estimated_remaining_secs}
						/>
					{/if}
				</div>
			{/each}
		</div>
	</section>
{/if}
