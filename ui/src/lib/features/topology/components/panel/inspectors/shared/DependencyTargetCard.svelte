<script lang="ts">
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import EntityTag from '$lib/shared/components/data/EntityTag.svelte';
	import { entityRef } from '$lib/shared/components/data/types';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import {
		ServiceDisplay,
		type ServiceDisplayContext
	} from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import BindingPicker from './BindingPicker.svelte';
	import type { DependencyTarget } from '../../../../resolvers';
	import type { Topology } from '../../../../types/base';

	let {
		form,
		topology,
		target,
		flatIndex
	}: {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		form: any;
		topology: Topology;
		target: DependencyTarget;
		flatIndex: number;
	} = $props();

	// Mirror form state — form.state.values isn't tracked by Svelte 5 $derived.
	interface MirroredValues {
		memberMode: 'Services' | 'Bindings';
		picks: Record<string, string>;
	}
	let formValues = $state<MirroredValues>({
		memberMode: form.state.values.memberMode ?? 'Services',
		picks: { ...(form.state.values.picks ?? {}) }
	});
	$effect(() => {
		return form.store.subscribe(() => {
			formValues = {
				memberMode: form.state.values.memberMode ?? 'Services',
				picks: { ...(form.state.values.picks ?? {}) }
			};
		});
	});

	let memberMode = $derived(formValues.memberMode);

	let host = $derived(
		target.kind === 'service'
			? topology.hosts.find(
					(h) => h.id === topology.services.find((s) => s.id === target.serviceId)?.host_id
				)
			: topology.hosts.find((h) => h.id === target.hostId)
	);

	let candidates = $derived(
		target.kind === 'service'
			? []
			: target.candidateServiceIds
					.map((id) => topology.services.find((s) => s.id === id))
					.filter((s): s is NonNullable<typeof s> => !!s)
	);

	let resolvedServiceId = $derived.by((): string | null => {
		if (target.kind === 'service') return target.serviceId;
		if (candidates.length === 0) return null;
		if (candidates.length === 1) return candidates[0].id;
		return formValues.picks[target.elementId] ?? candidates[0].id;
	});

	let resolvedService = $derived(
		resolvedServiceId ? topology.services.find((s) => s.id === resolvedServiceId) : undefined
	);

	let ipAddressIdFilter = $derived(target.kind === 'ipAddress' ? target.ipAddressId : null);

	// Seed default pick for multi-candidate targets so a service resolves on first render.
	$effect(() => {
		if (target.kind === 'service') return;
		if (candidates.length <= 1) return;
		if (formValues.picks[target.elementId]) return;
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

	let hasPicker = $derived(target.kind !== 'service' && candidates.length > 1);
	let showListeningOn = $derived(memberMode === 'Bindings' && resolvedServiceId !== null);

	// Service options for the RichSelect dropdown, annotated with host name as category.
	const serviceDisplayWithHost = {
		...ServiceDisplay,
		getCategory: (svc: { host_id: string }) =>
			topology.hosts.find((h) => h.id === svc.host_id)?.name ?? null
	};
	let serviceContext: ServiceDisplayContext = $derived({ compact: true });
</script>

<div class="card card-static space-y-2 p-2 text-sm">
	<!-- Line 1: [HostTag] running -->
	<div class="flex flex-wrap items-center gap-1.5">
		{#if host}
			<EntityTag
				entityRef={entityRef('Host', host.id, host)}
				label={host.name}
				icon={entities.getIconComponent('Host')}
				color={entities.getColorHelper('Host').color}
			/>
		{/if}
		<span class="text-tertiary">running</span>
	</div>

	<!-- Line 2: [Service] [listening on?] -->
	<div class="flex flex-wrap items-center gap-1.5">
		{#if hasPicker}
			<form.Field name="picks.{target.elementId}">
				{#snippet children(field: AnyFieldApi)}
					<div class="min-w-0 flex-1">
						<RichSelect
							options={candidates}
							selectedValue={field.state.value ?? resolvedServiceId}
							displayComponent={serviceDisplayWithHost}
							getOptionContext={() => serviceContext}
							onSelect={(id) => field.handleChange(id)}
							required
						/>
					</div>
				{/snippet}
			</form.Field>
		{:else if resolvedService}
			<EntityTag
				entityRef={entityRef('Service', resolvedService.id, resolvedService)}
				label={resolvedService.name}
				icon={serviceIcon(resolvedService.service_definition)}
				color={serviceIconColor(resolvedService.service_definition)}
			/>
		{:else}
			<span class="text-tertiary text-xs italic">—</span>
		{/if}
		{#if showListeningOn}
			<span class="text-tertiary">listening on</span>
		{/if}
	</div>

	<!-- Line 3 (Bindings mode only): [BindingTag or picker] -->
	{#if memberMode === 'Bindings' && resolvedServiceId}
		<div class="flex flex-wrap items-center gap-1.5">
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
