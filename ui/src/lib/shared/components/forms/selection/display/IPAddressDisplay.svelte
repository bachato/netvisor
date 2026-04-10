<script lang="ts" module>
	import { isContainerSubnet, getSubnetById } from '$lib/features/subnets/queries';
	import type { Subnet } from '$lib/features/subnets/types/base';
	import { entityRef } from '$lib/shared/components/data/types';

	// Context for interface display - needs access to subnets for lookups
	export interface IPAddressDisplayContext {
		subnets: Subnet[];
	}

	export const IPAddressDisplay: EntityDisplayComponent<Interface, IPAddressDisplayContext> = {
		getId: (iface: Interface) => iface.id,
		getLabel: (iface: Interface, context?: IPAddressDisplayContext) => {
			// Align with formatIPAddress(): "name: IP" or just "IP" (or name-only for containers)
			const subnetsData = context?.subnets ?? [];
			const subnet = getSubnetById(subnetsData, iface.subnet_id);
			if (subnet && isContainerSubnet(subnet)) {
				return iface.name ?? iface.ip_address;
			}
			return (iface.name ? iface.name + ': ' : '') + iface.ip_address;
		},
		getDescription: (iface: Interface) => {
			return iface.mac_address ?? 'No MAC';
		},
		getIcon: () => entities.getIconComponent('Interface'),
		getIconColor: () => entities.getColorHelper('Interface').icon,
		getTags: (iface: Interface, context: IPAddressDisplayContext) => {
			const subnetsData = context?.subnets ?? [];
			const subnet = getSubnetById(subnetsData, iface.subnet_id);
			const tags = [];
			if (subnet && !isContainerSubnet(subnet)) {
				tags.push({
					label: subnet.cidr,
					color: entities.getColorHelper('Subnet').color,
					entityRef: entityRef('Subnet', subnet.id, subnet)
				});
			}
			return tags;
		},
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { Interface } from '$lib/features/hosts/types/base';
	import type { EntityDisplayComponent } from '../types';
	import { entities } from '$lib/shared/stores/metadata';

	interface Props {
		item: Interface;
		context?: IPAddressDisplayContext;
	}

	let { item, context = { subnets: [] } }: Props = $props();
</script>

<ListSelectItem {item} {context} displayComponent={IPAddressDisplay} />
