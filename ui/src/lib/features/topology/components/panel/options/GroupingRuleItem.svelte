<script lang="ts">
	import type { GroupingRule } from '../../../types/grouping';
	import { getGroupingRuleType, getGroupingRuleTitle } from '../../../types/grouping';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import type { Color } from '$lib/shared/utils/styling';
	import type { Tag as TagType } from '$lib/features/tags/types/base';
	import {
		common_tag,
		common_subnet,
		topology_groupByServiceCategory,
		topology_groupByVirtualizingService,
		topology_groupRuleTitlePlaceholder
	} from '$lib/paraglide/messages';

	let {
		rule,
		allTags = [],
		onTitleChange,
		disabled = false
	}: {
		rule: GroupingRule;
		allTags?: TagType[];
		onTitleChange?: (title: string | null) => void;
		disabled?: boolean;
	} = $props();

	let ruleType = $derived(getGroupingRuleType(rule));
	let title = $derived(getGroupingRuleTitle(rule));

	const typeLabels: Record<string, () => string> = {
		BySubnet: common_subnet,
		ByServiceCategory: topology_groupByServiceCategory,
		ByVirtualizingService: topology_groupByVirtualizingService,
		ByTag: common_tag
	};

	const typeColors: Record<string, Color> = {
		BySubnet: 'Blue',
		ByServiceCategory: 'Purple',
		ByVirtualizingService: 'Teal',
		ByTag: 'Orange'
	};

	let configSummary = $derived.by(() => {
		if ('ByServiceCategory' in rule) {
			return rule.ByServiceCategory.categories.join(', ');
		}
		if ('ByTag' in rule) {
			const tagNames = rule.ByTag.tag_ids
				.map((id) => allTags.find((t) => t.id === id)?.name ?? id)
				.join(', ');
			return tagNames;
		}
		return '';
	});

	function handleTitleInput(e: Event) {
		const value = (e.currentTarget as HTMLInputElement).value;
		onTitleChange?.(value || null);
	}
</script>

<div class="flex flex-col gap-1.5">
	<div class="flex items-center gap-2">
		<Tag label={typeLabels[ruleType]()} color={typeColors[ruleType]} />
		<input
			type="text"
			class="input-field min-w-0 flex-1 py-0.5 text-sm"
			placeholder={topology_groupRuleTitlePlaceholder()}
			value={title ?? ''}
			oninput={handleTitleInput}
			{disabled}
		/>
	</div>
	{#if configSummary}
		<span class="text-tertiary truncate text-xs">{configSummary}</span>
	{/if}
</div>
