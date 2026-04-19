<script lang="ts">
	import { SvelteSet } from 'svelte/reactivity';
	import {
		topologyOptions,
		updateTopologyOptions,
		selectedTopologyId,
		useTopologiesQuery,
		autoRebuild
	} from '../../../queries';
	import { hoveredEdgeType } from '../../../interactions';
	import { isDisabledEdge } from '../../../layout/edge-classification';
	import { getTopologyEditState, getOptionDisabledTooltip } from '../../../state';
	import { edgeTypes, views, serviceCategories, entities } from '$lib/shared/stores/metadata';
	import { activeView } from '../../../queries';
	import { type Color } from '$lib/shared/utils/styling';
	import viewsJson from '$lib/data/views.json';
	import TagFilterGroup from './TagFilterGroup.svelte';
	import OptionToggle from './OptionToggle.svelte';
	import CategoryFilterGroup from './CategoryFilterGroup.svelte';
	import FilterGroup from './FilterGroup.svelte';
	import GroupingRuleEditor from './GroupingRuleEditor.svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		common_hosts,
		common_services,
		common_subnets,
		common_visual,
		common_dependenciesLabel,
		topology_bundleEdges,
		topology_bundleEdgesHelp,
		topology_dontFadeEdges,
		topology_dontFadeEdgesHelp,
		topology_hidePorts,
		topology_hidePortsHelp,
		topology_showMinimap,
		topology_showMinimapHelp,
		common_byCategory,
		common_byTag,
		common_edges,
		topology_filtersApplyToView,
		topology_groupsHelp,
		topology_displayHelp
	} from '$lib/paraglide/messages';

	let { activeTab }: { activeTab: 'filter' | 'group' | 'visual' } = $props();

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

	// Derive filter visibility from element_config
	let viewMetaObj = $derived(
		views.getMetadata($activeView) as {
			element_config?: {
				container_entity: string | null;
				element_entities: Array<{ entity_type: string; inline_entities: string[] }>;
			};
		} | null
	);
	let elementConfig = $derived(viewMetaObj?.element_config);
	let filterableEntities = $derived.by(() => {
		const config = elementConfig;
		if (!config) return new SvelteSet<string>();
		const set = new SvelteSet<string>();
		if (config.container_entity) set.add(config.container_entity);
		for (const ee of config.element_entities ?? []) {
			set.add(ee.entity_type);
			for (const inline of ee.inline_entities) set.add(inline);
		}
		// Expand element's parent taggable entity when the view has containers and the parent isn't already the container
		if (config.container_entity) {
			for (const ee of config.element_entities ?? []) {
				const parentEntity = entities.getMetadata(ee.entity_type)?.parent_taggable_entity;
				if (parentEntity && parentEntity !== config.container_entity) {
					set.add(parentEntity);
				}
			}
		}
		return set;
	});
	let showHostFilter = $derived(filterableEntities.has('Host'));
	let showServiceFilter = $derived(filterableEntities.has('Service'));
	let showSubnetFilter = $derived(filterableEntities.has('Subnet'));
	let hasCategoryFilter = $derived(showServiceFilter);

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

	function toggleServiceCategory(category: string) {
		const view = $activeView;
		updateTopologyOptions((opts) => {
			const allHidden = opts.request.hide_service_categories ?? {};
			const hidden = allHidden[view] ?? [];
			const cat = category as (typeof hidden)[number];
			const idx = hidden.indexOf(cat);
			const newHidden = idx !== -1 ? hidden.filter((c) => c !== cat) : [...hidden, cat];

			return {
				...opts,
				request: {
					...opts.request,
					hide_service_categories: {
						...allHidden,
						[view]: newHidden
					}
				}
			};
		});
	}

	function toggleEdgeType(edgeType: string) {
		updateTopologyOptions((opts) => {
			const hidden = opts.local.hide_edge_types ?? [];

			if (edgeType === DEPENDENCIES_GROUP) {
				// Toggle all dependency edge types together
				const allHidden = dependencyEdgeTypeIds.every((id) =>
					hidden.includes(id as (typeof hidden)[number])
				);
				const newHidden = allHidden
					? hidden.filter((e) => !dependencyEdgeTypeIds.includes(e))
					: [
							...hidden.filter((e) => !dependencyEdgeTypeIds.includes(e)),
							...(dependencyEdgeTypeIds as (typeof hidden)[number][])
						];
				return {
					...opts,
					local: { ...opts.local, hide_edge_types: newHidden }
				};
			}

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
		const types = value === DEPENDENCIES_GROUP ? dependencyEdgeTypeIds : [value];
		hoveredEdgeType.set({ edgeTypes: types, color: color as string });
	}

	function handleEdgeTypeHoverEnd() {
		hoveredEdgeType.set(null);
	}

	let viewMeta = $derived(viewsJson.find((p) => p.id === $activeView));

	// All service categories from fixture (not filtered by topology services)
	let allServiceCategoriesWithColors = $derived.by(() => {
		const allCats = serviceCategories.getItems();
		return allCats
			.map((cat) => ({
				value: cat.id,
				label: cat.name ?? cat.id,
				color: serviceCategories.getColorString(cat.id),
				tooltip: cat.description || undefined
			}))
			.sort((a, b) => a.label.localeCompare(b.label));
	});

	// Sentinel value for the unified dependency toggle
	const DEPENDENCIES_GROUP = 'Dependencies';

	// Determine which edge types are dependency edges from metadata
	let dependencyEdgeTypeIds = $derived.by(() => {
		if (!topology?.edges) return [] as string[];
		const seen = new SvelteSet<string>();
		const depTypes: string[] = [];
		for (const edge of topology.edges) {
			const et = edge.edge_type;
			if (et && !seen.has(et) && !isDisabledEdge(edge)) {
				seen.add(et);
				const meta = edgeTypes.getMetadata(et);
				if (meta?.is_dependency_edge) depTypes.push(et);
			}
		}
		return depTypes;
	});

	// Build edge types with colors from edges present in the topology
	// Dependency edges are collapsed into a single "Dependencies" toggle
	let edgeTypesWithColors = $derived.by(() => {
		if (!topology?.edges) return [];
		const seen: Record<string, boolean> = {};
		const result: { value: string; label: string; color: Color }[] = [];
		let addedDepGroup = false;
		for (const edge of topology.edges) {
			const edgeType = edge.edge_type;
			if (edgeType && !seen[edgeType] && !isDisabledEdge(edge)) {
				seen[edgeType] = true;
				const meta = edgeTypes.getMetadata(edgeType);
				if (meta?.is_dependency_edge) {
					if (!addedDepGroup) {
						addedDepGroup = true;
						const colorHelper = edgeTypes.getColorHelper(edgeType);
						result.push({
							value: DEPENDENCIES_GROUP,
							label: common_dependenciesLabel(),
							color: colorHelper.color
						});
					}
				} else {
					const colorHelper = edgeTypes.getColorHelper(edgeType);
					result.push({ value: edgeType, label: edgeType, color: colorHelper.color });
				}
			}
		}
		return result.sort((a, b) => a.label.localeCompare(b.label));
	});

	// Map hide_edge_types to filter-group selected values, replacing individual
	// dependency type IDs with the unified DEPENDENCIES_GROUP sentinel
	let edgeFilterSelectedValues = $derived.by(() => {
		const hidden = $topologyOptions.local.hide_edge_types ?? [];
		const nonDep = hidden.filter((e) => !dependencyEdgeTypeIds.includes(e));
		const allDepHidden =
			dependencyEdgeTypeIds.length > 0 &&
			dependencyEdgeTypeIds.every((id) => hidden.includes(id as (typeof hidden)[number]));
		return allDepHidden ? [...nonDep, DEPENDENCIES_GROUP] : nonDep;
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
			id: 'show_minimap',
			label: () => topology_showMinimap(),
			type: 'boolean',
			path: 'local',
			key: 'show_minimap',
			helpText: () => topology_showMinimapHelp(),
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
</script>

{#if activeTab === 'filter'}
	<!-- Filters -->
	<div class="space-y-3">
		<p class="text-secondary text-xs font-medium">
			{topology_filtersApplyToView({ viewName: viewMeta?.name ?? $activeView })}
		</p>

		<div class="space-y-1.5">
			<div class="text-secondary text-xs font-semibold uppercase tracking-wide">
				{common_edges()}
			</div>
			<FilterGroup
				items={edgeTypesWithColors}
				selectedValues={edgeFilterSelectedValues}
				mode="exclude"
				onToggle={toggleEdgeType}
				onHoverStart={handleEdgeTypeHoverStart}
				onHoverEnd={handleEdgeTypeHoverEnd}
			/>
		</div>

		{#if showSubnetFilter}
			<div class="space-y-1.5">
				<div class="text-secondary text-xs font-semibold uppercase tracking-wide">
					{common_subnets()}
				</div>
				<TagFilterGroup
					tags={subnetTags}
					hiddenTagIds={$topologyOptions.local.tag_filter?.hidden_subnet_tag_ids ?? []}
					onToggle={toggleSubnetTag}
					entityType="subnet"
					hasUntagged={hasUntaggedSubnets}
				/>
			</div>
		{/if}

		{#if showHostFilter}
			<div class="space-y-1.5">
				<div class="text-secondary text-xs font-semibold uppercase tracking-wide">
					{common_hosts()}
				</div>
				<TagFilterGroup
					tags={hostTags}
					hiddenTagIds={$topologyOptions.local.tag_filter?.hidden_host_tag_ids ?? []}
					onToggle={toggleHostTag}
					entityType="host"
					hasUntagged={hasUntaggedHosts}
				/>
			</div>
		{/if}

		{#if showServiceFilter}
			<div class="space-y-1.5">
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
				/>
				{#if hasCategoryFilter}
					<CategoryFilterGroup
						categories={allServiceCategoriesWithColors}
						hiddenCategories={(
							($topologyOptions.request.hide_service_categories ?? {}) as Record<string, string[]>
						)[$activeView] ?? []}
						onToggle={toggleServiceCategory}
						disabled={!editState.isEditable}
						label={common_byCategory()}
					/>
				{/if}
			</div>
		{/if}
	</div>
{:else if activeTab === 'group'}
	<!-- Group By -->
	<div class="space-y-3">
		<p class="text-tertiary text-xs">{topology_groupsHelp()}</p>
		<GroupingRuleEditor />
	</div>
{:else if activeTab === 'visual'}
	<!-- Visual Options -->
	<div class="space-y-3">
		<p class="text-tertiary text-xs">{topology_displayHelp()}</p>
		{#each sections as section (section.name)}
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
		{/each}
	</div>
{/if}
