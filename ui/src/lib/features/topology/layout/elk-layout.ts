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
	'elk.layered.spacing.nodeNodeBetweenLayers': '40',
	'elk.layered.spacing.edgeNodeBetweenLayers': '20',
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
function buildElkGraph(input: ElkLayoutInput): {
	graph: ElkNode;
	containerIds: Set<string>;
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
						layoutOptions: {
							'elk.algorithm': 'box',
							'elk.box.packingMode': 'SIMPLE',
							'elk.aspectRatio': '1.4',
							'elk.padding': padding,
							'elk.nodeSize.constraints': 'MINIMUM_SIZE',
							'elk.spacing.nodeNode': '25'
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

	// Sort children: elements first (alphabetical), then subcontainers (alphabetical).
	// Must run AFTER elements are added above.
	for (const [, parent] of containers) {
		if (parent.children && parent.children.length > 1) {
			parent.children.sort((a, b) => {
				const aIsSub = containerIds.has(a.id) ? 1 : 0;
				const bIsSub = containerIds.has(b.id) ? 1 : 0;
				if (aIsSub !== bIsSub) return aIsSub - bIsSub;
				return a.id.localeCompare(b.id);
			});
		}
	}

	// Predict element positions from box packing to create ports on containers.
	// SIMPLE packing fills left-to-right, top-to-bottom. We simulate this to know
	// WHERE each element sits within its container, then add ports at those positions
	// so ELK's crossing minimization can order same-layer containers correctly.
	const predictedPositions = new Map<string, { x: number; y: number }>();
	for (const [containerId, container] of containers) {
		if (!container.children || container.children.length === 0) continue;
		if (parentContainerMap.has(containerId)) continue; // skip subcontainers

		const opts = container.layoutOptions ?? {};
		const aspectRatio = parseFloat(opts['elk.aspectRatio'] ?? '1.4');
		const spacing = parseFloat(opts['elk.spacing.nodeNode'] ?? '25');
		const paddingStr = opts['elk.padding'] ?? '';
		const padMatch = paddingStr.match(/top=(\d+).*left=(\d+)/);
		const padTop = padMatch ? parseInt(padMatch[1]) : 20;
		const padLeft = padMatch ? parseInt(padMatch[2]) : 20;

		// Estimate target width from total area and aspect ratio
		const children = container.children.filter((c) => !containerIds.has(c.id));
		if (children.length === 0) continue;
		const totalArea = children.reduce((s, c) => s + (c.width ?? 0) * (c.height ?? 0), 0);
		const targetWidth = Math.sqrt(totalArea * aspectRatio) + padLeft * 2;

		let x = padLeft;
		let y = padTop;
		let rowHeight = 0;
		for (const child of children) {
			const w = child.width ?? 0;
			const h = child.height ?? 0;
			if (x + w > targetWidth && x > padLeft) {
				x = padLeft;
				y += rowHeight + spacing;
				rowHeight = 0;
			}
			predictedPositions.set(child.id, { x, y });
			x += w + spacing;
			rowHeight = Math.max(rowHeight, h);
		}
	}

	// Create port-based edges for cross-container connections.
	// Ports give ELK positional information on WHERE edges exit a container,
	// enabling meaningful crossing minimization for same-layer containers.
	const edges: ElkExtendedEdge[] = [];
	const containerPorts = new Map<string, { id: string; x: number; side: string }[]>();
	const seenEdges = new Set<string>();
	let edgeIndex = 0;

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

	for (const edge of input.edges) {
		if (!affectsLayout(edge)) continue;

		const key = `${edge.source}->${edge.target}`;
		if (seenEdges.has(key)) continue;
		seenEdges.add(key);

		const srcRoot = resolveRoot(edge.source);
		const tgtRoot = resolveRoot(edge.target);
		if (!srcRoot || !tgtRoot || srcRoot === tgtRoot) continue;

		// For each endpoint, create a port on its root container at the element's x position
		const addPort = (elementOrContainerId: string, rootId: string, side: string): string => {
			const portId = `port-${elementOrContainerId}-${side}`;
			if (!containerPorts.has(rootId)) containerPorts.set(rootId, []);
			const ports = containerPorts.get(rootId)!;
			if (ports.some((p) => p.id === portId)) return portId;

			const pos = predictedPositions.get(elementOrContainerId);
			const elemNode = containers.get(rootId)?.children?.find((c) => c.id === elementOrContainerId);
			const elemWidth = elemNode?.width ?? 180;
			const portX = pos ? pos.x + elemWidth / 2 : 0;

			ports.push({ id: portId, x: portX, side });
			return portId;
		};

		const srcPortId = addPort(edge.source, srcRoot, 'SOUTH');
		// Target might be a container itself (absorbs_edges) — use container center
		const tgtIsContainer = containerIds.has(edge.target);
		const tgtEndpoint = tgtIsContainer ? tgtRoot : addPort(edge.target, tgtRoot, 'NORTH');

		edges.push({
			id: `elk-edge-${edgeIndex++}`,
			sources: [srcPortId],
			targets: [tgtEndpoint]
		});
	}

	// Apply ports to container ElkNodes
	for (const [containerId, ports] of containerPorts) {
		const container = containers.get(containerId);
		if (!container) continue;
		if (!container.ports) container.ports = [];
		if (!container.layoutOptions) container.layoutOptions = {};
		container.layoutOptions['elk.portConstraints'] = 'FIXED_POS';

		for (const port of ports) {
			// y=0 for NORTH (top), y=container height estimate for SOUTH (bottom)
			const isBottom = port.side === 'SOUTH';
			// Estimate container height from predicted positions
			let containerH = 300; // fallback
			const children = container.children?.filter((c) => !containerIds.has(c.id)) ?? [];
			if (children.length > 0) {
				const lastChild = children[children.length - 1];
				const lastPos = predictedPositions.get(lastChild.id);
				if (lastPos) containerH = lastPos.y + (lastChild.height ?? 60) + 20;
			}

			container.ports.push({
				id: port.id,
				x: port.x,
				y: isBottom ? containerH : 0,
				width: 1,
				height: 1
			});
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
 * Biases toward vertical handles (Top/Bottom) since containers are typically
 * stacked vertically — horizontal handles cause edges to cross through
 * adjacent elements. Only uses Left/Right when the edge is very horizontal
 * (target at nearly the same vertical level).
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

	const { graph, containerIds } = buildElkGraph(input);
	const elk = await getElk();
	const result = await elk.layout(graph);
	return mapElkResults(result, containerIds, input);
}
