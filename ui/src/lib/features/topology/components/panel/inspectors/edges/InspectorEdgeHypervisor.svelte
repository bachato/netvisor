<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { autoRebuild } from '$lib/features/topology/queries';
	import { useTopology, selectedTopologyId } from '$lib/features/topology/context';
	import { getTopologyEditState } from '$lib/features/topology/state';

	let { edge, vmServiceId }: { edge: Edge; vmServiceId: string } = $props();

	const topo = useTopology();
	const topoStore = topo.fromContext ? topo.store : null;
	let isReadonly = topo.isReadonly;
	let topology = $derived(
		topoStore ? $topoStore : topo.query.data?.find((t) => t.id === $selectedTopologyId)
	);

	let editState = $derived(getTopologyEditState(topology, $autoRebuild, isReadonly));

	let vmService = $derived(topology ? topology.services.find((s) => s.id == vmServiceId) : null);
	let hypervisorHost = $derived(topology ? topology.hosts.find((h) => h.id == edge.target) : null);
</script>

<div class="space-y-3">
	{#if vmService}
		<span class="text-secondary mb-2 block text-sm font-medium">VM Service</span>
		<div class="card card-static">
			<EntityDisplayWrapper
				context={{
					ipAddressId: null,
					ports: topology?.ports ?? [],
					showEntityTagPicker: true,
					tagPickerDisabled: !editState.isEditable,
					entityTags: isReadonly ? (topology?.entity_tags ?? []) : undefined,
					compact: true
				}}
				item={vmService}
				displayComponent={ServiceDisplay}
			/>
		</div>
	{/if}

	{#if hypervisorHost}
		<span class="text-secondary mb-2 block text-sm font-medium">Hypervisor Host</span>
		<div class="card card-static">
			<EntityDisplayWrapper
				context={{
					services:
						topology?.services.filter((s) =>
							hypervisorHost ? s.host_id == hypervisorHost.id : false
						) ?? [],
					showEntityTagPicker: true,
					tagPickerDisabled: !editState.isEditable,
					entityTags: isReadonly ? (topology?.entity_tags ?? []) : undefined,
					compact: true
				}}
				item={hypervisorHost}
				displayComponent={HostDisplay}
			/>
		</div>
	{/if}
</div>
