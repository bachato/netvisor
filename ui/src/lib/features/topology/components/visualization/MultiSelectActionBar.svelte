<script lang="ts">
	import { get } from 'svelte/store';
	import { SvelteMap } from 'svelte/reactivity';
	import { X, GitBranch, Network } from 'lucide-svelte';
	import { selectedNodes, previewEdges, autoRebuild } from '../../queries';
	import type { Topology, InterfaceNode as InterfaceNodeType } from '../../types/base';
	import type { GroupType } from '$lib/features/groups/types/base';
	import { getTopologyStateInfo } from '../../state';
	import { computeCommonTags } from '$lib/shared/utils/tags';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import { useBulkAddTagMutation, useBulkRemoveTagMutation } from '$lib/features/tags/queries';
	import { useCreateGroupMutation, createEmptyGroupFormData } from '$lib/features/groups/queries';
	import type { Node, Edge } from '@xyflow/svelte';
	import {
		topology_multiSelectActionBarCount,
		topology_multiSelectGroupName,
		topology_multiSelectNoBindings,
		topology_multiSelectPickBinding,
		common_cancel,
		common_clearSelection,
		common_confirm,
		groups_createGroup
	} from '$lib/paraglide/messages';

	let {
		topology,
		isReadOnly = false,
		onClearSelection,
		onGroupCreated
	}: {
		topology: Topology;
		isReadOnly?: boolean;
		onClearSelection: () => void;
		onGroupCreated?: (groupId: string) => void;
	} = $props();

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
	let selectedHosts = $derived(topology.hosts.filter((h) => selectedHostIds.includes(h.id)));

	// Common tags across selected hosts
	let commonHostTags = $derived(computeCommonTags(selectedHosts));

	// Check if topology allows mutations
	let canMutate = $derived.by(() => {
		if (isReadOnly) return false;
		const stateInfo = getTopologyStateInfo(topology, get(autoRebuild));
		return stateInfo.type === 'fresh' && !topology.is_locked;
	});

	// Tag handlers (bulk operations on host IDs)
	async function handleAddTag(tagId: string) {
		await bulkAddTagMutation.mutateAsync({
			entity_ids: selectedHostIds,
			entity_type: 'Host',
			tag_id: tagId
		});
	}

	async function handleRemoveTag(tagId: string) {
		await bulkRemoveTagMutation.mutateAsync({
			entity_ids: selectedHostIds,
			entity_type: 'Host',
			tag_id: tagId
		});
	}

	// Group creation state
	let isCreatingGroup = $state(false);
	let groupType: GroupType = $state('RequestPath');
	let groupName = $state('');

	// Binding disambiguation: for each selected host, pick which binding to include
	interface HostBindingChoice {
		hostId: string;
		hostName: string;
		bindings: { id: string; label: string }[];
		selectedBindingId: string | null;
	}

	let hostBindingChoices = $derived.by(() => {
		const choices: HostBindingChoice[] = [];
		for (const host of selectedHosts) {
			// Find services for this host that have bindings
			const hostServices = topology.services.filter((s) => s.host_id === host.id);
			const allBindings: { id: string; label: string }[] = [];
			for (const service of hostServices) {
				for (const binding of service.bindings) {
					allBindings.push({
						id: binding.id,
						label: `${service.name} (${binding.type})`
					});
				}
			}
			choices.push({
				hostId: host.id,
				hostName: host.name,
				bindings: allBindings,
				selectedBindingId: allBindings.length === 1 ? allBindings[0].id : null
			});
		}
		return choices;
	});

	// Local copy for editing binding selections
	const bindingSelections = new SvelteMap<string, string | null>();

	function initBindingSelections() {
		bindingSelections.clear();
		for (const choice of hostBindingChoices) {
			bindingSelections.set(
				choice.hostId,
				choice.bindings.length === 1 ? choice.bindings[0].id : null
			);
		}
	}

	function startGroupCreation() {
		isCreatingGroup = true;
		groupName = '';
		initBindingSelections();
	}

	function cancelGroupCreation() {
		isCreatingGroup = false;
		groupName = '';
		previewEdges.set([]);
	}

	async function confirmGroupCreation() {
		// Collect selected binding IDs
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

		const created = await createGroupMutation.mutateAsync(newGroup);
		previewEdges.set([]);
		isCreatingGroup = false;
		onGroupCreated?.(created.id);
	}

	// Preview edges on hover over group type area
	function showPreviewEdges() {
		const nodeIds = nodes.map((n) => n.id);
		if (nodeIds.length < 2) return;

		const preview: Edge[] = [];
		if (groupType === 'RequestPath') {
			// Chain edges: node1→node2→node3...
			for (let i = 0; i < nodeIds.length - 1; i++) {
				preview.push({
					id: `preview-${i}`,
					source: nodeIds[i],
					target: nodeIds[i + 1],
					type: 'custom',
					style: 'stroke-dasharray: 5 5; opacity: 0.5;',
					data: {
						edge_type: 'Preview',
						is_preview: true
					},
					animated: true
				});
			}
		} else {
			// HubSpoke: first node is hub
			for (let i = 1; i < nodeIds.length; i++) {
				preview.push({
					id: `preview-${i}`,
					source: nodeIds[0],
					target: nodeIds[i],
					type: 'custom',
					style: 'stroke-dasharray: 5 5; opacity: 0.5;',
					data: {
						edge_type: 'Preview',
						is_preview: true
					},
					animated: true
				});
			}
		}
		previewEdges.set(preview);
	}

	function hidePreviewEdges() {
		previewEdges.set([]);
	}
</script>

<div class="absolute bottom-4 left-1/2 z-20 -translate-x-1/2 transform">
	<div class="card card-static flex items-center gap-3 px-4 py-2 shadow-lg">
		<!-- Count -->
		<span class="text-secondary whitespace-nowrap text-sm font-medium">
			{topology_multiSelectActionBarCount({ count: nodes.length })}
		</span>

		<!-- Clear button -->
		<button class="btn-icon p-1" onclick={onClearSelection} title={common_clearSelection()}>
			<X class="h-4 w-4" />
		</button>

		{#if canMutate}
			<div class="card-divider-v self-stretch"></div>

			<!-- Tags -->
			<div class="flex items-center gap-1">
				<TagPickerInline
					selectedTagIds={commonHostTags}
					onAdd={handleAddTag}
					onRemove={handleRemoveTag}
				/>
			</div>

			<div class="card-divider-v self-stretch"></div>

			{#if !isCreatingGroup}
				<!-- Group type toggle + Create Group -->
				<div
					class="flex items-center gap-2"
					role="group"
					onmouseenter={showPreviewEdges}
					onmouseleave={hidePreviewEdges}
				>
					<div class="flex rounded-md border border-gray-600">
						<button
							class="px-2 py-1 text-xs transition-colors {groupType === 'RequestPath'
								? 'bg-blue-600 text-white'
								: 'text-secondary hover:text-primary'}"
							onclick={() => {
								groupType = 'RequestPath';
								showPreviewEdges();
							}}
							title="Request Path"
						>
							<GitBranch class="h-3.5 w-3.5" />
						</button>
						<button
							class="px-2 py-1 text-xs transition-colors {groupType === 'HubAndSpoke'
								? 'bg-blue-600 text-white'
								: 'text-secondary hover:text-primary'}"
							onclick={() => {
								groupType = 'HubAndSpoke';
								showPreviewEdges();
							}}
							title="Hub & Spoke"
						>
							<Network class="h-3.5 w-3.5" />
						</button>
					</div>

					<button class="btn-primary text-xs" onclick={startGroupCreation}>
						{groups_createGroup()}
					</button>
				</div>
			{:else}
				<!-- Inline group creation form -->
				<div class="flex flex-col gap-2">
					<div class="flex items-center gap-2">
						<input
							type="text"
							bind:value={groupName}
							placeholder={topology_multiSelectGroupName()}
							class="h-7 w-40 rounded px-2 text-xs focus:outline-none focus:ring-1 focus:ring-blue-500"
							style="border: 1px solid var(--color-border-input); background: var(--color-bg-input); color: var(--color-text-primary)"
						/>
						<button
							class="btn-primary text-xs"
							onclick={confirmGroupCreation}
							disabled={!groupName.trim() || createGroupMutation.isPending}
						>
							{common_confirm()}
						</button>
						<button class="btn-secondary text-xs" onclick={cancelGroupCreation}>
							{common_cancel()}
						</button>
					</div>

					<!-- Binding disambiguation for hosts with multiple bindings -->
					{#each hostBindingChoices as choice (choice.hostId)}
						{#if choice.bindings.length === 0}
							<div class="text-tertiary text-xs">
								{choice.hostName}: {topology_multiSelectNoBindings()}
							</div>
						{:else if choice.bindings.length > 1}
							<div class="flex items-center gap-2 text-xs">
								<span class="text-secondary truncate" style="max-width: 120px"
									>{choice.hostName}:</span
								>
								<select
									class="h-6 rounded px-1 text-xs"
									style="border: 1px solid var(--color-border-input); background: var(--color-bg-input); color: var(--color-text-primary)"
									value={bindingSelections.get(choice.hostId) ?? ''}
									onchange={(e) => {
										const target = e.target as HTMLSelectElement;
										bindingSelections.set(choice.hostId, target.value || null);
									}}
								>
									<option value="">{topology_multiSelectPickBinding()}</option>
									{#each choice.bindings as binding (binding.id)}
										<option value={binding.id}>{binding.label}</option>
									{/each}
								</select>
							</div>
						{/if}
					{/each}
				</div>
			{/if}
		{/if}
	</div>
</div>
