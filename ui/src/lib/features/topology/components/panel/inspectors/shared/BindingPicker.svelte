<script lang="ts">
	import EntityTag from '$lib/shared/components/data/EntityTag.svelte';
	import { entityRef } from '$lib/shared/components/data/types';
	import { entities } from '$lib/shared/stores/metadata';
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import EntityTagSelect, {
		type EntityTagOption
	} from '$lib/shared/components/forms/selection/EntityTagSelect.svelte';
	import {
		BindingDisplay,
		type BindingDisplayContext
	} from '$lib/shared/components/forms/selection/display/BindingDisplay.svelte';
	import { useSubnetsQuery, isContainerSubnet } from '$lib/features/subnets/queries';
	import {
		dependencies_selectPort,
		dependencies_noOpenPortsError,
		topology_multiSelectNoBindings
	} from '$lib/paraglide/messages';
	import type { Topology } from '../../../../types/base';

	let {
		form,
		fieldPrefix = 'bindings',
		topology,
		serviceId,
		flatIndex,
		ipAddressIdFilter = null,
		disabled = false
	}: {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		form: any;
		/** Prefix for the form field path — final field is `${fieldPrefix}.${serviceId}`. */
		fieldPrefix?: string;
		topology: Topology;
		serviceId: string;
		flatIndex: number;
		ipAddressIdFilter?: string | null;
		disabled?: boolean;
	} = $props();

	const subnetsQuery = useSubnetsQuery();
	let subnetsData = $derived(subnetsQuery.data ?? []);
	let isContainerSubnetFn = $derived((subnetId: string) => {
		const subnet = subnetsData.find((s) => s.id === subnetId);
		return subnet ? isContainerSubnet(subnet) : false;
	});

	let bindingContext: BindingDisplayContext = $derived({
		ip_addresses: topology.ip_addresses,
		ports: topology.ports,
		isContainerSubnet: isContainerSubnetFn,
		compact: true
	});

	let backing = $derived(topology.services.find((s) => s.id === serviceId));
	let host = $derived(backing ? topology.hosts.find((h) => h.id === backing!.host_id) : undefined);

	// Mirror the bindings map — form.state.values is not tracked by Svelte 5 $derived.
	let bindingsMap = $state<Record<string, string>>({
		...((form.state.values[fieldPrefix] ?? {}) as Record<string, string>)
	});
	$effect(() => {
		return form.store.subscribe(() => {
			bindingsMap = {
				...((form.state.values[fieldPrefix] ?? {}) as Record<string, string>)
			};
		});
	});

	let candidates = $derived.by(() => {
		if (!backing) return [];
		return backing.bindings.filter((b) => {
			if (flatIndex > 0 && b.type === 'IPAddress') return false;
			if (ipAddressIdFilter != null) {
				if (b.ip_address_id !== ipAddressIdFilter && b.ip_address_id !== null) return false;
			}
			for (const [otherSvcId, chosenId] of Object.entries(bindingsMap)) {
				if (otherSvcId !== serviceId && chosenId === b.id) return false;
			}
			return true;
		});
	});

	// Auto-resolve singleton: write the only candidate to the form, idempotent.
	$effect(() => {
		if (candidates.length !== 1) return;
		if (bindingsMap[serviceId] === candidates[0].id) return;
		form.setFieldValue(`${fieldPrefix}.${serviceId}`, candidates[0].id);
	});
</script>

{#if backing}
	{#if candidates.length === 0}
		{#if flatIndex > 0 && backing.bindings.every((b) => b.type === 'IPAddress')}
			<p class="text-danger text-xs">
				{dependencies_noOpenPortsError({
					serviceName: backing.name,
					hostName: host?.name ?? ''
				})}
			</p>
		{:else}
			<span class="text-tertiary text-xs italic">
				{topology_multiSelectNoBindings()}
			</span>
		{/if}
	{:else if candidates.length === 1}
		<EntityTag
			entityRef={entityRef('Binding', candidates[0].id, candidates[0], bindingContext)}
			label={BindingDisplay.getLabel?.(candidates[0], bindingContext) ?? ''}
			icon={entities.getIconComponent('Port')}
			color={entities.getColorHelper('Port').color}
			disableNavigate={true}
			disablePopover={true}
		/>
	{:else}
		{@const bindingOptions: EntityTagOption[] = candidates.map((b) => ({
			id: b.id,
			entityRef: entityRef('Binding', b.id, b, bindingContext),
			label: BindingDisplay.getLabel?.(b, bindingContext) ?? '',
			icon: entities.getIconComponent('Port'),
			color: entities.getColorHelper('Port').color
		}))}
		<div class="min-w-0 flex-1">
			<form.Field name="{fieldPrefix}.{serviceId}">
				{#snippet children(field: AnyFieldApi)}
					<EntityTagSelect
						options={bindingOptions}
						selectedValue={field.state.value ?? null}
						placeholder={dependencies_selectPort()}
						onSelect={(bindingId) => field.handleChange(bindingId)}
						{disabled}
					/>
				{/snippet}
			</form.Field>
		</div>
	{/if}
{/if}
