<script lang="ts">
	import type { Snippet } from 'svelte';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import { common_options } from '$lib/paraglide/messages';

	let { children }: { children: Snippet } = $props();
	let expanded = $state(true);
</script>

<div class="card card-static px-0 py-2">
	<button
		onclick={() => (expanded = !expanded)}
		class="text-secondary hover:text-primary flex w-full items-center gap-2 px-3 py-2 text-sm font-medium"
	>
		{#if expanded}<ChevronDown class="h-4 w-4" />{:else}<ChevronRight class="h-4 w-4" />{/if}
		{common_options()}
	</button>
	{#if expanded}
		<div class="space-y-3 px-3 pb-3">
			{@render children()}
		</div>
	{/if}
</div>
