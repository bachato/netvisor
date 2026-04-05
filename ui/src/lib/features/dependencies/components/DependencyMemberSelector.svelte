<script lang="ts">
	import { SvelteMap } from 'svelte/reactivity';
	import { required } from '$lib/shared/components/forms/validators';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import { BindingWithServiceDisplay } from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import SegmentedControl from '$lib/shared/components/forms/SegmentedControl.svelte';
	import type { Service } from '$lib/features/services/types/base';
	import {
		dependencies_withPorts,
		dependencies_loadingServices,
		dependencies_noServicesYet,
		dependencies_selectPort,
		dependencies_selectService,
		dependencies_servicesOnly,
		common_services,
		dependencies_servicesHelp,
		dependencies_servicesInfoTitle,
		dependencies_servicesInfoBody
	} from '$lib/paraglide/messages';

	interface Props {
		selectedServiceIds: string[];
		memberMode: 'Services' | 'Bindings';
		bindingSelections: SvelteMap<string, string | null>;
		bindingsSubmitted: boolean;
		availableServices: Service[];
		selectedServices: Service[];
		hostsData: { id: string; name: string }[];
		isLoading?: boolean;
		onAddService: (serviceId: string) => void;
		onRemoveService: (index: number) => void;
		onReorderServices: (fromIndex: number, toIndex: number) => void;
		onModeChange: (mode: string) => void;
		onBindingSelect: (serviceId: string, bindingId: string) => void;
	}

	let {
		selectedServiceIds,
		memberMode,
		bindingSelections,
		bindingsSubmitted,
		availableServices,
		selectedServices,
		hostsData,
		isLoading = false,
		onAddService,
		onRemoveService,
		onReorderServices,
		onModeChange,
		onBindingSelect
	}: Props = $props();

	let modeOptions = $derived([
		{ value: 'Services', label: dependencies_servicesOnly() },
		{ value: 'Bindings', label: dependencies_withPorts() }
	]);

	// Custom display component that groups services by host
	let serviceDisplayWithHost = $derived({
		...ServiceDisplay,
		getCategory: (service: Service) => {
			const host = hostsData.find((h) => h.id === service.host_id);
			return host?.name ?? null;
		}
	});

	// Get available bindings for a specific service (exclude already-selected by other services)
	function getBindingsForService(service: Service) {
		return service.bindings.filter((b) => {
			for (const [svcId, bid] of bindingSelections) {
				if (svcId !== service.id && bid === b.id) return false;
			}
			return true;
		});
	}

	let bindingContext = $derived({
		ports: [] as { id: string; number: number; protocol: string }[]
	});
</script>

<div class="space-y-4">
	<InlineInfo
		title={dependencies_servicesInfoTitle()}
		body={dependencies_servicesInfoBody()}
		dismissableKey="dependency-services-info"
	/>

	<!-- Mode selector -->
	<SegmentedControl
		options={modeOptions}
		selected={memberMode}
		onchange={onModeChange}
		size="sm"
		fullWidth={true}
	/>

	<div class="card">
		<ListManager
			label={common_services()}
			helpText={dependencies_servicesHelp()}
			placeholder={isLoading ? dependencies_loadingServices() : dependencies_selectService()}
			emptyMessage={dependencies_noServicesYet()}
			allowReorder={true}
			allowItemEdit={() => false}
			showSearch={true}
			options={availableServices}
			items={selectedServices}
			optionDisplayComponent={serviceDisplayWithHost}
			itemDisplayComponent={serviceDisplayWithHost}
			getItemContext={() => ({})}
			getOptionContext={() => ({})}
			onAdd={onAddService}
			onRemove={onRemoveService}
			onMoveUp={(index) => onReorderServices(index, index - 1)}
			onMoveDown={(index) => onReorderServices(index, index + 1)}
		>
			{#snippet itemExpandedSnippet({ item })}
				{#if memberMode === 'Bindings'}
					{@const service = item as Service}
					{@const serviceBindings = getBindingsForService(service)}
					{@const selectedBindingId = bindingSelections.get(service.id) ?? null}
					{@const showError = bindingsSubmitted && !selectedBindingId}
					<div class="mt-2 w-full border-t border-gray-200 pt-2 dark:border-gray-700">
						<RichSelect
							options={serviceBindings}
							selectedValue={selectedBindingId}
							placeholder={dependencies_selectPort()}
							displayComponent={BindingWithServiceDisplay}
							getOptionContext={() => bindingContext}
							onSelect={(bindingId) => {
								onBindingSelect(service.id, bindingId);
							}}
							required={true}
							error={showError ? required(selectedBindingId) : null}
						/>
					</div>
				{/if}
			{/snippet}
		</ListManager>
	</div>
</div>
