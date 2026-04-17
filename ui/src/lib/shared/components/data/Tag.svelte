<script lang="ts">
	import { X } from 'lucide-svelte';
	import { createColorHelper, type Color } from '$lib/shared/utils/styling';
	import { common_unknown } from '$lib/paraglide/messages';
	import type { IconComponent } from '$lib/shared/utils/types';
	import { tooltip } from '$lib/shared/actions/tooltip';

	let {
		icon = null,
		color = 'Gray',
		disabled = false,
		label = null,
		badge = '',
		href = '',
		pill = false,
		title = '',
		removable = false,
		isShiny = false,
		nativeTooltip = false,
		faded = false,
		truncate = false,
		onclick = undefined,
		onmouseenter = undefined,
		onmouseleave = undefined,
		onRemove
	}: {
		icon?: IconComponent | null;
		color?: Color | null;
		disabled?: boolean;
		label?: string | null;
		badge?: string;
		href?: string;
		pill?: boolean;
		title?: string;
		removable?: boolean;
		isShiny?: boolean;
		nativeTooltip?: boolean;
		faded?: boolean;
		/**
		 * When true, the tag shrinks to fit its container (min-w-0 + max-w-full) and
		 * fades out at the right edge if the label is too long. The tag stays on one line.
		 */
		truncate?: boolean;
		onclick?: ((e: MouseEvent) => void) | undefined;
		onmouseenter?: ((e: MouseEvent) => void) | undefined;
		onmouseleave?: ((e: MouseEvent) => void) | undefined;
		onRemove?: () => void;
	} = $props();

	let interactive = $derived(!!href || !!onclick);
	let fadedClasses = $derived(
		faded ? 'opacity-50 grayscale hover:opacity-75 hover:grayscale-[50%] dark:opacity-40' : ''
	);

	let isUnknown = $derived(!label || !color);
	let colorHelper = $derived(color ? createColorHelper(color) : null);
	let bgColor = $derived(colorHelper?.bg ?? '');
	let textColor = $derived(colorHelper?.text ?? '');

	let unknownClasses = 'bg-gray-200 text-gray-600 dark:bg-gray-600 dark:text-gray-300';
</script>

{#snippet content()}
	<span
		class="inline-flex items-center gap-1 {pill
			? 'rounded-full'
			: 'rounded'} px-2 py-0.5 text-xs font-medium
		{isUnknown ? unknownClasses : disabled ? 'text-tertiary bg-gray-700/30' : `${bgColor} ${textColor}`}
		{isShiny ? 'tag-shiny' : ''}
		{truncate ? 'tag-truncate' : ''}"
	>
		{#if icon}
			{@const Icon = icon}
			<Icon size={16} class="{textColor} flex-shrink-0" />
		{/if}

		<span class="truncate">{label ?? common_unknown()}</span>
		{#if badge.length > 0}
			<span class="flex-shrink-0 {textColor}">{badge}</span>
		{/if}
		{#if removable && onRemove}
			<button
				type="button"
				onclick={onRemove}
				class="rounded-full p-0.5 transition-colors hover:bg-white/20"
			>
				<X class="h-3 w-3" />
			</button>
		{/if}
	</span>
{/snippet}

<!-- eslint-disable svelte/no-navigation-without-resolve -->
{#if href}
	<a
		{href}
		target="_blank"
		rel="noopener noreferrer"
		use:tooltip
		data-tooltip={nativeTooltip ? null : title || null}
		title={nativeTooltip ? title || undefined : undefined}
		class="inline-flex {truncate
			? 'min-w-0 max-w-full'
			: 'flex-shrink-0'} items-center gap-1 whitespace-nowrap rounded brightness-100 transition-all hover:brightness-90 dark:hover:brightness-125 {fadedClasses}"
		onclick={(e) => e.stopPropagation()}
	>
		{@render content()}
	</a>
{:else if interactive}
	<button
		type="button"
		use:tooltip
		data-tooltip={nativeTooltip ? null : title || null}
		title={nativeTooltip ? title || undefined : undefined}
		class="inline-flex {truncate
			? 'min-w-0 max-w-full'
			: 'flex-shrink-0'} cursor-pointer appearance-none items-center gap-1 whitespace-nowrap rounded brightness-100 transition-all hover:brightness-90 dark:hover:brightness-125 {fadedClasses}"
		{onclick}
		{onmouseenter}
		{onmouseleave}
		{disabled}
	>
		{@render content()}
	</button>
{:else}
	<div
		use:tooltip
		data-tooltip={nativeTooltip ? null : title || null}
		title={nativeTooltip ? title || undefined : undefined}
		class="inline-flex {truncate
			? 'min-w-0 max-w-full'
			: 'flex-shrink-0'} items-center gap-1 whitespace-nowrap rounded {fadedClasses}"
	>
		{@render content()}
	</div>
{/if}

<style>
	/* When a Tag has truncate=true: apply a right-edge fade mask so the label
	   gracefully fades out instead of hard-truncating with an ellipsis. The
	   inner .truncate span still clips overflow via overflow:hidden. We override
	   text-overflow to `clip` so no "..." appears before the fade. */
	:global(.tag-truncate) {
		-webkit-mask-image: linear-gradient(to right, black calc(100% - 1rem), transparent 100%);
		mask-image: linear-gradient(to right, black calc(100% - 1rem), transparent 100%);
	}

	:global(.tag-truncate) :global(.truncate) {
		text-overflow: clip;
	}

	:global(.tag-shiny) {
		position: relative;
		overflow: hidden;
	}

	:global(.tag-shiny)::after {
		content: '';
		position: absolute;
		inset: 0;
		background: linear-gradient(
			120deg,
			transparent 0%,
			transparent 30%,
			rgba(255, 255, 255, 0.08) 45%,
			rgba(255, 255, 255, 0.12) 50%,
			rgba(255, 255, 255, 0.08) 55%,
			transparent 70%,
			transparent 100%
		);
		transform: translateX(-100%);
		pointer-events: none;
	}

	:global(.tag-shiny:hover)::after {
		animation: tag-sheen-hover 0.6s ease-out forwards;
	}

	@keyframes tag-sheen {
		from {
			transform: translateX(-100%);
		}
		to {
			transform: translateX(100%);
		}
	}

	@keyframes tag-sheen-hover {
		from {
			transform: translateX(-100%);
			opacity: 0.4;
		}
		to {
			transform: translateX(100%);
			opacity: 0.4;
		}
	}
</style>
