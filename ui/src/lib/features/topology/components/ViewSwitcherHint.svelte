<script lang="ts">
	import { X } from 'lucide-svelte';
	import { showViewSwitcherHint } from '../queries';
	import { topology_viewSwitcherHint } from '$lib/paraglide/messages';
	import { onMount } from 'svelte';

	let { anchor }: { anchor: HTMLElement } = $props();

	let portalContainer: HTMLDivElement | null = $state(null);
	let top = $state(0);
	let left = $state(0);
	let ready = $state(false);

	onMount(() => {
		portalContainer = document.createElement('div');
		portalContainer.style.position = 'absolute';
		portalContainer.style.top = '0';
		portalContainer.style.left = '0';
		portalContainer.style.width = '0';
		portalContainer.style.height = '0';
		document.body.appendChild(portalContainer);

		// Delay measurement to ensure anchor is laid out
		setTimeout(() => {
			if (!anchor) return;
			const rect = anchor.getBoundingClientRect();
			top = rect.bottom + 8;
			left = rect.left;
			ready = true;
		}, 100);

		return () => {
			portalContainer?.remove();
		};
	});

	function portal(node: HTMLElement) {
		portalContainer?.appendChild(node);
		return {
			destroy() {
				node.remove();
			}
		};
	}

	function dismiss() {
		showViewSwitcherHint.set(false);
	}
</script>

{#if ready && portalContainer}
	<div
		use:portal
		class="fixed z-[9999] w-64"
		style="top: {top}px; left: {left}px;"
	>
		<div class="card card-static relative p-3 shadow-lg">
			<!-- Arrow pointing up -->
			<div
				class="absolute -top-2 left-6 h-0 w-0 border-x-8 border-b-8 border-x-transparent"
				style="border-bottom-color: var(--color-bg-surface);"
			></div>
			<div class="flex items-start gap-2">
				<p class="text-secondary flex-1 text-xs">
					{topology_viewSwitcherHint()}
				</p>
				<button class="btn-icon flex-shrink-0 p-0.5" onclick={dismiss}>
					<X class="h-3.5 w-3.5" />
				</button>
			</div>
		</div>
	</div>
{/if}
