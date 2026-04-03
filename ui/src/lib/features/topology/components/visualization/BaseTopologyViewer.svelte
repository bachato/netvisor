<script lang="ts">
	import { writable, get } from 'svelte/store';
	import {
		SvelteFlow,
		Controls,
		MiniMap,
		Panel,
		Background,
		BackgroundVariant,
		type EdgeMarkerType,
		useNodesInitialized,
		type Connection,
		useSvelteFlow
	} from '@xyflow/svelte';
	import { Keyboard, Minimize2, Maximize2 } from 'lucide-svelte';
	import {
		topology_shortcutsTitle,
		topology_collapseAll,
		topology_expandAll,
		topology_connectionsCount
	} from '$lib/paraglide/messages';
	import { type Node, type Edge } from '@xyflow/svelte';
	import '@xyflow/svelte/dist/style.css';
	import { edgeTypes, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { pushError } from '$lib/shared/stores/feedback';
	import { previewEdges, selectedNodes, topologyOptions } from '../../queries';
	import { isExporting } from '../../interactions';

	// Import custom node/edge components
	import ContainerNode from './ContainerNode.svelte';
	import LeafNode from './LeafNode.svelte';
	import CustomEdge from './CustomEdge.svelte';
	import type { TopologyEdge, Topology } from '../../types/base';
	import { resolveLeafNode } from '../../resolvers';
	import { computeElkLayout, computeLeafNodeSizes } from '../../layout/elk-layout';
	import {
		collapsedContainers,
		collapseAll,
		expandAll,
		buildLeafToContainer,
		buildContainerChildCounts,
		computeCollapsedEdges
	} from '../../collapse';
	import {
		updateConnectedNodes,
		toggleEdgeHover,
		getEdgeDisplayState,
		expandedBundles,
		collapseAllBundles
	} from '../../interactions';
	import { bundleEdges } from '../../layout/edge-bundling';
	import { isOverlayEdge } from '../../layout/edge-classification';
	import { onMount, tick, setContext } from 'svelte';
	import { useQueryClient } from '@tanstack/svelte-query';
	import { writable as svelteWritable } from 'svelte/store';
	import { themeStore } from '$lib/shared/stores/theme.svelte';

	// Props
	export let topology: Topology;
	export let readonly: boolean = false;
	export let showControls: boolean = true;
	export let isEmbed: boolean = false;
	export let showBranding: boolean = false;
	export let showMinimap: boolean | undefined = undefined;

	// Create a context store for the topology so child nodes can access it
	const topologyContext = svelteWritable<Topology>(topology);
	setContext('topology', topologyContext);

	// Keep context in sync with prop
	$: topologyContext.set(topology);

	// Selection state - can be bound by parent
	export let selectedNode: Node | null = null;
	export let selectedEdge: Edge | null = null;

	// Optional callbacks for editing
	export let onNodeDragStop: ((node: Node) => void) | null = null;
	export let onReconnect: ((edge: Edge, newConnection: Connection) => void) | null = null;

	// Optional callbacks for selection changes
	export let onNodeSelect: ((node: Node | null, event?: MouseEvent | TouchEvent) => void) | null =
		null;
	export let onEdgeSelect: ((edge: Edge | null) => void) | null = null;
	export let onPaneSelect: ((event?: MouseEvent, wasPanning?: boolean) => void) | null = null;
	export let onSelectionChange: ((nodes: Node[], edges: Edge[]) => void) | null = null;
	export let onOpenShortcuts: (() => void) | null = null;

	// Track viewport panning state
	let viewportMoved = false;
	let viewportMoveTimer: ReturnType<typeof setTimeout> | null = null;

	const { fitView, getNodes } = useSvelteFlow();
	const queryClient = useQueryClient();
	let containerElement: HTMLDivElement;

	export function triggerFitView() {
		requestAnimationFrame(() => fitView({ padding: 0.2 }));
	}

	export function fitViewToNodes(nodeIds: string[]) {
		requestAnimationFrame(() =>
			fitView({ nodes: nodeIds.map((id) => ({ id })), padding: 0.5, duration: 300 })
		);
	}

	onMount(() => {
		const { fitView } = useSvelteFlow();

		const observer = new IntersectionObserver(
			(entries) => {
				if (entries[0].isIntersecting) {
					requestAnimationFrame(() => fitView());
					observer.disconnect();
				}
			},
			{ threshold: 0.1 }
		);

		if (containerElement) {
			observer.observe(containerElement);
		}

		return () => observer.disconnect();
	});

	// Define node types
	const nodeTypes = {
		ContainerNode: ContainerNode,
		LeafNode: LeafNode
	};

	const customEdgeTypes = {
		custom: CustomEdge
	};

	// Stores for SvelteFlow
	let nodes = writable<Node[]>([]);
	let edges = writable<Edge[]>([]);

	// Hook to check when nodes are initialized
	const nodesInitialized = useNodesInitialized();

	// Store pending edges until nodes are ready
	let pendingEdges: Edge[] = [];

	// Track ELK layout — only skip within same session when structure unchanged
	let cachedLayoutResult: import('../../layout/elk-layout').ElkLayoutResult | null = null;
	let sessionStructureKey = '';

	function getStructureKey(topo: Topology): string {
		return `${topo.nodes.length}:${topo.edges.length}:${topo.nodes
			.map((n) => n.id)
			.sort()
			.join(',')}`;
	}

	// Clear expanded bundles when bundling is toggled off
	$: if (!$topologyOptions.local.bundle_edges) {
		collapseAllBundles();
	}

	// Load topology data when it changes, collapse state changes, or bundle state changes
	$: if (topology && (topology.edges || topology.nodes)) {
		void $collapsedContainers;
		void $expandedBundles;
		void $topologyOptions.local.bundle_edges;
		void loadTopologyData();
	}

	// Update edges when selection changes
	$: {
		void selectedNode;
		void selectedEdge;
		void $selectedNodes;

		if (topology && (topology.edges || topology.nodes)) {
			const currentEdges = get(edges);
			const currentNodes = get(nodes);
			const multiSelected = get(selectedNodes);
			updateConnectedNodes(
				selectedNode,
				selectedEdge,
				currentEdges,
				currentNodes,
				queryClient,
				topology,
				multiSelected
			);

			// Update edge animated state based on selection
			const updatedEdges = currentEdges.map((edge) => {
				const { shouldAnimate } = getEdgeDisplayState(edge, selectedNode, selectedEdge);

				return {
					...edge,
					id: edge.id, // Force new reference
					animated: shouldAnimate
				};
			});

			edges.set(updatedEdges);
		}
	}

	// Add edges when nodes are ready
	$: if (nodesInitialized.current && pendingEdges.length > 0) {
		edges.set(pendingEdges);
		pendingEdges = [];
	}

	async function loadTopologyData() {
		try {
			if (topology && (topology.edges || topology.nodes)) {
				const collapsed = get(collapsedContainers);
				const leafToContainer = buildLeafToContainer(topology.nodes);
				const childCounts = buildContainerChildCounts(topology.nodes);
				const hiddenEdgeTypes = $topologyOptions.local.hide_edge_types ?? [];

				// Compute aggregated edges for collapsed containers
				const aggregatedEdges = computeCollapsedEdges(
					topology.edges,
					collapsed,
					leafToContainer,
					hiddenEdgeTypes
				);

				// Filter out leaf nodes inside collapsed containers
				const visibleNodes = topology.nodes.filter((node) => {
					if (node.node_type === 'LeafNode') {
						const parentId = leafToContainer.get(node.id);
						if (parentId && collapsed.has(parentId)) return false;
					}
					return true;
				});

				// Run ELK on structure/collapse changes, skip for edge-only re-renders
				const opts = get(topologyOptions);
				const sizeKey = `${(opts.request.hide_service_categories ?? []).join(',')}:${opts.request.hide_ports}`;
				const structureKey =
					getStructureKey(topology) + ':' + Array.from(collapsed).sort().join(',') + ':' + sizeKey;
				const isNewStructure = sessionStructureKey !== structureKey;

				if (isNewStructure) {
					const leafNodeSizes = computeLeafNodeSizes(
						visibleNodes,
						topology,
						opts.request.hide_service_categories ?? [],
						opts.request.hide_ports ?? false,
						(sd) => serviceDefinitions.getCategory(sd)
					);
					cachedLayoutResult = await computeElkLayout({
						nodes: visibleNodes,
						edges: topology.edges,
						topology: topology,
						collapsedContainers: collapsed,
						leafNodeSizes
					});
					sessionStructureKey = structureKey;
				}

				const layoutResult = cachedLayoutResult ?? {
					nodePositions: new Map(),
					containerSizes: new Map(),
					leafNodeSizes: new Map(),
					edgeHandles: new Map()
				};

				// Save current state before rebuilding
				const currentEdges = get(edges);
				const animatedStates = new Map(currentEdges.map((edge) => [edge.id, edge.animated]));

				// Get live @xyflow positions (includes ELK layout + user drags)
				// getNodes() returns actual rendered state, not the stale store value
				const liveNodes = getNodes();
				const currentPositions = new Map(liveNodes.map((n) => [n.id, n.position]));
				const currentSizes = new Map(
					// eslint-disable-next-line @typescript-eslint/no-explicit-any -- @xyflow Node has runtime .computed not in type defs
					(liveNodes as Record<string, any>[]).map((n) => [
						n.id,
						{
							width: n.computed?.width ?? n.width,
							height: n.computed?.height ?? n.height
						}
					])
				);

				const allNodes: Node[] = visibleNodes.map((node) => {
					const isCollapsed = collapsed.has(node.id);

					// Position priority: ELK (if new structure) > current @xyflow > server
					let position: { x: number; y: number };
					let width: number;
					let height: number;

					if (isNewStructure) {
						const elkPos = layoutResult.nodePositions.get(node.id);
						const elkSize = layoutResult.containerSizes.get(node.id);
						const leafSize = layoutResult.leafNodeSizes.get(node.id);
						position = elkPos ?? { x: node.position.x, y: node.position.y };
						width = isCollapsed ? 200 : (elkSize?.width ?? leafSize?.x ?? node.size.x);
						height = isCollapsed ? 80 : (elkSize?.height ?? leafSize?.y ?? node.size.y);
					} else {
						const curPos = currentPositions.get(node.id);
						const curSize = currentSizes.get(node.id);
						position = curPos ?? { x: node.position.x, y: node.position.y };
						width = isCollapsed ? 200 : (curSize?.width ?? node.size.x);
						height = isCollapsed ? 80 : (curSize?.height ?? node.size.y);
					}

					return {
						id: node.id,
						type: node.node_type,
						position,
						width,
						height,
						expandParent: true,
						deletable: false,
						selectable: node.node_type !== 'ContainerNode',
						parentId:
							node.node_type == 'LeafNode'
								? (node.container_id ?? resolveLeafNode(node.id, node, topology).subnetId)
								: node.node_type == 'ContainerNode' && node.parent_container_id
									? (node.parent_container_id as string)
									: undefined,
						extent: node.node_type == 'LeafNode' ? 'parent' : undefined,
						data: isCollapsed
							? { ...node, isCollapsed: true, childCount: childCounts.get(node.id) ?? 0 }
							: node
					};
				});

				// Clear edges FIRST
				edges.set([]);

				// Sort so parents appear before children (SvelteFlow requirement).
				// Depth: 0 = root containers, 1 = sub-group containers, 2 = leaves
				const depthOf = (n: (typeof allNodes)[number]) => {
					if (!n.parentId) return 0;
					if (n.type === 'ContainerNode') return 1;
					// Leaf inside sub-group = depth 2, leaf inside subnet = depth 1
					return allNodes.some((p) => p.id === n.parentId && p.parentId) ? 2 : 1;
				};
				const sortedNodes = allNodes.sort((a, b) => depthOf(a) - depthOf(b));

				// Set nodes
				nodes.set(sortedNodes);

				// Build base edges: filter out edges with collapsed endpoints
				let baseEdges: TopologyEdge[];
				const extraFlowEdges: Edge[] = [];

				if (collapsed.size > 0 && aggregatedEdges.length > 0) {
					// Filter out edges where source or target is inside a collapsed container
					baseEdges = topology.edges.filter((edge) => {
						const srcContainer = leafToContainer.get(edge.source as string);
						const tgtContainer = leafToContainer.get(edge.target as string);
						const srcCollapsed = srcContainer && collapsed.has(srcContainer);
						const tgtCollapsed = tgtContainer && collapsed.has(tgtContainer);
						return !srcCollapsed && !tgtCollapsed;
					});

					// Create aggregated flow edges for collapsed containers
					for (let index = 0; index < aggregatedEdges.length; index++) {
						const agg = aggregatedEdges[index];
						const edgeKey = `${agg.source}->${agg.target}`;
						const handles = layoutResult.edgeHandles.get(edgeKey);
						extraFlowEdges.push({
							id: agg.id,
							source: agg.source,
							target: agg.target,
							sourceHandle: (handles?.sourceHandle ?? 'Bottom').toString(),
							targetHandle: (handles?.targetHandle ?? 'Top').toString(),
							type: 'custom',
							label: agg.count > 1 ? topology_connectionsCount({ count: agg.count }) : undefined,
							data: {
								...agg.originalEdges[0],
								isAggregated: true,
								aggregatedCount: agg.count,
								edgeIndex: 1000 + index
							},
							animated: false,
							interactionWidth: 50
						});
					}
				} else {
					// No collapsed containers — all edges are base edges
					baseEdges = topology.edges;
				}

				// Filter visible edges (hidden types excluded before bundling)
				const visibleEdges = baseEdges.filter((e) => !hiddenEdgeTypes.includes(e.edge_type));

				let flowEdges: Edge[];
				const currentExpandedBundles = get(expandedBundles);

				if ($topologyOptions.local.bundle_edges) {
					const { bundles, unbundled } = bundleEdges(visibleEdges, leafToContainer);
					flowEdges = [];
					let edgeIndex = 0;

					// Unbundled edges render normally
					for (const edge of unbundled) {
						flowEdges.push(createFlowEdge(edge, edgeIndex++, layoutResult, animatedStates));
					}

					for (const bundle of bundles) {
						if (currentExpandedBundles.has(bundle.id)) {
							// Expanded: render individual edges with fan offset
							const fanTotal = bundle.edges.length;
							for (let i = 0; i < fanTotal; i++) {
								flowEdges.push(
									createFlowEdge(bundle.edges[i], edgeIndex++, layoutResult, animatedStates, {
										bundleId: bundle.id,
										bundleFanIndex: i,
										bundleFanTotal: fanTotal
									})
								);
							}
						} else {
							// Collapsed: render single bundle edge
							const representative = bundle.edges[0];
							const bundleStrokeWidth = Math.min(2 + 0.5 * (bundle.count - 1), 6);
							flowEdges.push(
								createFlowEdge(representative, edgeIndex++, layoutResult, animatedStates, {
									isBundle: true,
									bundleId: bundle.id,
									bundleCount: bundle.count,
									bundleEdges: bundle.edges,
									bundleStrokeWidth,
									bundleIsOverlay: isOverlayEdge(representative)
								})
							);
						}
					}
				} else {
					// Bundling disabled: render all visible edges individually
					flowEdges = visibleEdges.map((edge, index) =>
						createFlowEdge(edge, index, layoutResult, animatedStates)
					);
				}

				// Add hidden edges (they get filtered by CustomEdge's hideEdge logic)
				const hiddenEdges = baseEdges.filter((e) => hiddenEdgeTypes.includes(e.edge_type));
				for (const edge of hiddenEdges) {
					flowEdges.push(createFlowEdge(edge, flowEdges.length, layoutResult, animatedStates));
				}

				// Add aggregated collapse edges
				flowEdges.push(...extraFlowEdges);

				pendingEdges = flowEdges;

				// Wait for nodes to render, then set edges
				await tick();
				if (pendingEdges.length > 0) {
					edges.set(pendingEdges);
					pendingEdges = [];
				}
			}
		} catch (err) {
			pushError(`Failed to parse topology data ${err}`);
		}
	}

	function createFlowEdge(
		edge: TopologyEdge,
		index: number,
		layoutResult: import('../../layout/elk-layout').ElkLayoutResult,
		animatedStates: Map<string, boolean | undefined>,
		extraData?: Record<string, unknown>
	): Edge {
		const edgeType = edge.edge_type as string;
		const edgeMetadata = edgeTypes.getMetadata(edgeType);
		const edgeColorHelper = edgeTypes.getColorHelper(edgeType);

		const markerStart = !edgeMetadata.has_start_marker
			? undefined
			: ({
					type: 'arrow',
					color: edgeColorHelper.rgb
				} as EdgeMarkerType);
		const markerEnd = !edgeMetadata.has_end_marker
			? undefined
			: ({
					type: 'arrow',
					color: edgeColorHelper.rgb
				} as EdgeMarkerType);

		const edgeId = `edge-${index}`;

		return {
			id: edgeId,
			source: edge.source,
			target: edge.target,
			markerEnd,
			markerStart,
			sourceHandle: (
				layoutResult.edgeHandles.get(`${edge.source}->${edge.target}`)?.sourceHandle ??
				edge.source_handle
			).toString(),
			targetHandle: (
				layoutResult.edgeHandles.get(`${edge.source}->${edge.target}`)?.targetHandle ??
				edge.target_handle
			).toString(),
			type: 'custom',
			label: edge.label ?? undefined,
			data: { ...edge, edgeIndex: index, ...extraData },
			animated: animatedStates.get(edgeId) ?? false,
			interactionWidth: 50
		};
	}

	function handleNodeDragStop({
		targetNode
	}: {
		targetNode: Node | null;
		nodes: Node[];
		event: MouseEvent | TouchEvent;
	}) {
		if (onNodeDragStop && targetNode) {
			onNodeDragStop(targetNode);
		}
	}

	function handleReconnect(edge: Edge, newConnection: Connection) {
		if (onReconnect) {
			onReconnect(edge, newConnection);
		}
	}

	function handleNodeClick({ node, event }: { node: Node; event: MouseEvent | TouchEvent }) {
		const isModifierClick = event instanceof MouseEvent && (event.ctrlKey || event.metaKey);

		if (!isModifierClick) {
			selectedNode = node;
			selectedEdge = null;
			collapseAllBundles();
		}
		if (onNodeSelect) {
			onNodeSelect(node, event);
		}
	}

	function handleEdgeClick({ edge }: { edge: Edge; event: MouseEvent }) {
		selectedEdge = edge;
		selectedNode = null;
		collapseAllBundles();
		if (onEdgeSelect) {
			onEdgeSelect(edge);
		}
	}

	function handleMove() {
		viewportMoved = true;
		if (viewportMoveTimer) {
			clearTimeout(viewportMoveTimer);
			viewportMoveTimer = null;
		}
	}

	function handleMoveEnd() {
		// Delay clearing the flag so it's still set when onpaneclick fires
		viewportMoveTimer = setTimeout(() => {
			viewportMoved = false;
		}, 50);
	}

	function handlePaneClick({ event }: { event: MouseEvent }) {
		collapseAllBundles();
		selectedEdge = null;
		if (!viewportMoved) {
			selectedNode = null;
		}
		if (onPaneSelect) {
			onPaneSelect(event, viewportMoved);
		}
		// Reset immediately after handling
		viewportMoved = false;
		if (viewportMoveTimer) {
			clearTimeout(viewportMoveTimer);
			viewportMoveTimer = null;
		}
	}

	function handleEdgeHover({ edge }: { edge: Edge }) {
		const currentEdges = get(edges);
		toggleEdgeHover(edge, currentEdges);

		// Update animated state for all edges after hover toggle
		const updatedEdges = currentEdges.map((e) => {
			const { shouldAnimate } = getEdgeDisplayState(e, selectedNode, selectedEdge);

			return {
				...e,
				id: e.id,
				animated: shouldAnimate
			};
		});

		edges.set(updatedEdges);
	}

	function handleSelectionChange({ nodes: selNodes }: { nodes: Node[]; edges: Edge[] }) {
		if (onSelectionChange) {
			onSelectionChange(selNodes, []);
		}
	}

	function handleCollapseAll() {
		const containerIds = topology.nodes
			.filter((n) => n.node_type === 'ContainerNode')
			.map((n) => n.id);
		collapseAll(containerIds);
		setTimeout(() => fitView({ padding: 0.2, duration: 300 }), 100);
	}

	function handleExpandAll() {
		expandAll();
		setTimeout(() => fitView({ padding: 0.2, duration: 300 }), 100);
	}

	// Merge preview edges into the edge store when they change
	$: {
		const preview = $previewEdges;
		if (preview.length > 0) {
			const currentEdges = get(edges);
			// Remove old preview edges, add new ones
			const realEdges = currentEdges.filter((e) => !e.id.startsWith('preview-'));
			edges.set([...realEdges, ...preview]);
		} else {
			const currentEdges = get(edges);
			const hasPreview = currentEdges.some((e) => e.id.startsWith('preview-'));
			if (hasPreview) {
				edges.set(currentEdges.filter((e) => !e.id.startsWith('preview-')));
			}
		}
	}
</script>

<div
	class="h-full w-full overflow-hidden !p-0"
	class:card={!isEmbed}
	class:card-static={!isEmbed}
	bind:this={containerElement}
>
	<SvelteFlow
		nodes={$nodes}
		edges={$edges}
		{nodeTypes}
		edgeTypes={customEdgeTypes}
		onpaneclick={handlePaneClick}
		onedgeclick={handleEdgeClick}
		onnodeclick={handleNodeClick}
		onedgepointerenter={handleEdgeHover}
		onedgepointerleave={handleEdgeHover}
		onnodedragstop={readonly ? undefined : handleNodeDragStop}
		onreconnect={readonly ? undefined : handleReconnect}
		onselectionchange={handleSelectionChange}
		onmove={handleMove}
		onmoveend={handleMoveEnd}
		fitView={true}
		minZoom={0.1}
		noPanClass="nopan"
		snapGrid={[25, 25]}
		nodesDraggable={!readonly}
		nodesConnectable={!readonly}
		elementsSelectable={true}
		selectionOnDrag={true}
		selectionKey="Shift"
		panOnDrag={true}
		zoomOnScroll={true}
	>
		<Background
			variant={BackgroundVariant.Dots}
			bgColor="var(--color-topology-bg)"
			gap={50}
			size={1}
		/>

		{#if showControls}
			<Panel position="top-right" class="!m-[10px] !flex !flex-col !items-center !gap-2 !p-0">
				<div
					class="flex flex-col gap-0.5 rounded !border !border-gray-300 !bg-white !shadow-lg dark:!border-gray-600 dark:!bg-gray-800"
				>
					<button
						class="flex items-center justify-center rounded-t p-1.5 !text-gray-700 hover:!bg-gray-100 dark:!text-gray-100 dark:hover:!bg-gray-600"
						onclick={handleCollapseAll}
						title={topology_collapseAll()}
					>
						<Minimize2 class="h-4 w-4" />
					</button>
					<button
						class="flex items-center justify-center rounded-b p-1.5 !text-gray-700 hover:!bg-gray-100 dark:!text-gray-100 dark:hover:!bg-gray-600"
						onclick={handleExpandAll}
						title={topology_expandAll()}
					>
						<Maximize2 class="h-4 w-4" />
					</button>
				</div>
				{#if onOpenShortcuts}
					<button
						class="flex items-center justify-center rounded !border !border-gray-300 !bg-gray-50 p-1.5 !text-gray-700 !shadow-lg hover:!bg-gray-100 dark:!border-gray-600 dark:!bg-gray-700 dark:!text-gray-100 dark:hover:!bg-gray-600"
						onclick={onOpenShortcuts}
						title={topology_shortcutsTitle()}
					>
						<Keyboard class="h-4 w-4" />
					</button>
				{/if}
				<Controls
					showZoom={true}
					showFitView={true}
					showLock={false}
					class="!static !m-0 !rounded !border !border-gray-300 !bg-white !shadow-lg dark:!border-gray-600 dark:!bg-gray-800 [&_button:hover]:!bg-gray-100 dark:[&_button:hover]:!bg-gray-600 [&_button]:!border-gray-300 [&_button]:!bg-gray-50 [&_button]:!text-gray-700 dark:[&_button]:!border-gray-600 dark:[&_button]:!bg-gray-700 dark:[&_button]:!text-gray-100"
				/>
			</Panel>
		{/if}

		{#if (showMinimap !== undefined ? showMinimap : $topologyOptions.local.show_minimap) && !$isExporting}
			<MiniMap
				position="bottom-left"
				bgColor={themeStore.resolvedTheme === 'dark' ? '#1f2937' : '#ffffff'}
				nodeColor={themeStore.resolvedTheme === 'dark' ? '#6b7280' : '#9ca3af'}
				maskColor={themeStore.resolvedTheme === 'dark'
					? 'rgba(17, 24, 39, 0.7)'
					: 'rgba(243, 244, 246, 0.7)'}
				maskStrokeColor={themeStore.resolvedTheme === 'dark' ? '#374151' : '#d1d5db'}
			/>
		{/if}

		{#if showBranding}
			<a
				href="https://scanopy.net?utm_source={isEmbed
					? 'embed'
					: 'share'}&utm_medium=referral&utm_campaign=created_with"
				target="_blank"
				rel="noopener noreferrer"
				class="branding-badge"
			>
				<img src="/logos/scanopy-logo.png" alt="Scanopy" class="h-4 w-4" />
				<span>Created with Scanopy</span>
			</a>
		{/if}
	</SvelteFlow>
</div>

<style>
	:global(.svelte-flow__attribution) {
		background: transparent;
		color: var(--color-text-disabled);
		font-size: 10px;
	}

	:global(.svelte-flow__attribution.bottom) {
		bottom: 10px;
		right: 10px;
	}

	:global(.svelte-flow__attribution a) {
		color: var(--color-text-disabled);
	}

	:global(.svelte-flow__attribution a:hover) {
		color: var(--color-text-muted);
	}

	.branding-badge {
		position: absolute;
		bottom: 10px;
		right: 10px;
		display: flex;
		align-items: center;
		gap: 6px;
		color: var(--color-text-muted);
		font-size: 12px;
		text-decoration: none;
		z-index: 5;
		transition: color 0.2s;
	}

	.branding-badge:hover {
		color: var(--color-text-secondary);
	}

	:global(.hide-for-export .svelte-flow__attribution) {
		opacity: 0;
	}

	:global(.hide-for-export .svelte-flow__controls) {
		opacity: 0;
	}

	:global(.hide-for-export .svelte-flow__panel.top.right) {
		opacity: 0;
	}

	:global(.hide-for-export .svelte-flow__node *) {
		transition: none !important;
	}

	:global(.hide-for-export .svelte-flow__minimap) {
		opacity: 0;
	}

	:global(.hide-for-export .svelte-flow__resize-control) {
		opacity: 0;
	}

	:global(.hide-for-export .branding-badge) {
		opacity: 0;
	}

	/* Force full opacity on all nodes during export to disable focus effect */
	:global(.hide-for-export .svelte-flow__node .card) {
		opacity: 1 !important;
		transition: none !important;
	}

	:global(.hide-for-export .svelte-flow__node > .relative) {
		opacity: 1 !important;
		transition: none !important;
	}
</style>
