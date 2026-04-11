/**
 * LayoutGraph: class-based layout state for topology visualization.
 *
 * Replaces the scattered Maps (nodePositions, containerSizes, elementNodeSizes, etc.)
 * with a proper object graph. Each container/element stores its own position, size,
 * and collapse state — eliminating the "lost original size" bugs and map-juggling.
 */

import type { TopologyNode } from '../types/base';
import type { EdgeHandles } from './elk-layout';
import { containerTypes } from '$lib/shared/stores/metadata';

const CHILD_SPACING = 30;

export class LayoutElement {
	id: string;
	node: TopologyNode;
	container: LayoutContainer | null = null;
	position: { x: number; y: number } = { x: 0, y: 0 };
	/** Current measured size from DOM */
	size: { x: number; y: number };
	portsExpanded = false;

	constructor(node: TopologyNode) {
		this.id = node.id;
		this.node = node;
		this.size = { x: node.size?.x ?? 250, y: node.size?.y ?? 100 };
	}

	get width(): number {
		return this.size.x;
	}
	get height(): number {
		return this.size.y;
	}
}

export class LayoutContainer {
	id: string;
	node: TopologyNode;
	parent: LayoutContainer | null = null;
	childContainers: LayoutContainer[] = [];
	childElements: LayoutElement[] = [];
	position: { x: number; y: number } = { x: 0, y: 0 };
	/** Size computed by ELK when expanded */
	expandedSize: { width: number; height: number } = { width: 0, height: 0 };
	collapsed = false;
	/** DOM-measured size when collapsed, set after first layout pass */
	measuredCollapsedSize: { width: number; height: number } | null = null;
	isSubcontainer: boolean;
	containerType: string;

	constructor(node: TopologyNode) {
		this.id = node.id;
		this.node = node;
		this.containerType = ((node as Record<string, unknown>).container_type as string) ?? 'Subnet';
		this.isSubcontainer = containerTypes.getMetadata(this.containerType).is_subcontainer;
	}

	get collapsedSize(): { width: number; height: number } {
		if (this.measuredCollapsedSize) return { ...this.measuredCollapsedSize };
		const meta = containerTypes.getMetadata(this.containerType);
		return { ...meta.collapsed_size };
	}

	get size(): { width: number; height: number } {
		return this.collapsed ? this.collapsedSize : this.expandedSize;
	}

	/** All children (containers + elements) for layout purposes */
	get allChildren(): (LayoutContainer | LayoutElement)[] {
		return [...this.childContainers, ...this.childElements];
	}

	/** Recursive count of element nodes (for collapsed badge) */
	get childCount(): number {
		let count = this.childElements.length;
		for (const child of this.childContainers) {
			count += child.childCount;
		}
		return count;
	}

	/**
	 * Reflow children within this container after a size change.
	 * If changedChildId is provided, that child keeps its position and only
	 * siblings below it shift by the height delta (stable local adjustment).
	 * Otherwise, restacks all children from their current positions.
	 * Returns the height delta so callers can propagate.
	 */
	reflowChildren(changedChildId?: string): number {
		const children = this.allChildren;
		if (children.length === 0) return 0;

		// Group all children (elements + subgroups) by x-position
		const columns = new Map<
			number,
			{ child: LayoutContainer | LayoutElement; y: number; height: number }[]
		>();
		for (const child of children) {
			const pos = child.position;
			const x = pos.x;
			const height = child instanceof LayoutContainer ? child.size.height : child.height;
			if (!columns.has(x)) columns.set(x, []);
			columns.get(x)!.push({ child, y: pos.y, height });
		}

		if (changedChildId) {
			// Stable reflow: find the changed child, shift only siblings below it
			for (const [, colNodes] of columns) {
				colNodes.sort((a, b) => a.y - b.y);
				const changedIdx = colNodes.findIndex((n) => n.child.id === changedChildId);
				if (changedIdx === -1) continue;

				// Restack from the changed node downward
				let y = colNodes[changedIdx].child.position.y + colNodes[changedIdx].height + CHILD_SPACING;
				for (let i = changedIdx + 1; i < colNodes.length; i++) {
					colNodes[i].child.position = { x: colNodes[i].child.position.x, y };
					y += colNodes[i].height + CHILD_SPACING;
				}
			}
		} else {
			// Full reflow: restack each column from the first node's position
			for (const [, colNodes] of columns) {
				colNodes.sort((a, b) => a.y - b.y);
				const startY = colNodes[0].y;
				let y = startY;
				for (const entry of colNodes) {
					entry.child.position = { x: entry.child.position.x, y };
					y += entry.height + CHILD_SPACING;
				}
			}
		}

		// Recompute container size from all columns
		let maxColumnBottom = 0;
		let maxColumnRight = 0;
		for (const [, colNodes] of columns) {
			const last = colNodes[colNodes.length - 1];
			const bottom = last.child.position.y + last.height;
			if (bottom > maxColumnBottom) maxColumnBottom = bottom;

			for (const entry of colNodes) {
				const w =
					entry.child instanceof LayoutContainer ? entry.child.size.width : entry.child.width;
				const right = entry.child.position.x + w;
				if (right > maxColumnRight) maxColumnRight = right;
			}
		}

		const meta = containerTypes.getMetadata(this.containerType);
		const newHeight = maxColumnBottom + meta.padding.bottom;
		const oldHeight = this.expandedSize.height;
		if (changedChildId) {
			// Stable reflow (child collapsed/expanded): recompute width since
			// the widest child may have changed size
			const newWidth = maxColumnRight + meta.padding.right;
			this.expandedSize = { width: newWidth, height: newHeight };
		} else {
			// Full reflow (container itself expanding): preserve ELK-computed
			// width, only update height from vertical restacking
			this.expandedSize = { width: this.expandedSize.width, height: newHeight };
		}
		return newHeight - oldHeight;
	}
}

export class LayoutGraph {
	containers = new Map<string, LayoutContainer>();
	elements = new Map<string, LayoutElement>();
	edgeHandles = new Map<string, EdgeHandles>();

	/** Build graph from topology nodes */
	static fromTopology(nodes: TopologyNode[]): LayoutGraph {
		const graph = new LayoutGraph();

		// Create all containers
		for (const node of nodes) {
			if (node.node_type === 'Container') {
				graph.containers.set(node.id, new LayoutContainer(node));
			}
		}

		// Create all elements and link to containers
		for (const node of nodes) {
			if (node.node_type === 'Element') {
				const element = new LayoutElement(node);
				const parentId =
					(node as Record<string, unknown>).container_id ??
					(node as Record<string, unknown>).subnet_id;
				if (typeof parentId === 'string') {
					const container = graph.containers.get(parentId);
					if (container) {
						element.container = container;
						container.childElements.push(element);
					}
				}
				graph.elements.set(node.id, element);
			}
		}

		// Link parent-child container relationships
		for (const container of graph.containers.values()) {
			const parentId = (container.node as Record<string, unknown>).parent_container_id as
				| string
				| undefined;
			if (parentId) {
				const parent = graph.containers.get(parentId);
				if (parent) {
					container.parent = parent;
					parent.childContainers.push(container);
				}
			}
		}

		return graph;
	}

	/** Apply positions and sizes from ELK layout result */
	applyElkResult(
		nodePositions: Map<string, { x: number; y: number }>,
		containerSizes: Map<string, { width: number; height: number }>,
		elementNodeSizes: Map<string, { x: number; y: number }>,
		edgeHandles: Map<string, EdgeHandles>
	): void {
		for (const [id, pos] of nodePositions) {
			const container = this.containers.get(id);
			if (container) {
				container.position = { ...pos };
				if (container.collapsed) {
					// Store the ELK-assigned collapsed size (from DOM measurement)
					const size = containerSizes.get(id);
					if (size) container.measuredCollapsedSize = { ...size };
					console.log(
						`[LAYOUT-DEBUG] applyElkResult collapsed ${id.substring(0, 8)} measuredCollapsed=${JSON.stringify(size)} expandedSize=${JSON.stringify(container.expandedSize)}`
					);
				} else {
					const size = containerSizes.get(id);
					if (size) container.expandedSize = { ...size };
					console.log(
						`[LAYOUT-DEBUG] applyElkResult expanded ${id.substring(0, 8)} expandedSize=${JSON.stringify(size)}`
					);
				}
			}
			const element = this.elements.get(id);
			if (element) {
				element.position = { ...pos };
				const size = elementNodeSizes.get(id);
				if (size) element.size = { ...size };
			}
		}
		this.edgeHandles = new Map(edgeHandles);

		// Summary: count containers by state
		let expandedCount = 0;
		let collapsedCount = 0;
		let zeroExpandedCount = 0;
		for (const c of this.containers.values()) {
			if (c.collapsed) collapsedCount++;
			else expandedCount++;
			if (c.expandedSize.width === 0) zeroExpandedCount++;
		}
		console.log(
			`[LAYOUT-DEBUG] applyElkResult summary: ${expandedCount} expanded, ${collapsedCount} collapsed, ${zeroExpandedCount} with expandedSize=0`
		);
	}

	/** Get node position (works for both containers and elements) */
	getPosition(nodeId: string): { x: number; y: number } | undefined {
		return this.containers.get(nodeId)?.position ?? this.elements.get(nodeId)?.position;
	}

	/** Get container size (respects collapsed state) */
	getContainerSize(containerId: string): { width: number; height: number } | undefined {
		return this.containers.get(containerId)?.size;
	}

	/** Get container expanded size (ignores collapsed state) */
	getExpandedSize(containerId: string): { width: number; height: number } | undefined {
		const container = this.containers.get(containerId);
		return container && container.expandedSize.width > 0 ? container.expandedSize : undefined;
	}

	/** Get expanded sizes for all containers (for preserving across rebuilds) */
	getExpandedContainerSizes(): Map<string, { width: number; height: number }> {
		const sizes = new Map<string, { width: number; height: number }>();
		for (const [id, container] of this.containers) {
			if (container.expandedSize.width > 0) {
				sizes.set(id, { ...container.expandedSize });
			}
		}
		return sizes;
	}

	/** Restore expanded sizes from a previous layout (for collapsed containers across rebuilds) */
	restoreExpandedSizes(sizes: Map<string, { width: number; height: number }>): void {
		for (const [id, size] of sizes) {
			const container = this.containers.get(id);
			if (container && container.collapsed) {
				container.expandedSize = { ...size };
				console.log(
					`[LAYOUT-DEBUG] restoreExpandedSizes ${id.substring(0, 8)} restored=${JSON.stringify(size)}`
				);
			}
		}
	}

	/** Get child positions for all containers with valid expanded sizes (for preserving across rebuilds) */
	getContainerChildPositions(): Map<string, Map<string, { x: number; y: number }>> {
		const positions = new Map<string, Map<string, { x: number; y: number }>>();
		for (const [id, container] of this.containers) {
			if (container.expandedSize.width > 0) {
				const childPos = new Map<string, { x: number; y: number }>();
				for (const child of container.childElements) {
					childPos.set(child.id, { ...child.position });
				}
				for (const child of container.childContainers) {
					childPos.set(child.id, { ...child.position });
				}
				if (childPos.size > 0) {
					positions.set(id, childPos);
				}
			}
		}
		return positions;
	}

	/** Restore child positions for collapsed containers (after graph rebuild where ELK skipped them) */
	restoreContainerChildPositions(
		positions: Map<string, Map<string, { x: number; y: number }>>
	): void {
		for (const [containerId, childPositions] of positions) {
			const container = this.containers.get(containerId);
			if (container && container.collapsed) {
				for (const [childId, pos] of childPositions) {
					const element = this.elements.get(childId);
					if (element) {
						element.position = { ...pos };
					}
					const childContainer = this.containers.get(childId);
					if (childContainer) {
						childContainer.position = { ...pos };
					}
				}
			}
		}
	}

	/** Get element size */
	getElementSize(elementId: string): { x: number; y: number } | undefined {
		return this.elements.get(elementId)?.size;
	}

	/** Get child count for a container (recursive) */
	getChildCount(containerId: string): number {
		return this.containers.get(containerId)?.childCount ?? 0;
	}

	/**
	 * Collapse a container. If it has child containers, collapse them too.
	 * Returns the set of all collapsed container IDs.
	 */
	collapse(containerId: string): Set<string> {
		const affected = new Set<string>();
		const container = this.containers.get(containerId);
		if (!container || container.collapsed) return affected;

		container.collapsed = true;
		affected.add(containerId);

		// Cascade: collapse child containers
		for (const child of container.childContainers) {
			if (!child.collapsed) {
				child.collapsed = true;
				affected.add(child.id);
			}
		}

		// Reflow parent if this is a subgroup — keep this container in place, shift siblings
		if (container.parent && !container.parent.collapsed) {
			const delta = container.parent.reflowChildren(containerId);
			if (delta !== 0 && container.parent.parent) {
				this.propagateResize(container.parent);
			}
		}

		return affected;
	}

	/**
	 * Expand a container. Also expands child containers.
	 * Returns the set of all expanded container IDs.
	 */
	expand(containerId: string): Set<string> {
		const affected = new Set<string>();
		const container = this.containers.get(containerId);
		if (!container || !container.collapsed) return affected;

		container.collapsed = false;
		affected.add(containerId);

		// Children stay collapsed when parent expands — no cascade needed

		// Recompute this container's expandedSize based on current child states,
		// since children may have been collapsed during the earlier collapse cascade
		container.reflowChildren();

		// Reflow parent if this is a subgroup — keep this container in place, shift siblings
		if (container.parent && !container.parent.collapsed) {
			const delta = container.parent.reflowChildren(containerId);
			if (delta !== 0 && container.parent.parent) {
				this.propagateResize(container.parent);
			}
		}

		return affected;
	}

	/**
	 * Update an element's size (e.g., after port expansion).
	 * Reflows its container and propagates upward.
	 */
	updateElementSize(elementId: string, newSize: { x: number; y: number }): void {
		const element = this.elements.get(elementId);
		if (!element) return;
		element.size = { ...newSize };

		// Reflow the element's container — keep this element in place, shift siblings below
		const container = element.container;
		if (container && !container.collapsed) {
			const delta = container.reflowChildren(elementId);
			if (delta !== 0) {
				this.propagateResize(container);
			}
		}
	}

	/**
	 * Propagate a container's size change to its parent.
	 * Shifts siblings below and grows the parent.
	 */
	private propagateResize(container: LayoutContainer): void {
		const parent = container.parent;
		if (!parent || parent.collapsed) return;

		const delta = parent.reflowChildren();
		if (delta !== 0 && parent.parent) {
			this.propagateResize(parent);
		}
	}

	/**
	 * Get visible nodes (filtering out children of collapsed containers).
	 */
	getVisibleNodes(allNodes: TopologyNode[]): TopologyNode[] {
		const collapsedIds = new Set<string>();
		for (const c of this.containers.values()) {
			if (c.collapsed) collapsedIds.add(c.id);
		}

		return allNodes.filter((node) => {
			if (node.node_type === 'Element') {
				const element = this.elements.get(node.id);
				if (element?.container && collapsedIds.has(element.container.id)) return false;
			}
			if (node.node_type === 'Container') {
				const container = this.containers.get(node.id);
				if (container?.parent && collapsedIds.has(container.parent.id)) return false;
			}
			return true;
		});
	}

	/**
	 * Get subgroup summaries for a container (for collapsed subnet display).
	 */
	getSubgroupSummaries(containerId: string): { groupId: string; childCount: number }[] {
		const container = this.containers.get(containerId);
		if (!container) return [];
		return container.childContainers.map((child) => ({
			groupId: child.id,
			childCount: child.childCount
		}));
	}

	/**
	 * Get the set of all collapsed container IDs.
	 */
	getCollapsedIds(): Set<string> {
		const ids = new Set<string>();
		for (const c of this.containers.values()) {
			if (c.collapsed) ids.add(c.id);
		}
		return ids;
	}

	/**
	 * Sync collapse state from an external Set (e.g., the collapsedContainers store).
	 * Returns true if anything changed.
	 */
	syncCollapseState(externalCollapsed: Set<string>): boolean {
		let changed = false;
		for (const container of this.containers.values()) {
			const shouldBeCollapsed = externalCollapsed.has(container.id);
			if (container.collapsed !== shouldBeCollapsed) {
				if (shouldBeCollapsed) {
					this.collapse(container.id);
				} else {
					this.expand(container.id);
				}
				changed = true;
			}
		}
		return changed;
	}

	/**
	 * Check if a node ID belongs to a subgroup container.
	 */
	isSubcontainer(nodeId: string): boolean {
		return this.containers.get(nodeId)?.isSubcontainer ?? false;
	}

	/** Apply positions from force layout (collapsed containers only) */
	applyForceResult(
		nodePositions: Map<string, { x: number; y: number }>,
		edgeHandles: Map<string, EdgeHandles>,
		measuredSizes?: Map<string, { x: number; y: number }>
	): void {
		for (const [id, pos] of nodePositions) {
			const container = this.containers.get(id);
			if (container) {
				container.position = { ...pos };
				const measured = measuredSizes?.get(id);
				if (measured && container.collapsed) {
					container.measuredCollapsedSize = { width: measured.x, height: measured.y };
				}
			}
		}
		this.edgeHandles = new Map(edgeHandles);
	}
}
