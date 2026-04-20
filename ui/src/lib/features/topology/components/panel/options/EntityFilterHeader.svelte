<script lang="ts">
	import type { components } from '$lib/api/schema';
	import { Eye, EyeOff } from 'lucide-svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { hoveredTag } from '../../../interactions';
	import {
		topology_hideEntity,
		topology_showEntity,
		topology_hideLastElementDisabled
	} from '$lib/paraglide/messages';

	type EntityType = components['schemas']['EntityDiscriminants'];

	let {
		entityType,
		hoverable,
		togglePresent,
		toggleDisabled,
		hidden,
		onToggle
	}: {
		entityType: EntityType;
		hoverable: boolean;
		togglePresent: boolean;
		toggleDisabled: boolean;
		hidden: boolean;
		onToggle: (entityType: EntityType) => void;
	} = $props();

	let label = $derived(entities.getMetadata(entityType)?.entity_name_plural ?? entityType);

	function onEnter() {
		if (!hoverable) return;
		hoveredTag.set({ entityType, tagId: null, color: null });
	}
	function onLeave() {
		if (!hoverable) return;
		hoveredTag.set(null);
	}
</script>

<!-- svelte-ignore a11y_no_static_element_interactions -->
<div
	class="flex items-center justify-between"
	onmouseenter={onEnter}
	onmouseleave={onLeave}
>
	<span class="text-secondary text-xs font-semibold uppercase tracking-wide">
		{label}
	</span>
	{#if togglePresent}
		<button
			type="button"
			class="text-tertiary hover:text-secondary flex items-center rounded p-0.5 transition-colors disabled:cursor-not-allowed disabled:opacity-40"
			disabled={toggleDisabled}
			title={toggleDisabled
				? topology_hideLastElementDisabled({ entity: label })
				: hidden
					? topology_showEntity({ entity: label })
					: topology_hideEntity({ entity: label })}
			aria-pressed={hidden}
			onclick={() => onToggle(entityType)}
		>
			{#if hidden}
				<EyeOff class="h-3.5 w-3.5" />
			{:else}
				<Eye class="h-3.5 w-3.5" />
			{/if}
		</button>
	{/if}
</div>
