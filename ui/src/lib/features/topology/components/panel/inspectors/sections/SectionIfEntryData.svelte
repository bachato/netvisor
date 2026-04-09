<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import type { Topology, TopologyNode } from '$lib/features/topology/types/base';
	import type { ElementRenderContext } from '$lib/features/topology/resolvers';
	import IfEntryDetailsCard from '$lib/features/hosts/components/IfEntryDetailsCard.svelte';

	let {
		node,
		topology,
		elementContext
	}: {
		node: Node;
		topology: Topology;
		elementContext?: ElementRenderContext;
	} = $props();

	// Find the IfEntry: for Port elements use if_entry_id, for others use interface_id
	let ifEntry = $derived.by(() => {
		const nodeData = node.data as TopologyNode;
		const ifEntryId = 'if_entry_id' in nodeData ? (nodeData.if_entry_id as string) : undefined;
		if (ifEntryId) {
			return topology.if_entries.find((e) => e.id === ifEntryId) ?? null;
		}
		if (!elementContext?.interfaceId) return null;
		return topology.if_entries.find((e) => e.interface_id === elementContext?.interfaceId) ?? null;
	});

	// Resolve linked entities from topology data
	let linkedInterface = $derived.by(() => {
		if (!ifEntry?.interface_id) return null;
		return topology.interfaces.find((i) => i.id === ifEntry!.interface_id) ?? null;
	});

	let linkedSubnet = $derived.by(() => {
		if (!linkedInterface) return null;
		return topology.subnets.find((s) => s.id === linkedInterface!.subnet_id) ?? null;
	});

	let neighborHost = $derived.by(() => {
		if (!ifEntry?.neighbor) return null;
		if (ifEntry.neighbor.type === 'Host') {
			return topology.hosts.find((h) => h.id === ifEntry!.neighbor!.id) ?? null;
		}
		const remoteEntry = topology.if_entries.find((e) => e.id === ifEntry!.neighbor!.id);
		if (remoteEntry) {
			return topology.hosts.find((h) => h.id === remoteEntry.host_id) ?? null;
		}
		return null;
	});

	let neighborIfEntry = $derived.by(() => {
		if (!ifEntry?.neighbor || ifEntry.neighbor.type !== 'IfEntry') return null;
		return topology.if_entries.find((e) => e.id === ifEntry!.neighbor!.id) ?? null;
	});

	let nativeVlan = $derived.by(() => {
		if (!ifEntry?.native_vlan_id || !('vlans' in topology)) return null;
		const vlans = (topology as any).vlans as Array<{
			id: string;
			vlan_number: number;
			name: string;
		}>;
		return vlans?.find((v) => v.id === ifEntry!.native_vlan_id) ?? null;
	});

	let taggedVlans = $derived.by(() => {
		if (!ifEntry?.vlan_ids?.length || !('vlans' in topology)) return [];
		const vlans = (topology as any).vlans as Array<{
			id: string;
			vlan_number: number;
			name: string;
		}>;
		if (!vlans) return [];
		return ifEntry!.vlan_ids!.map((id) => vlans.find((v) => v.id === id)).filter(Boolean) as Array<{
			id: string;
			vlan_number: number;
			name: string;
		}>;
	});
</script>

{#if ifEntry}
	<IfEntryDetailsCard
		{ifEntry}
		{linkedInterface}
		{linkedSubnet}
		{neighborHost}
		{neighborIfEntry}
		{nativeVlan}
		{taggedVlans}
	/>
{/if}
