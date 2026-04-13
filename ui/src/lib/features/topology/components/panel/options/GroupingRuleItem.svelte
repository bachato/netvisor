<script lang="ts">
	import { Lock } from 'lucide-svelte';
	import { tooltip } from '$lib/shared/actions/tooltip';

	let {
		label,
		description,
		locked = false,
		disabled = false,
		disabledTooltip
	}: {
		label: string;
		description?: string;
		locked?: boolean;
		disabled?: boolean;
		disabledTooltip?: string;
	} = $props();
</script>

<div
	class="flex flex-col"
	class:opacity-40={disabled}
	use:tooltip
	data-tooltip={disabled ? disabledTooltip : null}
>
	<div class="flex items-center gap-2">
		<span class="text-sm" class:text-primary={!disabled} class:text-tertiary={disabled}
			>{label}</span
		>
		{#if locked}
			<Lock class="text-tertiary h-3 w-3" />
		{/if}
	</div>
	{#if description}
		<span class="text-tertiary text-xs">{description}</span>
	{/if}
</div>
