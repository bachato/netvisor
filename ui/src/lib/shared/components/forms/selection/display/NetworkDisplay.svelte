<script lang="ts" context="module">
	import { entities } from '$lib/shared/stores/metadata';
	import { entityRef } from '$lib/shared/components/data/types';
	import type { SnmpCredential } from '$lib/features/snmp/types/base';

	export interface NetworkDisplayContext {
		snmpCredentials?: SnmpCredential[];
	}

	export const NetworkDisplay: EntityDisplayComponent<Network, NetworkDisplayContext> = {
		getId: (network: Network) => network.id,
		getLabel: (network: Network) => network.name,
		getDescription: (network: Network, context: NetworkDisplayContext) => {
			if (!network.snmp_credential_id) return 'No SNMP credential';
			const creds = context?.snmpCredentials ?? [];
			const cred = creds.find((c) => c.id === network.snmp_credential_id);
			if (cred) return `SNMP: ${cred.name}`;
			return 'SNMP Enabled';
		},
		getIcon: () => entities.getIconComponent('Network'),
		getIconColor: () => entities.getColorHelper('Network').icon,
		getTags: (network: Network, context: NetworkDisplayContext) => {
			if (!network.snmp_credential_id) return [];
			const creds = context?.snmpCredentials ?? [];
			const cred = creds.find((c) => c.id === network.snmp_credential_id);
			if (cred) {
				return [
					{
						label: cred.name,
						color: entities.getColorHelper('SnmpCredential').color,
						entityRef: entityRef('SnmpCredential', cred.id, cred)
					}
				];
			}
			return [];
		},
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityDisplayComponent } from '../types';
	import type { Network } from '$lib/features/networks/types';

	export let item: Network;
	export let context: NetworkDisplayContext = {};
</script>

<ListSelectItem {item} {context} displayComponent={NetworkDisplay} />
