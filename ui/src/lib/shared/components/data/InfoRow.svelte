<script lang="ts">
	import { onMount } from 'svelte';
	import type { Snippet } from 'svelte';

	let {
		label,
		mono = false,
		children
	}: {
		label: string;
		mono?: boolean;
		children: Snippet;
	} = $props();

	let rowEl: HTMLDivElement;
	let labelEl: HTMLSpanElement;
	let valueEl: HTMLSpanElement;
	let wrapped = $state(false);

	function checkWrap() {
		if (labelEl && valueEl) {
			wrapped = valueEl.offsetTop > labelEl.offsetTop;
		}
	}

	onMount(() => {
		checkWrap();
		const observer = new ResizeObserver(checkWrap);
		observer.observe(rowEl);
		return () => observer.disconnect();
	});
</script>

<div bind:this={rowEl} class="flex flex-wrap items-baseline justify-between gap-x-2 gap-y-0.5">
	<span bind:this={labelEl} class="text-secondary flex-shrink-0 text-sm">{label}:</span>
	<span
		bind:this={valueEl}
		class="min-w-0 text-sm"
		class:font-mono={mono}
		class:text-xs={mono}
		class:wrapped-value={wrapped}
		class:inline-value={!wrapped}
	>
		{@render children()}
	</span>
</div>

<style>
	.inline-value {
		text-align: right;
		color: var(--color-text-primary);
	}

	.wrapped-value {
		flex-basis: 100%;
		text-align: left;
		border-left: 2px solid var(--color-border);
		padding-left: 8px;
		color: var(--color-text-primary);
	}
</style>
