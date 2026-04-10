<script lang="ts">
	import {
		Handle,
		NodeResizeControl,
		Position,
		useViewport,
		type NodeProps,
		type ResizeDragEvent,
		type ResizeParams
	} from '@xyflow/svelte';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import type { Color, ColorStyle } from '$lib/shared/utils/styling';
	import { serviceDefinitions, containerTypes, views } from '$lib/shared/stores/metadata';
	import { activeView } from '../../queries';
	import {
		useTopologiesQuery,
		useUpdateNodeResizeMutation,
		selectedTopologyId,
		topologyOptions,
		selectedNode as globalSelectedNode,
		selectedEdge as globalSelectedEdge
	} from '../../queries';
	import type { TopologyNode, Topology } from '../../types/base';
	import { resolveContainerNode } from '../../resolvers';
	import { type Writable, get } from 'svelte/store';
	import { getContext } from 'svelte';
	import { editModeEnabled } from '../../state';
	import {
		connectedNodeIds,
		isExporting,
		tagHiddenNodeIds,
		searchHiddenNodeIds,
		hoveredTag,
		UNTAGGED_SENTINEL
	} from '../../interactions';
	import { collapsedContainers, toggleCollapse } from '../../collapse';
	import type { Node, Edge } from '@xyflow/svelte';
	import { createIconComponent } from '$lib/shared/utils/styling';
	import type { IconComponent } from '$lib/shared/utils/types';
	import ContainerHeader, { type SubgroupRow } from './ContainerHeader.svelte';

	// Subscribe to connectedNodeIds for reactivity
	let connectedNodes = $state(get(connectedNodeIds));
	connectedNodeIds.subscribe((value) => {
		connectedNodes = value;
	});

	// Subscribe to isExporting for reactivity
	let isExportingValue = $state(get(isExporting));
	isExporting.subscribe((value) => {
		isExportingValue = value;
	});

	// Subscribe to tag filter store for reactivity
	let hiddenNodes = $state(get(tagHiddenNodeIds));
	tagHiddenNodeIds.subscribe((value) => {
		hiddenNodes = value;
	});

	// Subscribe to search filter store for reactivity
	let searchHiddenNodes = $state(get(searchHiddenNodeIds));
	searchHiddenNodeIds.subscribe((value) => {
		searchHiddenNodes = value;
	});

	// Subscribe to tag hover state
	let currentHoveredTag = $state(get(hoveredTag));
	hoveredTag.subscribe((value) => {
		currentHoveredTag = value;
	});

	// Subscribe to collapse state
	let collapsedNodes = $state(get(collapsedContainers));
	collapsedContainers.subscribe((value) => {
		collapsedNodes = value;
	});

	let { id, data, selected, width, height }: NodeProps = $props();

	// Try to get topology from context (for share/embed pages), fallback to TanStack query
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery(() => !topologyContext);
	const updateNodeResizeMutation = useUpdateNodeResizeMutation();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext ? $topologyContext : topologiesData.find((t) => t.id === $selectedTopologyId)
	);

	// Try to get selection from context (for share/embed pages), fallback to global store
	const selectedNodeContext = getContext<Writable<Node | null> | undefined>('selectedNode');
	const selectedEdgeContext = getContext<Writable<Edge | null> | undefined>('selectedEdge');
	let selectedNode = $derived(
		selectedNodeContext ? $selectedNodeContext : $globalSelectedNode
	) as Node | null;
	let selectedEdge = $derived(
		selectedEdgeContext ? $selectedEdgeContext : $globalSelectedEdge
	) as Edge | null;

	// Fade out when another node is selected or hidden by tag/search filter
	let shouldFadeOut = $derived.by(() => {
		if (isExportingValue) return false;
		if (hiddenNodes.has(id)) return true;
		if (searchHiddenNodes.has(id)) return true;
		if (!selectedNode && !selectedEdge) return false;
		return !connectedNodes.has(id);
	});

	let nodeOpacity = $derived(shouldFadeOut ? 0.3 : 1);

	// Container metadata (drives all rendering decisions)
	let containerType = $derived(
		((data as Record<string, unknown>)?.container_type as string) ?? 'Subnet'
	);
	let containerMeta = $derived(containerTypes.getMetadata(containerType));
	let titleStyle = $derived(containerMeta.title_style);
	let isSubcontainer = $derived(containerMeta.is_subcontainer);
	let isCollapsible = $derived(containerMeta.is_collapsible);
	let hasBorder = $derived(containerMeta.has_border);
	let fillIcon = $derived(containerMeta.fill_icon ?? false);

	// Resolve container data
	let resolved = $derived(
		topology ? resolveContainerNode(id, data as TopologyNode, topology) : null
	);
	// TODO(views): subnet is used for tag hover. When containers represent other
	// entity types, refactor to use a generic entity tags lookup instead.
	let subnet = $derived(resolved?.subnet);

	let currentView = $state(get(activeView));
	activeView.subscribe((v) => (currentView = v));

	let elementLabel = $derived(
		(views.getMetadata(currentView) as { element_label?: string } | undefined)?.element_label ??
			'hosts'
	);

	let isCollapsed = $derived(collapsedNodes.has(id));
	let childCount = $derived(((data as Record<string, unknown>)?.childCount as number) ?? 0);
	let subgroupSummaries = $derived(
		((data as Record<string, unknown>)?.subgroupSummaries as Array<{
			groupId: string;
			childCount: number;
		}>) ?? []
	);

	let nodeStyle = $derived.by(() => {
		const parts = [
			width != null ? `width: ${width}px` : '',
			height != null ? `height: ${height}px` : ''
		].filter(Boolean);
		return parts.length > 0 ? parts.join('; ') + ';' : '';
	});

	// Title text: from node header (set by backend graph builder)
	let headerText = $derived((data as TopologyNode).header ?? '');

	// Icon and color: from node fields, falling back to ContainerType fixture icon when fillIcon
	let nodeIcon = $derived((data as Record<string, unknown>)?.icon as string | undefined);
	let nodeColor = $derived((data as Record<string, unknown>)?.color as string | undefined);
	let iconComponent: IconComponent | null = $derived.by(() => {
		if (nodeIcon) return createIconComponent(nodeIcon);
		if (fillIcon) return containerTypes.getIconComponent(containerType);
		return null;
	});

	// Service logo: from associated_service_definition (for Virtualizer/Stack subcontainers)
	let serviceDefId = $derived(
		(data as Record<string, unknown>)?.associated_service_definition as string | undefined
	);
	let logoComponent: IconComponent | null = $derived(
		serviceDefId ? serviceDefinitions.getIconComponent(serviceDefId) : null
	);
	let colorHelper: ColorStyle = $derived(
		nodeColor
			? createColorHelper(nodeColor as Parameters<typeof createColorHelper>[0])
			: createColorHelper('Gray')
	);

	// Element rule header + tag pills (for subcontainers created by element rules)
	let elementRuleId = $derived(
		(data as Record<string, unknown>)?.element_rule_id as string | undefined
	);
	let elementRule = $derived.by(() => {
		if (!elementRuleId) return null;
		const rules = $topologyOptions.request.element_rules ?? [];
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		return (rules as any[]).find((r: { id: string }) => r.id === elementRuleId) ?? null;
	});

	let groupLabels = $derived.by((): { label: string; color: Color }[] => {
		if (!elementRule?.rule) return [];
		const rule = elementRule.rule;
		if (typeof rule === 'string') return [];
		if ('ByServiceCategory' in rule) {
			return (rule.ByServiceCategory.categories ?? []).map((cat: string) => {
				const svc = topology?.services?.find(
					(s) => serviceDefinitions.getCategory(s.service_definition) === cat
				);
				const color = svc
					? serviceDefinitions.getColorHelper(svc.service_definition).color
					: ('Gray' as Color);
				return { label: cat, color };
			});
		}
		if ('ByTag' in rule) {
			return (rule.ByTag.tag_ids ?? []).map((tagId: string) => {
				const tag = topology?.entity_tags?.find((t) => t.id === tagId);
				return {
					label: tag?.name ?? tagId,
					color: (tag?.color as Color) ?? 'Gray'
				};
			});
		}
		return [];
	});

	// TODO(views): tag hover highlight is subnet-specific. When containers
	// represent other entity types, refactor to use generic entity tags.
	let tagHoverRingStyle = $derived.by(() => {
		if (!currentHoveredTag || currentHoveredTag.entityType !== 'subnet' || !subnet) return '';
		const { tagId, color } = currentHoveredTag;
		const isUntagged = subnet.tags.length === 0;
		const hasTag = tagId === UNTAGGED_SENTINEL ? isUntagged : subnet.tags.includes(tagId);
		if (!hasTag) return '';
		const ch = createColorHelper(color as Parameters<typeof createColorHelper>[0]);
		return `box-shadow: 0 0 0 3px ${ch.rgb};`;
	});

	// Pre-compute resolved subgroup rows for collapsed-root variant
	let resolvedSubgroups: SubgroupRow[] = $derived.by(() => {
		if (!isSubcontainer && isCollapsed && subgroupSummaries.length > 0) {
			return subgroupSummaries.map((summary) => {
				const groupNode = topology?.nodes.find((n) => n.id === summary.groupId);
				const sHeader = groupNode?.header ?? '';
				const ruleId = (groupNode as Record<string, unknown>)?.element_rule_id as
					| string
					| undefined;
				const rule = ruleId
					? ($topologyOptions.request.element_rules ?? []).find(
							(r) => (r as { id: string }).id === ruleId
						)
					: null;
				const groupServiceDef = (groupNode as Record<string, unknown>)
					?.associated_service_definition as string | undefined;
				const groupLogoComponent = groupServiceDef
					? serviceDefinitions.getIconComponent(groupServiceDef)
					: null;

				const labels: { label: string; color: Color }[] = (() => {
					if (!rule) return [];
					const r = (rule as { rule: Record<string, unknown> }).rule;
					if (typeof r === 'string') return [];
					if ('ByServiceCategory' in r) {
						return ((r.ByServiceCategory as { categories?: string[] }).categories ?? []).map(
							(cat) => {
								const svc = topology?.services?.find(
									(s) => serviceDefinitions.getCategory(s.service_definition) === cat
								);
								return {
									label: cat,
									color: (svc
										? serviceDefinitions.getColorHelper(svc.service_definition).color
										: 'Gray') as Color
								};
							}
						);
					}
					if ('ByTag' in r) {
						return ((r.ByTag as { tag_ids?: string[] }).tag_ids ?? []).map((tagId) => {
							const tag = topology?.entity_tags?.find((t) => t.id === tagId);
							return { label: tag?.name ?? tagId, color: (tag?.color ?? 'Gray') as Color };
						});
					}
					return [];
				})();

				return {
					logoComponent: groupLogoComponent,
					headerText: sHeader,
					labels,
					childCount: summary.childCount
				};
			});
		}
		return [];
	});

	const viewport = useViewport();
	let resizeHandleZoomLevel = $derived(viewport.current.zoom > 0.5);

	const grayColorHelper = createColorHelper('Gray');

	// Track pointer position to distinguish clicks from drags
	let pointerDownPos: { x: number; y: number } | null = null;

	function handleChevronClick(event: MouseEvent | KeyboardEvent) {
		event.stopPropagation();
		toggleCollapse(id, topology?.nodes);
	}

	async function onResize(event: ResizeDragEvent, params: ResizeParams) {
		if (!topology) return;
		let node = topology.nodes.find((n) => n.id == id);
		if (node && params.width && params.height) {
			let roundedWidth = Math.round(params.width / 25) * 25;
			let roundedHeight = Math.round(params.height / 25) * 25;
			let roundedX = Math.round(params.x / 25) * 25;
			let roundedY = Math.round(params.y / 25) * 25;

			node.size.x = roundedWidth;
			node.size.y = roundedHeight;
			node.position.x = roundedX;
			node.position.y = roundedY;

			await updateNodeResizeMutation.mutateAsync({
				topologyId: topology.id,
				networkId: topology.network_id,
				nodeId: node.id,
				size: { x: roundedWidth, y: roundedHeight },
				position: { x: roundedX, y: roundedY }
			});
		}
	}
</script>

<!-- svelte-ignore a11y_no_static_element_interactions -->
<div
	class="relative"
	style="{nodeStyle} opacity: {nodeOpacity}; transition: opacity 0.2s ease-in-out;{isSubcontainer
		? ' cursor: pointer;'
		: ''}"
	onpointerdown={isSubcontainer
		? (e) => {
				pointerDownPos = { x: e.clientX, y: e.clientY };
			}
		: undefined}
	onpointerup={isSubcontainer
		? (e) => {
				if (pointerDownPos) {
					const dx = Math.abs(e.clientX - pointerDownPos.x);
					const dy = Math.abs(e.clientY - pointerDownPos.y);
					if (dx < 5 && dy < 5) {
						e.stopPropagation();
						handleChevronClick(e);
					}
				}
				pointerDownPos = null;
			}
		: undefined}
>
	<!-- TITLE: External (card/pill above container) -->
	{#if titleStyle === 'External' && (headerText || isCollapsible)}
		<ContainerHeader
			variant="external"
			{isCollapsed}
			{isCollapsible}
			{headerText}
			{iconComponent}
			{logoComponent}
			{fillIcon}
			{colorHelper}
			{groupLabels}
			{childCount}
			{elementLabel}
			onToggleCollapse={handleChevronClick}
		/>
	{/if}

	<!-- TITLE: Inline (inside container top padding) -->
	{#if titleStyle === 'Inline' && !isCollapsed && (headerText || groupLabels.length > 0)}
		<ContainerHeader
			variant="inline"
			{isCollapsed}
			{isCollapsible}
			{headerText}
			{iconComponent}
			{logoComponent}
			{fillIcon}
			{colorHelper}
			{groupLabels}
			{childCount}
			{elementLabel}
			onToggleCollapse={handleChevronClick}
		/>
	{/if}

	<!-- COLLAPSED STATE -->
	{#if isCollapsed}
		{#if isSubcontainer}
			<ContainerHeader
				variant="collapsed-sub"
				{isCollapsed}
				{isCollapsible}
				{headerText}
				{iconComponent}
				{logoComponent}
				{fillIcon}
				{colorHelper}
				{groupLabels}
				{childCount}
				{elementLabel}
				onToggleCollapse={handleChevronClick}
			/>
		{:else}
			<ContainerHeader
				variant="collapsed-root"
				{isCollapsed}
				{isCollapsible}
				{headerText}
				{iconComponent}
				{logoComponent}
				{fillIcon}
				{colorHelper}
				{groupLabels}
				{childCount}
				{elementLabel}
				onToggleCollapse={handleChevronClick}
				subgroupSummaries={resolvedSubgroups}
				{tagHoverRingStyle}
			/>
		{/if}
	{:else}
		<!-- EXPANDED STATE -->
		{#if isSubcontainer}
			{#if hasBorder}
				<div
					class="rounded-lg border border-dashed border-gray-300 transition-all duration-200 dark:border-gray-600"
					style="background: var(--color-topology-subgroup-bg); width: 100%; height: 100%; position: relative; overflow: hidden;"
				></div>
			{/if}
		{:else}
			<div
				class="rounded-xl text-center text-sm font-semibold shadow-lg transition-all duration-200"
				style="background: var(--color-topology-node-bg); width: 100%; height: 100%; position: relative; overflow: hidden; transition: box-shadow 0.15s ease-in-out; border-top: 2px solid {colorHelper.rgb}; {tagHoverRingStyle}"
			></div>

			{#if resizeHandleZoomLevel && $editModeEnabled && !$topologyOptions.local.hide_resize_handles}
				<NodeResizeControl
					position="bottom-right"
					onResizeEnd={onResize}
					style="z-index: 100; border: none; width: 20px; height: 20px;"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="20"
						height="20"
						viewBox="0 0 20 20"
						style="position: absolute; right: 10px; bottom: 10px;"
					>
						<path
							d="M20 7.5 L20 20 L7.5 20 Z"
							fill={selected ? colorHelper.rgb : grayColorHelper.rgb}
							style="transition: fill 200ms ease-in-out;"
						/>
						<line x1="11.667" y1="20" x2="20" y2="11.667" stroke="#374151" stroke-width="1" />
						<line x1="16.333" y1="20" x2="20" y2="16.333" stroke="#374151" stroke-width="1" />
					</svg>
				</NodeResizeControl>
				<NodeResizeControl
					position="top-left"
					onResizeEnd={onResize}
					style="z-index: 100; border: none; width: 20px; height: 20px;"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="20"
						height="20"
						viewBox="0 0 20 20"
						style="position: absolute; left: 10px; top: 10px;"
					>
						<path
							d="M0 12.5 L0 0 L12.5 0 Z"
							fill={selected ? colorHelper.rgb : grayColorHelper.rgb}
							style="transition: fill 200ms ease-in-out;"
						/>
						<line x1="8.333" y1="0" x2="0" y2="8.333" stroke="#374151" stroke-width="1" />
						<line x1="3.667" y1="0" x2="0" y2="3.667" stroke="#374151" stroke-width="1" />
					</svg>
				</NodeResizeControl>
				<NodeResizeControl
					position="top-right"
					onResizeEnd={onResize}
					style="z-index: 100; border: none; width: 20px; height: 20px;"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="20"
						height="20"
						viewBox="0 0 20 20"
						style="position: absolute; right: 10px; top: 10px;"
					>
						<path
							d="M7.5 0 L20 0 L20 12.5 Z"
							fill={selected ? colorHelper.rgb : grayColorHelper.rgb}
							style="transition: fill 200ms ease-in-out;"
						/>
						<line x1="11.667" y1="0" x2="20" y2="8.333" stroke="#374151" stroke-width="1" />
						<line x1="16.333" y1="0" x2="20" y2="3.667" stroke="#374151" stroke-width="1" />
					</svg>
				</NodeResizeControl>
				<NodeResizeControl
					position="bottom-left"
					onResizeEnd={onResize}
					style="z-index: 100; border: none; width: 20px; height: 20px;"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="20"
						height="20"
						viewBox="0 0 20 20"
						style="position: absolute; left: 10px; bottom: 10px;"
					>
						<path
							d="M0 7.5 L12.5 20 L0 20 Z"
							fill={selected ? colorHelper.rgb : grayColorHelper.rgb}
							style="transition: fill 200ms ease-in-out;"
						/>
						<line x1="0" y1="11.667" x2="8.333" y2="20" stroke="#374151" stroke-width="1" />
						<line x1="0" y1="16.333" x2="3.667" y2="20" stroke="#374151" stroke-width="1" />
					</svg>
				</NodeResizeControl>
			{/if}
		{/if}
	{/if}
</div>

<Handle type="target" id="Top" position={Position.Top} style="opacity: 0" />
<Handle type="target" id="Right" position={Position.Right} style="opacity: 0" />
<Handle type="target" id="Bottom" position={Position.Bottom} style="opacity: 0" />
<Handle type="target" id="Left" position={Position.Left} style="opacity: 0" />

<Handle type="source" id="Top" position={Position.Top} style="opacity: 0" />
<Handle type="source" id="Right" position={Position.Right} style="opacity: 0" />
<Handle type="source" id="Bottom" position={Position.Bottom} style="opacity: 0" />
<Handle type="source" id="Left" position={Position.Left} style="opacity: 0" />

<style>
	div {
		word-wrap: break-word;
		overflow-wrap: break-word;
	}

	:global(.svelte-flow__resize-control) {
		background-color: transparent !important;
	}
</style>
