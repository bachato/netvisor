/**
 * Force-directed layout for collapsed containers.
 *
 * When all root containers are collapsed, this replaces the ELK layered layout
 * with d3-force positioning. Nodes repel, edges attract, and rectangular collision
 * prevents overlap — producing a natural, spread-out arrangement.
 */

import {
	forceSimulation,
	forceLink,
	forceManyBody,
	forceCenter,
	type SimulationNodeDatum,
	type SimulationLinkDatum
} from 'd3-force';
import type { TopologyEdge } from '../types/base';
import { computeOptimalHandles, type EdgeHandles } from './elk-layout';

export interface ForceNode {
	id: string;
	width: number;
	height: number;
}

export interface ForceLink {
	source: string;
	target: string;
}

export interface ForceLayoutResult {
	nodePositions: Map<string, { x: number; y: number }>;
	edgeHandles: Map<string, EdgeHandles>;
}

interface SimNode extends SimulationNodeDatum {
	id: string;
	width: number;
	height: number;
}

const SNAP = 25;
const PADDING = 40;
const ORIGIN_PAD = 50;

/**
 * Custom rectangular collision force.
 * d3-force's forceCollide is radius-based (circular). This checks axis-aligned
 * bounding box overlap and pushes apart along the axis of least overlap.
 */
function forceRectCollide(padding: number) {
	let nodes: SimNode[] = [];

	function force(alpha: number) {
		for (let i = 0; i < nodes.length; i++) {
			for (let j = i + 1; j < nodes.length; j++) {
				const a = nodes[i];
				const b = nodes[j];
				const dx = (b.x ?? 0) - (a.x ?? 0);
				const dy = (b.y ?? 0) - (a.y ?? 0);
				const overlapX = (a.width + b.width) / 2 + padding - Math.abs(dx);
				const overlapY = (a.height + b.height) / 2 + padding - Math.abs(dy);

				if (overlapX > 0 && overlapY > 0) {
					const strength = alpha * 0.5;
					if (overlapX < overlapY) {
						const sign = dx > 0 ? 1 : dx < 0 ? -1 : i < j ? -1 : 1;
						const shift = overlapX * strength * sign;
						a.x = (a.x ?? 0) - shift;
						b.x = (b.x ?? 0) + shift;
					} else {
						const sign = dy > 0 ? 1 : dy < 0 ? -1 : i < j ? -1 : 1;
						const shift = overlapY * strength * sign;
						a.y = (a.y ?? 0) - shift;
						b.y = (b.y ?? 0) + shift;
					}
				}
			}
		}
	}

	force.initialize = (n: SimNode[]) => {
		nodes = n;
	};

	return force;
}

/**
 * Compute force-directed layout for collapsed containers.
 *
 * @param nodes - Root-level collapsed containers with measured dimensions
 * @param links - Deduplicated edges between containers
 * @param edges - All elevated edges (for computing edge handles)
 * @param hiddenEdgeTypes - Edge types to exclude from handle computation
 */
export function computeForceLayout(
	nodes: ForceNode[],
	links: ForceLink[],
	edges: TopologyEdge[],
	hiddenEdgeTypes?: string[]
): ForceLayoutResult {
	if (nodes.length === 0) {
		return { nodePositions: new Map(), edgeHandles: new Map() };
	}

	// Single node: place at origin, no simulation needed
	if (nodes.length === 1) {
		const node = nodes[0];
		const nodePositions = new Map<string, { x: number; y: number }>();
		nodePositions.set(node.id, { x: ORIGIN_PAD, y: ORIGIN_PAD });
		const edgeHandles = computeEdgeHandles(nodePositions, nodes, edges, hiddenEdgeTypes);
		return { nodePositions, edgeHandles };
	}

	// Initialize simulation nodes in circular arrangement for better convergence
	const radius = 150 * Math.sqrt(nodes.length);
	const simNodes: SimNode[] = nodes.map((n, i) => ({
		id: n.id,
		width: n.width,
		height: n.height,
		x: Math.cos((i * 2 * Math.PI) / nodes.length) * radius,
		y: Math.sin((i * 2 * Math.PI) / nodes.length) * radius
	}));

	// Build link data with node references
	const nodeById = new Map(simNodes.map((n) => [n.id, n]));
	const simLinks: SimulationLinkDatum<SimNode>[] = links
		.filter((l) => nodeById.has(l.source) && nodeById.has(l.target))
		.map((l) => ({
			source: nodeById.get(l.source)!,
			target: nodeById.get(l.target)!
		}));

	// Configure and run simulation
	const simulation = forceSimulation<SimNode>(simNodes)
		.force(
			'link',
			forceLink<SimNode, SimulationLinkDatum<SimNode>>(simLinks).distance(200).strength(0.3)
		)
		.force('charge', forceManyBody().strength(-800))
		.force('center', forceCenter(0, 0))
		.force('collide', forceRectCollide(PADDING))
		.stop();

	// Run to convergence synchronously
	simulation.tick(300);

	// Snap to grid and normalize to positive coordinates
	let minX = Infinity;
	let minY = Infinity;
	for (const node of simNodes) {
		node.x = Math.round((node.x ?? 0) / SNAP) * SNAP;
		node.y = Math.round((node.y ?? 0) / SNAP) * SNAP;
		if (node.x < minX) minX = node.x;
		if (node.y < minY) minY = node.y;
	}

	const nodePositions = new Map<string, { x: number; y: number }>();
	for (const node of simNodes) {
		nodePositions.set(node.id, {
			x: (node.x ?? 0) - minX + ORIGIN_PAD,
			y: (node.y ?? 0) - minY + ORIGIN_PAD
		});
	}

	const edgeHandles = computeEdgeHandles(nodePositions, nodes, edges, hiddenEdgeTypes);

	return { nodePositions, edgeHandles };
}

/**
 * Compute edge handles (connection sides) for all visible edges using node positions.
 */
function computeEdgeHandles(
	nodePositions: Map<string, { x: number; y: number }>,
	nodes: ForceNode[],
	edges: TopologyEdge[],
	hiddenEdgeTypes?: string[]
): Map<string, EdgeHandles> {
	const handles = new Map<string, EdgeHandles>();
	const hiddenSet = new Set(hiddenEdgeTypes ?? []);
	const nodeMap = new Map(nodes.map((n) => [n.id, n]));

	for (const edge of edges) {
		const edgeType = (edge as Record<string, unknown>).edge_type as string | undefined;
		if (edgeType && hiddenSet.has(edgeType)) continue;

		const srcId = edge.source as string;
		const tgtId = edge.target as string;
		const srcPos = nodePositions.get(srcId);
		const tgtPos = nodePositions.get(tgtId);
		const srcNode = nodeMap.get(srcId);
		const tgtNode = nodeMap.get(tgtId);

		if (srcPos && tgtPos && srcNode && tgtNode && srcId !== tgtId) {
			handles.set(
				`${srcId}->${tgtId}`,
				computeOptimalHandles(srcPos, { w: srcNode.width, h: srcNode.height }, tgtPos, {
					w: tgtNode.width,
					h: tgtNode.height
				})
			);
		}
	}

	return handles;
}
