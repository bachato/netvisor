<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import { Crosshair } from 'lucide-svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { IfEntryDisplay } from '$lib/shared/components/forms/selection/display/IfEntryDisplay.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import type { Topology, TopologyNode } from '$lib/features/topology/types/base';
	import type { TopologyEditState } from '$lib/features/topology/state';
	import type {
		ElementRenderContext,
		ContainerRenderContext
	} from '$lib/features/topology/resolvers';
	import { inspector_thisEntity, topology_focusNode } from '$lib/paraglide/messages';
	import { containerTypes, entities } from '$lib/shared/stores/metadata';
	import { activeView } from '$lib/features/topology/queries';

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
			const name = entities.getItem(elementContext.elementType)?.name ?? elementContext.elementType;
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
	let isApplicationView = $derived($activeView === 'Application');
	let serviceDisplayContext = $derived({
		interfaceId: isApplicationView ? null : (elementContext?.interfaceId ?? null),
		ports: isApplicationView ? [] : topology.ports,
		showEntityTagPicker: !editState.isReadonly,
		tagPickerDisabled: !editState.isEditable,
		entityTags: topology.entity_tags
	});

	// For Port elements: show the IfEntry
	let thisIfEntry = $derived.by(() => {
		if (elementContext?.elementType !== 'Port') return null;
		const nodeData = node.data as TopologyNode;
		const ifEntryId = 'if_entry_id' in nodeData ? (nodeData.if_entry_id as string) : undefined;
		return ifEntryId ? (topology.if_entries.find((e) => e.id === ifEntryId) ?? null) : null;
	});

	// For Host and Virtualizer containers: show the host
	let thisHost = $derived.by(() => {
		if (containerContext?.containerType === 'Host') {
			// Find a child Port element to get the host_id
			const childElement = topology.nodes.find(
				(n) => n.node_type === 'Element' && n.container_id === node.id
			);
			if (childElement && 'host_id' in childElement) {
				return topology.hosts.find((h) => h.id === childElement.host_id) ?? null;
			}
			// Fallback: match by name
			return topology.hosts.find((h) => h.name === containerContext?.title) ?? null;
		}
		if (containerContext?.containerType === 'Virtualizer') {
			// Virtualizer container groups VMs — resolve the virtualizer host
			// via a child VM's virtualization data
			const childElement = topology.nodes.find(
				(n) => n.node_type === 'Element' && n.container_id === node.id
			);
			if (childElement && 'host_id' in childElement) {
				const vmHost = topology.hosts.find((h) => h.id === childElement.host_id);
				if (vmHost?.virtualization) {
					const virtService = topology.services.find(
						(s) => s.id === vmHost.virtualization!.details.service_id
					);
					if (virtService?.host_id) {
						return topology.hosts.find((h) => h.id === virtService.host_id) ?? null;
					}
				}
			}
			// Fallback: match by name
			return topology.hosts.find((h) => h.name === containerContext?.title) ?? null;
		}
		return null;
	});
	let hostDisplayContext = $derived({
		showEntityTagPicker: !editState.isReadonly,
		tagPickerDisabled: !editState.isEditable,
		entityTags: topology.entity_tags
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
	{#if thisIfEntry}
		<div class="card card-static">
			<EntityDisplayWrapper
				context={undefined}
				item={thisIfEntry}
				displayComponent={IfEntryDisplay}
			/>
		</div>
	{:else if thisInterface}
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
	{:else if thisHost}
		<div class="card card-static">
			<EntityDisplayWrapper
				context={hostDisplayContext}
				item={thisHost}
				displayComponent={HostDisplay}
			/>
		</div>
	{:else if containerTitle}
		<div class="card card-static">
			<p class="text-primary text-sm font-medium">{containerTitle}</p>
		</div>
	{/if}
</div>
