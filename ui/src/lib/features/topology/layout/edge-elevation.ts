import type { TopologyEdge, TopologyNode } from '../types/base';

/**
 * Elevate edge endpoints from elements to the outermost absorbing container.
 *
 * When a container or subcontainer has `absorbs_edges: true`, edges targeting
 * elements inside it should visually attach to the container boundary instead.
 * If multiple nested containers absorb, the outermost absorber wins.
 *
 * After elevation, edges that share the same source+target+edge_type are
 * deduplicated (only the first is kept).
 */
export function elevateEdgesToContainers(
	edges: TopologyEdge[],
	nodes: TopologyNode[]
): TopologyEdge[] {
	// Build container lookup: id → { parentId, absorbsEdges }
	const containerInfo = new Map<string, { parentId: string | undefined; absorbsEdges: boolean }>();
	for (const node of nodes) {
		if (node.node_type === 'Container') {
			const n = node as Record<string, unknown>;
			containerInfo.set(node.id, {
				parentId: n.parent_container_id as string | undefined,
				absorbsEdges: (n.absorbs_edges as boolean) ?? false
			});
		}
	}

	// Build element → outermost absorbing container map
	const elevationMap = new Map<string, string>();
	for (const node of nodes) {
		if (node.node_type !== 'Element') continue;
		const containerId =
			(node as Record<string, unknown>).container_id ?? (node as Record<string, unknown>).subnet_id;
		if (typeof containerId !== 'string') continue;

		// Walk up from the element's direct container through parents,
		// tracking the outermost container that absorbs edges
		let outermostAbsorber: string | undefined;
		let current: string | undefined = containerId;
		while (current) {
			const info = containerInfo.get(current);
			if (!info) break;
			if (info.absorbsEdges) {
				outermostAbsorber = current;
			}
			current = info.parentId;
		}

		if (outermostAbsorber) {
			elevationMap.set(node.id, outermostAbsorber);
		}
	}

	if (elevationMap.size === 0) return edges;

	// Elevate edge endpoints and deduplicate
	const seen = new Set<string>();
	const result: TopologyEdge[] = [];

	for (const edge of edges) {
		const source = elevationMap.get(edge.source) ?? edge.source;
		const target = elevationMap.get(edge.target) ?? edge.target;

		// Skip self-loops created by elevation
		if (source === target) continue;

		// Deduplicate by source+target+edge_type
		const key = `${source}:${target}:${edge.edge_type}`;
		if (seen.has(key)) continue;
		seen.add(key);

		if (source !== edge.source || target !== edge.target) {
			result.push({ ...edge, source, target });
		} else {
			result.push(edge);
		}
	}

	return result;
}
