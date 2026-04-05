<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Dependency } from '../types/base';
	import { entities, dependencyTypes } from '$lib/shared/stores/metadata';
	import { useServicesCacheQuery } from '$lib/features/services/queries';
	import { toColor } from '$lib/shared/utils/styling';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import { entityRef } from '$lib/shared/components/data/types';
	import {
		common_color,
		common_delete,
		common_description,
		common_edit,
		common_no,
		common_noTypeSpecified,
		common_services,
		common_tags,
		common_yes,
		dependencies_edgeStyleLabel,
		dependencies_dependencyType,
		dependencies_noServicesInDependency,
		dependencies_withPorts
	} from '$lib/paraglide/messages';

	// Queries
	const servicesQuery = useServicesCacheQuery();

	// Derived data
	let servicesData = $derived(servicesQuery.data ?? []);

	let {
		dependency,
		onEdit,
		onDelete,
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		dependency: Dependency;
		onEdit?: (dependency: Dependency) => void;
		onDelete?: (dependency: Dependency) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	// Get services for this dependency via members
	let dependencyServices = $derived.by(() => {
		if (servicesData.length === 0 || !dependency.members) return [];
		const serviceMap = new Map(servicesData.map((s) => [s.id, s]));
		const members = dependency.members;

		if (members.type === 'Services') {
			return members.service_ids
				.map((id) => serviceMap.get(id))
				.filter((s): s is NonNullable<typeof s> => s !== undefined);
		} else {
			// Bindings variant: derive services from binding IDs
			return (
				members.binding_ids
					.map((bid) => servicesData.find((s) => s.bindings.some((b) => b.id === bid)))
					.filter((s): s is NonNullable<typeof s> => s !== undefined)
					// Deduplicate (a service could have multiple bindings in the chain)
					.filter((s, i, arr) => arr.findIndex((x) => x.id === s.id) === i)
			);
		}
	});

	let dependencyServiceLabels = $derived(
		dependencyServices.map((s) => {
			const def = serviceDefinitions.getItem(s.service_definition);
			return {
				id: s.id,
				label: def ? `${s.name} (${def.name})` : s.name,
				service: s
			};
		})
	);

	// Build card data
	let cardData = $derived({
		title: dependency.name,
		iconColor: dependencyTypes.getColorHelper(dependency.dependency_type).icon,
		Icon: dependencyTypes.getIconComponent(dependency.dependency_type),
		fields: [
			{
				label: common_description(),
				value: dependency.description
			},
			{
				label: dependencies_dependencyType(),
				value: [
					{
						id: 'type',
						label: dependencyTypes.getName(dependency.dependency_type),
						color: dependencyTypes.getColorString(dependency.dependency_type)
					}
				],
				emptyText: common_noTypeSpecified()
			},
			{
				label: common_color(),
				value: [
					{
						id: 'color',
						label: dependency.color.charAt(0).toUpperCase() + dependency.color.slice(1),
						color: dependency.color
					}
				],
				emptyText: common_noTypeSpecified()
			},
			{
				label: dependencies_edgeStyleLabel(),
				value: [
					{
						id: 'type',
						label: dependency.edge_style,
						color: toColor('gray')
					}
				],
				emptyText: common_noTypeSpecified()
			},
			{
				label: dependencies_withPorts(),
				value: dependency.members?.type === 'Bindings' ? common_yes() : common_no()
			},
			{
				label: common_services(),
				value: dependencyServiceLabels.map(({ id, label, service }, i) => ({
					id: id + i,
					label,
					color: entities.getColorString('Service'),
					entityRef: entityRef('Service', service.id, service, { interfaceId: null })
				})),
				emptyText: dependencies_noServicesInDependency()
			},
			{ label: common_tags(), snippet: tagsSnippet }
		],

		actions: [
			...(onDelete
				? [
						{
							label: common_delete(),
							icon: Trash2,
							class: 'btn-icon-danger',
							onClick: () => onDelete(dependency)
						}
					]
				: []),
			...(onEdit ? [{ label: common_edit(), icon: Edit, onClick: () => onEdit(dependency) }] : [])
		]
	});
</script>

{#snippet tagsSnippet()}
	<div class="flex items-center gap-2">
		<span class="text-secondary text-sm">{common_tags()}:</span>
		<TagPickerInline
			selectedTagIds={dependency.tags}
			entityId={dependency.id}
			entityType="Dependency"
		/>
	</div>
{/snippet}

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
