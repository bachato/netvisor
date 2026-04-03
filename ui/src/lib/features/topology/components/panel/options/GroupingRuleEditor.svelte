<script lang="ts">
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import {
		SimpleOptionDisplay,
		type SimpleOption
	} from '$lib/shared/components/forms/selection/display/SimpleOptionDisplay';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';
	import FilterGroup from './FilterGroup.svelte';
	import GroupingRuleItem from './GroupingRuleItem.svelte';
	import type { GroupingRule } from '../../../types/grouping';
	import { getGroupingRuleType, setGroupingRuleTitle } from '../../../types/grouping';
	import { topologyOptions } from '../../../queries';
	import { getTopologyEditState } from '../../../state';
	import { useTopologiesQuery, selectedTopologyId, autoRebuild } from '../../../queries';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import type { Color } from '$lib/shared/utils/styling';
	import {
		common_tag,
		common_subnet,
		topology_groupBy,
		topology_addGroupingRule,
		topology_groupByServiceCategory,
		topology_groupByVirtualizingService
	} from '$lib/paraglide/messages';

	// Topology for edit state
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(topologiesData.find((t) => t.id === $selectedTopologyId));
	let editState = $derived(getTopologyEditState(topology, $autoRebuild, false));

	// Tags query
	const tagsQuery = useTagsQuery();
	let allTags = $derived(tagsQuery.data ?? []);

	// Current grouping rules from options (with type assertion since not yet in generated types)
	let allRules = $derived(
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		(($topologyOptions.request as any).grouping_rules as GroupingRule[] | undefined) ?? []
	);

	// BySubnet is always first and not editable in the list
	let subnetRule = $derived(allRules.find((r) => 'BySubnet' in r));
	let editableRules = $derived(allRules.filter((r) => !('BySubnet' in r)));

	// Editing state for tag/category pickers
	let editingRuleIndex = $state<number | null>(null);

	// Service categories available in topology
	let serviceCategoriesWithColors = $derived.by(() => {
		if (!topology?.services) return [];
		const seen: Record<string, boolean> = {};
		const result: { value: string; label: string; color: Color }[] = [];
		for (const service of topology.services) {
			const category = serviceDefinitions.getCategory(service.service_definition);
			if (category && !seen[category]) {
				seen[category] = true;
				const color = serviceDefinitions.getColorHelper(service.service_definition).color;
				result.push({ value: category, label: category, color });
			}
		}
		return result.sort((a, b) => a.label.localeCompare(b.label));
	});

	// Options for the add dropdown
	const addOptions: SimpleOption[] = [
		{ value: 'ByServiceCategory', label: topology_groupByServiceCategory() },
		{ value: 'ByVirtualizingService', label: topology_groupByVirtualizingService() },
		{ value: 'ByTag', label: common_tag() }
	];

	// A minimal display component for items (needed by ListManager even with itemSnippet)
	const ruleDisplayComponent = {
		getId: (_item: GroupingRule) => {
			// Use rule type + index as a stable ID
			const type = getGroupingRuleType(_item);
			if ('ByServiceCategory' in _item)
				return `${type}-${_item.ByServiceCategory.categories.join(',')}`;
			if ('ByTag' in _item) return `${type}-${_item.ByTag.tag_ids.join(',')}`;
			return type;
		},
		getLabel: (_item: GroupingRule) => getGroupingRuleType(_item)
	};

	function updateRules(newEditableRules: GroupingRule[]) {
		const subnetRules = subnetRule ? [subnetRule] : [{ BySubnet: { title: null } } as GroupingRule];
		const newRules = [...subnetRules, ...newEditableRules];
		topologyOptions.update((opts) => {
			// eslint-disable-next-line @typescript-eslint/no-explicit-any
			(opts.request as any).grouping_rules = newRules;
			return opts;
		});
	}

	function handleAdd(optionId: string) {
		let newRule: GroupingRule;
		switch (optionId) {
			case 'ByServiceCategory':
				newRule = { ByServiceCategory: { categories: [], title: null } };
				break;
			case 'ByVirtualizingService':
				newRule = { ByVirtualizingService: { title: null } };
				break;
			case 'ByTag':
				newRule = { ByTag: { tag_ids: [], title: null } };
				break;
			default:
				return;
		}
		const newRules = [...editableRules, newRule];
		updateRules(newRules);
		// Open editor for new rule
		editingRuleIndex = newRules.length - 1;
	}

	function handleRemove(index: number) {
		const newRules = editableRules.filter((_, i) => i !== index);
		updateRules(newRules);
		if (editingRuleIndex === index) editingRuleIndex = null;
		else if (editingRuleIndex !== null && editingRuleIndex > index) editingRuleIndex--;
	}

	function handleMoveUp(fromIndex: number) {
		if (fromIndex <= 0) return;
		const newRules = [...editableRules];
		[newRules[fromIndex - 1], newRules[fromIndex]] = [newRules[fromIndex], newRules[fromIndex - 1]];
		updateRules(newRules);
		if (editingRuleIndex === fromIndex) editingRuleIndex = fromIndex - 1;
		else if (editingRuleIndex === fromIndex - 1) editingRuleIndex = fromIndex;
	}

	function handleMoveDown(fromIndex: number) {
		if (fromIndex >= editableRules.length - 1) return;
		const newRules = [...editableRules];
		[newRules[fromIndex], newRules[fromIndex + 1]] = [newRules[fromIndex + 1], newRules[fromIndex]];
		updateRules(newRules);
		if (editingRuleIndex === fromIndex) editingRuleIndex = fromIndex + 1;
		else if (editingRuleIndex === fromIndex + 1) editingRuleIndex = fromIndex;
	}

	function handleTitleChange(index: number, title: string | null) {
		const newRules = [...editableRules];
		newRules[index] = setGroupingRuleTitle(newRules[index], title);
		updateRules(newRules);
	}

	function handleTagChange(index: number, tagIds: string[]) {
		const rule = editableRules[index];
		if ('ByTag' in rule) {
			const newRules = [...editableRules];
			newRules[index] = { ByTag: { ...rule.ByTag, tag_ids: tagIds } };
			updateRules(newRules);
		}
	}

	function toggleCategory(index: number, category: string) {
		const rule = editableRules[index];
		if ('ByServiceCategory' in rule) {
			const current = rule.ByServiceCategory.categories;
			const idx = current.indexOf(category);
			const newCategories =
				idx === -1 ? [...current, category] : current.filter((c) => c !== category);
			const newRules = [...editableRules];
			newRules[index] = {
				ByServiceCategory: { ...rule.ByServiceCategory, categories: newCategories }
			};
			updateRules(newRules);
		}
	}

	function handleRuleClick(_item: GroupingRule, index: number) {
		const type = getGroupingRuleType(_item);
		if (type === 'ByTag' || type === 'ByServiceCategory') {
			editingRuleIndex = editingRuleIndex === index ? null : index;
		}
	}
</script>

<!-- Fixed BySubnet header -->
<div class="mb-2 flex items-center gap-2">
	<span class="bg-primary/10 text-primary rounded px-2 py-0.5 text-xs font-medium">
		{common_subnet()}
	</span>
	<span class="text-tertiary text-xs italic">{topology_groupBy()}</span>
</div>

<ListManager
	label={topology_groupBy()}
	placeholder={topology_addGroupingRule()}
	items={editableRules}
	options={addOptions}
	optionDisplayComponent={SimpleOptionDisplay}
	itemDisplayComponent={ruleDisplayComponent}
	allowReorder={true}
	allowDuplicates={true}
	onAdd={handleAdd}
	onRemove={handleRemove}
	onMoveUp={handleMoveUp}
	onMoveDown={handleMoveDown}
	onClick={handleRuleClick}
>
	{#snippet itemSnippet({ item, index })}
		<GroupingRuleItem
			rule={item}
			{allTags}
			disabled={!editState.isEditable}
			onTitleChange={(title) => handleTitleChange(index, title)}
		/>
		<!-- Inline config editor for ByTag and ByServiceCategory -->
		{#if editingRuleIndex === index}
			<div class="mt-2 border-t pt-2">
				{#if 'ByTag' in item}
					<TagPicker
						selectedTagIds={item.ByTag.tag_ids}
						onChange={(tagIds) => handleTagChange(index, tagIds)}
						disabled={!editState.isEditable}
					/>
				{:else if 'ByServiceCategory' in item}
					<FilterGroup
						items={serviceCategoriesWithColors}
						selectedValues={item.ByServiceCategory.categories}
						mode="include"
						onToggle={(cat) => toggleCategory(index, cat)}
						disabled={!editState.isEditable}
					/>
				{/if}
			</div>
		{/if}
	{/snippet}
</ListManager>
