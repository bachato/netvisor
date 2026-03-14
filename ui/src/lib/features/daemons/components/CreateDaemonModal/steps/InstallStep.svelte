<script lang="ts">
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import DocsHint from '$lib/shared/components/feedback/DocsHint.svelte';
	import InlineDanger from '$lib/shared/components/feedback/InlineDanger.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import InlineSuccess from '$lib/shared/components/feedback/InlineSuccess.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import SupportOptions from '$lib/features/support/SupportOptions.svelte';
	import { useConfigQuery } from '$lib/shared/stores/config-query';
	import type { DaemonOS } from '../../../utils';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { useTestReachabilityMutation, useRetryDaemonConnectionMutation } from '../../../queries';
	import AnimatedProgressBar from '$lib/features/discovery/components/cards/AnimatedProgressBar.svelte';
	import OsSelector from '../../OsSelector.svelte';
	import { Loader2, CheckCircle2, AlertTriangle, SlidersHorizontal } from 'lucide-svelte';
	import type { DaemonConnectionStatus } from '../../../stores/daemon-setup';
	import {
		common_advanced,
		daemons_dockerLinuxOnly,
		daemons_dockerLinuxOnlyBody,
		daemons_docsMacvlan,
		daemons_docsMacvlanLinkText,
		daemons_docsMultiVlan,
		daemons_docsMultiVlanLinkText,
		daemons_fixValidationErrors,
		daemons_fixValidationErrorsBody,
		daemons_wslWarning,
		daemons_wslWarningBody
	} from '$lib/paraglide/messages';

	type LinuxMethod = 'binary' | 'docker';

	interface Props {
		selectedOS: DaemonOS;
		onOsSelect: (os: DaemonOS) => void;
		linuxMethod?: LinuxMethod;
		onLinuxMethodChange?: (method: LinuxMethod) => void;
		runCommand: string;
		dockerCompose: string;
		hasErrors: boolean;
		isFirstDaemon?: boolean;
		connectionStatus?: DaemonConnectionStatus;
		onReviewCommands?: () => void;
		onViewDiscovery?: () => void;
		hasEmailSupport?: boolean;
		showTroubleshootingPanel?: boolean;
		onAdvanced?: (() => void) | null;
		daemonMode?: string;
		daemonUrl?: string;
		provisionedDaemonId?: string;
		onTroubleshoot?: () => void;
	}

	let {
		selectedOS,
		onOsSelect,
		linuxMethod = 'binary',
		onLinuxMethodChange,
		runCommand,
		dockerCompose,
		hasErrors,
		isFirstDaemon = false,
		connectionStatus = 'idle',
		onReviewCommands,
		onViewDiscovery,
		hasEmailSupport = false,
		showTroubleshootingPanel = false,
		onAdvanced = null,
		daemonMode = 'daemon_poll',
		daemonUrl = '',
		provisionedDaemonId = '',
		onTroubleshoot
	}: Props = $props();

	const configQuery = useConfigQuery();
	let hasEmail = $derived(configQuery.data?.has_email_service ?? false);

	const windowsDownloadUrl =
		'https://github.com/scanopy/scanopy/releases/latest/download/scanopy-daemon-windows-amd64.exe';
	const windowsInstallCommand = `Invoke-WebRequest -Uri "${windowsDownloadUrl}" -OutFile "scanopy-daemon-windows-amd64.exe"`;
	const installScript = `bash -c "$(curl -fsSL https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh)"`;

	// Combined install commands
	let combinedLinuxMacCommand = $derived(`${installScript} && ${runCommand}`);
	let combinedWindowsCommand = $derived(`${windowsInstallCommand}; ${runCommand}`);

	// ServerPoll health check
	const healthCheckMutation = useTestReachabilityMutation();
	const retryConnectionMutation = useRetryDaemonConnectionMutation();
	let healthResult = $state<{ reachable: boolean; health?: boolean; error?: string } | null>(null);
	let isCheckingHealth = $state(false);

	async function handleHealthCheck() {
		if (!daemonUrl) return;
		isCheckingHealth = true;
		try {
			const result = await healthCheckMutation.mutateAsync({
				url: daemonUrl,
				check_health: true
			});
			healthResult = {
				reachable: result.reachable,
				health: result.health ?? undefined,
				error: result.error ?? undefined
			};
			// If reachable and healthy, reset unreachable flag so server resumes polling
			if (result.reachable && result.health && provisionedDaemonId) {
				retryConnectionMutation.mutate(provisionedDaemonId);
			}
		} catch {
			healthResult = { reachable: false, error: 'Failed to test reachability' };
		} finally {
			isCheckingHealth = false;
		}
	}

	// Clear health result when transitioning to connected
	$effect(() => {
		if (connectionStatus === 'connected') {
			healthResult = null;
		}
	});

	// Auto-run health check once on transition into trouble state for ServerPoll
	let prevConnectionStatus = $state<DaemonConnectionStatus>('idle');
	$effect(() => {
		if (
			prevConnectionStatus !== 'trouble' &&
			connectionStatus === 'trouble' &&
			daemonMode === 'server_poll' &&
			daemonUrl
		) {
			handleHealthCheck();
		}
		prevConnectionStatus = connectionStatus;
	});

	function handleOsSelect(os: DaemonOS) {
		onOsSelect(os);
		trackEvent('daemon_install_os_selected', { os });
	}

	function handleCopy(context: string) {
		trackEvent('daemon_install_command_copied', { os: selectedOS, context });
	}

	// Show waiting UI when connection status is not idle (first daemon only)
	let showWaitingUI = $derived(isFirstDaemon && connectionStatus !== 'idle');

	// Progress bar for waiting state (0-100 over 60 seconds)
	const WAIT_DURATION_MS = 60_000;
	let waitingProgress = $state(0);
	let waitingStartTime = $state<number | null>(null);
	$effect(() => {
		if (connectionStatus === 'waiting') {
			waitingStartTime = Date.now();
			waitingProgress = 0;
			const interval = setInterval(() => {
				const elapsed = Date.now() - (waitingStartTime ?? Date.now());
				waitingProgress = Math.min(100, (elapsed / WAIT_DURATION_MS) * 100);
				if (waitingProgress >= 100) clearInterval(interval);
			}, 500);
			return () => clearInterval(interval);
		}
	});

	// Auto-scroll to troubleshooting panel when first shown
	let troubleshootingRef: HTMLDivElement | undefined = $state(undefined);
	let hasScrolledToTroubleshooting = $state(false);
	$effect(() => {
		if (showTroubleshootingPanel && troubleshootingRef && !hasScrolledToTroubleshooting) {
			troubleshootingRef.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
			hasScrolledToTroubleshooting = true;
		}
	});
</script>

<div class="space-y-4">
	{#if showWaitingUI}
		<!-- Waiting / Connected / Trouble states -->
		{#if connectionStatus === 'waiting'}
			<div class="flex flex-col items-center gap-4 py-8 text-center">
				<div class="w-full max-w-xs">
					<div class="bg-tertiary h-2 w-full overflow-hidden rounded-full">
						<AnimatedProgressBar progress={waitingProgress} />
					</div>
				</div>
				<div>
					<h3 class="text-primary text-base font-semibold">
						Waiting for your daemon to connect...
					</h3>
					<p class="text-secondary mt-1 text-sm">
						This usually takes less than a minute. Make sure the daemon is running.
					</p>
				</div>
				<div class="flex items-center gap-3">
					<button type="button" class="btn-secondary text-sm" onclick={() => onReviewCommands?.()}>
						Return to install commands
					</button>
					<button type="button" class="btn-secondary text-sm" onclick={() => onTroubleshoot?.()}>
						Troubleshoot
					</button>
				</div>
			</div>
			{#if showTroubleshootingPanel}
				<div bind:this={troubleshootingRef} class="pt-4">
					<p class="text-secondary mb-3 text-sm font-medium">Need help?</p>
					<SupportOptions isTroubleshooting={true} {hasEmailSupport} />
				</div>
			{/if}
		{:else if connectionStatus === 'connected'}
			<div class="flex flex-col items-center gap-4 py-8 text-center">
				<CheckCircle2 class="h-10 w-10 text-green-400" />
				<div>
					<h3 class="text-primary text-base font-semibold">Your daemon is connected!</h3>
					<p class="text-secondary mt-1 text-sm">
						Discovery has automatically started. You can view the progress in real time.
					</p>
				</div>
				<button type="button" class="btn-primary" onclick={() => onViewDiscovery?.()}>
					View Discovery Progress
				</button>
				{#if hasEmail && isFirstDaemon}
					<p class="text-secondary text-sm">
						We'll email you when your first network discovery is complete.
					</p>
				{/if}
			</div>
		{:else if connectionStatus === 'trouble'}
			<div class="flex flex-col items-center gap-4 py-8 text-center">
				<AlertTriangle class="h-10 w-10 text-yellow-400" />
				<div>
					<h3 class="text-primary text-base font-semibold">Your daemon hasn't connected yet</h3>
					<p class="text-secondary mt-1 text-sm">
						It's been a while. Check that the daemon is running and can reach this server.
					</p>
				</div>
				<ol class="text-secondary list-decimal space-y-1 pl-5 text-left text-sm">
					<li>Check that the daemon process is running</li>
					<li>Verify the server URL in the daemon config matches this server</li>
					<li>Check that no firewall is blocking the connection</li>
				</ol>
				{#if daemonMode === 'server_poll' && daemonUrl}
					<div class="flex flex-col items-center gap-2">
						{#if healthResult}
							{#if healthResult.reachable && healthResult.health}
								<InlineSuccess
									title="Daemon is reachable and healthy — waiting for server to register it"
								/>
							{:else if healthResult.reachable}
								<InlineWarning title="Port open but health check failed" />
							{:else}
								<InlineDanger title={healthResult.error ?? 'Not reachable'} />
							{/if}
						{/if}
						<button
							type="button"
							class="btn-primary text-sm"
							disabled={isCheckingHealth}
							onclick={handleHealthCheck}
						>
							{#if isCheckingHealth}
								<Loader2 class="h-4 w-4 animate-spin" />
							{/if}
							Test Daemon Reachability
						</button>
					</div>
				{/if}
				<div class="flex items-center gap-3">
					<button type="button" class="btn-secondary text-sm" onclick={() => onReviewCommands?.()}>
						Return to install commands
					</button>
					<button type="button" class="btn-secondary text-sm" onclick={() => onTroubleshoot?.()}>
						Troubleshoot
					</button>
				</div>
				<DocsHint
					text="See our %link% for common solutions."
					href="https://scanopy.net/docs/setting-up-daemons/troubleshooting-setup/"
					linkText="troubleshooting guide"
				/>
			</div>
		{/if}
	{:else}
		<!-- Normal install commands view -->
		{#if hasErrors}
			<InlineWarning
				title={daemons_fixValidationErrors()}
				body={daemons_fixValidationErrorsBody()}
			/>
		{:else}
			<OsSelector
				{selectedOS}
				onOsSelect={handleOsSelect}
				{linuxMethod}
				onLinuxMethodChange={(method) => onLinuxMethodChange?.(method)}
			>
				{#snippet afterLabel()}
					<DocsHint
						text={daemons_docsMultiVlan()}
						href="https://scanopy.net/docs/setting-up-daemons/planning-daemon-deployment/"
						linkText={daemons_docsMultiVlanLinkText()}
					/>
				{/snippet}
				{#snippet afterButtons()}
					{#if onAdvanced}
						<button type="button" class="btn-secondary shrink-0 text-sm" onclick={onAdvanced}>
							<SlidersHorizontal class="h-4 w-4" />
							{common_advanced()}
						</button>
					{/if}
				{/snippet}
				{#if selectedOS === 'linux'}
					{#if linuxMethod === 'binary'}
						<p class="text-secondary text-sm">
							This command will download and install the daemon, then start it with your
							configuration.
						</p>
						<CodeContainer
							language="bash"
							expandable={false}
							code={combinedLinuxMacCommand}
							onCopy={() => handleCopy('combined-install')}
						/>
					{:else if linuxMethod === 'docker' && dockerCompose}
						<DocsHint
							text={daemons_docsMacvlan()}
							href="https://scanopy.net/docs/guides/macvlan-setup/"
							linkText={daemons_docsMacvlanLinkText()}
						/>
						<CodeContainer
							language="yaml"
							expandable={false}
							maxHeight=""
							code={dockerCompose}
							onCopy={() => handleCopy('docker-compose')}
						/>
					{/if}
				{:else if selectedOS === 'macos'}
					<p class="text-secondary text-sm">
						This command will download and install the daemon, then start it with your
						configuration.
					</p>
					<CodeContainer
						language="bash"
						expandable={false}
						code={combinedLinuxMacCommand}
						onCopy={() => handleCopy('combined-install')}
					/>

					<InlineInfo title={daemons_dockerLinuxOnly()} body={daemons_dockerLinuxOnlyBody()} />
				{:else if selectedOS === 'windows'}
					<p class="text-secondary text-sm">
						This command will download and install the daemon, then start it with your
						configuration.
					</p>
					<CodeContainer
						language="powershell"
						expandable={false}
						code={combinedWindowsCommand}
						onCopy={() => handleCopy('combined-install')}
					/>

					<InlineWarning title={daemons_wslWarning()} body={daemons_wslWarningBody()} />
					<InlineInfo title={daemons_dockerLinuxOnly()} body={daemons_dockerLinuxOnlyBody()} />
				{/if}
			</OsSelector>

			{#if showTroubleshootingPanel}
				<div bind:this={troubleshootingRef} class="pt-4">
					<p class="text-secondary mb-3 text-sm font-medium">Need help?</p>
					<SupportOptions isTroubleshooting={true} {hasEmailSupport} />
				</div>
			{/if}
		{/if}
	{/if}
</div>
