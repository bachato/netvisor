<script lang="ts">
	import { createQuery, useQueryClient } from '@tanstack/svelte-query';
	import { queryKeys } from '$lib/api/query-client';
	import { apiClient } from '$lib/api/client';
	import type { IfEntry, Interface } from '$lib/features/hosts/types/base';
	import { getHostByIdFromCache } from '$lib/features/hosts/queries';
	import { getSubnetByIdFromCache } from '$lib/features/subnets/queries';
	import ConfigHeader from '$lib/shared/components/forms/config/ConfigHeader.svelte';
	import CollapsibleCard from '$lib/shared/components/data/CollapsibleCard.svelte';
	import InfoRow from '$lib/shared/components/data/InfoRow.svelte';
	import IfEntryDetailsCard from '$lib/features/hosts/components/IfEntryDetailsCard.svelte';
	import {
		hosts_ifEntries_cdpNeighbor,
		hosts_ifEntries_chassisId,
		hosts_ifEntries_index,
		hosts_ifEntries_lldpNeighbor,
		hosts_ifEntries_lldpSysDescr,
		hosts_ifEntries_managementAddress,
		hosts_ifEntries_portId,
		hosts_ifEntries_remoteAddress,
		hosts_ifEntries_remoteDevice,
		hosts_ifEntries_remotePlatform,
		hosts_ifEntries_remotePort,
		hosts_ifEntries_remoteSystemName
	} from '$lib/paraglide/messages';

	interface Props {
		ifEntry: IfEntry;
	}

	let { ifEntry }: Props = $props();

	const queryClient = useQueryClient();

	// Linked Interface + Subnet resolution
	let linkedInterface = $derived.by(() => {
		if (!ifEntry.interface_id) return null;
		const allInterfaces = queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
		return allInterfaces.find((i) => i.id === ifEntry.interface_id) ?? null;
	});

	let linkedSubnet = $derived.by(() => {
		if (!linkedInterface) return null;
		return getSubnetByIdFromCache(queryClient, linkedInterface.subnet_id);
	});

	// Neighbor resolution
	let neighborHost = $derived.by(() => {
		if (!ifEntry.neighbor) return null;
		if (ifEntry.neighbor.type === 'Host') {
			return getHostByIdFromCache(queryClient, ifEntry.neighbor.id);
		}
		const allIfEntries = queryClient.getQueryData<IfEntry[]>(queryKeys.ifEntries.all) ?? [];
		const remoteEntry = allIfEntries.find((e) => e.id === ifEntry.neighbor!.id);
		if (remoteEntry) {
			return getHostByIdFromCache(queryClient, remoteEntry.host_id);
		}
		return null;
	});

	let neighborIfEntry = $derived.by(() => {
		if (!ifEntry.neighbor || ifEntry.neighbor.type !== 'IfEntry') return null;
		const allIfEntries = queryClient.getQueryData<IfEntry[]>(queryKeys.ifEntries.all) ?? [];
		return allIfEntries.find((e) => e.id === ifEntry.neighbor!.id) ?? null;
	});

	// VLAN resolution
	const vlansQuery = createQuery(() => ({
		queryKey: ['vlans', 'forNetwork', ifEntry.network_id],
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/v1/vlans', {
				params: { query: { network_id: ifEntry.network_id } }
			});
			return data?.data ?? [];
		},
		staleTime: 30000
	}));

	let nativeVlan = $derived.by(() => {
		if (!ifEntry.native_vlan_id || !vlansQuery.data) return null;
		const vlan = vlansQuery.data.find((v) => v.id === ifEntry.native_vlan_id);
		return vlan ? { id: vlan.id!, vlan_number: vlan.vlan_number, name: vlan.name } : null;
	});

	let taggedVlans = $derived.by(() => {
		if (!ifEntry.vlan_ids?.length || !vlansQuery.data) return [];
		return ifEntry.vlan_ids
			.map((id) => vlansQuery.data!.find((v) => v.id === id))
			.filter(Boolean)
			.map((v) => ({ id: v!.id!, vlan_number: v!.vlan_number, name: v!.name }));
	});

	let cdpExpanded = $state(false);
	let lldpExpanded = $state(false);
</script>

<div class="space-y-6">
	<ConfigHeader
		title={ifEntry.if_name || ifEntry.if_descr || `Interface ${ifEntry.if_index}`}
		subtitle={hosts_ifEntries_index({ index: ifEntry.if_index })}
	/>

	<IfEntryDetailsCard
		{ifEntry}
		{linkedInterface}
		{linkedSubnet}
		{neighborHost}
		{neighborIfEntry}
		{nativeVlan}
		{taggedVlans}
	/>

	<!-- CDP Neighbor Info Section -->
	<CollapsibleCard title={hosts_ifEntries_cdpNeighbor()} bind:expanded={cdpExpanded}>
		<InfoRow label={hosts_ifEntries_remoteDevice()}>{ifEntry.cdp_device_id || '-'}</InfoRow>
		<InfoRow label={hosts_ifEntries_remotePort()}>{ifEntry.cdp_port_id || '-'}</InfoRow>
		<InfoRow label={hosts_ifEntries_remoteAddress()} mono>{ifEntry.cdp_address || '-'}</InfoRow>
		<InfoRow label={hosts_ifEntries_remotePlatform()}>{ifEntry.cdp_platform || '-'}</InfoRow>
	</CollapsibleCard>

	<!-- LLDP Neighbor Info Section -->
	<CollapsibleCard title={hosts_ifEntries_lldpNeighbor()} bind:expanded={lldpExpanded}>
		<InfoRow label={hosts_ifEntries_chassisId()} mono
			>{ifEntry.lldp_chassis_id?.value || '-'}</InfoRow
		>
		<InfoRow label={hosts_ifEntries_portId()} mono>{ifEntry.lldp_port_id?.value || '-'}</InfoRow>
		<InfoRow label={hosts_ifEntries_remoteSystemName()}>{ifEntry.lldp_sys_name || '-'}</InfoRow>
		<InfoRow label={hosts_ifEntries_remotePort()}>{ifEntry.lldp_port_desc || '-'}</InfoRow>
		<InfoRow label={hosts_ifEntries_managementAddress()} mono
			>{ifEntry.lldp_mgmt_addr || '-'}</InfoRow
		>
		<InfoRow label={hosts_ifEntries_lldpSysDescr()}>{ifEntry.lldp_sys_desc || '-'}</InfoRow>
	</CollapsibleCard>
</div>
