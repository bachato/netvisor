<script lang="ts">
	import type { components } from '$lib/api/schema';
	import { Eye, EyeOff, FunnelX } from 'lucide-svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { hoveredTag } from '../../../interactions';
	import {
		topology_hideEntity,
		topology_showEntity,
		topology_hideLastElementDisabled,
		topology_clearSectionFilters
	} from '$lib/paraglide/messages';

	type EntityType = components['schemas']['EntityDiscriminants'];

	let {
		entityType,
		hoverable,
		togglePresent,
		toggleDisabled,
		hidden,
		activeFilterCount = 0,
		onToggle,
		onClearSection
	}: {
		entityType: EntityType;
		hoverable: boolean;
		togglePresent: boolean;
		toggleDisabled: boolean;
		hidden: boolean;
		activeFilterCount?: number;
		onToggle: (entityType: EntityType) => void;
		onClearSection?: (entityType: EntityType) => void;
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
<!-- Name + eye live in a single inline-flex block so the eye is visually
  anchored to the entity name (same-row, small gap). Hover + eye-click
  affordances are scoped to this block, not the whole section width. -->
<div class="flex items-center">
	<div
		class="filter-section-name flex select-none items-center gap-1.5"
		class:filter-section-name-hoverable={hoverable}
		onmouseenter={onEnter}
		onmouseleave={onLeave}
	>
		<span class="text-secondary text-xs font-semibold uppercase tracking-wide">
			{label}
		</span>
		{#if activeFilterCount > 0 && onClearSection}
			<button
				type="button"
				class="btn-secondary gap-1 rounded px-1.5 py-0 text-xs font-medium"
				title={topology_clearSectionFilters({ entity: label })}
				onclick={() => onClearSection(entityType)}
			>
				<FunnelX class="h-3 w-3" />
				{activeFilterCount}
			</button>
		{/if}
		{#if togglePresent}
			<button
				type="button"
				class="btn-secondary rounded px-1 py-0"
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
</div>

<style>
	.filter-section-name {
		cursor: default;
	}
	/* Always-on dotted underline when the section is hoverable — acts as a
	 * standing affordance that the name is interactive, rather than only
	 * appearing on hover. */
	.filter-section-name-hoverable > span {
		text-decoration: underline dotted;
		text-underline-offset: 3px;
		text-decoration-thickness: 1px;
	}
</style>
