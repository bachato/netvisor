<script lang="ts">
	import { onMount } from 'svelte';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import type { ColorStyle, Color } from '$lib/shared/utils/styling';
	import type { IconComponent } from '$lib/shared/utils/types';
	import { topology_elementCount, topology_ungroupedCount } from '$lib/paraglide/messages';

	export type SubgroupRow = {
		logoComponent: IconComponent | null;
		headerText: string;
		labels: Array<{ label: string; color: Color }>;
		childCount: number;
	};

	let {
		isCollapsed,
		isCollapsible,
		headerText,
		iconComponent = null,
		logoComponent = null,
		fillIcon = false,
		colorHelper,
		groupLabels = [],
		childCount = 0,
		elementLabel = 'hosts',
		onToggleCollapse,
		variant,
		subgroupSummaries = [],
		tagHoverRingStyle = ''
	}: {
		isCollapsed: boolean;
		isCollapsible: boolean;
		headerText: string;
		iconComponent: IconComponent | null;
		logoComponent: IconComponent | null;
		fillIcon: boolean;
		colorHelper: ColorStyle;
		groupLabels: Array<{ label: string; color: Color }>;
		childCount: number;
		elementLabel: string;
		onToggleCollapse: (event: MouseEvent | KeyboardEvent) => void;
		variant: 'external' | 'inline' | 'collapsed-sub' | 'collapsed-root';
		subgroupSummaries?: SubgroupRow[];
		tagHoverRingStyle?: string;
	} = $props();

	let subgroupTotal = $derived(subgroupSummaries.reduce((sum, s) => sum + s.childCount, 0));
	let ungroupedCount = $derived(childCount - subgroupTotal);

	// Tag truncation for inline variant: measure available space, show "+X more" for overflow
	const TAG_GAP = 4;
	const MORE_WIDTH = 50;
	let inlineContainerEl: HTMLDivElement | undefined = $state(undefined);
	let inlineMeasureEl: HTMLDivElement | undefined = $state(undefined);
	let visibleLabelCount = $state(groupLabels.length);

	function calculateVisibleLabels() {
		if (!inlineContainerEl || !inlineMeasureEl || groupLabels.length === 0) {
			visibleLabelCount = groupLabels.length;
			return;
		}

		const containerWidth = inlineContainerEl.offsetWidth;
		const tagEls = inlineMeasureEl.querySelectorAll('[data-tag]');
		const tagWidths: number[] = [];
		tagEls.forEach((el) => tagWidths.push((el as HTMLElement).offsetWidth));

		if (tagWidths.length === 0) {
			visibleLabelCount = groupLabels.length;
			return;
		}

		// Space used by non-tag elements (chevron, icon, header text)
		const fixedEls = inlineContainerEl.querySelectorAll('[data-fixed]');
		let fixedWidth = 0;
		fixedEls.forEach((el) => (fixedWidth += (el as HTMLElement).offsetWidth + TAG_GAP));

		let availableForTags = containerWidth - fixedWidth;
		let count = 0;
		let usedWidth = 0;

		for (let i = 0; i < tagWidths.length; i++) {
			const needsMore = i < tagWidths.length - 1;
			const extraWidth =
				(count > 0 ? TAG_GAP : 0) + tagWidths[i] + (needsMore ? TAG_GAP + MORE_WIDTH : 0);

			if (usedWidth + extraWidth <= availableForTags) {
				count++;
				usedWidth += (count > 1 ? TAG_GAP : 0) + tagWidths[i];
			} else {
				break;
			}
		}

		if (count < tagWidths.length && count > 1) {
			const totalWithMore = usedWidth + TAG_GAP + MORE_WIDTH;
			if (totalWithMore > availableForTags) {
				count--;
			}
		}

		visibleLabelCount = Math.max(count, 0);
	}

	let needsTruncation = $derived(
		(variant === 'inline' || variant === 'collapsed-sub') && groupLabels.length > 0
	);

	$effect(() => {
		if (needsTruncation && inlineContainerEl) {
			requestAnimationFrame(() => calculateVisibleLabels());
		}
	});

	onMount(() => {
		if (needsTruncation && inlineContainerEl) {
			const observer = new ResizeObserver(() => calculateVisibleLabels());
			observer.observe(inlineContainerEl);
			return () => observer.disconnect();
		}
	});

	let visibleLabels = $derived(groupLabels.slice(0, visibleLabelCount));
	let hiddenLabelCount = $derived(groupLabels.length - visibleLabelCount);
</script>

<!-- Hidden measurement container for tag widths (shared by inline + collapsed-sub) -->
{#if needsTruncation}
	<div
		bind:this={inlineMeasureEl}
		class="pointer-events-none invisible absolute flex items-center gap-1"
		aria-hidden="true"
	>
		{#each groupLabels as pill (pill.label)}
			<span data-tag><Tag label={pill.label} color={pill.color} /></span>
		{/each}
	</div>
{/if}

{#if variant === 'external'}
	<!-- External title pill: card above container -->
	<div
		class="nopan nodrag card text-secondary z-100 absolute -top-10 left-0 flex cursor-pointer items-center gap-1 px-2 py-1 shadow-lg backdrop-blur-sm"
		role="button"
		tabindex={-1}
		onclick={onToggleCollapse}
		onkeydown={(e) => {
			if (e.key === 'Enter' || e.key === ' ') onToggleCollapse(e);
		}}
		onmousedown={(e) => e.stopPropagation()}
		onpointerdown={(e) => e.stopPropagation()}
	>
		{#if isCollapsible}
			{#if isCollapsed}
				<ChevronRight class="text-secondary h-4 w-4 flex-shrink-0" />
			{:else}
				<ChevronDown class="text-secondary h-4 w-4 flex-shrink-0" />
			{/if}
		{/if}

		{#if iconComponent}
			{@const IconComp = iconComponent}
			<IconComp class={`h-5 w-5 ${colorHelper.icon}`} fill={fillIcon ? 'currentColor' : 'none'} />
		{/if}

		<span class="text-s text-secondary whitespace-nowrap font-medium">
			{headerText}
		</span>
	</div>
{:else if variant === 'inline'}
	<!-- Inline header: inside container top padding -->
	<div
		bind:this={inlineContainerEl}
		class="nopan nodrag text-secondary absolute left-2 right-2 top-2 flex items-center gap-1 overflow-hidden rounded-t px-2 py-0.5"
	>
		{#if isCollapsible}
			<span data-fixed><ChevronDown class="text-secondary h-3.5 w-3.5 flex-shrink-0" /></span>
		{/if}
		{#if logoComponent}
			{@const LogoComp = logoComponent}
			<span data-fixed><LogoComp class="h-4 w-4 flex-shrink-0" /></span>
		{/if}
		{#if headerText}
			<span data-fixed class="text-tertiary flex-shrink-0 whitespace-nowrap text-xs font-medium">
				{headerText}{groupLabels.length > 0 ? ':' : ''}
			</span>
		{/if}
		{#each visibleLabels as pill (pill.label)}
			<Tag label={pill.label} color={pill.color} />
		{/each}
		{#if hiddenLabelCount > 0}
			<span class="text-tertiary whitespace-nowrap text-xs">+{hiddenLabelCount} more</span>
		{/if}
	</div>
{:else if variant === 'collapsed-sub'}
	<!-- Collapsed subcontainer: compact inline with dashed border -->
	<div
		bind:this={inlineContainerEl}
		class="nopan nodrag flex cursor-pointer items-center gap-1 overflow-hidden rounded-lg border border-dashed border-gray-300 px-3 py-2 dark:border-gray-600"
		style="background: var(--color-topology-subgroup-bg);"
		role="button"
		tabindex={-1}
		onclick={onToggleCollapse}
		onkeydown={(e) => {
			if (e.key === 'Enter' || e.key === ' ') onToggleCollapse(e);
		}}
	>
		<span data-fixed><ChevronRight class="text-secondary h-3.5 w-3.5 flex-shrink-0" /></span>
		{#if iconComponent}
			{@const IconComp = iconComponent}
			<span data-fixed
				><IconComp
					class={`h-3.5 w-3.5 flex-shrink-0 ${colorHelper.icon}`}
					fill={fillIcon ? 'currentColor' : 'none'}
				/></span
			>
		{/if}
		{#if logoComponent}
			{@const LogoComp = logoComponent}
			<span data-fixed><LogoComp class="h-4 w-4 flex-shrink-0" /></span>
		{/if}
		{#if headerText}
			<span data-fixed class="text-tertiary whitespace-nowrap text-xs font-medium">
				{headerText}{groupLabels.length > 0 ? ':' : ''}
			</span>
		{/if}
		{#each visibleLabels.slice(0, 2) as pill (pill.label)}
			<Tag label={pill.label} color={pill.color} />
		{/each}
		{#if visibleLabels.length > 2}
			<span class="text-tertiary whitespace-nowrap text-xs">+{visibleLabels.length - 2}</span>
		{:else if hiddenLabelCount > 0}
			<span class="text-tertiary whitespace-nowrap text-xs">+{hiddenLabelCount} more</span>
		{/if}
		<span data-fixed class="text-tertiary ml-auto whitespace-nowrap text-xs">
			({topology_elementCount({ count: childCount, label: elementLabel })})
		</span>
	</div>
{:else if variant === 'collapsed-root'}
	<!-- Collapsed root container: summary with subcontainer info -->
	<div
		class="rounded-xl border border-dashed border-gray-400 text-center text-sm font-semibold shadow-lg dark:border-gray-500"
		style="background: var(--color-topology-node-bg); position: relative; overflow: visible; transition: box-shadow 0.15s ease-in-out; border-top: 2px solid {colorHelper.rgb}; {tagHoverRingStyle}"
	>
		<div class="flex min-w-fit flex-col items-center gap-2 whitespace-nowrap px-6 py-4">
			<span class="text-secondary text-base font-medium underline">
				{topology_elementCount({ count: childCount, label: elementLabel })}
			</span>
			{#if ungroupedCount > 0 && subgroupSummaries.length > 0}
				<span class="text-tertiary text-xs">
					{topology_ungroupedCount({ count: ungroupedCount, label: elementLabel })}
				</span>
			{/if}
			{#each subgroupSummaries as summary (summary.headerText)}
				<div
					class="flex items-center gap-1 whitespace-nowrap rounded-md border border-dashed border-gray-300 px-2 py-1 dark:border-gray-600"
					style="background: var(--color-topology-subgroup-bg);"
				>
					{#if summary.logoComponent}
						{@const GroupLogo = summary.logoComponent}
						<GroupLogo class="h-4 w-4 flex-shrink-0" />
					{/if}
					{#if summary.headerText}
						<span class="text-tertiary text-xs"
							>{summary.headerText}{summary.labels.length > 0 ? ':' : ''}</span
						>
					{/if}
					{#each summary.labels.slice(0, 2) as pill (pill.label)}
						<Tag label={pill.label} color={pill.color} />
					{/each}
					{#if summary.labels.length > 2}
						<span class="text-tertiary text-xs">+{summary.labels.length - 2}</span>
					{/if}
					<span class="text-tertiary text-xs"
						>({topology_elementCount({
							count: summary.childCount,
							label: elementLabel
						})})</span
					>
				</div>
			{/each}
		</div>
	</div>
{/if}
