<script lang="ts">
	import Tag from './Tag.svelte';
	import Popover from './Popover.svelte';
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityRef } from './types';
	import type { Color } from '$lib/shared/utils/styling';
	import type { IconComponent } from '$lib/shared/utils/types';
	import { entityUIConfig } from '$lib/shared/entity-ui-config';
	import { navigateToEntity } from '$lib/shared/stores/modal-registry';

	let {
		entityRef,
		label,
		icon = null,
		color = 'Gray',
		disabled = false,
		badge = '',
		disablePopover = false
	}: {
		entityRef: EntityRef;
		label: string;
		icon?: IconComponent | null;
		color?: Color;
		disabled?: boolean;
		badge?: string;
		disablePopover?: boolean;
	} = $props();

	let triggerEl: HTMLDivElement | undefined = $state();
	let isHovered = $state(false);
	let popoverHovered = $state(false);
	let hoverTimeout: ReturnType<typeof setTimeout> | undefined;
	let leaveTimeout: ReturnType<typeof setTimeout> | undefined;

	let config = $derived(entityUIConfig[entityRef.entityType]);
	let displayComponent = $derived(config?.displayComponent ?? null);

	function handleMouseEnter() {
		if (!displayComponent || disablePopover) return;
		clearTimeout(leaveTimeout);
		hoverTimeout = setTimeout(() => {
			isHovered = true;
		}, 300);
	}

	function handleMouseLeave() {
		clearTimeout(hoverTimeout);
		leaveTimeout = setTimeout(() => {
			if (!popoverHovered) {
				isHovered = false;
			}
		}, 150);
	}

	function handlePopoverEnter() {
		clearTimeout(leaveTimeout);
		popoverHovered = true;
	}

	function handlePopoverLeave() {
		popoverHovered = false;
		isHovered = false;
	}

	function handleClick(e: MouseEvent) {
		e.stopPropagation();
		e.preventDefault();
		if (disabled) return;
		isHovered = false;
		navigateToEntity(entityRef.entityType, entityRef.entityId, entityRef.data);
	}
</script>

<div
	bind:this={triggerEl}
	class="inline-flex flex-shrink-0 cursor-pointer items-center gap-1 whitespace-nowrap rounded-full brightness-100 transition-all hover:brightness-90 dark:hover:brightness-125"
	onmouseenter={handleMouseEnter}
	onmouseleave={handleMouseLeave}
	onclick={handleClick}
	onkeydown={(e) => {
		if (e.key === 'Enter' || e.key === ' ') handleClick(e as unknown as MouseEvent);
	}}
	role="button"
	tabindex="0"
>
	<Tag {icon} {color} {disabled} {label} {badge} pill={true} />
</div>

{#if displayComponent}
	<Popover
		triggerElement={triggerEl}
		isOpen={isHovered}
		onClose={() => {
			popoverHovered = false;
			isHovered = false;
		}}
		onMouseEnter={handlePopoverEnter}
		onMouseLeave={handlePopoverLeave}
	>
		<ListSelectItem item={entityRef.data} context={entityRef.context ?? {}} {displayComponent} />
	</Popover>
{/if}
