<script lang="ts">
	import { trackEvent } from '$lib/shared/utils/analytics';
	import InlineDanger from '$lib/shared/components/feedback/InlineDanger.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import InlineSuccess from '$lib/shared/components/feedback/InlineSuccess.svelte';
	import type { UseCase } from '../../types/base';
	import {
		onboarding_binaryExecutable,
		onboarding_compatibleBody,
		onboarding_compatibleTitle,
		onboarding_dockerCompose,
		onboarding_dockerLinuxOnlyTitle,
		onboarding_dockerLinuxWarning,
		onboarding_dockerMacWarning,
		onboarding_dockerWindowsWarning,
		onboarding_freebsdNotSupported,
		onboarding_installMethodQuestion,
		onboarding_notSupportedTitle,
		onboarding_openbsdNotSupported,
		onboarding_osNotSupported,
		onboarding_osQuestion
	} from '$lib/paraglide/messages';

	let {
		useCase
	}: {
		useCase: UseCase;
	} = $props();

	type OS = 'linux' | 'macos' | 'windows' | 'freebsd' | 'openbsd' | null;
	type InstallMethod = 'binary' | 'docker' | null;

	let selectedOS: OS = $state(null);
	let selectedMethod: InstallMethod = $state(null);

	const osOptions: { id: OS; label: string }[] = [
		{ id: 'linux', label: 'Linux' },
		{ id: 'macos', label: 'macOS' },
		{ id: 'windows', label: 'Windows' },
		{ id: 'freebsd', label: 'FreeBSD' },
		{ id: 'openbsd', label: 'OpenBSD' }
	];

	let methodOptions = $derived([
		{ id: 'binary' as InstallMethod, label: onboarding_binaryExecutable() },
		{ id: 'docker' as InstallMethod, label: onboarding_dockerCompose() }
	]);

	// Check if OS is unsupported (BSD variants)
	let isUnsupportedOS = $derived(selectedOS === 'freebsd' || selectedOS === 'openbsd');

	// Compatibility matrix
	let compatibility = $derived(getCompatibility(selectedOS, selectedMethod));

	function getCompatibility(
		os: OS,
		method: InstallMethod
	): 'compatible' | 'warning' | 'incompatible' | null {
		if (!os) return null;

		// FreeBSD and OpenBSD are not supported
		if (os === 'freebsd' || os === 'openbsd') {
			return 'incompatible';
		}

		if (!method) return null;

		// Docker Compose is only fully supported on Linux
		if (method === 'docker' && os !== 'linux') {
			return 'warning';
		}

		// All other combinations are compatible
		return 'compatible';
	}

	let warningBody = $derived(
		selectedOS === 'macos'
			? onboarding_dockerMacWarning()
			: selectedOS === 'windows'
				? onboarding_dockerWindowsWarning()
				: onboarding_dockerLinuxWarning()
	);

	let incompatibleBody = $derived(
		selectedOS === 'freebsd'
			? onboarding_freebsdNotSupported()
			: selectedOS === 'openbsd'
				? onboarding_openbsdNotSupported()
				: onboarding_osNotSupported()
	);

	function handleOsSelect(os: OS) {
		selectedOS = os;

		trackEvent('onboarding_compatibility_os_selected', {
			os: selectedOS,
			install_method: selectedMethod,
			result: compatibility,
			use_case: useCase
		});
	}

	function handleInstallSelect(method: InstallMethod) {
		selectedMethod = method;

		trackEvent('onboarding_compatibility_os_selected', {
			os: selectedOS,
			install_method: selectedMethod,
			result: compatibility,
			use_case: useCase
		});
	}
</script>

<div class="space-y-6">
	<!-- OS Selection -->
	<div class="space-y-3" role="group" aria-label="Operating system selection">
		<span class="text-secondary block text-sm font-medium">{onboarding_osQuestion()}</span>
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

	<!-- Install Method Selection (only for supported OSes) -->
	{#if selectedOS && !isUnsupportedOS}
		<div class="space-y-3" role="group" aria-label="Install method selection">
			<span class="text-secondary block text-sm font-medium"
				>{onboarding_installMethodQuestion()}</span
			>
			<div class="flex gap-2">
				{#each methodOptions as option (option.id)}
					<button
						type="button"
						class="btn-secondary flex-1 {selectedMethod === option.id ? 'ring-primary ring-2' : ''}"
						onclick={() => handleInstallSelect(option.id)}
					>
						{option.label}
					</button>
				{/each}
			</div>
		</div>
	{/if}

	<!-- Compatibility Result -->
	{#if compatibility === 'compatible'}
		<InlineSuccess title={onboarding_compatibleTitle()} body={onboarding_compatibleBody()} />
	{:else if compatibility === 'warning'}
		<InlineWarning title={onboarding_dockerLinuxOnlyTitle()} body={warningBody} />
	{:else if compatibility === 'incompatible'}
		<InlineDanger title={onboarding_notSupportedTitle()} body={incompatibleBody} />
	{/if}
</div>
