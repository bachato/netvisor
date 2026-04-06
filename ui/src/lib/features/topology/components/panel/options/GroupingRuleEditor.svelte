<script lang="ts">
	import { Edit, Check } from 'lucide-svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { SimpleOptionDisplay } from '$lib/shared/components/forms/selection/display/SimpleOptionDisplay';
	import FilterGroup from './FilterGroup.svelte';
	import GroupingRuleItem from './GroupingRuleItem.svelte';
	import type {
		ContainerGraphRule,
		ElementGraphRule,
		ElementRule,
		ContainerRule
	} from '../../../types/grouping';
	import {
		setElementRuleTitle,
		getElementRuleType,
		getElementRuleTitle,
		makeGraphRule,
		getContainerRuleDiscriminant
	} from '../../../types/grouping';
	import {
		topologyOptions,
		updateTopologyOptions,
		activeView,
		sharedElementRules,
		updateSharedElementRules
	} from '../../../queries';
	import { getTopologyEditState } from '../../../state';
	import {
		useTopologiesQuery,
		useRebuildTopologyMutation,
		selectedTopologyId,
		autoRebuild
	} from '../../../queries';
	import { serviceCategories, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { components } from '$lib/api/schema';
	type ServiceCategory = components['schemas']['ServiceCategory'];
	import { useTagsQuery } from '$lib/features/tags/queries';
	import { COLOR_MAP, type Color } from '$lib/shared/utils/styling';
	interface RuleTypeMetadata {
		id: string;
		name: string | null;
		description: string | null;
		category: string | null;
		icon: string | null;
		color: string | null;
		metadata: { is_user_editable: boolean; views?: string[] } | null;
	}
	import _containerRuleTypes from '$lib/data/container-rule-types.json';
	import _elementRuleTypes from '$lib/data/element-rule-types.json';
	const typedContainerRuleTypes = _containerRuleTypes as RuleTypeMetadata[];
	const typedElementRuleTypes = _elementRuleTypes as RuleTypeMetadata[];
	import {
		topology_containerGroupingPerspective,
		topology_elementGrouping,
		topology_addContainerRule,
		topology_addElementRule,
		topology_elementGroupingHelp,
		topology_elementRuleNotApplicable,
		topology_groupRuleTitlePlaceholder
	} from '$lib/paraglide/messages';
	import viewsJson from '$lib/data/views.json';

	// Topology for edit state and rebuild
	const topologiesQuery = useTopologiesQuery();
	const rebuildMutation = useRebuildTopologyMutation();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(topologiesData.find((t) => t.id === $selectedTopologyId));
	let editState = $derived(getTopologyEditState(topology, $autoRebuild, false));

	// Tags query
	const tagsQuery = useTagsQuery();
	let allTags = $derived(tagsQuery.data ?? []);

	// Container rules for the active view (per-view HashMap)
	let containerRules = $derived(
		((
			$topologyOptions.request.container_rules as Record<string, ContainerGraphRule[]> | undefined
		)?.[$activeView] ?? []) as ContainerGraphRule[]
	);

	// Element rules from shared store (committed state, cross-view)
	let committedElementRules = $derived($sharedElementRules);

	// Pending edits buffer: used while an editor is open so individual toggles
	// don't trigger rebuilds. Flushed to the store on checkmark close.
	let pendingElementRules = $state<ElementGraphRule[] | null>(null);

	// Active rules: pending edits if editing, otherwise committed
	let elementRules = $derived(pendingElementRules ?? committedElementRules);

	// Editing state tracked by rule UUID
	let editingElementId = $state<string | null>(null);

	// Metadata lookups
	const containerRuleMeta = Object.fromEntries(typedContainerRuleTypes.map((m) => [m.id, m]));
	const elementRuleMeta = Object.fromEntries(typedElementRuleTypes.map((m) => [m.id, m]));

	// Perspective name lookup for tooltip
	const viewNames = Object.fromEntries(viewsJson.map((p) => [p.id, p.name ?? p.id]));

	/** Whether an element rule applies to the current view */
	function isElementRuleApplicable(item: ElementGraphRule): boolean {
		const ruleId = getElementRuleType(item.rule);
		const meta = elementRuleMeta[ruleId];
		const applicableViews = meta?.metadata?.views;
		return !applicableViews || applicableViews.includes(currentView);
	}

	/** Tooltip for a disabled (non-applicable) element rule */
	function getElementRuleDisabledTooltip(item: ElementGraphRule): string | undefined {
		if (isElementRuleApplicable(item)) return undefined;
		const ruleId = getElementRuleType(item.rule);
		const meta = elementRuleMeta[ruleId];
		const applicableViews = meta?.metadata?.views ?? [];
		const names = applicableViews.map((p: string) => viewNames[p] ?? p);
		return topology_elementRuleNotApplicable({ perspectives: names.join(', ') });
	}

	// Service categories available in topology
	let serviceCategoriesWithColors = $derived.by(() => {
		if (!topology?.services) return [];
		const seen: Record<string, boolean> = {};
		const result: { value: string; label: string; color: Color; tooltip?: string }[] = [];
		for (const service of topology.services) {
			const category = serviceDefinitions.getCategory(service.service_definition);
			if (category && !seen[category]) {
				seen[category] = true;
				const color = serviceDefinitions.getColorHelper(service.service_definition).color;
				result.push({
					value: category,
					label: serviceCategories.getName(category),
					color,
					tooltip: serviceCategories.getDescription(category) || undefined
				});
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
			.filter(
				(m) =>
					m.metadata?.is_user_editable &&
					!containerRules.some((r) => getContainerRuleDiscriminant(r.rule) === m.id)
			)
			.map((m) => ({
				value: m.id,
				label: m.name ?? m.id,
				description: m.description ?? undefined
			}));
	});

	const containerRuleDisplayComponent = {
		getId: (item: ContainerGraphRule) => item.id,
		getLabel: (item: ContainerGraphRule) =>
			containerRuleMeta[getContainerRuleDiscriminant(item.rule)]?.name ??
			getContainerRuleDiscriminant(item.rule)
	};

	let currentView = $derived($activeView);

	let viewMeta = $derived(viewsJson.find((p) => p.id === currentView));
	let elementGroupingLabel = $derived.by(() => {
		const raw =
			((viewMeta?.metadata as Record<string, unknown>)?.element_label_singular as string) ??
			'element';
		return raw
			.split(' ')
			.map((w) => w.charAt(0).toUpperCase() + w.slice(1))
			.join(' ');
	});

	let filteredContainerRuleTypes = $derived(
		typedContainerRuleTypes.filter((m) => {
			const applicableViews = m.metadata?.views;
			return !applicableViews || applicableViews.includes(currentView);
		})
	);

	let filteredElementRuleTypes = $derived(
		typedElementRuleTypes.filter((m) => {
			const applicableViews = m.metadata?.views;
			return !applicableViews || applicableViews.includes(currentView);
		})
	);

	function updateContainerRules(newRules: ContainerGraphRule[]) {
		updateTopologyOptions((opts) => ({
			...opts,
			request: {
				...opts.request,
				container_rules: {
					...(opts.request.container_rules as Record<string, ContainerGraphRule[]>),
					[$activeView]: newRules
				}
			}
		}));
	}

	function handleContainerAdd(optionId: string) {
		let rule: ContainerRule;
		if (optionId === 'ByApplicationGroup') {
			rule = { ByApplicationGroup: { tag_ids: [] } };
		} else {
			rule = optionId as 'BySubnet' | 'MergeDockerBridges';
		}
		updateContainerRules([...containerRules, makeGraphRule(rule)]);
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
		return (
			containerRuleMeta[getContainerRuleDiscriminant(rule.rule)]?.metadata?.is_user_editable ?? true
		);
	}

	// --- Element Rules ---

	let elementAddOptions = $derived(
		filteredElementRuleTypes.map((m) => ({
			value: m.id,
			label: m.name ?? m.id,
			description: m.description ?? undefined
		}))
	);

	const elementRuleDisplayComponent = {
		getId: (item: ElementGraphRule) => item.id,
		getLabel: (item: ElementGraphRule) => getElementRuleType(item.rule)
	};

	function getElementRuleLabel(item: ElementGraphRule): string {
		const ruleType = getElementRuleType(item.rule);
		const title = getElementRuleTitle(item.rule);
		const typeName = elementRuleMeta[ruleType]?.name ?? '';
		return title ?? typeName;
	}

	function updateElementRules(newRules: ElementGraphRule[]) {
		updateSharedElementRules(() => newRules);
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
			case 'ByVirtualizer':
			case 'ByStack':
				newRule = optionId;
				break;
			default:
				return;
		}
		const graphRule = makeGraphRule(newRule);
		updateElementRules([...elementRules, graphRule]);

		if (typeof newRule === 'string') {
			// Fieldless rule — no edit needed, flush immediately
			if (topology) {
				rebuildMutation.mutate(topology);
			}
		} else {
			editingElementId = graphRule.id;
		}
	}

	function handleElementRemove(index: number) {
		// Always operate on committed state to avoid flushing pending edits
		const rules = committedElementRules;
		const removedId = rules[index]?.id;
		updateElementRules(rules.filter((_, i) => i !== index));
		// Keep pending buffer in sync if active
		if (pendingElementRules) {
			pendingElementRules = pendingElementRules.filter((r) => r.id !== removedId);
		}
		if (editingElementId === removedId) editingElementId = null;
		if (topology) rebuildMutation.mutate(topology);
	}

	function handleElementMoveUp(fromIndex: number) {
		if (fromIndex <= 0) return;
		const newRules = [...elementRules];
		[newRules[fromIndex - 1], newRules[fromIndex]] = [newRules[fromIndex], newRules[fromIndex - 1]];
		updateElementRules(newRules);
		if (topology) rebuildMutation.mutate(topology);
	}

	function handleElementMoveDown(fromIndex: number) {
		if (fromIndex >= elementRules.length - 1) return;
		const newRules = [...elementRules];
		[newRules[fromIndex], newRules[fromIndex + 1]] = [newRules[fromIndex + 1], newRules[fromIndex]];
		updateElementRules(newRules);
		if (topology) rebuildMutation.mutate(topology);
	}

	function handleElementEdit(_item: ElementGraphRule, index: number) {
		const ruleId = elementRules[index]?.id;
		const wasEditing = editingElementId === ruleId;
		editingElementId = wasEditing ? null : ruleId;

		if (wasEditing) {
			// Closing editor: flush pending edits to store and rebuild
			if (pendingElementRules) {
				updateElementRules(pendingElementRules);
				pendingElementRules = null;
			}
			if (topology) {
				rebuildMutation.mutate(topology);
			}
		} else {
			// Opening editor: start buffering edits
			pendingElementRules = [...elementRules];
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

	function bufferElementEdit(updater: (rules: ElementGraphRule[]) => ElementGraphRule[]) {
		pendingElementRules = updater(elementRules);
	}

	function handleElementTitleChange(index: number, title: string | null) {
		bufferElementEdit((rules) => {
			const newRules = [...rules];
			newRules[index] = {
				...newRules[index],
				rule: setElementRuleTitle(newRules[index].rule, title)
			};
			return newRules;
		});
	}

	function handleTagToggle(index: number, tagId: string) {
		const item = elementRules[index];
		if ('ByTag' in item.rule) {
			const current = item.rule.ByTag.tag_ids;
			const idx = current.indexOf(tagId);
			const newTagIds = idx === -1 ? [...current, tagId] : current.filter((id) => id !== tagId);
			bufferElementEdit((rules) => {
				const newRules = [...rules];
				newRules[index] = {
					...item,
					rule: { ByTag: { ...item.rule.ByTag, tag_ids: newTagIds } }
				};
				return newRules;
			});
		}
	}

	function toggleCategory(index: number, category: ServiceCategory) {
		const item = elementRules[index];
		if ('ByServiceCategory' in item.rule) {
			const current = item.rule.ByServiceCategory.categories;
			const idx = current.indexOf(category);
			const newCategories: ServiceCategory[] =
				idx === -1 ? [...current, category] : current.filter((c) => c !== category);
			bufferElementEdit((rules) => {
				const newRules = [...rules];
				newRules[index] = {
					...item,
					rule: {
						ByServiceCategory: { ...item.rule.ByServiceCategory, categories: newCategories }
					}
				};
				return newRules;
			});
		}
	}
</script>

<!-- Container grouping section -->
<div
	class="mb-4 border-l-2 pl-2"
	style="border-left-color: {viewMeta?.color
		? COLOR_MAP[viewMeta.color as Color]?.rgb
		: 'transparent'}"
>
	<ListManager
		label={topology_containerGroupingPerspective({ perspective: viewMeta?.name ?? '' })}
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
				label={containerRuleMeta[getContainerRuleDiscriminant(item.rule)]?.name ??
					getContainerRuleDiscriminant(item.rule)}
				description={containerRuleMeta[getContainerRuleDiscriminant(item.rule)]?.description ??
					undefined}
				locked={!isContainerRuleEditable(item)}
			/>
		{/snippet}
	</ListManager>
</div>

<!-- Element grouping section -->
<ListManager
	label={topology_elementGrouping({ label: elementGroupingLabel })}
	helpText={topology_elementGroupingHelp()}
	placeholder={topology_addElementRule()}
	items={elementRules}
	options={elementAddOptions}
	optionDisplayComponent={SimpleOptionDisplay}
	itemDisplayComponent={elementRuleDisplayComponent}
	allowReorder={true}
	allowDuplicates={true}
	allowItemEdit={(item) => typeof item.rule !== 'string' && isElementRuleApplicable(item)}
	allowItemRemove={isElementRuleApplicable}
	allowItemReorder={isElementRuleApplicable}
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
		<GroupingRuleItem
			label={getElementRuleLabel(item)}
			description={elementRuleMeta[getElementRuleType(item.rule)]?.description ?? undefined}
			disabled={!isElementRuleApplicable(item)}
			disabledTooltip={getElementRuleDisabledTooltip(item)}
		/>
	{/snippet}
	{#snippet itemExpandedSnippet({ item, index })}
		{#if isElementEditing(item) && typeof item.rule !== 'string'}
			{@const rule = item.rule}
			<!-- eslint-disable-next-line svelte/no-static-element-interactions -->
			<div
				onclick={(e) => e.stopPropagation()}
				class="mt-2 w-full space-y-3 border-t border-gray-200 pt-2 dark:border-gray-700"
			>
				<!-- Title input -->
				<input
					type="text"
					class="input-field w-full py-1 text-sm"
					placeholder={topology_groupRuleTitlePlaceholder()}
					value={getElementRuleTitle(item.rule) ?? ''}
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
						nativeTooltip={true}
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
