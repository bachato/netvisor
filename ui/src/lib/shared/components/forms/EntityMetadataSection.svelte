<script lang="ts">
	import CodeContainer from '../data/CodeContainer.svelte';

	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	export let entities: (any | null)[] = [null];
</script>

{#if entities.length > 0}
	<CodeContainer expandable={true} expanded={false} code={JSON.stringify(entities, null, 2)} />
{/if}
