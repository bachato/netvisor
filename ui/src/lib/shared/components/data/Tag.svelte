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
		onRemove?: () => void;
	} = $props();

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
		{isShiny ? 'tag-shiny' : ''}"
	>
		{#if icon}
			{@const Icon = icon}
			<Icon size={16} class={textColor} />
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
		class="inline-flex flex-shrink-0 items-center gap-1 whitespace-nowrap rounded brightness-100 transition-all hover:brightness-90 dark:hover:brightness-125"
		onclick={(e) => e.stopPropagation()}
	>
		{@render content()}
	</a>
{:else}
	<div
		use:tooltip
		data-tooltip={nativeTooltip ? null : title || null}
		title={nativeTooltip ? title || undefined : undefined}
		class="inline-flex flex-shrink-0 items-center gap-1 whitespace-nowrap rounded"
	>
		{@render content()}
	</div>
{/if}

<style>
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
