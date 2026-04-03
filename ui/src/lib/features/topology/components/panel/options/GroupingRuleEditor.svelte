<script lang="ts">
	import { Edit, Check } from 'lucide-svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { SimpleOptionDisplay } from '$lib/shared/components/forms/selection/display/SimpleOptionDisplay';
	import FilterGroup from './FilterGroup.svelte';
	import GroupingRuleItem from './GroupingRuleItem.svelte';
	import type { ContainerRule, LeafRule } from '../../../types/grouping';
	import { setLeafRuleTitle } from '../../../types/grouping';
	import { topologyOptions } from '../../../queries';
	import { getTopologyEditState } from '../../../state';
	import { useTopologiesQuery, selectedTopologyId, autoRebuild } from '../../../queries';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { components } from '$lib/api/schema';
	type ServiceCategory = components['schemas']['ServiceCategory'];
	import { useTagsQuery } from '$lib/features/tags/queries';
	import type { Color } from '$lib/shared/utils/styling';
	import containerRuleTypes from '$lib/data/container-rule-types.json';
	import leafRuleTypes from '$lib/data/leaf-rule-types.json';
	import {
		topology_containerGrouping,
		topology_leafGrouping,
		topology_addContainerRule,
		topology_addLeafRule,
		topology_leafGroupingHelp,
		topology_groupRuleTitlePlaceholder
	} from '$lib/paraglide/messages';

	// Topology for edit state
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(topologiesData.find((t) => t.id === $selectedTopologyId));
	let editState = $derived(getTopologyEditState(topology, $autoRebuild, false));

	// Tags query
	const tagsQuery = useTagsQuery();
	let allTags = $derived(tagsQuery.data ?? []);

	// Container rules from options
	let containerRules = $derived(
		($topologyOptions.request.container_rules as ContainerRule[] | undefined) ?? []
	);

	// Leaf rules from options
	let leafRules = $derived(($topologyOptions.request.leaf_rules as LeafRule[] | undefined) ?? []);

	// Stable ID tracking for leaf rules
	let nextLeafId = $state(0);
	let leafStableIds = $state<number[]>([]);
	let leafIdsInitialized = $state(false);

	// Sync stable IDs when leaf rules load for the first time
	$effect(() => {
		if (!leafIdsInitialized && leafRules.length > 0) {
			leafStableIds = leafRules.map((_, i) => i);
			nextLeafId = leafRules.length;
			leafIdsInitialized = true;
		}
	});

	// Editing state tracked by stable ID
	let editingLeafId = $state<number | null>(null);

	// Metadata lookups
	const containerRuleMeta = Object.fromEntries(containerRuleTypes.map((m) => [m.id, m]));
	const leafRuleMeta = Object.fromEntries(leafRuleTypes.map((m) => [m.id, m]));

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

	// All tags as toggleable pills
	let allTagsWithColors = $derived(
		allTags.map((t) => ({
			value: t.id,
			label: t.name,
			color: t.color as Color
		}))
	);

	// --- Container Rules ---

	let containerAddOptions = $derived.by(() => {
		return containerRuleTypes
			.filter(
				(m) => m.metadata?.is_user_editable && !containerRules.includes(m.id as ContainerRule)
			)
			.map((m) => ({
				value: m.id,
				label: m.name ?? m.id
			}));
	});

	const containerRuleDisplayComponent = {
		getId: (item: ContainerRule) => item,
		getLabel: (item: ContainerRule) => containerRuleMeta[item]?.name ?? item
	};

	function updateContainerRules(newRules: ContainerRule[]) {
		topologyOptions.update((opts) => {
			(opts.request as Record<string, unknown>).container_rules = newRules;
			return opts;
		});
	}

	function handleContainerAdd(optionId: string) {
		updateContainerRules([...containerRules, optionId as ContainerRule]);
	}

	function handleContainerRemove(index: number) {
		updateContainerRules(containerRules.filter((_, i) => i !== index));
	}

	function handleContainerMoveUp(fromIndex: number) {
		if (fromIndex <= 0) return;
		const newRules = [...containerRules];
		[newRules[fromIndex - 1], newRules[fromIndex]] = [newRules[fromIndex], newRules[fromIndex - 1]];
		updateContainerRules(newRules);
	}

	function handleContainerMoveDown(fromIndex: number) {
		if (fromIndex >= containerRules.length - 1) return;
		const newRules = [...containerRules];
		[newRules[fromIndex], newRules[fromIndex + 1]] = [newRules[fromIndex + 1], newRules[fromIndex]];
		updateContainerRules(newRules);
	}

	function isContainerRuleEditable(rule: ContainerRule): boolean {
		return containerRuleMeta[rule]?.metadata?.is_user_editable ?? true;
	}

	// --- Leaf Rules ---

	let leafAddOptions = $derived(
		leafRuleTypes.map((m) => ({
			value: m.id,
			label: m.name ?? m.id
		}))
	);

	const leafRuleDisplayComponent = {
		getId: (_item: LeafRule, index?: number) => {
			const idx = index ?? 0;
			return `leaf-${leafStableIds[idx] ?? idx}`;
		},
		getLabel: (item: LeafRule) => {
			if ('ByServiceCategory' in item) return 'ByServiceCategory';
			return 'ByTag';
		}
	};

	function getLeafRuleLabel(item: LeafRule): string {
		const title =
			'ByServiceCategory' in item
				? item.ByServiceCategory.title
				: 'ByTag' in item
					? item.ByTag.title
					: null;
		const typeName =
			leafRuleMeta['ByServiceCategory' in item ? 'ByServiceCategory' : 'ByTag']?.name ?? '';
		return title ?? typeName;
	}

	function updateLeafRules(newRules: LeafRule[]) {
		topologyOptions.update((opts) => {
			(opts.request as Record<string, unknown>).leaf_rules = newRules;
			return opts;
		});
	}

	function handleLeafAdd(optionId: string) {
		let newRule: LeafRule;
		switch (optionId) {
			case 'ByServiceCategory':
				newRule = { ByServiceCategory: { categories: [], title: null } };
				break;
			case 'ByTag':
				newRule = { ByTag: { tag_ids: [], title: null } };
				break;
			default:
				return;
		}
		const newId = nextLeafId++;
		leafStableIds = [...leafStableIds, newId];
		updateLeafRules([...leafRules, newRule]);
		editingLeafId = newId;
	}

	function handleLeafRemove(index: number) {
		const removedId = leafStableIds[index];
		leafStableIds = leafStableIds.filter((_, i) => i !== index);
		updateLeafRules(leafRules.filter((_, i) => i !== index));
		if (editingLeafId === removedId) editingLeafId = null;
	}

	function handleLeafMoveUp(fromIndex: number) {
		if (fromIndex <= 0) return;
		const newRules = [...leafRules];
		[newRules[fromIndex - 1], newRules[fromIndex]] = [newRules[fromIndex], newRules[fromIndex - 1]];
		const newIds = [...leafStableIds];
		[newIds[fromIndex - 1], newIds[fromIndex]] = [newIds[fromIndex], newIds[fromIndex - 1]];
		leafStableIds = newIds;
		updateLeafRules(newRules);
	}

	function handleLeafMoveDown(fromIndex: number) {
		if (fromIndex >= leafRules.length - 1) return;
		const newRules = [...leafRules];
		[newRules[fromIndex], newRules[fromIndex + 1]] = [newRules[fromIndex + 1], newRules[fromIndex]];
		const newIds = [...leafStableIds];
		[newIds[fromIndex], newIds[fromIndex + 1]] = [newIds[fromIndex + 1], newIds[fromIndex]];
		leafStableIds = newIds;
		updateLeafRules(newRules);
	}

	function handleLeafEdit(_item: LeafRule, index: number) {
		const stableId = leafStableIds[index];
		editingLeafId = editingLeafId === stableId ? null : stableId;
	}

	function isLeafEditing(index: number): boolean {
		return leafStableIds[index] === editingLeafId;
	}

	function getLeafEditIcon(_item: LeafRule, index: number) {
		return isLeafEditing(index) ? Check : Edit;
	}

	function handleLeafTitleChange(index: number, title: string | null) {
		const newRules = [...leafRules];
		newRules[index] = setLeafRuleTitle(newRules[index], title);
		updateLeafRules(newRules);
	}

	function handleTagToggle(index: number, tagId: string) {
		const rule = leafRules[index];
		if ('ByTag' in rule) {
			const current = rule.ByTag.tag_ids;
			const idx = current.indexOf(tagId);
			const newTagIds = idx === -1 ? [...current, tagId] : current.filter((id) => id !== tagId);
			const newRules = [...leafRules];
			newRules[index] = { ByTag: { ...rule.ByTag, tag_ids: newTagIds } };
			updateLeafRules(newRules);
		}
	}

	function toggleCategory(index: number, category: ServiceCategory) {
		const rule = leafRules[index];
		if ('ByServiceCategory' in rule) {
			const current = rule.ByServiceCategory.categories;
			const idx = current.indexOf(category);
			const newCategories: ServiceCategory[] =
				idx === -1 ? [...current, category] : current.filter((c) => c !== category);
			const newRules = [...leafRules];
			newRules[index] = {
				ByServiceCategory: { ...rule.ByServiceCategory, categories: newCategories }
			};
			updateLeafRules(newRules);
		}
	}
</script>

<!-- Container grouping section -->
<div class="mb-4">
	<ListManager
		label={topology_containerGrouping()}
		placeholder={topology_addContainerRule()}
		items={containerRules}
		options={containerAddOptions}
		optionDisplayComponent={SimpleOptionDisplay}
		itemDisplayComponent={containerRuleDisplayComponent}
		allowReorder={true}
		allowDuplicates={false}
		allowItemEdit={() => false}
		allowItemRemove={isContainerRuleEditable}
		allowItemReorder={isContainerRuleEditable}
		onAdd={handleContainerAdd}
		onRemove={handleContainerRemove}
		onMoveUp={handleContainerMoveUp}
		onMoveDown={handleContainerMoveDown}
	>
		{#snippet itemSnippet({ item })}
			<GroupingRuleItem
				label={containerRuleMeta[item]?.name ?? item}
				locked={!isContainerRuleEditable(item)}
			/>
		{/snippet}
	</ListManager>
</div>

<!-- Leaf grouping section -->
<ListManager
	label={topology_leafGrouping()}
	helpText={topology_leafGroupingHelp()}
	placeholder={topology_addLeafRule()}
	items={leafRules}
	options={leafAddOptions}
	optionDisplayComponent={SimpleOptionDisplay}
	itemDisplayComponent={leafRuleDisplayComponent}
	allowReorder={true}
	allowDuplicates={true}
	allowItemEdit={() => true}
	editIcon={getLeafEditIcon}
	onAdd={handleLeafAdd}
	onRemove={handleLeafRemove}
	onMoveUp={handleLeafMoveUp}
	onMoveDown={handleLeafMoveDown}
	onEdit={handleLeafEdit}
>
	{#snippet itemSnippet({ item })}
		<GroupingRuleItem label={getLeafRuleLabel(item)} />
	{/snippet}
	{#snippet itemExpandedSnippet({ item, index })}
		{#if isLeafEditing(index)}
			<div class="mt-2 w-full space-y-3 border-t border-gray-200 pt-2 dark:border-gray-700">
				<!-- Title input -->
				<input
					type="text"
					class="input-field w-full py-1 text-sm"
					placeholder={topology_groupRuleTitlePlaceholder()}
					value={('ByServiceCategory' in item
						? item.ByServiceCategory.title
						: 'ByTag' in item
							? item.ByTag.title
							: null) ?? ''}
					oninput={(e) =>
						handleLeafTitleChange(index, (e.currentTarget as HTMLInputElement).value || null)}
					disabled={!editState.isEditable}
				/>

				<!-- Selection pills -->
				{#if 'ByServiceCategory' in item}
					<FilterGroup
						items={serviceCategoriesWithColors}
						selectedValues={item.ByServiceCategory.categories}
						mode="include"
						onToggle={(cat) => toggleCategory(index, cat as ServiceCategory)}
						disabled={!editState.isEditable}
					/>
				{:else if 'ByTag' in item}
					<FilterGroup
						items={allTagsWithColors}
						selectedValues={item.ByTag.tag_ids}
						mode="include"
						onToggle={(tagId) => handleTagToggle(index, tagId)}
						disabled={!editState.isEditable}
					/>
				{/if}
			</div>
		{/if}
	{/snippet}
</ListManager>
