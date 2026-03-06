<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import { validateForm } from '$lib/shared/components/forms/form-context';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import type { ModalTab } from '$lib/shared/components/layout/GenericModal.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { entities } from '$lib/shared/stores/metadata';
	import { Settings, KeyRound, Terminal, SlidersHorizontal, Loader2 } from 'lucide-svelte';
	import {
		createEmptyApiKeyFormData,
		useCreateApiKeyMutation
	} from '$lib/features/daemon_api_keys/queries';
	import { useProvisionDaemonMutation } from '../../queries';
	import { useConfigQuery } from '$lib/shared/stores/config-query';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { billingPlans } from '$lib/shared/stores/metadata';
	import {
		buildDefaultValues,
		buildRunCommand,
		buildDockerCompose,
		constructDaemonUrl,
		detectOS,
		slugifyNetworkName,
		type DaemonOS
	} from '../../utils';
	import { useNetworksQuery } from '$lib/features/networks/queries';
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
		common_failedGenerateApiKey,
		common_install,
		common_next,
		daemons_createDaemon,
		daemons_enterApiKey,
		daemons_generateKeyToContinue
	} from '$lib/paraglide/messages';

	interface Props {
		isOpen?: boolean;
		onClose: () => void;
		name?: string;
	}

	let { isOpen = false, onClose, name = undefined }: Props = $props();

	// Queries & mutations
	const configQuery = useConfigQuery();
	const currentUserQuery = useCurrentUserQuery();
	const organizationQuery = useOrganizationQuery();
	const createApiKeyMutation = useCreateApiKeyMutation();
	const provisionDaemonMutation = useProvisionDaemonMutation();

	// Derived data
	let serverUrl = $derived(configQuery.data?.public_url ?? '');
	let currentUserId = $derived(currentUserQuery.data?.id ?? null);
	let org = $derived(organizationQuery.data);
	let hasDaemonPoll = $derived.by(() => {
		if (!org?.plan?.type) return true;
		return billingPlans.getMetadata(org.plan.type).features.daemon_poll;
	});
	let isFirstDaemon = $derived(!org?.onboarding?.includes('FirstDaemonRegistered'));

	// Networks
	const networksQuery = useNetworksQuery();
	let networksData = $derived(networksQuery.data ?? []);

	// Network selection
	let selectedNetworkId = $state('');
	let nameManuallyEdited = $state(false);

	// API key state
	let keyState = $state<string | null>(null);
	let key = $derived(keyState);
	let keySet = $derived(!!key);

	// Auto-generation state (for first daemon flow)
	let isAutoGenerating = $state(false);

	// OS selection
	let selectedOS: DaemonOS = $state(detectOS());

	function getDefaultDaemonName(networkId: string): string {
		const network = networksData.find((n) => n.id === networkId);
		if (network) {
			const slug = slugifyNetworkName(network.name);
			if (slug) return `scanopy-daemon-${slug}`;
		}
		return 'scanopy-daemon';
	}

	$effect(() => {
		if (selectedNetworkId && !nameManuallyEdited) {
			const defaultName = getDefaultDaemonName(selectedNetworkId);
			form.setFieldValue('name', defaultName);
		}
	});

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
	let mainFlow = $derived(
		isFirstDaemon
			? (['configure', 'install'] as const)
			: (['configure', 'api-key', 'install'] as const)
	);

	let activeTab = $state('configure');
	let previousMainTab = $state('configure');
	let furthestReached = $state(0);

	let tabs: ModalTab[] = $derived([
		{ id: 'configure', label: common_configure(), icon: Settings },
		...(isFirstDaemon
			? []
			: [
					{
						id: 'api-key',
						label: common_apiKey(),
						icon: KeyRound,
						disabled: furthestReached < 1
					}
				]),
		{
			id: 'install',
			label: common_install(),
			icon: Terminal,
			disabled: furthestReached < (isFirstDaemon ? 1 : 2)
		},
		{
			id: 'advanced',
			label: common_advanced(),
			icon: SlidersHorizontal,
			disabled: furthestReached < (isFirstDaemon ? 1 : 2)
		}
	]);

	let isOnAdvanced = $derived(activeTab === 'advanced');

	function nextTab() {
		const idx = (mainFlow as readonly string[]).indexOf(activeTab);
		if (idx >= 0 && idx < mainFlow.length - 1) {
			activeTab = mainFlow[idx + 1];
		}
	}

	function previousTab() {
		if (isOnAdvanced) {
			activeTab = previousMainTab;
			return;
		}
		const idx = (mainFlow as readonly string[]).indexOf(activeTab);
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

			if (!isValid) return;

			trackEvent('daemon_wizard_step_completed', { step: 'configure' });

			if (isFirstDaemon && !key) {
				isAutoGenerating = true;
				try {
					await handleCreateNewApiKey();
				} finally {
					isAutoGenerating = false;
				}
				if (!keyState) return; // generation failed
			}

			if (furthestReached < 1) furthestReached = 1;
			nextTab();
		} else if (activeTab === 'api-key') {
			if (!key) {
				pushError(daemons_generateKeyToContinue());
				return;
			}
			trackEvent('daemon_wizard_step_completed', { step: 'api-key' });
			if (furthestReached < 2) furthestReached = 2;
			nextTab();
		}
	}

	function handleOnClose() {
		trackEvent('daemon_wizard_closed');
		keyState = null;
		isAutoGenerating = false;
		nameManuallyEdited = false;
		activeTab = 'configure';
		previousMainTab = 'configure';
		furthestReached = 0;
		onClose();
	}

	function handleOpen() {
		trackEvent('daemon_wizard_opened');
		nameManuallyEdited = false;
		activeTab = 'configure';
		furthestReached = 0;
		previousMainTab = 'configure';
	}

	let colorHelper = entities.getColorHelper('Daemon');
	let title = daemons_createDaemon();
</script>

<GenericModal
	{isOpen}
	{title}
	{name}
	size="full"
	fixedHeight={true}
	onClose={handleOnClose}
	onOpen={handleOpen}
	{tabs}
	{activeTab}
	onTabChange={handleTabChange}
>
	{#snippet headerIcon()}
		<ModalHeaderIcon Icon={entities.getIconComponent('Daemon')} color={colorHelper.color} />
	{/snippet}

	<div class="flex min-h-0 flex-1 flex-col">
		<div class="flex-1 overflow-auto p-6">
			{#if activeTab === 'configure'}
				<ConfigureStep
					{form}
					{formValues}
					{selectedNetworkId}
					onNetworkChange={(id) => (selectedNetworkId = id)}
					onNameInput={() => (nameManuallyEdited = true)}
					{hasDaemonPoll}
					{keySet}
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
			<div class="flex items-center justify-end gap-3">
				{#if activeTab === 'configure'}
					<button
						type="button"
						class="btn-primary"
						onclick={handleNext}
						disabled={isAutoGenerating}
					>
						{#if isAutoGenerating}
							<Loader2 class="h-4 w-4 animate-spin" />
						{:else}
							{common_next()}
						{/if}
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
		</div>
	</div>
</GenericModal>
