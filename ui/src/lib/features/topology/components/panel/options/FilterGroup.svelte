<script lang="ts">
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import type { Color } from '$lib/shared/utils/styling';
	import type { IconComponent } from '$lib/shared/utils/types';

	export interface FilterItem {
		value: string;
		label: string;
		color: Color;
		icon?: IconComponent | null;
		isShiny?: boolean;
		tooltip?: string;
	}

	let {
		items,
		selectedValues,
		mode,
		onToggle,
		onHoverStart,
		onHoverEnd,
		disabled = false,
		label,
		nativeTooltip = false
	}: {
		items: FilterItem[];
		selectedValues: string[];
		mode: 'include' | 'exclude';
		onToggle: (value: string) => void;
		onHoverStart?: (value: string, color: Color) => void;
		onHoverEnd?: () => void;
		disabled?: boolean;
		label?: string;
		nativeTooltip?: boolean;
	} = $props();

	function isItemFaded(value: string): boolean {
		const isSelected = selectedValues.includes(value);
		if (mode === 'exclude') {
			// In exclude mode, selected values are hidden (faded)
			return isSelected;
		}
		// In include mode, non-selected values are inactive (faded)
		return !isSelected;
	}
</script>

<div class="space-y-2">
	{#if label}
		<div class="text-tertiary text-xs">{label}</div>
	{/if}
	<div class="flex flex-wrap gap-1.5">
		{#each items as item (item.value)}
			{@const faded = isItemFaded(item.value)}
			<button
				onclick={() => !disabled && onToggle(item.value)}
				onmouseenter={() => onHoverStart?.(item.value, item.color)}
				onmouseleave={() => onHoverEnd?.()}
				{disabled}
				class="transition-opacity {disabled
					? 'cursor-not-allowed opacity-50'
					: faded
						? 'opacity-50 hover:opacity-75'
						: 'opacity-100'}"
			>
				<Tag
					label={item.label}
					color={item.color}
					icon={item.icon}
					isShiny={item.isShiny}
					title={item.tooltip ?? ''}
					{nativeTooltip}
				/>
			</button>
		{/each}
	</div>
</div>
