<script lang="ts">
	import { type Node, type Edge, type Connection } from '@xyflow/svelte';
	import { get } from 'svelte/store';
	import {
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
	import { clearSelection } from '../../selection';
	import { editModeEnabled } from '../../state';
	import BaseTopologyViewer from './BaseTopologyViewer.svelte';
	import SearchOverlay from './SearchOverlay.svelte';
	import ShortcutsHelpOverlay from './ShortcutsHelpOverlay.svelte';
	import { onDestroy } from 'svelte';

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

	// Overlay state
	let shortcutsHelpOpen = $state(false);

	// Edit mode state — defaults to view mode (locked), resets on page load
	let editMode = $state(false);

	function toggleEditMode() {
		editMode = !editMode;
		editModeEnabled.set(editMode);
	}

	onDestroy(() => {
		editModeEnabled.set(false);
	});

	export function triggerFitView() {
		baseViewer?.triggerFitView();
	}

	async function handleNodeDragStop(targetNode: Node) {
		if (!topology) return;
		let movedNode = topology.nodes.find((node) => node.id == targetNode?.id);
		if (movedNode && targetNode && targetNode.position) {
			// Snap to 25px grid (matches SvelteFlow snapGrid and ELK post-layout snap)
			const SNAP = 25;
			const x = Math.round(targetNode.position.x / SNAP) * SNAP;
			const y = Math.round(targetNode.position.y / SNAP) * SNAP;
			// Update local state for immediate feedback
			movedNode.position.x = x;
			movedNode.position.y = y;
			// Send lightweight update to server (fixes HTTP 413 for large topologies)
			await updateNodePositionMutation.mutateAsync({
				topologyId: topology.id,
				networkId: topology.network_id,
				nodeId: movedNode.id,
				position: { x, y }
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
				clearSelection();
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
			case 'e':
			case 'E':
				toggleEditMode();
				break;
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
			readonly={!editMode}
			showControls={true}
			{editMode}
			onToggleEditMode={toggleEditMode}
			onNodeDragStop={handleNodeDragStop}
			onReconnect={handleReconnect}
			onOpenShortcuts={() => (shortcutsHelpOpen = true)}
		/>
		<SearchOverlay />
		<ShortcutsHelpOverlay bind:isOpen={shortcutsHelpOpen} />
	</div>
{/if}
