<script lang="ts" module>
	export const SnmpCredentialDisplay: EntityDisplayComponent<SnmpCredential, object> = {
		getId: (credential) => credential.id,
		getLabel: (credential) => credential.name,
		getDescription: (credential) => `SNMP ${credential.version}`,
		getIcon: () => entities.getIconComponent('SnmpCredential'),
		getIconColor: () => entities.getColorHelper('SnmpCredential').icon,
		getTags: (credential) => [
			{ label: credential.version ?? 'V2c', color: entities.getColorHelper('SnmpCredential').color }
		],
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityDisplayComponent } from '../types';
	import type { SnmpCredential } from '$lib/features/snmp/types/base';
	import { entities } from '$lib/shared/stores/metadata';

	interface Props {
		item: SnmpCredential;
		context?: object;
	}

	let { item, context = {} }: Props = $props();
</script>

<ListSelectItem {item} {context} displayComponent={SnmpCredentialDisplay} />
