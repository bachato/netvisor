<script lang="ts">
	import { X } from 'lucide-svelte';
	import { showViewSwitcherHint } from '../queries';
	import { topology_viewSwitcherHint } from '$lib/paraglide/messages';

	function dismiss() {
		showViewSwitcherHint.set(false);
	}
</script>

<div class="card card-static flex items-center gap-3 px-4 py-3">
	<p class="text-secondary flex-1 text-sm">
		{topology_viewSwitcherHint()}
	</p>
	<button class="btn-icon flex-shrink-0 p-1" onclick={dismiss}>
		<X class="h-4 w-4" />
	</button>
</div>
