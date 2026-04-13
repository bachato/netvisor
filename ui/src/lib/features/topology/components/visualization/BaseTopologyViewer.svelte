<script lang="ts">
	import { writable, derived, get, type Writable } from 'svelte/store';
	import {
		SvelteFlow,
		MiniMap,
		Background,
		BackgroundVariant,
		useNodesInitialized,
		type Connection,
		useSvelteFlow
	} from '@xyflow/svelte';
	import {
		common_collapse,
		common_expand,
		topology_levelFullyCollapsed,
		topology_levelContainersExpanded,
		topology_levelSubcontainersExpanded,
		topology_levelFullyExpanded
	} from '$lib/paraglide/messages';
	import { type Node, type Edge } from '@xyflow/svelte';
	import '@xyflow/svelte/dist/style.css';
	import './topology-viewer.css';
	import { pushError } from '$lib/shared/stores/feedback';
	import {
		previewEdges,
		selectedNodes,
		selectedEdge as selectedEdgeStore,
		selectedNode as selectedNodeStore,
		topologyOptions,
		optionsPanelExpanded,
		OPTIONS_PANEL_WIDTH_PX,
		OPTIONS_PANEL_FITVIEW_PADDING_PX,
		aggregatedEdgeOriginals,
		getInfrastructureRuleId
	} from '../../queries';
	import { isExporting, expandedPortNodeIds } from '../../interactions';

	// Import custom node/edge components
	import ContainerNode from './ContainerNode.svelte';
	import ElementNode from './ElementNode.svelte';
	import CustomEdge from './CustomEdge.svelte';
	import TopologySidebarControls from './TopologySidebarControls.svelte';
	import type { Topology } from '../../types/base';
	import { collapsedContainers, collapseLevel, stepExpand, stepCollapse } from '../../collapse';
	import type { CollapseLevel } from '../../collapse';
	import {
		updateConnectedNodes,
		setEdgeHover,
		clearEdgeHoverState,
		expandedBundles,
		collapseAllBundles,
		searchHiddenNodeIds,
		tagHiddenNodeIds
	} from '../../interactions';
	import {
		selectNode,
		selectEdge,
		clearSelection,
		handleModifierNodeClick,
		handleBoxSelect,
		type SelectionStores
	} from '../../selection';
	import { onMount, tick, setContext, getContext } from 'svelte';
	import { useQueryClient } from '@tanstack/svelte-query';
	import { writable as svelteWritable } from 'svelte/store';
	import { themeStore } from '$lib/shared/stores/theme.svelte';
	import { containerTypes } from '$lib/shared/stores/metadata';

	// Pipeline imports
	import { createInitialState } from '../../pipeline/types';
	import { prepareTopologyData } from '../../pipeline/prepare';
	import { resolveNodeSizes } from '../../pipeline/measure';
	import { executeLayout, handlePortExpansion } from '../../pipeline/execute-layout';
	import { buildFlowNodes, sortFlowNodes } from '../../pipeline/build-flow-nodes';
	import { buildFlowEdges } from '../../pipeline/build-flow-edges';
	import { cacheCollapsedSizes } from '../../pipeline/post-render';
	import { computeEdgeDisplayUpdates } from '../../pipeline/sync-edge-display';

	// Props
	let {
		topology,
		readonly = false,
		showControls = true,
		isEmbed = false,
		showBranding = false,
		showMinimap = undefined,
		onNodeDragStop = null,
		onReconnect = null,
		onOpenShortcuts = null,
		onOpenSearch = null,
		editMode = false,
		onToggleEditMode = null,
		sidebarCollapsed = false
	}: {
		topology: Topology;
		readonly?: boolean;
		showControls?: boolean;
		isEmbed?: boolean;
		showBranding?: boolean;
		showMinimap?: boolean | undefined;
		onNodeDragStop?: ((node: Node) => void) | null;
		onReconnect?: ((edge: Edge, newConnection: Connection) => void) | null;
		onOpenShortcuts?: (() => void) | null;
		onOpenSearch?: (() => void) | null;
		editMode?: boolean;
		onToggleEditMode?: (() => void) | null;
		sidebarCollapsed?: boolean;
	} = $props();

	// Create a context store for the topology so child nodes can access it
	const topologyContext = svelteWritable<Topology>(topology);
	setContext('topology', topologyContext);
	$effect(() => {
		topologyContext.set(topology);
	});

	// Resolve selection stores from context (share/embed) or fall back to global stores
	const selNodeStore = getContext<Writable<Node | null>>('selectedNode') ?? selectedNodeStore;
	const selEdgeStore = getContext<Writable<Edge | null>>('selectedEdge') ?? selectedEdgeStore;
	const selNodesStore = getContext<Writable<Node[]>>('selectedNodes') ?? selectedNodes;
	const selectionStores: SelectionStores = {
		selectedNode: selNodeStore,
		selectedEdge: selEdgeStore,
		selectedNodes: selNodesStore
	};

	// Track viewport panning state
	let viewportMoved = false;
	let viewportMoveTimer: ReturnType<typeof setTimeout> | null = null;

	const { fitView, getNodes } = useSvelteFlow();
	const queryClient = useQueryClient();
	let containerElement: HTMLDivElement;

	/** Returns fitView padding that accounts for the options panel overlay. */
	function getFitViewPadding(): import('@xyflow/system').Padding {
		if (get(optionsPanelExpanded)) {
			return { top: 0.2, right: 0.2, bottom: 0.2, left: `${OPTIONS_PANEL_FITVIEW_PADDING_PX}px` };
		}
		return 0.2;
	}

	export function triggerFitView() {
		requestAnimationFrame(() => fitView({ padding: getFitViewPadding() }));
	}

	export function fitViewToNodes(nodeIds: string[]) {
		requestAnimationFrame(() =>
			fitView({ nodes: nodeIds.map((id) => ({ id })), padding: 0.5, duration: 300 })
		);
	}

	onMount(() => {
		const { fitView } = useSvelteFlow();
		const observer = new IntersectionObserver(
			(entries) => {
				if (entries[0].isIntersecting) {
					requestAnimationFrame(() => fitView());
					observer.disconnect();
				}
			},
			{ threshold: 0.1 }
		);
		if (containerElement) {
			observer.observe(containerElement);
		}
		return () => observer.disconnect();
	});

	// Define node types
	const nodeTypes = { Container: ContainerNode, Element: ElementNode };
	const customEdgeTypes = { custom: CustomEdge };

	// Refit viewport when panel expands/collapses (after 300ms CSS transition)
	let panelInitialized = false;
	$effect(() => {
		if ($optionsPanelExpanded !== undefined) {
			if (panelInitialized) {
				setTimeout(() => fitView({ padding: getFitViewPadding() }), 300);
			}
			panelInitialized = true;
		}
	});

	// Stores for SvelteFlow
	let nodes = writable<Node[]>([]);
	let edges = writable<Edge[]>([]);
	const nodesInitialized = useNodesInitialized();
	let pendingEdges: Edge[] = [];

	// Pipeline state
	const layoutState = createInitialState();
	let isMeasuring = $state(false);
	let animatingCollapse = $state(false);

	// --- Reactive triggers ---

	// Clear expanded bundles when bundling is toggled off
	$effect(() => {
		if (!$topologyOptions.local.bundle_edges) {
			collapseAllBundles();
		}
	});

	// Trigger loadTopologyData on topology or store changes
	const bundleEdgesStore = derived(topologyOptions, (o) => o.local.bundle_edges ?? false);
	const hideEdgeTypesStore = derived(topologyOptions, (o) =>
		(o.local.hide_edge_types ?? []).join(',')
	);

	let loadInProgress = false;
	function triggerLoad() {
		if (!topology || loadInProgress) return;
		loadInProgress = true;
		void loadTopologyData()
			.catch((err) => {
				isMeasuring = false;
				pushError(`Failed to parse topology data ${err}`);
			})
			.finally(() => {
				loadInProgress = false;
			});
	}

	let storesInitialized = false;
	collapsedContainers.subscribe(() => {
		if (storesInitialized) triggerLoad();
	});
	expandedBundles.subscribe(() => {
		if (storesInitialized) triggerLoad();
	});
	expandedPortNodeIds.subscribe(() => {
		if (storesInitialized) triggerLoad();
	});
	bundleEdgesStore.subscribe(() => {
		if (storesInitialized) triggerLoad();
	});
	hideEdgeTypesStore.subscribe(() => {
		if (storesInitialized) triggerLoad();
	});
	storesInitialized = true;

	$effect(() => {
		if (topology) triggerLoad();
	});

	// Update edges when selection or search/tag filter changes
	$effect(() => {
		const curSelectedNode = $selNodeStore;
		const curSelectedEdge = $selEdgeStore;
		const multiSelected = $selNodesStore;
		const searchHidden = $searchHiddenNodeIds;
		const tagHidden = $tagHiddenNodeIds;

		if (topology && (topology.edges || topology.nodes)) {
			const currentEdges = get(edges);
			const currentNodes = get(nodes);
			const opts = get(topologyOptions);

			updateConnectedNodes(
				curSelectedNode,
				curSelectedEdge,
				currentEdges,
				currentNodes,
				queryClient,
				topology,
				multiSelected,
				opts.local.hide_edge_types ?? []
			);
			edges.set(
				computeEdgeDisplayUpdates(
					currentEdges,
					curSelectedNode,
					curSelectedEdge,
					searchHidden,
					tagHidden
				)
			);
		}
	});

	// Add edges when nodes are ready
	$effect(() => {
		if (nodesInitialized.current && pendingEdges.length > 0) {
			edges.set(pendingEdges);
			pendingEdges = [];
		}
	});

	// --- Main layout pipeline ---

	async function loadTopologyData() {
		// Wait for containerElement to be available (bind:this fires after mount)
		if (!containerElement) {
			await tick();
			if (!containerElement) return;
		}
		const thisGeneration = ++layoutState.layoutGeneration;
		const isStale = (): boolean => thisGeneration !== layoutState.layoutGeneration;

		if (!topology || (!topology.edges && !topology.nodes)) return;

		const prep = prepareTopologyData(topology, layoutState, getInfrastructureRuleId);
		if (!prep) return;

		const { needsElk, collapsed, visibleNodes: initialVisibleNodes } = prep;
		let visibleNodes = initialVisibleNodes;

		// Helper: build positioned flow nodes (called multiple times with different useGraph)
		const makeNodes = (useGraph: boolean) =>
			sortFlowNodes(
				buildFlowNodes({
					visibleNodes,
					collapsed,
					topology,
					useGraph,
					layoutGraph: layoutState.layoutGraph,
					isNewStructure: prep.isNewStructure,
					liveNodes: getNodes(),
					infraRuleId: getInfrastructureRuleId(),
					editMode: editMode ?? false
				})
			);

		if (needsElk) {
			const elementNodeSizes = await resolveNodeSizes(
				layoutState,
				prep,
				getNodes,
				containerElement,
				isStale,
				{
					setMeasuring: (v) => {
						isMeasuring = v;
					},
					setNodes: (n) => nodes.set(n),
					setEdges: (e) => edges.set(e),
					buildMeasureNodes: () => makeNodes(false),
					waitForNodesRendered: async () => {
						// Wait until SvelteFlow has rendered nodes in the DOM.
						// nodesInitialized becomes true after adoptUserNodes processes.
						await tick();
						if (nodesInitialized.current) return;
						// Not ready yet — wait for it via $effect
						await new Promise<void>((resolve) => {
							const unsub = $effect.root(() => {
								$effect(() => {
									if (nodesInitialized.current) {
										resolve();
										unsub();
									}
								});
							});
						});
						// One more rAF to ensure DOM is painted
						await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
					}
				}
			);
			if (!elementNodeSizes) {
				isMeasuring = false;
				return;
			}

			const layoutResult = await executeLayout(
				topology,
				layoutState,
				prep,
				elementNodeSizes,
				isStale,
				getInfrastructureRuleId
			);
			if (!layoutResult) {
				isMeasuring = false;
				return;
			}
			visibleNodes = layoutResult.visibleNodes;
		}

		// Port expansion handling (no full ELK re-layout)
		const currentExpandedPorts = get(expandedPortNodeIds);
		const portsChanged = await handlePortExpansion(
			layoutState,
			currentExpandedPorts,
			containerElement,
			() => makeNodes(false),
			(n) => nodes.set(n),
			isStale,
			needsElk
		);

		// Build final nodes and edges
		layoutState.edgeHandles = layoutState.layoutGraph?.edgeHandles ?? new Map();
		const needsLayout = needsElk || portsChanged || prep.collapseChanged;
		const allNodes = makeNodes(needsLayout);

		const { flowEdges, originalsMap } = buildFlowEdges({
			elevatedEdges: prep.elevatedEdges,
			collapsed,
			elementToContainer: prep.elementToContainer,
			aggregatedEdges: prep.aggregatedEdges,
			hiddenEdgeTypes: prep.hiddenEdgeTypes,
			layoutNodes: prep.layoutNodes,
			topology,
			edgeHandles: layoutState.edgeHandles,
			layoutGraph: layoutState.layoutGraph,
			bundleEnabled: $topologyOptions.local.bundle_edges ?? false,
			currentExpandedBundles: get(expandedBundles),
			selectionStores
		});
		aggregatedEdgeOriginals.set(originalsMap);

		// Render
		const shouldAnimate =
			needsElk && !isMeasuring && layoutState.lastRenderedTopoKey !== '' && !prep.viewChanged;

		if (shouldAnimate) {
			animatingCollapse = true;
			const previousNodeIds = new Set(get(nodes).map((n) => n.id));
			const phase1Nodes = allNodes.filter((n) => previousNodeIds.has(n.id));
			nodes.set(phase1Nodes);
			edges.set(flowEdges);

			const fullNodes = [...allNodes];
			const fullEdges = [...flowEdges];
			setTimeout(() => {
				// Phase 2: disable transitions, show all nodes.
				// New nodes get opacity 0 initially, then fade in.
				animatingCollapse = false;
				const newNodeIds = new Set(
					fullNodes.filter((n) => !previousNodeIds.has(n.id)).map((n) => n.id)
				);
				if (newNodeIds.size > 0) {
					// Set new nodes with opacity 0 via style
					const fadingNodes = fullNodes.map((n) =>
						newNodeIds.has(n.id)
							? { ...n, style: 'opacity: 0; transition: opacity 0.3s ease-in-out;' }
							: n
					);
					nodes.set(fadingNodes);
					edges.set(fullEdges);
					// Next frame: set opacity back to trigger fade
					requestAnimationFrame(() => {
						nodes.set(fullNodes);
						edges.set(fullEdges);
					});
				} else {
					nodes.set(fullNodes);
					edges.set(fullEdges);
				}
			}, 350);
		} else if (!isMeasuring) {
			nodes.set(allNodes);
			edges.set(flowEdges);
		} else {
			edges.set([]);
			nodes.set(allNodes);
			pendingEdges = flowEdges;
			await tick();
			if (isStale()) {
				isMeasuring = false;
				return;
			}
			if (pendingEdges.length > 0) {
				edges.set(pendingEdges);
				pendingEdges = [];
			}
			await tick();
			await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
			if (isStale()) {
				isMeasuring = false;
				return;
			}
			isMeasuring = false;
		}

		// Post-render: cache collapsed sizes, re-run if needed
		if (containerElement && layoutState.layoutGraph) {
			const newEntries = cacheCollapsedSizes(
				containerElement,
				layoutState.layoutGraph,
				collapsed,
				layoutState.containerSizeCache
			);
			if (newEntries > 0 && !isStale()) {
				// Invalidate structureKey to force ELK re-run. Do NOT
				// invalidate baseKey — base structure hasn't changed, and
				// clearing it would delete viewSizeCache (element sizes).
				layoutState.sessionStructureKey = '';
				// Preserve fitView intent across the recursive call — the
				// re-run won't see viewChanged/topologyChanged since we
				// update the tracking keys here.
				if (prep.viewChanged || prep.topologyChanged) {
					layoutState.fitViewPending = true;
				}
				layoutState.lastRenderedTopoKey = prep.topoKey;
				layoutState.lastRenderedView = prep.currentView;
				await loadTopologyData();
				return;
			}
		}

		const isFirstRender = layoutState.lastRenderedTopoKey === '';
		layoutState.lastRenderedTopoKey = prep.topoKey;
		layoutState.lastRenderedView = prep.currentView;

		if (prep.viewChanged || prep.topologyChanged || isFirstRender || layoutState.fitViewPending) {
			layoutState.fitViewPending = false;
			// Double rAF: first lets SvelteFlow process node positions, second triggers fitView
			requestAnimationFrame(() =>
				requestAnimationFrame(() => fitView({ padding: getFitViewPadding() }))
			);
		}
	}

	// --- Event handlers ---

	let ignoreNextSelectionChange = false;

	function handleNodeClick({ node, event }: { node: Node; event: MouseEvent | TouchEvent }) {
		const isModifierClick = event instanceof MouseEvent && (event.ctrlKey || event.metaKey);
		if (isModifierClick) {
			handleModifierNodeClick(node, selectionStores);
			ignoreNextSelectionChange = true;
		} else {
			collapseAllBundles();
			selectNode(node, selectionStores);
			ignoreNextSelectionChange = true;
		}
	}

	function handleEdgeClick({ edge }: { edge: Edge; event: MouseEvent }) {
		collapseAllBundles();
		selectEdge(edge, selectionStores);
		ignoreNextSelectionChange = true;
	}

	function handleMove() {
		viewportMoved = true;
		if (viewportMoveTimer) {
			clearTimeout(viewportMoveTimer);
			viewportMoveTimer = null;
		}
	}

	function handleMoveEnd() {
		viewportMoveTimer = setTimeout(() => {
			viewportMoved = false;
		}, 50);
	}

	function syncEdgeDisplayState() {
		edges.set(
			computeEdgeDisplayUpdates(
				get(edges),
				get(selectionStores.selectedNode),
				get(selectionStores.selectedEdge),
				get(searchHiddenNodeIds),
				get(tagHiddenNodeIds)
			)
		);
	}

	function handlePaneClick() {
		if (!viewportMoved) {
			clearSelection(selectionStores);
			clearEdgeHoverState();
			syncEdgeDisplayState();
		}
		viewportMoved = false;
		if (viewportMoveTimer) {
			clearTimeout(viewportMoveTimer);
			viewportMoveTimer = null;
		}
	}

	function handleEdgePointerEnter({ edge }: { edge: Edge }) {
		setEdgeHover(edge, true, get(edges));
		syncEdgeDisplayState();
	}

	function handleEdgePointerLeave({ edge }: { edge: Edge }) {
		setEdgeHover(edge, false, get(edges));
		syncEdgeDisplayState();
	}

	function handleSelectionChange({ nodes: selNodes }: { nodes: Node[]; edges: Edge[] }) {
		if (ignoreNextSelectionChange) {
			ignoreNextSelectionChange = false;
			return;
		}
		if (selNodes.length === 0 && !viewportMoved) {
			tick().then(() => {
				// Skip if a click handler has set an active selection
				if (get(selectionStores.selectedNode) || get(selectionStores.selectedEdge)) return;
				clearSelection(selectionStores);
				clearEdgeHoverState();
				syncEdgeDisplayState();
			});
			return;
		}
		handleBoxSelect(selNodes, selectionStores);
	}

	function handleNodeDragStop({
		targetNode
	}: {
		targetNode: Node | null;
		nodes: Node[];
		event: MouseEvent | TouchEvent;
	}) {
		if (onNodeDragStop && targetNode) onNodeDragStop(targetNode);
	}

	function handleReconnect(edge: Edge, newConnection: Connection) {
		if (onReconnect) onReconnect(edge, newConnection);
	}

	// --- Collapse controls ---

	function getCollapseLevelName(level: CollapseLevel): string {
		switch (level) {
			case 1:
				return topology_levelFullyCollapsed();
			case 2:
				return topology_levelContainersExpanded();
			case 3:
				return topology_levelSubcontainersExpanded();
			case 4:
				return topology_levelFullyExpanded();
		}
	}

	let expandDisabled = $derived($collapseLevel === 4 || !!editMode);
	let collapseDisabled = $derived($collapseLevel === 1 || !!editMode);
	let collapseLevelTooltipCollapse = $derived(
		$collapseLevel > 1
			? `${common_collapse()}: ${getCollapseLevelName(($collapseLevel - 1) as CollapseLevel)}`
			: ''
	);
	let collapseLevelTooltipExpand = $derived(
		$collapseLevel < 4
			? `${common_expand()}: ${getCollapseLevelName(($collapseLevel + 1) as CollapseLevel)}`
			: ''
	);

	function handleStepCollapse() {
		if (editMode) return;
		stepCollapse(topology.nodes, containerTypes, getInfrastructureRuleId());
		setTimeout(() => fitView({ padding: getFitViewPadding(), duration: 300 }), 100);
	}

	function handleStepExpand() {
		if (editMode) return;
		const { autoCollapseIds } = stepExpand(
			topology.nodes,
			containerTypes,
			getInfrastructureRuleId()
		);
		for (const id of autoCollapseIds) layoutState.seenAutoCollapseIds.add(id);
		setTimeout(() => fitView({ padding: getFitViewPadding(), duration: 300 }), 100);
	}

	export function triggerStepExpand() {
		handleStepExpand();
	}
	export function triggerStepCollapse() {
		handleStepCollapse();
	}

	// Merge preview edges into the edge store when they change
	$effect(() => {
		const preview = $previewEdges;
		if (preview.length > 0) {
			const currentEdges = get(edges);
			const realEdges = currentEdges.filter((e) => !e.id.startsWith('preview-'));
			edges.set([...realEdges, ...preview]);
		} else {
			const currentEdges = get(edges);
			const hasPreview = currentEdges.some((e) => e.id.startsWith('preview-'));
			if (hasPreview) {
				edges.set(currentEdges.filter((e) => !e.id.startsWith('preview-')));
			}
		}
	});
</script>

<div
	class="h-full w-full overflow-hidden !p-0"
	class:card={!isEmbed}
	class:card-static={!isEmbed}
	class:collapse-transition={animatingCollapse}
	style:visibility={isMeasuring ? 'hidden' : 'visible'}
	bind:this={containerElement}
>
	<SvelteFlow
		nodes={$nodes}
		edges={$edges}
		{nodeTypes}
		edgeTypes={customEdgeTypes}
		onpaneclick={handlePaneClick}
		onedgeclick={handleEdgeClick}
		onnodeclick={handleNodeClick}
		onedgepointerenter={handleEdgePointerEnter}
		onedgepointerleave={handleEdgePointerLeave}
		onnodedragstop={readonly ? undefined : handleNodeDragStop}
		onreconnect={readonly ? undefined : handleReconnect}
		onselectionchange={handleSelectionChange}
		onmove={handleMove}
		onmoveend={handleMoveEnd}
		fitView={true}
		minZoom={0.1}
		noPanClass="nopan"
		snapGrid={[25, 25]}
		nodesDraggable={!readonly}
		nodesConnectable={!readonly}
		elementsSelectable={true}
		selectionOnDrag={true}
		selectionKey="Shift"
		panOnDrag={true}
		zoomOnScroll={true}
	>
		<Background
			variant={BackgroundVariant.Dots}
			bgColor="var(--color-topology-bg)"
			gap={50}
			size={1}
		/>

		{#if showControls}
			<TopologySidebarControls
				{editMode}
				{onToggleEditMode}
				{onOpenShortcuts}
				{onOpenSearch}
				{sidebarCollapsed}
				onStepExpand={handleStepExpand}
				onStepCollapse={handleStepCollapse}
				onFitView={() => triggerFitView()}
				{expandDisabled}
				{collapseDisabled}
				collapseLevel={$collapseLevel}
				{collapseLevelTooltipExpand}
				{collapseLevelTooltipCollapse}
			/>
		{/if}

		{#if (showMinimap !== undefined ? showMinimap : $topologyOptions.local.show_minimap) && !$isExporting}
			<MiniMap
				position="bottom-left"
				style={$optionsPanelExpanded ? `left: ${OPTIONS_PANEL_WIDTH_PX + 32}px` : ''}
				bgColor={themeStore.resolvedTheme === 'dark' ? '#1f2937' : '#ffffff'}
				nodeColor={themeStore.resolvedTheme === 'dark' ? '#6b7280' : '#9ca3af'}
				maskColor={themeStore.resolvedTheme === 'dark'
					? 'rgba(17, 24, 39, 0.7)'
					: 'rgba(243, 244, 246, 0.7)'}
				maskStrokeColor={themeStore.resolvedTheme === 'dark' ? '#374151' : '#d1d5db'}
			/>
		{/if}

		{#if showBranding}
			<a
				href="https://scanopy.net?utm_source={isEmbed
					? 'embed'
					: 'share'}&utm_medium=referral&utm_campaign=created_with"
				target="_blank"
				rel="noopener noreferrer"
				class="branding-badge"
			>
				<img src="/logos/scanopy-logo.png" alt="Scanopy" class="h-4 w-4" />
				<span>Created with Scanopy</span>
			</a>
		{/if}
	</SvelteFlow>
</div>

<style>
	.branding-badge {
		position: absolute;
		bottom: 10px;
		right: 10px;
		display: flex;
		align-items: center;
		gap: 6px;
		color: var(--color-text-muted);
		font-size: 12px;
		text-decoration: none;
		z-index: 5;
		transition: color 0.2s;
	}

	.branding-badge:hover {
		color: var(--color-text-secondary);
	}
</style>
