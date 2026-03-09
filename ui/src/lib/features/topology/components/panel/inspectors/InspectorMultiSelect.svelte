<script lang="ts">
	import { get } from 'svelte/store';
	import { SvelteMap } from 'svelte/reactivity';
	import { GitBranch, Network, X } from 'lucide-svelte';
	import {
		selectedNodes,
		previewEdges,
		autoRebuild,
		selectedTopologyId,
		useTopologiesQuery
	} from '../../../queries';
	import type { InterfaceNode as InterfaceNodeType } from '../../../types/base';
	import type { GroupType, EdgeStyle } from '$lib/features/groups/types/base';
	import { getTopologyStateInfo } from '../../../state';
	import { computeCommonTags } from '$lib/shared/utils/tags';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import { useBulkAddTagMutation, useBulkRemoveTagMutation } from '$lib/features/tags/queries';
	import { useCreateGroupMutation, createEmptyGroupFormData } from '$lib/features/groups/queries';
	import EdgeStyleForm from '$lib/features/groups/components/GroupEditModal/EdgeStyleForm.svelte';
	import type { Node, Edge } from '@xyflow/svelte';
	import type { Color } from '$lib/shared/utils/styling';
	import { AVAILABLE_COLORS, createColorHelper } from '$lib/shared/utils/styling';
	import { useQueryClient } from '@tanstack/svelte-query';
	import { queryKeys } from '$lib/api/query-client';
	import {
		topology_multiSelectActionBarCount,
		topology_multiSelectGroupName,
		topology_multiSelectNoBindings,
		topology_multiSelectPickBinding,
		common_cancel,
		common_clearSelection,
		common_confirm,
		common_tags,
		groups_createGroup,
		groups_serviceBindings
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

	const queryClient = useQueryClient();
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(topologiesData.find((t) => t.id === $selectedTopologyId));

	const bulkAddTagMutation = useBulkAddTagMutation();
	const bulkRemoveTagMutation = useBulkRemoveTagMutation();
	const createGroupMutation = useCreateGroupMutation();

	// Subscribe to selectedNodes
	let nodes = $state<Node[]>(get(selectedNodes));
	selectedNodes.subscribe((value) => {
		nodes = value;
	});

	// Get unique host IDs from selected interface nodes
	let selectedHostIds = $derived.by(() => {
		const hostIds: string[] = [];
		for (const node of nodes) {
			const data = node.data as InterfaceNodeType;
			if (data.host_id && !hostIds.includes(data.host_id)) {
				hostIds.push(data.host_id);
			}
		}
		return hostIds;
	});

	// Get hosts from topology
	let selectedHosts = $derived(
		topology ? topology.hosts.filter((h) => selectedHostIds.includes(h.id)) : []
	);

	// Common tags across selected hosts
	let commonHostTags = $derived(computeCommonTags(selectedHosts));

	// Check if topology allows mutations
	let canMutate = $derived.by(() => {
		if (isReadOnly || !topology) return false;
		const stateInfo = getTopologyStateInfo(topology, get(autoRebuild));
		return stateInfo.type === 'fresh' && !topology.is_locked;
	});

	// Tag handlers — invalidate topology cache after so tags show immediately
	async function handleAddTag(tagId: string) {
		await bulkAddTagMutation.mutateAsync({
			entity_ids: selectedHostIds,
			entity_type: 'Host',
			tag_id: tagId
		});
		queryClient.invalidateQueries({ queryKey: queryKeys.topology.all });
	}

	async function handleRemoveTag(tagId: string) {
		await bulkRemoveTagMutation.mutateAsync({
			entity_ids: selectedHostIds,
			entity_type: 'Host',
			tag_id: tagId
		});
		queryClient.invalidateQueries({ queryKey: queryKeys.topology.all });
	}

	// Group creation state
	let isCreatingGroup = $state(false);
	let groupType: GroupType = $state('RequestPath');
	let groupName = $state('');
	let groupColor: Color = $state(
		AVAILABLE_COLORS[Math.floor(Math.random() * AVAILABLE_COLORS.length)]
	);
	let groupEdgeStyle: EdgeStyle = $state('SmoothStep');

	// Fake group data for EdgeStyleForm binding
	let edgeStyleFormData = $derived({
		color: groupColor,
		edge_style: groupEdgeStyle,
		id: '',
		name: '',
		description: '',
		binding_ids: [],
		created_at: '',
		updated_at: '',
		group_type: groupType,
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
			const data = node.data as InterfaceNodeType;
			if (!data.interface_id) continue;

			const iface = topology.interfaces.find((i) => i.id === data.interface_id);
			const host = topology.hosts.find((h) => h.id === data.host_id);
			if (!host) continue;

			// Find bindings on this specific interface
			const interfaceBindings: { id: string; label: string }[] = [];
			const hostServices = topology.services.filter((s) => s.host_id === host.id);
			for (const service of hostServices) {
				for (const binding of service.bindings) {
					// Only include bindings for this interface (or null = all interfaces)
					if (binding.interface_id === data.interface_id || binding.interface_id === null) {
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
				: data.interface_id;

			choices.push({
				interfaceId: data.interface_id,
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

	function startGroupCreation() {
		isCreatingGroup = true;
		groupName = '';
		groupColor = AVAILABLE_COLORS[Math.floor(Math.random() * AVAILABLE_COLORS.length)];
		groupEdgeStyle = 'SmoothStep';
		initBindingSelections();
		updatePreviewEdges();
	}

	function cancelGroupCreation() {
		isCreatingGroup = false;
		groupName = '';
		previewEdges.set([]);
	}

	async function confirmGroupCreation() {
		if (!topology) return;
		const bindingIds: string[] = [];
		for (const bindingId of bindingSelections.values()) {
			if (bindingId) {
				bindingIds.push(bindingId);
			}
		}

		if (bindingIds.length < 2 || !groupName.trim()) return;

		const newGroup = createEmptyGroupFormData(topology.network_id);
		newGroup.name = groupName.trim();
		newGroup.group_type = groupType;
		newGroup.binding_ids = bindingIds;
		newGroup.color = groupColor;
		newGroup.edge_style = groupEdgeStyle;

		const created = await createGroupMutation.mutateAsync(newGroup);
		previewEdges.set([]);
		isCreatingGroup = false;
		onGroupCreated?.(created.id);
	}

	// Preview edges — render as colored group edges
	function updatePreviewEdges() {
		const nodeIds = nodes.map((n) => n.id);
		if (nodeIds.length < 2) return;

		const colorHelper = createColorHelper(groupColor);
		const preview: Edge[] = [];

		if (groupType === 'RequestPath') {
			for (let i = 0; i < nodeIds.length - 1; i++) {
				preview.push({
					id: `preview-${i}`,
					source: nodeIds[i],
					target: nodeIds[i + 1],
					type: 'custom',
					data: {
						edge_type: 'RequestPath',
						is_preview: true,
						group_id: '__preview__',
						preview_color: groupColor
					},
					markerEnd: {
						type: 'arrow',
						color: colorHelper.rgb
					},
					animated: true
				});
			}
		} else {
			for (let i = 1; i < nodeIds.length; i++) {
				preview.push({
					id: `preview-${i}`,
					source: nodeIds[0],
					target: nodeIds[i],
					type: 'custom',
					data: {
						edge_type: 'HubAndSpoke',
						is_preview: true,
						group_id: '__preview__',
						preview_color: groupColor
					},
					markerEnd: {
						type: 'arrow',
						color: colorHelper.rgb
					},
					animated: true
				});
			}
		}
		previewEdges.set(preview);
	}

	// Update preview when color or group type changes while creating
	$effect(() => {
		if (isCreatingGroup) {
			void groupColor;
			void groupType;
			updatePreviewEdges();
		}
	});
</script>

<div class="w-full space-y-4">
	<!-- Header with count and clear -->
	<div class="flex items-center justify-between">
		<span class="text-secondary text-sm font-medium">
			{topology_multiSelectActionBarCount({ count: nodes.length })}
		</span>
		<button class="btn-icon p-1" onclick={onClearSelection} title={common_clearSelection()}>
			<X class="h-4 w-4" />
		</button>
	</div>

	{#if canMutate}
		<!-- Tags section -->
		<div class="space-y-2">
			<span class="text-secondary block text-sm font-medium">{common_tags()}</span>
			<div class="card card-static p-2">
				<TagPickerInline
					selectedTagIds={commonHostTags}
					onAdd={handleAddTag}
					onRemove={handleRemoveTag}
				/>
			</div>
		</div>

		<!-- Group creation section -->
		<div class="space-y-2">
			<span class="text-secondary block text-sm font-medium">{groups_createGroup()}</span>

			{#if !isCreatingGroup}
				<!-- Group type toggle + Create button -->
				<div class="flex items-center gap-2">
					<div class="flex rounded-md border border-gray-600">
						<button
							class="px-2 py-1.5 text-xs transition-colors {groupType === 'RequestPath'
								? 'bg-blue-600 text-white'
								: 'text-secondary hover:text-primary'}"
							onclick={() => (groupType = 'RequestPath')}
							title="Request Path"
						>
							<GitBranch class="h-3.5 w-3.5" />
						</button>
						<button
							class="px-2 py-1.5 text-xs transition-colors {groupType === 'HubAndSpoke'
								? 'bg-blue-600 text-white'
								: 'text-secondary hover:text-primary'}"
							onclick={() => (groupType = 'HubAndSpoke')}
							title="Hub & Spoke"
						>
							<Network class="h-3.5 w-3.5" />
						</button>
					</div>
					<button class="btn-primary flex-1 text-xs" onclick={startGroupCreation}>
						{groups_createGroup()}
					</button>
				</div>
			{:else}
				<!-- Group creation form -->
				<div class="space-y-3">
					<!-- Group type toggle -->
					<div class="flex items-center gap-2">
						<div class="flex rounded-md border border-gray-600">
							<button
								class="px-2 py-1.5 text-xs transition-colors {groupType === 'RequestPath'
									? 'bg-blue-600 text-white'
									: 'text-secondary hover:text-primary'}"
								onclick={() => (groupType = 'RequestPath')}
								title="Request Path"
							>
								<GitBranch class="h-3.5 w-3.5" />
							</button>
							<button
								class="px-2 py-1.5 text-xs transition-colors {groupType === 'HubAndSpoke'
									? 'bg-blue-600 text-white'
									: 'text-secondary hover:text-primary'}"
								onclick={() => (groupType = 'HubAndSpoke')}
								title="Hub & Spoke"
							>
								<Network class="h-3.5 w-3.5" />
							</button>
						</div>
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
						<span class="text-secondary block text-xs font-medium">{groups_serviceBindings()}</span>
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
										class="h-6 w-full rounded px-1 text-xs"
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

					<!-- Action buttons -->
					<div class="flex gap-2">
						<button
							class="btn-primary flex-1 text-xs"
							onclick={confirmGroupCreation}
							disabled={!groupName.trim() || createGroupMutation.isPending}
						>
							{common_confirm()}
						</button>
						<button class="btn-secondary flex-1 text-xs" onclick={cancelGroupCreation}>
							{common_cancel()}
						</button>
					</div>
				</div>
			{/if}
		</div>
	{/if}
</div>
