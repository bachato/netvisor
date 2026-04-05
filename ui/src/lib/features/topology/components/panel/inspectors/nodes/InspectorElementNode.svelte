<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import {
		useTopologiesQuery,
		selectedTopologyId,
		autoRebuild,
		activePerspective
	} from '$lib/features/topology/queries';
	import type { TopologyNode, Topology } from '$lib/features/topology/types/base';
	import { resolveElementNode } from '$lib/features/topology/resolvers';
	import { getTopologyEditState, getOptionDisabledTooltip } from '$lib/features/topology/state';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import OptionToggle from '../../options/OptionToggle.svelte';
	import OptionsCard from '../../options/OptionsCard.svelte';
	import { getInspectorConfig, getSectionComponent } from '../perspective-config';
	import {
		topology_hidePorts,
		topology_hidePortsHelp,
		topology_hideVmOnContainer,
		topology_hideVmOnContainerHelp
	} from '$lib/paraglide/messages';

	let { node }: { node: Node } = $props();

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

	let resolved = $derived(
		topology ? resolveElementNode(node.id, node.data as TopologyNode, topology) : null
	);

	// Perspective-driven section config
	let config = $derived(getInspectorConfig($activePerspective));
	let sections = $derived(config.element_sections);

	// Contextual hint conditions for options card
	let servicesOnThisInterface = $derived(
		(resolved?.services ?? []).filter((s) =>
			s.bindings.some((b) => b.interface_id === resolved?.interfaceId || b.interface_id === null)
		)
	);
	let hasPortBindings = $derived(
		servicesOnThisInterface.some((s) => s.bindings.some((b) => b.type === 'Port'))
	);
	let isVirtualized = $derived(resolved?.host?.virtualization != null);
</script>

{#if topology && resolved}
	<div class="space-y-4">
		{#if !editState.isReadonly && (hasPortBindings || isVirtualized)}
			<OptionsCard>
				{#if hasPortBindings}
					<OptionToggle
						label={topology_hidePorts()}
						helpText={topology_hidePortsHelp()}
						path="request"
						optionKey="hide_ports"
						disabled={!editState.isEditable}
						disabledReason={getOptionDisabledTooltip(editState.disabledReason)}
					/>
				{/if}
				{#if isVirtualized}
					<OptionToggle
						label={topology_hideVmOnContainer()}
						helpText={topology_hideVmOnContainerHelp()}
						path="request"
						optionKey="hide_vm_title_on_docker_container"
						disabled={!editState.isEditable}
						disabledReason={getOptionDisabledTooltip(editState.disabledReason)}
					/>
				{/if}
			</OptionsCard>
		{/if}

		{#each sections as section (section)}
			{@const SectionComponent = getSectionComponent(section)}
			<SectionComponent {node} {topology} {editState} elementContext={resolved} />
		{/each}
	</div>
{/if}
