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
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import type { Color } from '$lib/shared/utils/styling';
	import { subnetTypes, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { isContainerSubnet } from '$lib/features/subnets/queries';
	import { topology_hostsCount } from '$lib/paraglide/messages';
	import {
		useTopologiesQuery,
		useUpdateNodeResizeMutation,
		selectedTopologyId,
		topologyOptions,
		selectedNode as globalSelectedNode,
		selectedEdge as globalSelectedEdge
	} from '../../queries';
	import type { TopologyNode, ContainerRenderData, Topology } from '../../types/base';
	import { resolveContainerNode } from '../../resolvers';
	import { type Writable, get } from 'svelte/store';
	import { getContext } from 'svelte';
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

	// Calculate if this node should fade out when another node is selected or hidden by tag filter
	let shouldFadeOut = $derived.by(() => {
		if (isExportingValue) return false;

		// Tag filter: fade if this subnet is hidden
		if (hiddenNodes.has(id)) {
			return true;
		}

		// Search filter: fade if this subnet is hidden by search
		if (searchHiddenNodes.has(id)) {
			return true;
		}

		// Selection-based fading
		if (!selectedNode && !selectedEdge) return false;
		// Check if this node is in the connected set
		return !connectedNodes.has(id);
	});

	let nodeOpacity = $derived(shouldFadeOut ? 0.3 : 1);

	// Check if this subnet should be highlighted by tag hover
	let tagHoverRingStyle = $derived.by(() => {
		if (!currentHoveredTag || currentHoveredTag.entityType !== 'subnet' || !subnet) return '';
		const { tagId, color } = currentHoveredTag;
		const isUntagged = subnet.tags.length === 0;
		const hasTag = tagId === UNTAGGED_SENTINEL ? isUntagged : subnet.tags.includes(tagId);
		if (!hasTag) return '';
		const colorHelper = createColorHelper(color as Parameters<typeof createColorHelper>[0]);
		return `box-shadow: 0 0 0 3px ${colorHelper.rgb};`;
	});

	let containerType = $derived(
		((data as Record<string, unknown>)?.container_type as string) ?? 'Subnet'
	);
	let isSubgroup = $derived(
		containerType === 'TagGroup' || containerType === 'ServiceCategoryGroup'
	);

	let resolved = $derived(
		topology ? resolveContainerNode(id, data as TopologyNode, topology) : null
	);
	let subnet = $derived(resolved?.subnet);

	let isCollapsed = $derived(collapsedNodes.has(id));
	let childCount = $derived(((data as Record<string, unknown>)?.childCount as number) ?? 0);
	let subgroupSummaries = $derived(
		((data as Record<string, unknown>)?.subgroupSummaries as Array<{
			groupId: string;
			childCount: number;
		}>) ?? []
	);

	let nodeStyle = $derived(`width: ${width}px; height: ${height}px;`);

	// Header for sub-group containers comes from node header
	let groupHeader = $derived((data as TopologyNode).header ?? '');

	// Resolve element rule for sub-group containers to render Tag pills
	let elementRuleId = $derived(
		(data as Record<string, unknown>)?.element_rule_id as string | undefined
	);
	let elementRule = $derived.by(() => {
		if (!elementRuleId) return null;
		const rules = $topologyOptions.request.element_rules ?? [];
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		return (rules as any[]).find((r: { id: string }) => r.id === elementRuleId) ?? null;
	});

	// Build label pills from the element rule
	let groupLabels = $derived.by((): { label: string; color: Color }[] => {
		if (!elementRule?.rule) return [];
		const rule = elementRule.rule;
		if ('ByServiceCategory' in rule && topology) {
			return (rule.ByServiceCategory.categories ?? []).map((cat: string) => {
				// Find a service with this category to get its color
				const svc = topology!.services?.find(
					(s) => serviceDefinitions.getCategory(s.service_definition) === cat
				);
				const color = svc
					? serviceDefinitions.getColorHelper(svc.service_definition).color
					: ('Gray' as Color);
				return { label: cat, color };
			});
		}
		if ('ByTag' in rule && topology) {
			return (rule.ByTag.tag_ids ?? []).map((tagId: string) => {
				const tag = topology!.entity_tags?.find((t) => t.id === tagId);
				return {
					label: tag?.name ?? tagId,
					color: (tag?.color as Color) ?? 'Gray'
				};
			});
		}
		return [];
	});

	const viewport = useViewport();
	let resizeHandleZoomLevel = $derived(viewport.current.zoom > 0.5);

	const grayColorHelper = createColorHelper('Gray');

	let subnetRenderData: ContainerRenderData | null = $derived(
		subnet
			? (() => {
					const subnetColorHelper = subnetTypes.getColorHelper(subnet.subnet_type);
					let IconComponent = subnetTypes.getIconComponent(subnet.subnet_type);
					let cidr = subnet.cidr;

					let showLabel = subnetTypes.getMetadata(subnet.subnet_type).show_label;
					let nameOrType =
						subnet.name != subnet.cidr
							? subnet.name
							: showLabel
								? subnetTypes.getName(subnet.subnet_type)
								: '';
					let header = (data as TopologyNode).header;
					let label = header
						? header
						: nameOrType +
							(isContainerSubnet(subnet) ? '' : (nameOrType ? ': ' : '') + subnet.cidr);

					return {
						headerText: label,
						colorHelper: subnetColorHelper,
						cidr,
						IconComponent
					} as ContainerRenderData;
				})()
			: null
	);
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
			// Round to grid
			let roundedWidth = Math.round(params.width / 25) * 25;
			let roundedHeight = Math.round(params.height / 25) * 25;
			let roundedX = Math.round(params.x / 25) * 25;
			let roundedY = Math.round(params.y / 25) * 25;

			// Update local state for immediate feedback
			node.size.x = roundedWidth;
			node.size.y = roundedHeight;
			node.position.x = roundedX;
			node.position.y = roundedY;

			// Send lightweight update to server (fixes HTTP 413 for large topologies)
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

{#if isSubgroup}
	<!-- Sub-group container (TagGroup / ServiceCategoryGroup) -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div
		class="relative"
		style="{nodeStyle} opacity: {nodeOpacity}; transition: opacity 0.2s ease-in-out; cursor: pointer;"
		onpointerdown={(e) => {
			pointerDownPos = { x: e.clientX, y: e.clientY };
		}}
		onpointerup={(e) => {
			if (pointerDownPos) {
				const dx = Math.abs(e.clientX - pointerDownPos.x);
				const dy = Math.abs(e.clientY - pointerDownPos.y);
				if (dx < 5 && dy < 5) {
					e.stopPropagation();
					handleChevronClick(e);
				}
			}
			pointerDownPos = null;
		}}
	>
		{#if isCollapsed}
			<!-- Collapsed subgroup: compact header with same visual style as expanded -->
			<div
				class="nopan nodrag flex items-center gap-1 rounded-lg border border-dashed border-gray-300 px-3 py-2 dark:border-gray-600"
				style="background: var(--color-topology-subgroup-bg); width: 100%; height: 100%;"
			>
				<ChevronRight class="text-secondary h-3.5 w-3.5 flex-shrink-0" />
				{#if groupHeader}
					<span class="text-tertiary whitespace-nowrap text-xs font-medium">
						{groupHeader}{groupLabels.length > 0 ? ':' : ''}
					</span>
				{/if}
				{#each groupLabels as pill (pill.label)}
					<Tag label={pill.label} color={pill.color} />
				{/each}
				<span class="text-tertiary whitespace-nowrap text-xs">
					({topology_hostsCount({ count: childCount })})
				</span>
			</div>
		{:else}
			{#if groupHeader || groupLabels.length > 0}
				<div
					class="nopan nodrag text-secondary z-100 absolute left-2 top-1 flex items-center gap-1 rounded-t px-2 py-0.5"
				>
					<ChevronDown class="text-secondary h-3.5 w-3.5 flex-shrink-0" />
					{#if groupHeader}
						<span class="text-tertiary whitespace-nowrap text-xs font-medium">
							{groupHeader}{groupLabels.length > 0 ? ':' : ''}
						</span>
					{/if}
					{#each groupLabels as pill (pill.label)}
						<Tag label={pill.label} color={pill.color} />
					{/each}
				</div>
			{/if}

			<div
				class="rounded-lg border border-dashed border-gray-300 transition-all duration-200 dark:border-gray-600"
				style="background: var(--color-topology-subgroup-bg); width: 100%; height: 100%; position: relative; overflow: hidden;"
			></div>
		{/if}
	</div>
{:else if subnetRenderData}
	<div
		class="relative"
		style="{nodeStyle} opacity: {nodeOpacity}; transition: opacity 0.2s ease-in-out;"
	>
		<!-- External label in upper left corner -->
		{#if subnetRenderData.cidr || subnetRenderData.headerText}
			<div
				class="nopan nodrag card text-secondary z-100 absolute -top-10 left-0 flex cursor-pointer items-center gap-1 px-2 py-1 shadow-lg backdrop-blur-sm"
				role="button"
				tabindex={-1}
				onclick={handleChevronClick}
				onkeydown={(e) => {
					if (e.key === 'Enter' || e.key === ' ') handleChevronClick(e);
				}}
				onmousedown={(e) => e.stopPropagation()}
				onpointerdown={(e) => e.stopPropagation()}
			>
				<!-- Collapse chevron -->
				{#if isCollapsed}
					<ChevronRight class="text-secondary h-4 w-4 flex-shrink-0" />
				{:else}
					<ChevronDown class="text-secondary h-4 w-4 flex-shrink-0" />
				{/if}

				<!-- Icon -->
				{#if subnetRenderData.IconComponent}
					<!-- eslint-disable-next-line @typescript-eslint/no-explicit-any -->
					<subnetRenderData.IconComponent class={`h-5 w-5 ${subnetRenderData.colorHelper.icon}`} />
				{/if}

				<!-- Label -->
				<span class="text-s text-secondary whitespace-nowrap font-medium">
					{subnetRenderData.headerText || subnetRenderData.cidr}
				</span>
			</div>
		{/if}

		<!-- Main container -->
		<div
			class="rounded-xl text-center text-sm font-semibold shadow-lg transition-all duration-200"
			class:border-dashed={isCollapsed}
			class:border={isCollapsed}
			class:border-gray-400={isCollapsed}
			class:dark:border-gray-500={isCollapsed}
			style="background: var(--color-topology-node-bg); width: 100%; height: 100%; position: relative; overflow: {isCollapsed
				? 'visible'
				: 'hidden'}; transition: box-shadow 0.15s ease-in-out; {tagHoverRingStyle}"
		>
			{#if isCollapsed}
				<!-- Collapsed summary -->
				<div class="flex min-w-48 flex-col items-center gap-2 px-6 py-4">
					<span class="text-secondary text-base font-medium">
						{topology_hostsCount({ count: childCount })}
					</span>
					{#each subgroupSummaries as summary (summary.groupId)}
						{@const groupNode = topology?.nodes.find((n) => n.id === summary.groupId)}
						{@const header = groupNode?.header ?? ''}
						{@const ruleId = (groupNode as Record<string, unknown>)?.element_rule_id as
							| string
							| undefined}
						{@const rule = ruleId
							? ($topologyOptions.request.element_rules ?? []).find(
									(r) => (r as { id: string }).id === ruleId
								)
							: null}
						{@const labels = (() => {
							if (!rule) return [];
							const r = (rule as { rule: Record<string, unknown> }).rule;
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
						})()}
						<div class="flex items-center gap-1 rounded-md border border-dashed border-gray-300 px-2 py-1 dark:border-gray-600" style="background: var(--color-topology-subgroup-bg);">
							{#if header}
								<span class="text-tertiary text-xs">{header}{labels.length > 0 ? ':' : ''}</span>
							{/if}
							{#each labels as pill (pill.label)}
								<Tag label={pill.label} color={pill.color} />
							{/each}
							<span class="text-tertiary text-xs"
								>({topology_hostsCount({ count: summary.childCount })})</span
							>
						</div>
					{/each}
				</div>
			{/if}
		</div>

		{#if resizeHandleZoomLevel && !$topologyOptions.local.hide_resize_handles && !isCollapsed}
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
						fill={selected ? subnetRenderData.colorHelper.rgb : grayColorHelper.rgb}
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
						fill={selected ? subnetRenderData.colorHelper.rgb : grayColorHelper.rgb}
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
						fill={selected ? subnetRenderData.colorHelper.rgb : grayColorHelper.rgb}
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
						fill={selected ? subnetRenderData.colorHelper.rgb : grayColorHelper.rgb}
						style="transition: fill 200ms ease-in-out;"
					/>
					<line x1="0" y1="11.667" x2="8.333" y2="20" stroke="#374151" stroke-width="1" />
					<line x1="0" y1="16.333" x2="3.667" y2="20" stroke="#374151" stroke-width="1" />
				</svg>
			</NodeResizeControl>
		{/if}
	</div>
{/if}
<!-- Sub-group containers don't get handles; subnet containers do -->
<Handle type="target" id="Top" position={Position.Top} style="opacity: 0" />
<Handle type="target" id="Right" position={Position.Right} style="opacity: 0" />
<Handle type="target" id="Bottom" position={Position.Bottom} style="opacity: 0" />
<Handle type="target" id="Left" position={Position.Left} style="opacity: 0" />

<Handle type="source" id="Top" position={Position.Top} style="opacity: 0" />
<Handle type="source" id="Right" position={Position.Right} style="opacity: 0" />
<Handle type="source" id="Bottom" position={Position.Bottom} style="opacity: 0" />
<Handle type="source" id="Left" position={Position.Left} style="opacity: 0" />

<style>
	/* Ensure proper text wrapping and overflow handling */
	div {
		word-wrap: break-word;
		overflow-wrap: break-word;
	}

	:global(.svelte-flow__resize-control) {
		background-color: transparent !important;
	}
</style>
