<script lang="ts">
	import type { Snippet } from 'svelte';
	import { onMount } from 'svelte';

	let {
		triggerElement = null,
		isOpen = false,
		onClose,
		onMouseEnter,
		onMouseLeave,
		children
	}: {
		triggerElement?: HTMLElement | null;
		isOpen?: boolean;
		onClose: () => void;
		onMouseEnter?: () => void;
		onMouseLeave?: () => void;
		children: Snippet;
	} = $props();

	let portalContainer: HTMLDivElement | null = $state(null);
	let popoverEl: HTMLDivElement | undefined = $state();
	let position = $state({ top: 0, left: 0 });

	onMount(() => {
		portalContainer = document.createElement('div');
		portalContainer.style.position = 'absolute';
		portalContainer.style.top = '0';
		portalContainer.style.left = '0';
		portalContainer.style.width = '0';
		portalContainer.style.height = '0';
		portalContainer.style.zIndex = '9999';
		document.body.appendChild(portalContainer);

		return () => {
			portalContainer?.remove();
		};
	});

	function portal(node: HTMLElement) {
		if (portalContainer) {
			portalContainer.appendChild(node);
		}
		return {
			destroy() {
				// Cleaned up when portalContainer is removed
			}
		};
	}

	function updatePosition() {
		if (!triggerElement || !popoverEl) return;

		const rect = triggerElement.getBoundingClientRect();
		const popoverRect = popoverEl.getBoundingClientRect();
		const viewportHeight = window.innerHeight;
		const viewportWidth = window.innerWidth;

		// Position above or below based on space
		let top: number;
		const spaceBelow = viewportHeight - rect.bottom;
		const spaceAbove = rect.top;

		if (spaceBelow >= popoverRect.height + 8 || spaceBelow >= spaceAbove) {
			top = rect.bottom + window.scrollY + 4;
		} else {
			top = rect.top + window.scrollY - popoverRect.height - 4;
		}

		// Center horizontally, constrain to viewport
		let left = rect.left + window.scrollX + rect.width / 2 - popoverRect.width / 2;
		left = Math.max(8, Math.min(left, viewportWidth - popoverRect.width - 8));

		position = { top, left };
	}

	$effect(() => {
		if (isOpen && triggerElement && popoverEl) {
			updatePosition();
		}
	});

	// Close on scroll or click outside
	$effect(() => {
		if (!isOpen) return;

		function handleScroll() {
			onClose();
		}

		function handleClickOutside(e: MouseEvent) {
			if (
				popoverEl &&
				!popoverEl.contains(e.target as Node) &&
				triggerElement &&
				!triggerElement.contains(e.target as Node)
			) {
				onClose();
			}
		}

		function handleKeydown(e: KeyboardEvent) {
			if (e.key === 'Escape') onClose();
		}

		// Use capture to catch scroll on any ancestor
		window.addEventListener('scroll', handleScroll, true);
		document.addEventListener('mousedown', handleClickOutside);
		document.addEventListener('keydown', handleKeydown);

		return () => {
			window.removeEventListener('scroll', handleScroll, true);
			document.removeEventListener('mousedown', handleClickOutside);
			document.removeEventListener('keydown', handleKeydown);
		};
	});
</script>

{#if isOpen && portalContainer}
	<div
		use:portal
		bind:this={popoverEl}
		class="fixed z-[9999] rounded-lg border p-2 shadow-[0_4px_24px_rgba(0,0,0,0.15)] dark:shadow-[0_4px_24px_rgba(0,0,0,0.5)]"
		style="border-color: var(--color-border); background: var(--color-bg-elevated); top: {position.top}px; left: {position.left}px; min-width: 200px; max-width: 350px;"
		role="tooltip"
		onmouseenter={onMouseEnter}
		onmouseleave={onMouseLeave}
	>
		{@render children()}
	</div>
{/if}
