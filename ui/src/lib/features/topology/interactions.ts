import { writable, get } from 'svelte/store';
import type { Edge } from '@xyflow/svelte';
import type { Node } from '@xyflow/svelte';
import type { QueryClient } from '@tanstack/svelte-query';
import {
	edgeTypes,
	perspectives,
	serviceDefinitions,
	subnetTypes
} from '$lib/shared/stores/metadata';
import type { TopologyEdge, TopologyNode, Topology } from './types/base';
import { classifyEdge } from './layout/edge-classification';
import { getContainerContents } from './resolvers';
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
	perspective?: string,
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

	const meta = perspective
		? (perspectives.getMetadata(perspective) as {
				tag_filter_categories?: string[];
				services_are_elements?: boolean;
			} | null)
		: null;
	const categories = meta?.tag_filter_categories ?? ['host', 'service', 'subnet'];
	const servicesAreElements = meta?.services_are_elements ?? false;

	const hiddenHostTagIds = tagFilter?.hidden_host_tag_ids ?? [];
	const hiddenServiceTagIds = tagFilter?.hidden_service_tag_ids ?? [];
	const hiddenSubnetTagIds = tagFilter?.hidden_subnet_tag_ids ?? [];

	const hideUntaggedHosts = hiddenHostTagIds.includes(UNTAGGED_SENTINEL);
	const hideUntaggedServices = hiddenServiceTagIds.includes(UNTAGGED_SENTINEL);
	const hideUntaggedSubnets = hiddenSubnetTagIds.includes(UNTAGGED_SENTINEL);
	const hiddenCategorySet = new Set(hiddenCategories ?? []);

	const hiddenNodeIds = new Set<string>();
	const hiddenServiceIds = new Set<string>();

	// Host tags -> fade Element nodes (only if host filtering applies to this perspective)
	if (categories.includes('host')) {
		for (const host of topology.hosts) {
			const isUntagged = host.tags.length === 0;
			const hostHasHiddenTag = host.tags.some((t) => hiddenHostTagIds.includes(t));
			if (hostHasHiddenTag || (isUntagged && hideUntaggedHosts)) {
				const hostInterfaces = topology.interfaces.filter((i) => i.host_id === host.id);
				hostInterfaces.forEach((i) => hiddenNodeIds.add(i.id));
			}
		}
	}

	// Service tags + category filter -> hide services from display
	if (categories.includes('service')) {
		for (const service of topology.services) {
			const isUntagged = service.tags.length === 0;
			const serviceHasHiddenTag = service.tags.some((t) => hiddenServiceTagIds.includes(t));
			const serviceCategory = serviceDefinitions.getCategory(service.service_definition);
			const isCategoryHidden = hiddenCategorySet.has(serviceCategory);
			if (serviceHasHiddenTag || (isUntagged && hideUntaggedServices) || isCategoryHidden) {
				hiddenServiceIds.add(service.id);
				// When services are element nodes, hide the node too
				if (servicesAreElements) {
					hiddenNodeIds.add(service.id);
				}
			}
		}
	}

	// Subnet tags -> fade Container nodes (only if subnet filtering applies)
	if (categories.includes('subnet')) {
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
		const topologyEdges = topology?.edges ?? [];
		for (const node of multiSelectedNodes) {
			connected.add(node.id);
			// Add direct neighbors of each selected node
			for (const edge of topologyEdges) {
				if (edge.source === node.id) {
					connected.add(edge.target);
				}
				if (edge.target === node.id) {
					connected.add(edge.source);
				}
			}
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

		// Use topology edges (stable source of truth) rather than xyflow edges
		// store, which may be empty during re-layout triggered by collapseAllBundles.
		const topologyEdges = topology?.edges ?? [];

		for (const edge of topologyEdges) {
			// Skip edges that are disabled (perspective-level) or hidden (user toggle)
			if (classifyEdge(edge) === 'disabled') continue;
			if (hiddenEdgeTypes?.includes(edge.edge_type)) continue;

			// Add directly connected nodes
			if (edge.source === selectedNode.id) {
				connected.add(edge.target);
			}
			if (edge.target === selectedNode.id) {
				connected.add(edge.source);
			}

			// For visible virtualization edges, also add virtualized container nodes
			if (edge.edge_type === 'ServiceVirtualization') {
				if (edge.source === selectedNode.id || edge.target === selectedNode.id) {
					const virtualizedNodes = getVirtualizedContainerNodes(edge.source, queryClient, topology);
					virtualizedNodes.forEach((nodeId) => connected.add(nodeId));
				}
			}
		}

		// Add subcontainers that contain at least one connected element node
		for (const node of allNodes) {
			const nd = node.data as TopologyNode;
			if (nd.node_type !== 'Container') continue;
			const parentContainerId = (nd as Record<string, unknown>).parent_container_id as
				| string
				| undefined;
			if (!parentContainerId) continue; // not a subcontainer

			const contents = getContainerContents(nd.id, allNodes);
			for (const elementId of contents.elementNodeIds) {
				if (connected.has(elementId)) {
					connected.add(nd.id);
					break;
				}
			}
		}

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
			connectedNodeIds.set(connected);
			return;
		}

		const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);

		// For group edges
		if (edgeTypeMetadata.is_group_edge && 'group_id' in edgeData) {
			const groupId = edgeData.group_id as string;

			// Find all edges in this group and add their connected nodes
			for (const edge of allEdges) {
				const eData = edge.data as TopologyEdge | undefined;
				if (!eData) continue;
				const eMetadata = edgeTypes.getMetadata(eData.edge_type);

				if (eMetadata.is_group_edge && 'group_id' in eData && eData.group_id === groupId) {
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

		connectedNodeIds.set(connected);
		return;
	}

	// Nothing selected - clear
	connectedNodeIds.set(new Set());
}

/**
 * Toggle edge hover state - updates both individual edge and group hover states
 */
export function toggleEdgeHover(edge: Edge, allEdges: Edge[]) {
	const edgeData = edge.data as TopologyEdge | undefined;
	if (!edgeData) return;
	const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);

	// Toggle individual edge hover state
	edgeHoverState.update((state) => {
		const currentHoverState = state.get(edge.id) || false;
		const newState = new Map(state);
		newState.set(edge.id, !currentHoverState);
		return newState;
	});

	// For group edges, update group hover state
	if (edgeTypeMetadata.is_group_edge && 'group_id' in edgeData) {
		const groupId = edgeData.group_id as string;

		groupHoverState.update((state) => {
			const newState = new Map(state);

			// Get the UPDATED edge hover states (after we just toggled this edge)
			const updatedEdgeStates = get(edgeHoverState);
			let anyEdgeInGroupHovered = false;

			// Check if ANY edge in this group is hovered
			for (const e of allEdges) {
				const eData = e.data as TopologyEdge | undefined;
				if (!eData) continue;
				const eMetadata = edgeTypes.getMetadata(eData.edge_type);
				if (eMetadata.is_group_edge && 'group_id' in eData && eData.group_id === groupId) {
					const eIsHovered = updatedEdgeStates.get(e.id) || false;
					if (eIsHovered) {
						anyEdgeInGroupHovered = true;
						break;
					}
				}
			}

			newState.set(groupId, anyEdgeInGroupHovered);
			return newState;
		});
	}
}

/**
 * Get display state for an edge based on hover and selection
 * Returns: { shouldShowFull, shouldAnimate }
 */
export function getEdgeDisplayState(
	edge: Edge,
	selectedNode: Node | null,
	selectedEdge: Edge | null
): { shouldShowFull: boolean; shouldAnimate: boolean } {
	const edgeData = edge.data as TopologyEdge | undefined;
	if (!edgeData) {
		return { shouldShowFull: false, shouldAnimate: false };
	}
	const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);
	const isGroupEdge = edgeTypeMetadata.is_group_edge;

	let shouldShowFull: boolean;
	let shouldAnimate: boolean;

	// Check if this edge is hovered
	const isThisEdgeHovered = get(edgeHoverState).get(edge.id) || false;

	// Check if this edge is selected
	const isThisEdgeSelected = selectedEdge?.id === edge.id;

	// For group edges, check group hover/selection state
	if (isGroupEdge && 'group_id' in edgeData) {
		const groupId = edgeData.group_id as string;
		const isGroupHovered = get(groupHoverState).get(groupId) || false;

		// Check if any edge in this group is selected
		let isGroupSelected = false;
		if (selectedEdge) {
			const selectedEdgeData = selectedEdge.data as TopologyEdge | undefined;
			if (selectedEdgeData) {
				const selectedMetadata = edgeTypes.getMetadata(selectedEdgeData.edge_type);
				if (selectedMetadata.is_group_edge && 'group_id' in selectedEdgeData) {
					isGroupSelected = selectedEdgeData.group_id === groupId;
				}
			}
		}

		// Check if connected node is selected
		const isConnectedNodeSelected =
			selectedNode && (edgeData.source === selectedNode.id || edgeData.target === selectedNode.id);

		// Should show full if: group hovered, group selected, or connected node selected
		shouldShowFull = isGroupHovered || isGroupSelected || !!isConnectedNodeSelected;

		// Should animate if: group hovered, group selected, or connected node selected
		shouldAnimate = isGroupHovered || isGroupSelected || !!isConnectedNodeSelected;
	} else {
		// Non-group edges: show full if hovered, selected, or connected node selected
		const isConnectedNodeSelected =
			selectedNode && (edgeData.source === selectedNode.id || edgeData.target === selectedNode.id);

		shouldShowFull = isThisEdgeHovered || isThisEdgeSelected || !!isConnectedNodeSelected;
		shouldAnimate = false; // Non-group edges don't animate
	}

	return { shouldShowFull, shouldAnimate };
}

/**
 * Add interface nodes for a service based on its bindings.
 * If binding.interface_id is set, add that interface.
 * If binding.interface_id is null (all-interfaces binding), add all host interfaces.
 */
function addBoundInterfaces(
	topology: Topology,
	service: Topology['services'][number],
	matchingNodeIds: string[]
) {
	const getNonContainerHostInterfaces = () =>
		topology.interfaces.filter((i) => {
			if (i.host_id !== service.host_id) return false;
			const subnet = topology.subnets.find((s) => s.id === i.subnet_id);
			if (!subnet) return true;
			return !subnetTypes.getMetadata(subnet.subnet_type).is_for_containers;
		});

	for (const binding of service.bindings) {
		if (binding.interface_id) {
			if (!matchingNodeIds.includes(binding.interface_id)) {
				matchingNodeIds.push(binding.interface_id);
			}
		} else {
			// null interface_id = bound to all host interfaces (exclude container subnets)
			getNonContainerHostInterfaces().forEach((i) => {
				if (!matchingNodeIds.includes(i.id)) matchingNodeIds.push(i.id);
			});
		}
	}
	// If service has no bindings, fall back to all host interfaces (exclude container subnets)
	if (service.bindings.length === 0) {
		getNonContainerHostInterfaces().forEach((i) => {
			if (!matchingNodeIds.includes(i.id)) matchingNodeIds.push(i.id);
		});
	}
}

/**
 * Update search filter: find nodes matching query, set non-matching nodes to fade.
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
	const matchingNodeIds: string[] = [];
	const allNodeIds = new Set<string>();

	// Collect all node IDs (interfaces + subnets)
	for (const iface of topology.interfaces) {
		allNodeIds.add(iface.id);
	}
	for (const subnet of topology.subnets) {
		allNodeIds.add(subnet.id);
	}

	// Search hosts -> match their interface nodes
	for (const host of topology.hosts) {
		const nameMatch = host.name.toLowerCase().includes(q);
		const hostnameMatch = host.hostname?.toLowerCase().includes(q) ?? false;
		if (nameMatch || hostnameMatch) {
			const hostInterfaces = topology.interfaces.filter((i) => {
				if (i.host_id !== host.id) return false;
				const subnet = topology.subnets.find((s) => s.id === i.subnet_id);
				if (!subnet) return true;
				return !subnetTypes.getMetadata(subnet.subnet_type).is_for_containers;
			});
			hostInterfaces.forEach((i) => {
				if (!matchingNodeIds.includes(i.id)) matchingNodeIds.push(i.id);
			});
		}
	}

	// Search interfaces -> match by ip_address or name
	for (const iface of topology.interfaces) {
		const ipMatch = iface.ip_address?.toLowerCase().includes(q) ?? false;
		const nameMatch = iface.name?.toLowerCase().includes(q) ?? false;
		if (ipMatch || nameMatch) {
			if (!matchingNodeIds.includes(iface.id)) matchingNodeIds.push(iface.id);
		}
	}

	// Search services -> match bound interface nodes (binding-aware)
	for (const service of topology.services) {
		if (service.name.toLowerCase().includes(q)) {
			addBoundInterfaces(topology, service, matchingNodeIds);
		}
	}

	// Search subnets -> match subnet nodes
	for (const subnet of topology.subnets) {
		const nameMatch = subnet.name.toLowerCase().includes(q);
		const cidrMatch = subnet.cidr.toLowerCase().includes(q);
		if (nameMatch || cidrMatch) {
			if (!matchingNodeIds.includes(subnet.id)) matchingNodeIds.push(subnet.id);
		}
	}

	// Search tags -> match entities with matching tag names
	const entityTags = topology.entity_tags ?? [];
	for (const host of topology.hosts) {
		for (const tagId of host.tags) {
			const tag = entityTags.find((t) => t.id === tagId);
			if (tag && tag.name.toLowerCase().includes(q)) {
				const hostInterfaces = topology.interfaces.filter((i) => {
					if (i.host_id !== host.id) return false;
					const subnet = topology.subnets.find((s) => s.id === i.subnet_id);
					if (!subnet) return true;
					return !subnetTypes.getMetadata(subnet.subnet_type).is_for_containers;
				});
				hostInterfaces.forEach((i) => {
					if (!matchingNodeIds.includes(i.id)) matchingNodeIds.push(i.id);
				});
				break;
			}
		}
	}

	// Service tag search -> match bound interfaces (binding-aware)
	for (const service of topology.services) {
		for (const tagId of service.tags) {
			const tag = entityTags.find((t) => t.id === tagId);
			if (tag && tag.name.toLowerCase().includes(q)) {
				addBoundInterfaces(topology, service, matchingNodeIds);
				break;
			}
		}
	}

	for (const subnet of topology.subnets) {
		for (const tagId of subnet.tags) {
			const tag = entityTags.find((t) => t.id === tagId);
			if (tag && tag.name.toLowerCase().includes(q)) {
				if (!matchingNodeIds.includes(subnet.id)) matchingNodeIds.push(subnet.id);
				break;
			}
		}
	}

	// Hidden = all nodes NOT in the matching set
	const hiddenIds = new Set<string>();
	for (const nodeId of allNodeIds) {
		if (!matchingNodeIds.includes(nodeId)) {
			hiddenIds.add(nodeId);
		}
	}

	searchHiddenNodeIds.set(hiddenIds);
	searchMatchNodeIds.set(matchingNodeIds);
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
