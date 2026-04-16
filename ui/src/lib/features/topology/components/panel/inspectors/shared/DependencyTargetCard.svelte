<script lang="ts">
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import EntityTag from '$lib/shared/components/data/EntityTag.svelte';
	import { entityRef } from '$lib/shared/components/data/types';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { useSubnetsQuery, isContainerSubnet } from '$lib/features/subnets/queries';
	import BindingPicker from './BindingPicker.svelte';
	import type { DependencyTarget } from '../../../../resolvers';
	import type { Topology } from '../../../../types/base';

	let {
		form,
		topology,
		target,
		memberMode,
		flatIndex
	}: {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		form: any;
		topology: Topology;
		target: DependencyTarget;
		memberMode: 'Services' | 'Bindings';
		/** Position of this card's resolved service in the flattened dep service list. */
		flatIndex: number;
	} = $props();

	let host = $derived(
		target.kind === 'service'
			? topology.hosts.find(
					(h) => h.id === topology.services.find((s) => s.id === target.serviceId)?.host_id
				)
			: topology.hosts.find((h) => h.id === target.hostId)
	);

	let ipAddress = $derived(
		target.kind === 'ipAddress'
			? topology.ip_addresses.find((i) => i.id === target.ipAddressId)
			: undefined
	);

	const subnetsQuery = useSubnetsQuery();
	let subnetsData = $derived(subnetsQuery.data ?? []);

	let ipLabel = $derived.by(() => {
		if (!ipAddress) return '';
		const subnet = subnetsData.find((s) => s.id === ipAddress.subnet_id);
		if (subnet && isContainerSubnet(subnet)) {
			return ipAddress.name ?? ipAddress.ip_address;
		}
		return (ipAddress.name ? ipAddress.name + ': ' : '') + ipAddress.ip_address;
	});

	// Candidate services (not applicable for direct service targets).
	let candidates = $derived(
		target.kind === 'service'
			? []
			: target.candidateServiceIds
					.map((id) => topology.services.find((s) => s.id === id))
					.filter((s): s is NonNullable<typeof s> => !!s)
	);

	// The resolved service for this card: either the direct service, the single candidate,
	// or the currently-picked candidate from the form (defaulted to the first candidate).
	let resolvedServiceId = $derived.by((): string | null => {
		if (target.kind === 'service') return target.serviceId;
		if (candidates.length === 0) return null;
		if (candidates.length === 1) return candidates[0].id;
		const picked = form.state.values.picks?.[target.elementId];
		return picked ?? candidates[0].id;
	});

	let resolvedService = $derived(
		resolvedServiceId ? topology.services.find((s) => s.id === resolvedServiceId) : undefined
	);

	let ipAddressIdFilter = $derived(target.kind === 'ipAddress' ? target.ipAddressId : null);

	// Seed the form default for multi-candidate targets so a service is resolved on first render.
	$effect(() => {
		if (target.kind === 'service') return;
		if (candidates.length <= 1) return;
		const picked = form.state.values.picks?.[target.elementId];
		if (picked) return;
		form.setFieldValue(`picks.${target.elementId}`, candidates[0].id);
	});

	function serviceIcon(serviceDef: string | null | undefined) {
		return serviceDef
			? serviceDefinitions.getIconComponent(serviceDef)
			: entities.getIconComponent('Service');
	}

	function serviceIconColor(serviceDef: string | null | undefined) {
		return serviceDef
			? serviceDefinitions.getColorHelper(serviceDef).color
			: entities.getColorHelper('Service').color;
	}
</script>

<div class="card card-static space-y-2 p-2">
	<!-- Context header: host (+ IP if applicable). Tags show full details on hover. -->
	<div class="flex flex-wrap items-center gap-1.5">
		{#if host}
			<EntityTag
				entityRef={entityRef('Host', host.id, host)}
				label={host.name}
				icon={entities.getIconComponent('Host')}
				color={entities.getColorHelper('Host').color}
			/>
		{/if}
		{#if ipAddress}
			<EntityTag
				entityRef={entityRef('IPAddress', ipAddress.id, ipAddress, { subnets: subnetsData })}
				label={ipLabel}
				icon={entities.getIconComponent('IPAddress')}
				color={entities.getColorHelper('IPAddress').color}
			/>
		{/if}
	</div>

	<!-- Body: resolved service (static) or radio group to disambiguate. -->
	{#if target.kind === 'service' || candidates.length === 1}
		{#if resolvedService}
			<EntityTag
				entityRef={entityRef('Service', resolvedService.id, resolvedService)}
				label={resolvedService.name}
				icon={serviceIcon(resolvedService.service_definition)}
				color={serviceIconColor(resolvedService.service_definition)}
			/>
		{/if}
	{:else if candidates.length > 1}
		<form.Field name="picks.{target.elementId}">
			{#snippet children(field: AnyFieldApi)}
				<div class="space-y-1">
					{#each candidates as service (service.id)}
						<label
							class="text-secondary flex cursor-pointer items-center gap-2 text-sm font-medium"
						>
							<input
								type="radio"
								name="picks-{target.elementId}"
								value={service.id}
								checked={field.state.value === service.id}
								onchange={() => field.handleChange(service.id)}
								class="checkbox-card h-4 w-4 focus:ring-1 focus:ring-blue-500"
							/>
							<span>{service.name}</span>
						</label>
					{/each}
				</div>
			{/snippet}
		</form.Field>
	{:else}
		<div class="text-tertiary text-xs italic">—</div>
	{/if}

	<!-- Bindings mode: per-card binding picker for the resolved service. -->
	{#if memberMode === 'Bindings' && resolvedServiceId}
		<div class="border-t border-gray-200 pt-2 dark:border-gray-700">
			<BindingPicker
				{form}
				{topology}
				serviceId={resolvedServiceId}
				{flatIndex}
				{ipAddressIdFilter}
			/>
		</div>
	{/if}
</div>
