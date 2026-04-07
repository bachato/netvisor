<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import type { ElementRenderContext } from '$lib/features/topology/resolvers';
	import {
		inspector_ifEntryData,
		inspector_snmpStatus,
		common_speed,
		inspector_lldpNeighbor,
		inspector_fdbMacs,
		inspector_nativeVlan,
		inspector_taggedVlans
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

	// Find the IfEntry matching this interface
	let ifEntry = $derived.by(() => {
		if (!elementContext?.interfaceId) return null;
		return topology.if_entries.find((e) => e.interface_id === elementContext?.interfaceId) ?? null;
	});

	function formatSpeed(bps: number | null | undefined): string {
		if (!bps) return '-';
		if (bps >= 1_000_000_000) return `${(bps / 1_000_000_000).toFixed(0)} Gbps`;
		if (bps >= 1_000_000) return `${(bps / 1_000_000).toFixed(0)} Mbps`;
		if (bps >= 1_000) return `${(bps / 1_000).toFixed(0)} Kbps`;
		return `${bps} bps`;
	}

	function formatOperStatus(status: string): string {
		const map: Record<string, string> = {
			Up: 'Up',
			Down: 'Down',
			Testing: 'Testing',
			Unknown: 'Unknown',
			Dormant: 'Dormant',
			NotPresent: 'Not Present',
			LowerLayerDown: 'Lower Layer Down'
		};
		return map[status] ?? status;
	}

	let lldpNeighborName = $derived(ifEntry?.lldp_sys_name ?? ifEntry?.cdp_device_id ?? null);
	let lldpPortDesc = $derived(ifEntry?.lldp_port_desc ?? ifEntry?.cdp_port_id ?? null);
	let fdbMacs = $derived(ifEntry?.fdb_macs ?? []);
</script>

{#if ifEntry}
	<div>
		<span class="text-secondary mb-2 block text-sm font-medium">{inspector_ifEntryData()}</span>
		<div class="card card-static space-y-2 text-sm">
			<div class="flex justify-between">
				<span class="text-tertiary">{inspector_snmpStatus()}</span>
				<span class="text-primary">{formatOperStatus(ifEntry.oper_status)}</span>
			</div>
			{#if ifEntry.speed_bps}
				<div class="flex justify-between">
					<span class="text-tertiary">{common_speed()}</span>
					<span class="text-primary">{formatSpeed(ifEntry.speed_bps)}</span>
				</div>
			{/if}
			{#if lldpNeighborName}
				<div class="flex justify-between">
					<span class="text-tertiary">{inspector_lldpNeighbor()}</span>
					<span class="text-primary ml-2 truncate"
						>{lldpNeighborName}{lldpPortDesc ? ` (${lldpPortDesc})` : ''}</span
					>
				</div>
			{/if}
			{#if ifEntry.native_vlan_id != null}
				<div class="flex justify-between">
					<span class="text-tertiary">{inspector_nativeVlan()}</span>
					<span class="text-primary">{ifEntry.native_vlan_id}</span>
				</div>
			{/if}
			{#if ifEntry.vlan_ids && ifEntry.vlan_ids.length > 0}
				<div class="flex justify-between">
					<span class="text-tertiary">{inspector_taggedVlans()}</span>
					<span class="text-primary">{ifEntry.vlan_ids.join(', ')}</span>
				</div>
			{/if}
			{#if fdbMacs.length > 0}
				<div>
					<span class="text-tertiary block">{inspector_fdbMacs()}</span>
					<div class="mt-1 flex flex-wrap gap-1">
						{#each fdbMacs as mac}
							<span class="bg-surface-secondary rounded px-1.5 py-0.5 font-mono text-xs">{mac}</span
							>
						{/each}
					</div>
				</div>
			{/if}
		</div>
	</div>
{/if}
