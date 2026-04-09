<script lang="ts">
	import type { Snippet } from 'svelte';

	let {
		onclick,
		title,
		icon,
		label,
		active = false
	}: {
		onclick: () => void;
		title: string;
		icon: Snippet;
		label: string;
		active?: boolean;
	} = $props();
</script>

<button
	class="flex items-center gap-1.5 rounded px-2 py-1.5 text-xs font-medium !shadow-lg transition-colors
		{active
		? '!border !border-blue-400 !bg-blue-50 !text-blue-700 hover:!bg-blue-100 dark:!border-blue-500 dark:!bg-blue-900/40 dark:!text-blue-300 dark:hover:!bg-blue-800/50'
		: '!border !border-gray-300 !bg-gray-50 !text-gray-700 hover:!bg-gray-100 dark:!border-gray-600 dark:!bg-gray-700 dark:!text-gray-100 dark:hover:!bg-gray-600'}"
	{onclick}
	{title}
>
	<span class="flex h-4 w-4 items-center justify-center">
		{@render icon()}
	</span>
	{label}
</button>
