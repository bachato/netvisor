<script lang="ts">
	import {
		type EdgeProps,
		getSmoothStepPath,
		BaseEdge,
		EdgeLabel,
		getBezierPath,
		getStraightPath,
		type Edge,
		EdgeReconnectAnchor
	} from '@xyflow/svelte';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import {
		selectedEdge as globalSelectedEdge,
		selectedNode as globalSelectedNode,
		selectedTopologyId,
		topologyOptions,
		useTopologiesQuery
	} from '../../queries';
	import { edgeTypes } from '$lib/shared/stores/metadata';
	import { createColorHelper, type Color } from '$lib/shared/utils/styling';
	import type { Topology, TopologyEdge } from '../../types/base';
	import {
		getEdgeDisplayState,
		edgeHoverState,
		groupHoverState,
		isExporting,
		tagHiddenNodeIds,
		hoveredEdgeType,
		toggleBundleExpanded
	} from '../../interactions';
	import { isOverlayEdge } from '../../layout/edge-classification';
	import type { Node, Edge as FlowEdge } from '@xyflow/svelte';

	let {
		id,
		sourceX,
		sourceY,
		sourcePosition,
		targetX,
		targetY,
		targetPosition,
		sourceHandleId,
		targetHandleId,
		label,
		data,
		interactionWidth
	}: EdgeProps = $props();

	// Use context topology if available (for share views), otherwise fall back to query data
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');

	// TanStack Query for topology data — disabled when topology context exists (share/embed views)
	const topologiesQuery = useTopologiesQuery(() => !topologyContext);
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let globalTopology = $derived(topologiesData.find((t) => t.id === $selectedTopologyId));
	let topology = $derived(topologyContext ? $topologyContext : globalTopology);

	// Try to get selection from context (for share/embed pages), fallback to global store
	const selectedNodeContext = getContext<Writable<Node | null> | undefined>('selectedNode');
	const selectedEdgeContext = getContext<Writable<FlowEdge | null> | undefined>('selectedEdge');
	let selectedNode = $derived(
		selectedNodeContext ? $selectedNodeContext : $globalSelectedNode
	) as Node | null;
	let selectedEdge = $derived(
		selectedEdgeContext ? $selectedEdgeContext : $globalSelectedEdge
	) as FlowEdge | null;

	const nodes = $derived(topology?.nodes ?? []);

	const edgeData = $derived(data as TopologyEdge | undefined);

	// Bundle detection
	const anyEdgeData = $derived(data as Record<string, unknown> | undefined);
	let isBundle = $derived(!!anyEdgeData?.isBundle);
	let bundleCount = $derived((anyEdgeData?.bundleCount as number) ?? 0);
	let bundleId = $derived((anyEdgeData?.bundleId as string) ?? '');
	let bundleStrokeWidth = $derived((anyEdgeData?.bundleStrokeWidth as number) ?? 2);
	let bundleIsOverlay = $derived(!!anyEdgeData?.bundleIsOverlay);
	let hasFanOffset = $derived(anyEdgeData?.bundleFanTotal != null);
	let fanIndex = $derived((anyEdgeData?.bundleFanIndex as number) ?? 0);
	let fanTotal = $derived((anyEdgeData?.bundleFanTotal as number) ?? 0);
	// Check if either endpoint is hidden by tag filter
	let isEndpointHiddenByTagFilter = $derived.by(() => {
		const hiddenNodes = $tagHiddenNodeIds;
		if (!edgeData) return false;
		return hiddenNodes.has(edgeData.source as string) || hiddenNodes.has(edgeData.target as string);
	});
	const edgeTypeMetadata = $derived(edgeData ? edgeTypes.getMetadata(edgeData.edge_type) : null);

	// Get group reactively - updates when groups store changes
	let group = $derived.by(() => {
		if (!topology?.groups || !edgeTypeMetadata || !edgeData) return null;
		if (edgeTypeMetadata.is_group_edge && 'group_id' in edgeData) {
			return topology.groups.find((g) => g.id == edgeData.group_id) || null;
		}
		return null;
	});

	let hideEdge = $derived(
		edgeData ? $topologyOptions.local.hide_edge_types.includes(edgeData.edge_type) : false
	);

	let isOverlay = $derived(isBundle ? bundleIsOverlay : edgeData ? isOverlayEdge(edgeData) : false);

	// Get display state from helper - Make reactive to hover stores
	let displayState = $derived.by(() => {
		// Subscribe to hover stores to trigger reactivity
		void $edgeHoverState;
		void $groupHoverState;

		if (!edgeData) {
			return { shouldShowFull: false, shouldAnimate: false };
		}

		// Create a minimal edge object for the helper
		const edge: Edge = {
			id,
			source: edgeData.source as string,
			target: edgeData.target as string,
			data: edgeData
		} as Edge;

		return getEdgeDisplayState(edge, selectedNode, selectedEdge);
	});

	let shouldShowFull = $derived(displayState.shouldShowFull);
	let isSelected = $derived(selectedEdge?.id === id);

	// Calculate edge color - use group color if available, otherwise use edge type color
	let edgeColorHelper = $derived.by(() => {
		if (group?.color) {
			return createColorHelper(group.color);
		}
		// Preview edges carry their own color since they have no real group
		const anyData = edgeData as Record<string, unknown> | undefined;
		if (anyData?.is_preview && anyData?.preview_color) {
			return createColorHelper(anyData.preview_color as Color);
		}
		if (!edgeData) {
			return createColorHelper('Gray');
		}
		return edgeTypes.getColorHelper(edgeData.edge_type);
	});

	// Determine if this edge should use the two-color dashed effect
	let isGroupEdge = $derived(edgeTypeMetadata?.is_group_edge ?? false);
	let isPreview = $derived(!!(edgeData as Record<string, unknown> | undefined)?.is_preview);
	let useMultiColorDash = $derived((isGroupEdge && shouldShowFull) || isPreview);

	// Edge type hover highlight
	let isEdgeTypeHovered = $derived(
		$hoveredEdgeType !== null && edgeData?.edge_type === $hoveredEdgeType.edgeType
	);
	let isAnotherEdgeTypeHovered = $derived($hoveredEdgeType !== null && !isEdgeTypeHovered);

	// Aggregated edge support
	let isAggregated = $derived(!!(edgeData as Record<string, unknown> | undefined)?.isAggregated);
	let aggregatedCount = $derived(
		((edgeData as Record<string, unknown> | undefined)?.aggregatedCount as number) ?? 1
	);

	// Calculate base edge properties
	let baseStrokeWidth = $derived.by(() => {
		if (isAggregated) return Math.min(2 + aggregatedCount, 8);
		if (isBundle) return bundleStrokeWidth;
		if (isEdgeTypeHovered) return 3;
		if (!$topologyOptions.local.no_fade_edges && (shouldShowFull || isPreview)) return 3;
		if (isOverlay) return 1.5;
		return 2;
	});
	let baseOpacity = $derived.by(() => {
		if ($isExporting) return 1;
		// Preview edges always full opacity
		if (isPreview) return 1;
		// Edge type hover: matching edges full opacity, non-matching fade
		if (isEdgeTypeHovered) return 1;
		if (isAnotherEdgeTypeHovered) return 0.2;
		// Fade if either endpoint is hidden by tag filter
		if (isEndpointHiddenByTagFilter) return 0.4;
		// Overlay edges: reduced opacity unless highlighted
		if (isOverlay && !shouldShowFull) return 0.5;
		// Fade based on selection state
		if (!$topologyOptions.local.no_fade_edges && !shouldShowFull) return 0.4;
		return 1;
	});
	// Labels stay fully visible unless there's an active selection causing edges to fade
	let labelOpacity = $derived.by(() => {
		if ($isExporting) return 1;
		if (isEdgeTypeHovered) return 1;
		if (isAnotherEdgeTypeHovered) return 0.2;
		if (isEndpointHiddenByTagFilter) return 0.4;
		if (!$topologyOptions.local.no_fade_edges && (selectedNode || selectedEdge) && !shouldShowFull)
			return 0.4;
		return 1;
	});

	// Calculate edge style for primary layer (dashed white overlay for group edges, or normal edge)
	let edgeStyle = $derived.by(() => {
		// For group edges with multi-color dash: white dashes
		// For non-group dashed edges: use standard 5 5 pattern with edge color
		let strokeColor = edgeColorHelper.rgb;
		let dashArray = '';

		const isDark =
			typeof document !== 'undefined' && document.documentElement.classList.contains('dark');
		if (useMultiColorDash && isSelected) {
			// Group edge currently selected
			strokeColor = isDark ? 'rgba(0, 0, 0, 0.4)' : 'rgba(255, 255, 255, 0.6)';
		} else if (useMultiColorDash && !isSelected) {
			// Other group edges, subtler highlight
			strokeColor = isDark ? 'rgba(0, 0, 0, 0.15)' : 'rgba(255, 255, 255, 0.4)';
		} else if (!isGroupEdge && isOverlay) {
			dashArray = 'stroke-dasharray: 6 3;';
		}

		return `stroke: ${strokeColor}; stroke-width: ${baseStrokeWidth}px; opacity: ${baseOpacity}; ${dashArray} transition: opacity 0.2s ease-in-out, stroke-width 0.2s ease-in-out;`;
	});

	// Calculate edge style for secondary solid layer (only for group edges when shown full)
	let solidBaseStyle = $derived.by(() => {
		if (!useMultiColorDash) return '';
		// Solid base color underneath the white dashes
		return `stroke: ${edgeColorHelper.rgb}; stroke-width: ${baseStrokeWidth}px; opacity: ${baseOpacity}; transition: opacity 0.2s ease-in-out, stroke-width 0.2s ease-in-out;`;
	});

	// Calculate dynamic offset for multi-hop edges
	function calculateDynamicOffset(isMultiHop: boolean): number {
		if (!isMultiHop) {
			return 20; // Default offset for single-hop
		}

		// Determine routing direction from edge handles
		const routingLeft = sourceHandleId == 'Left' || targetHandleId == 'Left';

		// Find the bounding box of the edge path
		const minX = Math.min(sourceX, targetX);
		const maxX = Math.max(sourceX, targetX);
		const minY = Math.min(sourceY, targetY);
		const maxY = Math.max(sourceY, targetY);

		let maxOutcrop = 0;

		// Check all nodes to find intermediate subnets
		for (const node of nodes) {
			// Skip if node is outside the vertical range of the edge
			if (node.position.y <= minY || node.position.y >= maxY) {
				continue;
			}

			// Check if this node is a subnet in the path
			if (node.node_type == 'ContainerNode') {
				const nodeLeft = node.position.x;
				const nodeRight = node.position.x + (node.size.x || 0);

				if (routingLeft) {
					// Check how far left this node extends beyond our leftmost point
					const outcrop = minX - nodeLeft;
					maxOutcrop = Math.max(maxOutcrop, outcrop);
				} else {
					// Check how far right this node extends beyond our rightmost point
					const outcrop = nodeRight - maxX;
					maxOutcrop = Math.max(maxOutcrop, outcrop);
				}
			}
		}

		// Return calculated offset with padding, or minimum offset
		const padding = 50;
		const minimumOffset = 100;
		return Math.max(minimumOffset, maxOutcrop + padding);
	}

	// Helper function to get the path calculation function based on edge style
	function getPathFunction(edge_style: string) {
		const isMultiHop = (edgeData?.is_multi_hop as boolean) || false;
		const offset = calculateDynamicOffset(isMultiHop);

		// Apply fan offset for expanded bundle edges
		let fanOffsetX = 0;
		let fanOffsetY = 0;
		if (hasFanOffset && fanTotal > 1) {
			const spacing = 8;
			const fanOffset = (fanIndex - (fanTotal - 1) / 2) * spacing;
			// Offset perpendicular to edge direction
			const dx = targetX - sourceX;
			const dy = targetY - sourceY;
			const len = Math.sqrt(dx * dx + dy * dy) || 1;
			// Perpendicular unit vector
			fanOffsetX = (-dy / len) * fanOffset;
			fanOffsetY = (dx / len) * fanOffset;
		}

		const basePathProperties = {
			sourceX: sourceX + fanOffsetX,
			sourceY: sourceY + fanOffsetY,
			sourcePosition,
			targetX: targetX + fanOffsetX,
			targetY: targetY + fanOffsetY,
			targetPosition
		};

		switch (edge_style) {
			case 'Straight':
				return getStraightPath(basePathProperties);
			case 'Smoothstep':
			case 'SmoothStep':
				return getSmoothStepPath({
					...basePathProperties,
					borderRadius: 10,
					offset
				});
			case 'Bezier':
			case 'SimpleBezier':
				return getBezierPath(basePathProperties);
			case 'Step':
				return getSmoothStepPath({
					...basePathProperties,
					borderRadius: 10,
					offset
				});
			default:
				return getSmoothStepPath({
					...basePathProperties,
					borderRadius: 10,
					offset
				});
		}
	}

	// Calculate edge path and label position - DRY approach
	let pathData = $derived.by(() => {
		// Use group edge_style if available, then preview edge style, otherwise edge type metadata
		const anyData = edgeData as Record<string, unknown> | undefined;
		const edge_style = group
			? group.edge_style
			: ((anyData?.preview_edge_style as string) ?? edgeTypeMetadata?.edge_style ?? 'SmoothStep');
		return getPathFunction(edge_style);
	});

	let edgePath = $derived(pathData[0]);
	let labelX = $derived(pathData[1]);
	let labelY = $derived(pathData[2]);

	let labelOffsetX = $state(0);
	let labelOffsetY = $state(0);
	let isDragging = $state(false);
	let dragStartX = 0;
	let dragStartY = 0;

	function onDragStart(event: DragEvent) {
		isDragging = true;
		dragStartX = event.clientX - labelOffsetX;
		dragStartY = event.clientY - labelOffsetY;
	}

	function onDrag(event: DragEvent) {
		if (event.clientX === 0 && event.clientY === 0) return; // Ignore end drag event
		labelOffsetX = event.clientX - dragStartX;
		labelOffsetY = event.clientY - dragStartY;
	}

	function onDragEnd() {
		isDragging = false;
	}

	let reconnecting = $state(false);
</script>

{#if edgeData}
	{#if isSelected}
		<EdgeReconnectAnchor
			bind:reconnecting
			type="source"
			position={{ x: sourceX, y: sourceY }}
			class={{}}
			style={!reconnecting
				? `background: ${edgeColorHelper.rgb}; border: 2px solid var(--color-border); border-radius: 100%; width: 12px; height: 12px;`
				: 'background: transparent; border: 2px solid var(--color-border); border-radius: 100%; width: 12px; height: 12px;'}
		/>
		<EdgeReconnectAnchor
			bind:reconnecting
			type="target"
			position={{ x: targetX, y: targetY }}
			style={!reconnecting
				? `background: ${edgeColorHelper.rgb}; border: 2px solid var(--color-border); border-radius: 100%; width: 12px; height: 12px;`
				: 'background: transparent; border: 2px solid var(--color-border); border-radius: 100%; width: 12px; height: 12px;'}
		/>
	{/if}

	{#if !hideEdge && !reconnecting}
		<!-- Solid base layer for group edges when shown full (rendered first, behind) -->
		{#if useMultiColorDash}
			<BaseEdge
				path={edgePath}
				style={solidBaseStyle}
				{id}
				interactionWidth={0}
				class="solid-base"
			/>
		{/if}

		<!-- Primary edge layer (white dashes for group edges when shown, normal for everything else) -->
		<BaseEdge
			path={edgePath}
			style={edgeStyle}
			{id}
			interactionWidth={interactionWidth || 20}
			class={useMultiColorDash ? 'dashed-overlay' : ''}
		/>

		{#if isBundle}
			<!-- Bundle count badge -->
			<EdgeLabel x={labelX} y={labelY} style="background: none; pointer-events: none;">
				<div
					class="nopan"
					style="background: {edgeColorHelper.rgb}; color: white; font-size: 11px; font-weight: 600; padding: 2px 6px; border-radius: 10px; cursor: pointer; pointer-events: auto; opacity: {labelOpacity}; transition: opacity 0.2s ease-in-out; user-select: none;"
					onclick={(e) => {
						e.stopPropagation();
						toggleBundleExpanded(bundleId);
					}}
					onkeydown={(e) => {
						if (e.key === 'Enter' || e.key === ' ') {
							e.preventDefault();
							toggleBundleExpanded(bundleId);
						}
					}}
					role="button"
					tabindex="0"
				>
					&times;{bundleCount}
				</div>
			</EdgeLabel>
		{:else if label}
			<EdgeLabel
				x={labelX + labelOffsetX}
				y={labelY + labelOffsetY}
				style="background: none; pointer-events: none;"
			>
				<div
					class="card text-secondary nopan"
					style="font-size: 12px; font-weight: 500; padding: 0.5rem 0.75rem; border-color: var(--color-border); cursor: {isDragging
						? 'grabbing'
						: 'grab'}; pointer-events: auto; opacity: {labelOpacity}; transition: opacity 0.2s ease-in-out;"
					draggable="true"
					role="button"
					tabindex="0"
					ondragstart={onDragStart}
					ondrag={onDrag}
					ondragend={onDragEnd}
				>
					{label}
				</div>
			</EdgeLabel>
		{/if}
	{/if}
{/if}

<style>
	/* Override SvelteFlow's animated behavior ONLY for our solid base layer - keep it solid */
	:global(.svelte-flow__edge.animated .svelte-flow__edge-path.solid-base) {
		stroke-dasharray: 0 !important;
		animation: none !important;
	}

	/* Let the dashed overlay use SvelteFlow's built-in animation */
</style>
