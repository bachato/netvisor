import type { ElkNode, ElkExtendedEdge } from 'elkjs';
import type { TopologyNode, TopologyEdge, Topology } from '../types/base';
import type { components } from '$lib/api/schema';
import { classifyEdge } from './edge-classification';

type ServiceCategory = components['schemas']['ServiceCategory'];

type SubnetType = components['schemas']['SubnetType'];

export interface ElkLayoutInput {
	nodes: TopologyNode[];
	edges: TopologyEdge[];
	topology: Topology;
	collapsedContainers?: Set<string>;
	/** Frontend-computed leaf node sizes (overrides backend node.size) */
	leafNodeSizes?: Map<string, { x: number; y: number }>;
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
const CONTAINER_PADDING = '[top=50,left=25,bottom=25,right=25]';

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

// Leaf node size constants (px)
const LEAF_WIDTH = 250;
const HEADER_HEIGHT = 25;
const FOOTER_HEIGHT = 25;
const SERVICE_ROW_HEIGHT = 50;
const PORT_LINE_HEIGHT = 25;
const OPEN_PORTS_PILL_HEIGHT = 30;

/**
 * Compute leaf node sizes based on visible services and display options.
 * This replaces the backend size computation — the frontend knows which
 * services are actually visible after category filtering.
 */
export function computeLeafNodeSizes(
	nodes: TopologyNode[],
	topology: Topology,
	hiddenCategories: ServiceCategory[],
	hidePorts: boolean,
	getCategory: (serviceDefinition: string) => string
): Map<string, { x: number; y: number }> {
	const sizes = new Map<string, { x: number; y: number }>();

	for (const node of nodes) {
		if (node.node_type !== 'LeafNode') continue;
		const interfaceId = node.interface_id ?? node.id;

		// Find services bound to this interface
		const boundServices = topology.services.filter((s) =>
			s.bindings.some((b) => b.interface_id == null || b.interface_id === interfaceId)
		);

		// Split by visibility
		const visibleServices = boundServices.filter(
			(s) => !hiddenCategories.includes(getCategory(s.service_definition) as ServiceCategory)
		);
		const hiddenOpenPorts = boundServices.filter((s) => {
			const cat = getCategory(s.service_definition);
			return hiddenCategories.includes(cat as ServiceCategory) && cat === 'OpenPorts';
		});

		const hasHeader = node.header != null;
		const hasFooter = true; // leaf nodes always have a footer area

		let height = hasFooter ? FOOTER_HEIGHT : 0;
		if (hasHeader) height += HEADER_HEIGHT;

		if (visibleServices.length === 0 && hiddenOpenPorts.length === 0) {
			// Body text only (host name)
			height += SERVICE_ROW_HEIGHT;
		} else {
			// Service rows
			for (const service of visibleServices) {
				height += SERVICE_ROW_HEIGHT;
				if (
					!hidePorts &&
					service.bindings.some(
						(b) =>
							(b.interface_id === interfaceId || b.interface_id == null) &&
							b.type === 'Port' &&
							b.port_id
					)
				) {
					height += PORT_LINE_HEIGHT;
				}
			}
			// Open ports pill (when hidden ports exist)
			if (hiddenOpenPorts.length > 0) {
				height += OPEN_PORTS_PILL_HEIGHT;
			}
		}

		sizes.set(node.id, { x: LEAF_WIDTH, y: height });
	}

	return sizes;
}

/**
 * Build an ELK graph from topology data.
 * Containers become parent nodes; leaves become children inside their container.
 * Only primary edges are included (overlay edges don't affect layout).
 */
function buildElkGraph(input: ElkLayoutInput): { graph: ElkNode; containerIds: Set<string> } {
	const containers: Map<string, ElkNode> = new Map();
	const containerIds = new Set<string>();

	const collapsed = input.collapsedContainers ?? new Set<string>();

	// Track parent relationships for nested containers
	const parentContainerMap = new Map<string, string>();

	// Create container (parent) nodes
	for (const node of input.nodes) {
		if (node.node_type === 'ContainerNode') {
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
							'elk.algorithm': 'rectpacking',
							'elk.padding': padding,
							'elk.nodeSize.constraints': 'MINIMUM_SIZE',
							'elk.rectpacking.desiredAspectRatio': '2.5',
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

	// Add leaf nodes as children of their containers (skip collapsed)
	for (const node of input.nodes) {
		if (node.node_type === 'LeafNode') {
			const parentId = node.container_id ?? node.subnet_id;
			if (collapsed.has(parentId)) continue;
			const parent = containers.get(parentId);
			if (parent && parent.children) {
				const size = input.leafNodeSizes?.get(node.id) ?? node.size;
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

	if (layoutResult.children) {
		processChildren(layoutResult.children, 0, 0);
	}

	// Compute optimal edge handles using absolute positions
	const edgeHandles = new Map<string, EdgeHandles>();
	const nodeSizes = new Map<string, { w: number; h: number }>();
	for (const node of input.nodes) {
		// Use ELK-computed size for containers, frontend-computed size for leaves
		const elkSize = containerSizes.get(node.id);
		const leafSize = input.leafNodeSizes?.get(node.id);
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
