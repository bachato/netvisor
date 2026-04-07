/**
 * Two-phase force-directed compound layout for the L2 Physical perspective.
 *
 * Phase 1: Inter-host force layout — positions host containers using d3-force,
 * with estimated sizes derived from port count.
 *
 * Phase 2: Intra-host grid packing — arranges port elements in a grid inside
 * each host container, computing final container sizes.
 */

import {
	forceSimulation,
	forceLink,
	forceManyBody,
	forceCenter,
	type SimulationNodeDatum,
	type SimulationLinkDatum
} from 'd3-force';

import type { LayoutInput, LayoutResult, LayoutEngine } from './engine';
import type { EdgeHandles } from './elk-layout';
import { forceRectCollide } from './force-layout';

// Layout constants
const SNAP = 25;
const ORIGIN_PAD = 50;
const PADDING = 25;
const PORT_NODE_WIDTH = 150;
const PORT_NODE_HEIGHT = 40;
const PORT_GAP = 10;
const CONTAINER_PADDING_TOP = 50; // room for title
const CONTAINER_PADDING_SIDE = 25;
const CONTAINER_PADDING_BOTTOM = 25;

interface SimNode extends SimulationNodeDatum {
	id: string;
	width: number;
	height: number;
}

export class ForceCompoundLayoutEngine implements LayoutEngine {
	async compute(input: LayoutInput): Promise<LayoutResult> {
		const nodePositions = new Map<string, { x: number; y: number }>();
		const containerSizes = new Map<string, { width: number; height: number }>();
		const elementNodeSizes = new Map<string, { x: number; y: number }>();
		const edgeHandles = new Map<string, EdgeHandles>();

		// Separate containers and elements
		const containers = input.nodes.filter((n) => n.node_type === 'Container');
		const elements = input.nodes.filter((n) => n.node_type === 'Element');

		// Group elements by their container
		const elementsByContainer = new Map<string, typeof elements>();
		for (const el of elements) {
			const containerId = 'container_id' in el ? (el.container_id as string) : undefined;
			if (!containerId) continue;
			if (!elementsByContainer.has(containerId)) {
				elementsByContainer.set(containerId, []);
			}
			elementsByContainer.get(containerId)!.push(el);
		}

		// Phase 2 first (to get accurate sizes for Phase 1)
		// Grid-pack ports inside each container
		const containerGridSizes = new Map<string, { width: number; height: number }>();

		for (const container of containers) {
			const children = elementsByContainer.get(container.id) ?? [];
			// Sort by header (port name) for consistent ordering
			children.sort((a, b) => {
				const ha = a.header ?? '';
				const hb = b.header ?? '';
				return ha.localeCompare(hb, undefined, { numeric: true });
			});

			const portCount = children.length;
			const cols = Math.max(1, Math.ceil(Math.sqrt(portCount)));
			const rows = Math.ceil(portCount / cols);

			const gridWidth = cols * (PORT_NODE_WIDTH + PORT_GAP) - PORT_GAP;
			const gridHeight = rows * (PORT_NODE_HEIGHT + PORT_GAP) - PORT_GAP;

			const containerWidth = gridWidth + CONTAINER_PADDING_SIDE * 2;
			const containerHeight = gridHeight + CONTAINER_PADDING_TOP + CONTAINER_PADDING_BOTTOM;

			containerGridSizes.set(container.id, {
				width: Math.max(containerWidth, 200),
				height: Math.max(containerHeight, 80)
			});

			// Set element positions relative to container (will be adjusted after Phase 1)
			for (let i = 0; i < children.length; i++) {
				const col = i % cols;
				const row = Math.floor(i / cols);
				const relX = CONTAINER_PADDING_SIDE + col * (PORT_NODE_WIDTH + PORT_GAP);
				const relY = CONTAINER_PADDING_TOP + row * (PORT_NODE_HEIGHT + PORT_GAP);

				// Store relative positions temporarily (keyed as "rel:id")
				nodePositions.set(`rel:${children[i].id}`, { x: relX, y: relY });
				elementNodeSizes.set(children[i].id, {
					x: PORT_NODE_WIDTH,
					y: PORT_NODE_HEIGHT
				});
			}
		}

		// Phase 1: Inter-host force layout
		if (containers.length === 0) {
			return { nodePositions, containerSizes, elementNodeSizes, edgeHandles };
		}

		// Deduplicate edges to one per container pair
		const containerEdgeSet = new Set<string>();
		const containerLinks: { source: string; target: string }[] = [];

		for (const edge of input.edges) {
			// Find which container each endpoint belongs to
			const sourceContainer = this.findContainerForElement(
				edge.source,
				elements,
				elementsByContainer
			);
			const targetContainer = this.findContainerForElement(
				edge.target,
				elements,
				elementsByContainer
			);
			if (!sourceContainer || !targetContainer || sourceContainer === targetContainer) continue;

			const pairKey = [sourceContainer, targetContainer].sort().join(':');
			if (!containerEdgeSet.has(pairKey)) {
				containerEdgeSet.add(pairKey);
				containerLinks.push({ source: sourceContainer, target: targetContainer });
			}
		}

		// Build simulation nodes
		const simNodes: SimNode[] = containers.map((c, i) => {
			const size = containerGridSizes.get(c.id) ?? { width: 200, height: 80 };
			const radius = 150 * Math.sqrt(containers.length);
			return {
				id: c.id,
				width: size.width,
				height: size.height,
				x: Math.cos((i * 2 * Math.PI) / containers.length) * radius,
				y: Math.sin((i * 2 * Math.PI) / containers.length) * radius
			};
		});

		if (simNodes.length === 1) {
			// Single container: place at origin
			const c = simNodes[0];
			nodePositions.set(c.id, { x: ORIGIN_PAD, y: ORIGIN_PAD });
			containerSizes.set(c.id, {
				width: containerGridSizes.get(c.id)?.width ?? 200,
				height: containerGridSizes.get(c.id)?.height ?? 80
			});
		} else {
			// Run force simulation
			const nodeById = new Map(simNodes.map((n) => [n.id, n]));
			const simLinks: SimulationLinkDatum<SimNode>[] = containerLinks
				.filter((l) => nodeById.has(l.source) && nodeById.has(l.target))
				.map((l) => ({
					source: nodeById.get(l.source)!,
					target: nodeById.get(l.target)!
				}));

			const simulation = forceSimulation<SimNode>(simNodes)
				.force(
					'link',
					forceLink<SimNode, SimulationLinkDatum<SimNode>>(simLinks).distance(200).strength(0.5)
				)
				.force('charge', forceManyBody().strength(-600))
				.force('center', forceCenter(0, 0))
				.force('collide', forceRectCollide(PADDING))
				.stop();

			simulation.tick(300);

			// Snap to grid and normalize
			let minX = Infinity;
			let minY = Infinity;
			for (const node of simNodes) {
				node.x = Math.round((node.x ?? 0) / SNAP) * SNAP;
				node.y = Math.round((node.y ?? 0) / SNAP) * SNAP;
				if (node.x < minX) minX = node.x;
				if (node.y < minY) minY = node.y;
			}

			for (const node of simNodes) {
				nodePositions.set(node.id, {
					x: (node.x ?? 0) - minX + ORIGIN_PAD,
					y: (node.y ?? 0) - minY + ORIGIN_PAD
				});
				containerSizes.set(node.id, {
					width: containerGridSizes.get(node.id)?.width ?? 200,
					height: containerGridSizes.get(node.id)?.height ?? 80
				});
			}
		}

		// Convert relative element positions to absolute
		for (const container of containers) {
			const containerPos = nodePositions.get(container.id);
			if (!containerPos) continue;

			const children = elementsByContainer.get(container.id) ?? [];
			for (const child of children) {
				const relPos = nodePositions.get(`rel:${child.id}`);
				if (relPos) {
					nodePositions.set(child.id, {
						x: containerPos.x + relPos.x,
						y: containerPos.y + relPos.y
					});
					nodePositions.delete(`rel:${child.id}`);
				}
			}
		}

		// Compute edge handles
		for (const edge of input.edges) {
			const sourcePos = nodePositions.get(edge.source);
			const targetPos = nodePositions.get(edge.target);
			if (sourcePos && targetPos) {
				const dx = targetPos.x - sourcePos.x;
				const dy = targetPos.y - sourcePos.y;
				// Bias vertical for typical layouts
				if (Math.abs(dx) > Math.abs(dy) * 2.5) {
					edgeHandles.set(edge.id, {
						sourceHandle: dx > 0 ? 'Right' : 'Left',
						targetHandle: dx > 0 ? 'Left' : 'Right'
					});
				} else {
					edgeHandles.set(edge.id, {
						sourceHandle: dy > 0 ? 'Bottom' : 'Top',
						targetHandle: dy > 0 ? 'Top' : 'Bottom'
					});
				}
			}
		}

		return { nodePositions, containerSizes, elementNodeSizes, edgeHandles };
	}

	private findContainerForElement(
		elementId: string,
		elements: { id: string; container_id?: string }[],
		elementsByContainer: Map<string, { id: string }[]>
	): string | undefined {
		// Direct lookup — find which container this element belongs to
		for (const [containerId, children] of elementsByContainer) {
			if (children.some((c) => c.id === elementId)) {
				return containerId;
			}
		}
		return undefined;
	}
}
