<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import { Crosshair } from 'lucide-svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import type { TopologyEditState } from '$lib/features/topology/state';
	import type {
		ElementRenderContext,
		ContainerRenderContext
	} from '$lib/features/topology/resolvers';
	import { inspector_thisEntity, topology_focusNode } from '$lib/paraglide/messages';
	import { entities, containerTypes } from '$lib/shared/stores/metadata';

	let {
		node,
		topology,
		editState,
		elementContext,
		containerContext
	}: {
		node: Node;
		topology: Topology;
		editState: TopologyEditState;
		elementContext?: ElementRenderContext;
		containerContext?: ContainerRenderContext;
	} = $props();

	const { fitView } = useSvelteFlow();

	function handleFocus() {
		fitView({ nodes: [{ id: node.id }], padding: 0.5, duration: 300 });
	}

	// Derive the section label from entity/container type metadata
	let sectionLabel = $derived.by(() => {
		if (elementContext) {
			const name = entities.getName(elementContext.elementType);
			return inspector_thisEntity({ name });
		}
		if (containerContext) {
			const name = containerTypes.getName(containerContext.containerType);
			return inspector_thisEntity({ name });
		}
		return '';
	});

	// For Interface elements: show the interface
	let thisInterface = $derived(elementContext?.iface ?? null);
	let interfaceDisplayContext = $derived({ subnets: topology.subnets });

	// For Service elements: show the service
	let thisService = $derived(
		elementContext?.elementType === 'Service' && elementContext.services.length > 0
			? elementContext.services[0]
			: null
	);
	let serviceDisplayContext = $derived({
		interfaceId: elementContext?.interfaceId ?? null,
		ports: topology.ports,
		showEntityTagPicker: false,
		tagPickerDisabled: true
	});

	// For containers: show the header/title
	let containerTitle = $derived(containerContext?.title ?? null);
</script>

<div>
	<div class="mb-2 flex items-center gap-2">
		<span class="text-secondary text-sm font-medium">{sectionLabel}</span>
		<button class="btn-icon p-0.5" onclick={handleFocus} title={topology_focusNode()}>
			<Crosshair class="h-3.5 w-3.5" />
		</button>
	</div>
	{#if thisInterface}
		<div class="card card-static">
			<EntityDisplayWrapper
				context={interfaceDisplayContext}
				item={thisInterface}
				displayComponent={InterfaceDisplay}
			/>
		</div>
	{:else if thisService}
		<div class="card card-static">
			<EntityDisplayWrapper
				context={serviceDisplayContext}
				item={thisService}
				displayComponent={ServiceDisplay}
			/>
		</div>
	{:else if containerTitle}
		<div class="card card-static">
			<p class="text-primary text-sm font-medium">{containerTitle}</p>
		</div>
	{/if}
</div>
