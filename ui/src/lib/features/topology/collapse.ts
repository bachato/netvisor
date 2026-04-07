/**
 * Collapse state management for C4 Context Zoom.
 *
 * Tracks which containers are collapsed, persists to localStorage,
 * and provides edge aggregation for collapsed containers.
 */

import { writable } from 'svelte/store';
import { browser } from '$app/environment';
import type { TopologyEdge, TopologyNode } from './types/base';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface AggregatedEdge {
	id: string;
	source: string;
	target: string;
	count: number;
	originalEdges: TopologyEdge[];
}

// ---------------------------------------------------------------------------
// Store & persistence
// ---------------------------------------------------------------------------

const COLLAPSED_STORAGE_KEY = 'scanopy_topology_collapsed_containers';

function loadCollapsedFromStorage(): Set<string> {
	if (!browser) return new Set();
	try {
		const stored = localStorage.getItem(COLLAPSED_STORAGE_KEY);
		if (stored !== null) {
			const arr = JSON.parse(stored);
			if (Array.isArray(arr)) return new Set(arr);
		}
	} catch (error) {
		console.warn('Failed to load collapsed containers from localStorage:', error);
	}
	return new Set();
}

function saveCollapsedToStorage(collapsed: Set<string>): void {
	if (!browser) return;
	try {
		localStorage.setItem(COLLAPSED_STORAGE_KEY, JSON.stringify([...collapsed]));
	} catch (error) {
		console.error('Failed to save collapsed containers to localStorage:', error);
	}
}

export const collapsedContainers = writable<Set<string>>(loadCollapsedFromStorage());

// Persist on change (skip first subscription call)
let collapsedInitialized = false;
if (browser) {
	collapsedContainers.subscribe((value) => {
		if (collapsedInitialized) {
			saveCollapsedToStorage(value);
		}
		collapsedInitialized = true;
	});
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

export function toggleCollapse(containerId: string, allNodes?: TopologyNode[]): void {
	collapsedContainers.update((set) => {
		const next = new Set(set);
		if (next.has(containerId)) {
			// Expanding: also expand child containers (subgroups)
			next.delete(containerId);
			if (allNodes) {
				for (const node of allNodes) {
					if (node.node_type === 'Container') {
						const parentId = (node as Record<string, unknown>).parent_container_id as
							| string
							| undefined;
						if (parentId === containerId) next.delete(node.id);
					}
				}
			}
		} else {
			// Collapsing: also collapse child containers (subgroups)
			next.add(containerId);
			if (allNodes) {
				for (const node of allNodes) {
					if (node.node_type === 'Container') {
						const parentId = (node as Record<string, unknown>).parent_container_id as
							| string
							| undefined;
						if (parentId === containerId) next.add(node.id);
					}
				}
			}
		}
		return next;
	});
}

export function collapseAll(containerIds: string[]): void {
	collapsedContainers.set(new Set(containerIds));
}

export function expandAll(): void {
	collapsedContainers.set(new Set());
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Build a mapping from element node ID to its parent container ID.
 */
export function buildElementToContainer(nodes: TopologyNode[]): Map<string, string> {
	const map = new Map<string, string>();
	for (const node of nodes) {
		if (node.node_type === 'Element') {
			const parentId =
				(node as Record<string, unknown>).container_id ??
				(node as Record<string, unknown>).subnet_id;
			if (typeof parentId === 'string') {
				map.set(node.id, parentId);
			}
		}
	}
	return map;
}

/**
 * Count children per container.
 */
export function buildContainerChildCounts(nodes: TopologyNode[]): Map<string, number> {
	const counts = new Map<string, number>();
	// Count direct element children per container
	for (const node of nodes) {
		if (node.node_type === 'Element') {
			const parentId =
				(node as Record<string, unknown>).container_id ??
				(node as Record<string, unknown>).subnet_id;
			if (typeof parentId === 'string') {
				counts.set(parentId, (counts.get(parentId) ?? 0) + 1);
			}
		}
	}
	// Propagate subgroup counts up to parent containers so a collapsed parent
	// shows the total count of all nested hosts, not just direct children
	for (const node of nodes) {
		if (node.node_type === 'Container') {
			const parentId = (node as Record<string, unknown>).parent_container_id as string | undefined;
			if (parentId) {
				const subgroupCount = counts.get(node.id) ?? 0;
				if (subgroupCount > 0) {
					counts.set(parentId, (counts.get(parentId) ?? 0) + subgroupCount);
				}
			}
		}
	}
	return counts;
}

/**
 * Resolve a node ID to its nearest collapsed ancestor.
 * Walks up the parent chain (element → container → parent_container → …)
 * and returns the outermost collapsed container, or null if none.
 */
function resolveCollapsedAncestor(
	nodeId: string,
	collapsed: Set<string>,
	parentMap: Map<string, string>
): string | null {
	let current = nodeId;
	let result: string | null = null;
	const visited = new Set<string>();

	while (current && !visited.has(current)) {
		visited.add(current);
		if (collapsed.has(current)) {
			result = current;
		}
		const parent = parentMap.get(current);
		if (!parent || parent === current) break;
		current = parent;
	}

	return result;
}

/**
 * Compute aggregated edges for collapsed containers.
 *
 * - Resolves each edge endpoint to its nearest collapsed ancestor
 *   (works for elements, subcontainers, and containers at any nesting depth)
 * - Groups edges between the same pair of (resolved) nodes
 * - Returns aggregated edges with count
 */
export function computeCollapsedEdges(
	edges: TopologyEdge[],
	collapsed: Set<string>,
	nodes: TopologyNode[],
	hiddenEdgeTypes: string[]
): AggregatedEdge[] {
	if (collapsed.size === 0) return [];

	// Build a parent map: nodeId → immediate parent container ID
	// Elements map to their container_id/subnet_id, containers map to parent_container_id
	const parentMap = new Map<string, string>();
	for (const node of nodes) {
		if (node.node_type === 'Element') {
			const parentId =
				(node as Record<string, unknown>).container_id ??
				(node as Record<string, unknown>).subnet_id;
			if (typeof parentId === 'string') {
				parentMap.set(node.id, parentId);
			}
		} else if (node.node_type === 'Container') {
			const parentId = (node as Record<string, unknown>).parent_container_id as string | undefined;
			if (parentId) {
				parentMap.set(node.id, parentId);
			}
		}
	}

	const hiddenSet = new Set(hiddenEdgeTypes);

	// Cache resolved ancestors
	const ancestorCache = new Map<string, string | null>();
	function getCollapsedAncestor(nodeId: string): string | null {
		if (ancestorCache.has(nodeId)) return ancestorCache.get(nodeId)!;
		const result = resolveCollapsedAncestor(nodeId, collapsed, parentMap);
		ancestorCache.set(nodeId, result);
		return result;
	}

	// Group by resolved (source, target) pair
	const groups = new Map<string, TopologyEdge[]>();

	for (const edge of edges) {
		let src = edge.source as string;
		let tgt = edge.target as string;

		// Remap to nearest collapsed ancestor
		const srcAncestor = getCollapsedAncestor(src);
		if (srcAncestor) src = srcAncestor;
		const tgtAncestor = getCollapsedAncestor(tgt);
		if (tgtAncestor) tgt = tgtAncestor;

		// Skip if neither endpoint was remapped (edge is fully outside collapsed containers)
		if (!srcAncestor && !tgtAncestor) continue;

		// Skip self-loops (both endpoints inside same collapsed container)
		if (src === tgt) continue;

		// Normalize key so (A,B) and (B,A) are the same group
		const key = src < tgt ? `${src}->${tgt}` : `${tgt}->${src}`;

		let group = groups.get(key);
		if (!group) {
			group = [];
			groups.set(key, group);
		}
		group.push(edge);
	}

	const result: AggregatedEdge[] = [];
	let idx = 0;

	for (const [key, groupEdges] of groups) {
		// If all edges in this group are hidden types, skip
		const visibleEdges = groupEdges.filter((e) => !hiddenSet.has(e.edge_type));
		if (visibleEdges.length === 0) continue;

		const [src, tgt] = key.split('->');
		result.push({
			id: `collapsed-edge-${idx++}`,
			source: src,
			target: tgt,
			count: visibleEdges.length,
			originalEdges: visibleEdges
		});
	}

	return result;
}
