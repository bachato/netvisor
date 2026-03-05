<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import { validateForm } from '$lib/shared/components/forms/form-context';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import type { ModalTab } from '$lib/shared/components/layout/GenericModal.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { entities } from '$lib/shared/stores/metadata';
	import { SatelliteDish, Settings, KeyRound, Terminal, SlidersHorizontal } from 'lucide-svelte';
	import {
		createEmptyApiKeyFormData,
		useCreateApiKeyMutation
	} from '$lib/features/daemon_api_keys/queries';
	import { useProvisionDaemonMutation } from '../../queries';
	import { useConfigQuery } from '$lib/shared/stores/config-query';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { billingPlans } from '$lib/shared/stores/metadata';
	import { useNetworksQuery } from '$lib/features/networks/queries';
	import {
		buildDefaultValues,
		buildRunCommand,
		buildDockerCompose,
		constructDaemonUrl,
		detectOS,
		type DaemonOS
	} from '../../utils';
	import ConfigureStep from './steps/ConfigureStep.svelte';
	import ApiKeyStep from './steps/ApiKeyStep.svelte';
	import InstallStep from './steps/InstallStep.svelte';
	import AdvancedStep from './steps/AdvancedStep.svelte';
	import {
		common_advanced,
		common_apiKey,
		common_back,
		common_close,
		common_configure,
		common_continue,
		common_failedGenerateApiKey,
		common_install,
		common_next,
		daemons_createDaemon,
		daemons_enterApiKey,
		daemons_generateKeyToContinue,
		daemons_setupScanning,
		daemons_doThisLater
	} from '$lib/paraglide/messages';

	interface Props {
		isOpen?: boolean;
		onClose: () => void;
		onboardingMode?: boolean;
		onSkip?: (() => void) | null;
		onContinue?: (() => void) | null;
		provisionalApiKey?: string | null;
		provisionalNetworkId?: string | null;
		name?: string;
	}

	let {
		isOpen = false,
		onClose,
		onboardingMode = false,
		onSkip = null,
		onContinue = null,
		provisionalApiKey = null,
		provisionalNetworkId = null,
		name = undefined
	}: Props = $props();

	// Queries & mutations
	const networksQuery = useNetworksQuery();
	const configQuery = useConfigQuery();
	const currentUserQuery = useCurrentUserQuery();
	const organizationQuery = useOrganizationQuery();
	const createApiKeyMutation = useCreateApiKeyMutation();
	const provisionDaemonMutation = useProvisionDaemonMutation();

	// Derived data
	let networksData = $derived(networksQuery.data ?? []);
	let serverUrl = $derived(configQuery.data?.public_url ?? '');
	let currentUserId = $derived(currentUserQuery.data?.id ?? null);
	let org = $derived(organizationQuery.data);
	let hasDaemonPoll = $derived.by(() => {
		if (!org?.plan?.type) return true;
		return billingPlans.getMetadata(org.plan.type).features.daemon_poll;
	});
	let isFirstDaemon = $derived(!org?.onboarding?.includes('FirstDaemonRegistered'));

	// Network selection
	let selectedNetworkId = $state('');

	$effect(() => {
		if (onboardingMode && provisionalNetworkId) {
			selectedNetworkId = provisionalNetworkId;
		} else if (!selectedNetworkId && networksData[0]?.id) {
			selectedNetworkId = networksData[0].id;
		}
	});

	// API key state
	let keyState = $state<string | null>(null);
	let key = $derived(onboardingMode ? provisionalApiKey : keyState);
	let keySet = $derived(!!key);

	// OS selection
	let selectedOS: DaemonOS = $state(detectOS());

	// TanStack Form
	const form = createForm(() => ({
		defaultValues: buildDefaultValues(),
		onSubmit: async () => {
			// No-op; submission is handled by step navigation
		}
	}));

	// Reactive form values (form.state.values is NOT tracked by $derived)
	let formValues = $state<Record<string, string | number | boolean>>(buildDefaultValues());

	$effect(() => {
		return form.store.subscribe(() => {
			formValues = { ...form.state.values } as Record<string, string | number | boolean>;
		});
	});

	// Derived commands
	let runCommand = $derived(
		buildRunCommand(serverUrl, selectedNetworkId, key, formValues, null, currentUserId, selectedOS)
	);
	let dockerCompose = $derived(
		key ? buildDockerCompose(serverUrl, selectedNetworkId, key, formValues, currentUserId) : ''
	);

	// Check for form validation errors
	let hasErrors = $derived.by(() => {
		const fieldMeta = form.state.fieldMeta;
		for (const fieldKey of Object.keys(fieldMeta)) {
			const meta = fieldMeta[fieldKey];
			if (meta?.errors && meta.errors.length > 0) {
				return true;
			}
		}
		return false;
	});

	// --- Tab / wizard state ---
	const mainFlow = ['configure', 'api-key', 'install'] as const;

	let activeTab = $state('configure');
	let previousMainTab = $state('configure');
	let furthestReached = $state(0);

	let tabs: ModalTab[] = $derived([
		{ id: 'configure', label: common_configure(), icon: Settings },
		{ id: 'api-key', label: common_apiKey(), icon: KeyRound, disabled: furthestReached < 1 },
		{ id: 'install', label: common_install(), icon: Terminal, disabled: furthestReached < 2 },
		{
			id: 'advanced',
			label: common_advanced(),
			icon: SlidersHorizontal,
			disabled: furthestReached < 2
		}
	]);

	let isOnAdvanced = $derived(activeTab === 'advanced');

	function nextTab() {
		const idx = mainFlow.indexOf(activeTab as (typeof mainFlow)[number]);
		if (idx >= 0 && idx < mainFlow.length - 1) {
			activeTab = mainFlow[idx + 1];
		}
	}

	function previousTab() {
		if (isOnAdvanced) {
			activeTab = previousMainTab;
			return;
		}
		const idx = mainFlow.indexOf(activeTab as (typeof mainFlow)[number]);
		if (idx > 0) {
			activeTab = mainFlow[idx - 1];
		}
	}

	function handleTabChange(tabId: string) {
		// Track where we came from (for Back from Advanced)
		if (tabId === 'advanced' && activeTab !== 'advanced') {
			previousMainTab = activeTab;
		}
		activeTab = tabId;
	}

	// --- Key generation ---
	async function handleCreateNewApiKey() {
		const isValid = await validateForm(form);
		if (!isValid) return;

		const daemonName = (form.state.values['name'] as string) ?? 'daemon';
		const mode = (form.state.values['mode'] as string) ?? 'daemon_poll';
		const daemonUrlBase = (form.state.values['daemonUrl'] as string) ?? '';
		const daemonPort = (() => {
			const port = form.state.values['daemonPort'];
			return typeof port === 'number' ? port : 60073;
		})();

		if (mode === 'server_poll') {
			const fullDaemonUrl = constructDaemonUrl(daemonUrlBase, daemonPort);
			try {
				const result = await provisionDaemonMutation.mutateAsync({
					name: daemonName,
					network_id: selectedNetworkId,
					url: fullDaemonUrl
				});
				keyState = result.daemon_api_key;
			} catch {
				pushError(common_failedGenerateApiKey());
			}
		} else {
			let newApiKey = createEmptyApiKeyFormData(selectedNetworkId);
			newApiKey.name = `${daemonName} Api Key`;
			try {
				const result = await createApiKeyMutation.mutateAsync(newApiKey);
				keyState = result.keyString;
			} catch {
				pushError(common_failedGenerateApiKey());
			}
		}
	}

	async function handleUseExistingKey() {
		const isValid = await validateForm(form);
		if (!isValid) return;

		const trimmedKey = ((form.state.values['existingKeyInput'] as string) ?? '').trim();
		if (!trimmedKey) {
			pushError(daemons_enterApiKey());
			return;
		}
		keyState = trimmedKey;
	}

	// --- Navigation handlers ---
	async function handleNext() {
		if (activeTab === 'configure') {
			const isValid = await validateForm(form);
			if (isValid) {
				if (furthestReached < 1) furthestReached = 1;
				nextTab();
			}
		} else if (activeTab === 'api-key') {
			if (!key) {
				pushError(daemons_generateKeyToContinue());
				return;
			}
			if (furthestReached < 2) furthestReached = 2;
			nextTab();
		}
	}

	function handleOnClose() {
		keyState = null;
		activeTab = 'configure';
		previousMainTab = 'configure';
		furthestReached = 0;
		onClose();
	}

	// --- Onboarding: skip to install when provisionalApiKey provided ---
	function handleOpen() {
		if (onboardingMode && provisionalApiKey) {
			activeTab = 'install';
			furthestReached = 2;
		} else {
			activeTab = 'configure';
			furthestReached = 0;
		}
		previousMainTab = 'configure';
	}

	let colorHelper = entities.getColorHelper('Daemon');
	let title = $derived(onboardingMode ? daemons_setupScanning() : daemons_createDaemon());
	let showTabs = $derived(!onboardingMode || !!key);
</script>

<GenericModal
	{isOpen}
	{title}
	{name}
	size="full"
	fixedHeight={true}
	onClose={handleOnClose}
	onOpen={handleOpen}
	showCloseButton={!onboardingMode}
	showBackdrop={!onboardingMode}
	tabs={showTabs ? tabs : []}
	{activeTab}
	onTabChange={handleTabChange}
>
	{#snippet headerIcon()}
		{#if onboardingMode}
			<ModalHeaderIcon Icon={SatelliteDish} color="Green" />
		{:else}
			<ModalHeaderIcon Icon={entities.getIconComponent('Daemon')} color={colorHelper.color} />
		{/if}
	{/snippet}

	<div class="flex min-h-0 flex-1 flex-col">
		<div class="flex-1 overflow-auto p-6">
			{#if activeTab === 'configure'}
				<ConfigureStep
					{form}
					{formValues}
					{selectedNetworkId}
					onNetworkChange={(id) => (selectedNetworkId = id)}
					{hasDaemonPoll}
					{keySet}
					{onboardingMode}
				/>
			{/if}

			{#if activeTab === 'api-key'}
				<ApiKeyStep
					{form}
					{formValues}
					apiKey={key}
					{keySet}
					isServerPoll={formValues.mode === 'server_poll'}
					onGenerateKey={handleCreateNewApiKey}
					onUseExistingKey={handleUseExistingKey}
				/>
			{/if}

			{#if activeTab === 'install'}
				<InstallStep
					{selectedOS}
					onOsSelect={(os) => (selectedOS = os)}
					{runCommand}
					{dockerCompose}
					{hasErrors}
					{isFirstDaemon}
				/>
			{/if}

			{#if activeTab === 'advanced'}
				<AdvancedStep {form} {formValues} />
			{/if}
		</div>

		<!-- Footer -->
		<div class="modal-footer">
			{#if onboardingMode}
				<div class="flex w-full items-center justify-between gap-4">
					{#if onSkip}
						<button type="button" class="btn-secondary" onclick={onSkip}>
							{daemons_doThisLater()}
						</button>
					{/if}
					<button type="button" class="btn-primary ml-auto" onclick={onContinue ?? handleOnClose}>
						{common_continue()}
					</button>
				</div>
			{:else}
				<div class="flex items-center justify-end gap-3">
					{#if activeTab === 'configure'}
						<button type="button" class="btn-primary" onclick={handleNext}>
							{common_next()}
						</button>
					{:else if activeTab === 'api-key'}
						<button type="button" class="btn-secondary" onclick={previousTab}>
							{common_back()}
						</button>
						<button type="button" class="btn-primary" onclick={handleNext} disabled={!key}>
							{common_next()}
						</button>
					{:else if activeTab === 'install'}
						<button type="button" class="btn-secondary" onclick={previousTab}>
							{common_back()}
						</button>
						<button type="button" class="btn-secondary" onclick={handleOnClose}>
							{common_close()}
						</button>
					{:else if activeTab === 'advanced'}
						<button type="button" class="btn-secondary" onclick={previousTab}>
							{common_back()}
						</button>
					{/if}
				</div>
			{/if}
		</div>
	</div>
</GenericModal>
