<script lang="ts">
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
	interface RuleTypeMetadata {
		id: string;
		name: string | null;
		description: string | null;
		category: string | null;
		icon: string | null;
		color: string | null;
		metadata: { is_user_editable: boolean } | null;
	}
	import _containerRuleTypes from '$lib/data/container-rule-types.json';
	import _leafRuleTypes from '$lib/data/leaf-rule-types.json';
	const typedContainerRuleTypes = _containerRuleTypes as RuleTypeMetadata[];
	const typedLeafRuleTypes = _leafRuleTypes as RuleTypeMetadata[];
	import {
		topology_containerGrouping,
		topology_leafGrouping,
		topology_addContainerRule,
		topology_addLeafRule,
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

	// Editing state for leaf rule expansion
	let editingLeafIndex = $state<number | null>(null);

	// Metadata lookups
	const containerRuleMeta = Object.fromEntries(typedContainerRuleTypes.map((m) => [m.id, m]));
	const leafRuleMeta = Object.fromEntries(typedLeafRuleTypes.map((m) => [m.id, m]));

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

	// Options for container add dropdown (only user-editable rules not already present)
	let containerAddOptions = $derived.by(() => {
		return typedContainerRuleTypes
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
		typedLeafRuleTypes.map((m) => ({
			value: m.id,
			label: m.name ?? m.id
		}))
	);

	const leafRuleDisplayComponent = {
		getId: (item: LeafRule) => {
			if ('ByServiceCategory' in item)
				return `ByServiceCategory-${item.ByServiceCategory.categories.join(',')}`;
			if ('ByTag' in item) return `ByTag-${item.ByTag.tag_ids.join(',')}`;
			return 'unknown';
		},
		getLabel: (item: LeafRule) => {
			if ('ByServiceCategory' in item) return 'ByServiceCategory';
			return 'ByTag';
		}
	};

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
		const newRules = [...leafRules, newRule];
		updateLeafRules(newRules);
		editingLeafIndex = newRules.length - 1;
	}

	function handleLeafRemove(index: number) {
		const newRules = leafRules.filter((_, i) => i !== index);
		updateLeafRules(newRules);
		if (editingLeafIndex === index) editingLeafIndex = null;
		else if (editingLeafIndex !== null && editingLeafIndex > index) editingLeafIndex--;
	}

	function handleLeafMoveUp(fromIndex: number) {
		if (fromIndex <= 0) return;
		const newRules = [...leafRules];
		[newRules[fromIndex - 1], newRules[fromIndex]] = [newRules[fromIndex], newRules[fromIndex - 1]];
		updateLeafRules(newRules);
		if (editingLeafIndex === fromIndex) editingLeafIndex = fromIndex - 1;
		else if (editingLeafIndex === fromIndex - 1) editingLeafIndex = fromIndex;
	}

	function handleLeafMoveDown(fromIndex: number) {
		if (fromIndex >= leafRules.length - 1) return;
		const newRules = [...leafRules];
		[newRules[fromIndex], newRules[fromIndex + 1]] = [newRules[fromIndex + 1], newRules[fromIndex]];
		updateLeafRules(newRules);
		if (editingLeafIndex === fromIndex) editingLeafIndex = fromIndex + 1;
		else if (editingLeafIndex === fromIndex + 1) editingLeafIndex = fromIndex;
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

	function handleLeafRuleClick(_item: LeafRule, index: number) {
		editingLeafIndex = editingLeafIndex === index ? null : index;
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
	placeholder={topology_addLeafRule()}
	items={leafRules}
	options={leafAddOptions}
	optionDisplayComponent={SimpleOptionDisplay}
	itemDisplayComponent={leafRuleDisplayComponent}
	allowReorder={true}
	allowDuplicates={true}
	onAdd={handleLeafAdd}
	onRemove={handleLeafRemove}
	onMoveUp={handleLeafMoveUp}
	onMoveDown={handleLeafMoveDown}
	onClick={handleLeafRuleClick}
>
	{#snippet itemSnippet({ item, index })}
		<GroupingRuleItem
			label={('ByServiceCategory' in item
				? item.ByServiceCategory.title
				: 'ByTag' in item
					? item.ByTag.title
					: null) ??
				leafRuleMeta['ByServiceCategory' in item ? 'ByServiceCategory' : 'ByTag']?.name ??
				''}
		/>
		<!-- Expanded edit state -->
		{#if editingLeafIndex === index}
			<div class="mt-2 space-y-3 border-t pt-2">
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
