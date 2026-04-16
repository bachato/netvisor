import type { TopologyNode } from './types/base';

/**
 * Pre-computed parent/container lookups for the topology node hierarchy.
 * Built once per pipeline run from the full topology nodes (not just visible),
 * replacing 6+ duplicated `container_id ?? subnet_id` constructions across
 * collapse.ts, build-flow-edges.ts, elk-layout.ts, edge-elevation.ts, etc.
 */
export interface TopologyParentIndex {
	/** Element or container node ID → immediate parent container ID */
	parentMap: Map<string, string>;
	/** Element node ID → immediate container ID (elements only) */
	elementToContainer: Map<string, string>;
	/** Element node ID → root container ID (walks through subcontainers to top-level container) */
	elementToRootContainer: Map<string, string>;
	/** Container node ID → parent container ID (containers only) */
	containerParent: Map<string, string>;
	/** Set of all container node IDs */
	containerIds: Set<string>;
}

/**
 * Build a TopologyParentIndex from topology nodes.
 * Should be called with the full node set (not just visible/layout nodes)
 * since collapsed container children still need resolution for edges.
 */
export function buildTopologyParentIndex(nodes: TopologyNode[]): TopologyParentIndex {
	const parentMap = new Map<string, string>();
	const elementToContainer = new Map<string, string>();
	const containerParent = new Map<string, string>();
	const containerIds = new Set<string>();

	for (const node of nodes) {
		if (node.node_type === 'Element') {
			const parentId =
				(node as Record<string, unknown>).container_id ??
				(node as Record<string, unknown>).subnet_id;
			if (typeof parentId === 'string') {
				parentMap.set(node.id, parentId);
				elementToContainer.set(node.id, parentId);
			}
		} else if (node.node_type === 'Container') {
			containerIds.add(node.id);
			const parentId = (node as Record<string, unknown>).parent_container_id as string | undefined;
			if (parentId) {
				parentMap.set(node.id, parentId);
				containerParent.set(node.id, parentId);
			}
		}
	}

	// Build elementToRootContainer by walking from each element's immediate
	// container up through the container parent chain to the root.
	const elementToRootContainer = new Map<string, string>();
	for (const [elementId, immediateContainer] of elementToContainer) {
		let current = immediateContainer;
		while (containerParent.has(current)) {
			current = containerParent.get(current)!;
		}
		elementToRootContainer.set(elementId, current);
	}

	return {
		parentMap,
		elementToContainer,
		elementToRootContainer,
		containerParent,
		containerIds
	};
}
