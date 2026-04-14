<script lang="ts">
	import { X } from 'lucide-svelte';
	import { showViewSwitcherHint } from '../queries';
	import { topology_viewSwitcherHint } from '$lib/paraglide/messages';
	import { tick } from 'svelte';

	let anchor: HTMLDivElement | undefined = $state();
	let top = $state(0);
	let left = $state(0);
	let visible = $state(false);

	$effect(() => {
		if (anchor) {
			// Wait for layout to settle
			tick().then(() => {
				requestAnimationFrame(() => {
					if (!anchor) return;
					const rect = anchor.getBoundingClientRect();
					top = rect.bottom + 8;
					left = rect.left;
					visible = true;
				});
			});
		}
	});

	function dismiss() {
		showViewSwitcherHint.set(false);
	}
</script>

<!-- Invisible anchor to measure position -->
<div bind:this={anchor} class="pointer-events-none absolute inset-0"></div>

<!-- Fixed-positioned callout that escapes overflow -->
{#if visible}
	<div class="fixed z-50 w-64" style="top: {top}px; left: {left}px;">
		<div class="card card-static relative p-3 shadow-lg">
			<div
				class="border-primary/20 absolute -top-2 left-6 h-0 w-0 border-x-8 border-b-8 border-x-transparent"
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
