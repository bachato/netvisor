import { writable, get } from 'svelte/store';
import type { Edge } from '@xyflow/svelte';
import type { Node } from '@xyflow/svelte';
import type { QueryClient } from '@tanstack/svelte-query';
import { edgeTypes, views, serviceDefinitions, subnetTypes } from '$lib/shared/stores/metadata';
import type { TopologyEdge, TopologyNode, Topology } from './types/base';
import {
	isDisabledEdge,
	getHighlightBehavior,
	showDirectionality
} from './layout/edge-classification';
import { elevateEdgesToContainers } from './layout/edge-elevation';
import { getContainerContents, buildEntityNodeIndex } from './resolvers';
import { getHostFromInterfaceIdFromCache } from '../hosts/queries';
import {
	getInterfacesForHostFromCache,
	getInterfacesForSubnetFromCache
} from '../interfaces/queries';
import { getSubnetByIdFromCache } from '../subnets/queries';

// Shared stores for hover state across all component instances
export const groupHoverState = writable<Map<string, boolean>>(new Map());
export const edgeHoverState = writable<Map<string, boolean>>(new Map());
export const connectedNodeIds = writable<Set<string>>(new Set());
export const isExporting = writable(false);
export const newNodeIds = writable<Set<string>>(new Set());

// Tag filter stores - nodes/services hidden by tag filter
export const tagHiddenNodeIds = writable<Set<string>>(new Set());
export const tagHiddenServiceIds = writable<Set<string>>(new Set());

// Search stores
export const searchHiddenNodeIds = writable<Set<string>>(new Set());
export const searchMatchNodeIds = writable<string[]>([]);
export const searchActiveIndex = writable<number>(0);
export const searchOpen = writable<boolean>(false);

// Special sentinel value for "Untagged" pseudo-tag
export const UNTAGGED_SENTINEL = '__untagged__';

// Tag hover state for highlighting nodes with a specific tag
export interface HoveredTag {
	tagId: string;
	color: string;
	entityType: 'host' | 'service' | 'subnet';
}
export const hoveredTag = writable<HoveredTag | null>(null);

// Service category hover state for highlighting services in the same category
export interface HoveredServiceCategory {
	category: string;
	color: string;
}
export const hoveredServiceCategory = writable<HoveredServiceCategory | null>(null);

// Edge type hover state for highlighting edges of a specific type
export interface HoveredEdgeType {
	edgeType: string;
	color: string;
}
export const hoveredEdgeType = writable<HoveredEdgeType | null>(null);

// Edge bundle expand/collapse state (transient, not persisted)
export const expandedBundles = writable<Set<string>>(new Set());

// Open ports expand/collapse state per leaf node (transient, not persisted)
export const expandedPortNodeIds = writable<Set<string>>(new Set());

export function toggleBundleExpanded(bundleId: string): void {
	expandedBundles.update((set) => {
		const next = new Set(set);
		if (next.has(bundleId)) {
			next.delete(bundleId);
		} else {
			next.add(bundleId);
		}
		return next;
	});
}

export function toggleExpandedPorts(nodeId: string): void {
	expandedPortNodeIds.update((set) => {
		const next = new Set(set);
		if (next.has(nodeId)) {
			next.delete(nodeId);
		} else {
			next.add(nodeId);
		}
		return next;
	});
}

export function collapseAllBundles(): void {
	expandedBundles.set(new Set());
}

/** Clear all edge hover state — prevents stale hover from drag interactions */
export function clearEdgeHoverState(): void {
	edgeHoverState.set(new Map());
	groupHoverState.set(new Map());
}

interface TagFilter {
	hidden_host_tag_ids?: string[];
	hidden_service_tag_ids?: string[];
	hidden_subnet_tag_ids?: string[];
}

/**
 * Update hidden nodes/services based on tag filter and category filter settings.
 * - Hosts with hidden tags -> their Element nodes fade out
 * - Services with hidden tags -> hidden from node display (node does NOT fade)
 * - Services in hidden categories -> hidden from node display
 * - Subnets with hidden tags -> Container nodes fade out
 * - UNTAGGED_SENTINEL in hidden arrays -> hide entities with no tags
 */
export function updateTagFilter(
	topology: Topology | undefined,
	tagFilter: TagFilter | undefined,
	view?: string,
	hiddenCategories?: string[]
) {
	if (!topology) {
		tagHiddenNodeIds.set(new Set());
		tagHiddenServiceIds.set(new Set());
		return;
	}

	const hasTagFilter = tagFilter && !isTagFilterEmpty(tagFilter);
	const hasCategoryFilter = hiddenCategories && hiddenCategories.length > 0;

	if (!hasTagFilter && !hasCategoryFilter) {
		tagHiddenNodeIds.set(new Set());
		tagHiddenServiceIds.set(new Set());
		return;
	}

	// Derive filter behavior from element_config
	const meta = view
		? (views.getMetadata(view) as {
				element_config?: {
					parent_entity: string | null;
					element_entity: string;
					inline_entities: string[];
				};
			} | null)
		: null;
	const config = meta?.element_config;
	const parentEntity = config?.parent_entity ?? null;
	const elementEntity = config?.element_entity ?? 'Interface';
	const inlineEntities = config?.inline_entities ?? [];

	// Determine filter roles from element config
	const hostIsParent = parentEntity === 'Host';
	const hostIsElement = elementEntity === 'Host';
	const serviceIsElement = elementEntity === 'Service';
	const serviceIsInline = inlineEntities.includes('Service');
	const serviceIsVisible = serviceIsElement || serviceIsInline;

	const hiddenHostTagIds = tagFilter?.hidden_host_tag_ids ?? [];
	const hiddenServiceTagIds = tagFilter?.hidden_service_tag_ids ?? [];
	const hiddenSubnetTagIds = tagFilter?.hidden_subnet_tag_ids ?? [];

	const hideUntaggedHosts = hiddenHostTagIds.includes(UNTAGGED_SENTINEL);
	const hideUntaggedServices = hiddenServiceTagIds.includes(UNTAGGED_SENTINEL);
	const hideUntaggedSubnets = hiddenSubnetTagIds.includes(UNTAGGED_SENTINEL);
	const hiddenCategorySet = new Set(hiddenCategories ?? []);

	const hiddenNodeIds = new Set<string>();
	const hiddenServiceIds = new Set<string>();
	const index = buildEntityNodeIndex(topology.nodes);

	// Host filtering: hide element nodes when parent or element is Host
	if (hostIsParent || hostIsElement) {
		for (const host of topology.hosts) {
			const isUntagged = host.tags.length === 0;
			const hostHasHiddenTag = host.tags.some((t) => hiddenHostTagIds.includes(t));
			if (hostHasHiddenTag || (isUntagged && hideUntaggedHosts)) {
				const nodeIds = index.hostIdToNodes.get(host.id);
				nodeIds?.forEach((id) => hiddenNodeIds.add(id));
			}
		}
	}

	// Service filtering: behavior depends on whether Service is element vs inline
	if (serviceIsVisible) {
		for (const service of topology.services) {
			const isUntagged = service.tags.length === 0;
			const serviceHasHiddenTag = service.tags.some((t) => hiddenServiceTagIds.includes(t));
			const serviceCategory = serviceDefinitions.getCategory(service.service_definition);
			const isCategoryHidden = hiddenCategorySet.has(serviceCategory);
			if (serviceHasHiddenTag || (isUntagged && hideUntaggedServices) || isCategoryHidden) {
				hiddenServiceIds.add(service.id);
				// When Service IS the element entity, hide the node too
				if (serviceIsElement) {
					hiddenNodeIds.add(service.id);
				}
			}
		}
	}

	// Subnet filtering: hide container nodes
	if (hiddenSubnetTagIds.length > 0) {
		for (const subnet of topology.subnets) {
			const isUntagged = subnet.tags.length === 0;
			const subnetHasHiddenTag = subnet.tags.some((t) => hiddenSubnetTagIds.includes(t));
			if (subnetHasHiddenTag || (isUntagged && hideUntaggedSubnets)) {
				hiddenNodeIds.add(subnet.id);
			}
		}
	}

	tagHiddenNodeIds.set(hiddenNodeIds);
	tagHiddenServiceIds.set(hiddenServiceIds);
}

function isTagFilterEmpty(filter: {
	hidden_host_tag_ids?: string[];
	hidden_service_tag_ids?: string[];
	hidden_subnet_tag_ids?: string[];
}): boolean {
	return (
		(filter.hidden_host_tag_ids?.length ?? 0) === 0 &&
		(filter.hidden_service_tag_ids?.length ?? 0) === 0 &&
		(filter.hidden_subnet_tag_ids?.length ?? 0) === 0
	);
}

/**
 * Helper function to get all virtualized container interface IDs for a ServiceVirtualization edge
 * Returns the set of interface IDs for all containers on Docker bridge subnets
 * Uses topology data directly if provided, otherwise falls back to query cache
 */
function getVirtualizedContainerNodes(
	dockerHostInterfaceId: string,
	queryClient: QueryClient,
	topology?: Topology
): Set<string> {
	const connected = new Set<string>();

	// Try to use topology data directly (for share views where cache is empty)
	if (topology) {
		const iface = topology.interfaces.find((i) => i.id === dockerHostInterfaceId);
		if (!iface) return connected;

		const dockerHost = topology.hosts.find((h) => h.id === iface.host_id);
		if (!dockerHost) return connected;

		// Get all interfaces for this host
		const hostInterfaces = topology.interfaces.filter((i) => i.host_id === dockerHost.id);
		const hostInterfaceSubnetIds = hostInterfaces.map((i) => i.subnet_id);

		// Find container subnets
		const dockerBridgeSubnets = hostInterfaceSubnetIds
			.map((subnetId) => topology.subnets.find((s) => s.id === subnetId))
			.filter((s) => s !== undefined)
			.filter((s) => subnetTypes.getMetadata(s.subnet_type).is_for_containers);

		// Get all interfaces on those container subnets
		const interfacesOnDockerSubnets = dockerBridgeSubnets.flatMap((s) =>
			topology.interfaces.filter((i) => i.subnet_id === s.id)
		);

		for (const iface of interfacesOnDockerSubnets) {
			connected.add(iface.id);
		}

		return connected;
	}

	// Fall back to query cache
	const dockerHost = getHostFromInterfaceIdFromCache(queryClient, dockerHostInterfaceId);
	if (dockerHost) {
		// Get all interfaces for this host from the cache
		const hostInterfaces = getInterfacesForHostFromCache(queryClient, dockerHost.id);
		const hostInterfaceSubnetIds = hostInterfaces.map((i) => i.subnet_id);

		const dockerBridgeSubnets = hostInterfaceSubnetIds
			.map((s) => getSubnetByIdFromCache(queryClient, s))
			.filter((s) => s !== null)
			.filter((s) => subnetTypes.getMetadata(s.subnet_type).is_for_containers);

		const interfacesOnDockerSubnets = dockerBridgeSubnets.flatMap((s) =>
			getInterfacesForSubnetFromCache(queryClient, s.id)
		);

		for (const iface of interfacesOnDockerSubnets) {
			connected.add(iface.id);
		}
	}

	return connected;
}

/**
 * Add container highlights: when a container is in the connected set,
 * also include its element contents and subcontainers so they highlight.
 * When a container has connected elements inside it, highlight that container.
 * Uses topology data to find elements hidden by collapsed containers.
 */
function addContainerHighlights(connected: Set<string>, allNodes: Node[], topology?: Topology) {
	// First pass: use visible nodes (allNodes) for containers and their visible contents
	for (const node of allNodes) {
		const nd = node.data as TopologyNode;
		if (nd.node_type !== 'Container') continue;

		const contents = getContainerContents(nd.id, allNodes);

		if (connected.has(nd.id)) {
			// Container is connected — include its elements and subcontainers
			for (const id of contents.elementNodeIds) connected.add(id);
			for (const id of contents.subcontainerIds) connected.add(id);
		} else {
			// Check if this container has any connected elements inside it (visible)
			for (const elementId of contents.elementNodeIds) {
				if (connected.has(elementId)) {
					connected.add(nd.id);
					break;
				}
			}
		}
	}

	// Second pass: check topology data for elements hidden by collapsed containers.
	// Edge endpoints reference element IDs that may be hidden — map them to their
	// parent container so collapsed containers highlight correctly.
	if (topology) {
		for (const topoNode of topology.nodes) {
			if (topoNode.node_type !== 'Element') continue;
			if (!connected.has(topoNode.id)) continue;
			// This element is connected — ensure its container highlights
			const containerId = (topoNode as Record<string, unknown>).container_id as string | undefined;
			if (containerId && !connected.has(containerId)) {
				connected.add(containerId);
			}
		}
	}
}

/**
 * Update connected nodes when a node or edge is selected
 * @param topology - Optional topology data for direct lookups (used in share views where cache is empty)
 * @param multiSelectedNodes - Optional array of multi-selected nodes
 */
export function updateConnectedNodes(
	selectedNode: Node | null,
	selectedEdge: Edge | null,
	allEdges: Edge[],
	allNodes: Node[],
	queryClient: QueryClient,
	topology?: Topology,
	multiSelectedNodes?: Node[],
	hiddenEdgeTypes?: string[]
) {
	const connected = new Set<string>();

	// If multiple nodes are selected
	if (multiSelectedNodes && multiSelectedNodes.length >= 2) {
		const rawEdges = topology?.edges ?? [];
		const topologyNodes = topology?.nodes ?? [];
		const elevatedEdges = elevateEdgesToContainers(rawEdges, topologyNodes);
		for (const node of multiSelectedNodes) {
			connected.add(node.id);
			// Add direct neighbors of each selected node (using elevated edges)
			for (const edge of elevatedEdges) {
				if (isDisabledEdge(edge)) continue;
				const behavior = getHighlightBehavior(edge);
				if (behavior === 'never') continue;
				if (behavior === 'when_visible' && hiddenEdgeTypes?.includes(edge.edge_type)) continue;
				if (edge.source === node.id) {
					connected.add(edge.target);
				}
				if (edge.target === node.id) {
					connected.add(edge.source);
				}
			}
		}
		// Expand connected containers to include their element contents
		for (const node of allNodes) {
			const nd = node.data as TopologyNode;
			if (nd.node_type !== 'Container' || !connected.has(nd.id)) continue;
			const contents = getContainerContents(nd.id, allNodes);
			for (const id of contents.elementNodeIds) connected.add(id);
			for (const id of contents.subcontainerIds) connected.add(id);
		}
		connectedNodeIds.set(connected);
		return;
	}

	// If a node is selected
	if (selectedNode) {
		connected.add(selectedNode.id);
		const nodeData = selectedNode.data as TopologyNode;

		if (nodeData.node_type == 'Container') {
			const contents = getContainerContents(nodeData.id, allNodes);
			for (const id of contents.elementNodeIds) connected.add(id);
			for (const id of contents.subcontainerIds) connected.add(id);
		}

		// Use elevated edges so absorbing containers appear in the connected set.
		// Elevation rewrites edge endpoints from elements to their outermost
		// absorbing container, which is exactly what highlighting needs.
		const rawEdges = topology?.edges ?? [];
		const topologyNodes = topology?.nodes ?? [];
		const elevatedEdges = elevateEdgesToContainers(rawEdges, topologyNodes);

		for (const edge of elevatedEdges) {
			// Skip disabled edges entirely
			if (isDisabledEdge(edge)) continue;

			// Use highlight_behavior to decide if this edge contributes
			const behavior = getHighlightBehavior(edge);
			if (behavior === 'never') continue;
			if (behavior === 'when_visible' && hiddenEdgeTypes?.includes(edge.edge_type)) continue;

			// Add directly connected nodes
			if (edge.source === selectedNode.id) {
				connected.add(edge.target);
			}
			if (edge.target === selectedNode.id) {
				connected.add(edge.source);
			}

			// For virtualization edges, also add virtualized container nodes
			if (edge.edge_type === 'ServiceVirtualization') {
				if (edge.source === selectedNode.id || edge.target === selectedNode.id) {
					const virtualizedNodes = getVirtualizedContainerNodes(edge.source, queryClient, topology);
					virtualizedNodes.forEach((nodeId) => connected.add(nodeId));
				}
			}
		}

		addContainerHighlights(connected, allNodes, topology);

		connectedNodeIds.set(connected);
		return;
	}

	// If an edge is selected (group OR non-group)
	if (selectedEdge) {
		const edgeData = selectedEdge.data as TopologyEdge | undefined;
		if (!edgeData) {
			connectedNodeIds.set(new Set());
			return;
		}

		// Bundle edge: highlight all bundled edges' source/target nodes
		const anyData = selectedEdge.data as Record<string, unknown> | undefined;
		if (anyData?.isBundle && Array.isArray(anyData.bundleEdges)) {
			for (const bundledEdge of anyData.bundleEdges as TopologyEdge[]) {
				connected.add(bundledEdge.source as string);
				connected.add(bundledEdge.target as string);
			}
			addContainerHighlights(connected, allNodes, topology);
			connectedNodeIds.set(connected);
			return;
		}

		const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);

		// For group edges
		if (edgeTypeMetadata.is_dependency_edge && 'dependency_id' in edgeData) {
			const dependencyId = edgeData.dependency_id as string;

			// Find all edges in this dependency and add their connected nodes
			for (const edge of allEdges) {
				const eData = edge.data as TopologyEdge | undefined;
				if (!eData) continue;
				const eMetadata = edgeTypes.getMetadata(eData.edge_type);

				if (
					eMetadata.is_dependency_edge &&
					'dependency_id' in eData &&
					eData.dependency_id === dependencyId
				) {
					connected.add(eData.source as string);
					connected.add(eData.target as string);
				}
			}
		} else if (edgeData.edge_type === 'ServiceVirtualization') {
			// For ServiceVirtualization edges, add source, target, and all virtualized containers
			connected.add(edgeData.source as string);
			connected.add(edgeData.target as string);

			// Add all virtualized container nodes
			const virtualizedNodes = getVirtualizedContainerNodes(
				edgeData.source as string,
				queryClient,
				topology
			);
			virtualizedNodes.forEach((nodeId) => connected.add(nodeId));
		} else if (edgeData.edge_type === 'HostVirtualization') {
			// For HostVirtualization edges, add source and target
			connected.add(edgeData.source as string);
			connected.add(edgeData.target as string);
		} else {
			// For other non-group edges, just add source and target
			connected.add(edgeData.source as string);
			connected.add(edgeData.target as string);
		}

		addContainerHighlights(connected, allNodes, topology);
		connectedNodeIds.set(connected);
		return;
	}

	// Nothing selected - clear
	connectedNodeIds.set(new Set());
}

/**
 * Set edge hover state explicitly — avoids toggle desync when enter/leave events fire asymmetrically
 */
export function setEdgeHover(edge: Edge, hovered: boolean, allEdges: Edge[]) {
	const edgeData = edge.data as TopologyEdge | undefined;
	if (!edgeData) return;
	const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);

	// Set individual edge hover state
	edgeHoverState.update((state) => {
		const newState = new Map(state);
		newState.set(edge.id, hovered);
		return newState;
	});

	// For group edges, update group hover state
	if (edgeTypeMetadata.is_dependency_edge && 'dependency_id' in edgeData) {
		const dependencyId = edgeData.dependency_id as string;

		groupHoverState.update((state) => {
			const newState = new Map(state);

			// Get the UPDATED edge hover states (after we just toggled this edge)
			const updatedEdgeStates = get(edgeHoverState);
			let anyEdgeInGroupHovered = false;

			// Check if ANY edge in this dependency is hovered
			for (const e of allEdges) {
				const eData = e.data as TopologyEdge | undefined;
				if (!eData) continue;
				const eMetadata = edgeTypes.getMetadata(eData.edge_type);
				if (
					eMetadata.is_dependency_edge &&
					'dependency_id' in eData &&
					eData.dependency_id === dependencyId
				) {
					const eIsHovered = updatedEdgeStates.get(e.id) || false;
					if (eIsHovered) {
						anyEdgeInGroupHovered = true;
						break;
					}
				}
			}

			newState.set(dependencyId, anyEdgeInGroupHovered);
			return newState;
		});
	}
}

export interface EdgeDisplayState {
	shouldShowFull: boolean;
	shouldAnimate: boolean;
	isEndpointSearchHidden: boolean;
	isEndpointTagHidden: boolean;
}

/**
 * Get display state for an edge based on hover, selection, search, and tag filters.
 * Single source of truth for edge visual state computation.
 */
export function getEdgeDisplayState(
	edge: Edge,
	selectedNode: Node | null,
	selectedEdge: Edge | null,
	searchHidden?: Set<string>,
	tagHidden?: Set<string>
): EdgeDisplayState {
	const edgeData = edge.data as TopologyEdge | undefined;
	if (!edgeData) {
		return {
			shouldShowFull: false,
			shouldAnimate: false,
			isEndpointSearchHidden: false,
			isEndpointTagHidden: false
		};
	}

	const source = edgeData.source as string;
	const target = edgeData.target as string;

	// Centralized endpoint-hidden checks
	const isEndpointSearchHidden = searchHidden
		? searchHidden.has(source) || searchHidden.has(target)
		: false;
	const isEndpointTagHidden = tagHidden ? tagHidden.has(source) || tagHidden.has(target) : false;

	const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);
	const isGroupEdge = edgeTypeMetadata.is_dependency_edge;

	let shouldShowFull: boolean;
	let shouldAnimate: boolean;

	// Check if this edge is hovered
	const isThisEdgeHovered = get(edgeHoverState).get(edge.id) || false;

	// Check if this edge is selected
	const isThisEdgeSelected = selectedEdge?.id === edge.id;

	// For group edges, check group hover/selection state
	if (isGroupEdge && 'dependency_id' in edgeData) {
		const dependencyId = edgeData.dependency_id as string;
		const isGroupHovered = get(groupHoverState).get(dependencyId) || false;

		// Check if any edge in this group is selected
		let isGroupSelected = false;
		if (selectedEdge) {
			const selectedEdgeData = selectedEdge.data as TopologyEdge | undefined;
			if (selectedEdgeData) {
				const selectedMetadata = edgeTypes.getMetadata(selectedEdgeData.edge_type);
				if (selectedMetadata.is_dependency_edge && 'dependency_id' in selectedEdgeData) {
					isGroupSelected = selectedEdgeData.dependency_id === dependencyId;
				}
			}
		}

		// Check if connected node is selected
		const isConnectedNodeSelected =
			selectedNode && (edgeData.source === selectedNode.id || edgeData.target === selectedNode.id);

		// Should show full if: group hovered, group selected, or connected node selected
		shouldShowFull = isGroupHovered || isGroupSelected || !!isConnectedNodeSelected;

		// Animate only if view config enables directionality
		shouldAnimate = showDirectionality(edgeData)
			? isGroupHovered || isGroupSelected || !!isConnectedNodeSelected
			: false;
	} else {
		// Non-group edges: show full if hovered, selected, or connected node selected
		const isConnectedNodeSelected =
			selectedNode && (edgeData.source === selectedNode.id || edgeData.target === selectedNode.id);

		shouldShowFull = isThisEdgeHovered || isThisEdgeSelected || !!isConnectedNodeSelected;

		// Animate only if view config enables directionality
		shouldAnimate = showDirectionality(edgeData)
			? isThisEdgeHovered || isThisEdgeSelected || !!isConnectedNodeSelected
			: false;
	}

	return { shouldShowFull, shouldAnimate, isEndpointSearchHidden, isEndpointTagHidden };
}

/** Add all node IDs from an index map entry to matchSet (deduplicating) */
function addIndexedNodes(indexMap: Map<string, string[]>, entityId: string, matchSet: Set<string>) {
	const nodeIds = indexMap.get(entityId);
	if (nodeIds) nodeIds.forEach((id) => matchSet.add(id));
}

/**
 * Update search filter: find nodes matching query, set non-matching nodes to fade.
 * Uses buildEntityNodeIndex for view-agnostic entity→node resolution.
 * Searches hosts (name/hostname), interfaces (ip_address/name), services (name),
 * subnets (name/cidr), and tags (name matched to entities).
 */
export function updateSearchFilter(topology: Topology | undefined, query: string) {
	if (!topology || !query.trim()) {
		searchHiddenNodeIds.set(new Set());
		searchMatchNodeIds.set([]);
		searchActiveIndex.set(0);
		return;
	}

	const q = query.toLowerCase().trim();
	const index = buildEntityNodeIndex(topology.nodes);
	const matchingSet = new Set<string>();

	// allNodeIds = all element nodes + container nodes (for subnet/container search)
	const allNodeIds = new Set<string>([...index.allElementNodeIds, ...index.allContainerNodeIds]);

	// Search hosts -> match element nodes via hostIdToNodes
	for (const host of topology.hosts) {
		const nameMatch = host.name.toLowerCase().includes(q);
		const hostnameMatch = host.hostname?.toLowerCase().includes(q) ?? false;
		if (nameMatch || hostnameMatch) {
			addIndexedNodes(index.hostIdToNodes, host.id, matchingSet);
		}
	}

	// Search interfaces -> match element nodes via interfaceIdToNodes
	for (const iface of topology.interfaces) {
		const ipMatch = iface.ip_address?.toLowerCase().includes(q) ?? false;
		const nameMatch = iface.name?.toLowerCase().includes(q) ?? false;
		if (ipMatch || nameMatch) {
			addIndexedNodes(index.interfaceIdToNodes, iface.id, matchingSet);
		}
	}

	// Search services -> match via serviceIdToNodes + hostIdToNodes fallback
	for (const service of topology.services) {
		if (service.name.toLowerCase().includes(q)) {
			addIndexedNodes(index.serviceIdToNodes, service.id, matchingSet);
			if (service.host_id) {
				addIndexedNodes(index.hostIdToNodes, service.host_id, matchingSet);
			}
		}
	}

	// Search subnets -> match container nodes directly (subnet.id IS container node.id)
	for (const subnet of topology.subnets) {
		const nameMatch = subnet.name.toLowerCase().includes(q);
		const cidrMatch = subnet.cidr.toLowerCase().includes(q);
		if (nameMatch || cidrMatch) {
			matchingSet.add(subnet.id);
		}
	}

	// Search tags -> match entities with matching tag names
	const entityTags = topology.entity_tags ?? [];
	for (const host of topology.hosts) {
		for (const tagId of host.tags) {
			const tag = entityTags.find((t) => t.id === tagId);
			if (tag && tag.name.toLowerCase().includes(q)) {
				addIndexedNodes(index.hostIdToNodes, host.id, matchingSet);
				break;
			}
		}
	}

	for (const service of topology.services) {
		for (const tagId of service.tags) {
			const tag = entityTags.find((t) => t.id === tagId);
			if (tag && tag.name.toLowerCase().includes(q)) {
				addIndexedNodes(index.serviceIdToNodes, service.id, matchingSet);
				if (service.host_id) {
					addIndexedNodes(index.hostIdToNodes, service.host_id, matchingSet);
				}
				break;
			}
		}
	}

	for (const subnet of topology.subnets) {
		for (const tagId of subnet.tags) {
			const tag = entityTags.find((t) => t.id === tagId);
			if (tag && tag.name.toLowerCase().includes(q)) {
				matchingSet.add(subnet.id);
				break;
			}
		}
	}

	// Hidden = all nodes NOT in the matching set
	const hiddenIds = new Set<string>();
	for (const nodeId of allNodeIds) {
		if (!matchingSet.has(nodeId)) {
			hiddenIds.add(nodeId);
		}
	}

	searchHiddenNodeIds.set(hiddenIds);
	searchMatchNodeIds.set([...matchingSet]);
	searchActiveIndex.set(0);
}

/**
 * Clear all search state.
 */
export function clearSearch() {
	searchHiddenNodeIds.set(new Set());
	searchMatchNodeIds.set([]);
	searchActiveIndex.set(0);
	searchOpen.set(false);
}
