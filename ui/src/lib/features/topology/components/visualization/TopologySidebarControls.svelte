<script lang="ts">
	import { Panel } from '@xyflow/svelte';
	import { Keyboard, Expand, Shrink, Pencil, ZoomIn, ZoomOut, Maximize } from 'lucide-svelte';
	import {
		topology_shortcutsTitle,
		topology_editModeTooltip,
		topology_viewModeTooltip,
		topology_zoomIn,
		topology_zoomOut,
		topology_shortcutFitView,
		common_edit,
		common_shortcuts
	} from '$lib/paraglide/messages';
	import TopologySidebarButton from './TopologySidebarButton.svelte';

	let {
		editMode = false,
		onToggleEditMode = null,
		onOpenShortcuts = null,
		sidebarCollapsed = false,
		onStepExpand,
		onStepCollapse,
		onZoomIn,
		onZoomOut,
		onFitView,
		expandDisabled,
		collapseDisabled,
		collapseLevel,
		collapseLevelTooltipExpand,
		collapseLevelTooltipCollapse
	}: {
		editMode?: boolean;
		onToggleEditMode?: (() => void) | null;
		onOpenShortcuts?: (() => void) | null;
		sidebarCollapsed?: boolean;
		onStepExpand: () => void;
		onStepCollapse: () => void;
		onZoomIn: () => void;
		onZoomOut: () => void;
		onFitView: () => void;
		expandDisabled: boolean;
		collapseDisabled: boolean;
		collapseLevel: number;
		collapseLevelTooltipExpand: string;
		collapseLevelTooltipCollapse: string;
	} = $props();
</script>

<Panel position="top-right" class="!m-[10px] !flex !flex-col !items-end !gap-2 !p-0">
	{#if onToggleEditMode}
		<TopologySidebarButton
			onclick={onToggleEditMode}
			title={editMode ? topology_editModeTooltip() : topology_viewModeTooltip()}
			label={common_edit()}
			shortcut="E"
			active={editMode}
			collapsed={sidebarCollapsed}
		>
			{#snippet icon()}
				<Pencil class="h-4 w-4" />
			{/snippet}
		</TopologySidebarButton>
	{/if}

	<!-- Collapse/Expand group -->
	<div class="flex flex-col overflow-hidden rounded !shadow-lg">
		<TopologySidebarButton
			onclick={onStepExpand}
			title={collapseLevelTooltipExpand}
			shortcut="]"
			disabled={expandDisabled}
			collapsed={sidebarCollapsed}
			grouped="top"
		>
			{#snippet icon()}
				<Expand class="h-4 w-4" />
			{/snippet}
		</TopologySidebarButton>
		<div
			class="flex items-center justify-center border-x border-gray-300 bg-gray-50 text-xs font-semibold text-gray-500 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-400"
			style="padding: 2px 6px;"
		>
			{collapseLevel}
		</div>
		<TopologySidebarButton
			onclick={onStepCollapse}
			title={collapseLevelTooltipCollapse}
			shortcut="["
			disabled={collapseDisabled}
			collapsed={sidebarCollapsed}
			grouped="bottom"
		>
			{#snippet icon()}
				<Shrink class="h-4 w-4" />
			{/snippet}
		</TopologySidebarButton>
	</div>

	{#if onOpenShortcuts}
		<TopologySidebarButton
			onclick={onOpenShortcuts}
			title={topology_shortcutsTitle()}
			label={common_shortcuts()}
			shortcut="?"
			collapsed={sidebarCollapsed}
		>
			{#snippet icon()}
				<Keyboard class="h-4 w-4" />
			{/snippet}
		</TopologySidebarButton>
	{/if}

	<!-- Zoom group -->
	<div class="flex flex-col overflow-hidden rounded !shadow-lg">
		<TopologySidebarButton
			onclick={onZoomIn}
			title={topology_zoomIn()}
			reserveShortcutWidth={true}
			collapsed={sidebarCollapsed}
			grouped="top"
		>
			{#snippet icon()}
				<ZoomIn class="h-4 w-4" />
			{/snippet}
		</TopologySidebarButton>
		<TopologySidebarButton
			onclick={onZoomOut}
			title={topology_zoomOut()}
			reserveShortcutWidth={true}
			collapsed={sidebarCollapsed}
			grouped="bottom"
		>
			{#snippet icon()}
				<ZoomOut class="h-4 w-4" />
			{/snippet}
		</TopologySidebarButton>
	</div>

	<TopologySidebarButton
		onclick={onFitView}
		title={topology_shortcutFitView()}
		shortcut="F"
		collapsed={sidebarCollapsed}
	>
		{#snippet icon()}
			<Maximize class="h-4 w-4" />
		{/snippet}
	</TopologySidebarButton>
</Panel>
