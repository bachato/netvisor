import type { Topology } from '../types/base';
import type { Node } from '@xyflow/svelte';

const HOST_IDS = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];
const SERVICE_IDS = [crypto.randomUUID(), crypto.randomUUID(), crypto.randomUUID()];

export const TUTORIAL_NODES = [
	{ id: SERVICE_IDS[0], label: 'Web App', hostId: HOST_IDS[0] },
	{ id: SERVICE_IDS[1], label: 'API Server', hostId: HOST_IDS[1] },
	{ id: SERVICE_IDS[2], label: 'Database', hostId: HOST_IDS[2] }
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
	hosts: TUTORIAL_NODES.map((n) => ({
		id: n.hostId,
		name: n.label,
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
	services: TUTORIAL_NODES.map((n) => ({
		id: n.id,
		name: n.label,
		host_id: n.hostId,
		network_id: '',
		position: 0,
		service_definition: 'Generic',
		source: { type: 'Manual' },
		bindings: [],
		tags: [],
		created_at: new Date().toISOString(),
		updated_at: new Date().toISOString()
	})),
	subnets: []
} as unknown as Topology;

export function makeTutorialNode(tutorialNode: (typeof TUTORIAL_NODES)[number]): Node {
	return {
		id: tutorialNode.id,
		position: { x: 0, y: 0 },
		data: {
			id: tutorialNode.id,
			node_type: 'Element',
			element_type: 'Service',
			host_id: tutorialNode.hostId,
			header: tutorialNode.label,
			position: { x: 0, y: 0 },
			size: { x: 150, y: 40 }
		},
		type: 'Element'
	};
}
