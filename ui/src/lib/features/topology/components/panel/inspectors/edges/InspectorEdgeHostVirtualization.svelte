<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import {
		useTopologiesQuery,
		selectedTopologyId,
		autoRebuild
	} from '$lib/features/topology/queries';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getTopologyEditState } from '$lib/features/topology/state';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import OptionToggle from '../../options/OptionToggle.svelte';
	import OptionsCard from '../../options/OptionsCard.svelte';
	import {
		topology_hideVmOnContainer,
		topology_hideVmOnContainerHelp
	} from '$lib/paraglide/messages';

	let { edge, vmServiceId }: { edge: Edge; vmServiceId: string } = $props();

	// Try to get topology from context (for share/embed pages), fallback to query + selected topology
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext ? $topologyContext : topologiesData.find((t) => t.id === $selectedTopologyId)
	);

	// Unified edit state
	let isReadonly = $derived(!!topologyContext);
	let editState = $derived(getTopologyEditState(topology, $autoRebuild, isReadonly));

	let vmService = $derived(topology ? topology.services.find((s) => s.id == vmServiceId) : null);
	let hypervisorHost = $derived(topology ? topology.hosts.find((h) => h.id == edge.target) : null);
</script>

<div class="space-y-3">
	<OptionsCard>
		<OptionToggle
			label={topology_hideVmOnContainer()}
			helpText={topology_hideVmOnContainerHelp()}
			path="request"
			optionKey="hide_vm_title_on_docker_container"
			disabled={!editState.isEditable}
		/>
	</OptionsCard>

	{#if vmService}
		<span class="text-secondary mb-2 block text-sm font-medium">VM Service</span>
		<div class="card card-static">
			<EntityDisplayWrapper
				context={{
					interfaceId: null,
					ports: topology?.ports ?? [],
					showEntityTagPicker: true,
					tagPickerDisabled: !editState.isEditable,
					entityTags: isReadonly ? (topology?.entity_tags ?? []) : undefined
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
					entityTags: isReadonly ? (topology?.entity_tags ?? []) : undefined
				}}
				item={hypervisorHost}
				displayComponent={HostDisplay}
			/>
		</div>
	{/if}
</div>
