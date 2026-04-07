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
}

interface SimNode extends SimulationNodeDatum {
	id: string;
	width: number;
	height: number;
}

const SNAP = 25;
const PADDING = 25;
const ORIGIN_PAD = 50;

/**
 * Custom rectangular collision force.
 * d3-force's forceCollide is radius-based (circular). This checks axis-aligned
 * bounding box overlap and pushes apart along the axis of least overlap.
 */
export function forceRectCollide(padding: number) {
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
 * Returns only positions — edge handles are computed after edge aggregation.
 *
 * @param nodes - Root-level collapsed containers with measured dimensions
 * @param links - Deduplicated edges between containers
 */
export function computeForceLayout(nodes: ForceNode[], links: ForceLink[]): ForceLayoutResult {
	if (nodes.length === 0) {
		return { nodePositions: new Map() };
	}

	// Single node: place at origin, no simulation needed
	if (nodes.length === 1) {
		const node = nodes[0];
		const nodePositions = new Map<string, { x: number; y: number }>();
		nodePositions.set(node.id, { x: ORIGIN_PAD, y: ORIGIN_PAD });
		return { nodePositions };
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
			forceLink<SimNode, SimulationLinkDatum<SimNode>>(simLinks).distance(120).strength(0.5)
		)
		.force('charge', forceManyBody().strength(-400))
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

	return { nodePositions };
}
