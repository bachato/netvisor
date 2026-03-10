<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import {
		useTopologiesQuery,
		selectedTopologyId,
		topologyOptions,
		autoRebuild
	} from '$lib/features/topology/queries';
	import type { InterfaceNode, Topology } from '$lib/features/topology/types/base';
	import { getTopologyStateInfo } from '$lib/features/topology/state';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import OptionToggle from '../../options/OptionToggle.svelte';
	import OptionsCard from '../../options/OptionsCard.svelte';
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

	// Freshness gating for inline edits
	let isReadonly = $derived(!!topologyContext);
	let liveEditsEnabled = $derived(
		!isReadonly && topology && getTopologyStateInfo(topology, $autoRebuild).type == 'fresh'
	);

	let nodeData = $derived(node.data as InterfaceNode);

	let host = $derived(topology ? topology.hosts.find((h) => h.id == nodeData.host_id) : null);

	// Get the interface for this node from topology.interfaces
	let thisInterface = $derived(
		topology ? topology.interfaces.find((i) => i.id === nodeData.interface_id) : null
	);

	// Get all services for this host
	let servicesForHost = $derived(
		topology ? topology.services.filter((s) => s.host_id == nodeData.host_id) : []
	);

	// Filter services bound to this specific interface
	let servicesOnThisInterface = $derived(
		servicesForHost.filter((s) =>
			s.bindings.some((b) => b.interface_id === nodeData.interface_id || b.interface_id === null)
		)
	);

	// Get other interfaces on this host (excluding the current one)
	let otherInterfaces = $derived(
		topology
			? topology.interfaces.filter(
					(i) => i.host_id === nodeData.host_id && i.id !== nodeData.interface_id
				)
			: []
	);

	// Context for interface displays
	let interfaceContext = $derived({ subnets: topology?.subnets ?? [] });

	// Contextual hint conditions
	let hasPortBindings = $derived(
		servicesOnThisInterface.some((s) => s.bindings.some((b) => b.type === 'Port'))
	);
	let isVirtualized = $derived(host?.virtualization != null);

	// Context for service displays - include ports for actual port number display
	let serviceContext = $derived({
		interfaceId: nodeData.interface_id ?? null,
		ports: topology?.ports ?? [],
		showEntityTagPicker: !isReadonly,
		tagPickerDisabled: !liveEditsEnabled,
		categoryInteractable: !!liveEditsEnabled,
		entityTags: topology?.entity_tags ?? []
	});

	// Context for host display
	let hostContext = $derived({
		services: topology?.services.filter((s) => host && s.host_id == host.id) ?? [],
		showEntityTagPicker: !isReadonly,
		tagPickerDisabled: !liveEditsEnabled,
		entityTags: topology?.entity_tags ?? []
	});
</script>

<div class="space-y-4">
	{#if hasPortBindings || isVirtualized}
		<OptionsCard>
			{#if hasPortBindings}
				<OptionToggle
					label={topology_hidePorts()}
					helpText={topology_hidePortsHelp()}
					path="request"
					optionKey="hide_ports"
				/>
			{/if}
			{#if isVirtualized}
				<OptionToggle
					label={topology_hideVmOnContainer()}
					helpText={topology_hideVmOnContainerHelp()}
					path="request"
					optionKey="hide_vm_title_on_docker_container"
				/>
			{/if}
		</OptionsCard>
	{/if}

	<!-- This Interface -->
	{#if thisInterface}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">This Interface</span>
			<div class="card card-static">
				<EntityDisplayWrapper
					context={interfaceContext}
					item={thisInterface}
					displayComponent={InterfaceDisplay}
				/>
			</div>
		</div>
	{/if}

	<!-- Services Bound to Interface -->
	{#if servicesOnThisInterface.length > 0}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">
				Services Bound to Interface
			</span>
			<div class="space-y-1">
				{#each servicesOnThisInterface as service (service.id)}
					<div class="card card-static">
						<EntityDisplayWrapper
							context={serviceContext}
							item={service}
							displayComponent={ServiceDisplay}
						/>
					</div>
				{/each}
			</div>
		</div>
	{/if}

	<!-- Host -->
	{#if host}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">Host</span>
			<div class="card card-static">
				<EntityDisplayWrapper context={hostContext} item={host} displayComponent={HostDisplay} />
			</div>
		</div>
	{/if}

	<!-- Other Host Interfaces -->
	{#if otherInterfaces.length > 0}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">
				Other Host Interface{otherInterfaces.length > 1 ? 's' : ''}
			</span>
			<div class="space-y-1">
				{#each otherInterfaces as iface (iface.id)}
					<div class="card card-static">
						<EntityDisplayWrapper
							context={interfaceContext}
							item={iface}
							displayComponent={InterfaceDisplay}
						/>
					</div>
				{/each}
			</div>
		</div>
	{/if}
</div>
