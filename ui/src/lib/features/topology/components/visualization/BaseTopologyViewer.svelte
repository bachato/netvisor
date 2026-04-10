<script lang="ts">
	import { writable, derived, get, type Writable } from 'svelte/store';
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
	import { Keyboard, Expand, Shrink, PencilOff, Pencil } from 'lucide-svelte';
	import {
		topology_shortcutsTitle,
		topology_collapseLevelDown,
		topology_expandLevelUp,
		topology_connectionsCount,
		topology_viewModeTooltip,
		topology_editModeTooltip,
		topology_levelFullyCollapsed,
		topology_levelContainersExpanded,
		topology_levelSubcontainersExpanded,
		topology_levelFullyExpanded,
		common_edit,
		common_shortcuts
	} from '$lib/paraglide/messages';
	import TopologySidebarButton from './TopologySidebarButton.svelte';
	import { type Node, type Edge } from '@xyflow/svelte';
	import '@xyflow/svelte/dist/style.css';
	import { edgeTypes, containerTypes } from '$lib/shared/stores/metadata';
	import { pushError } from '$lib/shared/stores/feedback';
	import {
		previewEdges,
		selectedNodes,
		selectedEdge as selectedEdgeStore,
		selectedNode as selectedNodeStore,
		topologyOptions,
		activeView,
		optionsPanelExpanded,
		OPTIONS_PANEL_FITVIEW_PADDING_PX,
		aggregatedEdgeOriginals,
		getInfrastructureRuleId
	} from '../../queries';
	import { isExporting, expandedPortNodeIds } from '../../interactions';
	import { LayoutGraph } from '../../layout/layout-graph';

	// Import custom node/edge components
	import ContainerNode from './ContainerNode.svelte';
	import ElementNode from './ElementNode.svelte';
	import CustomEdge from './CustomEdge.svelte';
	import type { TopologyEdge, Topology } from '../../types/base';
	import { resolveElementNode } from '../../resolvers';
	import { ElkLayoutEngine } from '../../layout/engine';
	import {
		collapsedContainers,
		collapseLevel,
		stepExpand,
		stepCollapse,
		inferCurrentLevel,
		getAutoCollapseIds,
		buildElementToContainer,
		computeCollapsedEdges
	} from '../../collapse';
	import type { CollapseLevel } from '../../collapse';
	import {
		updateConnectedNodes,
		setEdgeHover,
		getEdgeDisplayState,
		clearEdgeHoverState,
		expandedBundles,
		collapseAllBundles,
		searchHiddenNodeIds,
		tagHiddenNodeIds
	} from '../../interactions';
	import {
		selectNode,
		selectEdge,
		clearSelection,
		handleModifierNodeClick,
		handleBoxSelect,
		type SelectionStores
	} from '../../selection';
	import { bundleEdges } from '../../layout/edge-bundling';
	import { elevateEdgesToContainers } from '../../layout/edge-elevation';
	import { computeForceLayout, type ForceNode, type ForceLink } from '../../layout/force-layout';
	import { computeOptimalHandles } from '../../layout/elk-layout';
	import { isDisabledEdge, isDashedEdge } from '../../layout/edge-classification';
	import { onMount, tick, setContext, getContext } from 'svelte';
	import { installLayoutDiagnostic } from '../../layout/layout-diagnostic';
	import { useQueryClient } from '@tanstack/svelte-query';
	import { writable as svelteWritable } from 'svelte/store';
	import { themeStore } from '$lib/shared/stores/theme.svelte';

	const layoutEngine = new ElkLayoutEngine();

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

	// Optional callbacks for editing
	export let onNodeDragStop: ((node: Node) => void) | null = null;
	export let onReconnect: ((edge: Edge, newConnection: Connection) => void) | null = null;

	// Optional callback for shortcuts overlay
	export let onOpenShortcuts: (() => void) | null = null;

	// Edit mode toggle
	export let editMode: boolean = false;
	export let onToggleEditMode: (() => void) | null = null;

	// Sidebar buttons collapse to icon-only after a brief delay
	export let sidebarCollapsed: boolean = false;

	// Resolve selection stores from context (share/embed) or fall back to global stores.
	// These are the SINGLE source of truth for selection state.
	const selNodeStore = getContext<Writable<Node | null>>('selectedNode') ?? selectedNodeStore;
	const selEdgeStore = getContext<Writable<Edge | null>>('selectedEdge') ?? selectedEdgeStore;
	const selNodesStore = getContext<Writable<Node[]>>('selectedNodes') ?? selectedNodes;
	const selectionStores: SelectionStores = {
		selectedNode: selNodeStore,
		selectedEdge: selEdgeStore,
		selectedNodes: selNodesStore
	};

	// Track viewport panning state
	let viewportMoved = false;
	let viewportMoveTimer: ReturnType<typeof setTimeout> | null = null;

	const { fitView, getNodes } = useSvelteFlow();

	/** Returns fitView padding that accounts for the options panel overlay. */
	function getFitViewPadding(): import('@xyflow/system').Padding {
		if (get(optionsPanelExpanded)) {
			return { top: 0.2, right: 0.2, bottom: 0.2, left: `${OPTIONS_PANEL_FITVIEW_PADDING_PX}px` };
		}
		return 0.2;
	}
	const queryClient = useQueryClient();
	let containerElement: HTMLDivElement;

	export function triggerFitView() {
		requestAnimationFrame(() => fitView({ padding: getFitViewPadding() }));
	}

	export function fitViewToNodes(nodeIds: string[]) {
		requestAnimationFrame(() =>
			fitView({ nodes: nodeIds.map((id) => ({ id })), padding: 0.5, duration: 300 })
		);
	}

	onMount(() => {
		installLayoutDiagnostic();
		// Expose layout state for the diagnostic to access
		(window as Record<string, unknown>).__scanopyLayoutState = {
			getNodes,
			getLayoutGraph: () => layoutGraph
		};
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
		Container: ContainerNode,
		Element: ElementNode
	};

	const customEdgeTypes = {
		custom: CustomEdge
	};

	// Refit viewport when panel expands/collapses (after 300ms CSS transition)
	let panelInitialized = false;
	$: if ($optionsPanelExpanded !== undefined) {
		if (panelInitialized) {
			setTimeout(() => fitView({ padding: getFitViewPadding() }), 300);
		}
		panelInitialized = true; // eslint-disable-line no-useless-assignment -- read on next reactive trigger
	}

	// Stores for SvelteFlow
	let nodes = writable<Node[]>([]);
	let edges = writable<Edge[]>([]);

	// Hook to check when nodes are initialized
	const nodesInitialized = useNodesInitialized();

	// Store pending edges until nodes are ready
	let pendingEdges: Edge[] = [];

	// Track ELK layout — only skip within same session when structure unchanged
	let layoutGraph: LayoutGraph | null = null;
	let sessionStructureKey = '';
	// eslint-disable-next-line svelte/prefer-svelte-reactivity -- internal cache, not rendered
	let seenAutoCollapseIds = new Set<string>();
	let collapseLevelInferred = false;
	let lastSeenTopologyId = '';
	let isMeasuring = false;
	let layoutGeneration = 0;
	let prevExpandedPortIds = new Set<string>();
	let prevView = get(activeView);
	let lastRenderedTopoKey = '';
	let lastRenderedView = '';
	let fitViewPending = false;
	let edgeHandles: Map<string, import('../../layout/elk-layout').EdgeHandles> = new Map();
	// Cache measured node sizes per (view, topology) so return visits skip the measurement pass.
	// Keyed by `${view}:${topologyId}` so switching topologies uses separate cache entries.
	// Cleared on topology rebuild since node sizes/content may have changed.
	// eslint-disable-next-line svelte/prefer-svelte-reactivity -- internal cache, not rendered
	const viewSizeCache = new Map<string, Map<string, { x: number; y: number }>>();

	function getStructureKey(topo: Topology): string {
		// Include container assignments so membership changes (element rules) trigger re-layout
		const nodeKeys = topo.nodes
			.map((n) => {
				const parentId = n.node_type === 'Element' ? n.container_id : n.parent_container_id;
				return `${n.id}@${parentId ?? ''}`;
			})
			.sort()
			.join(',');
		return `${topo.nodes.length}:${topo.edges.length}:${nodeKeys}`;
	}

	// Clear expanded bundles when bundling is toggled off
	$: if (!$topologyOptions.local.bundle_edges) {
		collapseAllBundles();
	}

	// Load topology data when it changes, collapse state changes, bundle state changes, or port expansion changes
	// Read layout-relevant options imperatively inside loadTopologyData instead
	// of reactively in the $: block. This prevents category/tag filter changes
	// (which only affect visual state) from triggering a full loadTopologyData.
	// We use dedicated stores for the two options that DO affect layout.
	const bundleEdgesStore = derived(topologyOptions, (o) => o.local.bundle_edges ?? false);
	const hideEdgeTypesStore = derived(topologyOptions, (o) =>
		(o.local.hide_edge_types ?? []).join(',')
	);

	$: if (topology && (topology.edges || topology.nodes)) {
		void $collapsedContainers;
		void $expandedBundles;
		void $expandedPortNodeIds;
		void $bundleEdgesStore;
		void $hideEdgeTypesStore;
		void loadTopologyData();
	}

	// Update edges when selection or search/tag filter changes — stores are the single source of truth
	$: {
		const curSelectedNode = $selNodeStore;
		const curSelectedEdge = $selEdgeStore;
		const multiSelected = $selNodesStore;
		// Reactive subscriptions — block re-runs when search or tag filter changes
		const searchHidden = $searchHiddenNodeIds;
		const tagHidden = $tagHiddenNodeIds;

		if (topology && (topology.edges || topology.nodes)) {
			const currentEdges = get(edges);
			const currentNodes = get(nodes);
			// Read hide_edge_types imperatively to avoid making this $: block
			// depend on $topologyOptions (which would cause a race with the
			// loadTopologyData block that also depends on it).
			const opts = get(topologyOptions);

			updateConnectedNodes(
				curSelectedNode,
				curSelectedEdge,
				currentEdges,
				currentNodes,
				queryClient,
				topology,
				multiSelected,
				opts.local.hide_edge_types ?? []
			);

			const hasActiveSelection = !!(curSelectedNode || curSelectedEdge);
			const updatedEdges = currentEdges.map((edge) => {
				const { shouldAnimate, shouldShowFull, isEndpointSearchHidden, isEndpointTagHidden } =
					getEdgeDisplayState(edge, curSelectedNode, curSelectedEdge, searchHidden, tagHidden);
				const isEdgeSelected = curSelectedEdge?.id === edge.id;

				return {
					...edge,
					data: {
						...edge.data,
						shouldShowFull,
						shouldAnimate,
						isSelected: isEdgeSelected,
						hasActiveSelection,
						isEndpointSearchHidden,
						isEndpointTagHidden
					},
					animated: false
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
		const thisGeneration = ++layoutGeneration;
		const isStale = () => {
			const stale = thisGeneration !== layoutGeneration;
			if (stale)
				console.log(
					`[LAYOUT-DEBUG] Generation ${thisGeneration} stale (current: ${layoutGeneration}), bailing out`
				);
			return stale;
		};
		try {
			if (topology && (topology.edges || topology.nodes)) {
				const currentView = get(activeView);
				const topoKey = getStructureKey(topology);
				const viewChanged = lastRenderedView !== '' && currentView !== lastRenderedView;
				const topologyChanged = topoKey !== lastRenderedTopoKey;
				if (topologyChanged) {
					viewSizeCache.clear();
				}
				console.log(
					`[LAYOUT-DEBUG] loadTopologyData gen=${thisGeneration} view=${currentView} viewChanged=${viewChanged} topologyChanged=${topologyChanged} nodes=${topology.nodes.length} edges=${topology.edges.length}`
				);

				// When view changed but topology data hasn't been rebuilt yet,
				// skip processing to avoid rendering old nodes with the new view (flicker)
				if (viewChanged && !topologyChanged) {
					return;
				}

				// When switching topologies, the incoming data may be built for a
				// different view than the user's activeView (e.g. topology was last
				// saved as Application but user is on L2). Skip rendering until a
				// rebuild delivers data matching the active view.
				const dataView = topology.options?.request?.view;
				if (dataView && dataView !== currentView) {
					return;
				}

				let collapsed = get(collapsedContainers);

				// Infer collapse level from persisted collapsed state on first load
				if (!collapseLevelInferred) {
					collapseLevelInferred = true;
					const inferred = inferCurrentLevel(
						collapsed,
						topology.nodes,
						containerTypes,
						getInfrastructureRuleId()
					);
					collapseLevel.set(inferred);
				}

				// When topology identity changes, reset auto-collapse tracking
				// and strip stale collapsed IDs (updates store directly).
				const topologyId = topology.id ?? '';
				if (topologyId !== lastSeenTopologyId && lastSeenTopologyId !== '') {
					seenAutoCollapseIds = new Set<string>();
					collapseLevelInferred = false; // re-infer after auto-collapse on new topology
					console.log(
						`[LAYOUT-DEBUG] Topology changed: ${lastSeenTopologyId.substring(0, 8)} → ${topologyId.substring(0, 8)}, reset seenAutoCollapseIds`
					);

					// Strip stale collapsed IDs and update store
					if (collapsed.size > 0) {
						const newContainerIds = new Set(
							topology.nodes.filter((n) => n.node_type === 'Container').map((n) => n.id)
						);
						const validCollapsed = new Set([...collapsed].filter((id) => newContainerIds.has(id)));
						const staleCount = collapsed.size - validCollapsed.size;

						// If ALL old root containers were collapsed, preserve "overview mode"
						if (layoutGraph) {
							const oldRootIds = [...layoutGraph.containers.values()]
								.filter((c) => !c.parent)
								.map((c) => c.id);
							const wasFullyCollapsed =
								oldRootIds.length > 0 && oldRootIds.every((id) => collapsed.has(id));
							if (wasFullyCollapsed) {
								const allContainerIds = topology.nodes
									.filter((n) => n.node_type === 'Container')
									.map((n) => n.id);
								const allCollapsed = new Set(allContainerIds);
								collapsedContainers.set(allCollapsed);
								collapseLevel.set(1);
								collapsed = allCollapsed;
								fitViewPending = true;
							} else if (staleCount > 0) {
								collapsedContainers.set(validCollapsed);
								collapsed = validCollapsed;
							}
						} else if (staleCount > 0) {
							collapsedContainers.set(validCollapsed);
							collapsed = validCollapsed;
						}

						if (staleCount > 0) {
							console.log(`[LAYOUT-DEBUG] Stripped ${staleCount} stale collapsed IDs`);
						}
					}
				}
				lastSeenTopologyId = topologyId;

				// All nodes participate in layout (hidden elements fade visually but
				// keep their positions to preserve layout stability)
				let layoutNodes = topology.nodes;

				// Remove subcontainers with no remaining element children
				const subcontainerIds = new Set(
					layoutNodes
						.filter(
							(n) =>
								n.node_type === 'Container' &&
								containerTypes.getMetadata(
									((n as Record<string, unknown>).container_type as string) ?? 'Subnet'
								).is_subcontainer
						)
						.map((n) => n.id)
				);
				if (subcontainerIds.size > 0) {
					// eslint-disable-next-line svelte/prefer-svelte-reactivity -- local variable, not reactive state
					const childCounts = new Map<string, number>();
					for (const n of layoutNodes) {
						if (n.node_type === 'Element') {
							const cid = (n as Record<string, unknown>).container_id as string;
							if (subcontainerIds.has(cid)) {
								childCounts.set(cid, (childCounts.get(cid) ?? 0) + 1);
							}
						}
					}
					layoutNodes = layoutNodes.filter(
						(n) =>
							!(
								n.node_type === 'Container' &&
								subcontainerIds.has(n.id) &&
								!childCounts.has(n.id) &&
								!collapsed.has(n.id)
							)
					);
				}

				const elementToContainer = buildElementToContainer(layoutNodes);
				const hiddenEdgeTypes = $topologyOptions.local.hide_edge_types ?? [];

				// Elevate edges targeting elements inside absorbing containers
				const elevatedEdges = elevateEdgesToContainers(topology.edges, layoutNodes);

				// After elevation, edge endpoints may be container IDs (not element IDs).
				// Map containers to themselves so bundling treats them as distinct targets
				// (not as "inside" their parent, which would cause intra-container skipping).
				for (const node of layoutNodes) {
					if (node.node_type === 'Container' && !elementToContainer.has(node.id)) {
						elementToContainer.set(node.id, node.id);
					}
				}

				// Run ELK on structure/collapse changes, skip for edge-only re-renders
				const opts = get(topologyOptions);
				const sizeKey = `${opts.request.hide_ports}`;
				const rootCollapsedPreview = new Set(
					[...collapsed].filter((id) => !layoutGraph || !layoutGraph.isSubcontainer(id))
				);
				const structureKey =
					currentView +
					':' +
					topoKey +
					':' +
					Array.from(rootCollapsedPreview).sort().join(',') +
					':' +
					sizeKey +
					':' +
					hiddenEdgeTypes.join(',');
				const isNewStructure = sessionStructureKey !== structureKey;

				// Capture expanded sizes and child positions from the current graph
				// BEFORE rebuilding — the rebuild resets all sizes to zero.
				const prevExpandedSizes = layoutGraph?.getExpandedContainerSizes();
				const prevChildPositions = layoutGraph?.getContainerChildPositions();

				console.log(
					`[LAYOUT-DEBUG] Structure: isNew=${isNewStructure} collapsed=${collapsed.size} prevExpandedSizes=${prevExpandedSizes?.size ?? 0} prevChildPositions=${prevChildPositions?.size ?? 0}`
				);

				// Build/rebuild the layout graph when topology or hidden services change
				if (!layoutGraph || isNewStructure) {
					layoutGraph = LayoutGraph.fromTopology(layoutNodes);
				}

				// On first load with persisted collapse (no previous expanded sizes),
				// defer collapse so measurement + ELK run with everything expanded.
				// This gives us real DOM-measured sizes and real ELK-computed expanded
				// dimensions. Collapse is applied after applyElkResult.
				const deferCollapse =
					isNewStructure &&
					collapsed.size > 0 &&
					(!prevExpandedSizes || prevExpandedSizes.size === 0);

				// Sync collapse state from store → graph (handles cascade internally)
				let collapseChanged = false;
				if (!deferCollapse) {
					collapseChanged = layoutGraph.syncCollapseState(collapsed);
				}

				// Force ELK re-layout when a container was expanded but has no
				// cached layout (e.g., was collapsed-by-default from initial load
				// or persisted via localStorage — ELK never ran with it expanded).
				let needsElkForExpand = false;
				if (collapseChanged) {
					for (const c of layoutGraph.containers.values()) {
						if (!c.collapsed && c.expandedSize.width === 0 && c.allChildren.length > 0) {
							needsElkForExpand = true;
							seenAutoCollapseIds.add(c.id);
						}
					}
				}

				// Compute aggregated edges for collapsed containers
				const aggregatedEdges = computeCollapsedEdges(
					elevatedEdges,
					collapsed,
					layoutNodes,
					hiddenEdgeTypes
				);

				// Use the graph to determine visible nodes
				const visibleNodes = layoutGraph.getVisibleNodes(layoutNodes);

				// Helper: build SvelteFlow node array from topology nodes
				const buildFlowNodes = (useGraph: boolean): Node[] => {
					// Get live @xyflow positions (includes ELK layout + user drags)
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

					return visibleNodes.map((node) => {
						const isNodeCollapsed = collapsed.has(node.id);
						let position: { x: number; y: number };
						let width: number | undefined;
						let height: number | undefined;

						const isElement = node.node_type === 'Element';

						// Container size from layout graph (collapsed = metadata size, expanded = ELK size)
						const containerSize =
							!isElement && layoutGraph ? layoutGraph.getContainerSize(node.id) : undefined;

						if (useGraph && layoutGraph) {
							const graphPos = layoutGraph.getPosition(node.id);
							const expandedSize = !isElement ? layoutGraph.getExpandedSize(node.id) : undefined;
							position = graphPos ?? { x: node.position.x, y: node.position.y };
							// Sub-containers keep expanded width when collapsed to prevent overlap on expand
							// Root containers use collapsed size from metadata
							const isSubContainer =
								!isElement && node.node_type === 'Container' && !!node.parent_container_id;
							if (isSubContainer) {
								console.log(
									`[LAYOUT-DEBUG] buildFlowNodes sub ${node.id.substring(0, 8)} collapsed=${isNodeCollapsed} expandedSize=${JSON.stringify(expandedSize)} containerSize=${JSON.stringify(containerSize)} w=${width} h=${height}`
								);
							}
							width = isNodeCollapsed
								? isSubContainer
									? (expandedSize?.width ?? containerSize?.width ?? undefined)
									: (containerSize?.width ?? undefined)
								: isElement
									? 250
									: (containerSize?.width ?? undefined);
							height = isNodeCollapsed
								? (containerSize?.height ?? undefined)
								: isElement
									? undefined
									: (containerSize?.height ?? undefined);
						} else if (!isNewStructure) {
							const curPos = currentPositions.get(node.id);
							const curSize = currentSizes.get(node.id);
							position = curPos ?? { x: node.position.x, y: node.position.y };
							width = isNodeCollapsed
								? (containerSize?.width ?? undefined)
								: isElement
									? 250
									: (curSize?.width ?? undefined);
							height = isNodeCollapsed
								? (containerSize?.height ?? undefined)
								: isElement
									? undefined
									: (curSize?.height ?? undefined);
						} else {
							// Measurement pass: place at origin, let content determine size
							position = { x: 0, y: 0 };
							width = isElement ? 250 : undefined;
							height = undefined;
						}

						return {
							id: node.id,
							type: node.node_type,
							position,
							...(width !== undefined && { width }),
							...(height !== undefined && { height }),
							expandParent: true,
							deletable: false,
							selectable: node.node_type !== 'Container',
							parentId:
								node.node_type == 'Element'
									? (node.container_id ?? resolveElementNode(node.id, node, topology).subnetId)
									: node.node_type == 'Container' && node.parent_container_id
										? (node.parent_container_id as string)
										: undefined,
							extent:
								node.node_type == 'Element' || node.parent_container_id ? 'parent' : undefined,
							data: isNodeCollapsed
								? (() => {
										const totalCount = layoutGraph?.getChildCount(node.id) ?? 0;
										const summaries = layoutGraph?.getSubgroupSummaries(node.id) ?? [];
										// Exclude infrastructure services subgroup from workload count
										const infraId = getInfrastructureRuleId();
										let excludedCount = 0;
										if (infraId) {
											for (const s of summaries) {
												const groupNode = topology.nodes.find((n) => n.id === s.groupId);
												if (
													groupNode &&
													(groupNode as Record<string, unknown>).element_rule_id === infraId
												) {
													excludedCount += s.childCount;
												}
											}
										}
										return {
											...node,
											isCollapsed: true,
											childCount: totalCount - excludedCount,
											subgroupSummaries: summaries
										};
									})()
								: node
						};
					});
				};

				// Sort helper: parents before children (SvelteFlow requirement)
				const depthOf = (n: Node) => {
					if (!n.parentId) return 0;
					if (n.type === 'Container') return 1;
					return 2;
				};
				const sortFlowNodes = (flowNodes: Node[]) =>
					flowNodes.sort((a, b) => depthOf(a) - depthOf(b));

				const isViewTransition = isNewStructure && viewChanged && topologyChanged;
				const needsElk = isNewStructure || needsElkForExpand;
				console.log(
					`[LAYOUT-DEBUG] Layout decision: needsElk=${needsElk} isNewStructure=${isNewStructure} needsElkForExpand=${needsElkForExpand} deferCollapse=${deferCollapse} collapseChanged=${collapseChanged} collapsed=${collapsed.size}`
				);

				if (needsElk) {
					// eslint-disable-next-line svelte/prefer-svelte-reactivity -- local variable, not reactive state
					const elementNodeSizes = new Map<string, { x: number; y: number }>();
					const viewCacheKey = `${currentView}:${topology.id}`;
					const cachedSizes = isViewTransition ? viewSizeCache.get(viewCacheKey) : undefined;
					const expandCachedSizes =
						needsElkForExpand && !isNewStructure ? viewSizeCache.get(viewCacheKey) : undefined;
					if (isViewTransition && cachedSizes) {
						// Return visit to a previously-measured view: use cached sizes
						// so the old layout stays visible (no measurement pass / container hide)
						for (const node of visibleNodes) {
							const cached = cachedSizes.get(node.id);
							elementNodeSizes.set(node.id, cached ?? { x: 250, y: 100 });
						}
					} else if (expandCachedSizes) {
						// Expanding a collapsed-by-default container: use cached sizes
						// from the current view to skip DOM measurement
						for (const node of visibleNodes) {
							const cached = expandCachedSizes.get(node.id);
							elementNodeSizes.set(node.id, cached ?? { x: 250, y: 100 });
						}
					} else {
						// First visit to view or non-view structural change:
						// full DOM measurement pass
						console.log(`[LAYOUT-DEBUG] Starting DOM measurement pass`);
						isMeasuring = true;
						edges.set([]);
						const measureNodes = sortFlowNodes(buildFlowNodes(false));
						nodes.set(measureNodes);

						await tick();
						await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
						if (isStale()) {
							isMeasuring = false;
							return;
						}

						// Read actual DOM sizes
						if (containerElement) {
							const nodeEls = containerElement.querySelectorAll('.svelte-flow__node');
							let zeroSizeCount = 0;
							for (const el of nodeEls) {
								const id = (el as HTMLElement).dataset.id;
								if (id) {
									const htmlEl = el as HTMLElement;
									const w = htmlEl.offsetWidth || 250;
									const h = htmlEl.offsetHeight || 100;
									if (htmlEl.offsetWidth === 0 || htmlEl.offsetHeight === 0) zeroSizeCount++;
									elementNodeSizes.set(id, { x: w, y: h });
								}
							}
							console.log(
								`[LAYOUT-DEBUG] DOM measurement complete: ${elementNodeSizes.size} nodes measured, ${zeroSizeCount} with zero size (fallback used)`
							);
							// Log container measurements separately for debugging subcontainer sizing
							if (layoutGraph) {
								const containerMeasurements = [...elementNodeSizes.entries()]
									.filter(([id]) => layoutGraph!.containers.has(id))
									.map(
										([id, s]) =>
											`${id.substring(0, 8)}=${s.x}x${s.y}${layoutGraph!.containers.get(id)?.isSubcontainer ? '(sub)' : ''}`
									);
								if (containerMeasurements.length > 0) {
									console.log(
										`[LAYOUT-DEBUG] Measured container sizes: ${containerMeasurements.join(', ')}`
									);
								}
							}
						}
					}

					// Detect if all root containers are collapsed → use force layout
					const rootContainerNodes = visibleNodes.filter(
						(n) => n.node_type === 'Container' && !n.parent_container_id
					);
					const allRootCollapsed =
						rootContainerNodes.length > 0 && rootContainerNodes.every((n) => collapsed.has(n.id));

					if (allRootCollapsed) {
						// Force layout for all-collapsed overview mode
						const forceNodes: ForceNode[] = rootContainerNodes.map((n) => {
							const measured = elementNodeSizes.get(n.id);
							const meta = containerTypes.getMetadata(
								((n as Record<string, unknown>).container_type as string) ?? 'Subnet'
							);
							return {
								id: n.id,
								width: measured?.x ?? meta.collapsed_size.width,
								height: measured?.y ?? meta.collapsed_size.height
							};
						});

						// Build deduplicated links from elevated edges between root containers
						const rootIds = new Set(rootContainerNodes.map((n) => n.id));
						const forceLinks: ForceLink[] = [];
						// eslint-disable-next-line svelte/prefer-svelte-reactivity -- local computation, not reactive state
						const seenLinks = new Set<string>();
						for (const edge of elevatedEdges) {
							const src = edge.source as string;
							const tgt = edge.target as string;
							if (rootIds.has(src) && rootIds.has(tgt) && src !== tgt) {
								const key = `${src}->${tgt}`;
								if (!seenLinks.has(key)) {
									seenLinks.add(key);
									forceLinks.push({ source: src, target: tgt });
								}
							}
						}

						const forceResult = computeForceLayout(forceNodes, forceLinks);

						// Compute edge handles for force-layout edges
						const forceEdgeHandles = new Map<
							string,
							import('../../layout/elk-layout').EdgeHandles
						>();
						const forceNodeSizes = new Map(
							forceNodes.map((n) => [n.id, { w: n.width, h: n.height }])
						);
						for (const edge of elevatedEdges) {
							const srcPos = forceResult.nodePositions.get(edge.source as string);
							const tgtPos = forceResult.nodePositions.get(edge.target as string);
							const srcSize = forceNodeSizes.get(edge.source as string);
							const tgtSize = forceNodeSizes.get(edge.target as string);
							if (srcPos && tgtPos && srcSize && tgtSize) {
								forceEdgeHandles.set(
									`${edge.source}->${edge.target}`,
									computeOptimalHandles(srcPos, srcSize, tgtPos, tgtSize)
								);
							}
						}

						sessionStructureKey = structureKey;
						layoutGraph = LayoutGraph.fromTopology(layoutNodes);
						layoutGraph.syncCollapseState(collapsed);
						layoutGraph.applyForceResult(
							forceResult.nodePositions,
							forceEdgeHandles,
							elementNodeSizes
						);
						console.log(
							`[LAYOUT-DEBUG] Force layout applied: ${forceResult.nodePositions.size} positioned nodes (all-collapsed overview)`
						);
					} else {
						// When there are no previous expanded sizes (first load with
						// persisted collapse from localStorage), run ELK with everything
						// EXPANDED so all containers get proper expandedSize computed.
						// Then apply collapse state after, preserving the sizes.
						// When deferring collapse, ELK runs with everything expanded
						// using real DOM measurements. Otherwise, use actual collapse state.
						const elkCollapsed = deferCollapse ? new Set<string>() : collapsed;
						const elkNodes = deferCollapse ? layoutNodes : visibleNodes;

						const elkResult = await layoutEngine.compute({
							nodes: elkNodes,
							edges: elevatedEdges,
							topology: topology,
							collapsedContainers: elkCollapsed,
							expandedContainerSizes: prevExpandedSizes,
							elementNodeSizes,
							hiddenEdgeTypes: hiddenEdgeTypes
						});
						if (isStale()) {
							isMeasuring = false;
							return;
						}
						sessionStructureKey = structureKey;

						// Rebuild graph and apply ELK result
						layoutGraph = LayoutGraph.fromTopology(layoutNodes);
						if (!deferCollapse) {
							layoutGraph.syncCollapseState(collapsed);
							if (prevExpandedSizes) {
								layoutGraph.restoreExpandedSizes(prevExpandedSizes);
							}
							if (prevChildPositions) {
								layoutGraph.restoreContainerChildPositions(prevChildPositions);
							}
						}
						layoutGraph.applyElkResult(
							elkResult.nodePositions,
							elkResult.containerSizes,
							elkResult.elementNodeSizes,
							elkResult.edgeHandles
						);
						// When collapse was deferred, apply it AFTER ELK result
						// so all containers have their real expandedSize set first.
						if (deferCollapse) {
							layoutGraph.syncCollapseState(collapsed);
						}

						// Log size mismatches between DOM-measured and ELK-computed
						{
							const mismatches: string[] = [];
							for (const [id, elkSize] of elkResult.containerSizes) {
								const measured = elementNodeSizes.get(id);
								if (measured) {
									const dw = Math.abs(measured.x - elkSize.width);
									const dh = Math.abs(measured.y - elkSize.height);
									if (dw > 10 || dh > 10) {
										mismatches.push(
											`${id.substring(0, 8)}: DOM=${measured.x}x${measured.y} ELK=${elkSize.width}x${elkSize.height}`
										);
									}
								}
							}
							if (mismatches.length > 0) {
								console.log(
									`[LAYOUT-DEBUG] Size mismatches (DOM vs ELK): ${mismatches.join(', ')}`
								);
							}
							console.log(
								`[LAYOUT-DEBUG] ELK layout applied: deferCollapse=${deferCollapse} containers=${layoutGraph.containers.size} elements=${layoutGraph.elements.size}`
							);
						}
					}

					// Cache measured sizes for this view so return visits skip measurement
					viewSizeCache.set(viewCacheKey, new Map(elementNodeSizes));

					// Auto-collapse containers whose type has collapsed_by_default metadata.
					// Runs after layout so expanded sizes are cached for correct expand later.
					// Only collapse containers we haven't seen before (so user can expand them).
					// Skip at level 4 (fully expanded) — user explicitly wants everything open.
					{
						const currentLevel = get(collapseLevel);
						const infraRuleId = getInfrastructureRuleId();
						// Log all auto-collapse candidates and why they were included/excluded
						const allCandidates = topology.nodes.filter((n) => {
							if (n.node_type !== 'Container') return false;
							const data = n as Record<string, unknown>;
							const ct = data.container_type as string | undefined;
							return (
								(ct && containerTypes.getMetadata(ct).collapsed_by_default === true) ||
								(infraRuleId && data.element_rule_id === infraRuleId)
							);
						});
						// Skip at level 4 only if the user explicitly set it via the stepper —
						// not if it was inferred from an empty collapsed set (e.g., after topology switch).
						// collapseLevelInferred=false means level needs re-inference, so don't trust it.
						const userExplicitlyExpandedAll = currentLevel === 4 && collapseLevelInferred;
						const autoCollapseIds = userExplicitlyExpandedAll
							? []
							: allCandidates
									.filter((n) => !collapsed.has(n.id) && !seenAutoCollapseIds.has(n.id))
									.map((n) => n.id);
						console.log(
							`[LAYOUT-DEBUG] Auto-collapse: level=${currentLevel} inferred=${collapseLevelInferred} skipL4=${userExplicitlyExpandedAll}, ${allCandidates.length} candidates, ${allCandidates.filter((n) => collapsed.has(n.id)).length} already collapsed, ${allCandidates.filter((n) => seenAutoCollapseIds.has(n.id)).length} already seen, ${autoCollapseIds.length} will auto-collapse`
						);
						if (autoCollapseIds.length > 0) {
							console.log(
								`[LAYOUT-DEBUG] Auto-collapse: ${autoCollapseIds
									.map((id) => {
										const c = layoutGraph?.containers.get(id);
										return `${id.substring(0, 8)}(${c?.containerType ?? '?'} expanded=${JSON.stringify(c?.expandedSize)})`;
									})
									.join(', ')}`
							);
							for (const id of autoCollapseIds) seenAutoCollapseIds.add(id);
							// eslint-disable-next-line svelte/prefer-svelte-reactivity -- temporary value for store update
							const next = new Set(collapsed);
							for (const id of autoCollapseIds) next.add(id);
							collapsedContainers.set(next);
						}
						// Re-infer level after auto-collapse so it reflects actual state
						if (!collapseLevelInferred) {
							collapseLevelInferred = true;
							const newCollapsed = get(collapsedContainers);
							const inferred = inferCurrentLevel(
								newCollapsed,
								topology.nodes,
								containerTypes,
								getInfrastructureRuleId()
							);
							collapseLevel.set(inferred);
						}
					}
				}

				// Local size adjustment for port expansion (no full ELK re-layout)
				const currentExpandedPorts = get(expandedPortNodeIds);
				const portsChanged =
					currentExpandedPorts.size !== prevExpandedPortIds.size ||
					[...currentExpandedPorts].some((id) => !prevExpandedPortIds.has(id)) ||
					[...prevExpandedPortIds].some((id) => !currentExpandedPorts.has(id));

				if (portsChanged && !needsElk && layoutGraph) {
					// Phase 1: Render with current positions to let DOM update port content
					const measureNodes = sortFlowNodes(buildFlowNodes(false));
					nodes.set(measureNodes);
					await tick();
					await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
					if (isStale()) {
						isMeasuring = false;
						return;
					}

					// Phase 2: Re-measure affected nodes and update graph
					if (containerElement) {
						const changedIds = new Set([...currentExpandedPorts, ...prevExpandedPortIds]);
						for (const nodeId of changedIds) {
							const el = containerElement.querySelector(`[data-id="${nodeId}"]`) as HTMLElement;
							if (el) {
								layoutGraph.updateElementSize(nodeId, {
									x: el.offsetWidth || 250,
									y: el.offsetHeight || 100
								});
							}
						}
					}
					prevExpandedPortIds = new Set(currentExpandedPorts);
				} else if (needsElk) {
					prevExpandedPortIds = new Set(currentExpandedPorts);
				}

				// Subgroup collapse/expand is handled by syncCollapseState which calls
				// collapse()/expand() with proper targeted reflowChildren(changedChildId).
				// No additional blanket reflow needed here.

				// Use handles from the most recent layout computation
				edgeHandles = layoutGraph?.edgeHandles ?? new Map();
				prevView = currentView;

				// Build final nodes with positions from graph
				const needsLayout = needsElk || portsChanged || collapseChanged;
				const allNodes = sortFlowNodes(buildFlowNodes(needsLayout));

				// Build edges (pure data — no DOM dependency)
				let baseEdges: TopologyEdge[];
				const extraFlowEdges: Edge[] = [];

				if (collapsed.size > 0 && aggregatedEdges.length > 0) {
					// Filter out edges where source or target is inside a collapsed container
					baseEdges = elevatedEdges.filter((edge) => {
						const srcContainer = elementToContainer.get(edge.source as string);
						const tgtContainer = elementToContainer.get(edge.target as string);
						const srcCollapsed = srcContainer && collapsed.has(srcContainer);
						const tgtCollapsed = tgtContainer && collapsed.has(tgtContainer);
						return !srcCollapsed && !tgtCollapsed;
					});

					// Create aggregated flow edges for collapsed containers
					// Store original edges in a separate lookup (not in flow edge data,
					// which causes SvelteFlow rendering issues with nested objects)
					// eslint-disable-next-line svelte/prefer-svelte-reactivity -- local computation, not reactive state
					const originalsMap = new Map<string, import('../../types/base').TopologyEdge[]>();
					for (let index = 0; index < aggregatedEdges.length; index++) {
						const agg = aggregatedEdges[index];
						originalsMap.set(agg.id, agg.originalEdges);
						const edgeKey = `${agg.source}->${agg.target}`;
						let handles = edgeHandles.get(edgeKey);

						// Derive handles from original element-level edges' cached handles
						// so collapsed containers use the same handle directions as their children.
						// Must account for direction: computeCollapsedEdges normalizes keys
						// (src < tgt), so original edges may be flipped relative to the
						// aggregated edge. Resolve each original edge's source to its collapsed
						// ancestor to determine alignment.
						if (!handles && agg.originalEdges.length > 0) {
							// Build parent map for ancestor resolution
							const parentMap = new Map<string, string>();
							for (const node of topology.nodes) {
								if (node.node_type === 'Element') {
									const pid =
										(node as Record<string, unknown>).container_id ??
										(node as Record<string, unknown>).subnet_id;
									if (typeof pid === 'string') parentMap.set(node.id, pid);
								} else if (node.node_type === 'Container') {
									const pid = (node as Record<string, unknown>).parent_container_id as
										| string
										| undefined;
									if (pid) parentMap.set(node.id, pid);
								}
							}
							function resolveAncestor(nodeId: string): string | null {
								let cur = nodeId;
								let result: string | null = null;
								const visited = new Set<string>();
								while (cur && !visited.has(cur)) {
									visited.add(cur);
									if (collapsed.has(cur)) result = cur;
									const p = parentMap.get(cur);
									if (!p || p === cur) break;
									cur = p;
								}
								return result;
							}

							const handleCounts = new Map<string, number>();
							for (const origEdge of agg.originalEdges) {
								const origKey = `${origEdge.source}->${origEdge.target}`;
								const origHandles =
									edgeHandles.get(origKey) ??
									edgeHandles.get(`${origEdge.target}->${origEdge.source}`);
								if (origHandles) {
									// Determine if original edge's source aligns with agg.source.
									// If source isn't inside a collapsed container, use its ID directly.
									const resolvedSrc = resolveAncestor(origEdge.source as string);
									const srcSide = resolvedSrc ?? (origEdge.source as string);
									const aligned = srcSide === agg.source;
									const srcH = aligned ? origHandles.sourceHandle : origHandles.targetHandle;
									const tgtH = aligned ? origHandles.targetHandle : origHandles.sourceHandle;
									const combo = `${srcH}|${tgtH}`;
									handleCounts.set(combo, (handleCounts.get(combo) ?? 0) + 1);
								}
							}
							if (handleCounts.size > 0) {
								let bestCombo = '';
								let bestCount = 0;
								for (const [combo, count] of handleCounts) {
									if (count > bestCount) {
										bestCombo = combo;
										bestCount = count;
									}
								}
								const [srcH, tgtH] = bestCombo.split('|');
								handles = {
									sourceHandle: srcH as 'Top' | 'Bottom' | 'Left' | 'Right',
									targetHandle: tgtH as 'Top' | 'Bottom' | 'Left' | 'Right'
								};
							}
						}

						// Fall back to position-based computation if no original handles found
						// (force layout doesn't pre-compute handles)
						if (!handles && layoutGraph) {
							const srcPos = layoutGraph.getPosition(agg.source);
							const tgtPos = layoutGraph.getPosition(agg.target);
							const srcSize = layoutGraph.getContainerSize(agg.source);
							const tgtSize = layoutGraph.getContainerSize(agg.target);
							if (srcPos && tgtPos && srcSize && tgtSize) {
								handles = computeOptimalHandles(
									srcPos,
									{ w: srcSize.width, h: srcSize.height },
									tgtPos,
									{ w: tgtSize.width, h: tgtSize.height }
								);
							}
						}
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
					aggregatedEdgeOriginals.set(originalsMap);
				} else {
					// No collapsed containers — all edges are base edges
					baseEdges = elevatedEdges;
					aggregatedEdgeOriginals.set(new Map());
				}

				// Filter visible edges (disabled edges excluded entirely, hidden types excluded before bundling)
				const nonDisabledEdges = baseEdges.filter((e) => !isDisabledEdge(e));
				const visibleEdgesRaw = nonDisabledEdges.filter(
					(e) => !hiddenEdgeTypes.includes(e.edge_type)
				);

				// Build root container lookup (walk parent_container_id chain to root)
				const containerParent = new Map<string, string>();
				for (const node of layoutNodes) {
					if (node.node_type === 'Container' && node.parent_container_id) {
						containerParent.set(node.id, node.parent_container_id as string);
					}
				}
				function getRootContainer(id: string): string {
					let current = elementToContainer.get(id) ?? id;
					while (containerParent.has(current)) {
						current = containerParent.get(current)!;
					}
					return current;
				}

				// Remove self-edges and strip labels for intra-container edges
				const visibleEdges = visibleEdgesRaw
					.filter((e) => e.source !== e.target)
					.map((e) => {
						const srcRoot = getRootContainer(e.source as string);
						const tgtRoot = getRootContainer(e.target as string);
						if (srcRoot === tgtRoot && e.label) {
							return { ...e, label: undefined };
						}
						return e;
					});

				let flowEdges: Edge[];
				const currentExpandedBundles = get(expandedBundles);

				if ($topologyOptions.local.bundle_edges) {
					const { bundles, unbundled } = bundleEdges(visibleEdges, elementToContainer);
					flowEdges = [];
					let edgeIndex = 0;

					// Unbundled edges render normally
					for (const edge of unbundled) {
						flowEdges.push(createFlowEdge(edge, edgeIndex++));
					}

					for (const bundle of bundles) {
						if (currentExpandedBundles.has(bundle.id)) {
							// Expanded: render individual edges with fan offset
							const fanTotal = bundle.edges.length;
							for (let i = 0; i < fanTotal; i++) {
								flowEdges.push(
									createFlowEdge(bundle.edges[i], edgeIndex++, {
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
								createFlowEdge(representative, edgeIndex++, {
									isBundle: true,
									bundleId: bundle.id,
									bundleCount: bundle.count,
									bundleEdges: bundle.edges,
									bundleStrokeWidth,
									bundleIsOverlay: isDashedEdge(representative)
								})
							);
						}
					}
				} else {
					// Bundling disabled: render all visible edges individually
					flowEdges = visibleEdges.map((edge, index) => createFlowEdge(edge, index));
				}

				// Add hidden edges (they get filtered by CustomEdge's hideEdge logic)
				const hiddenEdges = nonDisabledEdges.filter((e) => hiddenEdgeTypes.includes(e.edge_type));
				for (const edge of hiddenEdges) {
					flowEdges.push(createFlowEdge(edge, flowEdges.length));
				}

				// Add aggregated collapse edges
				flowEdges.push(...extraFlowEdges);

				if (!isMeasuring) {
					// Cached-size path (no measurement pass): set nodes and edges atomically
					// in one synchronous batch — old layout swaps to new in a single frame
					nodes.set(allNodes);
					edges.set(flowEdges);
				} else {
					// Measurement path: container is hidden, set positioned nodes + edges,
					// then reveal after paint completes
					edges.set([]);
					nodes.set(allNodes);

					pendingEdges = flowEdges;

					// Wait for nodes to render, then set edges
					await tick();
					if (isStale()) {
						isMeasuring = false;
						return;
					}
					if (pendingEdges.length > 0) {
						edges.set(pendingEdges);
						pendingEdges = [];
					}

					// Reveal after positioned nodes + edges have painted
					// Double rAF ensures the compositing pass completes before revealing
					await tick();
					await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
					if (isStale()) {
						isMeasuring = false;
						return;
					}
					isMeasuring = false;
				}

				const isFirstRender = lastRenderedTopoKey === '';
				lastRenderedTopoKey = topoKey;
				lastRenderedView = currentView;

				// Auto-fit viewport after layout completes:
				// - on perspective switch (viewChanged && topologyChanged)
				// - on first render / URL navigation (no previous layout)
				if ((viewChanged && topologyChanged) || isFirstRender || fitViewPending) {
					fitViewPending = false;
					requestAnimationFrame(() => fitView({ padding: getFitViewPadding() }));
				}
			}
		} catch (err) {
			isMeasuring = false;
			pushError(`Failed to parse topology data ${err}`);
		}
	}

	function createFlowEdge(
		edge: TopologyEdge,
		index: number,
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
		const flowEdge: Edge = {
			id: edgeId,
			source: edge.source,
			target: edge.target,
			markerEnd,
			markerStart,
			sourceHandle: (
				edgeHandles.get(`${edge.source}->${edge.target}`)?.sourceHandle ?? edge.source_handle
			).toString(),
			targetHandle: (
				edgeHandles.get(`${edge.source}->${edge.target}`)?.targetHandle ?? edge.target_handle
			).toString(),
			type: 'custom',
			label: edge.label ?? undefined,
			data: { ...edge, edgeIndex: index, ...extraData },
			animated: false,
			interactionWidth: 50
		};

		// Compute display state from current selection
		const curNode = get(selectionStores.selectedNode);
		const curEdge = get(selectionStores.selectedEdge);
		const searchHidden = get(searchHiddenNodeIds);
		const tagHidden = get(tagHiddenNodeIds);
		const { shouldAnimate, shouldShowFull, isEndpointSearchHidden, isEndpointTagHidden } =
			getEdgeDisplayState(flowEdge, curNode, curEdge, searchHidden, tagHidden);
		flowEdge.data = {
			...flowEdge.data,
			shouldShowFull,
			shouldAnimate,
			isSelected: curEdge?.id === flowEdge.id,
			hasActiveSelection: !!(curNode || curEdge),
			isEndpointSearchHidden,
			isEndpointTagHidden
		};

		return flowEdge;
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

	// Flag to ignore SvelteFlow's onselectionchange after we handle Ctrl+click ourselves
	let ignoreNextSelectionChange = false;

	function handleNodeClick({ node, event }: { node: Node; event: MouseEvent | TouchEvent }) {
		const isModifierClick = event instanceof MouseEvent && (event.ctrlKey || event.metaKey);

		if (isModifierClick) {
			handleModifierNodeClick(node, selectionStores);
			ignoreNextSelectionChange = true;
		} else {
			collapseAllBundles();
			selectNode(node, selectionStores);
		}
	}

	function handleEdgeClick({ edge }: { edge: Edge; event: MouseEvent }) {
		collapseAllBundles();
		selectEdge(edge, selectionStores);
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

	/** Imperatively sync edge display state (animation, highlight) with current selection stores. */
	function syncEdgeDisplayState() {
		const currentEdges = get(edges);
		const curNode = get(selectionStores.selectedNode);
		const curEdge = get(selectionStores.selectedEdge);
		const hasActiveSelection = !!(curNode || curEdge);
		const searchHidden = get(searchHiddenNodeIds);
		const tagHidden = get(tagHiddenNodeIds);
		const updatedEdges = currentEdges.map((e) => {
			const { shouldAnimate, shouldShowFull, isEndpointSearchHidden, isEndpointTagHidden } =
				getEdgeDisplayState(e, curNode, curEdge, searchHidden, tagHidden);
			const isEdgeSelected = curEdge?.id === e.id;
			return {
				...e,
				data: {
					...e.data,
					shouldShowFull,
					shouldAnimate,
					isSelected: isEdgeSelected,
					hasActiveSelection,
					isEndpointSearchHidden,
					isEndpointTagHidden
				},
				animated: false
			};
		});
		edges.set(updatedEdges);
	}

	function handlePaneClick() {
		if (!viewportMoved) {
			clearSelection(selectionStores);
			clearEdgeHoverState();
			syncEdgeDisplayState();
		}
		// Reset immediately after handling
		viewportMoved = false;
		if (viewportMoveTimer) {
			clearTimeout(viewportMoveTimer);
			viewportMoveTimer = null;
		}
	}

	function handleEdgePointerEnter({ edge }: { edge: Edge }) {
		setEdgeHover(edge, true, get(edges));
		syncEdgeDisplayState();
	}

	function handleEdgePointerLeave({ edge }: { edge: Edge }) {
		setEdgeHover(edge, false, get(edges));
		syncEdgeDisplayState();
	}

	function handleSelectionChange({ nodes: selNodes }: { nodes: Node[]; edges: Edge[] }) {
		if (ignoreNextSelectionChange) {
			ignoreNextSelectionChange = false;
			return;
		}
		// When SvelteFlow deselects everything (e.g. pane click while edge selected),
		// it fires onselectionchange with empty arrays instead of onpaneclick.
		// Deferred with tick() to escape SvelteFlow's $effect batch.
		if (selNodes.length === 0 && !viewportMoved) {
			tick().then(() => {
				clearSelection(selectionStores);
				clearEdgeHoverState();
				syncEdgeDisplayState();
			});
			return;
		}
		handleBoxSelect(selNodes, selectionStores);
	}

	function getCollapseLevelName(level: CollapseLevel): string {
		switch (level) {
			case 1:
				return topology_levelFullyCollapsed();
			case 2:
				return topology_levelContainersExpanded();
			case 3:
				return topology_levelSubcontainersExpanded();
			case 4:
				return topology_levelFullyExpanded();
		}
	}

	$: collapseLevelTooltipCollapse = `${topology_collapseLevelDown()} (${$collapseLevel}/4: ${getCollapseLevelName($collapseLevel)})`;
	$: collapseLevelTooltipExpand = `${topology_expandLevelUp()} (${$collapseLevel}/4: ${getCollapseLevelName($collapseLevel)})`;

	function handleStepCollapse() {
		stepCollapse(topology.nodes, containerTypes, getInfrastructureRuleId());
		setTimeout(() => fitView({ padding: getFitViewPadding(), duration: 300 }), 100);
	}

	function handleStepExpand() {
		const { autoCollapseIds } = stepExpand(
			topology.nodes,
			containerTypes,
			getInfrastructureRuleId()
		);
		// Mark auto-collapse containers as "seen" so they don't re-collapse
		for (const id of autoCollapseIds) seenAutoCollapseIds.add(id);
		setTimeout(() => fitView({ padding: getFitViewPadding(), duration: 300 }), 100);
	}

	export function triggerStepExpand() {
		handleStepExpand();
	}

	export function triggerStepCollapse() {
		handleStepCollapse();
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
	style:visibility={isMeasuring ? 'hidden' : 'visible'}
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
		onedgepointerenter={handleEdgePointerEnter}
		onedgepointerleave={handleEdgePointerLeave}
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
				<div
					class="flex flex-col items-center overflow-hidden rounded !border !border-gray-300 !bg-gray-50 !shadow-lg dark:!border-gray-600 dark:!bg-gray-700"
					title={getCollapseLevelName($collapseLevel)}
				>
					<button
						class="flex items-center justify-center p-1.5 text-gray-700 hover:bg-gray-100 dark:text-gray-100 dark:hover:bg-gray-600"
						onclick={handleStepExpand}
						title={collapseLevelTooltipExpand}
					>
						<Expand class="h-3.5 w-3.5" />
					</button>
					<span
						class="flex min-h-[1.25rem] items-center justify-center text-xs font-semibold text-gray-700 dark:text-gray-100"
					>
						{$collapseLevel}
					</span>
					<button
						class="flex items-center justify-center p-1.5 text-gray-700 hover:bg-gray-100 dark:text-gray-100 dark:hover:bg-gray-600"
						onclick={handleStepCollapse}
						title={collapseLevelTooltipCollapse}
					>
						<Shrink class="h-3.5 w-3.5" />
					</button>
				</div>
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
					fitViewOptions={{
						padding: $optionsPanelExpanded
							? { top: 0.2, right: 0.2, bottom: 0.2, left: `${OPTIONS_PANEL_FITVIEW_PADDING_PX}px` }
							: 0.2
					}}
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
