<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { CheckCircle, SatelliteDish } from 'lucide-svelte';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import { useActiveSessionsQuery, discoverySSEManager } from '$lib/features/discovery/queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import {
		onboarding_daemonConnected,
		onboarding_daemonVerificationHelpMessage,
		onboarding_skipVerification,
		onboarding_verifyingDaemon,
		onboarding_waitingForDaemon
	} from '$lib/paraglide/messages';

	interface Props {
		isOpen: boolean;
		onComplete: () => void;
		onSkip: () => void;
	}

	let { isOpen, onComplete, onSkip }: Props = $props();

	// Query for active sessions to detect when daemon connects and starts scanning
	let queryEnabled = $state(false);
	const sessionsQuery = useActiveSessionsQuery(() => queryEnabled);
	let sessionsData = $derived(sessionsQuery.data ?? []);

	// Query for daemons to detect when daemon registers
	const daemonsQuery = useDaemonsQuery();
	let daemonsData = $derived(daemonsQuery.data ?? []);

	// Wait for daemon query to load before checking conditions
	let daemonQueryReady = $derived(!daemonsQuery.isPending && !daemonsQuery.isLoading);

	// Check if any daemon has connected (last_seen is set)
	let hasDaemonConnected = $derived(
		daemonQueryReady && daemonsData.some((d) => d.last_seen !== null)
	);

	// Check if there are any active sessions
	let hasActiveSession = $derived(sessionsData.length > 0);

	// Track if daemon was connected (to show success state before auto-advancing)
	let daemonVerified = $state(false);

	// Guard to ensure we only trigger navigation once
	let navigationScheduled = $state(false);

	// Rotating status text for waiting state
	let currentMessageIndex = $state(0);
	let intervalId: ReturnType<typeof setInterval> | null = null;

	onMount(() => {
		// Enable queries and connect to SSE
		const enableQuery = () => {
			queryEnabled = true;
			discoverySSEManager.connect();
		};

		if ('requestIdleCallback' in window) {
			requestIdleCallback(enableQuery);
		} else {
			setTimeout(enableQuery, 0);
		}

		// Toggle messages every 4 seconds
		intervalId = setInterval(() => {
			currentMessageIndex = currentMessageIndex === 0 ? 1 : 0;
		}, 4000);

		// Also poll daemon status more frequently
		const daemonPollId = setInterval(() => {
			daemonsQuery.refetch();
		}, 5000);

		return () => {
			if (intervalId) clearInterval(intervalId);
			clearInterval(daemonPollId);
		};
	});

	onDestroy(() => {
		discoverySSEManager.disconnect();
		if (intervalId) clearInterval(intervalId);
	});

	// Auto-advance when daemon connects or starts a session
	$effect(() => {
		// Guard: only run once
		if (navigationScheduled) return;

		if (hasActiveSession || hasDaemonConnected) {
			// Mark as verified and prevent re-entry
			daemonVerified = true;
			navigationScheduled = true;

			// Clear pending daemon setup flag
			if (typeof localStorage !== 'undefined') {
				localStorage.removeItem('pendingDaemonSetup');
			}

			// Capture callback reference before setTimeout
			const completeCallback = onComplete;

			// Wait 1.5 seconds to show success state, then advance
			setTimeout(() => {
				completeCallback();
			}, 1500);
		}
	});

	function handleSkip() {
		// Clear pending daemon setup flag when skipping
		if (typeof localStorage !== 'undefined') {
			localStorage.removeItem('pendingDaemonSetup');
		}
		onSkip();
	}
</script>

<GenericModal
	{isOpen}
	title={onboarding_verifyingDaemon()}
	onClose={handleSkip}
	size="md"
	showCloseButton={false}
	preventCloseOnClickOutside={true}
>
	<div class="flex min-h-0 flex-1 flex-col">
		<div class="flex flex-1 flex-col items-center justify-center space-y-6 overflow-y-auto p-8">
			{#if daemonVerified}
				<!-- Success state -->
				<div class="flex h-16 w-16 items-center justify-center rounded-full bg-success/20">
					<CheckCircle class="h-10 w-10 text-success" />
				</div>
				<div class="text-center">
					<p class="text-primary text-lg font-medium">{onboarding_daemonConnected()}</p>
					<p class="text-secondary mt-1 text-sm">Redirecting...</p>
				</div>
			{:else}
				<!-- Waiting state -->
				<div class="relative flex h-16 w-16 items-center justify-center">
					<div class="absolute inset-0 flex items-center justify-center">
						<div
							class="h-16 w-16 animate-spin rounded-full border-4 border-gray-700 border-t-primary-500"
						></div>
					</div>
					<SatelliteDish class="text-primary h-8 w-8" />
				</div>

				<div class="h-12 text-center">
					<!-- Rotating messages -->
					<div class="relative h-6 overflow-hidden">
						<p
							class="text-primary absolute inset-0 flex items-center justify-center text-lg font-medium"
						>
							{onboarding_waitingForDaemon()}
						</p>
					</div>
					<p class="text-secondary mt-2 text-sm">
						{onboarding_daemonVerificationHelpMessage()}
					</p>
				</div>
			{/if}
		</div>
	</div>

	{#snippet footer()}
		{#if !daemonVerified}
			<div class="modal-footer">
				<div class="flex justify-center">
					<button
						type="button"
						class="text-secondary hover:text-primary text-sm underline"
						onclick={handleSkip}
					>
						{onboarding_skipVerification()}
					</button>
				</div>
			</div>
		{/if}
	{/snippet}
</GenericModal>
