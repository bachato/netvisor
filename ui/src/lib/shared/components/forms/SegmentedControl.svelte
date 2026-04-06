<script lang="ts">
	import type { IconComponent } from '$lib/shared/utils/types';
	import { tooltip } from '$lib/shared/actions/tooltip';

	interface Option {
		value: string;
		label: string;
		icon?: IconComponent;
		tooltip?: string;
	}

	let {
		options,
		selected,
		onchange,
		size = 'sm',
		iconSize: iconSizeProp,
		disabled = false,
		fullWidth = false
	}: {
		options: Option[];
		selected: string;
		onchange: (value: string) => void;
		size?: 'sm' | 'md';
		iconSize?: 'sm' | 'md' | 'lg';
		disabled?: boolean;
		fullWidth?: boolean;
	} = $props();

	let sizeClasses = $derived(size === 'sm' ? 'px-2 py-1 text-xs' : 'px-3 py-1.5 text-sm');

	const iconSizeMap = { sm: 'h-3.5 w-3.5', md: 'h-4 w-4', lg: 'h-5 w-5' };
	let iconSizeClass = $derived(
		iconSizeProp ? iconSizeMap[iconSizeProp] : size === 'sm' ? 'h-3.5 w-3.5' : 'h-4 w-4'
	);
</script>

<div
	class="rounded-md border border-gray-600"
	class:inline-flex={!fullWidth}
	class:flex={fullWidth}
	class:opacity-50={disabled}
	class:cursor-not-allowed={disabled}
>
	{#each options as option (option.value)}
		<button
			type="button"
			{disabled}
			use:tooltip
			data-tooltip={option.tooltip || null}
			class="{sizeClasses} flex items-center justify-center gap-1 transition-colors {selected ===
			option.value
				? 'bg-blue-600 text-white'
				: 'text-secondary hover:text-primary'}"
			class:flex-1={fullWidth}
			onclick={() => {
				if (!disabled) onchange(option.value);
			}}
		>
			{#if option.icon}
				{@const Icon = option.icon}
				<Icon class={iconSizeClass} />
			{/if}
			{#if option.label}
				{option.label}
			{/if}
		</button>
	{/each}
</div>
