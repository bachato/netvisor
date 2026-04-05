<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import { submitForm, validateForm } from '$lib/shared/components/forms/form-context';
	import { required, max } from '$lib/shared/components/forms/validators';
	import { Info, Palette, ArrowRight } from 'lucide-svelte';
	import { createEmptyDependencyFormData } from '../../queries';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import type { Dependency, DependencyMembers, EdgeStyle } from '../../types/base';
	import type { Color } from '$lib/shared/utils/styling';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities, dependencyTypes } from '$lib/shared/stores/metadata';
	import { useServicesCacheQuery } from '$lib/features/services/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useInterfacesQuery } from '$lib/features/interfaces/queries';
	import { usePortsQuery } from '$lib/features/ports/queries';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import DependencyMemberSelector from '../DependencyMemberSelector.svelte';
	import EdgeStyleForm from './EdgeStyleForm.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';
	import type { Service } from '$lib/features/services/types/base';
	import { SvelteMap } from 'svelte/reactivity';
	import {
		common_back,
		common_cancel,
		common_create,
		common_delete,
		common_deleting,
		common_description,
		common_details,
		common_editName,
		common_next,
		common_saving,
		common_update,
		dependencies_createDependency,
		dependencies_descriptionPlaceholder,
		dependencies_edgeAppearance,
		dependencies_dependencyName,
		dependencies_dependencyNamePlaceholder,
		dependencies_dependencyType,
		common_services
	} from '$lib/paraglide/messages';

	interface Props {
		dependency?: Dependency | null;
		isOpen?: boolean;
		onCreate: (data: Dependency) => Promise<void> | void;
		onUpdate: (id: string, data: Dependency) => Promise<void> | void;
		onClose: () => void;
		onDelete?: ((id: string) => Promise<void> | void) | null;
		name?: string;
	}

	let {
		dependency = null,
		isOpen = false,
		onCreate,
		onUpdate,
		onClose,
		onDelete = null,
		name = undefined
	}: Props = $props();

	// TanStack Query hooks
	const servicesQuery = useServicesCacheQuery();
	const networksQuery = useNetworksQuery();
	const hostsQuery = useHostsQuery({ limit: 0 });
	const interfacesQuery = useInterfacesQuery();
	const portsQuery = usePortsQuery();

	let servicesData = $derived(servicesQuery.data ?? []);
	let isServicesLoading = $derived(hostsQuery.isPending);
	let networksData = $derived(networksQuery.data ?? []);
	let hostsData = $derived(hostsQuery.data?.items ?? []);
	let interfacesData = $derived(interfacesQuery.data ?? []);
	let portsData = $derived(portsQuery.data ?? []);
	let defaultNetworkId = $derived(networksData[0]?.id ?? '');

	let loading = $state(false);
	let deleting = $state(false);

	let isEditing = $derived(dependency !== null);
	let title = $derived(
		isEditing ? common_editName({ name: dependency?.name ?? '' }) : dependencies_createDependency()
	);

	// Tab management
	let activeTab = $state('details');
	let furthestReached = $state(0);

	let tabs = $derived([
		{ id: 'details', label: common_details(), icon: Info },
		{
			id: 'services',
			label: common_services(),
			icon: entities.getIconComponent('Service'),
			disabled: !isEditing && furthestReached < 1
		},
		{
			id: 'edge-style',
			label: dependencies_edgeAppearance(),
			icon: Palette,
			disabled: !isEditing && furthestReached < 2
		}
	]);

	let enabledTabs = $derived(tabs.filter((t) => !t.disabled));
	let currentEnabledIndex = $derived(enabledTabs.findIndex((t) => t.id === activeTab));

	function nextTab() {
		if (currentEnabledIndex < enabledTabs.length - 1) {
			activeTab = enabledTabs[currentEnabledIndex + 1].id;
		}
	}

	function previousTab() {
		if (currentEnabledIndex > 0) {
			activeTab = enabledTabs[currentEnabledIndex - 1].id;
		}
	}

	const wizardSteps = ['details', 'services', 'edge-style'];
	let isLastWizardStep = $derived(activeTab === wizardSteps[wizardSteps.length - 1]);

	let saveLabel = $derived(
		isEditing ? common_update() : isLastWizardStep ? common_create() : common_next()
	);
	let cancelLabel = $derived(isEditing ? common_cancel() : common_back());
	let showCancel = $derived(isEditing ? true : currentEnabledIndex !== 0);

	function getDefaultValues(): Dependency {
		return dependency ? { ...dependency } : createEmptyDependencyFormData(defaultNetworkId);
	}

	// Create form
	const form = createForm(() => ({
		defaultValues: createEmptyDependencyFormData(''),
		onSubmit: async ({ value }) => {
			// Build members from local state
			let members: DependencyMembers;
			if (memberMode === 'Bindings') {
				const bindingIds = selectedServiceIds
					.map((svcId) => bindingSelections.get(svcId))
					.filter((id): id is string => id !== undefined && id !== null);
				members = { type: 'Bindings', binding_ids: bindingIds };
			} else {
				members = { type: 'Services', service_ids: [...selectedServiceIds] };
			}

			const dependencyData: Dependency = {
				...(value as Dependency),
				name: value.name.trim(),
				description: value.description?.trim() || '',
				members,
				color: edgeColor,
				edge_style: edgeEdgeStyle
			};

			loading = true;
			try {
				if (isEditing && dependency) {
					await onUpdate(dependency.id, dependencyData);
				} else {
					await onCreate(dependencyData);
				}
			} finally {
				loading = false;
			}
		}
	}));

	// Local state for Svelte 5 reactivity
	let selectedServiceIds = $state<string[]>([]);
	let memberMode = $state<'Services' | 'Bindings'>('Services');
	let bindingSelections = new SvelteMap<string, string | null>();
	let bindingsSubmitted = $state(false);
	let selectedNetworkId = $state<string>('');
	let edgeColor = $state<Color>('Blue');
	let edgeEdgeStyle = $state<EdgeStyle>('SmoothStep');

	// Reset form when modal opens
	function handleOpen() {
		const defaults = getDefaultValues();
		form.reset(defaults);
		selectedNetworkId = defaults.network_id ?? '';
		edgeColor = defaults.color || 'Blue';
		edgeEdgeStyle = defaults.edge_style || 'SmoothStep';
		activeTab = 'details';
		furthestReached = 0;
		bindingsSubmitted = false;

		// Initialize member state from existing dependency
		bindingSelections.clear();
		const members = defaults.members;
		if (members?.type === 'Bindings') {
			memberMode = 'Bindings';
			// Derive service IDs from binding IDs
			const svcIds: string[] = [];
			for (const bindingId of members.binding_ids) {
				const service = servicesData.find((s) => s.bindings.some((b) => b.id === bindingId));
				if (service && !svcIds.includes(service.id)) {
					svcIds.push(service.id);
					bindingSelections.set(service.id, bindingId);
				}
			}
			selectedServiceIds = svcIds;
		} else {
			memberMode = 'Services';
			selectedServiceIds = members?.service_ids ? [...members.service_ids] : [];
		}
	}

	// Available services on the selected network (exclude already selected), sorted by host then name
	let availableServices = $derived.by(() => {
		return servicesData
			.filter((s) => s.network_id === selectedNetworkId)
			.filter((s) => s.service_definition !== 'Unclaimed Open Ports')
			.filter((s) => !selectedServiceIds.includes(s.id))
			.sort((a, b) => {
				const hostA = hostsData.find((h: { id: string }) => h.id === a.host_id)?.name ?? '';
				const hostB = hostsData.find((h: { id: string }) => h.id === b.host_id)?.name ?? '';
				const hostCmp = hostA.localeCompare(hostB);
				return hostCmp !== 0 ? hostCmp : a.name.localeCompare(b.name);
			});
	});

	// Selected service objects (in order)
	let selectedServices = $derived.by(() => {
		return selectedServiceIds
			.map((id) => servicesData.find((s) => s.id === id))
			.filter((s): s is Service => s !== undefined);
	});

	// Handlers for service list
	function handleAddService(serviceId: string) {
		selectedServiceIds = [...selectedServiceIds, serviceId];
		// In Bindings mode, auto-select if service has exactly one binding
		if (memberMode === 'Bindings') {
			const service = servicesData.find((s) => s.id === serviceId);
			if (service?.bindings.length === 1) {
				bindingSelections.set(serviceId, service.bindings[0].id);
			} else {
				bindingSelections.set(serviceId, null);
			}
		}
	}

	function handleRemoveService(index: number) {
		const removedId = selectedServiceIds[index];
		selectedServiceIds = selectedServiceIds.filter((_, i) => i !== index);
		bindingSelections.delete(removedId);
	}

	function handleReorderServices(fromIndex: number, toIndex: number) {
		if (fromIndex === toIndex) return;
		const current = [...selectedServiceIds];
		const [moved] = current.splice(fromIndex, 1);
		current.splice(toIndex, 0, moved);
		selectedServiceIds = current;
	}

	// Handle member mode switch
	function handleModeChange(mode: string) {
		bindingsSubmitted = false;
		if (mode === 'Services') {
			memberMode = 'Services';
			bindingSelections.clear();
		} else {
			memberMode = 'Bindings';
			// Initialize binding slots — auto-select if service has exactly one binding
			for (const svcId of selectedServiceIds) {
				if (!bindingSelections.has(svcId) || !bindingSelections.get(svcId)) {
					const service = servicesData.find((s) => s.id === svcId);
					if (service?.bindings.length === 1) {
						bindingSelections.set(svcId, service.bindings[0].id);
					} else {
						bindingSelections.set(svcId, null);
					}
				}
			}
		}
	}

	// Handle binding selection for a specific service
	function handleBindingSelect(serviceId: string, bindingId: string) {
		bindingSelections.set(serviceId, bindingId);
	}

	async function handleSubmit() {
		await submitForm(form);
	}

	function validateBindings(): boolean {
		if (memberMode !== 'Bindings') return true;
		const missing = selectedServiceIds.some((svcId) => !bindingSelections.get(svcId));
		if (missing) {
			bindingsSubmitted = true;
			return false;
		}
		return true;
	}

	async function handleFormSubmit() {
		if (isEditing || isLastWizardStep) {
			if (!validateBindings()) return;
			handleSubmit();
		} else {
			const isValid = await validateForm(form);
			// Also validate bindings when advancing from the services tab
			if (isValid && activeTab === 'services' && !validateBindings()) return;
			if (isValid) {
				const wizardIndex = wizardSteps.indexOf(activeTab);
				if (wizardIndex >= 0 && wizardIndex + 1 > furthestReached) {
					furthestReached = wizardIndex + 1;
				}
				nextTab();
			}
		}
	}

	function handleFormCancel() {
		if (isEditing || currentEnabledIndex === 0) {
			onClose();
		} else {
			previousTab();
		}
	}

	async function handleDelete() {
		if (onDelete && dependency) {
			deleting = true;
			try {
				await onDelete(dependency.id);
			} finally {
				deleting = false;
			}
		}
	}

	// Dependency type options for RichSelect
	let dependencyTypeItems = $derived(
		dependencyTypes.getItems().map((dt) => ({
			id: dt.id,
			name: dt.name ?? dt.id,
			description: dt.description ?? '',
			icon: dependencyTypes.getIconComponent(dt.id),
			iconColor: dependencyTypes.getColorHelper(dt.id).icon
		}))
	);

	type DepTypeItem = (typeof dependencyTypeItems)[number];
	const dependencyTypeDisplay = {
		getId: (item: DepTypeItem) => item.id,
		getLabel: (item: DepTypeItem) => item.name,
		getDescription: (item: DepTypeItem) => item.description,
		getIcon: (item: DepTypeItem) => item.icon,
		getIconColor: (item: DepTypeItem) => item.iconColor
	};

	// Service display with host grouping for the service picker
	let colorHelper = entities.getColorHelper('Dependency');

	let edgeStyleFormData = $derived({
		color: edgeColor,
		edge_style: edgeEdgeStyle
	} as Dependency);
</script>

<GenericModal
	{isOpen}
	{title}
	{name}
	entityId={dependency?.id}
	size="full"
	{onClose}
	onOpen={handleOpen}
	showCloseButton={true}
	{tabs}
	{activeTab}
	tabStyle={isEditing ? 'tabs' : 'stepper'}
	onTabChange={(tabId) => (activeTab = tabId)}
>
	{#snippet headerIcon()}
		<ModalHeaderIcon Icon={entities.getIconComponent('Dependency')} color={colorHelper.color} />
	{/snippet}

	<form
		onsubmit={(e) => {
			e.preventDefault();
			e.stopPropagation();
			handleFormSubmit();
		}}
		class="flex min-h-0 flex-1 flex-col"
	>
		<div class="min-h-0 flex-1 overflow-auto">
			<!-- Details Tab -->
			{#if activeTab === 'details'}
				<div class="space-y-4 p-6">
					<form.Field
						name="name"
						validators={{
							onBlur: ({ value }) => required(value) || max(100)(value)
						}}
					>
						{#snippet children(field)}
							<TextInput
								label={dependencies_dependencyName()}
								id="name"
								{field}
								placeholder={dependencies_dependencyNamePlaceholder()}
								required
							/>
						{/snippet}
					</form.Field>

					<form.Field name="network_id">
						{#snippet children(field)}
							<SelectNetwork
								selectedNetworkId={field.state.value}
								onNetworkChange={(id) => {
									field.handleChange(id);
									selectedNetworkId = id;
								}}
							/>
						{/snippet}
					</form.Field>

					<form.Field name="dependency_type">
						{#snippet children(field)}
							<RichSelect
								label={dependencies_dependencyType()}
								options={dependencyTypeItems}
								selectedValue={field.state.value}
								displayComponent={dependencyTypeDisplay}
								onSelect={(value) => field.handleChange(value)}
							/>
						{/snippet}
					</form.Field>

					<form.Field
						name="description"
						validators={{
							onBlur: ({ value }) => max(500)(value || '')
						}}
					>
						{#snippet children(field)}
							<TextArea
								label={common_description()}
								id="description"
								{field}
								placeholder={dependencies_descriptionPlaceholder()}
							/>
						{/snippet}
					</form.Field>

					<form.Field name="tags">
						{#snippet children(field)}
							<TagPicker
								selectedTagIds={field.state.value || []}
								onChange={(tags) => field.handleChange(tags)}
							/>
						{/snippet}
					</form.Field>
				</div>
			{/if}

			<!-- Services Tab -->
			{#if activeTab === 'services'}
				<div class="space-y-4 p-6">
					<DependencyMemberSelector
						{selectedServiceIds}
						{memberMode}
						{bindingSelections}
						{bindingsSubmitted}
						{availableServices}
						{selectedServices}
						{hostsData}
						isLoading={isServicesLoading}
						onAddService={handleAddService}
						onRemoveService={handleRemoveService}
						onReorderServices={handleReorderServices}
						onModeChange={handleModeChange}
						onBindingSelect={handleBindingSelect}
					/>
				</div>
			{/if}

			<!-- Edge Style Tab -->
			{#if activeTab === 'edge-style'}
				<div class="p-6">
					<EdgeStyleForm
						formData={edgeStyleFormData}
						showCollapseToggle={false}
						layout="horizontal"
						onColorChange={(color) => {
							edgeColor = color;
							form.setFieldValue('color', color);
						}}
						onEdgeStyleChange={(style) => {
							edgeEdgeStyle = style;
							form.setFieldValue('edge_style', style);
						}}
					/>
				</div>
			{/if}
		</div>

		{#if isEditing && dependency}
			<EntityMetadataSection entities={[dependency]} />
		{/if}

		<!-- Footer -->
		<div class="modal-footer">
			<div class="flex items-center justify-between">
				<div>
					{#if isEditing && onDelete}
						<button
							type="button"
							disabled={deleting || loading}
							onclick={handleDelete}
							class="btn-danger"
						>
							{deleting ? common_deleting() : common_delete()}
						</button>
					{/if}
				</div>
				<div class="flex items-center gap-3">
					{#if showCancel}
						<button
							type="button"
							disabled={loading || deleting}
							onclick={handleFormCancel}
							class="btn-secondary"
						>
							{cancelLabel}
						</button>
					{/if}
					<button
						type="submit"
						disabled={loading || deleting}
						class="btn-primary {!isEditing && !isLastWizardStep ? 'btn-primary-lg' : ''}"
					>
						{loading ? common_saving() : saveLabel}
						{#if !isEditing && !isLastWizardStep}
							<ArrowRight class="h-4 w-4" />
						{/if}
					</button>
				</div>
			</div>
		</div>
	</form>
</GenericModal>
