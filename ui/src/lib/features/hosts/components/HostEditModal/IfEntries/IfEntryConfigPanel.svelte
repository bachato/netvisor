<script lang="ts">
	import { useQueryClient } from '@tanstack/svelte-query';
	import { queryKeys } from '$lib/api/query-client';
	import type { IfEntry, Interface } from '$lib/features/hosts/types/base';
	import { getHostByIdFromCache } from '$lib/features/hosts/queries';
	import { getAdminStatusLabels, getOperStatusLabels } from '$lib/features/snmp/types/base';
	import ConfigHeader from '$lib/shared/components/forms/config/ConfigHeader.svelte';
	import CollapsibleCard from '$lib/shared/components/data/CollapsibleCard.svelte';
	import InfoRow from '$lib/shared/components/data/InfoRow.svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { IfEntryDisplay } from '$lib/shared/components/forms/selection/display/IfEntryDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import UnresolvedPlaceholder from '$lib/shared/components/data/UnresolvedPlaceholder.svelte';
	import { CornerDownRight } from 'lucide-svelte';
	import type { Color } from '$lib/shared/utils/styling';
	import {
		common_macAddress,
		common_speed,
		common_status,
		common_unknown,
		hosts_ifEntries_adminStatus,
		hosts_ifEntries_aliasDescription,
		hosts_ifEntries_cdpNeighbor,
		hosts_ifEntries_chassisId,
		hosts_ifEntries_details,
		hosts_ifEntries_ifName,
		hosts_ifEntries_index,
		hosts_ifEntries_interfaceId,
		hosts_ifEntries_lldpNeighbor,
		hosts_ifEntries_lldpSysDescr,
		hosts_ifEntries_managementAddress,
		hosts_ifEntries_neighbor,
		hosts_ifEntries_operStatus,
		hosts_ifEntries_portId,
		hosts_ifEntries_remoteAddress,
		hosts_ifEntries_remoteDevice,
		hosts_ifEntries_remotePlatform,
		hosts_ifEntries_remotePort,
		hosts_ifEntries_remoteSystemName,
		hosts_ifEntries_type,
		hosts_ifEntries_unresolvedInterface
	} from '$lib/paraglide/messages';

	interface Props {
		ifEntry: IfEntry;
	}

	let { ifEntry }: Props = $props();

	const queryClient = useQueryClient();

	function formatSpeed(speed: number | null | undefined): string {
		if (!speed) return common_unknown();
		if (speed >= 1_000_000_000) return `${(speed / 1_000_000_000).toFixed(1)} Gbps`;
		if (speed >= 1_000_000) return `${(speed / 1_000_000).toFixed(1)} Mbps`;
		if (speed >= 1_000) return `${(speed / 1_000).toFixed(1)} Kbps`;
		return `${speed} bps`;
	}

	let adminStatusLabel = $derived(getAdminStatusLabels()[ifEntry.admin_status] ?? common_unknown());
	let operStatusLabel = $derived(getOperStatusLabels()[ifEntry.oper_status] ?? common_unknown());

	let operStatusColor: Color = $derived.by(() => {
		switch (ifEntry.oper_status) {
			case 'Up':
				return 'Green';
			case 'Down':
				return 'Red';
			case 'Dormant':
				return 'Yellow';
			default:
				return 'Gray';
		}
	});

	// Linked Interface resolution
	let linkedInterface = $derived.by(() => {
		if (!ifEntry.interface_id) return null;
		const allInterfaces = queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
		return allInterfaces.find((i) => i.id === ifEntry.interface_id) ?? null;
	});

	// Neighbor resolution
	let neighborHost = $derived.by(() => {
		if (!ifEntry.neighbor) return null;
		if (ifEntry.neighbor.type === 'Host') {
			return getHostByIdFromCache(queryClient, ifEntry.neighbor.id);
		}
		// IfEntry type — resolve through the remote ifEntry's host_id
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

	// Section expand state
	let statusExpanded = $state(true);
	let detailsExpanded = $state(true);
	let cdpExpanded = $state(false);
	let lldpExpanded = $state(false);
</script>

<div class="space-y-6">
	<ConfigHeader
		title={ifEntry.if_name || ifEntry.if_descr || `Interface ${ifEntry.if_index}`}
		subtitle={hosts_ifEntries_index({ index: ifEntry.if_index })}
	/>

	<!-- Status Section -->
	<CollapsibleCard title={common_status()} bind:expanded={statusExpanded}>
		<InfoRow label={hosts_ifEntries_adminStatus()}>{adminStatusLabel}</InfoRow>
		<InfoRow label={hosts_ifEntries_operStatus()}>
			<Tag label={operStatusLabel} color={operStatusColor} />
		</InfoRow>
	</CollapsibleCard>

	<!-- Interface Details Section -->
	<CollapsibleCard title={hosts_ifEntries_details()} bind:expanded={detailsExpanded}>
		<InfoRow label={hosts_ifEntries_ifName()}>{ifEntry.if_name || '-'}</InfoRow>
		<InfoRow label={hosts_ifEntries_type()}>{ifEntry.if_type || '-'}</InfoRow>
		<InfoRow label={common_macAddress()} mono>{ifEntry.mac_address || '-'}</InfoRow>
		<InfoRow label={common_speed()}>{formatSpeed(ifEntry.speed_bps)}</InfoRow>
		<InfoRow label={hosts_ifEntries_aliasDescription()}>{ifEntry.if_alias || '-'}</InfoRow>

		<!-- Linked Interface -->
		{#if linkedInterface}
			<div class="pt-1">
				<span class="text-tertiary mb-1.5 block text-xs font-medium"
					>{hosts_ifEntries_interfaceId()}</span
				>
				<div class="card card-static">
					<EntityDisplayWrapper
						context={{ subnets: [] }}
						item={linkedInterface}
						displayComponent={InterfaceDisplay}
					/>
				</div>
			</div>
		{:else}
			<InfoRow label={hosts_ifEntries_interfaceId()}>-</InfoRow>
		{/if}

		<!-- Neighbor -->
		{#if ifEntry.neighbor}
			<div class="pt-1">
				<span class="text-tertiary mb-1.5 block text-xs font-medium"
					>{hosts_ifEntries_neighbor()}</span
				>
				<div class="space-y-1.5">
					{#if neighborHost}
						<div class="card card-static">
							<EntityDisplayWrapper
								context={{}}
								item={neighborHost}
								displayComponent={HostDisplay}
							/>
						</div>
					{/if}
					<div class="flex items-start gap-1.5">
						<CornerDownRight class="text-tertiary mt-1.5 h-4 w-4 flex-shrink-0" />
						{#if neighborIfEntry}
							<div class="card card-static min-w-0 flex-1">
								<EntityDisplayWrapper
									context={undefined}
									item={neighborIfEntry}
									displayComponent={IfEntryDisplay}
								/>
							</div>
						{:else}
							<div class="min-w-0 flex-1">
								<UnresolvedPlaceholder label={hosts_ifEntries_unresolvedInterface()} />
							</div>
						{/if}
					</div>
				</div>
			</div>
		{:else}
			<InfoRow label={hosts_ifEntries_neighbor()}>-</InfoRow>
		{/if}
	</CollapsibleCard>

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
