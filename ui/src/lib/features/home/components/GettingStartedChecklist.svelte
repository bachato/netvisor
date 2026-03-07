<script lang="ts">
	import type { components } from '$lib/api/schema';
	import { Check, Circle } from 'lucide-svelte';
	import SectionPanel from '$lib/shared/components/layout/SectionPanel.svelte';
	import { openModal } from '$lib/shared/stores/modal-registry';
	import { onMount } from 'svelte';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import confetti from 'canvas-confetti';

	type OnboardingOperation = components['schemas']['OnboardingOperation'];

	let {
		onboarding,
		onNavigate
	}: {
		onboarding: OnboardingOperation[];
		onNavigate: (tab: string) => void;
	} = $props();

	const DISMISS_KEY = 'home-checklist-dismissed';

	let dismissed = $state(false);
	let showCelebration = $state(false);
	let celebrationDone = $state(false);

	onMount(() => {
		dismissed = localStorage.getItem(DISMISS_KEY) === 'true';
	});

	$effect(() => {
		if (allComplete && !dismissed && !celebrationDone) {
			showCelebration = true;
			confetti({ particleCount: 100, spread: 70, origin: { y: 0.6 } });
			setTimeout(() => {
				showCelebration = false;
				celebrationDone = true;
				localStorage.setItem(DISMISS_KEY, 'true');
			}, 4000);
		}
	});

	interface ChecklistStep {
		id: string;
		milestone: OnboardingOperation;
		prerequisite: OnboardingOperation | null;
		label: string;
		description: string;
		action: () => void;
	}

	const steps: ChecklistStep[] = [
		{
			id: 'daemon',
			milestone: 'FirstDaemonRegistered',
			prerequisite: null,
			label: 'Add a Daemon',
			description: 'Install a daemon to start discovering your network.',
			action: () => {
				onNavigate('daemons');
				openModal('create-daemon');
			}
		},
		{
			id: 'discovery',
			milestone: 'FirstDiscoveryCompleted',
			prerequisite: 'FirstDaemonRegistered',
			label: 'Check Discovery Progress',
			description: 'See live results as your daemon discovers hosts and services.',
			action: () => onNavigate('discovery-sessions')
		},
		{
			id: 'topology',
			milestone: 'FirstTopologyRebuild',
			prerequisite: 'FirstDiscoveryCompleted',
			label: 'View your Topology',
			description: 'See your network visualized as an interactive map.',
			action: () => onNavigate('topology')
		}
	];

	let completedCount = $derived(steps.filter((s) => onboarding.includes(s.milestone)).length);

	let allComplete = $derived(completedCount === steps.length);

	function isStepComplete(step: ChecklistStep): boolean {
		return onboarding.includes(step.milestone);
	}

	function isStepEnabled(step: ChecklistStep): boolean {
		if (step.prerequisite === null) return true;
		return onboarding.includes(step.prerequisite);
	}

	function dismiss() {
		trackEvent('checklist_dismissed', { completed_count: completedCount });
		localStorage.setItem(DISMISS_KEY, 'true');
		dismissed = true;
	}
</script>

{#if showCelebration}
	<section>
		<div
			class="rounded-lg border border-green-300 bg-green-50 p-6 text-center dark:border-green-600/30 dark:bg-green-900/20"
		>
			<h3 class="text-primary text-base font-semibold">You're all set!</h3>
			<p class="text-secondary mt-1 text-sm">
				Your network is mapped. Explore your topology and discover what Scanopy can do.
			</p>
		</div>
	</section>
{:else if !allComplete && !dismissed}
	<section>
		<SectionPanel>
			<div class="mb-3 flex items-center justify-between">
				<h3 class="text-primary text-base font-semibold">Getting Started</h3>
				<div class="flex items-center gap-3">
					<span class="text-tertiary text-sm">{completedCount} of {steps.length} complete</span>
					{#if completedCount > 0}
						<button
							onclick={dismiss}
							class="text-tertiary hover:text-secondary text-sm transition-colors"
						>
							Dismiss
						</button>
					{/if}
				</div>
			</div>

			<div class="space-y-2">
				{#each steps as step (step.id)}
					{@const complete = isStepComplete(step)}
					{@const enabled = isStepEnabled(step)}
					<button
						class="flex w-full items-center justify-between rounded-lg px-3 py-2 text-left transition-colors {!complete &&
						enabled
							? 'bg-gray-100 hover:bg-gray-200 dark:bg-gray-800/50 dark:hover:bg-gray-700/50'
							: ''} {!enabled ? 'opacity-50' : ''}"
						disabled={complete || !enabled}
						onclick={() => step.action()}
					>
						<div class="flex items-center gap-3">
							{#if complete}
								<Check class="h-5 w-5 flex-shrink-0 text-green-400" />
							{:else}
								<Circle
									class="h-5 w-5 flex-shrink-0 {enabled ? 'text-tertiary' : 'text-disabled'}"
								/>
							{/if}
							<div>
								<span
									class="text-sm font-medium"
									class:text-primary={!complete && enabled}
									class:text-tertiary={complete}
									class:text-disabled={!complete && !enabled}
									class:line-through={complete}
								>
									{step.label}
								</span>
								{#if !complete && enabled}
									<p class="text-tertiary text-xs">{step.description}</p>
								{/if}
							</div>
						</div>
					</button>
				{/each}
			</div>
		</SectionPanel>
	</section>
{/if}
