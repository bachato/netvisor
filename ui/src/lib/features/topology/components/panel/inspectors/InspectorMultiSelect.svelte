<script lang="ts">
	import { get } from 'svelte/store';
	import { SvelteMap } from 'svelte/reactivity';
	import { Eye, EyeOff, X, Crosshair } from 'lucide-svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import {
		selectedNodes,
		previewEdges,
		autoRebuild,
		selectedTopologyId,
		useTopologiesQuery
	} from '../../../queries';
	import type { TopologyNode } from '../../../types/base';
	import { resolveElementNode } from '../../../resolvers';
	import type { DependencyType, EdgeStyle } from '$lib/features/dependencies/types/base';
	import { getTopologyEditState } from '../../../state';
	import { computeCommonTags } from '$lib/shared/utils/tags';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import { useBulkAddTagMutation, useBulkRemoveTagMutation } from '$lib/features/tags/queries';
	import {
		useCreateDependencyMutation,
		createEmptyDependencyFormData
	} from '$lib/features/dependencies/queries';
	import EdgeStyleForm from '$lib/features/dependencies/components/DependencyEditModal/EdgeStyleForm.svelte';
	import EntityTag from '$lib/shared/components/data/EntityTag.svelte';
	import { entityRef } from '$lib/shared/components/data/types';
	import { entities, dependencyTypes } from '$lib/shared/stores/metadata';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import SegmentedControl from '$lib/shared/components/forms/SegmentedControl.svelte';
	import type { Node, Edge } from '@xyflow/svelte';
	import type { Color } from '$lib/shared/utils/styling';
	import { AVAILABLE_COLORS, createColorHelper } from '$lib/shared/utils/styling';
	import { browser } from '$app/environment';
	import {
		topology_multiSelectActionBarCount,
		topology_multiSelectGroupName,
		topology_multiSelectNoBindings,
		topology_multiSelectPickBinding,
		topology_multiSelectCreateGroupRebuildWarning,
		common_hosts,
		common_services,
		topology_multiSelectLockedHint,
		topology_multiSelectStaleHint,
		topology_multiSelectReadOnlyHint,
		common_clearSelection,
		common_tags,
		dependencies_createDependency,
		dependencies_serviceBindings,
		dependencies_serviceBindingsInfoTitle,
		dependencies_serviceBindingsInfoBody,
		topology_multiSelectPreviewEdge,
		topology_focusSelection
	} from '$lib/paraglide/messages';

	let {
		isReadOnly = false,
		onClearSelection,
		onGroupCreated
	}: {
		isReadOnly?: boolean;
		onClearSelection: () => void;
		onGroupCreated?: (groupId: string) => void;
	} = $props();

	const { fitView } = useSvelteFlow();
	const PREVIEW_STORAGE_KEY = 'scanopy_topology_group_preview';

	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(topologiesData.find((t) => t.id === $selectedTopologyId));

	const bulkAddTagMutation = useBulkAddTagMutation();
	const bulkRemoveTagMutation = useBulkRemoveTagMutation();
	const createDependencyMutation = useCreateDependencyMutation();

	// Subscribe to selectedNodes
	let nodes = $state<Node[]>(get(selectedNodes));
	selectedNodes.subscribe((value) => {
		nodes = value;
	});

	// Get unique host IDs from selected interface nodes
	let selectedHostIds = $derived.by(() => {
		if (!topology) return [];
		const hostIds: string[] = [];
		for (const node of nodes) {
			const resolved = resolveElementNode(node.id, node.data as TopologyNode, topology);
			if (resolved.hostId && !hostIds.includes(resolved.hostId)) {
				hostIds.push(resolved.hostId);
			}
		}
		return hostIds;
	});

	// Get hosts from topology
	let selectedHosts = $derived(
		topology ? topology.hosts.filter((h) => selectedHostIds.includes(h.id)) : []
	);

	// Get services bound to selected interfaces
	let selectedServiceIds = $derived.by(() => {
		if (!topology) return [];
		const serviceIds: string[] = [];
		for (const node of nodes) {
			const resolved = resolveElementNode(node.id, node.data as TopologyNode, topology);
			if (!resolved.interfaceId) continue;
			for (const service of topology.services) {
				if (serviceIds.includes(service.id)) continue;
				for (const binding of service.bindings) {
					if (binding.interface_id === resolved.interfaceId || binding.interface_id === null) {
						if (service.host_id && selectedHostIds.includes(service.host_id)) {
							serviceIds.push(service.id);
							break;
						}
					}
				}
			}
		}
		return serviceIds;
	});

	let selectedServices = $derived(
		topology ? topology.services.filter((s) => selectedServiceIds.includes(s.id)) : []
	);

	// Tag entity type toggle
	let tagEntityType: 'Host' | 'Service' = $state('Host');

	let tagEntityIds = $derived(tagEntityType === 'Host' ? selectedHostIds : selectedServiceIds);
	let tagEntities = $derived(tagEntityType === 'Host' ? selectedHosts : selectedServices);

	// Common tags across selected entities
	let commonTags = $derived(computeCommonTags(tagEntities));

	// Unified edit state
	let editState = $derived(getTopologyEditState(topology, get(autoRebuild), isReadOnly));

	let mutateDisabledReason = $derived.by(() => {
		if (!editState.disabledReason) return '';
		if (editState.disabledReason === 'readonly') return topology_multiSelectReadOnlyHint();
		if (editState.disabledReason === 'locked') return topology_multiSelectLockedHint();
		return topology_multiSelectStaleHint();
	});

	// Tag handlers — mutation onSuccess handles cache updates optimistically
	async function handleAddTag(tagId: string) {
		await bulkAddTagMutation.mutateAsync({
			entity_ids: tagEntityIds,
			entity_type: tagEntityType,
			tag_id: tagId
		});
	}

	async function handleRemoveTag(tagId: string) {
		await bulkRemoveTagMutation.mutateAsync({
			entity_ids: tagEntityIds,
			entity_type: tagEntityType,
			tag_id: tagId
		});
	}

	// Dependency creation state — always visible, no expand/collapse
	let groupType: DependencyType = $state('RequestPath');
	let groupName = $state('');
	let groupColor: Color = $state(
		AVAILABLE_COLORS[Math.floor(Math.random() * AVAILABLE_COLORS.length)]
	);
	let groupEdgeStyle: EdgeStyle = $state('SmoothStep');

	// Preview toggle with localStorage persistence
	let showPreview = $state(true);
	if (browser) {
		try {
			const stored = localStorage.getItem(PREVIEW_STORAGE_KEY);
			if (stored !== null) showPreview = stored === 'true';
		} catch {
			// ignore
		}
	}

	function togglePreview() {
		showPreview = !showPreview;
		if (browser) {
			try {
				localStorage.setItem(PREVIEW_STORAGE_KEY, String(showPreview));
			} catch {
				// ignore
			}
		}
		if (!showPreview) {
			previewEdges.set([]);
		} else {
			updatePreviewEdges();
		}
	}

	// Fake group data for EdgeStyleForm binding
	let edgeStyleFormData = $derived({
		color: groupColor,
		edge_style: groupEdgeStyle,
		id: '',
		name: '',
		description: '',
		members: [],
		created_at: '',
		updated_at: '',
		dependency_type: groupType,
		source: { type: 'Manual' as const },
		network_id: '',
		tags: []
	});

	// Binding disambiguation per selected interface
	interface InterfaceBindingChoice {
		interfaceId: string;
		interfaceName: string;
		hostName: string;
		bindings: { id: string; label: string }[];
	}

	let interfaceBindingChoices = $derived.by(() => {
		if (!topology) return [];
		const choices: InterfaceBindingChoice[] = [];
		for (const node of nodes) {
			const resolved = resolveElementNode(node.id, node.data as TopologyNode, topology);
			if (!resolved.interfaceId) continue;

			const iface = resolved.iface;
			const host = resolved.host;
			if (!host) continue;

			// Find bindings on this specific interface
			const interfaceBindings: { id: string; label: string }[] = [];
			const hostServices = topology.services.filter((s) => s.host_id === host.id);
			for (const service of hostServices) {
				for (const binding of service.bindings) {
					// Only include bindings for this interface (or null = all interfaces)
					if (binding.interface_id === resolved.interfaceId || binding.interface_id === null) {
						const portInfo =
							binding.type === 'Port' && binding.port_id
								? (() => {
										const port = topology.ports.find((p) => p.id === binding.port_id);
										return port ? `:${port.number}/${port.protocol}` : '';
									})()
								: '';
						interfaceBindings.push({
							id: binding.id,
							label: `${service.name}${portInfo}`
						});
					}
				}
			}

			const ifaceName = iface
				? (iface.name ? iface.name + ': ' : '') + iface.ip_address
				: resolved.interfaceId;

			choices.push({
				interfaceId: resolved.interfaceId,
				interfaceName: ifaceName,
				hostName: host.name,
				bindings: interfaceBindings
			});
		}
		return choices;
	});

	// Binding selections keyed by interface ID
	const bindingSelections = new SvelteMap<string, string | null>();

	function initBindingSelections() {
		bindingSelections.clear();
		for (const choice of interfaceBindingChoices) {
			bindingSelections.set(
				choice.interfaceId,
				choice.bindings.length === 1 ? choice.bindings[0].id : null
			);
		}
	}

	// Initialize binding selections reactively when choices change
	$effect(() => {
		void interfaceBindingChoices;
		initBindingSelections();
	});

	async function confirmGroupCreation() {
		if (!topology) return;
		const bindingIds: string[] = [];
		for (const bindingId of bindingSelections.values()) {
			if (bindingId) {
				bindingIds.push(bindingId);
			}
		}

		if (bindingIds.length < 2 || !groupName.trim()) return;

		const newDependency = createEmptyDependencyFormData(topology.network_id);
		newDependency.name = groupName.trim();
		newDependency.dependency_type = groupType;
		// Convert binding IDs to members (service_id + binding_id)
		const allServices = topology.services;
		newDependency.members = bindingIds.map((bindingId) => {
			const service = allServices.find((s) => s.bindings.some((b) => b.id === bindingId));
			return {
				service_id: service?.id ?? '',
				binding_id: bindingId
			};
		});
		newDependency.color = groupColor;
		newDependency.edge_style = groupEdgeStyle;

		const created = await createDependencyMutation.mutateAsync(newDependency);
		previewEdges.set([]);
		onGroupCreated?.(created.id);
	}

	// Get absolute position for a node (accounting for parent offset)
	function getAbsolutePosition(node: Node): { x: number; y: number } {
		if (node.parentId && topology) {
			const parent = topology.nodes.find((n) => n.id === node.parentId);
			if (parent) {
				return {
					x: parent.position.x + node.position.x,
					y: parent.position.y + node.position.y
				};
			}
		}
		return { x: node.position.x, y: node.position.y };
	}

	// Compute best source/target handles based on absolute node positions
	function getBestHandles(
		source: Node,
		target: Node
	): { sourceHandle: string; targetHandle: string } {
		const sourcePos = getAbsolutePosition(source);
		const targetPos = getAbsolutePosition(target);
		const dx = targetPos.x - sourcePos.x;
		const dy = targetPos.y - sourcePos.y;
		if (Math.abs(dx) > Math.abs(dy)) {
			return dx > 0
				? { sourceHandle: 'Right', targetHandle: 'Left' }
				: { sourceHandle: 'Left', targetHandle: 'Right' };
		} else {
			return dy > 0
				? { sourceHandle: 'Bottom', targetHandle: 'Top' }
				: { sourceHandle: 'Top', targetHandle: 'Bottom' };
		}
	}

	// Preview edges — render as colored group edges
	function updatePreviewEdges() {
		if (nodes.length < 2) return;

		const colorHelper = createColorHelper(groupColor);
		const preview: Edge[] = [];

		if (groupType === 'RequestPath') {
			for (let i = 0; i < nodes.length - 1; i++) {
				const source = nodes[i];
				const target = nodes[i + 1];
				const handles = getBestHandles(source, target);
				preview.push({
					id: `preview-${i}`,
					source: source.id,
					target: target.id,
					sourceHandle: handles.sourceHandle,
					targetHandle: handles.targetHandle,
					type: 'custom',
					data: {
						edge_type: 'RequestPath',
						is_preview: true,
						group_id: '__preview__',
						preview_color: groupColor,
						preview_edge_style: groupEdgeStyle
					},
					markerEnd: {
						type: 'arrow',
						color: colorHelper.rgb
					}
				});
			}
		} else {
			const hub = nodes[0];
			for (let i = 1; i < nodes.length; i++) {
				const spoke = nodes[i];
				const handles = getBestHandles(hub, spoke);
				preview.push({
					id: `preview-${i}`,
					source: hub.id,
					target: spoke.id,
					sourceHandle: handles.sourceHandle,
					targetHandle: handles.targetHandle,
					type: 'custom',
					data: {
						edge_type: 'HubAndSpoke',
						is_preview: true,
						group_id: '__preview__',
						preview_color: groupColor,
						preview_edge_style: groupEdgeStyle
					},
					markerEnd: {
						type: 'arrow',
						color: colorHelper.rgb
					}
				});
			}
		}
		previewEdges.set(preview);
	}

	// Start preview edges on mount and update when dependencies change
	$effect(() => {
		if (showPreview) {
			void groupColor;
			void groupType;
			void groupEdgeStyle;
			void nodes;
			updatePreviewEdges();
		}
	});
</script>

<div class="w-full space-y-4">
	<!-- Header with count, focus, and clear -->
	<div class="flex items-center justify-between">
		<span class="text-secondary text-sm font-medium">
			{topology_multiSelectActionBarCount({ count: nodes.length })}
		</span>
		<div class="flex items-center gap-1">
			<button
				class="btn-icon p-1"
				onclick={() =>
					fitView({ nodes: nodes.map((n) => ({ id: n.id })), padding: 0.5, duration: 300 })}
				title={topology_focusSelection()}
			>
				<Crosshair class="h-4 w-4" />
			</button>
			<button class="btn-icon p-1" onclick={onClearSelection} title={common_clearSelection()}>
				<X class="h-4 w-4" />
			</button>
		</div>
	</div>

	{#if editState.isEditable}
		<!-- Tags section -->
		<div class="space-y-2">
			<span class="text-secondary block text-sm font-medium">{common_tags()}</span>
			<div class="card card-static space-y-2 p-2">
				<!-- Entity type toggle -->
				<div class="flex items-center gap-1">
					<SegmentedControl
						options={[
							{ value: 'Host', label: common_hosts() },
							{ value: 'Service', label: common_services() }
						]}
						selected={tagEntityType}
						onchange={(v) => (tagEntityType = v as 'Host' | 'Service')}
					/>
				</div>
				<!-- Entity names as EntityTag pills -->
				{#if tagEntities.length > 0}
					{@const IconComponent = entities.getIconComponent(tagEntityType)}
					{@const color = entities.getColorHelper(tagEntityType).color}
					<div class="flex flex-wrap gap-1">
						{#each tagEntities as entity (entity.id)}
							<EntityTag
								entityRef={entityRef(tagEntityType, entity.id, entity)}
								label={entity.name}
								icon={IconComponent}
								{color}
							/>
						{/each}
					</div>
				{/if}
				<div class="flex items-center gap-1.5">
					<span class="text-tertiary shrink-0 text-xs">{common_tags()}:</span>
					<TagPickerInline
						selectedTagIds={commonTags}
						onAdd={handleAddTag}
						onRemove={handleRemoveTag}
					/>
				</div>
			</div>
		</div>

		<!-- Dependency creation section — always visible -->
		<div class="space-y-2">
			<span class="text-secondary block text-sm font-medium">{dependencies_createDependency()}</span
			>

			<div class="card card-static space-y-3 p-3">
				<!-- Dependency type toggle + preview button -->
				<div class="flex items-center gap-2">
					<SegmentedControl
						options={['RequestPath', 'HubAndSpoke'].map((type) => ({
							value: type,
							label: '',
							icon: dependencyTypes.getIconComponent(type)
						}))}
						selected={groupType}
						onchange={(v) => (groupType = v as DependencyType)}
					/>
					<span class="text-secondary text-xs">{dependencyTypes.getName(groupType)}</span>
					<button
						class="btn-secondary ml-auto flex items-center gap-1 p-1.5 text-xs"
						onclick={togglePreview}
						title={showPreview ? 'Hide preview' : 'Show preview'}
					>
						{#if showPreview}
							<Eye class="h-3.5 w-3.5" />
						{:else}
							<EyeOff class="h-3.5 w-3.5" />
						{/if}
						{topology_multiSelectPreviewEdge()}
					</button>
				</div>

				<!-- Name input -->
				<input
					type="text"
					bind:value={groupName}
					placeholder={topology_multiSelectGroupName()}
					class="h-8 w-full rounded px-2 text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
					style="border: 1px solid var(--color-border-input); background: var(--color-bg-input); color: var(--color-text-primary)"
				/>

				<!-- Edge style & color -->
				<EdgeStyleForm
					bind:formData={edgeStyleFormData}
					collapsed={false}
					editable={true}
					showCollapseToggle={false}
					onColorChange={(c) => (groupColor = c)}
					onEdgeStyleChange={(s) => (groupEdgeStyle = s)}
				/>

				<!-- Binding selection -->
				<div class="space-y-2">
					<span class="text-secondary block text-xs font-medium"
						>{dependencies_serviceBindings()}</span
					>
					<InlineInfo
						title={dependencies_serviceBindingsInfoTitle()}
						body={dependencies_serviceBindingsInfoBody()}
						dismissableKey="group-bindings-info"
					/>
					{#each interfaceBindingChoices as choice (choice.interfaceId)}
						<div class="card card-static space-y-1 p-2">
							<div class="text-primary truncate text-xs font-medium">
								{choice.hostName}
							</div>
							<div class="text-tertiary truncate text-[10px]">
								{choice.interfaceName}
							</div>
							{#if choice.bindings.length === 0}
								<div class="text-tertiary text-xs italic">
									{topology_multiSelectNoBindings()}
								</div>
							{:else if choice.bindings.length === 1}
								<div class="text-secondary text-xs">
									{choice.bindings[0].label}
								</div>
							{:else}
								<select
									class="h-auto min-h-6 w-full rounded px-1 text-xs"
									style="border: 1px solid var(--color-border-input); background: var(--color-bg-input); color: var(--color-text-primary)"
									value={bindingSelections.get(choice.interfaceId) ?? ''}
									onchange={(e) => {
										const target = e.target as HTMLSelectElement;
										bindingSelections.set(choice.interfaceId, target.value || null);
									}}
								>
									<option value="">{topology_multiSelectPickBinding()}</option>
									{#each choice.bindings as binding (binding.id)}
										<option value={binding.id}>{binding.label}</option>
									{/each}
								</select>
							{/if}
						</div>
					{/each}
				</div>

				<!-- Rebuild warning + Create button -->
				<div class="space-y-2">
					<p class="text-tertiary text-xs">
						{topology_multiSelectCreateGroupRebuildWarning()}
					</p>
					<button
						class="btn-primary w-full text-xs"
						onclick={confirmGroupCreation}
						disabled={!groupName.trim() || createDependencyMutation.isPending}
					>
						{dependencies_createDependency()}
					</button>
				</div>
			</div>
		</div>
	{:else}
		<!-- Show reason why actions are unavailable -->
		{#if mutateDisabledReason}
			<div class="text-tertiary py-2 text-center text-sm">
				{mutateDisabledReason}
			</div>
		{/if}
	{/if}
</div>
