import { get } from 'svelte/store';
import type { Edge, EdgeMarkerType } from '@xyflow/svelte';
import type { TopologyEdge, Topology } from '../types/base';
import type { EdgeHandles } from '../layout/elk-layout';
import { computeOptimalHandles } from '../layout/elk-layout';
import type { SelectionStores } from '../selection';
import type { AggregatedEdge } from '../collapse';
import type { LayoutGraph } from '../layout/layout-graph';
import { edgeTypes } from '$lib/shared/stores/metadata';
import { getEdgeDisplayState, searchHiddenNodeIds, tagHiddenNodeIds } from '../interactions';
import { isDisabledEdge, isDashedEdge } from '../layout/edge-classification';
import { bundleEdges } from '../layout/edge-bundling';

export interface CreateFlowEdgeParams {
	edge: TopologyEdge;
	index: number;
	edgeHandles: Map<string, EdgeHandles>;
	selectionStores: SelectionStores;
	extraData?: Record<string, unknown>;
}

export function createFlowEdge(params: CreateFlowEdgeParams): Edge {
	const { edge, index, edgeHandles: handles, selectionStores, extraData } = params;

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
			handles.get(`${edge.source}->${edge.target}`)?.sourceHandle ?? edge.source_handle
		).toString(),
		targetHandle: (
			handles.get(`${edge.source}->${edge.target}`)?.targetHandle ?? edge.target_handle
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

export interface BuildFlowEdgesParams {
	elevatedEdges: TopologyEdge[];
	collapsed: Set<string>;
	elementToContainer: Map<string, string>;
	aggregatedEdges: AggregatedEdge[];
	hiddenEdgeTypes: string[];
	layoutNodes: import('../types/base').TopologyNode[];
	topology: Topology;
	edgeHandles: Map<string, EdgeHandles>;
	layoutGraph: LayoutGraph | null;
	bundleEnabled: boolean;
	currentExpandedBundles: Set<string>;
	selectionStores: SelectionStores;
}

export interface BuildFlowEdgesResult {
	flowEdges: Edge[];
	originalsMap: Map<string, TopologyEdge[]>;
}

export function buildFlowEdges(params: BuildFlowEdgesParams): BuildFlowEdgesResult {
	const {
		elevatedEdges,
		collapsed,
		elementToContainer,
		aggregatedEdges,
		hiddenEdgeTypes,
		layoutNodes,
		topology,
		edgeHandles: edgeHandlesMap,
		layoutGraph,
		bundleEnabled,
		currentExpandedBundles,
		selectionStores
	} = params;

	let baseEdges: TopologyEdge[];
	const extraFlowEdges: Edge[] = [];
	const originalsMap = new Map<string, TopologyEdge[]>();

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
		for (let index = 0; index < aggregatedEdges.length; index++) {
			const agg = aggregatedEdges[index];
			originalsMap.set(agg.id, agg.originalEdges);
			const edgeKey = `${agg.source}->${agg.target}`;
			let handles = edgeHandlesMap.get(edgeKey);

			// Derive handles from original element-level edges' cached handles
			if (!handles && agg.originalEdges.length > 0) {
				handles = deriveAggregatedHandles(agg, collapsed, topology, edgeHandlesMap);
			}

			// Fall back to position-based computation if no original handles found
			if (!handles && layoutGraph) {
				const srcPos = layoutGraph.getAbsolutePosition(agg.source);
				const tgtPos = layoutGraph.getAbsolutePosition(agg.target);
				const srcSize = layoutGraph.getContainerSize(agg.source);
				const tgtSize = layoutGraph.getContainerSize(agg.target);
				if (srcPos && tgtPos && srcSize && tgtSize) {
					handles = computeOptimalHandles(srcPos, { w: srcSize.width, h: srcSize.height }, tgtPos, {
						w: tgtSize.width,
						h: tgtSize.height
					});
				}
			}

			const aggFlowEdge: Edge = {
				id: agg.id,
				source: agg.source,
				target: agg.target,
				sourceHandle: (handles?.sourceHandle ?? 'Bottom').toString(),
				targetHandle: (handles?.targetHandle ?? 'Top').toString(),
				type: 'custom',
				label: undefined,
				data: {
					...agg.originalEdges[0],
					source: agg.source,
					target: agg.target,
					isAggregated: true,
					aggregatedCount: agg.count,
					edgeIndex: 1000 + index
				},
				animated: false,
				interactionWidth: 50
			};

			// Compute display state (same pattern as createFlowEdge)
			const curNode = get(selectionStores.selectedNode);
			const curEdge = get(selectionStores.selectedEdge);
			const searchHidden = get(searchHiddenNodeIds);
			const tagHidden = get(tagHiddenNodeIds);
			const { shouldAnimate, shouldShowFull, isEndpointSearchHidden, isEndpointTagHidden } =
				getEdgeDisplayState(aggFlowEdge, curNode, curEdge, searchHidden, tagHidden);
			aggFlowEdge.data = {
				...aggFlowEdge.data,
				shouldShowFull,
				shouldAnimate,
				isSelected: curEdge?.id === aggFlowEdge.id,
				hasActiveSelection: !!(curNode || curEdge),
				isEndpointSearchHidden,
				isEndpointTagHidden
			};

			extraFlowEdges.push(aggFlowEdge);
		}
	} else {
		baseEdges = elevatedEdges;
	}

	// Filter visible edges
	const nonDisabledEdges = baseEdges.filter((e) => !isDisabledEdge(e));
	const visibleEdgesRaw = nonDisabledEdges.filter((e) => !hiddenEdgeTypes.includes(e.edge_type));

	// Build root container lookup
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
	const visibleEdges: TopologyEdge[] = visibleEdgesRaw
		.filter((e) => e.source !== e.target)
		.map((e) => {
			const srcRoot = getRootContainer(e.source as string);
			const tgtRoot = getRootContainer(e.target as string);
			if (srcRoot === tgtRoot && e.label) {
				return { ...e, label: null } as TopologyEdge;
			}
			return e;
		});

	let flowEdges: Edge[];
	const createParams = { edgeHandles: edgeHandlesMap, selectionStores };

	if (bundleEnabled) {
		const { bundles, unbundled } = bundleEdges(visibleEdges, elementToContainer);
		flowEdges = [];
		let edgeIndex = 0;

		for (const edge of unbundled) {
			flowEdges.push(createFlowEdge({ ...createParams, edge, index: edgeIndex++ }));
		}

		for (const bundle of bundles) {
			if (currentExpandedBundles.has(bundle.id)) {
				const fanTotal = bundle.edges.length;
				for (let i = 0; i < fanTotal; i++) {
					flowEdges.push(
						createFlowEdge({
							...createParams,
							edge: bundle.edges[i],
							index: edgeIndex++,
							extraData: {
								bundleId: bundle.id,
								bundleFanIndex: i,
								bundleFanTotal: fanTotal
							}
						})
					);
				}
			} else {
				const representative = bundle.edges[0];
				const bundleStrokeWidth = Math.min(2 + 0.5 * (bundle.count - 1), 6);
				flowEdges.push(
					createFlowEdge({
						...createParams,
						edge: representative,
						index: edgeIndex++,
						extraData: {
							isBundle: true,
							bundleId: bundle.id,
							bundleCount: bundle.count,
							bundleEdges: bundle.edges,
							bundleStrokeWidth,
							bundleIsOverlay: isDashedEdge(representative)
						}
					})
				);
			}
		}
	} else {
		flowEdges = visibleEdges.map((edge, index) => createFlowEdge({ ...createParams, edge, index }));
	}

	// Add hidden edges (get filtered by CustomEdge's hideEdge logic)
	const hiddenEdges = nonDisabledEdges.filter((e) => hiddenEdgeTypes.includes(e.edge_type));
	for (const edge of hiddenEdges) {
		flowEdges.push(createFlowEdge({ ...createParams, edge, index: flowEdges.length }));
	}

	// Add aggregated collapse edges
	flowEdges.push(...extraFlowEdges);

	return { flowEdges, originalsMap };
}

/**
 * Derive handles for an aggregated edge from its original element-level edges.
 * Resolves each original edge's source to its collapsed ancestor to determine alignment.
 */
function deriveAggregatedHandles(
	agg: AggregatedEdge,
	collapsed: Set<string>,
	topology: Topology,
	edgeHandlesMap: Map<string, EdgeHandles>
): EdgeHandles | undefined {
	// Build parent map for ancestor resolution
	const parentMap = new Map<string, string>();
	for (const node of topology.nodes) {
		if (node.node_type === 'Element') {
			const pid =
				(node as Record<string, unknown>).container_id ??
				(node as Record<string, unknown>).subnet_id;
			if (typeof pid === 'string') parentMap.set(node.id, pid);
		} else if (node.node_type === 'Container') {
			const pid = (node as Record<string, unknown>).parent_container_id as string | undefined;
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
			edgeHandlesMap.get(origKey) ?? edgeHandlesMap.get(`${origEdge.target}->${origEdge.source}`);
		if (origHandles) {
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
		return {
			sourceHandle: srcH as 'Top' | 'Bottom' | 'Left' | 'Right',
			targetHandle: tgtH as 'Top' | 'Bottom' | 'Left' | 'Right'
		};
	}

	return undefined;
}
