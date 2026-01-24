<script lang="ts">
	import type { IfEntry } from '$lib/features/hosts/types/base';
	import { getAdminStatusLabels, getOperStatusLabels } from '$lib/features/snmp/types/base';
	import {
		common_macAddress,
		common_speed,
		common_status,
		common_unknown,
		hosts_ifEntries_adminStatus,
		hosts_ifEntries_aliasDescription,
		hosts_ifEntries_cdpNeighbor,
		hosts_ifEntries_details,
		hosts_ifEntries_index,
		hosts_ifEntries_lldpNeighbor,
		hosts_ifEntries_lldpSysDescr,
		hosts_ifEntries_managementAddress,
		hosts_ifEntries_operStatus,
		hosts_ifEntries_remoteAddress,
		hosts_ifEntries_remoteDevice,
		hosts_ifEntries_remotePlatform,
		hosts_ifEntries_remotePort,
		hosts_ifEntries_remoteSystemName,
		hosts_ifEntries_type
	} from '$lib/paraglide/messages';

	interface Props {
		ifEntry: IfEntry;
	}

	let { ifEntry }: Props = $props();

	function formatSpeed(speed: number | null | undefined): string {
		if (!speed) return common_unknown();
		if (speed >= 1_000_000_000) return `${(speed / 1_000_000_000).toFixed(1)} Gbps`;
		if (speed >= 1_000_000) return `${(speed / 1_000_000).toFixed(1)} Mbps`;
		if (speed >= 1_000) return `${(speed / 1_000).toFixed(1)} Kbps`;
		return `${speed} bps`;
	}

	let adminStatusLabel = $derived(getAdminStatusLabels()[ifEntry.admin_status] ?? common_unknown());

	let operStatusLabel = $derived(getOperStatusLabels()[ifEntry.oper_status] ?? common_unknown());

	let operStatusColor = $derived(() => {
		switch (ifEntry.oper_status) {
			case 'Up':
				return 'text-green-400 bg-green-400/10';
			case 'Down':
				return 'text-red-400 bg-red-400/10';
			case 'Dormant':
				return 'text-yellow-400 bg-yellow-400/10';
			default:
				return 'text-gray-400 bg-gray-400/10';
		}
	});
</script>

<div class="space-y-6 p-6">
	<!-- Header -->
	<div class="border-b border-gray-700 pb-4">
		<h3 class="text-primary text-lg font-medium">
			{ifEntry.if_descr || `Interface ${ifEntry.if_index}`}
		</h3>
		<p class="text-muted mt-1 text-sm">{hosts_ifEntries_index({ index: ifEntry.if_index })}</p>
	</div>

	<!-- Status Section -->
	<div class="space-y-4">
		<h4 class="text-secondary text-sm font-medium uppercase tracking-wide">{common_status()}</h4>
		<div class="grid grid-cols-2 gap-4">
			<div class="bg-tertiary/30 rounded-lg p-4">
				<span class="text-secondary block text-xs font-medium">{hosts_ifEntries_adminStatus()}</span
				>
				<p class="text-primary mt-1 text-sm font-medium">{adminStatusLabel}</p>
			</div>
			<div class="bg-tertiary/30 rounded-lg p-4">
				<span class="text-secondary block text-xs font-medium">{hosts_ifEntries_operStatus()}</span>
				<span
					class="mt-1 inline-flex items-center rounded px-2 py-0.5 text-sm font-medium {operStatusColor()}"
				>
					{operStatusLabel}
				</span>
			</div>
		</div>
	</div>

	<!-- Interface Details Section -->
	<div class="space-y-4">
		<h4 class="text-secondary text-sm font-medium uppercase tracking-wide">
			{hosts_ifEntries_details()}
		</h4>
		<div class="grid grid-cols-2 gap-4">
			<div class="bg-tertiary/30 rounded-lg p-4">
				<span class="text-secondary block text-xs font-medium">{hosts_ifEntries_type()}</span>
				<p class="text-primary mt-1 text-sm">{ifEntry.if_type}</p>
			</div>

			{#if ifEntry.mac_address}
				<div class="bg-tertiary/30 rounded-lg p-4">
					<span class="text-secondary block text-xs font-medium">{common_macAddress()}</span>
					<p class="text-primary mt-1 font-mono text-sm">{ifEntry.mac_address}</p>
				</div>
			{/if}

			<div class="bg-tertiary/30 rounded-lg p-4">
				<span class="text-secondary block text-xs font-medium">{common_speed()}</span>
				<p class="text-primary mt-1 text-sm">{formatSpeed(ifEntry.speed_bps)}</p>
			</div>
		</div>
	</div>

	<!-- Alias Section -->
	{#if ifEntry.if_alias}
		<div class="space-y-4">
			<h4 class="text-secondary text-sm font-medium uppercase tracking-wide">
				{hosts_ifEntries_aliasDescription()}
			</h4>
			<div class="bg-tertiary/30 rounded-lg p-4">
				<p class="text-primary text-sm">{ifEntry.if_alias}</p>
			</div>
		</div>
	{/if}

	<!-- CDP Neighbor Info Section -->
	{#if ifEntry.cdp_device_id || ifEntry.cdp_port_id || ifEntry.cdp_address}
		<div class="space-y-4">
			<h4 class="text-secondary text-sm font-medium uppercase tracking-wide">
				{hosts_ifEntries_cdpNeighbor()}
			</h4>
			<div class="grid grid-cols-2 gap-4">
				{#if ifEntry.cdp_device_id}
					<div class="bg-tertiary/30 rounded-lg p-4">
						<span class="text-secondary block text-xs font-medium"
							>{hosts_ifEntries_remoteDevice()}</span
						>
						<p class="text-primary mt-1 text-sm">{ifEntry.cdp_device_id}</p>
					</div>
				{/if}
				{#if ifEntry.cdp_port_id}
					<div class="bg-tertiary/30 rounded-lg p-4">
						<span class="text-secondary block text-xs font-medium"
							>{hosts_ifEntries_remotePort()}</span
						>
						<p class="text-primary mt-1 text-sm">{ifEntry.cdp_port_id}</p>
					</div>
				{/if}
				{#if ifEntry.cdp_address}
					<div class="bg-tertiary/30 rounded-lg p-4">
						<span class="text-secondary block text-xs font-medium"
							>{hosts_ifEntries_remoteAddress()}</span
						>
						<p class="text-primary mt-1 font-mono text-sm">{ifEntry.cdp_address}</p>
					</div>
				{/if}
				{#if ifEntry.cdp_platform}
					<div class="bg-tertiary/30 rounded-lg p-4">
						<span class="text-secondary block text-xs font-medium"
							>{hosts_ifEntries_remotePlatform()}</span
						>
						<p class="text-primary mt-1 text-sm">{ifEntry.cdp_platform}</p>
					</div>
				{/if}
			</div>
		</div>
	{/if}

	<!-- LLDP Neighbor Info Section -->
	{#if ifEntry.lldp_sys_name || ifEntry.lldp_port_desc || ifEntry.lldp_mgmt_addr}
		<div class="space-y-4">
			<h4 class="text-secondary text-sm font-medium uppercase tracking-wide">
				{hosts_ifEntries_lldpNeighbor()}
			</h4>
			<div class="grid grid-cols-2 gap-4">
				{#if ifEntry.lldp_sys_name}
					<div class="bg-tertiary/30 rounded-lg p-4">
						<span class="text-secondary block text-xs font-medium"
							>{hosts_ifEntries_remoteSystemName()}</span
						>
						<p class="text-primary mt-1 text-sm">{ifEntry.lldp_sys_name}</p>
					</div>
				{/if}
				{#if ifEntry.lldp_port_desc}
					<div class="bg-tertiary/30 rounded-lg p-4">
						<span class="text-secondary block text-xs font-medium"
							>{hosts_ifEntries_remotePort()}</span
						>
						<p class="text-primary mt-1 text-sm">{ifEntry.lldp_port_desc}</p>
					</div>
				{/if}
				{#if ifEntry.lldp_mgmt_addr}
					<div class="bg-tertiary/30 rounded-lg p-4">
						<span class="text-secondary block text-xs font-medium"
							>{hosts_ifEntries_managementAddress()}</span
						>
						<p class="text-primary mt-1 font-mono text-sm">{ifEntry.lldp_mgmt_addr}</p>
					</div>
				{/if}
				{#if ifEntry.lldp_sys_desc}
					<div class="bg-tertiary/30 col-span-2 rounded-lg p-4">
						<span class="text-secondary block text-xs font-medium"
							>{hosts_ifEntries_lldpSysDescr()}</span
						>
						<p class="text-primary mt-1 text-sm">{ifEntry.lldp_sys_desc}</p>
					</div>
				{/if}
			</div>
		</div>
	{/if}
</div>
