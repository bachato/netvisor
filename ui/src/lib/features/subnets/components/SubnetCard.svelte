<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { subnetTypes } from '$lib/shared/stores/metadata';
	import { isContainerSubnet } from '../queries';
	import type { Subnet } from '../types/base';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';

	let {
		subnet,
		onEdit,
		onDelete,
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		subnet: Subnet;
		onEdit?: (subnet: Subnet) => void;
		onDelete?: (subnet: Subnet) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	// Build card data
	let cardData = $derived({
		title: subnet.name,
		subtitle: isContainerSubnet(subnet) ? '' : subnet.cidr,
		iconColor: subnetTypes.getColorHelper(subnet.subnet_type).icon,
		Icon: subnetTypes.getIconComponent(subnet.subnet_type),
		fields: [
			{
				label: 'Description',
				value: subnet.description
			},
			{
				label: 'Subnet Type',
				value: [
					{
						id: 'type',
						label: subnetTypes.getName(subnet.subnet_type),
						color: subnetTypes.getColorString(subnet.subnet_type)
					}
				],
				emptyText: 'No type specified'
			},
			{ label: 'Tags', snippet: tagsSnippet }
		],

		actions: [
			...(onDelete
				? [
						{
							label: 'Delete',
							icon: Trash2,
							class: 'btn-icon-danger',
							onClick: () => onDelete(subnet)
						}
					]
				: []),
			...(onEdit
				? [
						{
							label: 'Edit',
							icon: Edit,
							onClick: () => onEdit(subnet)
						}
					]
				: [])
		]
	});
</script>

{#snippet tagsSnippet()}
	<div class="flex items-center gap-2">
		<span class="text-secondary text-sm">Tags:</span>
		<TagPickerInline selectedTagIds={subnet.tags} entityId={subnet.id} entityType="Subnet" />
	</div>
{/snippet}

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
