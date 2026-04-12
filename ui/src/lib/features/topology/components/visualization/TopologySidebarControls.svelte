<script lang="ts">
	import { Controls, Panel } from '@xyflow/svelte';
	import { Keyboard, Expand, Shrink, PencilOff, Pencil } from 'lucide-svelte';
	import {
		topology_shortcutsTitle,
		topology_editModeTooltip,
		topology_viewModeTooltip,
		common_edit,
		common_shortcuts
	} from '$lib/paraglide/messages';
	import TopologySidebarButton from './TopologySidebarButton.svelte';
	import type { Padding } from '@xyflow/system';

	let {
		editMode = false,
		onToggleEditMode = null,
		onOpenShortcuts = null,
		sidebarCollapsed = false,
		onStepExpand,
		onStepCollapse,
		expandDisabled,
		collapseDisabled,
		collapseLevelLabel,
		collapseLevelTooltipExpand,
		collapseLevelTooltipCollapse,
		fitViewOptions
	}: {
		editMode?: boolean;
		onToggleEditMode?: (() => void) | null;
		onOpenShortcuts?: (() => void) | null;
		sidebarCollapsed?: boolean;
		onStepExpand: () => void;
		onStepCollapse: () => void;
		expandDisabled: boolean;
		collapseDisabled: boolean;
		collapseLevelLabel: string;
		collapseLevelTooltipExpand: string;
		collapseLevelTooltipCollapse: string;
		fitViewOptions: { padding: Padding };
	} = $props();
</script>

<Panel position="top-right" class="!m-[10px] !flex !flex-col !items-end !gap-2 !p-0">
	{#if onToggleEditMode}
		<TopologySidebarButton
			onclick={onToggleEditMode}
			title={editMode ? topology_editModeTooltip() : topology_viewModeTooltip()}
			label={common_edit()}
			active={editMode}
			collapsed={sidebarCollapsed}
		>
			{#snippet icon()}
				{#if editMode}
					<Pencil class="h-4 w-4" />
				{:else}
					<PencilOff class="h-4 w-4" />
				{/if}
			{/snippet}
		</TopologySidebarButton>
	{/if}
	<TopologySidebarButton
		onclick={onStepExpand}
		title={collapseLevelTooltipExpand}
		label={collapseLevelLabel}
		disabled={expandDisabled}
		collapsed={sidebarCollapsed}
	>
		{#snippet icon()}
			<Expand class="h-4 w-4" />
		{/snippet}
	</TopologySidebarButton>
	<TopologySidebarButton
		onclick={onStepCollapse}
		title={collapseLevelTooltipCollapse}
		label={collapseLevelLabel}
		disabled={collapseDisabled}
		collapsed={sidebarCollapsed}
	>
		{#snippet icon()}
			<Shrink class="h-4 w-4" />
		{/snippet}
	</TopologySidebarButton>
	{#if onOpenShortcuts}
		<TopologySidebarButton
			onclick={onOpenShortcuts}
			title={topology_shortcutsTitle()}
			label={common_shortcuts()}
			collapsed={sidebarCollapsed}
		>
			{#snippet icon()}
				<Keyboard class="h-4 w-4" />
			{/snippet}
		</TopologySidebarButton>
	{/if}
	<Controls
		showZoom={true}
		showFitView={true}
		{fitViewOptions}
		showLock={false}
		class="!static !m-0 !rounded !border !border-gray-300 !bg-white !shadow-lg dark:!border-gray-600 dark:!bg-gray-800 [&_button:hover]:!bg-gray-100 dark:[&_button:hover]:!bg-gray-600 [&_button]:!border-gray-300 [&_button]:!bg-gray-50 [&_button]:!text-gray-700 dark:[&_button]:!border-gray-600 dark:[&_button]:!bg-gray-700 dark:[&_button]:!text-gray-100"
	/>
</Panel>
