import type { Topology } from '../types/base';
import type { Node } from '@xyflow/svelte';

const HOST_IDS = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];
const SERVICE_IDS = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];

export const TUTORIAL_SERVICES = [
	{
		id: SERVICE_IDS[0],
		label: 'Caddy',
		hostId: HOST_IDS[0],
		hostName: 'web-proxy-01',
		serviceDefinition: 'Caddy'
	},
	{
		id: SERVICE_IDS[1],
		label: 'PostgreSQL',
		hostId: HOST_IDS[1],
		hostName: 'db-primary-01',
		serviceDefinition: 'PostgreSQL'
	},
	{
		id: SERVICE_IDS[2],
		label: 'Redis',
		hostId: HOST_IDS[2],
		hostName: 'cache-01',
		serviceDefinition: 'Redis'
	}
];

export const TUTORIAL_TOPOLOGY: Topology = {
	id: crypto.randomUUID(),
	name: 'Tutorial',
	network_id: crypto.randomUUID(),
	is_locked: false,
	is_stale: false,
	last_refreshed: new Date().toISOString(),
	locked_at: null,
	locked_by: null,
	parent_id: null,
	created_at: new Date().toISOString(),
	updated_at: new Date().toISOString(),
	nodes: [],
	edges: [],
	dependencies: [],
	entity_tags: [],
	bindings: [],
	ports: [],
	ip_addresses: [],
	interfaces: [],
	removed_bindings: [],
	removed_dependencies: [],
	removed_hosts: [],
	removed_interfaces: [],
	removed_ip_addresses: [],
	removed_ports: [],
	removed_services: [],
	removed_subnets: [],
	options: {
		request: { element_rules: [], container_rules: [] },
		local: {
			hide_edge_types: [],
			edge_color_mode: 'ByType',
			hide_ports: false,
			expand_level: 'ContainersExpanded'
		}
	},
	hosts: TUTORIAL_SERVICES.map((n) => ({
		id: n.hostId,
		name: n.hostName,
		hostname: null,
		description: null,
		hidden: false,
		chassis_id: null,
		management_url: null,
		manufacturer: null,
		model: null,
		os: null,
		serial: null,
		credential_assignments: [],
		network_id: '',
		tags: [],
		source: { type: 'Manual' },
		created_at: new Date().toISOString(),
		updated_at: new Date().toISOString()
	})),
	services: TUTORIAL_SERVICES.map((n) => ({
		id: n.id,
		name: n.label,
		host_id: n.hostId,
		network_id: '',
		position: 0,
		service_definition: n.serviceDefinition,
		source: { type: 'Manual' },
		bindings: [],
		tags: [],
		created_at: new Date().toISOString(),
		updated_at: new Date().toISOString()
	})),
	subnets: []
} as unknown as Topology;

// Xyflow nodes positioned in a row for the mini topology viewer
export const TUTORIAL_XYFLOW_NODES: Node[] = TUTORIAL_SERVICES.map((n, i) => ({
	id: n.id,
	position: { x: i * 200, y: 50 },
	data: {
		id: n.id,
		node_type: 'Element',
		element_type: 'Service',
		host_id: n.hostId,
		header: n.hostName,
		position: { x: i * 200, y: 50 },
		size: { x: 150, y: 60 }
	},
	type: 'Element'
}));
