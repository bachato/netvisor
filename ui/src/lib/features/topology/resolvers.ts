import type { components } from '$lib/api/schema';
import type { Topology, TopologyNode } from './types/base';

type ElementEntityType = components['schemas']['ElementEntityType'];

// Resolver return types
export interface ElementRenderContext {
	elementType: ElementEntityType;
	host: Topology['hosts'][number] | undefined;
	iface: Topology['interfaces'][number] | undefined;
	services: Topology['services'][number][];
	hostId: string | undefined;
	ipAddressId: string | undefined;
	subnetId: string;
	isInfra: boolean;
}

export interface ContainerRenderContext {
	subnet: Topology['subnets'][number] | undefined;
	title: string | null;
	containerType: string;
}

// Exhaustive resolver maps — TypeScript errors if a variant is missing
const elementResolvers: Record<
	ElementEntityType,
	(nodeId: string, node: TopologyNode, topology: Topology) => ElementRenderContext
> = {
	IPAddress: (_nodeId, node, topology) => {
		const hostId = 'host_id' in node ? (node.host_id as string) : undefined;
		const ipAddressId =
			'ip_address_id' in node ? (node.ip_address_id as string | undefined) : undefined;
		const subnetId = 'subnet_id' in node ? (node.subnet_id as string) : '';
		const isInfra = 'is_infra' in node ? (node.is_infra as boolean) : false;

		const host = topology.hosts.find((h) => h.id === hostId);
		const iface = ipAddressId ? topology.ip_addresses.find((i) => i.id === ipAddressId) : undefined;
		const services = topology.services.filter(
			(s) =>
				s.host_id === hostId &&
				s.bindings.some((b) => b.ip_address_id === ipAddressId || b.ip_address_id === null)
		);

		return {
			elementType: 'IPAddress',
			host,
			iface,
			services,
			hostId,
			ipAddressId: ipAddressId,
			subnetId,
			isInfra
		};
	},
	Service: (nodeId, node, topology) => {
		const hostId = 'host_id' in node ? (node.host_id as string) : undefined;
		const host = topology.hosts.find((h) => h.id === hostId);
		const service = topology.services.find((s) => s.id === nodeId);
		const services = service ? [service] : [];

		return {
			elementType: 'Service' as ElementEntityType,
			host,
			iface: undefined,
			services,
			hostId,
			ipAddressId: undefined,
			subnetId: '',
			isInfra: false
		};
	},
	Host: (_nodeId, node, topology) => {
		const hostId = 'host_id' in node ? (node.host_id as string) : undefined;
		const host = topology.hosts.find((h) => h.id === hostId);
		const services = topology.services.filter((s) => s.host_id === hostId);

		return {
			elementType: 'Host' as ElementEntityType,
			host,
			iface: undefined,
			services,
			hostId,
			ipAddressId: undefined,
			subnetId: '',
			isInfra: false
		};
	},
	Interface: (_nodeId, node, topology) => {
		const hostId = 'host_id' in node ? (node.host_id as string) : undefined;
		const interfaceId = 'interface_id' in node ? (node.interface_id as string) : undefined;
		const host = topology.hosts.find((h) => h.id === hostId);
		const iface = interfaceId ? topology.interfaces.find((e) => e.id === interfaceId) : undefined;
		return {
			elementType: 'Interface' as ElementEntityType,
			host,
			iface,
			services: [],
			hostId,
			ipAddressId: interfaceId,
			subnetId: '',
			isInfra: false
		};
	}
};

// TODO(views): This resolver returns a subnet entity for tag hover support.
// When containers represent other entity types (hosts, services, hypervisors),
// this must be refactored to return tags generically from whatever entity
// the container represents, not specifically a subnet.
function resolveContainer(
	nodeId: string,
	node: TopologyNode,
	topology: Topology
): ContainerRenderContext {
	const containerType = 'container_type' in node ? (node.container_type as string) : 'Subnet';
	const title = 'header' in node ? (node.header as string | null) : null;

	// Only Subnet containers have a subnet entity to look up
	if (containerType === 'Subnet') {
		const subnet = topology.subnets.find((s) => s.id === nodeId);
		return { subnet, title, containerType };
	}

	return { subnet: undefined, title, containerType };
}

// Selection context for multi-select operations
export interface NodeSelectionIds {
	hostIds: string[];
	serviceIds: string[];
}

/**
 * Get the host and service IDs represented by an element node.
 * Handles both Interface nodes (services bound to the interface) and
 * Service nodes (the service itself) uniformly.
 */
export function getNodeSelectionIds(
	nodeId: string,
	node: TopologyNode,
	topology: Topology
): NodeSelectionIds {
	const resolved = resolveElementNode(nodeId, node, topology);
	const hostIds = resolved.hostId ? [resolved.hostId] : [];

	if (resolved.elementType === 'Service') {
		return { hostIds, serviceIds: resolved.services.map((s) => s.id) };
	}
	if (resolved.elementType === 'Host') {
		return { hostIds, serviceIds: resolved.services.map((s) => s.id) };
	}
	// Interface node: services bound to this specific interface on this host
	const serviceIds = topology.services
		.filter(
			(s) =>
				s.host_id &&
				hostIds.includes(s.host_id) &&
				s.bindings.some((b) => b.ip_address_id === resolved.ipAddressId || b.ip_address_id === null)
		)
		.map((s) => s.id);
	return { hostIds, serviceIds };
}

// Container contents — shared utility for fading, hiding, counting
export interface ContainerContents {
	hostIds: Set<string>;
	serviceIds: Set<string>;
	ipAddressIds: Set<string>;
	elementNodeIds: Set<string>;
	subcontainerIds: Set<string>;
}

/**
 * Walk topology nodes and return all entities inside a container,
 * including entities in nested subcontainers. Works generically across
 * views — uses container_id/subnet_id for elements and
 * parent_container_id for subcontainers.
 */
export function getContainerContents(
	containerId: string,
	topologyNodes: TopologyNode[]
): ContainerContents {
	const hostIds = new Set<string>();
	const serviceIds = new Set<string>();
	const ipAddressIds = new Set<string>();
	const elementNodeIds = new Set<string>();
	const subcontainerIds = new Set<string>();

	// Collect subcontainer IDs (direct children of this container)
	for (const nd of topologyNodes) {
		if (nd.node_type === 'Container') {
			const parentContainerId = (nd as Record<string, unknown>).parent_container_id as
				| string
				| undefined;
			if (parentContainerId === containerId) {
				subcontainerIds.add(nd.id);
			}
		}
	}

	// Collect element nodes whose parent is this container or a subcontainer
	const containerSet = new Set([containerId, ...subcontainerIds]);
	for (const nd of topologyNodes) {
		if (nd.node_type !== 'Element') continue;

		const parentId =
			((nd as Record<string, unknown>).container_id as string | undefined) ??
			((nd as Record<string, unknown>).subnet_id as string | undefined);
		if (!parentId || !containerSet.has(parentId)) continue;

		elementNodeIds.add(nd.id);

		const hostId = (nd as Record<string, unknown>).host_id as string | undefined;
		if (hostId) hostIds.add(hostId);

		if (nd.element_type === 'Service') {
			serviceIds.add(nd.id);
		} else if (nd.element_type === 'Interface') {
			const ifaceId = (nd as Record<string, unknown>).interface_id as string | undefined;
			if (ifaceId) ipAddressIds.add(ifaceId);
		} else if (nd.element_type === 'Host') {
			// Host elements: no additional IDs needed beyond hostId (already added above)
		} else if (nd.element_type === 'Port') {
			// Port elements: no additional IDs needed beyond hostId
		}
	}

	return { hostIds, serviceIds, ipAddressIds, elementNodeIds, subcontainerIds };
}

// Entity→Node index — canonical resolver for mapping entity IDs to topology node IDs
export interface EntityNodeIndex {
	hostIdToNodes: Map<string, string[]>;
	hostIdToContainerIds: Map<string, Set<string>>;
	ipAddressIdToNodes: Map<string, string[]>;
	serviceIdToNodes: Map<string, string[]>;
	ifEntryIdToNodes: Map<string, string[]>;
	allElementNodeIds: Set<string>;
	allContainerNodeIds: Set<string>;
}

/**
 * Build an index mapping entity IDs to the topology node IDs that represent them.
 * Single pass over topology.nodes. Use this instead of ad-hoc entity→node lookups.
 */
export function buildEntityNodeIndex(nodes: TopologyNode[]): EntityNodeIndex {
	const hostIdToNodes = new Map<string, string[]>();
	const hostIdToContainerIds = new Map<string, Set<string>>();
	const ipAddressIdToNodes = new Map<string, string[]>();
	const serviceIdToNodes = new Map<string, string[]>();
	const ifEntryIdToNodes = new Map<string, string[]>();
	const allElementNodeIds = new Set<string>();
	const allContainerNodeIds = new Set<string>();

	for (const nd of nodes) {
		if (nd.node_type === 'Container') {
			allContainerNodeIds.add(nd.id);
			continue;
		}
		if (nd.node_type !== 'Element') continue;

		allElementNodeIds.add(nd.id);

		const hostId = 'host_id' in nd ? (nd.host_id as string | undefined) : undefined;
		if (hostId) {
			const existing = hostIdToNodes.get(hostId);
			if (existing) existing.push(nd.id);
			else hostIdToNodes.set(hostId, [nd.id]);

			// Map host → container(s) for views where Host is the container
			const containerId =
				'container_id' in nd ? (nd.container_id as string | undefined) : undefined;
			if (containerId) {
				const containerSet = hostIdToContainerIds.get(hostId);
				if (containerSet) containerSet.add(containerId);
				else hostIdToContainerIds.set(hostId, new Set([containerId]));
			}
		}

		if (nd.element_type === 'Interface') {
			const ifaceId = 'interface_id' in nd ? (nd.interface_id as string | undefined) : undefined;
			if (ifaceId) {
				const existing = ipAddressIdToNodes.get(ifaceId);
				if (existing) existing.push(nd.id);
				else ipAddressIdToNodes.set(ifaceId, [nd.id]);
			}
		} else if (nd.element_type === 'Service') {
			const existing = serviceIdToNodes.get(nd.id);
			if (existing) existing.push(nd.id);
			else serviceIdToNodes.set(nd.id, [nd.id]);
		} else if (nd.element_type === 'Port') {
			const ifEntryId = 'interface_id' in nd ? (nd.interface_id as string | undefined) : undefined;
			if (ifEntryId) {
				const existing = ifEntryIdToNodes.get(ifEntryId);
				if (existing) existing.push(nd.id);
				else ifEntryIdToNodes.set(ifEntryId, [nd.id]);
			}
		}
	}

	return {
		hostIdToNodes,
		hostIdToContainerIds,
		ipAddressIdToNodes,
		serviceIdToNodes,
		ifEntryIdToNodes,
		allElementNodeIds,
		allContainerNodeIds
	};
}

// Public API
export function resolveElementNode(
	nodeId: string,
	node: TopologyNode,
	topology: Topology
): ElementRenderContext {
	if (node.node_type !== 'Element') throw new Error(`Expected Element, got ${node.node_type}`);
	const elementType = node.element_type;
	if (!elementType || !(elementType in elementResolvers)) {
		console.warn(`[resolveElementNode] Unknown element_type: ${elementType} for node ${nodeId}`);
		return {
			elementType: elementType ?? ('Unknown' as ElementEntityType),
			host: undefined,
			iface: undefined,
			services: [],
			hostId: undefined,
			interfaceId: undefined,
			subnetId: '',
			isInfra: false
		};
	}
	return elementResolvers[elementType](nodeId, node, topology);
}

export function resolveContainerNode(
	nodeId: string,
	node: TopologyNode,
	topology: Topology
): ContainerRenderContext {
	if (node.node_type !== 'Container') throw new Error(`Expected Container, got ${node.node_type}`);
	return resolveContainer(nodeId, node, topology);
}
