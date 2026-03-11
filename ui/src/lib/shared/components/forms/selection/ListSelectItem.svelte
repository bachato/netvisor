<!-- T: Item type, C: type of context passed to item -->
<!-- eslint-disable-next-line @typescript-eslint/no-explicit-any -->
<script lang="ts" generics="T, C">
	import { onMount, getContext } from 'svelte';
	import Tag from '../../data/Tag.svelte';
	import EntityTag from '../../data/EntityTag.svelte';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import InlineDescription from '$lib/features/topology/components/panel/inspectors/InlineDescription.svelte';
	import type { EntityDisplayComponent } from './types';

	export let item: T;
	export let displayComponent: EntityDisplayComponent<T, C>;
	export let context: C;
	export let staticTags: boolean = false;

	const staticTagsContext = getContext<boolean>('staticTags') ?? false;

	$: icon = displayComponent.getIcon?.(item, context);
	$: tags = displayComponent.getTags?.(item, context) || [];
	$: description = displayComponent.getDescription?.(item, context) || '';
	$: tagPickerProps = displayComponent.getTagPickerProps?.(item, context) ?? null;
	$: showTagPicker =
		tagPickerProps &&
		context &&
		typeof context === 'object' &&
		'showEntityTagPicker' in context &&
		(context as Record<string, unknown>).showEntityTagPicker;
	$: tagPickerDisabled =
		context &&
		typeof context === 'object' &&
		'tagPickerDisabled' in context &&
		!!(context as Record<string, unknown>).tagPickerDisabled;

	$: showEditableDescription =
		context &&
		typeof context === 'object' &&
		'showEditableEntityDescription' in context &&
		(context as Record<string, unknown>).showEditableEntityDescription;
	$: descriptionValue = showEditableDescription
		? (((context as Record<string, unknown>).entityDescription as string | null) ?? null)
		: null;
	$: descriptionDisabled = showEditableDescription
		? !!(context as Record<string, unknown>).entityDescriptionDisabled
		: true;
	$: descriptionOnSave = showEditableDescription
		? ((context as Record<string, unknown>).onEntityDescriptionSave as
				| ((value: string | null) => void)
				| undefined)
		: undefined;

	let containerEl: HTMLDivElement;
	let labelEl: HTMLSpanElement;
	let measureEl: HTMLDivElement;
	let visibleTagCount = 1;

	const MIN_LABEL_WIDTH = 60;
	const GAP = 8; // gap-2 = 0.5rem = 8px
	const TAG_GAP = 4; // gap-1 = 0.25rem = 4px
	const MORE_WIDTH = 50; // approximate width for "+X more"

	function calculateVisibleTags() {
		if (!containerEl || !labelEl || !measureEl || tags.length === 0) return;

		const containerWidth = containerEl.offsetWidth;
		const labelScrollWidth = labelEl.scrollWidth;

		// Get measured tag widths
		const tagEls = measureEl.querySelectorAll('[data-tag]');
		const tagWidths: number[] = [];
		tagEls.forEach((el) => tagWidths.push((el as HTMLElement).offsetWidth));

		if (tagWidths.length === 0) return;

		// Calculate how much space we have for tags
		// Start with full label, then see how many tags fit
		let availableForTags = containerWidth - labelScrollWidth - GAP;

		// If label takes too much space, give it minimum and use the rest for tags
		if (availableForTags < tagWidths[0]) {
			availableForTags = containerWidth - MIN_LABEL_WIDTH - GAP;
		}

		// Always show at least one tag
		let count = 1;
		let usedWidth = tagWidths[0];

		// Try to fit more tags
		for (let i = 1; i < tagWidths.length; i++) {
			const needsMore = i < tagWidths.length - 1;
			const extraWidth = TAG_GAP + tagWidths[i] + (needsMore ? TAG_GAP + MORE_WIDTH : 0);

			if (usedWidth + extraWidth <= availableForTags) {
				count++;
				usedWidth += TAG_GAP + tagWidths[i];
			} else {
				break;
			}
		}

		// If we're not showing all tags, account for "+X more" in final check
		if (count < tagWidths.length) {
			const totalWithMore = usedWidth + TAG_GAP + MORE_WIDTH;
			if (totalWithMore > availableForTags && count > 1) {
				count--;
			}
		}

		visibleTagCount = count;
	}

	onMount(() => {
		calculateVisibleTags();
		const observer = new ResizeObserver(() => calculateVisibleTags());
		observer.observe(containerEl);
		return () => observer.disconnect();
	});

	$: if (tags && containerEl) {
		// Recalculate when tags change
		requestAnimationFrame(() => calculateVisibleTags());
	}

	$: visibleTags = tags.slice(0, visibleTagCount);
	$: hiddenCount = tags.length - visibleTagCount;
</script>

<div class="flex min-w-0 items-center gap-3">
	<!-- Icon -->
	{#if icon}
		<div class="flex h-7 w-7 flex-shrink-0 items-center justify-center">
			<svelte:component
				this={icon}
				class="h-5 w-5 {displayComponent.getIconColor?.(item, context) || 'text-secondary'}"
			/>
		</div>
	{/if}

	<!-- Label and description -->
	<div class="min-w-0 flex-1 overflow-hidden text-left">
		<div bind:this={containerEl} class="flex min-w-0 items-center gap-2">
			<span bind:this={labelEl} class="text-secondary truncate"
				>{displayComponent.getLabel(item, context)}</span
			>
			{#if tags.length > 0}
				<div class="flex flex-shrink-0 items-center gap-1">
					{#each visibleTags as tag, i (`${tag.label}-${i}`)}
						{#if !staticTags && !staticTagsContext && tag.entityRef}
							<EntityTag
								entityRef={tag.entityRef}
								label={tag.label}
								color={tag.color}
								icon={tag.icon ?? null}
							/>
						{:else if !staticTags && !staticTagsContext && (tag.onmouseenter || tag.onmouseleave || tag.onclick)}
							<button
								type="button"
								class="inline-flex cursor-pointer"
								onmouseenter={tag.onmouseenter}
								onmouseleave={tag.onmouseleave}
								onclick={tag.onclick}
							>
								<Tag
									label={tag.label}
									color={tag.color}
									pill={tag.pill}
									icon={tag.icon ?? null}
									href={tag.href ?? ''}
								/>
							</button>
						{:else}
							<Tag
								label={tag.label}
								color={tag.color}
								icon={tag.icon ?? null}
								href={tag.href ?? ''}
							/>
						{/if}
					{/each}
					{#if hiddenCount > 0}
						<span class="text-tertiary whitespace-nowrap text-xs">+{hiddenCount} more</span>
					{/if}
				</div>
			{/if}
		</div>
		{#if description.length > 0}
			<span class="text-tertiary mt-1 block truncate text-xs">{description}</span>
		{/if}
		{#if (showEditableDescription && descriptionOnSave) || (showTagPicker && tagPickerProps && (!tagPickerDisabled || tagPickerProps.selectedTagIds.length > 0))}
			<div class="mt-2 space-y-2 border-t border-gray-700/50 pt-2">
				{#if showEditableDescription && descriptionOnSave}
					<InlineDescription
						value={descriptionValue}
						editable={!descriptionDisabled}
						onSave={descriptionOnSave}
					/>
				{/if}
				{#if showTagPicker && tagPickerProps && (!tagPickerDisabled || tagPickerProps.selectedTagIds.length > 0)}
					<div class="flex items-start gap-1.5">
						<span class="text-tertiary shrink-0 text-xs leading-5">Tags:</span>
						<TagPickerInline
							selectedTagIds={tagPickerProps.selectedTagIds}
							entityId={tagPickerProps.entityId}
							entityType={tagPickerProps.entityType}
							disabled={tagPickerDisabled}
							availableTags={tagPickerProps.availableTags}
						/>
					</div>
				{/if}
			</div>
		{/if}
	</div>
</div>

<!-- Hidden measurement container -->
{#if tags.length > 0}
	<div bind:this={measureEl} class="invisible absolute -left-[9999px]" aria-hidden="true">
		<div class="flex gap-1">
			{#each tags as tag, i (`measure-${tag.label}-${i}`)}
				<span data-tag
					><Tag
						label={tag.label}
						color={tag.color}
						icon={tag.icon ?? null}
						href={tag.href ?? ''}
					/></span
				>
			{/each}
		</div>
	</div>
{/if}
