import type { TopologyEdge } from '../types/base';
import type { components } from '$lib/api/schema';

type EdgeTypeDiscriminants = components['schemas']['EdgeTypeDiscriminants'];
type TopologyPerspective = components['schemas']['TopologyPerspective'];

export type EdgeClassification = 'primary' | 'overlay' | 'disabled';

/**
 * Classify an edge as primary (affects layout), overlay (drawn after layout),
 * or disabled (not shown in this perspective).
 * Uses the backend-provided `classification` field; defaults to overlay if absent.
 */
export function classifyEdge(edge: TopologyEdge): EdgeClassification {
	if ('classification' in edge && (edge as Record<string, unknown>).classification) {
		return (edge as Record<string, unknown>).classification as EdgeClassification;
	}
	return 'overlay';
}

export function isOverlayEdge(edge: TopologyEdge): boolean {
	return classifyEdge(edge) === 'overlay';
}

export function isDisabledEdge(edge: TopologyEdge): boolean {
	return classifyEdge(edge) === 'disabled';
}

/** Returns the edge types that should be hidden by default for a given perspective. */
export function getDefaultHiddenEdgeTypes(
	perspective: TopologyPerspective
): EdgeTypeDiscriminants[] {
	switch (perspective) {
		case 'L3Logical':
			return ['HostVirtualization', 'ServiceVirtualization', 'PhysicalLink'];
		case 'L2Physical':
			return ['HostVirtualization', 'ServiceVirtualization', 'RequestPath', 'HubAndSpoke'];
		case 'Infrastructure':
			return ['RequestPath', 'HubAndSpoke', 'PhysicalLink'];
		case 'Application':
			return ['HostVirtualization', 'ServiceVirtualization', 'HubAndSpoke', 'PhysicalLink'];
	}
}
