<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { SnmpCredential } from '../types/base';
	import { entities } from '$lib/shared/stores/metadata';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { permissions } from '$lib/shared/stores/metadata';
	import {
		common_delete,
		common_edit,
		common_version,
		snmp_versionV2cShort
	} from '$lib/paraglide/messages';

	let {
		credential,
		onEdit = () => {},
		onDelete = () => {},
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		credential: SnmpCredential;
		onEdit?: (credential: SnmpCredential) => void;
		onDelete?: (credential: SnmpCredential) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	let colorHelper = $derived(entities.getColorHelper('SnmpCredential'));

	let canManage = $derived(
		(currentUser && permissions.getMetadata(currentUser.permissions).manage_org_entities) || false
	);

	let cardData = $derived({
		title: credential.name,
		iconColor: colorHelper.icon,
		Icon: entities.getIconComponent('SnmpCredential'),
		fields: [
			{
				label: common_version(),
				value: [
					{
						id: 'version',
						label: credential.version ?? snmp_versionV2cShort(),
						color: colorHelper.color
					}
				]
			}
		],
		actions: [
			...(canManage
				? [
						{
							label: common_delete(),
							icon: Trash2,
							class: 'btn-icon-danger',
							onClick: () => onDelete(credential)
						},
						{
							label: common_edit(),
							icon: Edit,
							onClick: () => onEdit(credential)
						}
					]
				: [])
		]
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} selectable={canManage} />
