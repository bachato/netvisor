<script lang="ts">
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import type { DaemonOS } from '../../../utils';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import OsSelector from '../../OsSelector.svelte';
	import {
		common_stepNumber,
		daemons_advancedHint,
		daemons_dockerLinuxOnly,
		daemons_dockerLinuxOnlyBody,
		daemons_docsMacvlan,
		daemons_docsMultiVlan,
		daemons_downloadDaemon,
		daemons_fixValidationErrors,
		daemons_fixValidationErrorsBody,
		daemons_runDaemon,
		daemons_runInPowershell,
		daemons_wslWarning,
		daemons_wslWarningBody
	} from '$lib/paraglide/messages';

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

	const windowsDownloadUrl =
		'https://github.com/scanopy/scanopy/releases/latest/download/scanopy-daemon-windows-amd64.exe';
	const windowsInstallCommand = `Invoke-WebRequest -Uri "${windowsDownloadUrl}" -OutFile "scanopy-daemon-windows-amd64.exe"`;
	const installScript = `bash -c "$(curl -fsSL https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh)"`;

	function handleOsSelect(os: DaemonOS) {
		onOsSelect(os);
		trackEvent('daemon_install_os_selected', { os });
	}
</script>

<div class="space-y-4">
	<!-- Hint about Advanced tab -->
	<InlineInfo title="" body={daemons_advancedHint()} dismissableKey="daemon-wizard-advanced-hint" />

	{#if hasErrors}
		<InlineWarning title={daemons_fixValidationErrors()} body={daemons_fixValidationErrorsBody()} />
	{:else}
		<!-- eslint-disable-next-line svelte/no-at-html-tags -- trusted i18n content -->
		<p class="docs-hint text-tertiary text-xs">{@html daemons_docsMultiVlan()}</p>
		<OsSelector
			{selectedOS}
			onOsSelect={handleOsSelect}
			{linuxMethod}
			onLinuxMethodChange={(method) => (linuxMethod = method)}
		>
			{#if selectedOS === 'linux'}
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
			{/if}
		</OsSelector>
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
