import type { ElkNode, ElkExtendedEdge } from 'elkjs';
import type { TopologyNode, TopologyEdge, Topology } from '../types/base';
import type { components } from '$lib/api/schema';
import { classifyEdge } from './edge-classification';

type SubnetType = components['schemas']['SubnetType'];

export interface ElkLayoutInput {
	nodes: TopologyNode[];
	edges: TopologyEdge[];
	topology: Topology;
	collapsedContainers?: Set<string>;
	/** Frontend-computed leaf node sizes (overrides backend node.size) */
	elementNodeSizes?: Map<string, { x: number; y: number }>;
	hiddenEdgeTypes?: string[];
}

export type HandleSide = 'Top' | 'Bottom' | 'Left' | 'Right';

export interface EdgeHandles {
	sourceHandle: HandleSide;
	targetHandle: HandleSide;
}

export interface ElkLayoutResult {
	nodePositions: Map<string, { x: number; y: number }>;
	containerSizes: Map<string, { width: number; height: number }>;
	elementNodeSizes: Map<string, { x: number; y: number }>;
	edgeHandles: Map<string, EdgeHandles>;
}

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

/** Map SubnetType to vertical layer order (lower = higher on screen). */
const SUBNET_TYPE_LAYER: Record<SubnetType, number> = {
	Internet: 0,
	Remote: 0,
	Gateway: 1,
	VpnTunnel: 1,
	Dmz: 1,
	Lan: 2,
	WiFi: 2,
	IoT: 2,
	Guest: 2,
	Management: 3,
	Storage: 3,
	DockerBridge: 4,
	MacVlan: 4,
	IpVlan: 4,
	Loopback: 999,
	Unknown: 999
};

/** Root-level ELK layout options for layered compound layout. */
const ROOT_LAYOUT_OPTIONS: Record<string, string> = {
	'elk.algorithm': 'layered',
	'elk.direction': 'DOWN',
	'elk.layered.spacing.nodeNodeBetweenLayers': '100',
	'elk.layered.spacing.edgeNodeBetweenLayers': '50',
	'elk.spacing.componentComponent': '80',
	'elk.spacing.nodeNode': '60',
	'elk.layered.nodePlacement.strategy': 'NETWORK_SIMPLEX',
	'elk.layered.crossingMinimization.strategy': 'LAYER_SWEEP',
	'elk.hierarchyHandling': 'SEPARATE_CHILDREN',
	'elk.layered.layering.strategy': 'INTERACTIVE',
	'elk.layered.compaction.postCompaction.strategy': 'LEFT_RIGHT_CONSTRAINT_LOCKING',
	'elk.aspectRatio': '1.6',
	'elk.padding': '[top=20,left=20,bottom=20,right=20]'
};

/** Container node padding (extra top for header). */
const CONTAINER_PADDING = '[top=25,left=25,bottom=25,right=25]';

/** Sub-group container padding (smaller header). */
const SUBGROUP_PADDING = '[top=30,left=15,bottom=15,right=15]';

/** Container types that represent sub-groups within a subnet. */
const SUBGROUP_CONTAINER_TYPES = new Set(['TagGroup', 'ServiceCategoryGroup']);

function getLayerHint(node: TopologyNode, topology: Topology): number {
	// Future: use layer_hint if present
	if ('layer_hint' in node && typeof (node as Record<string, unknown>).layer_hint === 'number') {
		return (node as Record<string, unknown>).layer_hint as number;
	}

	// Derive from subnet's subnet_type
	const subnet = topology.subnets.find((s) => s.id === node.id);
	if (subnet) {
		return SUBNET_TYPE_LAYER[subnet.subnet_type as SubnetType] ?? 999;
	}
	return 999;
}

/**
 * Build an ELK graph from topology data.
 * Containers become parent nodes; leaves become children inside their container.
 * Only primary edges are included (overlay edges don't affect layout).
 */
function buildElkGraph(input: ElkLayoutInput): {
	graph: ElkNode;
	containerIds: Set<string>;
	elementExternalEdgeInfo: Map<
		string,
		{ hasUpwardEdge: boolean; hasDownwardEdge: boolean; externalEdgeCount: number }
	>;
} {
	const containers: Map<string, ElkNode> = new Map();
	const containerIds = new Set<string>();

	const collapsed = input.collapsedContainers ?? new Set<string>();

	// Track parent relationships for nested containers
	const parentContainerMap = new Map<string, string>();

	// Create container (parent) nodes
	for (const node of input.nodes) {
		if (node.node_type === 'Container') {
			containerIds.add(node.id);
			const isCollapsed = collapsed.has(node.id);
			const containerType = (node as Record<string, unknown>).container_type as string | undefined;
			const isSubgroup = containerType ? SUBGROUP_CONTAINER_TYPES.has(containerType) : false;
			const parentId = (node as Record<string, unknown>).parent_container_id as string | undefined;
			if (parentId) parentContainerMap.set(node.id, parentId);

			const layerId = isSubgroup ? undefined : getLayerHint(node, input.topology);
			const padding = isSubgroup ? SUBGROUP_PADDING : CONTAINER_PADDING;

			const elkNode: ElkNode = isCollapsed
				? {
						id: node.id,
						width: 200,
						height: 80,
						children: [],
						layoutOptions: {
							'elk.nodeSize.constraints': 'MINIMUM_SIZE',
							'elk.nodeSize.minimum': '(200,80)',
							...(layerId !== undefined && {
								'elk.layered.layering.layerId': String(layerId)
							})
						}
					}
				: {
						id: node.id,
						children: [],
						layoutOptions: {
							'elk.algorithm': 'box',
							'elk.box.packingMode': 'SIMPLE',
							'elk.padding': padding,
							'elk.nodeSize.constraints': 'MINIMUM_SIZE',
							'elk.spacing.nodeNode': '20',
							...(layerId !== undefined && {
								'elk.layered.layering.layerId': String(layerId)
							})
						}
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

	// Sort sub-group children within each parent for deterministic placement
	for (const [, parent] of containers) {
		if (parent.children && parent.children.length > 0) {
			parent.children.sort((a, b) => a.id.localeCompare(b.id));
		}
	}

	// Build leaf→container mapping
	const elementToContainer = new Map<string, string>();
	for (const node of input.nodes) {
		if (node.node_type === 'Element') {
			const parentId = node.container_id ?? node.subnet_id;
			if (containers.has(parentId)) {
				elementToContainer.set(node.id, parentId);
			}
		}
	}

	// Build container layerId lookup for edge direction enforcement
	const containerLayerId = new Map<string, number>();
	for (const [id, container] of containers) {
		containerLayerId.set(
			id,
			parseInt(container.layoutOptions?.['elk.layered.layering.layerId'] ?? '999')
		);
	}

	// Build cross-container edge metadata per leaf node for edge-aware positioning
	const elementExternalEdgeInfo = new Map<
		string,
		{ hasUpwardEdge: boolean; hasDownwardEdge: boolean; externalEdgeCount: number }
	>();
	// Consider all VISIBLE edge types for positioning metadata (not just primary).
	// Primary/overlay classification only matters for container-level ELK edges —
	// for leaf positioning, any visible cross-container edge indicates the node
	// should be near the boundary (e.g., ServiceVirtualization edges to Docker Bridge).
	const hiddenEdgeSet = new Set(input.hiddenEdgeTypes ?? []);
	for (const edge of input.edges) {
		if (hiddenEdgeSet.has(edge.edge_type)) continue;
		// Resolve container: leaf→parent container, or the node itself if it IS a container
		// (ServiceVirtualization edges can target a container node directly)
		const srcContainer =
			elementToContainer.get(edge.source) ??
			(containerIds.has(edge.source) ? edge.source : undefined);
		const tgtContainer =
			elementToContainer.get(edge.target) ??
			(containerIds.has(edge.target) ? edge.target : undefined);
		if (srcContainer && tgtContainer && srcContainer !== tgtContainer) {
			const srcLayer = containerLayerId.get(srcContainer) ?? 999;
			const tgtLayer = containerLayerId.get(tgtContainer) ?? 999;
			for (const [leafId, myLayer, otherLayer] of [
				[edge.source, srcLayer, tgtLayer],
				[edge.target, tgtLayer, srcLayer]
			] as [string, number, number][]) {
				const info = elementExternalEdgeInfo.get(leafId) ?? {
					hasUpwardEdge: false,
					hasDownwardEdge: false,
					externalEdgeCount: 0
				};
				info.externalEdgeCount++;
				if (otherLayer < myLayer) info.hasUpwardEdge = true;
				if (otherLayer > myLayer) info.hasDownwardEdge = true;
				elementExternalEdgeInfo.set(leafId, info);
			}
		}
	}

	// Add leaf nodes as children of their containers (skip collapsed)
	for (const node of input.nodes) {
		if (node.node_type === 'Element') {
			const parentId = node.container_id ?? node.subnet_id;
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

	// With SEPARATE_CHILDREN, create container-level edges from cross-container
	// leaf edges. Direction is normalized to respect layer hierarchy (lower layerId → higher).
	const edges: ElkExtendedEdge[] = [];
	const seenContainerEdges = new Set<string>();
	let edgeIndex = 0;
	for (const edge of input.edges) {
		if (classifyEdge(edge) !== 'primary') continue;

		const srcContainer = elementToContainer.get(edge.source);
		const tgtContainer = elementToContainer.get(edge.target);
		if (srcContainer && tgtContainer && srcContainer !== tgtContainer) {
			// Normalize direction: source should have lower layerId (higher on screen)
			const srcLayer = containerLayerId.get(srcContainer) ?? 999;
			const tgtLayer = containerLayerId.get(tgtContainer) ?? 999;
			const [from, to] =
				srcLayer <= tgtLayer ? [srcContainer, tgtContainer] : [tgtContainer, srcContainer];

			const key = `${from}->${to}`;
			if (!seenContainerEdges.has(key)) {
				seenContainerEdges.add(key);
				edges.push({
					id: `elk-edge-${edgeIndex++}`,
					sources: [from],
					targets: [to]
				});
			}
		}
	}

	// Add hierarchy-enforcing edges between layer tiers for disconnected containers.
	// Without these, containers with no cross-container leaf edges (e.g., Docker Bridge)
	// float as disconnected components and ignore layerId ordering.
	const connectedContainers = new Set<string>();
	for (const key of seenContainerEdges) {
		const [src, tgt] = key.split('->');
		connectedContainers.add(src);
		connectedContainers.add(tgt);
	}

	// Group containers by layer, sorted by layerId
	const containersByLayer = new Map<number, string[]>();
	for (const [id, container] of containers) {
		const layerId = parseInt(container.layoutOptions?.['elk.layered.layering.layerId'] ?? '999');
		if (!containersByLayer.has(layerId)) containersByLayer.set(layerId, []);
		containersByLayer.get(layerId)!.push(id);
	}
	const sortedLayers = Array.from(containersByLayer.entries()).sort((a, b) => a[0] - b[0]);

	// Chain adjacent layers with edges to enforce vertical ordering.
	// Connect every container to a container in the next layer so disconnected
	// containers (e.g., VPN at layer 1 with no edges) still respect ordering.
	for (let i = 0; i < sortedLayers.length - 1; i++) {
		const currentLayerContainers = sortedLayers[i][1];
		const nextLayerContainers = sortedLayers[i + 1][1];
		for (const src of currentLayerContainers) {
			const tgt = nextLayerContainers[0];
			const key = `${src}->${tgt}`;
			if (!seenContainerEdges.has(key)) {
				seenContainerEdges.add(key);
				edges.push({
					id: `elk-edge-${edgeIndex++}`,
					sources: [src],
					targets: [tgt]
				});
			}
		}
	}

	// Only add root-level containers (not nested sub-groups) to root children
	const rootContainers = Array.from(containers.entries())
		.filter(([id]) => !parentContainerMap.has(id))
		.map(([, node]) => node);

	const graph: ElkNode = {
		id: 'root',
		layoutOptions: ROOT_LAYOUT_OPTIONS,
		children: rootContainers,
		edges
	};

	return { graph, containerIds, elementExternalEdgeInfo };
}

/**
 * Compute optimal handle sides based on relative position of source and target.
 * Picks the pair of sides (Top/Bottom/Left/Right) that minimizes edge distance.
 */
function computeOptimalHandles(
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

	// Pick handle based on predominant direction
	if (Math.abs(dy) >= Math.abs(dx)) {
		// Vertical: target is below source → source Bottom, target Top (and vice versa)
		if (dy >= 0) {
			return { sourceHandle: 'Bottom', targetHandle: 'Top' };
		} else {
			return { sourceHandle: 'Top', targetHandle: 'Bottom' };
		}
	} else {
		// Horizontal: target is right of source → source Right, target Left
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

/**
 * Post-layout swap: move nodes with external edges to container boundary positions.
 * - Upward-only edges: move to top of their column
 * - Downward-only edges: move to bottom of their column
 * - Bridge nodes (both up+down): move to left/right edge column, handles face outward
 *
 * Returns a map of bridge node IDs → outward-facing handle side.
 */
function applyEdgeAwareSwaps(
	container: ElkNode,
	elementExternalEdgeInfo: Map<
		string,
		{ hasUpwardEdge: boolean; hasDownwardEdge: boolean; externalEdgeCount: number }
	>,
	containerIds: Set<string>
): Map<string, HandleSide> {
	const bridgeNodeSides = new Map<string, HandleSide>();
	if (!container.children || container.children.length < 2) return bridgeNodeSides;

	// Only consider leaf nodes (not nested sub-group containers)
	const leaves = container.children.filter((c) => !containerIds.has(c.id));
	if (leaves.length < 2) return bridgeNodeSides;

	// Group leaves by x-coordinate (same column)
	const columns = new Map<number, ElkNode[]>();
	for (const leaf of leaves) {
		const x = leaf.x ?? 0;
		if (!columns.has(x)) columns.set(x, []);
		columns.get(x)!.push(leaf);
	}

	const spacing = parseInt(container.layoutOptions?.['elk.spacing.nodeNode'] ?? '20');
	const sortedColumnXs = Array.from(columns.keys()).sort((a, b) => a - b);

	// Phase 1: Move bridge nodes to edge columns
	if (sortedColumnXs.length >= 2) {
		const leftX = sortedColumnXs[0];
		const rightX = sortedColumnXs[sortedColumnXs.length - 1];

		// Collect bridge nodes from all columns
		const bridgeNodes: { node: ElkNode; sourceColX: number }[] = [];
		for (const [colX, colNodes] of columns) {
			for (const n of colNodes) {
				const info = elementExternalEdgeInfo.get(n.id);
				if (info?.hasUpwardEdge && info?.hasDownwardEdge) {
					bridgeNodes.push({ node: n, sourceColX: colX });
				}
			}
		}

		// Assign bridge nodes to edge columns, alternating right/left
		for (let i = 0; i < bridgeNodes.length; i++) {
			const { node: bridgeNode, sourceColX } = bridgeNodes[i];
			const targetX = i % 2 === 0 ? rightX : leftX;
			const side: HandleSide = targetX === leftX ? 'Left' : 'Right';

			if (sourceColX === targetX) {
				// Already in an edge column
				bridgeNodeSides.set(bridgeNode.id, side);
				continue;
			}

			const targetCol = columns.get(targetX)!;
			const sourceCol = columns.get(sourceColX)!;

			// Find closest-sized node in target column to swap with
			let bestIdx = 0;
			let bestDiff = Infinity;
			const bridgeH = bridgeNode.height ?? 0;
			for (let j = 0; j < targetCol.length; j++) {
				const info = elementExternalEdgeInfo.get(targetCol[j].id);
				// Don't swap with another bridge node
				if (info?.hasUpwardEdge && info?.hasDownwardEdge) continue;
				const diff = Math.abs((targetCol[j].height ?? 0) - bridgeH);
				if (diff < bestDiff) {
					bestDiff = diff;
					bestIdx = j;
				}
			}

			const displaced = targetCol[bestIdx];

			// Swap column membership: bridge → target column, displaced → source column
			targetCol[bestIdx] = bridgeNode;
			const srcIdx = sourceCol.indexOf(bridgeNode);
			sourceCol[srcIdx] = displaced;

			// Update x-coordinates
			bridgeNode.x = targetX;
			displaced.x = sourceColX;

			bridgeNodeSides.set(bridgeNode.id, side);
		}

		// Recompute y in all columns that were modified by bridge swaps
		if (bridgeNodes.length > 0) {
			for (const [, colNodes] of columns) {
				recomputeColumnY(colNodes, spacing);
			}
		}
	}

	// Phase 2: Within each column, reorder upward-only to top, downward-only to bottom
	for (const [, colNodes] of columns) {
		if (colNodes.length < 2) continue;

		colNodes.sort((a, b) => (a.y ?? 0) - (b.y ?? 0));
		const startY = colNodes[0].y ?? 0;

		const upward: ElkNode[] = [];
		const middle: ElkNode[] = [];
		const downward: ElkNode[] = [];
		for (const n of colNodes) {
			const info = elementExternalEdgeInfo.get(n.id);
			// Bridge nodes already handled — treat them as middle here
			if (info?.hasUpwardEdge && info?.hasDownwardEdge) {
				middle.push(n);
			} else if (info?.hasUpwardEdge) {
				upward.push(n);
			} else if (info?.hasDownwardEdge) {
				downward.push(n);
			} else {
				middle.push(n);
			}
		}

		const reordered = [...upward, ...middle, ...downward];
		let y = startY;
		for (const node of reordered) {
			node.y = y;
			y += (node.height ?? 0) + spacing;
		}
	}

	return bridgeNodeSides;
}

function mapElkResults(
	layoutResult: ElkNode,
	containerIds: Set<string>,
	input: ElkLayoutInput,
	elementExternalEdgeInfo: Map<
		string,
		{ hasUpwardEdge: boolean; hasDownwardEdge: boolean; externalEdgeCount: number }
	>
): ElkLayoutResult {
	const nodePositions = new Map<string, { x: number; y: number }>();
	const containerSizes = new Map<string, { width: number; height: number }>();

	// Track absolute positions for handle computation (leaves need container offset)
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
				// Recurse into children (nested containers or leaves)
				if (child.children) {
					processChildren(child.children, absX, absY);
				}
			} else {
				// Leaf node: position relative to parent for SvelteFlow
				nodePositions.set(child.id, { x: cx, y: cy });
				absolutePositions.set(child.id, { x: absX, y: absY });
			}
		}
	}

	// Collect bridge node handle overrides from all containers
	const bridgeNodeSides = new Map<string, HandleSide>();

	if (layoutResult.children) {
		// Apply edge-aware position swaps before extracting positions
		for (const child of layoutResult.children) {
			if (containerIds.has(child.id)) {
				const sides = applyEdgeAwareSwaps(child, elementExternalEdgeInfo, containerIds);
				for (const [id, side] of sides) bridgeNodeSides.set(id, side);
				// Also apply to nested sub-group containers
				if (child.children) {
					for (const subChild of child.children) {
						if (containerIds.has(subChild.id)) {
							const subSides = applyEdgeAwareSwaps(subChild, elementExternalEdgeInfo, containerIds);
							for (const [id, side] of subSides) bridgeNodeSides.set(id, side);
						}
					}
				}
			}
		}
		processChildren(layoutResult.children, 0, 0);
	}

	// Compute optimal edge handles using absolute positions
	const edgeHandles = new Map<string, EdgeHandles>();
	const nodeSizes = new Map<string, { w: number; h: number }>();
	for (const node of input.nodes) {
		// Use ELK-computed size for containers, frontend-computed size for leaves
		const elkSize = containerSizes.get(node.id);
		const leafSize = input.elementNodeSizes?.get(node.id);
		nodeSizes.set(node.id, {
			w: elkSize?.width ?? leafSize?.x ?? node.size.x,
			h: elkSize?.height ?? leafSize?.y ?? node.size.y
		});
	}

	for (const edge of input.edges) {
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

	// Override handles for bridge nodes — edges should face outward from container edge
	if (bridgeNodeSides.size > 0) {
		for (const edge of input.edges) {
			const key = `${edge.source}->${edge.target}`;
			const handles = edgeHandles.get(key);
			if (!handles) continue;

			const srcSide = bridgeNodeSides.get(edge.source);
			if (srcSide) handles.sourceHandle = srcSide;

			const tgtSide = bridgeNodeSides.get(edge.target);
			if (tgtSide) handles.targetHandle = tgtSide;
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

	const { graph, containerIds, elementExternalEdgeInfo } = buildElkGraph(input);
	const elk = await getElk();
	const result = await elk.layout(graph);
	return mapElkResults(result, containerIds, input, elementExternalEdgeInfo);
}
