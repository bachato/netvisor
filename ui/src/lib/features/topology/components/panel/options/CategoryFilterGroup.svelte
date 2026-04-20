<script lang="ts">
	import type { Color } from '$lib/shared/utils/styling';
	import type { components } from '$lib/api/schema';
	import { hoveredMetadata } from '../../../interactions';
	import FilterGroup from './FilterGroup.svelte';

	type EntityType = components['schemas']['EntityDiscriminants'];

	let {
		entityType,
		filterType,
		categories,
		hiddenCategories,
		onToggle,
		disabled = false,
		label = undefined
	}: {
		entityType: EntityType;
		filterType: string;
		categories: { value: string; label: string; color: Color }[];
		hiddenCategories: string[];
		onToggle: (category: string) => void;
		disabled?: boolean;
		label?: string;
	} = $props();

	function handleHoverStart(value: string, color: Color) {
		hoveredMetadata.set({ entityType, filterType, valueId: value, color: color as string });
	}

	function handleHoverEnd() {
		hoveredMetadata.set(null);
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
