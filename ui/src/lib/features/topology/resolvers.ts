import type { Node } from '@xyflow/svelte';
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
	interfaceId: string | undefined;
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
	Interface: (_nodeId, node, topology) => {
		const hostId = 'host_id' in node ? (node.host_id as string) : undefined;
		const interfaceId =
			'interface_id' in node ? (node.interface_id as string | undefined) : undefined;
		const subnetId = 'subnet_id' in node ? (node.subnet_id as string) : '';
		const isInfra = 'is_infra' in node ? (node.is_infra as boolean) : false;

		const host = topology.hosts.find((h) => h.id === hostId);
		const iface = interfaceId ? topology.interfaces.find((i) => i.id === interfaceId) : undefined;
		const services = topology.services.filter((s) => s.host_id === hostId);

		return {
			elementType: 'Interface',
			host,
			iface,
			services,
			hostId,
			interfaceId,
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
			interfaceId: undefined,
			subnetId: '',
			isInfra: false
		};
	}
};

// TODO(perspectives): This resolver returns a subnet entity for tag hover support.
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

	// ServiceCategory containers don't have subnet entities
	if (containerType === 'ServiceCategoryContainer') {
		return { subnet: undefined, title, containerType };
	}

	const subnet = topology.subnets.find((s) => s.id === nodeId);
	return { subnet, title, containerType };
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
	// Interface node: services bound to this specific interface on this host
	const serviceIds = topology.services
		.filter(
			(s) =>
				s.host_id &&
				hostIds.includes(s.host_id) &&
				s.bindings.some((b) => b.interface_id === resolved.interfaceId || b.interface_id === null)
		)
		.map((s) => s.id);
	return { hostIds, serviceIds };
}

// Container contents — shared utility for fading, hiding, counting
export interface ContainerContents {
	hostIds: Set<string>;
	serviceIds: Set<string>;
	interfaceIds: Set<string>;
	elementNodeIds: Set<string>;
	subcontainerIds: Set<string>;
}

/**
 * Walk the flow node tree and return all entities inside a container,
 * including entities in nested subcontainers. Works generically across
 * perspectives — uses container_id/subnet_id for elements and
 * parent_container_id for subcontainers.
 */
export function getContainerContents(containerId: string, allNodes: Node[]): ContainerContents {
	const hostIds = new Set<string>();
	const serviceIds = new Set<string>();
	const interfaceIds = new Set<string>();
	const elementNodeIds = new Set<string>();
	const subcontainerIds = new Set<string>();

	// Collect subcontainer IDs (direct children of this container)
	for (const n of allNodes) {
		const nd = n.data as TopologyNode;
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
	for (const n of allNodes) {
		const nd = n.data as TopologyNode;
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
			if (ifaceId) interfaceIds.add(ifaceId);
		}
	}

	return { hostIds, serviceIds, interfaceIds, elementNodeIds, subcontainerIds };
}

// Public API
export function resolveElementNode(
	nodeId: string,
	node: TopologyNode,
	topology: Topology
): ElementRenderContext {
	if (node.node_type !== 'Element') throw new Error(`Expected Element, got ${node.node_type}`);
	const elementType = node.element_type ?? 'Interface'; // Default for backward compat
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
