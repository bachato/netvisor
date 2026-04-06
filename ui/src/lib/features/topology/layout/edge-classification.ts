import type { TopologyEdge } from '../types/base';
import type { components } from '$lib/api/schema';
import { views } from '$lib/shared/stores/metadata';

type EdgeTypeDiscriminants = components['schemas']['EdgeTypeDiscriminants'];
type TopologyView = components['schemas']['TopologyView'];

export type EdgeClassification = 'primary' | 'overlay' | 'overlay_hidden' | 'disabled';

/**
 * Classify an edge as primary (affects layout), overlay (drawn after layout),
 * or disabled (not shown in this view).
 * Uses the backend-provided `classification` field; defaults to overlay if absent.
 */
export function classifyEdge(edge: TopologyEdge): EdgeClassification {
	if ('classification' in edge && (edge as Record<string, unknown>).classification) {
		return (edge as Record<string, unknown>).classification as EdgeClassification;
	}
	return 'overlay';
}

export function isOverlayEdge(edge: TopologyEdge): boolean {
	const c = classifyEdge(edge);
	return c === 'overlay' || c === 'overlay_hidden';
}

export function isDisabledEdge(edge: TopologyEdge): boolean {
	return classifyEdge(edge) === 'disabled';
}

/** Returns the edge types that should be hidden by default for a given view.
 * Reads from view metadata — edge types classified as `overlay_hidden`. */
export function getDefaultHiddenEdgeTypes(view: TopologyView): EdgeTypeDiscriminants[] {
	const meta = views.getMetadata(view) as {
		edge_classifications?: Record<string, string>;
	} | null;
	if (!meta?.edge_classifications) return [];
	return Object.entries(meta.edge_classifications)
		.filter(([, c]) => c === 'overlay_hidden')
		.map(([id]) => id as EdgeTypeDiscriminants);
}
