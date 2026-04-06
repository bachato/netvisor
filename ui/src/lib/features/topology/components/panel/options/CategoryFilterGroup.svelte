<script lang="ts">
	import type { Color } from '$lib/shared/utils/styling';
	import { hoveredServiceCategory } from '../../../interactions';
	import FilterGroup from './FilterGroup.svelte';

	let {
		categories,
		hiddenCategories,
		onToggle,
		disabled = false,
		label = undefined
	}: {
		categories: { value: string; label: string; color: Color }[];
		hiddenCategories: string[];
		onToggle: (category: string) => void;
		disabled?: boolean;
		label?: string;
	} = $props();

	function handleHoverStart(value: string, color: Color) {
		hoveredServiceCategory.set({ category: value, color: color as string });
	}

	function handleHoverEnd() {
		hoveredServiceCategory.set(null);
	}
</script>

<FilterGroup
	items={categories}
	selectedValues={hiddenCategories}
	mode="exclude"
	{onToggle}
	onHoverStart={handleHoverStart}
	onHoverEnd={handleHoverEnd}
	{disabled}
	{label}
	nativeTooltip={true}
/>
