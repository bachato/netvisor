<script lang="ts">
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { ArrowBigUpDash } from 'lucide-svelte';
	import type { Daemon } from '../types/base';
	import { VERSION } from '$lib/version';
	import { type DaemonOS, detectOS } from '../utils';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import OsSelector from './OsSelector.svelte';
	import {
		common_close,
		common_stepNumber,
		daemons_currentVersion,
		daemons_dockerApplyChanges,
		daemons_dockerLatestTag,
		daemons_dockerLinuxOnly,
		daemons_dockerLinuxOnlyBody,
		daemons_dockerPinnedVersion,
		daemons_latestVersion,
		daemons_updateAvailable,
		daemons_upgradeDownload,
		daemons_upgradeDaemon,
		daemons_upgradeRestartProcess,
		daemons_upgradeRestartSystemd
	} from '$lib/paraglide/messages';

	interface Props {
		isOpen?: boolean;
		onClose: () => void;
		daemon: Daemon;
	}

	let { isOpen = false, onClose, daemon }: Props = $props();

	// OS selection state
	let selectedOS: DaemonOS = $state(detectOS());

	type LinuxMethod = 'binary' | 'docker';
	let linuxMethod: LinuxMethod = $state('binary');

	// Commands for upgrading
	const binaryUpgradeCommand = `bash -c "$(curl -fsSL https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh)"`;
	const systemdRestart = 'sudo systemctl restart scanopy-daemon';

	const windowsDownloadUrl =
		'https://github.com/scanopy/scanopy/releases/latest/download/scanopy-daemon-windows-amd64.exe';
	const windowsDownloadCommand = `Invoke-WebRequest -Uri "${windowsDownloadUrl}" -OutFile "scanopy-daemon-windows-amd64.exe"`;

	const dockerComposeLatestPull = `docker compose pull
docker compose up -d`;
	const dockerComposeImageLine = `image: ghcr.io/scanopy/scanopy/daemon:latest`;

	function handleOsSelect(os: DaemonOS) {
		selectedOS = os;
		trackEvent('daemon_upgrade_os_selected', { os });
	}

	let colorHelper = entities.getColorHelper('Daemon');
</script>

<GenericModal {isOpen} title={daemons_upgradeDaemon()} size="lg" {onClose}>
	{#snippet headerIcon()}
		<ModalHeaderIcon Icon={ArrowBigUpDash} color={colorHelper.color} />
	{/snippet}

	<div class="flex min-h-0 flex-1 flex-col">
		<div class="flex-1 overflow-auto p-6">
			<div class="space-y-6">
				<p class="text-secondary">
					{daemons_updateAvailable()} <span class="text-primary font-medium">{daemon.name}</span>.
					{#if daemon.version_status.version}
						{daemons_currentVersion()}
						<span class="font-mono">{daemon.version_status.version}.</span>
					{/if}
					{daemons_latestVersion()} <span class="font-mono">{VERSION}.</span>
				</p>

				<OsSelector
					{selectedOS}
					onOsSelect={handleOsSelect}
					{linuxMethod}
					onLinuxMethodChange={(method) => (linuxMethod = method)}
				>
					{#if selectedOS === 'linux'}
						{#if linuxMethod === 'binary'}
							<!-- Linux Binary: download + systemd restart -->
							<div class="space-y-3">
								<div class="text-secondary">
									<b>{common_stepNumber({ number: '1' })}</b>
									{daemons_upgradeDownload()}
								</div>
								<CodeContainer language="bash" expandable={false} code={binaryUpgradeCommand} />
								<div class="text-secondary">
									<b>{common_stepNumber({ number: '2' })}</b>
									{daemons_upgradeRestartSystemd()}
								</div>
								<CodeContainer language="bash" expandable={false} code={systemdRestart} />
							</div>
						{:else if linuxMethod === 'docker'}
							<!-- Linux Docker Compose -->
							<div class="space-y-3">
								<div class="space-y-2">
									<p class="text-secondary text-sm">
										{daemons_dockerLatestTag()}
									</p>
									<CodeContainer
										language="bash"
										expandable={false}
										code={dockerComposeLatestPull}
									/>
								</div>

								<div class="space-y-2">
									<p class="text-secondary text-sm">
										{daemons_dockerPinnedVersion()}
										<span class="font-mono">docker-compose.yml</span>:
									</p>
									<CodeContainer language="yaml" expandable={false} code={dockerComposeImageLine} />
									<p class="text-secondary text-sm">
										{daemons_dockerApplyChanges()}
									</p>
								</div>
							</div>
						{/if}
					{:else if selectedOS === 'macos'}
						<!-- macOS: download + restart info -->
						<div class="space-y-3">
							<div class="text-secondary">
								<b>{common_stepNumber({ number: '1' })}</b>
								{daemons_upgradeDownload()}
							</div>
							<CodeContainer language="bash" expandable={false} code={binaryUpgradeCommand} />
							<div class="text-secondary">
								<b>{common_stepNumber({ number: '2' })}</b>
								{daemons_upgradeRestartProcess()}
							</div>

							<InlineInfo title={daemons_dockerLinuxOnly()} body={daemons_dockerLinuxOnlyBody()} />
						</div>
					{:else if selectedOS === 'windows'}
						<!-- Windows: PowerShell download + restart info -->
						<div class="space-y-3">
							<div class="text-secondary">
								<b>{common_stepNumber({ number: '1' })}</b>
								{daemons_upgradeDownload()}
							</div>
							<CodeContainer
								language="powershell"
								expandable={false}
								code={windowsDownloadCommand}
							/>
							<div class="text-secondary">
								<b>{common_stepNumber({ number: '2' })}</b>
								{daemons_upgradeRestartProcess()}
							</div>

							<InlineInfo title={daemons_dockerLinuxOnly()} body={daemons_dockerLinuxOnlyBody()} />
						</div>
					{/if}
				</OsSelector>
			</div>
		</div>

		<!-- Footer -->
		<div class="modal-footer">
			<div class="flex items-center justify-end">
				<button type="button" class="btn-secondary" onclick={onClose}>{common_close()}</button>
			</div>
		</div>
	</div>
</GenericModal>
