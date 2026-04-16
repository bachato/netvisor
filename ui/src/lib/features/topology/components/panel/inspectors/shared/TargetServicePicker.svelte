<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import type { DependencyTarget } from '../../../../resolvers';
	import type { Topology } from '../../../../types/base';
	import {
		dependencies_pickServicesOnHost,
		dependencies_pickServicesAtIp
	} from '$lib/paraglide/messages';

	let {
		topology,
		target,
		onChange
	}: {
		topology: Topology;
		target: Extract<DependencyTarget, { kind: 'host' | 'ipAddress' }>;
		/** Called whenever the user toggles a checkbox with the full set of picked service IDs. */
		onChange: (pickedServiceIds: string[]) => void;
	} = $props();

	let candidates = $derived(
		target.candidateServiceIds
			.map((id) => topology.services.find((s) => s.id === id))
			.filter((s): s is NonNullable<typeof s> => !!s)
	);

	// One mini TanStack form per picker keeps each checkbox backed by a real field
	// (matching the shared `Checkbox` component's contract) while letting the parent
	// InspectorMultiSelect stay in charge of the overall submit payload.
	const form = createForm(() => ({
		defaultValues: Object.fromEntries(
			target.candidateServiceIds.map((id) => [id, target.candidateServiceIds.length === 1])
		) as Record<string, boolean>,
		onSubmit: () => {}
	}));

	$effect(() => {
		const values = form.state.values;
		const picks = Object.entries(values)
			.filter(([, checked]) => checked)
			.map(([id]) => id);
		onChange(picks);
	});

	let heading = $derived(
		target.kind === 'host'
			? dependencies_pickServicesOnHost({ hostName: target.label })
			: dependencies_pickServicesAtIp({ ipAddress: target.label })
	);
</script>

<div class="card card-static space-y-1.5 p-2">
	<div class="text-primary text-xs font-medium">{heading}</div>
	{#if target.kind === 'ipAddress' && target.hostName}
		<div class="text-tertiary truncate text-[10px]">{target.hostName}</div>
	{/if}
	{#if candidates.length === 0}
		<div class="text-tertiary text-xs italic">—</div>
	{:else}
		<ul class="space-y-1">
			{#each candidates as service (service.id)}
				<li>
					<form.Field name={service.id}>
						{#snippet children(field)}
							<Checkbox label={service.name} id="target-{target.elementId}-{service.id}" {field} />
						{/snippet}
					</form.Field>
				</li>
			{/each}
		</ul>
	{/if}
</div>
