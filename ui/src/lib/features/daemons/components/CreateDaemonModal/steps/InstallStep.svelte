<script lang="ts">
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import DocsHint from '$lib/shared/components/feedback/DocsHint.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import SupportOptions from '$lib/features/support/SupportOptions.svelte';
	import { useConfigQuery } from '$lib/shared/stores/config-query';
	import type { DaemonOS } from '../../../utils';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { useTestReachabilityMutation } from '../../../queries';
	import OsSelector from '../../OsSelector.svelte';
	import { Loader2, CheckCircle2, AlertTriangle, SlidersHorizontal, XCircle } from 'lucide-svelte';
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
		daemonUrl = ''
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

	// ServerPoll health check for trouble state
	const healthCheckMutation = useTestReachabilityMutation();
	let healthResult = $state<{ reachable: boolean; health?: boolean; error?: string } | null>(null);

	async function handleHealthCheck() {
		if (!daemonUrl) return;
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
		} catch {
			healthResult = { reachable: false, error: 'Failed to test reachability' };
		}
	}

	// Auto-poll health check for ServerPoll when waiting
	let healthPollInterval = $state<ReturnType<typeof setInterval> | null>(null);
	$effect(() => {
		if (connectionStatus === 'waiting' && daemonMode === 'server_poll' && daemonUrl) {
			handleHealthCheck();
			healthPollInterval = setInterval(handleHealthCheck, 10_000);
			return () => {
				if (healthPollInterval) clearInterval(healthPollInterval);
			};
		}
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
				<Loader2 class="text-primary h-10 w-10 animate-spin" />
				<div>
					<h3 class="text-primary text-base font-semibold">
						Waiting for your daemon to connect...
					</h3>
					<p class="text-secondary mt-1 text-sm">
						This usually takes less than a minute. Make sure the daemon is running.
					</p>
				</div>
				{#if daemonMode === 'server_poll' && healthResult}
					<div class="text-sm">
						{#if healthResult.reachable && healthResult.health}
							<span class="flex items-center gap-1 text-green-400">
								<CheckCircle2 class="h-4 w-4" />
								Daemon is running and reachable
							</span>
						{:else if healthResult.reachable && healthResult.health === false}
							<span class="flex items-center gap-1 text-yellow-400">
								<AlertTriangle class="h-4 w-4" />
								Port is open but daemon may still be starting...
							</span>
						{:else if !healthResult.reachable}
							<span class="flex items-center gap-1 text-red-400">
								<XCircle class="h-4 w-4" />
								Port not reachable — check firewall and port forwarding
							</span>
						{/if}
					</div>
				{/if}
				<button type="button" class="btn-link text-sm" onclick={() => onReviewCommands?.()}>
					Review install commands
				</button>
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
				<ul class="text-secondary space-y-1 text-left text-sm">
					<li>Check that the daemon process is running</li>
					<li>Verify the server URL in the daemon config matches this server</li>
					<li>Check that no firewall is blocking the connection</li>
				</ul>
				{#if daemonMode === 'server_poll' && daemonUrl}
					<div class="flex items-center gap-3">
						<button
							type="button"
							class="btn-secondary text-sm"
							disabled={healthCheckMutation.isPending}
							onclick={handleHealthCheck}
						>
							{#if healthCheckMutation.isPending}
								<Loader2 class="h-4 w-4 animate-spin" />
							{/if}
							Test Daemon Reachability
						</button>
						{#if healthResult}
							{#if healthResult.reachable && healthResult.health}
								<span class="flex items-center gap-1 text-sm text-green-400">
									<CheckCircle2 class="h-4 w-4" />
									Daemon is reachable and healthy
								</span>
							{:else if healthResult.reachable}
								<span class="flex items-center gap-1 text-sm text-yellow-400">
									<AlertTriangle class="h-4 w-4" />
									Port open but health check failed
								</span>
							{:else}
								<span class="flex items-center gap-1 text-sm text-red-400">
									<XCircle class="h-4 w-4" />
									{healthResult.error ?? 'Not reachable'}
								</span>
							{/if}
						{/if}
					</div>
				{/if}
				<DocsHint
					text="See our %link% for common solutions."
					href="https://scanopy.net/docs/setting-up-daemons/troubleshooting-setup/"
					linkText="troubleshooting guide"
				/>
				<button type="button" class="btn-link text-sm" onclick={() => onReviewCommands?.()}>
					Review install commands
				</button>
			</div>
			<SupportOptions isTroubleshooting={true} {hasEmailSupport} />
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
					<CodeContainer
						language="bash"
						expandable={false}
						code={combinedLinuxMacCommand}
						onCopy={() => handleCopy('combined-install')}
					/>

					<InlineInfo title={daemons_dockerLinuxOnly()} body={daemons_dockerLinuxOnlyBody()} />
				{:else if selectedOS === 'windows'}
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
