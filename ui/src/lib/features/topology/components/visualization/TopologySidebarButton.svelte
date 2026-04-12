<script lang="ts">
	import type { Snippet } from 'svelte';
	import KbdKey from '$lib/shared/components/feedback/KbdKey.svelte';

	let {
		onclick,
		title,
		icon,
		label = '',
		shortcut,
		reserveShortcutWidth = false,
		active = false,
		collapsed = false,
		disabled = false,
		grouped
	}: {
		onclick: () => void;
		title: string;
		icon: Snippet;
		label?: string;
		shortcut?: string;
		reserveShortcutWidth?: boolean;
		active?: boolean;
		collapsed?: boolean;
		disabled?: boolean;
		grouped?: 'top' | 'middle' | 'bottom';
	} = $props();

	let hovered = $state(false);
	let hasLabel = $derived(label.length > 0);
	let showLabel = $derived(hasLabel && (!collapsed || hovered));

	let roundingClass = $derived(
		grouped === 'top'
			? 'rounded-t'
			: grouped === 'bottom'
				? 'rounded-b'
				: grouped === 'middle'
					? ''
					: 'rounded'
	);
</script>

<button
	class="flex items-center justify-center overflow-hidden text-xs font-medium transition-all duration-300 ease-in-out {roundingClass}
		{disabled
		? '!cursor-not-allowed !border !border-gray-200 !bg-gray-100 !text-gray-400 !opacity-40 !shadow-none dark:!border-gray-700 dark:!bg-gray-800 dark:!text-gray-600'
		: active
			? '!border !border-blue-400 !bg-blue-50 !text-blue-700 hover:!bg-blue-100 dark:!border-blue-500 dark:!bg-blue-900/40 dark:!text-blue-300 dark:hover:!bg-blue-800/50'
			: '!border !border-gray-300 !bg-gray-50 !text-gray-700 hover:!bg-gray-100 dark:!border-gray-600 dark:!bg-gray-700 dark:!text-gray-100 dark:hover:!bg-gray-600'}
	{grouped ? '' : '!shadow-lg'}"
	style="padding: 6px; gap: 6px; min-width: 60px;"
	onclick={disabled ? undefined : onclick}
	aria-disabled={disabled || undefined}
	{title}
	onpointerenter={() => (hovered = true)}
	onpointerleave={() => (hovered = false)}
>
	<span class="flex h-4 w-4 shrink-0 items-center justify-center">
		{@render icon()}
	</span>
	{#if shortcut}
		<KbdKey key={shortcut} size="sm" class="shrink-0 !shadow-none" />
	{:else if reserveShortcutWidth}
		<span class="inline-flex h-5 min-w-5 shrink-0"></span>
	{/if}
	{#if hasLabel}
		<span
			class="overflow-hidden whitespace-nowrap transition-all duration-300 ease-in-out"
			style="max-width: {showLabel ? '150px' : '0px'}; opacity: {showLabel
				? 1
				: 0}; margin-right: {showLabel ? '2px' : '0px'};"
		>
			{label}
		</span>
	{/if}
</button>
