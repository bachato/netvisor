<script lang="ts">
	import { Lock } from 'lucide-svelte';

	let {
		label,
		locked = false
	}: {
		label: string;
		locked?: boolean;
	} = $props();
</script>

<div class="flex items-center gap-2">
	<span class="text-primary text-sm">{label}</span>
	{#if locked}
		<Lock class="text-tertiary h-3 w-3" />
	{/if}
</div>
