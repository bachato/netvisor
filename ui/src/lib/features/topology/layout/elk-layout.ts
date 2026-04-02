import type { ElkNode, ElkExtendedEdge } from 'elkjs';
import type { TopologyNode, TopologyEdge, Topology } from '../types/base';
import type { components } from '$lib/api/schema';
import { classifyEdge } from './edge-classification';

type SubnetType = components['schemas']['SubnetType'];

export interface ElkLayoutInput {
	nodes: TopologyNode[];
	edges: TopologyEdge[];
	topology: Topology;
}

export type HandleSide = 'Top' | 'Bottom' | 'Left' | 'Right';

export interface EdgeHandles {
	sourceHandle: HandleSide;
	targetHandle: HandleSide;
}

export interface ElkLayoutResult {
	nodePositions: Map<string, { x: number; y: number }>;
	containerSizes: Map<string, { width: number; height: number }>;
	edgeHandles: Map<string, EdgeHandles>;
}

let elkPromise: Promise<import('elkjs')['default']> | null = null;

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
const CONTAINER_PADDING = '[top=50,left=25,bottom=25,right=25]';

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
function buildElkGraph(input: ElkLayoutInput): { graph: ElkNode; containerIds: Set<string> } {
	const containers: Map<string, ElkNode> = new Map();
	const containerIds = new Set<string>();

	// Create container (parent) nodes
	for (const node of input.nodes) {
		if (node.node_type === 'ContainerNode') {
			containerIds.add(node.id);
			const layerId = getLayerHint(node, input.topology);
			containers.set(node.id, {
				id: node.id,
				children: [],
				layoutOptions: {
					'elk.algorithm': 'rectpacking',
					'elk.padding': CONTAINER_PADDING,
					'elk.nodeSize.constraints': 'MINIMUM_SIZE',
					'elk.rectpacking.desiredAspectRatio': '2.5',
					'elk.spacing.nodeNode': '20',
					'elk.layered.layering.layerId': String(layerId)
				}
			});
		}
	}

	// Add leaf nodes as children of their containers
	for (const node of input.nodes) {
		if (node.node_type === 'LeafNode') {
			const parentId = node.container_id ?? node.subnet_id;
			const parent = containers.get(parentId);
			if (parent && parent.children) {
				parent.children.push({
					id: node.id,
					width: node.size.x,
					height: node.size.y,
					layoutOptions: {
						'elk.nodeSize.constraints': 'MINIMUM_SIZE',
						'elk.nodeSize.minimum': `(${node.size.x},${node.size.y})`
					}
				});
			}
		}
	}

	// Build leaf→container mapping
	const leafToContainer = new Map<string, string>();
	for (const node of input.nodes) {
		if (node.node_type === 'LeafNode') {
			const parentId = node.container_id ?? node.subnet_id;
			if (containers.has(parentId)) {
				leafToContainer.set(node.id, parentId);
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

	// With SEPARATE_CHILDREN, create container-level edges from cross-container
	// leaf edges. Direction is normalized to respect layer hierarchy (lower layerId → higher).
	const edges: ElkExtendedEdge[] = [];
	const seenContainerEdges = new Set<string>();
	let edgeIndex = 0;
	for (const edge of input.edges) {
		if (classifyEdge(edge) !== 'primary') continue;

		const srcContainer = leafToContainer.get(edge.source);
		const tgtContainer = leafToContainer.get(edge.target);
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

	const graph: ElkNode = {
		id: 'root',
		layoutOptions: ROOT_LAYOUT_OPTIONS,
		children: Array.from(containers.values()),
		edges
	};

	return { graph, containerIds };
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

/**
 * Extract positions from ELK result. Leaf positions are made relative to their
 * parent container (as @xyflow expects when parentId is set).
 */
function mapElkResults(
	layoutResult: ElkNode,
	containerIds: Set<string>,
	input: ElkLayoutInput
): ElkLayoutResult {
	const nodePositions = new Map<string, { x: number; y: number }>();
	const containerSizes = new Map<string, { width: number; height: number }>();

	// Track absolute positions for handle computation (leaves need container offset)
	const absolutePositions = new Map<string, { x: number; y: number }>();

	// Map container positions and sizes
	if (layoutResult.children) {
		for (const container of layoutResult.children) {
			if (!containerIds.has(container.id)) continue;
			const cx = container.x ?? 0;
			const cy = container.y ?? 0;
			nodePositions.set(container.id, { x: cx, y: cy });
			absolutePositions.set(container.id, { x: cx, y: cy });
			containerSizes.set(container.id, {
				width: container.width ?? 0,
				height: container.height ?? 0
			});

			// Map leaf node positions (relative to parent for SvelteFlow)
			if (container.children) {
				for (const leaf of container.children) {
					const lx = leaf.x ?? 0;
					const ly = leaf.y ?? 0;
					nodePositions.set(leaf.id, { x: lx, y: ly });
					// Absolute = container pos + leaf offset
					absolutePositions.set(leaf.id, { x: cx + lx, y: cy + ly });
				}
			}
		}
	}

	// Compute optimal edge handles using absolute positions
	const edgeHandles = new Map<string, EdgeHandles>();
	const nodeSizes = new Map<string, { w: number; h: number }>();
	for (const node of input.nodes) {
		// Use ELK-computed size for containers, original size for leaves
		const elkSize = containerSizes.get(node.id);
		nodeSizes.set(node.id, {
			w: elkSize?.width ?? node.size.x,
			h: elkSize?.height ?? node.size.y
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

	return { nodePositions, containerSizes, edgeHandles };
}

/**
 * Compute layout positions using elkjs compound layered algorithm.
 * Returns positions for all nodes and computed sizes for containers.
 */
export async function computeElkLayout(input: ElkLayoutInput): Promise<ElkLayoutResult> {
	if (input.nodes.length === 0) {
		return { nodePositions: new Map(), containerSizes: new Map(), edgeHandles: new Map() };
	}

	const { graph, containerIds } = buildElkGraph(input);
	const elk = await getElk();
	const result = await elk.layout(graph);
	return mapElkResults(result, containerIds, input);
}
