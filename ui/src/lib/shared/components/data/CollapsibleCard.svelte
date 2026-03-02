<script lang="ts">
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import type { Snippet } from 'svelte';

	interface Props {
		title: string;
		expanded?: boolean;
		description?: string;
		children: Snippet;
	}

	let { title, expanded = $bindable(true), description, children }: Props = $props();

	function toggle() {
		expanded = !expanded;
	}
</script>

<div class="card card-static">
	<button
		type="button"
		class="flex w-full items-center justify-between text-left focus:outline-none"
		onclick={toggle}
		aria-expanded={expanded}
	>
		<div>
			<h3 class="text-primary text-sm font-semibold">{title}</h3>
			{#if description}
				<p class="text-tertiary mt-0.5 text-xs">{description}</p>
			{/if}
		</div>
		{#if expanded}
			<ChevronDown class="text-secondary h-4 w-4 flex-shrink-0" />
		{:else}
			<ChevronRight class="text-secondary h-4 w-4 flex-shrink-0" />
		{/if}
	</button>

	{#if expanded}
		<div class="mt-3 space-y-3">
			{@render children()}
		</div>
	{/if}
</div>
