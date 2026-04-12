import { get } from 'svelte/store';
import type { Topology } from '../types/base';
import type { LayoutState, PrepareResult } from './types';
import { LayoutGraph } from '../layout/layout-graph';
import {
	collapsedContainers,
	collapseLevel,
	inferCurrentLevel,
	computeCollapsedForLevel,
	buildElementToContainer,
	computeCollapsedEdges
} from '../collapse';
import { elevateEdgesToContainers } from '../layout/edge-elevation';
import { containerTypes } from '$lib/shared/stores/metadata';
import { activeView, topologyOptions } from '../queries';

function getStructureKey(topo: Topology): string {
	const nodeKeys = topo.nodes
		.map((n) => {
			const parentId = n.node_type === 'Element' ? n.container_id : n.parent_container_id;
			return `${n.id}@${parentId ?? ''}`;
		})
		.sort()
		.join(',');
	return `${topo.nodes.length}:${topo.edges.length}:${nodeKeys}`;
}

/**
 * Prepare topology data for layout: validate inputs, manage collapse state,
 * filter nodes, elevate edges, compute structure keys.
 *
 * @returns null to signal "skip this run" (view mismatch, stale data)
 */
export function prepareTopologyData(
	topology: Topology,
	state: LayoutState,
	getInfrastructureRuleId: () => string | null
): PrepareResult | null {
	const currentView = get(activeView);
	const topoKey = getStructureKey(topology);
	const viewChanged = state.lastRenderedView !== '' && currentView !== state.lastRenderedView;
	const topologyChanged = topoKey !== state.lastRenderedTopoKey;

	if (topologyChanged) {
		state.viewSizeCache.clear();
		state.containerSizeCache.clear();
		// Remove seenAutoCollapseIds entries that don't exist in the new topology
		const newContainerIds = new Set(
			topology.nodes.filter((n) => n.node_type === 'Container').map((n) => n.id)
		);
		for (const id of state.seenAutoCollapseIds) {
			if (!newContainerIds.has(id)) state.seenAutoCollapseIds.delete(id);
		}
	}

	// Skip if view changed but topology data hasn't been rebuilt yet
	if (viewChanged && !topologyChanged) {
		return null;
	}

	// Skip if data was built for a different view than the active view
	const dataView = topology.options?.request?.view;
	if (dataView && dataView !== currentView) {
		return null;
	}

	let collapsed = get(collapsedContainers);

	// Infer collapse level from persisted collapsed state on first load
	if (!state.collapseLevelInferred) {
		state.collapseLevelInferred = true;
		const inferred = inferCurrentLevel(
			collapsed,
			topology.nodes,
			containerTypes,
			getInfrastructureRuleId()
		);
		collapseLevel.set(inferred);
	}

	// On view switch, apply the current collapse level to the new view's containers
	if (viewChanged && topologyChanged && state.collapseLevelInferred) {
		const currentLevel = get(collapseLevel);
		const levelCollapsed = computeCollapsedForLevel(
			currentLevel,
			topology.nodes,
			containerTypes,
			getInfrastructureRuleId()
		);
		collapsedContainers.set(levelCollapsed);
		collapsed = levelCollapsed;
	}

	// When topology identity changes, reset tracking and strip stale collapsed IDs
	const topologyId = topology.id ?? '';
	if (topologyId !== state.lastSeenTopologyId && state.lastSeenTopologyId !== '') {
		state.seenAutoCollapseIds = new Set<string>();
		state.containerSizeCache.clear();
		state.collapseLevelInferred = false;

		if (collapsed.size > 0) {
			const newContainerIds = new Set(
				topology.nodes.filter((n) => n.node_type === 'Container').map((n) => n.id)
			);
			const validCollapsed = new Set([...collapsed].filter((id) => newContainerIds.has(id)));
			const staleCount = collapsed.size - validCollapsed.size;

			// If ALL old root containers were collapsed, preserve "overview mode"
			if (state.layoutGraph) {
				const oldRootIds = [...state.layoutGraph.containers.values()]
					.filter((c) => !c.parent)
					.map((c) => c.id);
				const wasFullyCollapsed =
					oldRootIds.length > 0 && oldRootIds.every((id) => collapsed.has(id));
				if (wasFullyCollapsed) {
					const allContainerIds = topology.nodes
						.filter((n) => n.node_type === 'Container')
						.map((n) => n.id);
					const allCollapsed = new Set(allContainerIds);
					collapsedContainers.set(allCollapsed);
					collapseLevel.set(1);
					collapsed = allCollapsed;
					state.fitViewPending = true;
				} else if (staleCount > 0) {
					collapsedContainers.set(validCollapsed);
					collapsed = validCollapsed;
				}
			} else if (staleCount > 0) {
				collapsedContainers.set(validCollapsed);
				collapsed = validCollapsed;
			}
		}
	}
	state.lastSeenTopologyId = topologyId;

	// All nodes participate in layout
	let layoutNodes = topology.nodes;

	// Remove subcontainers with no remaining element children
	const subcontainerIds = new Set(
		layoutNodes
			.filter(
				(n) =>
					n.node_type === 'Container' &&
					containerTypes.getMetadata(
						((n as Record<string, unknown>).container_type as string) ?? 'Subnet'
					).is_subcontainer
			)
			.map((n) => n.id)
	);
	if (subcontainerIds.size > 0) {
		const childCounts = new Map<string, number>();
		for (const n of layoutNodes) {
			if (n.node_type === 'Element') {
				const cid = (n as Record<string, unknown>).container_id as string;
				if (subcontainerIds.has(cid)) {
					childCounts.set(cid, (childCounts.get(cid) ?? 0) + 1);
				}
			}
		}
		layoutNodes = layoutNodes.filter(
			(n) =>
				!(
					n.node_type === 'Container' &&
					subcontainerIds.has(n.id) &&
					!childCounts.has(n.id) &&
					!collapsed.has(n.id)
				)
		);
	}

	const elementToContainer = buildElementToContainer(layoutNodes);
	const hiddenEdgeTypes = get(topologyOptions).local.hide_edge_types ?? [];

	// Elevate edges targeting elements inside absorbing containers
	const elevatedEdges = elevateEdgesToContainers(topology.edges, layoutNodes);

	// Map containers to themselves for bundling
	for (const node of layoutNodes) {
		if (node.node_type === 'Container' && !elementToContainer.has(node.id)) {
			elementToContainer.set(node.id, node.id);
		}
	}

	// Compute structure and base keys
	const baseKey = currentView + ':' + topoKey + ':' + hiddenEdgeTypes.join(',');
	const structureKey = baseKey + ':' + Array.from(collapsed).sort().join(',');
	const isNewStructure = state.sessionStructureKey !== structureKey;
	const isNewBaseStructure = state.sessionBaseKey !== baseKey;

	// Capture expanded sizes before rebuilding the graph
	const prevExpandedSizes = state.layoutGraph?.getExpandedContainerSizes();
	const prevChildPositions = state.layoutGraph?.getContainerChildPositions();

	// Build/rebuild layout graph when structure changes
	if (!state.layoutGraph || isNewStructure) {
		state.layoutGraph = LayoutGraph.fromTopology(layoutNodes);
	}

	// Defer collapse so ELK runs with everything expanded — only if
	// no expanded size is available from either the graph or the cache.
	let deferCollapse = false;
	if (isNewStructure && collapsed.size > 0) {
		for (const id of collapsed) {
			const hasChildren = layoutNodes.some(
				(n) =>
					(n.node_type === 'Element' && (n as Record<string, unknown>).container_id === id) ||
					(n.node_type === 'Container' && (n as Record<string, unknown>).parent_container_id === id)
			);
			const hasExpandedSize =
				prevExpandedSizes?.has(id) || !!state.containerSizeCache.get(id)?.expanded;
			if (hasChildren && !hasExpandedSize) {
				deferCollapse = true;
				break;
			}
		}
	}

	// Sync collapse state from store -> graph
	let collapseChanged = false;
	if (!deferCollapse) {
		collapseChanged = state.layoutGraph.syncCollapseState(collapsed);
	}

	// Force ELK re-layout when a container was expanded but has no cached layout
	let needsElkForExpand = false;
	if (collapseChanged) {
		for (const c of state.layoutGraph.containers.values()) {
			if (!c.collapsed && c.allChildren.length > 0) {
				const hasZeroExpandedSize = c.expandedSize.width === 0;
				const hasUninitializedChildren = c.childElements.some((el) => el.size.y === 0);
				if (hasZeroExpandedSize || hasUninitializedChildren) {
					needsElkForExpand = true;
					state.seenAutoCollapseIds.add(c.id);
				}
			}
		}
	}

	// Compute aggregated edges for collapsed containers
	const aggregatedEdges = computeCollapsedEdges(
		elevatedEdges,
		collapsed,
		layoutNodes,
		hiddenEdgeTypes
	);

	const visibleNodes = state.layoutGraph.getVisibleNodes(layoutNodes);

	const isViewTransition = isNewStructure && viewChanged && topologyChanged;
	const needsElk = isNewStructure || needsElkForExpand;

	// Clear view size cache on base structure change
	if (isNewBaseStructure) {
		state.viewSizeCache.delete(`${currentView}:${topology.id}`);
	}

	return {
		layoutNodes,
		collapsed,
		elevatedEdges,
		elementToContainer,
		topoKey,
		structureKey,
		baseKey,
		isNewStructure,
		isNewBaseStructure,
		viewChanged,
		topologyChanged,
		deferCollapse,
		needsElkForExpand,
		collapseChanged,
		visibleNodes,
		aggregatedEdges,
		hiddenEdgeTypes,
		prevExpandedSizes,
		prevChildPositions,
		currentView,
		topologyId: topology.id ?? '',
		needsElk,
		isViewTransition
	};
}
