<script lang="ts">
	import { X } from 'lucide-svelte';
	import { showViewSwitcherHint } from '../queries';
	import { topology_viewSwitcherHint } from '$lib/paraglide/messages';

	function dismiss() {
		showViewSwitcherHint.set(false);
	}
</script>

<div class="absolute left-0 top-full z-20 mt-2 w-64">
	<div class="card card-static relative p-3 shadow-lg">
		<!-- Arrow pointing up -->
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
