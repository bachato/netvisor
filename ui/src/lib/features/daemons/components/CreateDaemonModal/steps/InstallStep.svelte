<script lang="ts">
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import type { DaemonOS } from '../../../utils';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import {
		common_binary,
		common_docker,
		common_linux,
		common_macos,
		common_stepNumber,
		common_windows,
		daemons_advancedHint,
		daemons_dockerLinuxOnly,
		daemons_dockerLinuxOnlyBody,
		daemons_docsMacvlan,
		daemons_docsMultiVlan,
		daemons_downloadDaemon,
		daemons_fixValidationErrors,
		daemons_fixValidationErrorsBody,
		daemons_operatingSystem,
		daemons_requestOsSupport,
		daemons_runDaemon,
		daemons_runInPowershell,
		daemons_wslWarning,
		daemons_wslWarningBody,
		onboarding_freebsdNotSupported,
		onboarding_notSupportedTitle,
		onboarding_openbsdNotSupported
	} from '$lib/paraglide/messages';
	import { useConfigQuery } from '$lib/shared/stores/config-query';

	interface Props {
		selectedOS: DaemonOS;
		onOsSelect: (os: DaemonOS) => void;
		runCommand: string;
		dockerCompose: string;
		hasErrors: boolean;
	}

	let { selectedOS, onOsSelect, runCommand, dockerCompose, hasErrors }: Props = $props();

	type LinuxMethod = 'binary' | 'docker';
	let linuxMethod: LinuxMethod = $state('binary');

	let linuxMethodOptions = $derived([
		{ id: 'binary' as LinuxMethod, label: common_binary() },
		{ id: 'docker' as LinuxMethod, label: common_docker() }
	]);

	let osOptions = $derived([
		{ id: 'linux' as DaemonOS, label: common_linux() },
		{ id: 'macos' as DaemonOS, label: common_macos() },
		{ id: 'windows' as DaemonOS, label: common_windows() },
		{ id: 'freebsd' as DaemonOS, label: 'FreeBSD' },
		{ id: 'openbsd' as DaemonOS, label: 'OpenBSD' }
	]);

	const windowsDownloadUrl =
		'https://github.com/scanopy/scanopy/releases/latest/download/scanopy-daemon-windows-amd64.exe';
	const windowsInstallCommand = `Invoke-WebRequest -Uri "${windowsDownloadUrl}" -OutFile "scanopy-daemon-windows-amd64.exe"`;
	const installScript = `bash -c "$(curl -fsSL https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh)"`;

	const configQuery = useConfigQuery();
	let hasPosthog = $derived(!!configQuery.data?.posthog_key);
	let requestedOs = $state(new Set<string>());

	function handleOsSelect(os: DaemonOS) {
		onOsSelect(os);
		trackEvent('daemon_install_os_selected', { os });
	}

	function handleRequestOsSupport(os: string) {
		trackEvent('daemon_os_support_requested', { os });
		requestedOs = new Set([...requestedOs, os]);
	}
</script>

<div class="space-y-4">
	<!-- Hint about Advanced tab -->
	<InlineInfo title="" body={daemons_advancedHint()} dismissableKey="daemon-wizard-advanced-hint" />

	{#if hasErrors}
		<InlineWarning title={daemons_fixValidationErrors()} body={daemons_fixValidationErrorsBody()} />
	{:else}
		<!-- OS Selector -->
		<div class="space-y-3" role="group" aria-label={daemons_operatingSystem()}>
			<span class="text-secondary block text-sm font-medium">{daemons_operatingSystem()}</span>
			<!-- eslint-disable-next-line svelte/no-at-html-tags -- trusted i18n content -->
			<p class="docs-hint text-tertiary text-xs">{@html daemons_docsMultiVlan()}</p>
			<div class="flex gap-2">
				{#each osOptions as option (option.id)}
					<button
						type="button"
						class="btn-secondary flex-1 {selectedOS === option.id ? 'ring-primary ring-2' : ''}"
						onclick={() => handleOsSelect(option.id)}
					>
						{option.label}
					</button>
				{/each}
			</div>
		</div>

		{#if selectedOS === 'linux'}
			<!-- Linux: Install method sub-toggle, sized to match the Linux OS button -->
			<div class="flex gap-1" style="width: calc((100% - 4 * 0.5rem) / 5)">
				{#each linuxMethodOptions as option (option.id)}
					<button
						type="button"
						class="btn-secondary btn-sm flex-1 {linuxMethod === option.id
							? 'ring-primary ring-2'
							: ''}"
						onclick={() => (linuxMethod = option.id)}
					>
						{option.label}
					</button>
				{/each}
			</div>

			{#if linuxMethod === 'binary'}
				<!-- Linux Binary: install script + run command -->
				<div class="text-secondary">
					<b>{common_stepNumber({ number: '1' })}</b>
					{daemons_downloadDaemon()}
				</div>
				<CodeContainer language="bash" expandable={false} code={installScript} />
				<div class="text-secondary">
					<b>{common_stepNumber({ number: '2' })}</b>
					{daemons_runDaemon()}
				</div>
				<CodeContainer language="bash" expandable={false} code={runCommand} />
			{:else if linuxMethod === 'docker' && dockerCompose}
				<!-- Linux Docker Compose -->
				<!-- eslint-disable-next-line svelte/no-at-html-tags -- trusted i18n content -->
				<p class="docs-hint text-tertiary text-xs">{@html daemons_docsMacvlan()}</p>
				<CodeContainer language="yaml" expandable={false} code={dockerCompose} />
			{/if}
		{:else if selectedOS === 'macos'}
			<!-- macOS: install script + run command -->
			<div class="text-secondary">
				<b>{common_stepNumber({ number: '1' })}</b>
				{daemons_downloadDaemon()}
			</div>
			<CodeContainer language="bash" expandable={false} code={installScript} />
			<div class="text-secondary">
				<b>{common_stepNumber({ number: '2' })}</b>
				{daemons_runDaemon()}
			</div>
			<CodeContainer language="bash" expandable={false} code={runCommand} />

			<InlineInfo title={daemons_dockerLinuxOnly()} body={daemons_dockerLinuxOnlyBody()} />
		{:else if selectedOS === 'windows'}
			<!-- Windows: Step 1 - Download -->
			<div class="text-secondary">
				<b>{common_stepNumber({ number: '1' })}</b>
				{daemons_downloadDaemon()}
			</div>
			<CodeContainer language="powershell" expandable={false} code={windowsInstallCommand} />

			<!-- Windows: Step 2 - Run -->
			<div class="text-secondary">
				<b>{common_stepNumber({ number: '2' })}</b>
				{daemons_runInPowershell()}
			</div>
			<CodeContainer language="powershell" expandable={false} code={runCommand} />

			<!-- Windows: WSL warning -->
			<InlineWarning title={daemons_wslWarning()} body={daemons_wslWarningBody()} />
			<InlineInfo title={daemons_dockerLinuxOnly()} body={daemons_dockerLinuxOnlyBody()} />
		{:else if selectedOS === 'freebsd'}
			<InlineWarning
				title={onboarding_notSupportedTitle()}
				body={onboarding_freebsdNotSupported()}
			/>
			{#if hasPosthog}
				<button
					type="button"
					class="btn-secondary btn-sm"
					disabled={requestedOs.has('freebsd')}
					onclick={() => handleRequestOsSupport('freebsd')}
				>
					{requestedOs.has('freebsd') ? '✓' : ''}
					{daemons_requestOsSupport({ os: 'FreeBSD' })}
				</button>
			{/if}
		{:else if selectedOS === 'openbsd'}
			<InlineWarning
				title={onboarding_notSupportedTitle()}
				body={onboarding_openbsdNotSupported()}
			/>
			{#if hasPosthog}
				<button
					type="button"
					class="btn-secondary btn-sm"
					disabled={requestedOs.has('openbsd')}
					onclick={() => handleRequestOsSupport('openbsd')}
				>
					{requestedOs.has('openbsd') ? '✓' : ''}
					{daemons_requestOsSupport({ os: 'OpenBSD' })}
				</button>
			{/if}
		{/if}
	{/if}
</div>

<style>
	.docs-hint :global(a) {
		color: var(--color-blue-500, #3b82f6);
	}
	.docs-hint :global(a:hover) {
		text-decoration: underline;
	}
</style>
