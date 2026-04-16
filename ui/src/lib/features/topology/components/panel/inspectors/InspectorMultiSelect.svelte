<script lang="ts">
	import { get } from 'svelte/store';
	import { SvelteMap, SvelteSet } from 'svelte/reactivity';
	import { Eye, EyeOff, X, Crosshair, ArrowDown } from 'lucide-svelte';
	import { useSvelteFlow } from '@xyflow/svelte';
	import {
		selectedNodes,
		previewEdges,
		autoRebuild,
		useRebuildTopologyMutation,
		activeView,
		topologyOptions,
		updateSharedElementRules
	} from '../../../queries';
	import type { Topology } from '../../../types/base';
	import type { TopologyNode } from '../../../types/base';
	import {
		getNodeSelectionIds,
		resolveDependencyTargets,
		type DependencyTarget
	} from '../../../resolvers';
	import type { DependencyType, EdgeStyle } from '$lib/features/dependencies/types/base';
	import { generateDependencyName } from '$lib/features/dependencies/utils';
	import { getTopologyEditState } from '../../../state';
	import { computeCommonTags } from '$lib/shared/utils/tags';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import {
		useTagsQuery,
		useBulkAddTagMutation,
		useBulkRemoveTagMutation
	} from '$lib/features/tags/queries';
	import {
		useCreateDependencyMutation,
		createEmptyDependencyFormData
	} from '$lib/features/dependencies/queries';
	import EdgeStyleForm from '$lib/features/dependencies/components/DependencyEditModal/EdgeStyleForm.svelte';
	import { dependencyTypes, concepts, views } from '$lib/shared/stores/metadata';
	import { getInspectorConfig } from './view-config';
	import DependencyTargetCard from './shared/DependencyTargetCard.svelte';
	import SegmentedControl from '$lib/shared/components/forms/SegmentedControl.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { createForm } from '@tanstack/svelte-form';
	import { submitForm } from '$lib/shared/components/forms/form-context';
	import { required, max } from '$lib/shared/components/forms/validators';
	import type { Node, Edge } from '@xyflow/svelte';
	import type { Color } from '$lib/shared/utils/styling';
	import { AVAILABLE_COLORS, createColorHelper } from '$lib/shared/utils/styling';
	import { browser } from '$app/environment';
	import {
		appWizard_selectedCount,
		topology_multiSelectCreateGroupRebuildWarning,
		topology_multiSelectLockedHint,
		topology_multiSelectStaleHint,
		topology_multiSelectReadOnlyHint,
		topology_multiSelectGroupName,
		common_clearSelection,
		common_services,
		common_hub,
		common_spokes,
		tags_entityTags,
		dependencies_calls,
		dependencies_createDependency,
		dependencies_dependencyName,
		dependencies_serves,
		dependencies_servicesOnly,
		dependencies_withPorts,
		topology_multiSelectPreviewEdge,
		topology_focusSelection,
		tags_crossGroupSelectionHint,
		tags_inheritedFromHost,
		tags_inheritedOverrideHint,
		inspector_createGroupingRuleFromTag,
		topology_tutorialDone,
		appWizard_applicationTags
	} from '$lib/paraglide/messages';

	let {
		topology,
		isReadOnly = false,
		isTutorial = false,
		onClearSelection,
		onGroupCreated,
		onDependencyTypeChange
	}: {
		topology: Topology | undefined;
		isReadOnly?: boolean;
		isTutorial?: boolean;
		onClearSelection: () => void;
		onGroupCreated?: (groupId: string) => void;
		onDependencyTypeChange?: (type: DependencyType) => void;
	} = $props();

	const { fitView } = useSvelteFlow();
	const PREVIEW_STORAGE_KEY = 'scanopy_topology_group_preview';

	const bulkAddTagMutation = useBulkAddTagMutation();
	const bulkRemoveTagMutation = useBulkRemoveTagMutation();
	const createDependencyMutation = useCreateDependencyMutation();
	const rebuildTopologyMutation = useRebuildTopologyMutation();

	// Subscribe to selectedNodes
	let nodes = $state<Node[]>(get(selectedNodes));
	selectedNodes.subscribe((value) => {
		nodes = value;
	});

	// Bulk-tag selection uses the legacy fan-out resolver (tagging a host = tagging its services)
	let selectionIds = $derived.by(() => {
		if (!topology) return { hostIds: [] as string[], serviceIds: [] as string[] };
		const hostSet = new SvelteSet<string>();
		const serviceSet = new SvelteSet<string>();
		for (const node of nodes) {
			const ids = getNodeSelectionIds(node.id, node.data as TopologyNode, topology);
			ids.hostIds.forEach((id) => hostSet.add(id));
			ids.serviceIds.forEach((id) => serviceSet.add(id));
		}
		return { hostIds: [...hostSet], serviceIds: [...serviceSet] };
	});

	let selectedHostIds = $derived(selectionIds.hostIds);
	let selectedHosts = $derived(
		topology ? topology.hosts.filter((h) => selectedHostIds.includes(h.id)) : []
	);
	let selectedServiceIds = $derived(selectionIds.serviceIds);
	let selectedServices = $derived(
		topology ? topology.services.filter((s) => selectedServiceIds.includes(s.id)) : []
	);

	// View-driven config
	let inspectorConfig = $derived(getInspectorConfig($activeView));
	let viewMeta = $derived(views.getMetadata($activeView) as Record<string, unknown> | null);
	let elementLabel = $derived.by(() => {
		const count = nodes.length;
		if (count === 1) return (viewMeta?.element_label_singular as string) ?? 'element';
		return (viewMeta?.element_label as string) ?? 'elements';
	});

	// Tag entity type — fixed by view config (no user toggle)
	let tagEntityType = $derived(inspectorConfig.bulk_tag_entity as 'Host' | 'Service');

	let tagEntityIds = $derived(tagEntityType === 'Host' ? selectedHostIds : selectedServiceIds);
	let tagEntities = $derived(tagEntityType === 'Host' ? selectedHosts : selectedServices);

	// Common tags across selected entities
	let commonTags = $derived(computeCommonTags(tagEntities));

	// Unified edit state — tutorial mode always allows edits
	let editState = $derived(
		isTutorial
			? { isReadonly: false, isEditable: true, disabledReason: null }
			: getTopologyEditState(topology, get(autoRebuild), isReadOnly)
	);

	let mutateDisabledReason = $derived.by(() => {
		if (!editState.disabledReason) return '';
		if (editState.disabledReason === 'readonly') return topology_multiSelectReadOnlyHint();
		if (editState.disabledReason === 'locked') return topology_multiSelectLockedHint();
		return topology_multiSelectStaleHint();
	});

	// Merge topology entity_tags with tags query cache for newly created tags
	const tagsQuery = useTagsQuery();
	let topoEntityTags = $derived.by(() => {
		const topoTags = topology?.entity_tags ?? [];
		const cachedTags = tagsQuery.data ?? [];
		const topoIds = new Set(topoTags.map((t) => t.id));
		return [...topoTags, ...cachedTags.filter((t) => !topoIds.has(t.id))];
	});

	let appTagIds = $derived(topoEntityTags.filter((t) => t.is_application).map((t) => t.id));

	let appTagSet = $derived(new Set(appTagIds));

	// Filtered tag lists for pickers
	let nonAppTags = $derived(topoEntityTags.filter((t) => !t.is_application));
	let appTags = $derived(topoEntityTags.filter((t) => t.is_application));

	// Common app tags across selected entities (for app picker selectedTagIds)
	let commonAppTags = $derived(commonTags.filter((id) => appTagSet.has(id)));
	let hasAppTag = $derived(commonAppTags.length > 0);

	// App-group available tags: if already tagged, only show current tag (for removal)
	let appAvailableTags = $derived(
		hasAppTag ? appTags.filter((t) => commonAppTags.includes(t.id)) : appTags
	);

	// Analyze each selected service's app status
	type AppInfo = { tagId: string; inherited: boolean } | null;

	let serviceAppInfos = $derived.by((): AppInfo[] => {
		if (!topology) return [];
		return selectedServices.map((service) => {
			// Check for direct app tag on the service
			for (const tagId of service.tags) {
				if (appTagSet.has(tagId)) {
					return { tagId, inherited: false };
				}
			}
			// Check for inherited app tag from host
			const host = topology!.hosts.find((h) => h.id === service.host_id);
			if (host) {
				for (const tagId of host.tags) {
					if (appTagSet.has(tagId)) {
						return { tagId, inherited: true };
					}
				}
			}
			return null; // Ungrouped
		});
	});

	// Overall app selection state
	let appState = $derived.by(() => {
		const infos = serviceAppInfos;
		if (infos.length === 0) return { type: 'ungrouped' as const };

		const uniqueTagIds = new Set(infos.map((i) => i?.tagId ?? '__ungrouped__'));
		if (uniqueTagIds.size > 1) return { type: 'cross-group' as const };

		const tagId = infos[0]?.tagId;
		if (!tagId) return { type: 'ungrouped' as const };

		const allInherited = infos.every((i) => i?.inherited === true);
		const allDirect = infos.every((i) => i?.inherited === false);
		return {
			type: 'single' as const,
			tagId,
			allInherited,
			allDirect,
			mixed: !allInherited && !allDirect
		};
	});

	// Get the tag object for the current app
	let currentAppTag = $derived.by(() => {
		if (appState.type !== 'single') return null;
		return topoEntityTags.find((t) => t.id === appState.tagId) ?? null;
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

	// Track recently added non-app tags for "create grouping rule" action
	let recentlyAddedTagIds = $state<string[]>([]);

	async function handleAddTagWithTracking(tagId: string) {
		await handleAddTag(tagId);
		// Only track non-app tags for grouping rule creation
		recentlyAddedTagIds = [...recentlyAddedTagIds, tagId];
	}

	// App-group tag handler (no grouping rule tracking)
	async function handleAddAppTag(tagId: string) {
		await handleAddTag(tagId);
	}

	// Check if a ByTag rule already exists covering the recently added tags
	let existingRuleCoversRecentTags = $derived.by(() => {
		if (recentlyAddedTagIds.length === 0) return false;
		const rules = $topologyOptions?.request?.element_rules ?? [];
		const recentSet = new Set(recentlyAddedTagIds);
		return rules.some((rule) => {
			if (typeof rule.rule === 'object' && 'ByTag' in rule.rule) {
				const ruleTagIds = rule.rule.ByTag.tag_ids;
				return ruleTagIds.some((id: string) => recentSet.has(id));
			}
			return false;
		});
	});

	// Resolve recently added tags to tag objects for display
	let recentlyAddedTags = $derived(
		recentlyAddedTagIds
			.map(
				(id) =>
					topoEntityTags.find((t) => t.id === id) ?? topology?.entity_tags?.find((t) => t.id === id)
			)
			.filter(Boolean)
	);

	function createGroupingRuleFromTags(tagIds: string[]) {
		updateSharedElementRules((current) => [
			...current,
			{
				id: crypto.randomUUID(),
				rule: { ByTag: { tag_ids: tagIds, title: null } }
			}
		]);
		recentlyAddedTagIds = [];
		// Rebuild topology to apply the new grouping rule
		if (topology) {
			rebuildTopologyMutation.mutate(topology);
		}
	}

	// Dependency creation state — always visible, no expand/collapse
	function getNodeNames(): string[] {
		return nodes.map((n) => (n.data as TopologyNode)?.header ?? '').filter(Boolean);
	}

	// Edge styling lives outside the TanStack form (same pattern as DependencyEditModal):
	// EdgeStyleForm manages it via bindable callbacks.
	let dependencyColor: Color = $state(
		AVAILABLE_COLORS[Math.floor(Math.random() * AVAILABLE_COLORS.length)]
	);
	let dependencyEdgeStyle: EdgeStyle = $state('Bezier');
	let edgeStyleCollapsed = $state(true);

	// Initial default for dependency type — forwarded to the form's defaults.
	const DEFAULT_DEP_TYPE: DependencyType = 'RequestPath';

	let memberModeOptions = $derived([
		{ value: 'Services', label: dependencies_servicesOnly() },
		{ value: 'Bindings', label: dependencies_withPorts() }
	]);

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

	// Fake dependency data for EdgeStyleForm binding
	let edgeStyleFormData = $derived({
		color: dependencyColor,
		edge_style: dependencyEdgeStyle,
		id: '',
		name: '',
		description: '',
		members: [],
		created_at: '',
		updated_at: '',
		dependency_type: DEFAULT_DEP_TYPE,
		source: { type: 'Manual' as const },
		network_id: '',
		tags: []
	});

	// ----- Element-aware dependency creation -----

	// Resolve selected nodes to dependency targets (service / host / ipAddress).
	// Each non-service target requires the user to pick its services.
	let depTargets = $derived<DependencyTarget[]>(
		topology ? resolveDependencyTargets(nodes, topology) : []
	);

	// L3 (or any view marking Bindings required) forces the binding toggle on.
	let bindingsRequired = $derived(inspectorConfig.dependency_creation === 'Bindings');

	// Single TanStack form. `picks` is a single-select per multi-candidate target
	// (`picks.<elementId> = <chosen serviceId>`); `bindings.<serviceId> = <bindingId>`.
	// Service / single-candidate targets don't need form entries — derived resolution
	// knows their service ID directly.
	type MemberMode = 'Services' | 'Bindings';
	interface DepFormValues {
		name: string;
		dependency_type: DependencyType;
		memberMode: MemberMode;
		picks: Record<string, string>;
		bindings: Record<string, string>;
	}

	// Each card's resolved service, in canvas selection order.
	interface ResolvedService {
		serviceId: string;
		ipAddressIdFilter: string | null;
	}

	const form = createForm(() => ({
		defaultValues: {
			name: '',
			dependency_type: DEFAULT_DEP_TYPE,
			memberMode: 'Services' as MemberMode,
			picks: {} as Record<string, string>,
			bindings: {} as Record<string, string>
		} as DepFormValues,
		onSubmit: async ({ value }) => {
			if (!topology) return;
			const v = value as DepFormValues;

			const newDependency = createEmptyDependencyFormData(topology.network_id);
			newDependency.name = v.name.trim();
			newDependency.dependency_type = v.dependency_type;
			newDependency.color = dependencyColor;
			newDependency.edge_style = dependencyEdgeStyle;

			if (v.memberMode === 'Bindings') {
				const bindingIds: string[] = [];
				for (const r of resolvedServices) {
					const id = v.bindings?.[r.serviceId];
					if (!id) return;
					bindingIds.push(id);
				}
				newDependency.members = { type: 'Bindings', binding_ids: bindingIds };
			} else {
				newDependency.members = {
					type: 'Services',
					service_ids: resolvedServices.map((r) => r.serviceId)
				};
			}

			const created = await createDependencyMutation.mutateAsync(newDependency);
			previewEdges.set([]);
			onGroupCreated?.(created.id);
		}
	}));

	// TanStack Form's `form.state.values` is not tracked by Svelte 5 $derived.
	// Mirror it into a $state via form.store.subscribe (pattern from CreateDaemonModal).
	let formValues = $state<DepFormValues>({
		name: '',
		dependency_type: DEFAULT_DEP_TYPE,
		memberMode: 'Services',
		picks: {},
		bindings: {}
	});
	$effect(() => {
		return form.store.subscribe(() => {
			const v = form.state.values as DepFormValues;
			formValues = {
				name: v.name ?? '',
				dependency_type: v.dependency_type ?? DEFAULT_DEP_TYPE,
				memberMode: v.memberMode ?? 'Services',
				picks: { ...(v.picks ?? {}) },
				bindings: { ...(v.bindings ?? {}) }
			};
		});
	});

	let resolvedServices = $derived<ResolvedService[]>(
		(() => {
			if (!topology) return [] as ResolvedService[];
			const out: ResolvedService[] = [];
			const picksMap = formValues.picks;
			for (const target of depTargets) {
				if (target.kind === 'service') {
					out.push({ serviceId: target.serviceId, ipAddressIdFilter: null });
				} else {
					if (target.candidateServiceIds.length === 0) continue;
					const picked =
						target.candidateServiceIds.length === 1
							? target.candidateServiceIds[0]
							: (picksMap[target.elementId] ?? target.candidateServiceIds[0]);
					out.push({
						serviceId: picked,
						ipAddressIdFilter: target.kind === 'ipAddress' ? target.ipAddressId : null
					});
				}
			}
			return out;
		})()
	);

	let allServicesHaveBindings = $derived(
		resolvedServices.length > 0 && resolvedServices.every((r) => !!formValues.bindings[r.serviceId])
	);

	// Keep the view-driven "bindings required" flag in sync with the form.
	$effect(() => {
		if (bindingsRequired && formValues.memberMode !== 'Bindings') {
			form.setFieldValue('memberMode', 'Bindings');
		}
	});

	// Bubble dependency_type changes to the parent (tutorial checklist watches this).
	$effect(() => {
		onDependencyTypeChange?.(formValues.dependency_type);
	});

	let lastAutoName = $state('');
	// Auto-generate dependency name when type or selection changes, unless the user edited it.
	$effect(() => {
		const newName = generateDependencyName(formValues.dependency_type, getNodeNames());
		if (
			(formValues.name === '' || formValues.name === lastAutoName) &&
			formValues.name !== newName
		) {
			form.setFieldValue('name', newName);
		}
		lastAutoName = newName;
	});

	let canCreate = $derived.by(() => {
		if (!formValues.name.trim()) return false;
		if (createDependencyMutation.isPending) return false;
		if (resolvedServices.length < 2) return false;
		if (formValues.memberMode === 'Bindings' && !allServicesHaveBindings) return false;
		return true;
	});

	async function confirmGroupCreation() {
		if (!canCreate) return;
		await submitForm(form);
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

		const colorHelper = createColorHelper(dependencyColor);
		const preview: Edge[] = [];
		const depType = formValues.dependency_type;

		if (depType === 'RequestPath') {
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
						dependency_id: '__preview__',
						preview_color: dependencyColor,
						preview_edge_style: dependencyEdgeStyle
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
						dependency_id: '__preview__',
						preview_color: dependencyColor,
						preview_edge_style: dependencyEdgeStyle
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
			void dependencyColor;
			void formValues.dependency_type;
			void dependencyEdgeStyle;
			void nodes;
			updatePreviewEdges();
		}
	});
</script>

<div class="w-full space-y-4">
	<!-- Header with count, focus, and clear -->
	<div class="flex items-center justify-between">
		<span class="text-secondary text-sm font-medium">
			{appWizard_selectedCount({ count: nodes.length, label: elementLabel })}
		</span>
		<div class="flex items-center gap-1">
			{#if !isTutorial}
				<button
					class="btn-icon p-1"
					onclick={() =>
						fitView({ nodes: nodes.map((n) => ({ id: n.id })), padding: 0.5, duration: 300 })}
					title={topology_focusSelection()}
				>
					<Crosshair class="h-4 w-4" />
				</button>
			{/if}
			{#if !isTutorial}
				<button class="btn-icon p-1" onclick={onClearSelection} title={common_clearSelection()}>
					<X class="h-4 w-4" />
				</button>
			{/if}
		</div>
	</div>

	{#if editState.isEditable}
		{#if !isTutorial}
			<!-- Tags section -->
			<div class="space-y-2">
				<span class="text-secondary block text-sm font-medium"
					>{tags_entityTags({ entity: tagEntityType })}</span
				>
				<div class="card card-static space-y-2 p-2">
					<div class="flex items-center gap-1.5">
						<TagPickerInline
							selectedTagIds={commonTags.filter((id) => !appTagSet.has(id))}
							onAdd={handleAddTagWithTracking}
							onRemove={handleRemoveTag}
							availableTags={nonAppTags}
						/>
					</div>
					{#if recentlyAddedTagIds.length > 0 && !existingRuleCoversRecentTags}
						<button
							class="btn-secondary flex w-full items-center justify-center gap-1.5 text-xs"
							onclick={() => createGroupingRuleFromTags(recentlyAddedTagIds)}
						>
							<span>{inspector_createGroupingRuleFromTag()}</span>
							{#each recentlyAddedTags as tag (tag?.id)}
								{#if tag}
									<Tag label={tag.name} color={tag.color} />
								{/if}
							{/each}
						</button>
					{/if}
				</div>
			</div>

			{#if inspectorConfig.show_application_picker}
				<!-- App-group tag picker — with cross-group and inheritance awareness -->
				<div class="space-y-2">
					<span class="text-secondary block text-sm font-medium">{appWizard_applicationTags()}</span
					>
					<div class="card card-static space-y-2 p-2">
						{#if appState.type === 'cross-group'}
							<p class="text-tertiary text-xs">{tags_crossGroupSelectionHint()}</p>
						{:else}
							{#if appState.type === 'single' && appState.allInherited && currentAppTag}
								<div class="flex flex-wrap items-center gap-1">
									<Tag
										label={currentAppTag.name}
										color={currentAppTag.color}
										icon={concepts.getIconComponent('Application')}
										isShiny={true}
									/>
									<span class="text-tertiary text-xs">{tags_inheritedFromHost()}</span>
								</div>
								<p class="text-tertiary text-xs">{tags_inheritedOverrideHint()}</p>
							{/if}
							<TagPickerInline
								selectedTagIds={commonAppTags}
								onAdd={handleAddAppTag}
								onRemove={handleRemoveTag}
								availableTags={appAvailableTags}
								allowCreate={false}
							/>
						{/if}
					</div>
				</div>
			{/if}
		{/if}

		{#if inspectorConfig.dependency_creation}
			<!-- Dependency creation — flat layout, no outer wrapping card -->
			<div class="space-y-3">
				<span class="text-secondary block text-sm font-medium"
					>{dependencies_createDependency()}</span
				>

				<!-- Dependency type toggle + preview button -->
				<form.Field name="dependency_type">
					{#snippet children(field)}
						<div class="flex items-center gap-2">
							<SegmentedControl
								options={['RequestPath', 'HubAndSpoke'].map((type) => ({
									value: type,
									label: '',
									icon: dependencyTypes.getIconComponent(type)
								}))}
								selected={field.state.value}
								onchange={(v) => field.handleChange(v as DependencyType)}
							/>
							<span class="text-secondary text-xs"
								>{dependencyTypes.getName(field.state.value)}</span
							>
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
					{/snippet}
				</form.Field>

				<!-- Name input -->
				<form.Field
					name="name"
					validators={{
						onBlur: ({ value }: { value: string }) => required(value) || max(100)(value)
					}}
				>
					{#snippet children(field)}
						<TextInput
							label={dependencies_dependencyName()}
							id="dependency-name"
							{field}
							placeholder={topology_multiSelectGroupName()}
						/>
					{/snippet}
				</form.Field>

				<!-- Edge style & color — collapsed by default; matches how EdgeStyleForm
				     renders on a selected dep edge. -->
				<div class="card card-static p-2">
					<EdgeStyleForm
						bind:formData={edgeStyleFormData}
						bind:collapsed={edgeStyleCollapsed}
						editable={true}
						showCollapseToggle={true}
						onColorChange={(c) => (dependencyColor = c)}
						onEdgeStyleChange={(s) => (dependencyEdgeStyle = s)}
					/>
				</div>

				<!-- Services only / With ports -->
				{#if !isTutorial && !bindingsRequired}
					<form.Field name="memberMode">
						{#snippet children(field)}
							<SegmentedControl
								options={memberModeOptions}
								selected={field.state.value}
								onchange={(v) => field.handleChange(v as MemberMode)}
								size="sm"
								fullWidth={true}
							/>
						{/snippet}
					</form.Field>
				{/if}

				<!-- Services section: one card per selection, in canvas order.
				     Between-card arrow + direction label:
				       RequestPath: "↓ calls" between every pair of cards.
				       HubAndSpoke: "↓ serves" between Hub card and Spokes header. -->
				{#if !isTutorial && topology && depTargets.length > 0}
					{@const depType = formValues.dependency_type}
					<div class="space-y-2">
						<span class="text-secondary block text-sm font-medium">{common_services()}</span>
						{#each depTargets as target, targetIdx (target.elementId)}
							{@const flatIndex = depTargets
								.slice(0, targetIdx)
								.filter((t) => t.kind === 'service' || t.candidateServiceIds.length > 0).length}
							{#if depType === 'HubAndSpoke' && targetIdx === 0}
								<span class="text-tertiary block text-xs font-semibold uppercase"
									>{common_hub()}</span
								>
							{:else if depType === 'HubAndSpoke' && targetIdx === 1}
								<div class="flex flex-col items-center gap-0.5">
									<ArrowDown class="text-secondary h-4 w-4" />
									<span class="text-tertiary text-xs">{dependencies_serves()}</span>
								</div>
								<span class="text-tertiary mt-2 block text-xs font-semibold uppercase"
									>{common_spokes()}</span
								>
							{/if}
							<DependencyTargetCard {form} {topology} {target} {flatIndex} />
							{#if depType === 'RequestPath' && targetIdx < depTargets.length - 1}
								<div class="flex flex-col items-center gap-0.5">
									<ArrowDown class="text-secondary h-4 w-4" />
									<span class="text-tertiary text-xs">{dependencies_calls()}</span>
								</div>
							{/if}
						{/each}
					</div>
				{/if}

				<!-- Rebuild warning (only when auto-rebuild is off) + Create button -->
				{#if isTutorial}
					<button class="btn-primary w-full text-xs" onclick={onClearSelection}>
						{topology_tutorialDone()}
					</button>
				{:else}
					<div class="space-y-2">
						{#if !$autoRebuild}
							<p class="text-tertiary text-xs">
								{topology_multiSelectCreateGroupRebuildWarning()}
							</p>
						{/if}
						<button
							class="btn-primary w-full text-xs"
							onclick={confirmGroupCreation}
							disabled={!canCreate}
						>
							{dependencies_createDependency()}
						</button>
					</div>
				{/if}
			</div>
		{/if}
	{:else}
		<!-- Show reason why actions are unavailable -->
		{#if mutateDisabledReason}
			<div class="text-tertiary py-2 text-center text-sm">
				{mutateDisabledReason}
			</div>
		{/if}
	{/if}
</div>
