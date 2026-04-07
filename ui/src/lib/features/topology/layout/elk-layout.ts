import type { ElkNode, ElkExtendedEdge } from 'elkjs';
import type { TopologyNode } from '../types/base';
import { isDisabledEdge, affectsLayout } from './edge-classification';
import { containerTypes } from '$lib/shared/stores/metadata';
import type { LayoutInput, LayoutResult } from './engine';

/** @deprecated Use LayoutInput from engine.ts */
export type ElkLayoutInput = LayoutInput;

export type HandleSide = 'Top' | 'Bottom' | 'Left' | 'Right';

export interface EdgeHandles {
	sourceHandle: HandleSide;
	targetHandle: HandleSide;
}

/** @deprecated Use LayoutResult from engine.ts */
export type ElkLayoutResult = LayoutResult;

// @ts-expect-error -- elkjs module import type works at runtime but svelte-check disagrees
let elkPromise: Promise<import('elkjs')['default']> | null = null;

// @ts-expect-error -- elkjs module import type works at runtime but svelte-check disagrees
async function getElk(): Promise<import('elkjs/lib/elk-api')['default']> {
	if (!elkPromise) {
		elkPromise = import('elkjs/lib/elk.bundled.js').then((mod) => {
			const ELK = mod.default;
			return new ELK();
		});
	}
	return elkPromise;
}

/** Root-level ELK layout options for layered compound layout. */
const ROOT_LAYOUT_OPTIONS: Record<string, string> = {
	'elk.algorithm': 'layered',
	'elk.direction': 'DOWN',
	'elk.layered.spacing.nodeNodeBetweenLayers': '30',
	'elk.layered.spacing.edgeNodeBetweenLayers': '15',
	'elk.edgeRouting': 'POLYLINE',
	'elk.layered.spacing.edgeEdgeBetweenLayers': '10',
	'elk.spacing.componentComponent': '50',
	'elk.spacing.nodeNode': '40',
	'elk.layered.nodePlacement.strategy': 'NETWORK_SIMPLEX',
	'elk.layered.crossingMinimization.strategy': 'LAYER_SWEEP',
	'elk.hierarchyHandling': 'SEPARATE_CHILDREN',
	'elk.layered.layering.strategy': 'NETWORK_SIMPLEX',
	'elk.layered.compaction.postCompaction.strategy': 'LEFT_RIGHT_CONSTRAINT_LOCKING',
	'elk.aspectRatio': '1.6',
	'elk.padding': '[top=20,left=20,bottom=20,right=20]'
};

/**
 * Build an ELK graph from topology data.
 * Containers become parent nodes; elements become children inside their container.
 * Only layout-affecting edges are included in the ELK graph.
 */
function buildElkGraph(
	input: ElkLayoutInput,
	elementPositions?: Map<string, { x: number; w: number; containerW: number }>
): {
	graph: ElkNode;
	containerIds: Set<string>;
} {
	const containers: Map<string, ElkNode> = new Map();
	const containerIds = new Set<string>();

	const collapsed = input.collapsedContainers ?? new Set<string>();

	// Track parent relationships for nested containers
	const parentContainerMap = new Map<string, string>();

	// Determine if the current view benefits from layered child layout
	// (crossing minimization for port-to-port edges)
	const view = input.topology?.options?.request?.view;
	const useLayeredChildren = view === 'L2Physical';

	// Create container (parent) nodes
	for (const node of input.nodes) {
		if (node.node_type === 'Container') {
			containerIds.add(node.id);
			const isCollapsed = collapsed.has(node.id);
			const containerType =
				((node as Record<string, unknown>).container_type as string) ?? 'Subnet';
			const meta = containerTypes.getMetadata(containerType);
			const isSubcontainer = meta.is_subcontainer;
			const parentId = (node as Record<string, unknown>).parent_container_id as string | undefined;
			if (parentId) parentContainerMap.set(node.id, parentId);

			const p = meta.padding;
			const padding = `[top=${p.top},left=${p.left},bottom=${p.bottom},right=${p.right}]`;

			// Use DOM-measured size for collapsed containers when available,
			// falling back to static metadata for the initial render
			const measured = input.elementNodeSizes?.get(node.id);
			const collapsedWidth = measured?.x ?? meta.collapsed_size.width;
			const collapsedHeight = measured?.y ?? meta.collapsed_size.height;
			// Use expanded width for collapsed containers so ELK reserves horizontal
			// space — prevents neighbors from being placed where they'd overlap on expand
			const expandedWidth = input.expandedContainerSizes?.get(node.id)?.width;
			const elkCollapsedWidth = expandedWidth ?? collapsedWidth;

			// Layered children: ELK optimizes child ordering for crossing minimization
			// Box children: grid packing by size (default for most views)
			const childLayoutOptions: Record<string, string> = useLayeredChildren
				? {
						// With INCLUDE_CHILDREN, the root layered algorithm handles child
						// placement and crossing minimization — container just sets padding
						'elk.padding': padding,
						'elk.nodeSize.constraints': 'MINIMUM_SIZE',
						'elk.spacing.nodeNode': '10'
					}
				: {
						'elk.algorithm': 'box',
						'elk.box.packingMode': 'SIMPLE',
						'elk.aspectRatio': '1.4',
						'elk.padding': padding,
						'elk.nodeSize.constraints': 'MINIMUM_SIZE',
						'elk.spacing.nodeNode': '25'
					};

			const elkNode: ElkNode = isCollapsed
				? {
						id: node.id,
						width: elkCollapsedWidth,
						height: collapsedHeight,
						children: [],
						layoutOptions: {
							'elk.nodeSize.constraints': 'MINIMUM_SIZE',
							'elk.nodeSize.minimum': `(${elkCollapsedWidth},${collapsedHeight})`
						}
					}
				: {
						id: node.id,
						children: [],
						layoutOptions: childLayoutOptions
					};
			containers.set(node.id, elkNode);
		}
	}

	// Nest sub-group containers inside their parent containers
	for (const [childId, parentId] of parentContainerMap) {
		const parent = containers.get(parentId);
		const child = containers.get(childId);
		if (parent && child && parent.children) {
			parent.children.push(child);
		}
	}

	// Subcontainer children sorted after elements are added (below)

	// Build dual element→container mappings:
	// - immediate: direct parent container (may be a subcontainer)
	// - root: resolved through subcontainers to root-level container
	const elementToImmediateContainer = new Map<string, string>();
	const elementToRootContainer = new Map<string, string>();
	for (const node of input.nodes) {
		if (node.node_type === 'Element') {
			const parentId = node.container_id;
			if (typeof parentId === 'string' && containers.has(parentId)) {
				elementToImmediateContainer.set(node.id, parentId);
				let rootId = parentId;
				while (parentContainerMap.has(rootId)) {
					rootId = parentContainerMap.get(rootId)!;
				}
				elementToRootContainer.set(node.id, rootId);
			}
		}
	}

	// Add element nodes as children of their containers (skip collapsed)
	for (const node of input.nodes) {
		if (node.node_type === 'Element') {
			const parentId = node.container_id;
			if (collapsed.has(parentId)) continue;
			const parent = containers.get(parentId);
			if (parent && parent.children) {
				const size = input.elementNodeSizes?.get(node.id) ?? node.size;
				parent.children.push({
					id: node.id,
					width: size.x,
					height: size.y,
					layoutOptions: {
						'elk.nodeSize.constraints': 'MINIMUM_SIZE',
						'elk.nodeSize.minimum': `(${size.x},${size.y})`
					}
				});
			}
		}
	}

	// Helper: resolve an edge endpoint to its root container
	const resolveRoot = (id: string): string | undefined => {
		const fromElem = elementToRootContainer.get(id);
		if (fromElem) return fromElem;
		if (!containerIds.has(id)) return undefined;
		let rootId = id;
		while (parentContainerMap.has(rootId)) {
			rootId = parentContainerMap.get(rootId)!;
		}
		return rootId;
	};

	// Build element → target root container(s) mapping for edge-aware sorting.
	// Elements connecting to the same target should be adjacent in the grid so
	// their ports cluster together, giving ELK meaningful crossing information.
	const elementTargets = new Map<string, Set<string>>();
	for (const edge of input.edges) {
		if (!affectsLayout(edge)) continue;
		const srcRoot = resolveRoot(edge.source);
		const tgtRoot = resolveRoot(edge.target);
		if (!srcRoot || !tgtRoot || srcRoot === tgtRoot) continue;

		// Map source element → target container
		if (elementToRootContainer.has(edge.source)) {
			if (!elementTargets.has(edge.source)) elementTargets.set(edge.source, new Set());
			elementTargets.get(edge.source)!.add(tgtRoot);
		}
		// Map target element → source container (reverse direction)
		if (elementToRootContainer.has(edge.target)) {
			if (!elementTargets.has(edge.target)) elementTargets.set(edge.target, new Set());
			elementTargets.get(edge.target)!.add(srcRoot);
		}
	}

	// Sort children: elements grouped by target, then elements without edges, then subcontainers.
	// Within target groups, elements connecting to the same target are adjacent.
	// Group order is by first target ID (arbitrary but stable) — ELK will reorder
	// the target containers to match via crossing minimization.
	for (const [containerId, container] of containers) {
		if (!container.children || container.children.length < 2) continue;
		if (parentContainerMap.has(containerId)) continue;

		container.children.sort((a, b) => {
			const aIsSub = containerIds.has(a.id) ? 1 : 0;
			const bIsSub = containerIds.has(b.id) ? 1 : 0;
			if (aIsSub !== bIsSub) return aIsSub - bIsSub;
			if (aIsSub && bIsSub) return a.id.localeCompare(b.id);

			// Both are elements: sort by target group
			const aTargets = elementTargets.get(a.id);
			const bTargets = elementTargets.get(b.id);
			const aHasEdge = aTargets && aTargets.size > 0;
			const bHasEdge = bTargets && bTargets.size > 0;

			// Elements without edges go in the middle (sort group 1)
			// Elements with edges go at the edges of the grid (sort group 0 or 2)
			// — but we just need them grouped by target, so put them all before no-edge elements
			if (aHasEdge && !bHasEdge) return -1;
			if (!aHasEdge && bHasEdge) return 1;
			if (!aHasEdge && !bHasEdge) return a.id.localeCompare(b.id);

			// Both have edges: group by primary target (sorted target IDs as group key)
			const aKey = Array.from(aTargets!).sort().join(',');
			const bKey = Array.from(bTargets!).sort().join(',');
			if (aKey !== bKey) return aKey.localeCompare(bKey);

			return a.id.localeCompare(b.id);
		});
	}

	// Create port-based edges for cross-container connections.
	// Ports encode the relative order of edge sources within a container so ELK's
	// crossing minimization can meaningfully order same-layer target containers.
	//
	// Port positions are distributed evenly across the container width, ordered by
	// target group. Box packing internally reorders elements by size, so predicting
	// actual element positions is unreliable. What matters is the RELATIVE order:
	// elements connecting to "left" targets get left-side ports, "right" targets
	// get right-side ports.
	const edges: ElkExtendedEdge[] = [];
	const seenEdges = new Set<string>();
	let edgeIndex = 0;

	// Collect all cross-container edges grouped by source container
	const edgesBySourceContainer = new Map<
		string,
		{ source: string; target: string; srcRoot: string; tgtRoot: string }[]
	>();
	for (const edge of input.edges) {
		if (!affectsLayout(edge)) continue;
		const key = `${edge.source}->${edge.target}`;
		if (seenEdges.has(key)) continue;
		seenEdges.add(key);

		const srcRoot = resolveRoot(edge.source);
		const tgtRoot = resolveRoot(edge.target);
		if (!srcRoot || !tgtRoot || srcRoot === tgtRoot) continue;

		if (!edgesBySourceContainer.has(srcRoot)) edgesBySourceContainer.set(srcRoot, []);
		edgesBySourceContainer
			.get(srcRoot)!
			.push({ source: edge.source, target: edge.target, srcRoot, tgtRoot });
	}

	// For each source container, distribute ports evenly ordered by target group
	for (const [srcContainerId, containerEdges] of edgesBySourceContainer) {
		const container = containers.get(srcContainerId);
		if (!container) continue;

		// Group edges by source element, then sort elements by their target group key
		// (same key = same target set → adjacent ports)
		const elementEdges = new Map<string, Set<string>>();
		for (const e of containerEdges) {
			if (!elementEdges.has(e.source)) elementEdges.set(e.source, new Set());
			elementEdges.get(e.source)!.add(e.tgtRoot);
		}
		const sortedElements = Array.from(elementEdges.entries()).sort(([, aTargets], [, bTargets]) => {
			const aKey = Array.from(aTargets).sort().join(',');
			const bKey = Array.from(bTargets).sort().join(',');
			return aKey.localeCompare(bKey);
		});

		if (!container.ports) container.ports = [];
		if (!container.layoutOptions) container.layoutOptions = {};

		const useFixedPos = elementPositions && elementPositions.size > 0;
		container.layoutOptions['elk.portConstraints'] = useFixedPos ? 'FIXED_POS' : 'FIXED_SIDE';

		const elementPortIds = new Map<string, string>();
		for (const [elemId] of sortedElements) {
			const portId = `port-${elemId}-SOUTH`;
			const pos = elementPositions?.get(elemId);
			if (useFixedPos && pos) {
				// Pass 2: place port at the element's actual x center within the container
				container.ports.push({
					id: portId,
					x: pos.x + pos.w / 2,
					y: pos.containerW * 0.7, // approximate container height
					width: 1,
					height: 1,
					layoutOptions: { 'elk.port.side': 'SOUTH' }
				});
			} else {
				// Pass 1: let ELK decide port positions
				container.ports.push({
					id: portId,
					layoutOptions: { 'elk.port.side': 'SOUTH' }
				});
			}
			elementPortIds.set(elemId, portId);
		}

		// Create edges from source ports to target containers (or target ports)
		for (const e of containerEdges) {
			const srcPortId = elementPortIds.get(e.source);
			if (!srcPortId) continue;

			// Target: always route to the target ROOT container.
			// If the target is an element inside a container, create a NORTH port
			// on the target container so ELK knows the edge enters from the top.
			const tgtContainer = containers.get(e.tgtRoot);
			let tgtEndpoint = e.tgtRoot;
			if (tgtContainer && !containerIds.has(e.target)) {
				// Target is an element, not a container — add a NORTH port on its container
				const tgtPortId = `port-${e.target}-NORTH`;
				if (!tgtContainer.ports) tgtContainer.ports = [];
				if (!tgtContainer.ports.some((p: { id: string }) => p.id === tgtPortId)) {
					if (!tgtContainer.layoutOptions) tgtContainer.layoutOptions = {};
					tgtContainer.layoutOptions['elk.portConstraints'] = 'FIXED_SIDE';
					tgtContainer.ports.push({
						id: tgtPortId,
						layoutOptions: { 'elk.port.side': 'NORTH' }
					});
				}
				tgtEndpoint = tgtPortId;
			}

			edges.push({
				id: `elk-edge-${edgeIndex++}`,
				sources: [srcPortId],
				targets: [tgtEndpoint]
			});
		}
	}

	// Detect cross-child edges within the same root container (e.g., element → ByVirtualizer
	// subcontainer, or Docker element → ByStack subcontainer). These edges need inner ELK edges
	// so the root container can use layered algorithm to position connected children adjacently.
	const rootsWithCrossChildEdges = new Set<string>();
	const seenInnerEdges = new Map<string, Set<string>>();

	for (const edge of input.edges) {
		if (!affectsLayout(edge)) continue;

		const srcImm =
			elementToImmediateContainer.get(edge.source) ??
			(containerIds.has(edge.source) ? edge.source : undefined);
		const tgtImm =
			elementToImmediateContainer.get(edge.target) ??
			(containerIds.has(edge.target) ? edge.target : undefined);
		const srcRoot = resolveRoot(edge.source);
		const tgtRoot = resolveRoot(edge.target);

		if (!srcImm || !tgtImm) continue;
		if (srcImm === tgtImm) continue;
		if (!srcRoot || !tgtRoot || srcRoot !== tgtRoot) continue;

		// Cross-child edge within same root
		const srcNode = srcImm === srcRoot ? edge.source : srcImm;
		const tgtNode = tgtImm === tgtRoot ? edge.target : tgtImm;
		if (srcNode === tgtNode) continue;

		rootsWithCrossChildEdges.add(srcRoot);
		const key = `${srcNode}->${tgtNode}`;
		if (!seenInnerEdges.has(srcRoot)) seenInnerEdges.set(srcRoot, new Set());
		const seen = seenInnerEdges.get(srcRoot)!;
		if (!seen.has(key) && !seen.has(`${tgtNode}->${srcNode}`)) {
			seen.add(key);
			const rootContainer = containers.get(srcRoot);
			if (rootContainer) {
				if (!rootContainer.edges) rootContainer.edges = [];
				rootContainer.edges.push({
					id: `elk-inner-edge-${edgeIndex++}`,
					sources: [srcNode],
					targets: [tgtNode]
				});
			}
		}
	}

	// Switch root containers with cross-child edges from box to layered
	for (const rootId of rootsWithCrossChildEdges) {
		const container = containers.get(rootId);
		if (container?.layoutOptions) {
			container.layoutOptions['elk.algorithm'] = 'layered';
			container.layoutOptions['elk.direction'] = 'DOWN';
			container.layoutOptions['elk.hierarchyHandling'] = 'SEPARATE_CHILDREN';
			container.layoutOptions['elk.layered.nodePlacement.strategy'] = 'NETWORK_SIMPLEX';
			container.layoutOptions['elk.layered.crossingMinimization.strategy'] = 'LAYER_SWEEP';
			container.layoutOptions['elk.layered.layering.strategy'] = 'NETWORK_SIMPLEX';
			container.layoutOptions['elk.spacing.nodeNode'] = '15';
			container.layoutOptions['elk.layered.spacing.nodeNodeBetweenLayers'] = '10';
			container.layoutOptions['elk.layered.spacing.edgeNodeBetweenLayers'] = '5';
			container.layoutOptions['elk.layered.compaction.postCompaction.strategy'] = 'EDGE_LENGTH';
			delete container.layoutOptions['elk.box.packingMode'];
		}
	}

	// For layered containers, also add element↔element edges within the same container
	if (rootsWithCrossChildEdges.size > 0) {
		for (const edge of input.edges) {
			if (!affectsLayout(edge)) continue;
			const srcImm =
				elementToImmediateContainer.get(edge.source) ??
				(containerIds.has(edge.source) ? edge.source : undefined);
			const tgtImm =
				elementToImmediateContainer.get(edge.target) ??
				(containerIds.has(edge.target) ? edge.target : undefined);
			if (srcImm && tgtImm && srcImm === tgtImm && rootsWithCrossChildEdges.has(srcImm)) {
				const key = `${edge.source}->${edge.target}`;
				if (!seenInnerEdges.has(srcImm)) seenInnerEdges.set(srcImm, new Set());
				const seen = seenInnerEdges.get(srcImm)!;
				if (!seen.has(key) && !seen.has(`${edge.target}->${edge.source}`)) {
					seen.add(key);
					const container = containers.get(srcImm);
					if (container) {
						if (!container.edges) container.edges = [];
						container.edges.push({
							id: `elk-inner-edge-${edgeIndex++}`,
							sources: [edge.source],
							targets: [edge.target]
						});
					}
				}
			}
		}
	}

	// Only add root-level containers (not nested sub-groups) to root children
	const rootContainers = Array.from(containers.entries())
		.filter(([id]) => !parentContainerMap.has(id))
		.map(([, node]) => node);

	// For L2 Physical, use INCLUDE_CHILDREN so ELK can optimize crossing
	// minimization across container boundaries (port-to-port edges)
	const rootOptions = useLayeredChildren
		? {
				...ROOT_LAYOUT_OPTIONS,
				'elk.hierarchyHandling': 'INCLUDE_CHILDREN',
				'elk.direction': 'RIGHT'
			}
		: ROOT_LAYOUT_OPTIONS;

	const graph: ElkNode = {
		id: 'root',
		layoutOptions: rootOptions,
		children: rootContainers,
		edges
	};

	return { graph, containerIds };
}

/**
 * Compute optimal handle sides based on relative position of source and target.
 * Biases toward vertical handles (Top/Bottom) since containers are typically
 * stacked vertically — horizontal handles cause edges to cross through
 * adjacent elements. Only uses Left/Right when the edge is very horizontal
 * (target at nearly the same vertical level).
 */
export function computeOptimalHandles(
	srcPos: { x: number; y: number },
	srcSize: { w: number; h: number },
	tgtPos: { x: number; y: number },
	tgtSize: { w: number; h: number }
): EdgeHandles {
	const srcCx = srcPos.x + srcSize.w / 2;
	const srcCy = srcPos.y + srcSize.h / 2;
	const tgtCx = tgtPos.x + tgtSize.w / 2;
	const tgtCy = tgtPos.y + tgtSize.h / 2;

	const dx = tgtCx - srcCx;
	const dy = tgtCy - srcCy;

	// Bias toward vertical handles: use horizontal only when |dx| > 2.5 * |dy|
	// (roughly 68° from vertical). This ensures edges to containers that are
	// below-and-to-the-side use Bottom/Top handles, routing cleanly downward
	// instead of horizontally through adjacent elements.
	const useVertical = Math.abs(dy) * 2.5 >= Math.abs(dx);

	if (useVertical) {
		if (dy >= 0) {
			return { sourceHandle: 'Bottom', targetHandle: 'Top' };
		} else {
			return { sourceHandle: 'Top', targetHandle: 'Bottom' };
		}
	} else {
		if (dx >= 0) {
			return { sourceHandle: 'Right', targetHandle: 'Left' };
		} else {
			return { sourceHandle: 'Left', targetHandle: 'Right' };
		}
	}
}

/** Recompute y-coordinates for a column of nodes based on actual heights. */
function recomputeColumnY(colNodes: ElkNode[], spacing: number): void {
	colNodes.sort((a, b) => (a.y ?? 0) - (b.y ?? 0));
	const startY = colNodes[0].y ?? 0;
	let y = startY;
	for (const node of colNodes) {
		node.y = y;
		y += (node.height ?? 0) + spacing;
	}
}

function mapElkResults(
	layoutResult: ElkNode,
	containerIds: Set<string>,
	input: ElkLayoutInput
): ElkLayoutResult {
	const nodePositions = new Map<string, { x: number; y: number }>();
	const containerSizes = new Map<string, { width: number; height: number }>();

	// Track absolute positions for handle computation (elements need container offset)
	const absolutePositions = new Map<string, { x: number; y: number }>();

	// Recursively map container and child positions
	function processChildren(children: ElkNode[], parentAbsX: number, parentAbsY: number) {
		for (const child of children) {
			const cx = child.x ?? 0;
			const cy = child.y ?? 0;
			const absX = parentAbsX + cx;
			const absY = parentAbsY + cy;

			if (containerIds.has(child.id)) {
				// Container node: position relative to parent, track absolute
				nodePositions.set(child.id, { x: cx, y: cy });
				absolutePositions.set(child.id, { x: absX, y: absY });
				containerSizes.set(child.id, {
					width: child.width ?? 0,
					height: child.height ?? 0
				});
				// Recurse into children (nested containers or elements)
				if (child.children) {
					processChildren(child.children, absX, absY);
				}
			} else {
				// Element node: position relative to parent for SvelteFlow
				nodePositions.set(child.id, { x: cx, y: cy });
				absolutePositions.set(child.id, { x: absX, y: absY });
			}
		}
	}

	if (layoutResult.children) {
		processChildren(layoutResult.children, 0, 0);
	}

	// Compute optimal edge handles using absolute positions
	const edgeHandles = new Map<string, EdgeHandles>();
	const nodeSizes = new Map<string, { w: number; h: number }>();
	for (const node of input.nodes) {
		// Use ELK-computed size for containers, frontend-computed size for elements
		const elkSize = containerSizes.get(node.id);
		const elementSize = input.elementNodeSizes?.get(node.id);
		nodeSizes.set(node.id, {
			w: elkSize?.width ?? elementSize?.x ?? node.size.x,
			h: elkSize?.height ?? elementSize?.y ?? node.size.y
		});
	}

	// Only compute handles for edges that will actually be rendered (not hidden or disabled)
	const hiddenEdgeSet = new Set(input.hiddenEdgeTypes ?? []);
	const renderedEdges = input.edges.filter(
		(e) => !hiddenEdgeSet.has(e.edge_type) && !isDisabledEdge(e)
	);

	for (const edge of renderedEdges) {
		const srcPos = absolutePositions.get(edge.source);
		const tgtPos = absolutePositions.get(edge.target);
		const srcSize = nodeSizes.get(edge.source);
		const tgtSize = nodeSizes.get(edge.target);
		if (srcPos && tgtPos && srcSize && tgtSize) {
			edgeHandles.set(
				`${edge.source}->${edge.target}`,
				computeOptimalHandles(srcPos, srcSize, tgtPos, tgtSize)
			);
		}
	}

	// Snap container positions to the 25px grid so they align with SvelteFlow's snapGrid.
	// Only snap containers — element positions are relative to their parent and snapping
	// them independently would break the inter-node spacing ELK computed.
	const SNAP = 25;
	for (const [id, pos] of nodePositions) {
		if (containerIds.has(id)) {
			nodePositions.set(id, {
				x: Math.round(pos.x / SNAP) * SNAP,
				y: Math.round(pos.y / SNAP) * SNAP
			});
		}
	}

	return {
		nodePositions,
		containerSizes,
		elementNodeSizes: input.elementNodeSizes ?? new Map(),
		edgeHandles
	};
}

/**
 * @deprecated Use LayoutGraph.updateElementSize() instead.
 * Kept temporarily for transition — will be removed.
 */
export function applyLocalSizeAdjustment(
	cachedResult: ElkLayoutResult,
	updatedLeafSizes: Map<string, { x: number; y: number }>,
	nodes: TopologyNode[],
	collapsed: Set<string>
): ElkLayoutResult {
	const nodePositions = new Map(cachedResult.nodePositions);
	const containerSizes = new Map(cachedResult.containerSizes);
	const leafNodeSizes = new Map(cachedResult.elementNodeSizes);

	// Build leaf→container mapping and container→children mapping
	const leafToContainer = new Map<string, string>();
	const containerChildren = new Map<string, string[]>();
	for (const node of nodes) {
		if (node.node_type === 'Element') {
			const parentId = node.container_id;
			if (parentId && !collapsed.has(parentId)) {
				leafToContainer.set(node.id, parentId);
				if (!containerChildren.has(parentId)) containerChildren.set(parentId, []);
				containerChildren.get(parentId)!.push(node.id);
			}
		}
	}

	// Build parent container map for nested containers
	const parentContainerMap = new Map<string, string>();
	for (const node of nodes) {
		if (node.node_type === 'Container') {
			const parentId = (node as Record<string, unknown>).parent_container_id as string | undefined;
			if (parentId) parentContainerMap.set(node.id, parentId);
		}
	}

	// Find affected containers
	const affectedContainers = new Set<string>();
	for (const [leafId] of updatedLeafSizes) {
		const containerId = leafToContainer.get(leafId);
		if (containerId) affectedContainers.add(containerId);
	}

	// Update leaf sizes
	for (const [id, size] of updatedLeafSizes) {
		leafNodeSizes.set(id, size);
	}

	// For each affected container, rebuild column layout
	for (const containerId of affectedContainers) {
		const childIds = containerChildren.get(containerId) ?? [];
		if (childIds.length === 0) continue;

		// Group children by x-position (column), using ELK-computed positions
		// (from cachedResult, never mutated) for Y sort order, and updated
		// heights for spacing. recomputeColumnY sorts by y then re-stacks,
		// so using computed Y preserves ELK's original column order.
		const columns = new Map<number, ElkNode[]>();
		for (const childId of childIds) {
			const computedPos = cachedResult.nodePositions.get(childId);
			const size = leafNodeSizes.get(childId);
			if (!computedPos || !size) continue;
			const x = computedPos.x;
			if (!columns.has(x)) columns.set(x, []);
			columns.get(x)!.push({
				id: childId,
				x: computedPos.x,
				y: computedPos.y,
				width: size.x,
				height: size.y
			});
		}

		// Detect container type for correct spacing/padding
		const containerNode = nodes.find((n) => n.id === containerId);
		const containerType = (containerNode as Record<string, unknown>)?.container_type as
			| string
			| undefined;
		const ctMeta = containerTypes.getMetadata(containerType ?? 'Subnet');
		const spacing = 25;
		const bottomPad = ctMeta.padding.bottom;

		// Reuse recomputeColumnY: sorts by y (= computed Y = stable order),
		// then re-stacks with updated heights
		let maxColumnBottom = 0;
		for (const [, colNodes] of columns) {
			recomputeColumnY(colNodes, spacing);
			for (const node of colNodes) {
				nodePositions.set(node.id, { x: node.x ?? 0, y: node.y ?? 0 });
			}
			const lastNode = colNodes[colNodes.length - 1];
			const columnBottom = (lastNode.y ?? 0) + (lastNode.height ?? 0);
			if (columnBottom > maxColumnBottom) maxColumnBottom = columnBottom;
		}

		// Update container height
		const newHeight = maxColumnBottom + bottomPad;
		const prevSize = containerSizes.get(containerId);
		if (prevSize) {
			const heightDelta = newHeight - prevSize.height;
			containerSizes.set(containerId, { width: prevSize.width, height: newHeight });

			// If nested in parent, grow parent and shift sibling containers
			const parentId = parentContainerMap.get(containerId);
			if (parentId && heightDelta !== 0) {
				const siblingIds = nodes
					.filter(
						(n) =>
							n.node_type === 'Container' &&
							(n as Record<string, unknown>).parent_container_id === parentId &&
							n.id !== containerId
					)
					.map((n) => n.id);

				const myPos = nodePositions.get(containerId);
				if (myPos) {
					for (const sibId of siblingIds) {
						const sibPos = nodePositions.get(sibId);
						if (sibPos && sibPos.y > myPos.y) {
							nodePositions.set(sibId, { x: sibPos.x, y: sibPos.y + heightDelta });
						}
					}
				}

				// Grow parent container
				const parentSize = containerSizes.get(parentId);
				if (parentSize) {
					containerSizes.set(parentId, {
						width: parentSize.width,
						height: parentSize.height + heightDelta
					});
				}
			}
		}
	}

	return {
		nodePositions,
		containerSizes,
		elementNodeSizes: leafNodeSizes,
		edgeHandles: cachedResult.edgeHandles
	};
}

/**
 * Apply local size adjustment when subgroups collapse/expand.
 * Adjusts subgroup sizes and reflections within their parent containers.
 */
export function applySubgroupCollapseAdjustment(
	cachedResult: ElkLayoutResult,
	nodes: TopologyNode[],
	collapsed: Set<string>,
	prevCollapsed: Set<string>
): ElkLayoutResult {
	const nodePositions = new Map(cachedResult.nodePositions);
	const containerSizes = new Map(cachedResult.containerSizes);

	// Find subgroups whose collapse state changed
	const changedSubgroups = new Set<string>();
	for (const node of nodes) {
		if (node.node_type !== 'Container') continue;
		const parentId = (node as Record<string, unknown>).parent_container_id as string | undefined;
		if (!parentId) continue; // only subgroups
		const wasCollapsed = prevCollapsed.has(node.id);
		const isCollapsed = collapsed.has(node.id);
		if (wasCollapsed !== isCollapsed) changedSubgroups.add(node.id);
	}

	if (changedSubgroups.size === 0) return cachedResult;

	// Find affected parent containers
	const affectedParents = new Set<string>();
	for (const node of nodes) {
		if (!changedSubgroups.has(node.id)) continue;
		const parentId = (node as Record<string, unknown>).parent_container_id as string | undefined;
		if (parentId) affectedParents.add(parentId);
	}

	// For each affected parent, recompute child subgroup positions
	for (const parentId of affectedParents) {
		// Gather all children of this parent (subgroups + elements not in subgroups)
		const childContainers = nodes.filter(
			(n) =>
				n.node_type === 'Container' &&
				(n as Record<string, unknown>).parent_container_id === parentId
		);

		// Group children by x-position (column) and restack
		const columns = new Map<number, { id: string; x: number; y: number; height: number }[]>();
		for (const child of childContainers) {
			const pos = nodePositions.get(child.id);
			if (!pos) continue;
			const isCollapsed = collapsed.has(child.id);
			const existingSize = containerSizes.get(child.id);
			const size = isCollapsed
				? { width: existingSize?.width ?? 250, height: 40 }
				: (existingSize ?? { width: 250, height: 100 });
			const x = pos.x;
			if (!columns.has(x)) columns.set(x, []);
			columns.get(x)!.push({ id: child.id, x: pos.x, y: pos.y, height: size.height });
		}

		// Restack each column
		let maxColumnBottom = 0;
		for (const [, colNodes] of columns) {
			colNodes.sort((a, b) => a.y - b.y);
			const startY = colNodes[0].y;
			let y = startY;
			for (const node of colNodes) {
				nodePositions.set(node.id, { x: node.x, y });
				y += node.height + 25; // spacing between subgroups (grid-aligned)
			}
			const lastNode = colNodes[colNodes.length - 1];
			const columnBottom = y - 25 + lastNode.height; // undo last spacing
			if (columnBottom > maxColumnBottom) maxColumnBottom = columnBottom;
		}

		// Update parent container height
		const parentSize = containerSizes.get(parentId);
		if (parentSize) {
			const newHeight = maxColumnBottom + 25; // bottom padding
			containerSizes.set(parentId, { width: parentSize.width, height: newHeight });
		}
	}

	return {
		nodePositions,
		containerSizes,
		elementNodeSizes: cachedResult.elementNodeSizes,
		edgeHandles: cachedResult.edgeHandles
	};
}

/**
 * Compute layout positions using elkjs compound layered algorithm.
 * Returns positions for all nodes and computed sizes for containers.
 */
export async function computeElkLayout(input: ElkLayoutInput): Promise<ElkLayoutResult> {
	if (input.nodes.length === 0) {
		return {
			nodePositions: new Map(),
			containerSizes: new Map(),
			elementNodeSizes: new Map(),
			edgeHandles: new Map()
		};
	}

	const elk = await getElk();

	// Pass 1: compute layout with FIXED_SIDE ports (no position info).
	// This gives us actual element positions within box-packed containers.
	const { graph: graph1, containerIds } = buildElkGraph(input);
	const result1 = await elk.layout(graph1);

	// Extract actual element positions from pass 1 to set accurate port positions
	const elementPositions = new Map<string, { x: number; w: number; containerW: number }>();
	function extractPositions(children: ElkNode[]) {
		for (const child of children) {
			if (containerIds.has(child.id)) {
				// Container: record width, recurse into children
				if (child.children) {
					for (const elem of child.children) {
						if (!containerIds.has(elem.id)) {
							elementPositions.set(elem.id, {
								x: elem.x ?? 0,
								w: elem.width ?? 0,
								containerW: child.width ?? 0
							});
						}
					}
					extractPositions(child.children);
				}
			}
		}
	}
	if (result1.children) extractPositions(result1.children);

	// Pass 2: rebuild graph with FIXED_POS ports at actual element positions
	const { graph: graph2, containerIds: cids2 } = buildElkGraph(input, elementPositions);
	const result2 = await elk.layout(graph2);
	return mapElkResults(result2, cids2, input);
}
