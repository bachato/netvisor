<script lang="ts">
	import { Edit, Check } from 'lucide-svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { SimpleOptionDisplay } from '$lib/shared/components/forms/selection/display/SimpleOptionDisplay';
	import FilterGroup from './FilterGroup.svelte';
	import GroupingRuleItem from './GroupingRuleItem.svelte';
	import type { ContainerGraphRule, ElementGraphRule, ElementRule } from '../../../types/grouping';
	import { setElementRuleTitle, makeGraphRule } from '../../../types/grouping';
	import { topologyOptions, updateTopologyOptions, activePerspective } from '../../../queries';
	import type { TopologyPerspective } from '../../../queries';
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
	import _elementRuleTypes from '$lib/data/element-rule-types.json';
	const typedContainerRuleTypes = _containerRuleTypes as RuleTypeMetadata[];
	const typedElementRuleTypes = _elementRuleTypes as RuleTypeMetadata[];
	import {
		topology_containerGrouping,
		topology_elementGrouping,
		topology_addContainerRule,
		topology_addElementRule,
		topology_elementGroupingHelp,
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
		($topologyOptions.request.container_rules as ContainerGraphRule[] | undefined) ?? []
	);

	// Element rules from options
	let elementRules = $derived(
		($topologyOptions.request.element_rules as ElementGraphRule[] | undefined) ?? []
	);

	// Editing state tracked by rule UUID
	let editingElementId = $state<string | null>(null);

	// Metadata lookups
	const containerRuleMeta = Object.fromEntries(typedContainerRuleTypes.map((m) => [m.id, m]));
	const elementRuleMeta = Object.fromEntries(typedElementRuleTypes.map((m) => [m.id, m]));

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
		return filteredContainerRuleTypes
			.filter((m) => m.metadata?.is_user_editable && !containerRules.some((r) => r.rule === m.id))
			.map((m) => ({
				value: m.id,
				label: m.name ?? m.id
			}));
	});

	const containerRuleDisplayComponent = {
		getId: (item: ContainerGraphRule) => item.id,
		getLabel: (item: ContainerGraphRule) => containerRuleMeta[item.rule]?.name ?? item.rule
	};

	const CONTAINER_RULE_PERSPECTIVES: Record<string, TopologyPerspective[]> = {
		BySubnet: ['L3Logical'],
		ByVirtualizingService: ['L3Logical', 'Infrastructure']
	};

	const ELEMENT_RULE_PERSPECTIVES: Record<string, TopologyPerspective[]> = {
		ByServiceCategory: ['L3Logical', 'Application'],
		ByTag: ['L2Physical', 'L3Logical', 'Infrastructure', 'Application']
	};

	let currentPerspective = $derived($activePerspective);

	let filteredContainerRuleTypes = $derived(
		typedContainerRuleTypes.filter((m) => {
			const perspectives = CONTAINER_RULE_PERSPECTIVES[m.id];
			return !perspectives || perspectives.includes(currentPerspective);
		})
	);

	let filteredElementRuleTypes = $derived(
		typedElementRuleTypes.filter((m) => {
			const perspectives = ELEMENT_RULE_PERSPECTIVES[m.id];
			return !perspectives || perspectives.includes(currentPerspective);
		})
	);

	function updateContainerRules(newRules: ContainerGraphRule[]) {
		updateTopologyOptions((opts) => ({
			...opts,
			request: { ...opts.request, container_rules: newRules }
		}));
	}

	function handleContainerAdd(optionId: string) {
		updateContainerRules([
			...containerRules,
			makeGraphRule(optionId as ContainerGraphRule['rule'])
		]);
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

	function isContainerRuleEditable(rule: ContainerGraphRule): boolean {
		return containerRuleMeta[rule.rule]?.metadata?.is_user_editable ?? true;
	}

	// --- Element Rules ---

	let elementAddOptions = $derived(
		filteredElementRuleTypes.map((m) => ({
			value: m.id,
			label: m.name ?? m.id
		}))
	);

	const elementRuleDisplayComponent = {
		getId: (item: ElementGraphRule) => item.id,
		getLabel: (item: ElementGraphRule) => {
			if ('ByServiceCategory' in item.rule) return 'ByServiceCategory';
			return 'ByTag';
		}
	};

	function getElementRuleLabel(item: ElementGraphRule): string {
		const rule = item.rule;
		const title =
			'ByServiceCategory' in rule
				? rule.ByServiceCategory.title
				: 'ByTag' in rule
					? rule.ByTag.title
					: null;
		const typeName =
			elementRuleMeta['ByServiceCategory' in rule ? 'ByServiceCategory' : 'ByTag']?.name ?? '';
		return title ?? typeName;
	}

	function updateElementRules(newRules: ElementGraphRule[]) {
		updateTopologyOptions((opts) => ({
			...opts,
			request: { ...opts.request, element_rules: newRules }
		}));
	}

	function handleElementAdd(optionId: string) {
		let newRule: ElementRule;
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
		const graphRule = makeGraphRule(newRule);
		updateElementRules([...elementRules, graphRule]);
		editingElementId = graphRule.id;
	}

	function handleElementRemove(index: number) {
		const removedId = elementRules[index]?.id;
		updateElementRules(elementRules.filter((_, i) => i !== index));
		if (editingElementId === removedId) editingElementId = null;
	}

	function handleElementMoveUp(fromIndex: number) {
		if (fromIndex <= 0) return;
		const newRules = [...elementRules];
		[newRules[fromIndex - 1], newRules[fromIndex]] = [newRules[fromIndex], newRules[fromIndex - 1]];
		updateElementRules(newRules);
	}

	function handleElementMoveDown(fromIndex: number) {
		if (fromIndex >= elementRules.length - 1) return;
		const newRules = [...elementRules];
		[newRules[fromIndex], newRules[fromIndex + 1]] = [newRules[fromIndex + 1], newRules[fromIndex]];
		updateElementRules(newRules);
	}

	function handleElementEdit(_item: ElementGraphRule, index: number) {
		const ruleId = elementRules[index]?.id;
		const wasEditing = editingElementId === ruleId;
		editingElementId = wasEditing ? null : ruleId;

		// Closing editor: re-apply current rules to ensure rebuild fires
		if (wasEditing) {
			updateElementRules([...elementRules]);
		}
	}

	function isElementEditing(item: ElementGraphRule): boolean {
		return item.id === editingElementId;
	}

	function getElementEditIcon(item: ElementGraphRule) {
		return isElementEditing(item) ? Check : Edit;
	}

	function getElementEditButtonClass(item: ElementGraphRule): string {
		return isElementEditing(item) ? 'btn-icon-success' : 'btn-icon';
	}

	function isElementItemEditing(item: ElementGraphRule): boolean {
		return isElementEditing(item);
	}

	function handleElementTitleChange(index: number, title: string | null) {
		const newRules = [...elementRules];
		newRules[index] = {
			...newRules[index],
			rule: setElementRuleTitle(newRules[index].rule, title)
		};
		updateElementRules(newRules);
	}

	function handleTagToggle(index: number, tagId: string) {
		const item = elementRules[index];
		if ('ByTag' in item.rule) {
			const current = item.rule.ByTag.tag_ids;
			const idx = current.indexOf(tagId);
			const newTagIds = idx === -1 ? [...current, tagId] : current.filter((id) => id !== tagId);
			const newRules = [...elementRules];
			newRules[index] = {
				...item,
				rule: { ByTag: { ...item.rule.ByTag, tag_ids: newTagIds } }
			};
			updateElementRules(newRules);
		}
	}

	function toggleCategory(index: number, category: ServiceCategory) {
		const item = elementRules[index];
		if ('ByServiceCategory' in item.rule) {
			const current = item.rule.ByServiceCategory.categories;
			const idx = current.indexOf(category);
			const newCategories: ServiceCategory[] =
				idx === -1 ? [...current, category] : current.filter((c) => c !== category);
			const newRules = [...elementRules];
			newRules[index] = {
				...item,
				rule: { ByServiceCategory: { ...item.rule.ByServiceCategory, categories: newCategories } }
			};
			updateElementRules(newRules);
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
				label={containerRuleMeta[item.rule]?.name ?? item.rule}
				locked={!isContainerRuleEditable(item)}
			/>
		{/snippet}
	</ListManager>
</div>

<!-- Element grouping section -->
<ListManager
	label={topology_elementGrouping()}
	helpText={topology_elementGroupingHelp()}
	placeholder={topology_addElementRule()}
	items={elementRules}
	options={elementAddOptions}
	optionDisplayComponent={SimpleOptionDisplay}
	itemDisplayComponent={elementRuleDisplayComponent}
	allowReorder={true}
	allowDuplicates={true}
	allowItemEdit={() => true}
	editIcon={getElementEditIcon}
	editButtonClass={getElementEditButtonClass}
	isItemEditing={isElementItemEditing}
	onAdd={handleElementAdd}
	onRemove={handleElementRemove}
	onMoveUp={handleElementMoveUp}
	onMoveDown={handleElementMoveDown}
	onEdit={handleElementEdit}
>
	{#snippet itemSnippet({ item })}
		<GroupingRuleItem label={getElementRuleLabel(item)} />
	{/snippet}
	{#snippet itemExpandedSnippet({ item, index })}
		{#if isElementEditing(item)}
			{@const rule = item.rule}
			<div class="mt-2 w-full space-y-3 border-t border-gray-200 pt-2 dark:border-gray-700">
				<!-- Title input -->
				<input
					type="text"
					class="input-field w-full py-1 text-sm"
					placeholder={topology_groupRuleTitlePlaceholder()}
					value={('ByServiceCategory' in rule
						? rule.ByServiceCategory.title
						: 'ByTag' in rule
							? rule.ByTag.title
							: null) ?? ''}
					oninput={(e) =>
						handleElementTitleChange(index, (e.currentTarget as HTMLInputElement).value || null)}
					disabled={!editState.isEditable}
				/>

				<!-- Selection pills -->
				{#if 'ByServiceCategory' in rule}
					<FilterGroup
						items={serviceCategoriesWithColors}
						selectedValues={rule.ByServiceCategory.categories}
						mode="include"
						onToggle={(cat) => toggleCategory(index, cat as ServiceCategory)}
						disabled={!editState.isEditable}
					/>
				{:else if 'ByTag' in rule}
					<FilterGroup
						items={allTagsWithColors}
						selectedValues={rule.ByTag.tag_ids}
						mode="include"
						onToggle={(tagId) => handleTagToggle(index, tagId)}
						disabled={!editState.isEditable}
					/>
				{/if}
			</div>
		{/if}
	{/snippet}
</ListManager>
