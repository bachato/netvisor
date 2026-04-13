import type { components } from '$lib/api/schema';
import type { Service } from '$lib/features/services/types/base';

// Re-export generated types
export type Topology = components['schemas']['Topology'];
export type TopologyBase = components['schemas']['TopologyBase'];
export type TopologyOptions = components['schemas']['TopologyOptions'];
export type TopologyLocalOptions = components['schemas']['TopologyLocalOptions'];
export type TopologyRequestOptions = components['schemas']['TopologyRequestOptions'];
export type TopologyEdge = components['schemas']['Edge'];
export type TopologyNode = components['schemas']['Node'];
export type EdgeHandle = components['schemas']['EdgeHandle'];

// Variant types from Node union
export type ElementNode = Extract<TopologyNode, { node_type: 'Element' }>;
export type ContainerNode = Extract<TopologyNode, { node_type: 'Container' }>;

// Frontend-specific render types (not from backend)
export interface PortStatus {
	operStatus: 'Up' | 'Down' | string;
	speed: string | null;
	macAddress: string | null;
}

export interface ElementRenderData {
	elementType: string;
	headerText: string | null;
	subtitleText?: string | null;
	footerText: string | null;
	bodyText: string | null;
	showServices: boolean;
	isVirtualized: boolean;
	isContainerized: boolean;
	services: Service[];
	hiddenOpenPorts: Service[];
	ip_address_id: string;
	isCategoryHidden?: boolean;
	portStatus?: PortStatus;
}

// ContainerRenderData removed — ContainerNode now reads icon/color directly
// from node data (set by backend graph builder) and metadata.
