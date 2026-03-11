<script lang="ts">
	import KbdKey from '$lib/shared/components/feedback/KbdKey.svelte';
	import type { IconComponent } from '$lib/shared/utils/types';

	let {
		Icon,
		label,
		cls,
		disabled,
		onClick = null
	}: {
		Icon: IconComponent;
		label: string;
		cls: string;
		disabled: boolean;
		onClick?: (() => void) | null;
	} = $props();
</script>

<button type="button" onclick={onClick} class={cls} {disabled}>
	<Icon class="h-4 w-4" />
	<span>{label}</span>
	<KbdKey size="sm" key="R" />
</button>
