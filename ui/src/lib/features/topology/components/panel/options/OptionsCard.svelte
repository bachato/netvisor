<script lang="ts">
	import type { Snippet } from 'svelte';
	import { browser } from '$app/environment';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import { common_options } from '$lib/paraglide/messages';

	const STORAGE_KEY = 'scanopy_topology_inspector_options_expanded';

	function loadFromStorage(): boolean {
		if (!browser) return false;
		try {
			const stored = localStorage.getItem(STORAGE_KEY);
			return stored ? JSON.parse(stored) : false;
		} catch {
			return false;
		}
	}

	function saveToStorage(value: boolean): void {
		if (!browser) return;
		try {
			localStorage.setItem(STORAGE_KEY, JSON.stringify(value));
		} catch {
			// ignore storage errors
		}
	}

	let { children }: { children: Snippet } = $props();
	let expanded = $state(loadFromStorage());

	function toggle() {
		expanded = !expanded;
		saveToStorage(expanded);
	}
</script>

<div class="card card-static px-0 py-2">
	<button
		onclick={toggle}
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
