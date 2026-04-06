<script lang="ts">
	import {
		topologyOptions,
		updateTopologyOptions,
		selectedTopologyId,
		useTopologiesQuery,
		autoRebuild
	} from '../../../queries';
	import { hoveredEdgeType } from '../../../interactions';
	import { getTopologyEditState, getOptionDisabledTooltip } from '../../../state';
	import { edgeTypes, views, serviceCategories } from '$lib/shared/stores/metadata';
	import { activeView } from '../../../queries';
	import { type Color, COLOR_MAP } from '$lib/shared/utils/styling';
	import viewsJson from '$lib/data/views.json';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
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
		topology_filtersHelp
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

	// Derive filter visibility from element_config
	let viewMetaObj = $derived(
		views.getMetadata($activeView) as {
			element_config?: {
				parent_entity: string | null;
				element_entity: string;
				inline_entities: string[];
			};
		} | null
	);
	let elementConfig = $derived(viewMetaObj?.element_config);
	let showHostFilter = $derived(
		elementConfig?.parent_entity === 'Host' || elementConfig?.element_entity === 'Host'
	);
	let showServiceFilter = $derived(
		elementConfig?.element_entity === 'Service' ||
			(elementConfig?.inline_entities?.includes('Service') ?? false)
	);
	let showSubnetFilter = $derived(!!elementConfig?.parent_entity);
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
			const allHidden = (opts.request.hide_service_categories ?? {}) as Record<string, string[]>;
			const hidden = allHidden[view] ?? [];
			const idx = hidden.indexOf(category);
			const newHidden =
				idx !== -1 ? hidden.filter((c: string) => c !== category) : [...hidden, category];

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

				{#if showHostFilter}
					<!-- Hosts -->
					<div
						class="space-y-1.5 rounded-lg p-2.5"
						style="background: var(--color-bg-surface-hover)"
					>
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
				{/if}

				{#if showServiceFilter}
					<!-- Services -->
					<div
						class="space-y-1.5 rounded-lg p-2.5"
						style="background: var(--color-bg-surface-hover)"
					>
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
							<div
								class="border-l-2 pl-2"
								style="border-left-color: {viewMeta?.color
									? COLOR_MAP[viewMeta.color as Color]?.rgb
									: 'transparent'}"
							>
								<CategoryFilterGroup
									categories={allServiceCategoriesWithColors}
									hiddenCategories={(
										($topologyOptions.request.hide_service_categories ?? {}) as Record<
											string,
											string[]
										>
									)[$activeView] ?? []}
									onToggle={toggleServiceCategory}
									disabled={!editState.isEditable}
									label={common_byCategory()}
								/>
							</div>
						{/if}
					</div>
				{/if}

				{#if showSubnetFilter}
					<!-- Subnets -->
					<div
						class="space-y-1.5 rounded-lg p-2.5"
						style="background: var(--color-bg-surface-hover)"
					>
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
				{/if}

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
