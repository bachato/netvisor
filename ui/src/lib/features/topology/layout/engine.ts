import type { TopologyNode, TopologyEdge, Topology } from '../types/base';
import type { EdgeHandles } from './elk-layout';
import { computeElkLayout } from './elk-layout';

export interface LayoutInput {
	nodes: TopologyNode[];
	edges: TopologyEdge[];
	topology: Topology;
	collapsedContainers?: Set<string>;
	expandedContainerSizes?: Map<string, { width: number; height: number }>;
	elementNodeSizes?: Map<string, { x: number; y: number }>;
	hiddenEdgeTypes?: string[];
}

export interface LayoutResult {
	nodePositions: Map<string, { x: number; y: number }>;
	containerSizes: Map<string, { width: number; height: number }>;
	elementNodeSizes: Map<string, { x: number; y: number }>;
	edgeHandles: Map<string, EdgeHandles>;
}

export interface LayoutEngine {
	compute(input: LayoutInput): Promise<LayoutResult>;
}

export class ElkLayoutEngine implements LayoutEngine {
	async compute(input: LayoutInput): Promise<LayoutResult> {
		return computeElkLayout(input);
	}
}
