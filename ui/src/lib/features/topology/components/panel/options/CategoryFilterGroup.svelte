<script lang="ts">
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import type { Color } from '$lib/shared/utils/styling';
	import { hoveredServiceCategory } from '../../../interactions';

	let {
		categories,
		hiddenCategories,
		onToggle,
		disabled = false
	}: {
		categories: { value: string; label: string; color: Color }[];
		hiddenCategories: string[];
		onToggle: (category: string) => void;
		disabled?: boolean;
	} = $props();

	function handleMouseEnter(category: string, color: Color) {
		hoveredServiceCategory.set({ category, color });
	}

	function handleMouseLeave() {
		hoveredServiceCategory.set(null);
	}
</script>

<div class="space-y-2">
	<div class="text-secondary text-sm font-medium">Service Categories</div>
	<div class="flex flex-wrap gap-1.5">
		{#each categories as category (category.value)}
			{@const isHidden = hiddenCategories.includes(category.value)}
			<button
				onclick={() => !disabled && onToggle(category.value)}
				onmouseenter={() => handleMouseEnter(category.value, category.color)}
				onmouseleave={handleMouseLeave}
				{disabled}
				class="transition-opacity {disabled
					? 'cursor-not-allowed opacity-50'
					: isHidden
						? 'opacity-50 hover:opacity-75'
						: 'opacity-100'}"
			>
				<Tag label={category.label} color={category.color} />
			</button>
		{/each}
	</div>
</div>
