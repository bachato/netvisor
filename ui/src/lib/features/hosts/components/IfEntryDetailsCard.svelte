<script lang="ts">
	import type { IfEntry, Interface } from '$lib/features/hosts/types/base';
	import type { Subnet } from '$lib/features/subnets/types/base';
	import type { Host } from '$lib/features/hosts/types/base';
	import { getAdminStatusLabels, getOperStatusLabels } from '$lib/features/credentials/types/base';
	import CollapsibleCard from '$lib/shared/components/data/CollapsibleCard.svelte';
	import InfoRow from '$lib/shared/components/data/InfoRow.svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import EntityTag from '$lib/shared/components/data/EntityTag.svelte';
	import { entityRef } from '$lib/shared/components/data/types';
	import { entities } from '$lib/shared/stores/metadata';
	import type { Color } from '$lib/shared/utils/styling';
	import {
		common_details,
		common_ipAddress,
		common_macAddress,
		common_speed,
		common_status,
		common_unknown,
		hosts_ifEntries_adminStatus,
		hosts_ifEntries_aliasDescription,
		hosts_ifEntries_index,
		hosts_ifEntries_neighbor,
		hosts_ifEntries_operStatus
	} from '$lib/paraglide/messages';

	interface Props {
		ifEntry: IfEntry;
		linkedInterface?: Interface | null;
		linkedSubnet?: Subnet | null;
		neighborHost?: Host | null;
		neighborIfEntry?: IfEntry | null;
		showStatus?: boolean;
	}

	let {
		ifEntry,
		linkedInterface = null,
		linkedSubnet = null,
		neighborHost = null,
		neighborIfEntry = null,
		showStatus = true
	}: Props = $props();

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

	let statusExpanded = $state(true);
	let detailsExpanded = $state(true);
</script>

{#if showStatus}
	<CollapsibleCard title={common_status()} bind:expanded={statusExpanded}>
		<InfoRow label={hosts_ifEntries_adminStatus()}>{adminStatusLabel}</InfoRow>
		<InfoRow label={hosts_ifEntries_operStatus()}>
			<Tag label={operStatusLabel} color={operStatusColor} />
		</InfoRow>
	</CollapsibleCard>
{/if}

<CollapsibleCard title={common_details()} bind:expanded={detailsExpanded}>
	<InfoRow label="ifName">{ifEntry.if_name || '-'}</InfoRow>
	<InfoRow label="ifType">{ifEntry.if_type || '-'}</InfoRow>
	<InfoRow label={common_macAddress()} mono>{ifEntry.mac_address || '-'}</InfoRow>
	<InfoRow label={common_speed()}>{formatSpeed(ifEntry.speed_bps)}</InfoRow>
	<InfoRow label={hosts_ifEntries_aliasDescription()}>{ifEntry.if_alias || '-'}</InfoRow>
	<InfoRow label={hosts_ifEntries_index({ index: ifEntry.if_index })}>{ifEntry.if_index}</InfoRow>

	<InfoRow label={common_ipAddress()}>
		{#if linkedInterface}
			<div class="flex flex-wrap items-center gap-1">
				<EntityTag
					entityRef={entityRef('Interface', linkedInterface.id, linkedInterface)}
					label={linkedInterface.ip_address}
					icon={entities.getIconComponent('Interface')}
					color={entities.getColorHelper('Interface').color}
				/>
				{#if linkedSubnet}
					<span class="text-tertiary text-xs">on</span>
					<EntityTag
						entityRef={entityRef('Subnet', linkedSubnet.id, linkedSubnet)}
						label={linkedSubnet.name && linkedSubnet.name !== linkedSubnet.cidr
							? `${linkedSubnet.name} (${linkedSubnet.cidr})`
							: linkedSubnet.cidr}
						icon={entities.getIconComponent('Subnet')}
						color={entities.getColorHelper('Subnet').color}
					/>
				{/if}
			</div>
		{:else}
			-
		{/if}
	</InfoRow>

	<InfoRow label={hosts_ifEntries_neighbor()}>
		{#if ifEntry.neighbor}
			<div class="flex flex-wrap items-center gap-1">
				{#if neighborIfEntry}
					<EntityTag
						entityRef={entityRef('IfEntry', neighborIfEntry.id, neighborIfEntry)}
						label={neighborIfEntry.if_name ||
							neighborIfEntry.if_descr ||
							`Index ${neighborIfEntry.if_index}`}
						icon={entities.getIconComponent('IfEntry')}
						color={entities.getColorHelper('IfEntry').color}
					/>
					<span class="text-tertiary text-xs">on</span>
				{/if}
				{#if neighborHost}
					<EntityTag
						entityRef={entityRef('Host', neighborHost.id, neighborHost)}
						label={neighborHost.name}
						icon={entities.getIconComponent('Host')}
						color={entities.getColorHelper('Host').color}
					/>
				{/if}
			</div>
		{:else}
			-
		{/if}
	</InfoRow>
</CollapsibleCard>
