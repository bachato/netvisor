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
	import { searchOpen, clearSearch } from '../../interactions';
	import BaseTopologyViewer from './BaseTopologyViewer.svelte';
	import SearchOverlay from './SearchOverlay.svelte';
	import ShortcutsHelpOverlay from './ShortcutsHelpOverlay.svelte';

	// Props for callbacks from parent
	let {
		onToggleLock,
		onRebuild,
		isActive = false
	}: {
		onToggleLock?: () => void;
		onRebuild?: () => void;
		isActive?: boolean;
	} = $props();

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

	// Overlay state
	let shortcutsHelpOpen = $state(false);

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

	// Flag to ignore SvelteFlow's onselectionchange after we handle Ctrl+click ourselves
	let ignoreNextSelectionChange = false;

	function handleNodeSelect(node: Node | null, event?: MouseEvent | TouchEvent) {
		const isModifierClick = event instanceof MouseEvent && (event.ctrlKey || event.metaKey);

		if (isModifierClick && node) {
			const nodeData = node.data as TopologyNode;
			if (nodeData.node_type !== 'InterfaceNode') return;

			const current = get(selectedNodes);
			const currentSingle = get(selectedNode);
			const idx = current.findIndex((n) => n.id === node.id);

			if (idx !== -1) {
				// Deselect: remove node from multi-selection
				const remaining = current.filter((_, i) => i !== idx);
				if (remaining.length < 2) {
					// Exit multi-select, revert to single-select on the remaining node
					selectedNodes.set([]);
					if (remaining.length === 1) {
						selectedNode.set(remaining[0]);
						optionsPanelExpanded.set(true);
					}
				} else {
					selectedNodes.set(remaining);
				}
			} else {
				// Add node to multi-selection
				if (current.length === 0 && currentSingle) {
					// Transition from single-select to multi-select
					const currentSingleData = currentSingle.data as TopologyNode;
					if (currentSingleData.node_type === 'InterfaceNode') {
						selectedNodes.set([currentSingle, node]);
					} else {
						selectedNodes.set([node]);
					}
				} else if (current.length > 0) {
					selectedNodes.set([...current, node]);
				} else {
					// No current selection at all — just start fresh
					selectedNodes.set([node]);
				}
				selectedNode.set(null);
				selectedEdge.set(null);
			}

			ignoreNextSelectionChange = true;
			return;
		}

		// Normal click (no modifier)
		selectedNode.set(node);
		selectedEdge.set(null);
		selectedNodes.set([]);
		optionsPanelExpanded.set(true);
	}

	function handleEdgeSelect(edge: Edge | null) {
		selectedEdge.set(edge);
		selectedNode.set(null);
		optionsPanelExpanded.set(true);
	}

	function handlePaneSelect(_event?: MouseEvent, wasPanning?: boolean) {
		
		selectedEdge.set(null);
		// Only clear selection on true click, not after panning
		if (!wasPanning) {
			selectedNodes.set([]);
			selectedNode.set(null);
		}
		clearSearch();
	}

	// eslint-disable-next-line @typescript-eslint/no-unused-vars
	function handleSelectionChange(newNodes: Node[], _edges: Edge[]) {
		// Ignore SvelteFlow's selection change after we handled a Ctrl+click ourselves
		if (ignoreNextSelectionChange) {
			ignoreNextSelectionChange = false;
			return;
		}

		// Box-select scenario (Shift+drag): use SvelteFlow's node set
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
			selectedNode.set(null);
			selectedEdge.set(null);
		} else if (newNodes.length > 0) {
			// Single interface node selected — not enough for multi-select
			selectedNodes.set([]);
		}
		// When newNodes is empty, don't clear — could be a pan event
		// Explicit clear happens via pane click or Escape
	}

	function isInputElement(target: EventTarget | null): boolean {
		if (!target || !(target instanceof HTMLElement)) return false;
		const tag = target.tagName.toLowerCase();
		if (tag === 'input' || tag === 'textarea' || tag === 'select') return true;
		if (target.isContentEditable) return true;
		return false;
	}

	function handleKeydown(event: KeyboardEvent) {
		if (!isActive) return;
		if (shortcutsHelpOpen) return;

		const isSearchOpen = get(searchOpen);

		// Escape always works
		if (event.key === 'Escape') {
			if (isSearchOpen) {
				clearSearch();
			} else {
				selectedNodes.set([]);
				selectedNode.set(null);
				selectedEdge.set(null);
			}
			return;
		}

		// Skip shortcuts when typing in inputs (except Escape handled above)
		if (isInputElement(event.target)) return;

		// Cmd/Ctrl+F: open search
		if ((event.metaKey || event.ctrlKey) && event.key === 'f') {
			event.preventDefault();
			searchOpen.set(true);
			return;
		}

		// Single key shortcuts (no modifiers)
		if (event.metaKey || event.ctrlKey || event.altKey) return;

		switch (event.key) {
			case '/':
				event.preventDefault();
				searchOpen.set(true);
				break;
			case 'f':
			case 'F':
				baseViewer?.triggerFitView();
				break;
			case 'z':
			case 'Z': {
				// Zoom to selected node(s)
				const multiSelected = get(selectedNodes);
				const singleSelected = get(selectedNode);
				if (multiSelected.length >= 2) {
					baseViewer?.fitViewToNodes(multiSelected.map((n) => n.id));
				} else if (singleSelected) {
					baseViewer?.fitViewToNodes([singleSelected.id]);
				}
				break;
			}
			case 'l':
			case 'L':
				onToggleLock?.();
				break;
			case 'r':
			case 'R':
				onRebuild?.();
				break;
			case '?':
				shortcutsHelpOpen = !shortcutsHelpOpen;
				break;
		}
	}
</script>

<svelte:window onkeydown={handleKeydown} />

{#if topology}
	<div class="relative h-[calc(100vh-150px)] w-full">
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
			onOpenShortcuts={() => (shortcutsHelpOpen = true)}
		/>
		<SearchOverlay />
		<ShortcutsHelpOverlay bind:isOpen={shortcutsHelpOpen} />
	</div>
{/if}
