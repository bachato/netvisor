import type { components } from '$lib/api/schema';
import type { Topology, TopologyNode } from './types/base';

// Type aliases for the discriminated union variants
type ContainerType = components['schemas']['ContainerType'];
type ElementEntityType = components['schemas']['ElementEntityType'];

// Resolver return types
export interface ElementRenderContext {
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
}

// Exhaustive resolver maps — TypeScript errors if a variant is missing
const elementResolvers: Record<
	ElementEntityType,
	(nodeId: string, node: TopologyNode, topology: Topology) => ElementRenderContext
> = {
	Interface: (_nodeId, node, topology) => {
		// Currently reads from convenience fields on the node.
		// When convenience fields are removed, resolve from entity collections:
		//   const iface = topology.interfaces.find(i => i.id === nodeId);
		//   const host = topology.hosts.find(h => h.id === iface?.host_id);
		const hostId = 'host_id' in node ? (node.host_id as string) : undefined;
		const interfaceId =
			'interface_id' in node ? (node.interface_id as string | undefined) : undefined;
		const subnetId = 'subnet_id' in node ? (node.subnet_id as string) : '';
		const isInfra = 'is_infra' in node ? (node.is_infra as boolean) : false;

		const host = topology.hosts.find((h) => h.id === hostId);
		const iface = interfaceId ? topology.interfaces.find((i) => i.id === interfaceId) : undefined;
		const services = topology.services.filter((s) => s.host_id === hostId);

		return { host, iface, services, hostId, interfaceId, subnetId, isInfra };
	}
};

const containerResolvers: Record<
	ContainerType,
	(nodeId: string, node: TopologyNode, topology: Topology) => ContainerRenderContext
> = {
	Subnet: (nodeId, node, topology) => {
		const subnet = topology.subnets.find((s) => s.id === nodeId);
		const title = 'header' in node ? (node.header as string | null) : null;
		return { subnet, title };
	},
	TagContainer: (_nodeId, node) => {
		const title = 'header' in node ? (node.header as string | null) : null;
		return { subnet: undefined, title };
	},
	ServiceCategoryContainer: (_nodeId, node) => {
		const title = 'header' in node ? (node.header as string | null) : null;
		return { subnet: undefined, title };
	}
};

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
	const containerType = (node.container_type ?? 'Subnet') as ContainerType;
	const resolver = containerResolvers[containerType];
	if (!resolver) return containerResolvers['Subnet'](nodeId, node, topology);
	return resolver(nodeId, node, topology);
}
