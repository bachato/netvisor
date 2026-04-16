<script lang="ts">
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import {
		BindingWithServiceDisplay,
		type BindingWithServiceContext
	} from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
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
		/** Position in the flattened dep service list. Index 0 is the entry point. */
		flatIndex: number;
		/** Restrict candidates to this IP (or null = all-IPs) when the service came from an IP target. */
		ipAddressIdFilter?: string | null;
		disabled?: boolean;
	} = $props();

	const subnetsQuery = useSubnetsQuery();
	let subnetsData = $derived(subnetsQuery.data ?? []);
	let isContainerSubnetFn = $derived((subnetId: string) => {
		const subnet = subnetsData.find((s) => s.id === subnetId);
		return subnet ? isContainerSubnet(subnet) : false;
	});

	let bindingContext: BindingWithServiceContext = $derived({
		services: topology.services,
		hosts: topology.hosts,
		ip_addresses: topology.ip_addresses,
		ports: topology.ports,
		isContainerSubnet: isContainerSubnetFn,
		compact: true
	});

	let backing = $derived(topology.services.find((s) => s.id === serviceId));
	let host = $derived(backing ? topology.hosts.find((h) => h.id === backing!.host_id) : undefined);

	// A binding chosen by any other service in the same form is unavailable to this one.
	let candidates = $derived.by(() => {
		if (!backing) return [];
		const bindingsMap = (form.state.values[fieldPrefix] ?? {}) as Record<string, string>;
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
		const existing = form.state.values[fieldPrefix]?.[serviceId];
		if (existing === candidates[0].id) return;
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
			<div class="text-tertiary text-xs italic">
				{topology_multiSelectNoBindings()}
			</div>
		{/if}
	{:else if candidates.length === 1}
		<EntityDisplayWrapper
			context={bindingContext}
			item={candidates[0]}
			displayComponent={BindingWithServiceDisplay}
		/>
	{:else}
		<form.Field name="{fieldPrefix}.{serviceId}">
			{#snippet children(field: AnyFieldApi)}
				<RichSelect
					options={candidates}
					selectedValue={field.state.value ?? null}
					placeholder={dependencies_selectPort()}
					displayComponent={BindingWithServiceDisplay}
					getOptionContext={() => bindingContext}
					onSelect={(bindingId) => field.handleChange(bindingId)}
					required
					{disabled}
				/>
			{/snippet}
		</form.Field>
	{/if}
{/if}
