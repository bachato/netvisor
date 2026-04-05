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
	import { edgeTypes, containerTypes } from '$lib/shared/stores/metadata';
	import { pushError } from '$lib/shared/stores/feedback';
	import { previewEdges, selectedNodes, topologyOptions, activePerspective } from '../../queries';
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
		collapseAll,
		expandAll,
		buildElementToContainer,
		computeCollapsedEdges
	} from '../../collapse';
	import {
		updateConnectedNodes,
		toggleEdgeHover,
		getEdgeDisplayState,
		expandedBundles,
		collapseAllBundles,
		tagHiddenServiceIds
	} from '../../interactions';
	import { bundleEdges } from '../../layout/edge-bundling';
	import { isOverlayEdge } from '../../layout/edge-classification';
	import { onMount, tick, setContext } from 'svelte';
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
		Container: ContainerNode,
		Element: ElementNode
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
	let layoutGraph: LayoutGraph | null = null;
	let sessionStructureKey = '';
	let isMeasuring = false;
	let prevExpandedPortIds = new Set<string>();
	let prevPerspective = get(activePerspective);
	let lastRenderedTopoKey = '';
	let lastRenderedPerspective = '';

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
	$: if (topology && (topology.edges || topology.nodes)) {
		void $collapsedContainers;
		void $expandedBundles;
		void $expandedPortNodeIds;
		void $topologyOptions.local.bundle_edges;
		void $topologyOptions.local.hide_edge_types;
		void $tagHiddenServiceIds;
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
			// Read hide_edge_types imperatively to avoid making this $: block
			// depend on $topologyOptions (which would cause a race with the
			// loadTopologyData block that also depends on it).
			const opts = get(topologyOptions);
			updateConnectedNodes(
				selectedNode,
				selectedEdge,
				currentEdges,
				currentNodes,
				queryClient,
				topology,
				multiSelected,
				opts.local.hide_edge_types ?? []
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
				const currentPerspective = get(activePerspective);
				const topoKey = getStructureKey(topology);
				const perspectiveChanged =
					lastRenderedPerspective !== '' && currentPerspective !== lastRenderedPerspective;
				const topologyChanged = topoKey !== lastRenderedTopoKey;

				// When perspective changed but topology data hasn't been rebuilt yet,
				// skip processing to avoid rendering old nodes with the new perspective (flicker)
				if (perspectiveChanged && !topologyChanged) {
					return;
				}

				const collapsed = get(collapsedContainers);
				const hiddenServices = get(tagHiddenServiceIds);

				// Filter out hidden service element nodes before layout
				let layoutNodes =
					hiddenServices.size > 0
						? topology.nodes.filter(
								(n) =>
									!(
										n.node_type === 'Element' &&
										'element_type' in n &&
										n.element_type === 'Service' &&
										hiddenServices.has(n.id)
									)
							)
						: topology.nodes;

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
							!(n.node_type === 'Container' && subcontainerIds.has(n.id) && !childCounts.has(n.id))
					);
				}

				const elementToContainer = buildElementToContainer(layoutNodes);
				const hiddenEdgeTypes = $topologyOptions.local.hide_edge_types ?? [];

				// Run ELK on structure/collapse changes, skip for edge-only re-renders
				const opts = get(topologyOptions);
				const sizeKey = `${(opts.request.hide_service_categories ?? []).join(',')}:${opts.request.hide_ports}`;
				const rootCollapsedPreview = new Set(
					[...collapsed].filter((id) => !layoutGraph || !layoutGraph.isSubcontainer(id))
				);
				const structureKey =
					currentPerspective +
					':' +
					topoKey +
					':' +
					Array.from(rootCollapsedPreview).sort().join(',') +
					':' +
					sizeKey +
					':' +
					hiddenEdgeTypes.join(',') +
					':h' +
					hiddenServices.size;
				const isNewStructure = sessionStructureKey !== structureKey;

				// Build/rebuild the layout graph when topology or hidden services change
				if (!layoutGraph || isNewStructure) {
					layoutGraph = LayoutGraph.fromTopology(layoutNodes);
				}

				// Sync collapse state from store → graph (handles cascade internally)
				const collapseChanged = layoutGraph.syncCollapseState(collapsed);

				// Compute aggregated edges for collapsed containers
				const aggregatedEdges = computeCollapsedEdges(
					topology.edges,
					collapsed,
					elementToContainer,
					hiddenEdgeTypes
				);

				// Use the graph to determine visible nodes
				const visibleNodes = layoutGraph.getVisibleNodes(layoutNodes);

				// Only root container collapses affect graph structure (need full ELK)
				const rootCollapsed = new Set(
					[...collapsed].filter((id) => !layoutGraph!.isSubcontainer(id))
				);

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

						if (useGraph && layoutGraph) {
							const graphPos = layoutGraph.getPosition(node.id);
							const containerSize = !isElement ? layoutGraph.getContainerSize(node.id) : undefined;
							const expandedSize = !isElement ? layoutGraph.getExpandedSize(node.id) : undefined;
							position = graphPos ?? { x: node.position.x, y: node.position.y };
							// Sub-containers keep expanded width when collapsed to prevent overlap on expand
							// Root containers use content-fit width (min-w-48 in ContainerNode)
							const isSubContainer =
								!isElement && node.node_type === 'Container' && !!node.parent_container_id;
							width = isNodeCollapsed
								? isSubContainer
									? (expandedSize?.width ?? undefined)
									: undefined
								: isElement
									? 250
									: (containerSize?.width ?? undefined);
							height = isNodeCollapsed
								? undefined
								: isElement
									? undefined
									: (containerSize?.height ?? undefined);
						} else if (!isNewStructure) {
							const curPos = currentPositions.get(node.id);
							const curSize = currentSizes.get(node.id);
							position = curPos ?? { x: node.position.x, y: node.position.y };
							width = isNodeCollapsed ? undefined : isElement ? 250 : (curSize?.width ?? undefined);
							height = isNodeCollapsed
								? undefined
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
								? {
										...node,
										isCollapsed: true,
										childCount: layoutGraph?.getChildCount(node.id) ?? 0,
										subgroupSummaries: layoutGraph?.getSubgroupSummaries(node.id) ?? []
									}
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

				if (isNewStructure) {
					// Phase 1: Render nodes for DOM measurement (hidden, no ELK yet)
					isMeasuring = true;
					edges.set([]);
					const measureNodes = sortFlowNodes(buildFlowNodes(false));
					nodes.set(measureNodes);

					await tick();
					await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));

					// Phase 2: Read actual DOM sizes
					// eslint-disable-next-line svelte/prefer-svelte-reactivity -- local variable, not reactive state
					const elementNodeSizes = new Map<string, { x: number; y: number }>();
					if (containerElement) {
						const nodeEls = containerElement.querySelectorAll('.svelte-flow__node');
						for (const el of nodeEls) {
							const id = (el as HTMLElement).dataset.id;
							if (id) {
								const htmlEl = el as HTMLElement;
								elementNodeSizes.set(id, {
									x: htmlEl.offsetWidth || 250,
									y: htmlEl.offsetHeight || 100
								});
							}
						}
					}

					// Phase 3: Run layout engine with real measured sizes
					const expandedContainerSizes = layoutGraph?.getExpandedContainerSizes();
					const elkResult = await layoutEngine.compute({
						nodes: visibleNodes,
						edges: topology.edges,
						topology: topology,
						collapsedContainers: collapsed,
						expandedContainerSizes,
						elementNodeSizes,
						hiddenEdgeTypes: hiddenEdgeTypes
					});
					sessionStructureKey = structureKey;

					// Rebuild graph and apply ELK result
					layoutGraph = LayoutGraph.fromTopology(layoutNodes);
					layoutGraph.syncCollapseState(collapsed);
					// Restore expanded sizes for collapsed containers before applying ELK
					// results — applyElkResult skips them since ELK only has collapsed dims.
					// Only restore on non-structural changes (collapse/expand); on structural
					// rebuilds the old sizes may be stale (different child sets).
					if (expandedContainerSizes && !isNewStructure) {
						layoutGraph.restoreExpandedSizes(expandedContainerSizes);
					}
					layoutGraph.applyElkResult(
						elkResult.nodePositions,
						elkResult.containerSizes,
						elkResult.elementNodeSizes,
						elkResult.edgeHandles
					);
				}

				// Local size adjustment for port expansion (no full ELK re-layout)
				const currentExpandedPorts = get(expandedPortNodeIds);
				const portsChanged =
					currentExpandedPorts.size !== prevExpandedPortIds.size ||
					[...currentExpandedPorts].some((id) => !prevExpandedPortIds.has(id)) ||
					[...prevExpandedPortIds].some((id) => !currentExpandedPorts.has(id));

				if (portsChanged && !isNewStructure && layoutGraph) {
					// Phase 1: Render with current positions to let DOM update port content
					const measureNodes = sortFlowNodes(buildFlowNodes(false));
					nodes.set(measureNodes);
					await tick();
					await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));

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
				} else if (isNewStructure) {
					prevExpandedPortIds = new Set(currentExpandedPorts);
				}

				// Subgroup collapse/expand is handled by syncCollapseState which calls
				// collapse()/expand() with proper targeted reflowChildren(changedChildId).
				// No additional blanket reflow needed here.

				let layoutResult = layoutGraph?.toLayoutResult() ?? {
					nodePositions: new Map(),
					containerSizes: new Map(),
					elementNodeSizes: new Map(),
					edgeHandles: new Map()
				};

				// Skip handle preservation on perspective change
				if (currentPerspective !== prevPerspective) {
					layoutResult = { ...layoutResult, edgeHandles: new Map() };
					prevPerspective = currentPerspective;
				}

				// Save current state before rebuilding
				const currentEdges = get(edges);
				const animatedStates = new Map(currentEdges.map((edge) => [edge.id, edge.animated]));

				// Build final nodes with positions from graph
				const needsLayout = isNewStructure || portsChanged || collapseChanged;
				const allNodes = sortFlowNodes(buildFlowNodes(needsLayout));

				// Clear edges, set positioned nodes (keep isMeasuring until paint completes)
				edges.set([]);
				nodes.set(allNodes);

				// Build base edges: filter out edges with collapsed endpoints
				let baseEdges: TopologyEdge[];
				const extraFlowEdges: Edge[] = [];

				if (collapsed.size > 0 && aggregatedEdges.length > 0) {
					// Filter out edges where source or target is inside a collapsed container
					baseEdges = topology.edges.filter((edge) => {
						const srcContainer = elementToContainer.get(edge.source as string);
						const tgtContainer = elementToContainer.get(edge.target as string);
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

				// Filter visible edges (disabled edges excluded entirely, hidden types excluded before bundling)
				const nonDisabledEdges = baseEdges.filter((e) => e.classification !== 'disabled');
				const visibleEdges = nonDisabledEdges.filter((e) => !hiddenEdgeTypes.includes(e.edge_type));

				let flowEdges: Edge[];
				const currentExpandedBundles = get(expandedBundles);

				if ($topologyOptions.local.bundle_edges) {
					const { bundles, unbundled } = bundleEdges(visibleEdges, elementToContainer);
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
				const hiddenEdges = nonDisabledEdges.filter((e) => hiddenEdgeTypes.includes(e.edge_type));
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

				// Reveal after positioned nodes + edges have painted
				// Double rAF ensures the compositing pass completes before revealing
				await tick();
				await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
				isMeasuring = false;

				lastRenderedTopoKey = topoKey;
				lastRenderedPerspective = currentPerspective;
			}
		} catch (err) {
			pushError(`Failed to parse topology data ${err}`);
		}
	}

	function createFlowEdge(
		edge: TopologyEdge,
		index: number,
		layoutResult: import('../../layout/engine').LayoutResult,
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
		const containerIds = topology.nodes.filter((n) => n.node_type === 'Container').map((n) => n.id);
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
