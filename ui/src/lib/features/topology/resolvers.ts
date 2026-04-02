import type { components } from '$lib/api/schema';
import type { Topology, TopologyNode } from './types/base';

// Type aliases for the discriminated union variants
type ContainerType = components['schemas']['ContainerType']; // 'Subnet'
type LeafEntityType = components['schemas']['LeafEntityType']; // 'Interface'

// Resolver return types
export interface LeafRenderContext {
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
	infraWidth: number;
}

// Exhaustive resolver maps — TypeScript errors if a variant is missing
const leafResolvers: Record<
	LeafEntityType,
	(nodeId: string, node: TopologyNode, topology: Topology) => LeafRenderContext
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
	Subnet: (nodeId, _node, topology) => {
		const subnet = topology.subnets.find((s) => s.id === nodeId);
		// Currently reads infra_width from convenience field on the node.
		// When removed, this could come from layout metadata or be computed.
		const infraWidth = 'infra_width' in _node ? (_node.infra_width as number) : 0;
		return { subnet, infraWidth };
	}
};

// Public API
export function resolveLeafNode(
	nodeId: string,
	node: TopologyNode,
	topology: Topology
): LeafRenderContext {
	if (node.node_type !== 'LeafNode') throw new Error(`Expected LeafNode, got ${node.node_type}`);
	const leafType = node.leaf_type ?? 'Interface'; // Default for backward compat
	return leafResolvers[leafType](nodeId, node, topology);
}

export function resolveContainerNode(
	nodeId: string,
	node: TopologyNode,
	topology: Topology
): ContainerRenderContext {
	if (node.node_type !== 'ContainerNode')
		throw new Error(`Expected ContainerNode, got ${node.node_type}`);
	const containerType = node.container_type ?? 'Subnet'; // Default for backward compat
	return containerResolvers[containerType](nodeId, node, topology);
}
