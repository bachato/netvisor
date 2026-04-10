<script lang="ts">
	import type { Snippet } from 'svelte';

	let {
		onclick,
		title,
		icon,
		label,
		active = false,
		collapsed = false,
		disabled = false
	}: {
		onclick: () => void;
		title: string;
		icon: Snippet;
		label: string;
		active?: boolean;
		collapsed?: boolean;
		disabled?: boolean;
	} = $props();

	let hovered = $state(false);
	let showLabel = $derived(!collapsed || hovered);
</script>

<button
	class="flex items-center overflow-hidden rounded text-xs font-medium !shadow-lg transition-all duration-300 ease-in-out
		{active
		? '!border !border-blue-400 !bg-blue-50 !text-blue-700 hover:!bg-blue-100 dark:!border-blue-500 dark:!bg-blue-900/40 dark:!text-blue-300 dark:hover:!bg-blue-800/50'
		: '!border !border-gray-300 !bg-gray-50 !text-gray-700 hover:!bg-gray-100 dark:!border-gray-600 dark:!bg-gray-700 dark:!text-gray-100 dark:hover:!bg-gray-600'}"
	style="padding: 6px {showLabel ? '8px' : '6px'} 6px 6px; gap: {showLabel ? '6px' : '0px'}; {disabled ? 'opacity: 0.4; cursor: not-allowed; pointer-events: auto;' : ''}"
	onclick={disabled ? undefined : onclick}
	{disabled}
	{title}
	onpointerenter={() => (hovered = true)}
	onpointerleave={() => (hovered = false)}
>
	<span class="flex h-4 w-4 shrink-0 items-center justify-center">
		{@render icon()}
	</span>
	<span
		class="overflow-hidden whitespace-nowrap transition-all duration-300 ease-in-out"
		style="max-width: {showLabel ? '150px' : '0px'}; opacity: {showLabel ? 1 : 0};"
	>
		{label}
	</span>
</button>
