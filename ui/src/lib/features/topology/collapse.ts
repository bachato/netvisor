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

export function toggleCollapse(containerId: string): void {
	collapsedContainers.update((set) => {
		const next = new Set(set);
		if (next.has(containerId)) {
			next.delete(containerId);
		} else {
			next.add(containerId);
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
 * Build a mapping from leaf node ID to its parent container ID.
 */
export function buildLeafToContainer(nodes: TopologyNode[]): Map<string, string> {
	const map = new Map<string, string>();
	for (const node of nodes) {
		if (node.node_type === 'LeafNode') {
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
	for (const node of nodes) {
		if (node.node_type === 'LeafNode') {
			const parentId =
				(node as Record<string, unknown>).container_id ??
				(node as Record<string, unknown>).subnet_id;
			if (typeof parentId === 'string') {
				counts.set(parentId, (counts.get(parentId) ?? 0) + 1);
			}
		}
	}
	return counts;
}

/**
 * Compute aggregated edges for collapsed containers.
 *
 * - Remaps edges whose source/target is a hidden leaf inside a collapsed container
 * - Groups edges between the same pair of (resolved) nodes
 * - Returns aggregated edges with count
 */
export function computeCollapsedEdges(
	edges: TopologyEdge[],
	collapsed: Set<string>,
	leafToContainer: Map<string, string>,
	hiddenEdgeTypes: string[]
): AggregatedEdge[] {
	if (collapsed.size === 0) return [];

	const hiddenSet = new Set(hiddenEdgeTypes);

	// Group by resolved (source, target) pair
	const groups = new Map<string, TopologyEdge[]>();

	for (const edge of edges) {
		let src = edge.source as string;
		let tgt = edge.target as string;

		// Remap if the leaf's container is collapsed
		const srcContainer = leafToContainer.get(src);
		if (srcContainer && collapsed.has(srcContainer)) {
			src = srcContainer;
		}
		const tgtContainer = leafToContainer.get(tgt);
		if (tgtContainer && collapsed.has(tgtContainer)) {
			tgt = tgtContainer;
		}

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
