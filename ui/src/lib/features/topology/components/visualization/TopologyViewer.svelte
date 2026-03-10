<script lang="ts">
	import { type Node, type Edge, type Connection } from '@xyflow/svelte';
	import { get } from 'svelte/store';
	import {
		optionsPanelExpanded,
		selectedEdge,
		selectedNode,
		selectedNodes,
		selectedTopologyId,
		useTopologiesQuery,
		useUpdateNodePositionMutation,
		useUpdateEdgeHandlesMutation
	} from '../../queries';
	import { type EdgeHandle, type TopologyEdge, type TopologyNode } from '../../types/base';
	import BaseTopologyViewer from './BaseTopologyViewer.svelte';

	// TanStack Query hooks
	const topologiesQuery = useTopologiesQuery();
	const updateNodePositionMutation = useUpdateNodePositionMutation();
	const updateEdgeHandlesMutation = useUpdateEdgeHandlesMutation();

	// Derived topology from query data
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(topologiesData.find((t) => t.id === $selectedTopologyId));

	let baseViewer: BaseTopologyViewer | null = $state(null);

	// Selection state synced with stores
	let localSelectedNode: Node | null = $state(null);
	let localSelectedEdge: Edge | null = $state(null);

	// Track mouse movement to distinguish pane click from pan
	let mouseDownPos: { x: number; y: number } | null = null;
	const PAN_THRESHOLD = 5; // pixels

	function handleMouseDown(event: MouseEvent) {
		mouseDownPos = { x: event.clientX, y: event.clientY };
	}

	function wasPan(event?: MouseEvent): boolean {
		if (!mouseDownPos || !event) return false;
		const dx = event.clientX - mouseDownPos.x;
		const dy = event.clientY - mouseDownPos.y;
		return Math.abs(dx) > PAN_THRESHOLD || Math.abs(dy) > PAN_THRESHOLD;
	}

	export function triggerFitView() {
		baseViewer?.triggerFitView();
	}

	async function handleNodeDragStop(targetNode: Node) {
		if (!topology) return;
		let movedNode = topology.nodes.find((node) => node.id == targetNode?.id);
		if (movedNode && targetNode && targetNode.position) {
			// Update local state for immediate feedback
			movedNode.position.x = targetNode.position.x;
			movedNode.position.y = targetNode.position.y;
			// Send lightweight update to server (fixes HTTP 413 for large topologies)
			await updateNodePositionMutation.mutateAsync({
				topologyId: topology.id,
				networkId: topology.network_id,
				nodeId: movedNode.id,
				position: { x: targetNode.position.x, y: targetNode.position.y }
			});
		}
	}

	async function handleReconnect(edge: Edge, newConnection: Connection) {
		if (!topology) return;
		const edgeData = edge.data as TopologyEdge;

		if ($selectedEdge && edge.id === $selectedEdge.id) {
			let topologyEdge = topology.edges.find((e) => e.id == edgeData.id);
			if (
				topologyEdge &&
				newConnection.source == topologyEdge.source &&
				newConnection.target == topologyEdge.target &&
				newConnection.sourceHandle &&
				newConnection.targetHandle
			) {
				// Update local state for immediate feedback
				topologyEdge.source_handle = newConnection.sourceHandle as EdgeHandle;
				topologyEdge.target_handle = newConnection.targetHandle as EdgeHandle;
				// Send lightweight update to server (fixes HTTP 413 for large topologies)
				await updateEdgeHandlesMutation.mutateAsync({
					topologyId: topology.id,
					networkId: topology.network_id,
					edgeId: topologyEdge.id,
					sourceHandle: newConnection.sourceHandle as 'Top' | 'Bottom' | 'Left' | 'Right',
					targetHandle: newConnection.targetHandle as 'Top' | 'Bottom' | 'Left' | 'Right'
				});
			}
		}
	}

	function handleNodeSelect(node: Node | null) {
		selectedNode.set(node);
		selectedEdge.set(null);
		optionsPanelExpanded.set(true);
	}

	function handleEdgeSelect(edge: Edge | null) {
		selectedEdge.set(edge);
		selectedNode.set(null);
		optionsPanelExpanded.set(true);
	}

	function handlePaneSelect(event?: MouseEvent) {
		selectedNode.set(null);
		selectedEdge.set(null);
		// Only clear multi-selection on true click, not after panning
		if (!wasPan(event)) {
			selectedNodes.set([]);
		}
		mouseDownPos = null;
	}

	function handleSelectionChange(newNodes: Node[]) {
		// Filter to InterfaceNodes only
		const interfaceNodes = newNodes.filter((n) => {
			const nodeData = n.data as TopologyNode;
			return nodeData.node_type === 'InterfaceNode';
		});

		if (interfaceNodes.length >= 2) {
			// Preserve insertion order: keep existing nodes in order, append new ones at end
			const current = get(selectedNodes);
			const currentIds = new Set(current.map((n) => n.id));
			const newIds = new Set(interfaceNodes.map((n) => n.id));
			const kept = current.filter((n) => newIds.has(n.id));
			const added = interfaceNodes.filter((n) => !currentIds.has(n.id));
			selectedNodes.set([...kept, ...added]);
			// Clear single-select to hide inspector, show action bar
			selectedNode.set(null);
			selectedEdge.set(null);
		} else if (newNodes.length > 0) {
			// Single interface node selected — not enough for multi-select
			selectedNodes.set([]);
		}
		// When newNodes is empty, don't clear — could be a pan event
		// Explicit clear happens via pane click or Escape
	}

	function handleKeydown(event: KeyboardEvent) {
		if (event.key === 'Escape') {
			selectedNodes.set([]);
			selectedNode.set(null);
			selectedEdge.set(null);
		}
	}
</script>

{#if topology}
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div class="h-[calc(100vh-150px)] w-full" onkeydown={handleKeydown} onmousedown={handleMouseDown}>
		<BaseTopologyViewer
			bind:this={baseViewer}
			{topology}
			readonly={false}
			showControls={true}
			bind:selectedNode={localSelectedNode}
			bind:selectedEdge={localSelectedEdge}
			onNodeDragStop={handleNodeDragStop}
			onReconnect={handleReconnect}
			onNodeSelect={handleNodeSelect}
			onEdgeSelect={handleEdgeSelect}
			onPaneSelect={handlePaneSelect}
			onSelectionChange={handleSelectionChange}
		/>
	</div>
{/if}
