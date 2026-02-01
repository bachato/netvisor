<script lang="ts">
	import { Network } from 'lucide-svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ConfirmationDialog from '$lib/shared/components/feedback/ConfirmationDialog.svelte';
	import CreateDaemonForm from '$lib/features/daemons/components/CreateDaemonForm.svelte';
	import { useDaemonSetupMutation } from '../../queries';
	import { onboardingStore } from '../../stores/onboarding';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { pushError } from '$lib/shared/stores/feedback';
	import type { NetworkSetup } from '../../types/base';
	import {
		common_continue,
		common_settingUp,
		onboarding_daemonsActivateBody,
		onboarding_daemonsActivateTitle,
		onboarding_exploreDemoInstead,
		onboarding_selectADaemon,
		onboarding_selectDaemon,
		onboarding_selectDaemonHelp,
		onboarding_skipConfirmBody,
		onboarding_skipConfirmTitle,
		onboarding_skipDaemonSetup,
		onboarding_startScanning
	} from '$lib/paraglide/messages';

	// Convert string to kebab-case
	function toKebabCase(str: string): string {
		return str
			.toLowerCase()
			.replace(/[^a-z0-9]+/g, '-')
			.replace(/^-+|-+$/g, '');
	}

	interface Props {
		isOpen: boolean;
		networks: NetworkSetup[];
		onComplete: () => void;
		onClose: () => void;
	}

	let { isOpen, networks, onComplete, onClose }: Props = $props();

	// Track the selected network for daemon installation
	let selectedNetworkId = $state<string | null>(null);

	// Track loading state during daemon setup
	let isLoading = $state(false);

	// API key returned after daemon setup (null = not yet configured)
	let apiKey = $state<string | null>(null);

	// Track skip confirmation modal
	let showSkipConfirm = $state(false);

	// Daemon setup mutation
	const daemonSetupMutation = useDaemonSetupMutation();

	// Restore daemon setup state from store on mount (for page reload persistence)
	$effect(() => {
		// Only run once when component mounts and no selection has been made
		if (selectedNetworkId !== null) return;

		const state = onboardingStore.getState();
		// Find a daemon setup that has an API key (was configured to install now)
		for (const [networkId, setup] of state.daemonSetups.entries()) {
			if (setup.installNow && setup.apiKey) {
				selectedNetworkId = networkId;
				apiKey = setup.apiKey;
				break;
			}
		}
	});

	// Get the selected network object
	let selectedNetwork = $derived(networks.find((n) => n.id === selectedNetworkId));

	// Get daemon name based on selected network
	let defaultDaemonName = $derived(
		selectedNetwork ? toKebabCase(selectedNetwork.name) + '-daemon' : 'daemon'
	);

	async function selectNetwork(networkId: string) {
		if (selectedNetworkId === networkId) return;

		// Reset API key when changing selection
		apiKey = null;
		selectedNetworkId = networkId;

		// Immediately set up the daemon for the selected network
		const network = networks.find((n) => n.id === networkId);
		if (!network) return;

		const daemonName = toKebabCase(network.name) + '-daemon';
		isLoading = true;

		try {
			const result = await daemonSetupMutation.mutateAsync({
				daemon_name: daemonName,
				network_id: networkId,
				install_later: false
			});

			apiKey = result.api_key ?? null;

			// Update onboarding store
			onboardingStore.setDaemonSetup(networkId, {
				name: daemonName,
				installNow: true,
				apiKey: result.api_key ?? undefined
			});

			// Set pending daemon setup flag for ScanProgressIndicator
			if (typeof localStorage !== 'undefined') {
				localStorage.setItem('pendingDaemonSetup', 'true');
			}

			// Mark other networks as install later
			for (const n of networks) {
				if (n.id && n.id !== networkId) {
					onboardingStore.setDaemonSetup(n.id, {
						name: toKebabCase(n.name) + '-daemon',
						installNow: false
					});
				}
			}

			// Track daemon choice
			trackEvent('onboarding_daemon_choice', {
				choice: 'install_now',
				use_case: onboardingStore.getState().useCase
			});
		} catch {
			pushError('Failed to generate daemon key. Please try again.');
		} finally {
			isLoading = false;
		}
	}

	function handleContinue() {
		if (apiKey) {
			onComplete();
		}
	}

	function handleSkipClick() {
		showSkipConfirm = true;
	}

	function handleSkipCancel() {
		showSkipConfirm = false;
	}

	function handleExploreDemo() {
		showSkipConfirm = false;
		window.open('https://demo.scanopy.net', '_blank');
	}

	// Determine button state - can only continue after API key is generated
	let canContinue = $derived(apiKey !== null && !isLoading);
</script>

<GenericModal
	{isOpen}
	title={onboarding_startScanning()}
	{onClose}
	size="xl"
	showCloseButton={false}
	preventCloseOnClickOutside={true}
>
	<div class="flex min-h-0 flex-1 flex-col">
		<div class="flex-1 space-y-6 overflow-y-auto p-6">
			<div class="space-y-2">
				<p class="text-primary font-medium">{onboarding_selectDaemon()}</p>
				<p class="text-secondary text-sm">
					{onboarding_selectDaemonHelp()}
				</p>
			</div>

			<InlineInfo
				title={onboarding_daemonsActivateTitle()}
				body={onboarding_daemonsActivateBody()}
			/>

			<!-- Network selection cards -->
			<div class="space-y-2">
				{#each networks as network (network.id)}
					{#if network.id}
						{@const isSelected = selectedNetworkId === network.id}
						<button
							type="button"
							class="card flex w-full items-center gap-4 p-4 text-left transition-all {isSelected
								? 'card-selected'
								: ''}"
							onclick={() => network.id && selectNetwork(network.id)}
						>
							<div
								class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-gray-700 text-gray-400"
							>
								<Network class="h-5 w-5" />
							</div>
							<div class="flex-1">
								<div class="text-primary font-medium">{network.name}</div>
							</div>
							<div
								class="flex h-5 w-5 items-center justify-center rounded-full border-2 {isSelected
									? 'border-primary-500 bg-primary-500'
									: 'border-gray-500'}"
							>
								{#if isSelected}
									<div class="h-2 w-2 rounded-full bg-white"></div>
								{/if}
							</div>
						</button>
					{/if}
				{/each}
			</div>

			<!-- Show loading state while daemon is being set up -->
			{#if selectedNetworkId && isLoading}
				<div class="card flex items-center justify-center p-8">
					<div class="text-secondary flex items-center gap-2">
						<div
							class="h-4 w-4 animate-spin rounded-full border-2 border-gray-500 border-t-primary-500"
						></div>
						<span>{common_settingUp()}...</span>
					</div>
				</div>
			{/if}

			<!-- Show installation commands after API key is generated -->
			{#if selectedNetworkId && apiKey && !isLoading}
				<div class="card space-y-4">
					<CreateDaemonForm
						daemon={null}
						networkId={selectedNetworkId}
						{apiKey}
						showAdvanced={true}
						initialName={defaultDaemonName}
						showModeSelect={false}
					/>
				</div>
			{/if}
		</div>
	</div>

	{#snippet footer()}
		<div class="modal-footer">
			<div class="flex items-center justify-between">
				<button
					type="button"
					class="text-secondary hover:text-primary text-sm underline"
					onclick={handleSkipClick}
				>
					{onboarding_skipDaemonSetup()}
				</button>
				<button type="button" class="btn-primary" disabled={!canContinue} onclick={handleContinue}>
					{common_continue()}
				</button>
			</div>
		</div>
	{/snippet}
</GenericModal>

<!-- Skip confirmation modal -->
<ConfirmationDialog
	isOpen={showSkipConfirm}
	title={onboarding_skipConfirmTitle()}
	message={onboarding_skipConfirmBody()}
	confirmLabel={onboarding_selectADaemon()}
	cancelLabel={onboarding_exploreDemoInstead()}
	onConfirm={handleSkipCancel}
	onCancel={handleExploreDemo}
	onClose={() => (showSkipConfirm = false)}
	variant="warning"
/>
