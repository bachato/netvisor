import type { Node, Edge } from '@xyflow/svelte';
import { getEdgeDisplayState } from '../interactions';

/**
 * Compute updated edge display state (animation, highlight, selection)
 * based on current selection and filter stores.
 */
export function computeEdgeDisplayUpdates(
	currentEdges: Edge[],
	selectedNode: Node | null,
	selectedEdge: Edge | null,
	searchHidden: Set<string>,
	tagHidden: Set<string>
): Edge[] {
	const hasActiveSelection = !!(selectedNode || selectedEdge);
	return currentEdges.map((e) => {
		const { shouldAnimate, shouldShowFull, isEndpointSearchHidden, isEndpointTagHidden } =
			getEdgeDisplayState(e, selectedNode, selectedEdge, searchHidden, tagHidden);
		return {
			...e,
			data: {
				...e.data,
				shouldShowFull,
				shouldAnimate,
				isSelected: selectedEdge?.id === e.id,
				hasActiveSelection,
				isEndpointSearchHidden,
				isEndpointTagHidden
			},
			animated: false
		};
	});
}
