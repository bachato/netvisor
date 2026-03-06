<script lang="ts">
	import { Download } from 'lucide-svelte';

	let { onclick }: { onclick: () => void } = $props();
</script>

<button class="btn-secondary flex items-center gap-1" {onclick}>
	<Download class="my-1 h-5 w-5" />
</button>
