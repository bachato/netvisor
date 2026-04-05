<script lang="ts">
	import {
		topologyOptions,
		updateTopologyOptions,
		selectedTopologyId,
		useTopologiesQuery,
		autoRebuild
	} from '../../../queries';
	import { updateTagFilter, hoveredEdgeType } from '../../../interactions';
	import { getTopologyEditState, getOptionDisabledTooltip } from '../../../state';
	import { edgeTypes, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Color } from '$lib/shared/utils/styling';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import TagFilterGroup from './TagFilterGroup.svelte';
	import OptionToggle from './OptionToggle.svelte';
	import CategoryFilterGroup from './CategoryFilterGroup.svelte';
	import FilterGroup from './FilterGroup.svelte';
	import GroupingRuleEditor from './GroupingRuleEditor.svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import { SvelteSet } from 'svelte/reactivity';
	import { activePerspective } from '../../../queries';
	import {
		common_hosts,
		common_services,
		common_subnets,
		common_visual,
		topology_bundleEdges,
		topology_bundleEdgesHelp,
		topology_dontFadeEdges,
		topology_dontFadeEdgesHelp,
		topology_groupBy,
		topology_hidePorts,
		topology_hidePortsHelp,
		topology_hideResizeHandles,
		topology_hideResizeHandlesHelp,
		topology_showMinimap,
		topology_showMinimapHelp,
		common_byCategory,
		common_byTag,
		common_byType,
		common_edges,
		common_filters,
		topology_filtersHelp,
		topology_hideVmOnContainer,
		topology_hideVmOnContainerHelp
	} from '$lib/paraglide/messages';

	// Get topology for entity_tags
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(topologiesData.find((t) => t.id === $selectedTopologyId));

	// Unified edit state for gating request-path options
	let editState = $derived(getTopologyEditState(topology, $autoRebuild, false));

	// Tags query — always up-to-date, survives SSE topology overwrites
	const tagsQuery = useTagsQuery();
	let allTags = $derived(tagsQuery.data ?? []);

	// Derive tags that are actually used per entity type
	let hostTagIds = $derived(new Set(topology?.hosts.flatMap((h) => h.tags) ?? []));
	let serviceTagIds = $derived(new Set(topology?.services.flatMap((s) => s.tags) ?? []));
	let subnetTagIds = $derived(new Set(topology?.subnets.flatMap((s) => s.tags) ?? []));

	// Filter tags to only those used by each entity type (from tags query, not entity_tags)
	let hostTags = $derived(allTags.filter((t) => hostTagIds.has(t.id)));
	let serviceTags = $derived(allTags.filter((t) => serviceTagIds.has(t.id)));
	let subnetTags = $derived(allTags.filter((t) => subnetTagIds.has(t.id)));

	// Check if there are any untagged entities
	let hasUntaggedHosts = $derived(topology?.hosts.some((h) => h.tags.length === 0) ?? false);
	let hasUntaggedServices = $derived(topology?.services.some((s) => s.tags.length === 0) ?? false);
	let hasUntaggedSubnets = $derived(topology?.subnets.some((s) => s.tags.length === 0) ?? false);

	// Toggle functions for tag filter
	function toggleHostTag(tagId: string) {
		updateTopologyOptions((opts) => {
			const currentFilter = opts.local.tag_filter;
			const hiddenIds = currentFilter?.hidden_host_tag_ids ?? [];
			const idx = hiddenIds.indexOf(tagId);
			const newHiddenIds =
				idx === -1 ? [...hiddenIds, tagId] : hiddenIds.filter((id) => id !== tagId);
			opts.local.tag_filter = {
				hidden_host_tag_ids: newHiddenIds,
				hidden_service_tag_ids: currentFilter?.hidden_service_tag_ids ?? [],
				hidden_subnet_tag_ids: currentFilter?.hidden_subnet_tag_ids ?? []
			};
			return opts;
		});
	}

	function toggleServiceTag(tagId: string) {
		updateTopologyOptions((opts) => {
			const currentFilter = opts.local.tag_filter;
			const hiddenIds = currentFilter?.hidden_service_tag_ids ?? [];
			const idx = hiddenIds.indexOf(tagId);
			const newHiddenIds =
				idx === -1 ? [...hiddenIds, tagId] : hiddenIds.filter((id) => id !== tagId);
			opts.local.tag_filter = {
				hidden_host_tag_ids: currentFilter?.hidden_host_tag_ids ?? [],
				hidden_service_tag_ids: newHiddenIds,
				hidden_subnet_tag_ids: currentFilter?.hidden_subnet_tag_ids ?? []
			};
			return opts;
		});
	}

	function toggleSubnetTag(tagId: string) {
		updateTopologyOptions((opts) => {
			const currentFilter = opts.local.tag_filter;
			const hiddenIds = currentFilter?.hidden_subnet_tag_ids ?? [];
			const idx = hiddenIds.indexOf(tagId);
			const newHiddenIds =
				idx === -1 ? [...hiddenIds, tagId] : hiddenIds.filter((id) => id !== tagId);
			opts.local.tag_filter = {
				hidden_host_tag_ids: currentFilter?.hidden_host_tag_ids ?? [],
				hidden_service_tag_ids: currentFilter?.hidden_service_tag_ids ?? [],
				hidden_subnet_tag_ids: newHiddenIds
			};
			return opts;
		});
	}

	// Track categories being unhidden to prevent flicker during topology rebuild
	let pendingUnhideCategories = new SvelteSet<string>();

	// Clear pending unhide categories when topology reference changes (rebuild completed)
	$effect(() => {
		// Access topology to create dependency
		void topology;
		if (pendingUnhideCategories.size > 0) {
			pendingUnhideCategories.clear();
		}
	});

	function toggleServiceCategory(category: string) {
		updateTopologyOptions((opts) => {
			const hidden = opts.request.hide_service_categories ?? [];
			const idx = hidden.indexOf(category as (typeof hidden)[number]);
			const isUnhiding = idx !== -1;
			const newHidden = isUnhiding
				? hidden.filter((c) => c !== category)
				: [...hidden, category as (typeof hidden)[number]];

			if (isUnhiding) {
				pendingUnhideCategories.add(category);
			}

			return {
				...opts,
				request: {
					...opts.request,
					hide_service_categories: newHidden
				}
			};
		});
	}

	function toggleEdgeType(edgeType: string) {
		updateTopologyOptions((opts) => {
			const hidden = opts.local.hide_edge_types ?? [];
			const idx = hidden.indexOf(edgeType as (typeof hidden)[number]);
			const newHidden =
				idx === -1
					? [...hidden, edgeType as (typeof hidden)[number]]
					: hidden.filter((e) => e !== edgeType);
			return {
				...opts,
				local: {
					...opts.local,
					hide_edge_types: newHidden
				}
			};
		});
	}

	function handleEdgeTypeHoverStart(value: string, color: Color) {
		hoveredEdgeType.set({ edgeType: value, color: color as string });
	}

	function handleEdgeTypeHoverEnd() {
		hoveredEdgeType.set(null);
	}

	// Update tag filter stores when topology or options change
	$effect(() => {
		updateTagFilter(topology, $topologyOptions.local.tag_filter);
	});

	// Build categories with colors from services present in the topology
	let serviceCategoriesWithColors = $derived.by(() => {
		if (!topology?.services) return [];
		const seen: Record<string, boolean> = {};
		const result: { value: string; label: string; color: Color }[] = [];
		for (const service of topology.services) {
			const category = serviceDefinitions.getCategory(service.service_definition);
			if (category && !seen[category]) {
				seen[category] = true;
				const color = serviceDefinitions.getColorHelper(service.service_definition).color;
				result.push({ value: category, label: category, color });
			}
		}
		return result.sort((a, b) => a.label.localeCompare(b.label));
	});

	// All categories including hidden ones and pending unhides (for Hide Stuff section).
	// Hidden categories are removed from topology.services by the backend,
	// so we need to merge them back from the request options + service definitions.
	// Pending unhide categories are kept visible during the rebuild debounce window.
	let allServiceCategoriesWithColors = $derived.by(() => {
		const hiddenCategories = $topologyOptions.request.hide_service_categories ?? [];
		const extraCategories = [...hiddenCategories, ...pendingUnhideCategories];
		if (extraCategories.length === 0) return serviceCategoriesWithColors;

		const seen = new SvelteSet(serviceCategoriesWithColors.map((c) => c.value));
		const result = [...serviceCategoriesWithColors];

		for (const category of extraCategories) {
			if (seen.has(category)) continue;
			seen.add(category);
			// Find any service definition with this category to get the color
			const allDefs = serviceDefinitions.getItems();
			const def = allDefs.find((d) => d.category === category);
			if (def) {
				const color = serviceDefinitions.getColorHelper(def.id).color;
				result.push({ value: category, label: category, color });
			}
		}

		return result.sort((a, b) => a.label.localeCompare(b.label));
	});

	// Build edge types with colors from edges present in the topology
	// Filter out edge types where all edges have classification === 'disabled'
	let edgeTypesWithColors = $derived.by(() => {
		if (!topology?.edges) return [];
		const seen: Record<string, boolean> = {};
		const result: { value: string; label: string; color: Color }[] = [];
		for (const edge of topology.edges) {
			const edgeType = edge.edge_type;
			if (edgeType && !seen[edgeType] && edge.classification !== 'disabled') {
				seen[edgeType] = true;
				const colorHelper = edgeTypes.getColorHelper(edgeType);
				result.push({ value: edgeType, label: edgeType, color: colorHelper.color });
			}
		}
		return result.sort((a, b) => a.label.localeCompare(b.label));
	});

	interface TopologyFieldDef {
		id: string;
		label: () => string;
		type: 'boolean' | 'string';
		path: 'local' | 'request';
		key: string;
		helpText: () => string;
		section: () => string;
		placeholder?: () => string;
	}

	const fieldDefs: TopologyFieldDef[] = [
		// Visual section
		{
			id: 'bundle_edges',
			label: () => topology_bundleEdges(),
			type: 'boolean',
			path: 'local',
			key: 'bundle_edges',
			helpText: () => topology_bundleEdgesHelp(),
			section: () => common_visual()
		},
		{
			id: 'no_fade_edges',
			label: () => topology_dontFadeEdges(),
			type: 'boolean',
			path: 'local',
			key: 'no_fade_edges',
			helpText: () => topology_dontFadeEdgesHelp(),
			section: () => common_visual()
		},
		{
			id: 'hide_resize_handles',
			label: () => topology_hideResizeHandles(),
			type: 'boolean',
			path: 'local',
			key: 'hide_resize_handles',
			helpText: () => topology_hideResizeHandlesHelp(),
			section: () => common_visual()
		},
		{
			id: 'show_minimap',
			label: () => topology_showMinimap(),
			type: 'boolean',
			path: 'local',
			key: 'show_minimap',
			helpText: () => topology_showMinimapHelp(),
			section: () => common_visual()
		},
		{
			id: 'hide_vm_title_on_docker_container',
			label: () => topology_hideVmOnContainer(),
			type: 'boolean',
			path: 'request',
			key: 'hide_vm_title_on_docker_container',
			helpText: () => topology_hideVmOnContainerHelp(),
			section: () => common_visual()
		},
		{
			id: 'hide_ports',
			label: () => topology_hidePorts(),
			type: 'boolean',
			path: 'request',
			key: 'hide_ports',
			helpText: () => topology_hidePortsHelp(),
			section: () => common_visual()
		}
	];

	// Get unique section names in order
	let sectionNames = $derived([...new Set(fieldDefs.map((d) => d.section()))]);

	// Group fields by section
	let sections = $derived(
		sectionNames.map((name) => ({
			name,
			fields: fieldDefs.filter((d) => d.section() === name)
		}))
	);

	// Track expanded sections
	let expandedSections = $state<Record<string, boolean>>(
		Object.fromEntries(
			[common_visual(), topology_groupBy(), common_filters()].map((name) => [name, true])
		)
	);

	// Create form values initialized from topologyOptions
	let values = $state<Record<string, boolean | string | string[]>>({});

	// Initialize values from topologyOptions
	$effect(() => {
		const opts = $topologyOptions;
		const newValues: Record<string, boolean | string | string[]> = {};
		for (const def of fieldDefs) {
			const value =
				def.path === 'local'
					? opts.local[def.key as keyof typeof opts.local]
					: opts.request[def.key as keyof typeof opts.request];
			newValues[def.id] = value as boolean | string | string[];
		}
		values = newValues;
	});

	// Update a field value and sync to topologyOptions
	function updateValue(def: TopologyFieldDef, newValue: boolean | string | string[]) {
		values = { ...values, [def.id]: newValue };

		updateTopologyOptions((opts) => {
			if (def.path === 'local') {
				// eslint-disable-next-line @typescript-eslint/no-explicit-any
				(opts.local as any)[def.key] = newValue;
			} else {
				// eslint-disable-next-line @typescript-eslint/no-explicit-any
				(opts.request as any)[def.key] = newValue;
			}
			return opts;
		});
	}

	function toggleSection(sectionName: string) {
		expandedSections[sectionName] = !expandedSections[sectionName];
	}
</script>

<div class="space-y-4">
	<!-- Filters Section -->
	<div class="card card-static px-0 py-2">
		<button
			type="button"
			class="text-secondary hover:text-primary flex w-full items-center gap-2 px-3 py-2 text-sm font-medium"
			onclick={() => toggleSection(common_filters())}
		>
			{#if expandedSections[common_filters()]}
				<ChevronDown class="h-4 w-4" />
			{:else}
				<ChevronRight class="h-4 w-4" />
			{/if}
			{common_filters()}
		</button>

		{#if expandedSections[common_filters()]}
			<div class="space-y-2 px-3 pb-3">
				<p class="text-tertiary text-xs">{topology_filtersHelp()}</p>

				<!-- Hosts -->
				<div class="space-y-1.5 rounded-lg p-2.5" style="background: var(--color-bg-surface-hover)">
					<div class="text-secondary text-xs font-semibold uppercase tracking-wide">
						{common_hosts()}
					</div>
					<TagFilterGroup
						label={common_byTag()}
						tags={hostTags}
						hiddenTagIds={$topologyOptions.local.tag_filter?.hidden_host_tag_ids ?? []}
						onToggle={toggleHostTag}
						entityType="host"
						hasUntagged={hasUntaggedHosts}
					/>
				</div>

				<!-- Services -->
				<div class="space-y-1.5 rounded-lg p-2.5" style="background: var(--color-bg-surface-hover)">
					<div class="text-secondary text-xs font-semibold uppercase tracking-wide">
						{common_services()}
					</div>
					<TagFilterGroup
						label={common_byTag()}
						tags={serviceTags}
						hiddenTagIds={$topologyOptions.local.tag_filter?.hidden_service_tag_ids ?? []}
						onToggle={toggleServiceTag}
						entityType="service"
						hasUntagged={hasUntaggedServices}
						hasGeneric={$activePerspective === 'application'}
					/>
					<CategoryFilterGroup
						categories={allServiceCategoriesWithColors}
						hiddenCategories={$topologyOptions.request.hide_service_categories ?? []}
						onToggle={toggleServiceCategory}
						disabled={!editState.isEditable}
						label={common_byCategory()}
					/>
				</div>

				<!-- Subnets -->
				<div class="space-y-1.5 rounded-lg p-2.5" style="background: var(--color-bg-surface-hover)">
					<div class="text-secondary text-xs font-semibold uppercase tracking-wide">
						{common_subnets()}
					</div>
					<TagFilterGroup
						label={common_byTag()}
						tags={subnetTags}
						hiddenTagIds={$topologyOptions.local.tag_filter?.hidden_subnet_tag_ids ?? []}
						onToggle={toggleSubnetTag}
						entityType="subnet"
						hasUntagged={hasUntaggedSubnets}
					/>
				</div>

				<!-- Edges -->
				<div class="space-y-1.5 rounded-lg p-2.5" style="background: var(--color-bg-surface-hover)">
					<div class="text-secondary text-xs font-semibold uppercase tracking-wide">
						{common_edges()}
					</div>
					<FilterGroup
						items={edgeTypesWithColors}
						selectedValues={$topologyOptions.local.hide_edge_types ?? []}
						mode="exclude"
						onToggle={toggleEdgeType}
						onHoverStart={handleEdgeTypeHoverStart}
						onHoverEnd={handleEdgeTypeHoverEnd}
						label={common_byType()}
					/>
				</div>
			</div>
		{/if}
	</div>

	<!-- Group By Section -->
	<div class="card card-static px-0 py-2">
		<button
			type="button"
			class="text-secondary hover:text-primary flex w-full items-center gap-2 px-3 py-2 text-sm font-medium"
			onclick={() => toggleSection(topology_groupBy())}
		>
			{#if expandedSections[topology_groupBy()]}
				<ChevronDown class="h-4 w-4" />
			{:else}
				<ChevronRight class="h-4 w-4" />
			{/if}
			{topology_groupBy()}
		</button>

		{#if expandedSections[topology_groupBy()]}
			<div class="px-3 pb-3">
				<GroupingRuleEditor />
			</div>
		{/if}
	</div>

	{#each sections as section (section.name)}
		<div class="card card-static px-0 py-2">
			<button
				type="button"
				class="text-secondary hover:text-primary flex w-full items-center gap-2 px-3 py-2 text-sm font-medium"
				onclick={() => toggleSection(section.name)}
			>
				{#if expandedSections[section.name]}
					<ChevronDown class="h-4 w-4" />
				{:else}
					<ChevronRight class="h-4 w-4" />
				{/if}
				{section.name}
			</button>

			{#if expandedSections[section.name]}
				<div class="space-y-3 px-3 pb-3">
					{#each section.fields as def (def.id)}
						{#if def.type === 'boolean'}
							<OptionToggle
								label={def.label()}
								helpText={def.helpText()}
								path={def.path}
								optionKey={def.key}
								disabled={def.path === 'request' && !editState.isEditable}
								disabledReason={def.path === 'request' && !editState.isEditable
									? getOptionDisabledTooltip(editState.disabledReason)
									: ''}
							/>
						{:else if def.type === 'string'}
							<div>
								<label for={def.id} class="text-secondary mb-1 block text-sm font-medium">
									{def.label()}
								</label>
								<input
									type="text"
									id={def.id}
									class="input-field w-full"
									placeholder={def.placeholder?.() ?? ''}
									value={values[def.id] ?? ''}
									oninput={(e) => updateValue(def, e.currentTarget.value)}
								/>
								{#if def.helpText}
									<p class="text-tertiary mt-1 text-xs">{def.helpText()}</p>
								{/if}
							</div>
						{/if}
					{/each}
				</div>
			{/if}
		</div>
	{/each}
</div>
