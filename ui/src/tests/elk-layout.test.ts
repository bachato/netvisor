import { describe, it, expect, beforeEach } from 'vitest';
import { computeElkLayout, type ElkLayoutInput } from '$lib/features/topology/layout/elk-layout';
import {
	isDisabledEdge,
	isDashedEdge,
	affectsLayout,
	isHiddenByDefault,
	getDefaultHiddenEdgeTypes
} from '$lib/features/topology/layout/edge-classification';
import type { components } from '$lib/api/schema';

type TopologyNode = components['schemas']['Node'];
type TopologyEdge = components['schemas']['Edge'];
type Subnet = components['schemas']['Subnet'];
type SubnetType = components['schemas']['SubnetType'];

// --- Test Helpers ---

let idCounter = 0;
function uuid(): string {
	return `00000000-0000-0000-0000-${String(++idCounter).padStart(12, '0')}`;
}

function resetIds() {
	idCounter = 0;
}

function makeContainer(
	id: string,
	opts?: { width?: number; height?: number; container_type?: string; parent_container_id?: string }
): TopologyNode {
	return {
		id,
		node_type: 'Container',
		container_type: opts?.container_type ?? 'Subnet',
		...(opts?.parent_container_id && { parent_container_id: opts.parent_container_id }),
		position: { x: 0, y: 0 },
		size: { x: opts?.width ?? 400, y: opts?.height ?? 300 }
	} as TopologyNode;
}

function makeElement(id: string, subnetId: string, hostId?: string): TopologyNode {
	return {
		id,
		node_type: 'Element',
		element_type: 'Interface',
		host_id: hostId ?? uuid(),
		container_id: subnetId,
		subnet_id: subnetId,
		position: { x: 0, y: 0 },
		size: { x: 180, y: 60 }
	} as TopologyNode;
}

function makeEdge(
	source: string,
	target: string,
	edgeType: string = 'Interface',
	viewConfig?: {
		affects_layout: boolean;
		default_visibility?: 'visible' | 'hidden';
		stroke?: 'solid' | 'dashed';
	}
): TopologyEdge {
	return {
		edge_type: edgeType,
		source,
		target,
		source_handle: 'Bottom',
		target_handle: 'Top',
		view_config: viewConfig
			? {
					type: 'active' as const,
					affects_layout: viewConfig.affects_layout,
					default_visibility: viewConfig.default_visibility ?? 'visible',
					stroke: viewConfig.stroke ?? 'solid',
					highlight_behavior: 'when_visible'
				}
			: { type: 'disabled' as const }
	} as TopologyEdge;
}

/** Shorthand for a layout-affecting visible solid edge */
function primaryEdge(source: string, target: string, edgeType: string = 'Interface'): TopologyEdge {
	return makeEdge(source, target, edgeType, { affects_layout: true });
}

function makeSubnet(id: string, subnetType: SubnetType): Subnet {
	return {
		id,
		name: `subnet-${subnetType}`,
		subnet_type: subnetType,
		network_id: uuid(),
		cidr: '10.0.0.0/24',
		source: { type: 'Manual' },
		tags: [],
		created_at: '2026-01-01T00:00:00Z',
		updated_at: '2026-01-01T00:00:00Z'
	} as Subnet;
}

function makeTopology(
	nodes: TopologyNode[],
	edges: TopologyEdge[],
	subnets: Subnet[]
): ElkLayoutInput {
	return {
		nodes,
		edges,
		topology: {
			id: uuid(),
			created_at: '2026-01-01T00:00:00Z',
			updated_at: '2026-01-01T00:00:00Z',
			name: 'test',
			network_id: uuid(),
			is_locked: false,
			is_stale: false,
			last_refreshed: '2026-01-01T00:00:00Z',
			nodes,
			edges,
			subnets,
			hosts: [],
			interfaces: [],
			services: [],
			dependencies: [],
			entity_tags: [],
			ports: [],
			bindings: [],
			if_entries: [],
			tags: [],
			removed_hosts: [],
			removed_interfaces: [],
			removed_services: [],
			removed_subnets: [],
			removed_dependencies: [],
			removed_ports: [],
			removed_bindings: [],
			removed_if_entries: [],
			options: {
				local: {
					left_zone_title: '', // Deprecated field, kept for generated type compat
					hide_edge_types: [],
					no_fade_edges: false,
					hide_resize_handles: false
				},
				request: {
					hide_ports: false,
					hide_service_categories: [],
					container_rules: [
						{ id: '00000000-0000-0000-0000-000000000001', rule: 'BySubnet' },
						{ id: '00000000-0000-0000-0000-000000000002', rule: 'MergeDockerBridges' }
					],
					element_rules: []
				}
			}
		} as ElkLayoutInput['topology']
	};
}

// --- Edge Classification Tests ---

describe('edge view config helpers', () => {
	it('treats edges without view_config as disabled', () => {
		const edge = { edge_type: 'Interface', source: 'a', target: 'b' } as TopologyEdge;
		expect(isDisabledEdge(edge)).toBe(true);
		expect(affectsLayout(edge)).toBe(false);
	});

	it('isDisabledEdge returns true for disabled config', () => {
		const edge = makeEdge('a', 'b', 'Interface');
		expect(isDisabledEdge(edge)).toBe(true);
	});

	it('isDisabledEdge returns false for active config', () => {
		const edge = makeEdge('a', 'b', 'Interface', { affects_layout: true });
		expect(isDisabledEdge(edge)).toBe(false);
	});

	it('affectsLayout reads from view config', () => {
		expect(affectsLayout(makeEdge('a', 'b', 'Interface', { affects_layout: true }))).toBe(true);
		expect(affectsLayout(makeEdge('a', 'b', 'Interface', { affects_layout: false }))).toBe(false);
		expect(affectsLayout(makeEdge('a', 'b', 'Interface'))).toBe(false); // disabled
	});

	it('isDashedEdge reads stroke from view config', () => {
		expect(
			isDashedEdge(makeEdge('a', 'b', 'Interface', { affects_layout: true, stroke: 'dashed' }))
		).toBe(true);
		expect(
			isDashedEdge(makeEdge('a', 'b', 'Interface', { affects_layout: true, stroke: 'solid' }))
		).toBe(false);
	});

	it('isHiddenByDefault reads default_visibility from view config', () => {
		expect(
			isHiddenByDefault(
				makeEdge('a', 'b', 'Interface', { affects_layout: true, default_visibility: 'hidden' })
			)
		).toBe(true);
		expect(
			isHiddenByDefault(
				makeEdge('a', 'b', 'Interface', { affects_layout: true, default_visibility: 'visible' })
			)
		).toBe(false);
	});

	it('getDefaultHiddenEdgeTypes returns an array', () => {
		const result = getDefaultHiddenEdgeTypes('L3Logical');
		expect(Array.isArray(result)).toBe(true);
	});
});

// --- ELK Layout Tests ---

describe('computeElkLayout', () => {
	beforeEach(() => resetIds());

	it('returns empty maps for empty input', async () => {
		const result = await computeElkLayout({
			nodes: [],
			edges: [],
			topology: makeTopology([], [], []).topology
		});
		expect(result.nodePositions.size).toBe(0);
		expect(result.containerSizes.size).toBe(0);
	});

	it('produces valid positions for a simple topology', async () => {
		const subnetExt = uuid();
		const subnetGw = uuid();
		const subnetLan = uuid();

		const elem1 = uuid();
		const elem2 = uuid();
		const elem3 = uuid();
		const elem4 = uuid();
		const elem5 = uuid();

		const host1 = uuid();

		const nodes: TopologyNode[] = [
			makeContainer(subnetExt),
			makeContainer(subnetGw),
			makeContainer(subnetLan),
			makeElement(elem1, subnetExt, host1),
			makeElement(elem2, subnetExt),
			makeElement(elem3, subnetGw, host1), // multi-homed: same host in different subnet
			makeElement(elem4, subnetLan),
			makeElement(elem5, subnetLan)
		];

		const edges: TopologyEdge[] = [
			primaryEdge(elem1, elem3, 'Interface'), // primary: ext -> gw
			primaryEdge(elem3, elem4, 'Interface'), // primary: gw -> lan
			makeEdge(elem1, elem4, 'HostVirtualization') // overlay: should be ignored by layout
		];

		const subnets = [
			makeSubnet(subnetExt, 'Internet'),
			makeSubnet(subnetGw, 'Gateway'),
			makeSubnet(subnetLan, 'Lan')
		];

		const input = makeTopology(nodes, edges, subnets);
		const result = await computeElkLayout(input);

		// All nodes should have positions
		expect(result.nodePositions.size).toBeGreaterThanOrEqual(nodes.length);

		// All positions should be valid numbers
		for (const [, pos] of result.nodePositions) {
			expect(Number.isFinite(pos.x)).toBe(true);
			expect(Number.isFinite(pos.y)).toBe(true);
		}

		// Container sizes should be set
		expect(result.containerSizes.has(subnetExt)).toBe(true);
		expect(result.containerSizes.has(subnetGw)).toBe(true);
		expect(result.containerSizes.has(subnetLan)).toBe(true);

		for (const [, size] of result.containerSizes) {
			expect(size.width).toBeGreaterThan(0);
			expect(size.height).toBeGreaterThan(0);
		}
	});

	it('respects layer ordering (External above Gateway above Lan)', async () => {
		const subnetExt = uuid();
		const subnetGw = uuid();
		const subnetLan = uuid();

		const elem1 = uuid();
		const elem2 = uuid();
		const elem3 = uuid();

		const nodes: TopologyNode[] = [
			makeContainer(subnetExt),
			makeContainer(subnetGw),
			makeContainer(subnetLan),
			makeElement(elem1, subnetExt),
			makeElement(elem2, subnetGw),
			makeElement(elem3, subnetLan)
		];

		const edges: TopologyEdge[] = [
			primaryEdge(elem1, elem2, 'Interface'),
			primaryEdge(elem2, elem3, 'Interface')
		];

		const subnets = [
			makeSubnet(subnetExt, 'Internet'),
			makeSubnet(subnetGw, 'Gateway'),
			makeSubnet(subnetLan, 'Lan')
		];

		const input = makeTopology(nodes, edges, subnets);
		const result = await computeElkLayout(input);

		const extPos = result.nodePositions.get(subnetExt)!;
		const gwPos = result.nodePositions.get(subnetGw)!;
		const lanPos = result.nodePositions.get(subnetLan)!;

		expect(extPos.y).toBeLessThan(gwPos.y);
		expect(gwPos.y).toBeLessThan(lanPos.y);
	});

	it('positions element nodes with non-negative relative coordinates', async () => {
		const subnetId = uuid();
		const elem1 = uuid();
		const elem2 = uuid();

		const nodes: TopologyNode[] = [
			makeContainer(subnetId),
			makeElement(elem1, subnetId),
			makeElement(elem2, subnetId)
		];

		const edges: TopologyEdge[] = [primaryEdge(elem1, elem2, 'Interface')];
		const subnets = [makeSubnet(subnetId, 'Lan')];

		const input = makeTopology(nodes, edges, subnets);
		const result = await computeElkLayout(input);

		// Element positions should be non-negative (relative to parent)
		const l1Pos = result.nodePositions.get(elem1)!;
		const l2Pos = result.nodePositions.get(elem2)!;

		expect(l1Pos.x).toBeGreaterThanOrEqual(0);
		expect(l1Pos.y).toBeGreaterThanOrEqual(0);
		expect(l2Pos.x).toBeGreaterThanOrEqual(0);
		expect(l2Pos.y).toBeGreaterThanOrEqual(0);
	});

	it('handles single subnet with single host', async () => {
		const subnetId = uuid();
		const elementId = uuid();

		const nodes: TopologyNode[] = [makeContainer(subnetId), makeElement(elementId, subnetId)];
		const edges: TopologyEdge[] = [];
		const subnets = [makeSubnet(subnetId, 'Lan')];

		const input = makeTopology(nodes, edges, subnets);
		const result = await computeElkLayout(input);

		expect(result.nodePositions.has(subnetId)).toBe(true);
		expect(result.nodePositions.has(elementId)).toBe(true);

		const containerSize = result.containerSizes.get(subnetId)!;
		expect(containerSize.width).toBeGreaterThanOrEqual(180); // at least as wide as child
		expect(containerSize.height).toBeGreaterThanOrEqual(60); // at least as tall as child
	});

	it('handles medium topology without errors', async () => {
		const subnetTypes: SubnetType[] = [
			'Internet',
			'Gateway',
			'Lan',
			'WiFi',
			'DockerBridge',
			'Management',
			'Storage',
			'IoT'
		];

		const subnetIds = subnetTypes.map(() => uuid());
		const subnets = subnetIds.map((id, i) => makeSubnet(id, subnetTypes[i]));

		const nodes: TopologyNode[] = subnetIds.map((id) => makeContainer(id));

		// Add ~2-3 hosts per subnet
		const elementIds: string[] = [];
		for (const subnetId of subnetIds) {
			const count = 2 + Math.floor(subnetIds.indexOf(subnetId) % 3);
			for (let j = 0; j < count; j++) {
				const elementId = uuid();
				elementIds.push(elementId);
				nodes.push(makeElement(elementId, subnetId));
			}
		}

		// Create some primary edges between adjacent subnets
		const edges: TopologyEdge[] = [];
		for (let i = 0; i < elementIds.length - 1; i += 3) {
			edges.push(primaryEdge(elementIds[i], elementIds[i + 1], 'Interface'));
		}

		const input = makeTopology(nodes, edges, subnets);
		const result = await computeElkLayout(input);

		// All nodes have positions
		for (const node of nodes) {
			expect(result.nodePositions.has(node.id)).toBe(true);
		}

		// No NaN positions
		for (const [, pos] of result.nodePositions) {
			expect(Number.isFinite(pos.x)).toBe(true);
			expect(Number.isFinite(pos.y)).toBe(true);
		}
	});

	it('handles nested sub-group containers inside a subnet', async () => {
		const subnetId = uuid();
		const groupId = uuid();
		const elem1 = uuid();
		const elem2 = uuid();
		const elem3 = uuid();

		const nodes: TopologyNode[] = [
			makeContainer(subnetId),
			makeContainer(groupId, {
				container_type: 'NestedServiceCategory',
				parent_container_id: subnetId
			}),
			makeElement(elem1, subnetId),
			makeElement(elem2, groupId),
			makeElement(elem3, groupId)
		];

		const edges: TopologyEdge[] = [primaryEdge(elem1, elem2, 'Interface')];
		const subnets = [makeSubnet(subnetId, 'Lan')];

		const input = makeTopology(nodes, edges, subnets);
		const result = await computeElkLayout(input);

		// All nodes should have positions
		expect(result.nodePositions.has(subnetId)).toBe(true);
		expect(result.nodePositions.has(groupId)).toBe(true);
		expect(result.nodePositions.has(elem1)).toBe(true);
		expect(result.nodePositions.has(elem2)).toBe(true);

		// Sub-group should have a size
		expect(result.containerSizes.has(groupId)).toBe(true);
		const groupSize = result.containerSizes.get(groupId)!;
		expect(groupSize.width).toBeGreaterThan(0);
		expect(groupSize.height).toBeGreaterThan(0);

		// Sub-group position should be non-negative (relative to parent)
		const groupPos = result.nodePositions.get(groupId)!;
		expect(groupPos.x).toBeGreaterThanOrEqual(0);
		expect(groupPos.y).toBeGreaterThanOrEqual(0);
	});

	it('containers with 8 elements use multi-column layout', async () => {
		const subnetId = uuid();
		const elemIds = Array.from({ length: 8 }, () => uuid());

		const nodes: TopologyNode[] = [
			makeContainer(subnetId),
			...elemIds.map((id) => makeElement(id, subnetId))
		];

		const edges: TopologyEdge[] = [];
		const subnets = [makeSubnet(subnetId, 'Lan')];
		const input = makeTopology(nodes, edges, subnets);
		const result = await computeElkLayout(input);

		// Elements should NOT all have the same x position (i.e., not single column)
		const xPositions = new Set(elemIds.map((id) => result.nodePositions.get(id)!.x));
		expect(xPositions.size).toBeGreaterThan(1);

		// Container should be wider than a single element (180px)
		const containerSize = result.containerSizes.get(subnetId)!;
		expect(containerSize.width).toBeGreaterThan(250);
	});

	it('containers with 20 elements wrap into multiple rows', async () => {
		const subnetId = uuid();
		const elemIds = Array.from({ length: 20 }, () => uuid());

		const nodes: TopologyNode[] = [
			makeContainer(subnetId),
			...elemIds.map((id) => makeElement(id, subnetId))
		];

		const edges: TopologyEdge[] = [];
		const subnets = [makeSubnet(subnetId, 'Lan')];
		const input = makeTopology(nodes, edges, subnets);
		const result = await computeElkLayout(input);

		// Should have multiple distinct x AND y positions (grid, not single row)
		const xPositions = new Set(elemIds.map((id) => result.nodePositions.get(id)!.x));
		const yPositions = new Set(elemIds.map((id) => result.nodePositions.get(id)!.y));
		expect(xPositions.size).toBeGreaterThan(1);
		expect(yPositions.size).toBeGreaterThan(1);

		// Container should not be excessively wide (no more than ~7 elements wide)
		const containerSize = result.containerSizes.get(subnetId)!;
		expect(containerSize.width).toBeLessThan(180 * 8 + 25 * 7); // ~1615px
	});

	it('does not pass disabled edges to ELK layout', async () => {
		const subnetId = uuid();
		const elem1 = uuid();
		const elem2 = uuid();

		const nodes: TopologyNode[] = [
			makeContainer(subnetId),
			makeElement(elem1, subnetId),
			makeElement(elem2, subnetId)
		];

		// Only disabled edges — no layout-affecting edges to drive layout
		const edges: TopologyEdge[] = [
			makeEdge(elem1, elem2, 'HostVirtualization'),
			makeEdge(elem1, elem2, 'RequestPath')
		];

		const subnets = [makeSubnet(subnetId, 'Lan')];
		const input = makeTopology(nodes, edges, subnets);

		// Should succeed even with no layout-affecting edges
		const result = await computeElkLayout(input);
		expect(result.nodePositions.size).toBeGreaterThan(0);
	});
});
