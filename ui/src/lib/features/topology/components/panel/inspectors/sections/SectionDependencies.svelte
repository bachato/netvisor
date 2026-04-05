<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import type { ElementRenderContext } from '$lib/features/topology/resolvers';
	import {
		common_dependenciesLabel,
		common_inbound,
		common_outbound,
		inspector_noDependencies
	} from '$lib/paraglide/messages';

	let {
		node,
		topology,
		elementContext
	}: {
		node: Node;
		topology: Topology;
		elementContext?: ElementRenderContext;
	} = $props();

	let service = $derived(
		elementContext?.elementType === 'Service' && elementContext.services.length > 0
			? elementContext.services[0]
			: null
	);

	// Find dependencies where this service is a member
	let inboundDeps = $derived.by(() => {
		if (!service) return [];
		return topology.dependencies.filter((d) => {
			const members = d.members;
			if (members.type === 'Services') {
				// Service is a target (last in the chain for RequestPath, spoke for HubAndSpoke)
				const idx = members.service_ids.indexOf(service!.id);
				return idx > 0; // Not the source (first)
			}
			if (members.type === 'Bindings') {
				const serviceBindingIds = service!.bindings.map((b) => b.id);
				const idx = members.binding_ids.findIndex((bid) => serviceBindingIds.includes(bid));
				return idx > 0;
			}
			return false;
		});
	});

	let outboundDeps = $derived.by(() => {
		if (!service) return [];
		return topology.dependencies.filter((d) => {
			const members = d.members;
			if (members.type === 'Services') {
				return members.service_ids[0] === service!.id;
			}
			if (members.type === 'Bindings') {
				const serviceBindingIds = service!.bindings.map((b) => b.id);
				return serviceBindingIds.includes(members.binding_ids[0]);
			}
			return false;
		});
	});

	let hasDeps = $derived(inboundDeps.length > 0 || outboundDeps.length > 0);

	function getDepServiceNames(dep: Topology['dependencies'][number]): string[] {
		const members = dep.members;
		if (members.type === 'Services') {
			return members.service_ids.map(
				(id) => topology.services.find((s) => s.id === id)?.name ?? id
			);
		}
		if (members.type === 'Bindings') {
			return members.binding_ids.map((bid) => {
				const svc = topology.services.find((s) => s.bindings.some((b) => b.id === bid));
				return svc?.name ?? bid;
			});
		}
		return [];
	}
</script>

<div>
	<span class="text-secondary mb-2 block text-sm font-medium">{common_dependenciesLabel()}</span>
	{#if !hasDeps}
		<p class="text-tertiary text-sm">{inspector_noDependencies()}</p>
	{:else}
		<div class="space-y-3">
			{#if outboundDeps.length > 0}
				<div>
					<span class="text-tertiary mb-1 block text-xs font-medium uppercase"
						>{common_outbound()}</span
					>
					<div class="space-y-1">
						{#each outboundDeps as dep (dep.id)}
							<div class="card card-static text-sm">
								<div class="flex items-center gap-2">
									<span class="text-primary font-medium">{dep.name}</span>
									<span class="text-tertiary text-xs">{dep.dependency_type}</span>
								</div>
								<p class="text-tertiary mt-0.5 truncate text-xs">
									{getDepServiceNames(dep).join(' → ')}
								</p>
							</div>
						{/each}
					</div>
				</div>
			{/if}
			{#if inboundDeps.length > 0}
				<div>
					<span class="text-tertiary mb-1 block text-xs font-medium uppercase"
						>{common_inbound()}</span
					>
					<div class="space-y-1">
						{#each inboundDeps as dep (dep.id)}
							<div class="card card-static text-sm">
								<div class="flex items-center gap-2">
									<span class="text-primary font-medium">{dep.name}</span>
									<span class="text-tertiary text-xs">{dep.dependency_type}</span>
								</div>
								<p class="text-tertiary mt-0.5 truncate text-xs">
									{getDepServiceNames(dep).join(' → ')}
								</p>
							</div>
						{/each}
					</div>
				</div>
			{/if}
		</div>
	{/if}
</div>
