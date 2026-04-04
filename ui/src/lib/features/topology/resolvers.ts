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
