<script lang="ts">
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import EntityTag from '$lib/shared/components/data/EntityTag.svelte';
	import { entityRef } from '$lib/shared/components/data/types';
	import { entities } from '$lib/shared/stores/metadata';
	import { useSubnetsQuery, isContainerSubnet } from '$lib/features/subnets/queries';
	import type { DependencyTarget } from '../../../../resolvers';
	import type { Topology } from '../../../../types/base';

	let {
		form,
		topology,
		target
	}: {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		form: any;
		topology: Topology;
		target: Extract<DependencyTarget, { kind: 'host' | 'ipAddress' }>;
	} = $props();

	let host = $derived(topology.hosts.find((h) => h.id === target.hostId));
	let ipAddress = $derived(
		target.kind === 'ipAddress'
			? topology.ip_addresses.find((i) => i.id === target.ipAddressId)
			: undefined
	);

	let candidates = $derived(
		target.candidateServiceIds
			.map((id) => topology.services.find((s) => s.id === id))
			.filter((s): s is NonNullable<typeof s> => !!s)
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
</script>

<div class="card card-static space-y-2 p-2">
	<!-- Context header: host (+ IP if applicable) rendered as EntityTag pills with hover-details -->
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

	{#if candidates.length === 0}
		<div class="text-tertiary text-xs italic">—</div>
	{:else}
		{#each candidates as service (service.id)}
			<form.Field name="picks.{target.elementId}.{service.id}">
				{#snippet children(field: AnyFieldApi)}
					<Checkbox label={service.name} id="target-{target.elementId}-{service.id}" {field} />
				{/snippet}
			</form.Field>
		{/each}
	{/if}
</div>
