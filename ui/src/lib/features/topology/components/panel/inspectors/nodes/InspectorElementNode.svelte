<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { autoRebuild, activeView } from '$lib/features/topology/queries';
	import type { TopologyNode } from '$lib/features/topology/types/base';
	import { resolveElementNode } from '$lib/features/topology/resolvers';
	import { useTopology } from '$lib/features/topology/context';
	import { getTopologyEditState, getOptionDisabledTooltip } from '$lib/features/topology/state';
	import OptionToggle from '../../options/OptionToggle.svelte';
	import OptionsCard from '../../options/OptionsCard.svelte';
	import { getInspectorConfig, getSectionComponent } from '../view-config';
	import { topology_hidePorts, topology_hidePortsHelp } from '$lib/paraglide/messages';

	let { node }: { node: Node } = $props();

	const { topology: topologyStore, isReadonly } = useTopology();
	let topology = $derived($topologyStore);

	let editState = $derived(getTopologyEditState(topology, $autoRebuild, isReadonly));

	let resolved = $derived(
		topology ? resolveElementNode(node.id, node.data as TopologyNode, topology) : null
	);

	// View-driven section config
	let config = $derived(getInspectorConfig($activeView));
	let sections = $derived(config.element_sections);

	// Contextual hint conditions for options card
	let servicesOnThisInterface = $derived(
		(resolved?.services ?? []).filter((s) =>
			s.bindings.some((b) => b.ip_address_id === resolved?.ipAddressId || b.ip_address_id === null)
		)
	);
	let hasPortBindings = $derived(
		servicesOnThisInterface.some((s) => s.bindings.some((b) => b.type === 'Port'))
	);
</script>

{#if topology && resolved}
	<div class="space-y-4">
		{#each sections as section (section)}
			{@const SectionComponent = getSectionComponent(section)}
			<SectionComponent {node} {topology} {editState} elementContext={resolved} />
		{/each}
	</div>
{/if}
