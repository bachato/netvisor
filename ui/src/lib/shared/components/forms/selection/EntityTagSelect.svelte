<script lang="ts" module>
	import type { EntityRef } from '$lib/shared/components/data/types';
	import type { Color } from '$lib/shared/utils/styling';
	import type { IconComponent } from '$lib/shared/utils/types';

	export interface EntityTagOption {
		id: string;
		entityRef: EntityRef;
		label: string;
		icon?: IconComponent | null;
		color?: Color;
	}
</script>

<script lang="ts">
	import { ChevronDown } from 'lucide-svelte';
	import { tick, onMount, setContext } from 'svelte';
	import EntityTag from '$lib/shared/components/data/EntityTag.svelte';
	import { common_selectOption, common_noOptionsAvailable } from '$lib/paraglide/messages';

	// Disable EntityTag's own click-to-navigate and hover-popover inside the dropdown —
	// otherwise clicking an option would navigate away instead of selecting it.
	setContext('staticTags', true);

	let {
		options,
		selectedValue,
		onSelect,
		placeholder = undefined,
		disabled = false,
		error = null
	}: {
		options: EntityTagOption[];
		selectedValue: string | null;
		onSelect: (id: string) => void;
		placeholder?: string;
		disabled?: boolean;
		error?: string | null;
	} = $props();

	let isOpen = $state(false);
	let triggerEl: HTMLButtonElement | undefined = $state();
	let dropdownEl: HTMLDivElement | undefined = $state();
	let portalContainer: HTMLDivElement | null = $state(null);
	let dropdownPosition = $state({ top: 0, left: 0, width: 0 });
	let openUpward = $state(false);

	onMount(() => {
		portalContainer = document.createElement('div');
		portalContainer.style.position = 'absolute';
		portalContainer.style.top = '0';
		portalContainer.style.left = '0';
		portalContainer.style.width = '0';
		portalContainer.style.height = '0';
		document.body.appendChild(portalContainer);
		return () => {
			portalContainer?.remove();
		};
	});

	let selected = $derived(options.find((o) => o.id === selectedValue));

	function portal(node: HTMLElement) {
		if (portalContainer) portalContainer.appendChild(node);
		return { destroy() {} };
	}

	async function toggle(e: MouseEvent) {
		e.preventDefault();
		e.stopPropagation();
		if (disabled || options.length === 0) return;
		if (!isOpen) {
			isOpen = true;
			await tick();
			if (triggerEl) {
				const rect = triggerEl.getBoundingClientRect();
				const spaceBelow = window.innerHeight - rect.bottom - 4;
				openUpward = spaceBelow < 280 && rect.top > spaceBelow;
				dropdownPosition = {
					top: openUpward ? rect.top - 4 : rect.bottom + 4,
					left: rect.left,
					width: rect.width
				};
			}
		} else {
			isOpen = false;
		}
	}

	function handleSelect(id: string) {
		onSelect(id);
		isOpen = false;
	}

	function handleOutside(e: MouseEvent) {
		if (
			dropdownEl &&
			!dropdownEl.contains(e.target as Node) &&
			triggerEl &&
			!triggerEl.contains(e.target as Node)
		) {
			isOpen = false;
		}
	}
</script>

<svelte:window onclick={handleOutside} />

<div class="relative">
	<button
		bind:this={triggerEl}
		type="button"
		onclick={toggle}
		class="select-trigger text-primary flex w-full items-center justify-between gap-2 rounded-md px-2 py-1.5
           {error ? 'border-red-500' : ''}
           {disabled || options.length === 0 ? 'cursor-not-allowed opacity-50' : ''}"
		disabled={disabled || options.length === 0}
	>
		{#if selected}
			<EntityTag
				entityRef={selected.entityRef}
				label={selected.label}
				icon={selected.icon ?? null}
				color={selected.color ?? 'Gray'}
				disablePopover={true}
			/>
		{:else}
			<span class="text-secondary text-sm">
				{options.length === 0
					? common_noOptionsAvailable()
					: (placeholder ?? common_selectOption())}
			</span>
		{/if}
		<ChevronDown
			class="text-tertiary h-4 w-4 flex-shrink-0 transition-transform {isOpen ? 'rotate-180' : ''}"
		/>
	</button>
	{#if error}
		<div class="text-danger mt-1 text-xs">{error}</div>
	{/if}
</div>

{#if isOpen && portalContainer}
	<div
		bind:this={dropdownEl}
		use:portal
		class="select-dropdown fixed z-[9999] max-h-72 overflow-y-auto rounded-md shadow-lg"
		style="top: {dropdownPosition.top}px; left: {dropdownPosition.left}px; min-width: {dropdownPosition.width}px;
           {openUpward ? 'transform: translateY(-100%);' : ''}"
	>
		<div class="flex flex-col items-start gap-1 p-2">
			{#each options as option (option.id)}
				<button
					type="button"
					onclick={() => handleSelect(option.id)}
					class="flex w-full rounded p-1 text-left transition-colors hover:bg-gray-100 dark:hover:bg-gray-800 {option.id ===
					selectedValue
						? 'ring-1 ring-blue-500'
						: ''}"
				>
					<EntityTag
						entityRef={option.entityRef}
						label={option.label}
						icon={option.icon ?? null}
						color={option.color ?? 'Gray'}
						disablePopover={true}
					/>
				</button>
			{/each}
		</div>
	</div>
{/if}
