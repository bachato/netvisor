<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import ProgressTrack from '$lib/shared/components/data/ProgressTrack.svelte';
	import AnimatedProgressBar from './AnimatedProgressBar.svelte';
	import { cancellingSessions } from '$lib/features/discovery/queries';
	import { entities } from '$lib/shared/stores/metadata';
	import { Loader2, X } from 'lucide-svelte';
	import type { DiscoveryUpdatePayload } from '../../types/api';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import DocsHint from '$lib/shared/components/feedback/DocsHint.svelte';
	import {
		home_docsDiscoveryTakesLong,
		home_docsDiscoveryTakesLongLinkText
	} from '$lib/paraglide/messages';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useSubnetsQuery } from '$lib/features/subnets/queries';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { entityRef } from '$lib/shared/components/data/types';
	import { formatEstimatedRemaining } from '$lib/features/discovery/utils/estimation';

	// Props
	let {
		viewMode,
		session,
		onCancel
	}: {
		viewMode: 'card' | 'list';
		session: DiscoveryUpdatePayload;
		onCancel?: (sessionId: string) => void;
	} = $props();

	// Queries
	const daemonsQuery = useDaemonsQuery();
	const hostsQuery = useHostsQuery({ limit: 0 });
	const subnetsQuery = useSubnetsQuery();

	// Derived data
	let daemonsData = $derived(daemonsQuery.data ?? []);
	let hostsData = $derived(hostsQuery.data?.items ?? []);
	let subnetsData = $derived(subnetsQuery.data ?? []);
	let daemon = $derived(daemonsData.find((d) => d.id == session.daemon_id));
	let isCancelling = $derived(
		session?.session_id ? $cancellingSessions.get(session.session_id) === true : false
	);

	let isNetworkScanning = $derived(
		session.discovery_type?.type === 'Network' && session.phase === 'Scanning'
	);

	let estimationText = $derived.by(() => {
		if (!isNetworkScanning) return null;
		const hosts = session.hosts_discovered;
		const estimate = session.estimated_remaining_secs;

		if (!hosts) return 'Scanning for hosts...';
		if (estimate != null)
			return `Found ${hosts} hosts — ${formatEstimatedRemaining(estimate)} remaining`;
		return `Found ${hosts} hosts — estimating scan time...`;
	});

	async function handleCancelDiscovery() {
		if (onCancel) {
			await onCancel(session.session_id);
		}
	}

	// Build card data
	let cardData = $derived({
		title: session.discovery_type.type + ' Discovery',
		iconColor: entities.getColorHelper('Discovery').icon,
		Icon: entities.getIconComponent('Discovery'),
		fields: [
			{
				label: 'Daemon',
				value: (() => {
					if (!daemon) return 'Unknown Daemon';
					return [
						{
							id: daemon.id,
							label: daemon.name,
							color: entities.getColorHelper('Daemon').color,
							entityRef: entityRef('Daemon', daemon.id, daemon, {
								hosts: hostsData,
								subnets: subnetsData
							})
						}
					];
				})()
			},
			{
				label: 'Started',
				value: session.started_at ? formatTimestamp(session.started_at) : 'Not Yet'
			},
			{
				label: 'Session ID',
				value: session.session_id
			},
			{
				label: '', // No label needed for snippet
				snippet: progressSnippet
			}
		],
		actions: [
			...(onCancel
				? [
						{
							label: 'Cancel Discovery',
							icon: isCancelling ? Loader2 : X,
							class: 'btn-icon-danger',
							animation: isCancelling ? 'animate-spin' : '',
							onClick: isCancelling ? () => {} : () => handleCancelDiscovery()
						}
					]
				: [])
		]
	});
</script>

{#snippet progressSnippet()}
	<div class="flex items-center justify-between gap-3">
		<div class="flex-1 space-y-2">
			<div class="flex items-center gap-3">
				<span class={`text-secondary ${viewMode == 'list' ? 'text-xs' : 'text-sm'} font-medium`}
					>Phase:
				</span>
				<span class={`text-accent ${viewMode == 'list' ? 'text-xs' : 'text-sm'} font-medium`}
					>{isCancelling ? 'Cancelling' : session.phase}</span
				>
			</div>

			<div class="flex items-center gap-2">
				<ProgressTrack class="flex-1">
					<AnimatedProgressBar progress={session.progress} />
				</ProgressTrack>
				<span class="text-secondary text-xs">{session.progress}%</span>
			</div>

			{#if estimationText}
				<p class="text-secondary mt-1 text-xs">{estimationText}</p>
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
	</div>
{/snippet}

<GenericCard {...cardData} {viewMode} selectable={false} />
