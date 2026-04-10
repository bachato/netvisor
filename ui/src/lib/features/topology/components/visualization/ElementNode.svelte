<script lang="ts">
	import { Handle, Position, type NodeProps } from '@xyflow/svelte';
	import { concepts, entities, serviceDefinitions, views } from '$lib/shared/stores/metadata';
	import {
		selectedEdge as globalSelectedEdge,
		selectedNode as globalSelectedNode,
		selectedNodes as globalSelectedNodes,
		selectedTopologyId,
		topologyOptions,
		activeView,
		useTopologiesQuery
	} from '../../queries';
	import type { TopologyNode, ElementRenderData, Topology } from '../../types/base';
	import { resolveElementNode } from '../../resolvers';
	import { type Writable, get } from 'svelte/store';
	import { formatPort } from '$lib/shared/utils/formatting';
	import {
		connectedNodeIds,
		isExporting,
		newNodeIds,
		tagHiddenNodeIds,
		tagHiddenServiceIds,
		searchHiddenNodeIds,
		hoveredTag,
		hoveredServiceCategory,
		expandedPortNodeIds,
		toggleExpandedPorts,
		UNTAGGED_SENTINEL
	} from '../../interactions';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import { getContext } from 'svelte';
	import type { Port } from '$lib/features/hosts/types/base';
	import type { Node, Edge } from '@xyflow/svelte';
	import { topology_hideOpenPorts, topology_openPortsSummary } from '$lib/paraglide/messages';

	let { id, data, width }: NodeProps = $props();

	// Subscribe to isExporting for reactivity
	let isExportingValue = $state(get(isExporting));
	isExporting.subscribe((value) => {
		isExportingValue = value;
	});

	// Subscribe to tag filter stores for reactivity
	let hiddenNodes = $state(get(tagHiddenNodeIds));
	tagHiddenNodeIds.subscribe((value) => {
		hiddenNodes = value;
	});

	let hiddenServices = $state(get(tagHiddenServiceIds));
	tagHiddenServiceIds.subscribe((value) => {
		hiddenServices = value;
	});

	// Subscribe to search filter store for reactivity
	let searchHiddenNodes = $state(get(searchHiddenNodeIds));
	searchHiddenNodeIds.subscribe((value) => {
		searchHiddenNodes = value;
	});

	// Subscribe to new node highlight store
	let highlightedNewNodes = $state(get(newNodeIds));
	newNodeIds.subscribe((value) => {
		highlightedNewNodes = value;
	});

	// Subscribe to multi-select store
	let multiSelectedNodes = $state(get(globalSelectedNodes));
	globalSelectedNodes.subscribe((value) => {
		multiSelectedNodes = value;
	});

	// Subscribe to tag hover state
	let currentHoveredTag = $state(get(hoveredTag));
	hoveredTag.subscribe((value) => {
		currentHoveredTag = value;
	});

	// Subscribe to service category hover state
	let currentHoveredCategory = $state(get(hoveredServiceCategory));
	hoveredServiceCategory.subscribe((value) => {
		currentHoveredCategory = value;
	});

	// Try to get topology from context (for share/embed pages), fallback to TanStack query
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery(() => !topologyContext);
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

	let resolved = $derived(topology ? resolveElementNode(id, data as TopologyNode, topology) : null);
	let host = $derived(resolved?.host);
	let servicesForHost = $derived(resolved?.services ?? []);
	let iface = $derived(resolved?.iface ?? null);

	let effectiveWidth = $derived(width ? width : 0);

	// Per-card toggle for expanding hidden open ports (lifted to topology-level store for re-layout)
	let expandedOpenPorts = $derived($expandedPortNodeIds.has(id));

	// All services for this host (tag-hidden services stay in list to preserve card height)
	let visibleServicesForHost = $derived(servicesForHost);

	// Reactively subscribe to the container subnet store
	let isContainerSubnetValue = $derived(
		iface ? topology?.subnets.find((s) => s.id == iface.subnet_id)?.cidr == '0.0.0.0/0' : false
	);

	function getPortById(portId: string): Port | null {
		return topology?.ports.find((p) => p.id == portId) ?? null;
	}

	// Compute nodeRenderData reactively
	let nodeRenderData: ElementRenderData | null = $derived.by(() => {
		if (!resolved) return null;
		return (() => {
			const elementType = resolved.elementType ?? 'Interface';

			// Service elements: simpler rendering — single service with host name.
			// Intentionally does NOT read $topologyOptions here — category/tag
			// fading is handled by shouldFadeOut via hiddenServices store, so
			// category toggles don't trigger nodeRenderData recomputation.
			if (elementType === 'Service') {
				const service = resolved.services[0];
				return {
					elementType,
					footerText: null,
					services: service ? [service] : [],
					hiddenOpenPorts: [],
					headerText: host?.name ?? null,
					bodyText: service ? null : 'Unknown Service',
					showServices: !!service,
					isVirtualized: false,
					isCategoryHidden: false,
					ip_address_id: id
				} as ElementRenderData;
			}

			// Host elements: show host name with services
			if (elementType === 'Host') {
				if (!host || !resolved.hostId) return null;

				const hiddenCategories =
					(($topologyOptions.request.hide_service_categories ?? {}) as Record<string, string[]>)[
						$activeView
					] ?? [];

				type CategoryType = (typeof hiddenCategories)[number];
				// Services visible in card: exclude OpenPorts hidden by category or tag
				// (non-OpenPorts stay and render faded when hidden)
				const servicesOnHost = visibleServicesForHost.filter((s) => {
					const category = serviceDefinitions.getCategory(s.service_definition);
					if (
						category === 'OpenPorts' &&
						(hiddenCategories.includes(category as CategoryType) || hiddenServices.has(s.id))
					)
						return false;
					return true;
				});

				// OpenPorts hidden by category OR tag → collapsed indicator
				const hiddenOpenPorts = visibleServicesForHost.filter((s) => {
					const category = serviceDefinitions.getCategory(s.service_definition);
					if (category !== 'OpenPorts') return false;
					return hiddenCategories.includes(category as CategoryType) || hiddenServices.has(s.id);
				});

				const showServices = servicesOnHost.length !== 0 || hiddenOpenPorts.length !== 0;

				const hostLabel = (data as TopologyNode).header ?? (host.name || host.hostname || null);

				return {
					elementType,
					footerText: null,
					services: servicesOnHost,
					hiddenOpenPorts,
					headerText: hostLabel,
					bodyText: showServices ? null : hostLabel,
					showServices,
					isVirtualized: host.virtualization !== null,
					ip_address_id: id
				} as ElementRenderData;
			}

			// Port elements: show port name + status/MAC info
			if (elementType === 'Interface') {
				const ifEntryId =
					'interface_id' in (data as Record<string, unknown>)
						? ((data as Record<string, unknown>).interface_id as string)
						: undefined;
				const iface = ifEntryId ? topology?.interfaces.find((e) => e.id === ifEntryId) : undefined;

				let speed: string | null = null;
				if (iface?.speed_bps) {
					const bps = iface?.speed_bps;
					if (bps >= 1_000_000_000) speed = `${(bps / 1_000_000_000).toFixed(0)}G`;
					else if (bps >= 1_000_000) speed = `${(bps / 1_000_000).toFixed(0)}M`;
					else speed = `${bps} bps`;
				}

				return {
					elementType,
					headerText: (data as TopologyNode).header ?? null,
					footerText: null,
					bodyText: null,
					showServices: false,
					isVirtualized: false,
					services: [],
					hiddenOpenPorts: [],
					ip_address_id: '',
					portStatus: iface
						? {
								operStatus: iface.oper_status,
								speed,
								macAddress: iface.mac_address ?? null
							}
						: undefined
				} as ElementRenderData;
			}

			// Interface elements: existing behavior
			if (!host || !resolved.hostId) return null;

			const hiddenCategories =
				(($topologyOptions.request.hide_service_categories ?? {}) as Record<string, string[]>)[
					$activeView
				] ?? [];

			// All services bound to this interface (after tag filtering)
			const allServicesOnIPAddress = visibleServicesForHost
				? visibleServicesForHost.filter((s) =>
						s.bindings.some((b) => b.interface_id == null || (iface && b.interface_id == iface.id))
					)
				: [];

			// Split into visible services and hidden open ports
			// OpenPorts hidden by category or tag go to collapsed indicator
			// Non-OpenPorts stay and render faded when hidden
			type CategoryType = (typeof hiddenCategories)[number];
			const servicesOnIPAddress = allServicesOnIPAddress.filter((s) => {
				const category = serviceDefinitions.getCategory(s.service_definition);
				if (
					category === 'OpenPorts' &&
					(hiddenCategories.includes(category as CategoryType) || hiddenServices.has(s.id))
				)
					return false;
				return true;
			});

			const hiddenOpenPorts = allServicesOnIPAddress.filter((s) => {
				const category = serviceDefinitions.getCategory(s.service_definition);
				if (category !== 'OpenPorts') return false;
				return hiddenCategories.includes(category as CategoryType) || hiddenServices.has(s.id);
			});

			let bodyText: string | null = null;
			let footerText: string | null = null;
			let subtitleText: string | null = null;
			let headerText: string | null = (data as TopologyNode).header ?? null;
			let showServices = servicesOnIPAddress.length != 0 || hiddenOpenPorts.length != 0;

			if (iface && !isContainerSubnetValue) {
				subtitleText = (iface.name ? iface.name + ': ' : '') + iface.ip_address;
			}

			if (!showServices) {
				bodyText = host.name;
			}

			return {
				elementType,
				footerText,
				subtitleText,
				services: servicesOnIPAddress,
				hiddenOpenPorts,
				headerText,
				bodyText,
				showServices,
				isVirtualized:
					headerText?.startsWith('Docker @') || isContainerSubnetValue
						? false
						: host.virtualization !== null,
				ip_address_id: resolved?.ipAddressId ?? ''
			} as ElementRenderData;
		})();
	});

	let isNewNode = $derived(nodeRenderData ? highlightedNewNodes.has(id) : false);

	let isNodeSelected = $derived(
		selectedNode?.id === nodeRenderData?.ip_address_id ||
			multiSelectedNodes.some((n) => n.id === nodeRenderData?.ip_address_id)
	);

	// Calculate if this node should fade out when another node is selected or hidden by tag filter
	let shouldFadeOut = $derived.by(() => {
		if (isExportingValue) return false;

		// Tag filter: fade if this node is hidden
		if (nodeRenderData && hiddenNodes.has(nodeRenderData.ip_address_id)) {
			return true;
		}

		// Service/category filter: fade if this service element is hidden
		if (hiddenServices.has(id) || nodeRenderData?.isCategoryHidden) {
			return true;
		}

		// Search filter: fade if this node is hidden by search
		if (nodeRenderData && searchHiddenNodes.has(nodeRenderData.ip_address_id)) {
			return true;
		}

		// Selection-based fading
		if (!selectedNode && !selectedEdge && multiSelectedNodes.length < 2) return false;
		if (!nodeRenderData) return false;

		// Check if this node is in the connected set
		return !$connectedNodeIds.has(id);
	});

	let nodeOpacity = $derived(shouldFadeOut ? 0.3 : 1);

	const hostColorHelper = entities.getColorHelper('Host');
	const virtualizationColorHelper = concepts.getColorHelper('Virtualization');
	const discoveryColorHelper = entities.getColorHelper('Discovery');

	// Check if this host should be highlighted by tag hover
	let tagHoverRingStyle = $derived.by(() => {
		if (!currentHoveredTag || currentHoveredTag.entityType !== 'host' || !host) return '';
		const { tagId, color } = currentHoveredTag;
		const isUntagged = host.tags.length === 0;
		const hasTag = tagId === UNTAGGED_SENTINEL ? isUntagged : host.tags.includes(tagId);
		if (!hasTag) return '';
		const colorHelper = createColorHelper(color as Parameters<typeof createColorHelper>[0]);
		return `box-shadow: 0 0 0 3px ${colorHelper.rgb};`;
	});

	// Check if any service in this node matches the hovered tag/category — for card shadow
	let serviceHoverShadowStyle = $derived.by(() => {
		if (!nodeRenderData?.showServices) return '';
		const services = nodeRenderData.services;
		if (currentHoveredTag && currentHoveredTag.entityType === 'service') {
			const { tagId, color } = currentHoveredTag;
			for (const service of services) {
				const isUntagged = service.tags.length === 0;
				const hasTag = tagId === UNTAGGED_SENTINEL ? isUntagged : service.tags.includes(tagId);
				if (hasTag) {
					const colorHelper = createColorHelper(color as Parameters<typeof createColorHelper>[0]);
					return `--pulse-color: ${colorHelper.rgb};`;
				}
			}
		}
		if (currentHoveredCategory) {
			for (const service of services) {
				const serviceCategory = serviceDefinitions.getCategory(service.service_definition);
				if (serviceCategory === currentHoveredCategory.category) {
					const colorHelper = createColorHelper(
						currentHoveredCategory.color as Parameters<typeof createColorHelper>[0]
					);
					return `--pulse-color: ${colorHelper.rgb};`;
				}
			}
		}
		return '';
	});

	let cardClass = $derived(
		`card ${isNodeSelected ? 'card-selected' : ''} ${nodeRenderData?.isVirtualized ? `border-color: ${virtualizationColorHelper.border}` : ''}`
	);

	let handleStyle = $derived.by(() => {
		const baseSize = 8;
		const baseOpacity = selectedEdge?.source == id || selectedEdge?.target == id ? 1 : 0;

		// Use host color or virtualization color
		const fillColor = nodeRenderData?.isVirtualized
			? virtualizationColorHelper.rgb
			: hostColorHelper.rgb;

		return `
			width: ${baseSize}px;
			height: ${baseSize}px;
			border: 2px solid #374151;
			background-color: ${fillColor};
			opacity: ${baseOpacity};
			transition: opacity 0.2s ease-in-out;
		`;
	});
</script>

{#if nodeRenderData}
	<div
		class={`${cardClass} ${isNewNode ? 'animate-pulse-highlight' : ''} ${serviceHoverShadowStyle ? 'animate-pulse-highlight-once' : ''}`}
		style={`width: ${effectiveWidth}px; display: flex; flex-direction: column; padding: 0; opacity: ${nodeOpacity}; transition: opacity 0.2s ease-in-out, box-shadow 0.15s ease-in-out; ${isNewNode ? `--pulse-color: ${discoveryColorHelper.rgb};` : ''} ${serviceHoverShadowStyle} ${tagHoverRingStyle}`}
	>
		<!-- Rest of component stays the same -->
		<!-- Header section with gradient transition to body -->
		{#if nodeRenderData.headerText}
			<div class="relative flex-shrink-0 px-2 pt-2 text-center">
				<div
					class={`truncate text-xs font-medium leading-none ${nodeRenderData.isVirtualized ? virtualizationColorHelper.text : 'text-tertiary'}`}
				>
					{nodeRenderData.headerText}
				</div>
			</div>
		{/if}

		{#if nodeRenderData.subtitleText}
			<div
				class="text-secondary truncate px-2 text-center font-mono text-xs {!nodeRenderData.headerText &&
				!nodeRenderData.showServices
					? 'py-2'
					: 'pt-0.5'}"
			>
				{nodeRenderData.subtitleText}
			</div>
		{/if}

		<!-- Body section -->
		<div class="flex flex-col items-center px-3 py-2">
			{#if nodeRenderData.showServices}
				<!-- Show services list -->
				<div class="flex w-full flex-col items-center" style="min-width: 0; max-width: 100%;">
					{#each nodeRenderData.services as service (service.id)}
						{@const isServiceTagHidden =
							nodeRenderData.elementType !== 'Service' && hiddenServices.has(service.id)}
						{@const ServiceIcon = serviceDefinitions.getIconComponent(service.service_definition)}
						{@const serviceTagHighlight = (() => {
							if (!currentHoveredTag || currentHoveredTag.entityType !== 'service') return '';
							const { tagId, color } = currentHoveredTag;
							const isUntagged = service.tags.length === 0;
							const hasTag =
								tagId === UNTAGGED_SENTINEL ? isUntagged : service.tags.includes(tagId);
							if (!hasTag) return '';
							const colorHelper = createColorHelper(
								color as Parameters<typeof createColorHelper>[0]
							);
							return `color: ${colorHelper.rgb}; --text-pulse-color: ${colorHelper.rgb};`;
						})()}
						{@const serviceCategoryHighlight = (() => {
							if (!currentHoveredCategory) return '';
							const serviceCategory = serviceDefinitions.getCategory(service.service_definition);
							if (serviceCategory !== currentHoveredCategory.category) return '';
							const colorHelper = createColorHelper(
								currentHoveredCategory.color as Parameters<typeof createColorHelper>[0]
							);
							return `color: ${colorHelper.rgb}; --text-pulse-color: ${colorHelper.rgb};`;
						})()}
						<div
							class="flex flex-col items-center justify-center py-2"
							style="min-width: 0; max-width: 100%; width: 100%;{isServiceTagHidden
								? ' opacity: 0.3;'
								: ''}"
						>
							<div
								class="flex items-center justify-center gap-1"
								style="line-height: 1.3; width: 100%; min-width: 0; max-width: 100%;"
								title={service.name}
							>
								<ServiceIcon class="h-5 w-5 flex-shrink-0 {hostColorHelper.icon}" />
								<span
									class="text-m text-secondary truncate {serviceTagHighlight ||
									serviceCategoryHighlight
										? 'animate-text-pulse-highlight'
										: ''}"
									style="transition: color 0.15s; {serviceTagHighlight || serviceCategoryHighlight}"
								>
									{service.name}
								</span>
							</div>
							{#if !$topologyOptions.request.hide_ports && nodeRenderData.elementType !== 'Service' && nodeRenderData.elementType !== 'Host' && service.bindings.filter((b) => b.type == 'Port').length > 0}
								<span class="text-tertiary mt-1 text-center text-xs"
									>{service.bindings
										.map((b) => {
											if (
												(b.ip_address_id == nodeRenderData.ip_address_id ||
													b.ip_address_id == null) &&
												b.type == 'Port' &&
												b.port_id
											) {
												const port = getPortById(b.port_id);
												if (port) {
													return formatPort(port);
												}
											}
										})
										.filter((p) => {
											return p !== undefined;
										})
										.join(', ')}</span
								>
							{/if}
						</div>
					{/each}
					{#if nodeRenderData.hiddenOpenPorts.length > 0 && nodeRenderData.elementType !== 'Host'}
						{#if expandedOpenPorts}
							{#each nodeRenderData.hiddenOpenPorts as service (service.id)}
								{@const ServiceIcon = serviceDefinitions.getIconComponent(
									service.service_definition
								)}
								<div
									class="flex flex-col items-center justify-center"
									style="min-width: 0; max-width: 100%; width: 100%;"
								>
									<div
										class="flex items-center justify-center gap-1"
										style="line-height: 1.3; width: 100%; min-width: 0; max-width: 100%;"
										title={service.name}
									>
										<ServiceIcon class="h-5 w-5 flex-shrink-0 {hostColorHelper.icon}" />
										<span class="text-m text-secondary truncate" style="transition: color 0.15s;">
											{service.name}
										</span>
									</div>
									{#if !$topologyOptions.request.hide_ports && nodeRenderData.elementType !== 'Service' && nodeRenderData.elementType !== 'Host' && service.bindings.filter((b) => b.type == 'Port').length > 0}
										<span class="text-tertiary mt-1 text-center text-xs"
											>{service.bindings
												.map((b) => {
													if (
														(b.ip_address_id == nodeRenderData.ip_address_id ||
															b.ip_address_id == null) &&
														b.type == 'Port' &&
														b.port_id
													) {
														const port = getPortById(b.port_id);
														if (port) {
															return formatPort(port);
														}
													}
												})
												.filter((p) => p !== undefined)
												.join(', ')}</span
										>
									{/if}
								</div>
							{/each}
							<button
								class="nopan text-tertiary hover:text-secondary mb-2 mt-1 cursor-pointer text-xs underline"
								onclick={(e) => {
									e.stopPropagation();
									toggleExpandedPorts(id);
								}}
							>
								{topology_hideOpenPorts()}
							</button>
						{:else}
							<button
								class="nopan bg-surface-secondary text-tertiary hover:text-secondary mb-2 mt-1 cursor-pointer rounded-full px-2 py-0.5 text-xs underline"
								onclick={(e) => {
									e.stopPropagation();
									toggleExpandedPorts(id);
								}}
							>
								{topology_openPortsSummary({
									count:
										nodeRenderData.hiddenOpenPorts.reduce(
											(sum, s) =>
												sum +
												s.bindings.filter(
													(b) =>
														(b.ip_address_id == nodeRenderData.ip_address_id ||
															b.ip_address_id == null) &&
														b.type == 'Port'
												).length,
											0
										) || nodeRenderData.hiddenOpenPorts.length
								})}
							</button>
						{/if}
					{/if}
				</div>
			{:else}
				<!-- Show host name as body text -->
				<div
					class="text-secondary truncate text-center text-xs leading-none"
					title={nodeRenderData.bodyText}
				>
					{nodeRenderData.bodyText}
				</div>
			{/if}
		</div>

		<!-- Footer section -->
		{#if nodeRenderData.portStatus}
			<div class="flex flex-shrink-0 items-center justify-center gap-1.5 px-2 pb-1.5">
				<span
					class="text-xs font-medium"
					style="color: {nodeRenderData.portStatus.operStatus === 'Up'
						? '#22c55e'
						: nodeRenderData.portStatus.operStatus === 'Down'
							? '#ef4444'
							: '#9ca3af'}">●</span
				>
				{#if nodeRenderData.portStatus.speed}
					<span class="text-tertiary text-xs">{nodeRenderData.portStatus.speed}</span>
				{/if}
				{#if nodeRenderData.portStatus.macAddress}
					<span class="text-tertiary truncate font-mono text-xs" style="font-size: 0.6rem"
						>{nodeRenderData.portStatus.macAddress}</span
					>
				{/if}
			</div>
		{:else if nodeRenderData.footerText}
			<div class="relative flex flex-shrink-0 items-center justify-center px-2 pb-2">
				<div class="text-tertiary truncate text-xs font-medium leading-none">
					{nodeRenderData.footerText}
				</div>
			</div>
		{/if}
	</div>
{/if}

<Handle type="target" id="Top" position={Position.Top} style={handleStyle} />
<Handle type="target" id="Right" position={Position.Right} style={handleStyle} />
<Handle type="target" id="Bottom" position={Position.Bottom} style={handleStyle} />
<Handle type="target" id="Left" position={Position.Left} style={handleStyle} />

<Handle type="source" id="Top" position={Position.Top} style={handleStyle} />
<Handle type="source" id="Right" position={Position.Right} style={handleStyle} />
<Handle type="source" id="Bottom" position={Position.Bottom} style={handleStyle} />
<Handle type="source" id="Left" position={Position.Left} style={handleStyle} />
