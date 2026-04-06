/**
 * TanStack Query hooks for Topology
 *
 * Note: UI state (selected nodes/edges, options panel, localStorage preferences)
 * remains in local component state or a separate UI store.
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryClient, queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Topology, TopologyOptions } from './types/base';
import type { ContainerGraphRule, ElementGraphRule } from './types/grouping';
import { makeGraphRule } from './types/grouping';
import type { ContainerRule } from './types/grouping';
import _containerRuleTypes from '$lib/data/container-rule-types.json';
import _elementRuleTypes from '$lib/data/element-rule-types.json';
import type { Organization } from '$lib/features/organizations/types';
import { uuidv4Sentinel, utcTimeZoneSentinel } from '$lib/shared/utils/formatting';
import { BaseSSEManager, type SSEConfig } from '$lib/shared/utils/sse';
import { writable, derived, get } from 'svelte/store';
import { UNTAGGED_SENTINEL } from './interactions';
import { getDefaultHiddenEdgeTypes } from './layout/edge-classification';
import type { components } from '$lib/api/schema';
import perspectivesJson from '$lib/data/perspectives.json';
import { perspectives } from '$lib/shared/stores/metadata';
import type { ServiceCategoryMetadata } from '$lib/shared/stores/metadata';
import serviceCategoriesJson from '$lib/data/service-categories.json';

export type TopologyPerspective = components['schemas']['TopologyPerspective'];
type PerPerspectiveOptions = Record<TopologyPerspective, TopologyOptions>;

/** Strip UI-only sentinel values from options before sending to the API */
export function sanitizeOptionsForApi(options: TopologyOptions): TopologyOptions {
	const tf = options.local?.tag_filter;
	const isSentinel = (id: string) => id === UNTAGGED_SENTINEL;
	return {
		...options,
		local: {
			...options.local,
			tag_filter: {
				hidden_host_tag_ids: (tf?.hidden_host_tag_ids ?? []).filter((id) => !isSentinel(id)),
				hidden_service_tag_ids: (tf?.hidden_service_tag_ids ?? []).filter((id) => !isSentinel(id)),
				hidden_subnet_tag_ids: (tf?.hidden_subnet_tag_ids ?? []).filter((id) => !isSentinel(id))
			}
		}
	};
}

// Default container rules, derived from fixture metadata per perspective
function getDefaultContainerRules(perspective: TopologyPerspective): ContainerGraphRule[] {
	return _containerRuleTypes
		.filter((r) => (r.metadata as { perspectives?: string[] })?.perspectives?.includes(perspective))
		.map((r) => {
			if (r.id === 'ByApplicationGroup') {
				return makeGraphRule({ ByApplicationGroup: { tag_ids: [] } } as ContainerRule);
			}
			return makeGraphRule(r.id as ContainerRule);
		});
}

// Legacy default for backward compatibility
export const defaultContainerRules: ContainerGraphRule[] = getDefaultContainerRules('L3Logical');

// Default element rules, derived from fixture metadata per perspective
function getDefaultElementRules(perspective: TopologyPerspective): ElementGraphRule[] {
	return _elementRuleTypes
		.filter((r) => (r.metadata as { perspectives?: string[] })?.perspectives?.includes(perspective))
		.map((r) => {
			if (r.id === 'ByServiceCategory') {
				return makeGraphRule({ ByServiceCategory: { categories: [], title: null } });
			}
			if (r.id === 'ByTag') {
				return makeGraphRule({ ByTag: { tag_ids: [], title: null } });
			}
			// Parameterless rules (e.g. ByVirtualizer)
			return makeGraphRule(r.id as string);
		});
}

// Union of all perspective defaults — one rule per type across all perspectives.
// Used as initial value before topology hydration.
function getUnionDefaultElementRules(): ElementGraphRule[] {
	const seen = new Set<string>();
	const result: ElementGraphRule[] = [];
	for (const r of _elementRuleTypes) {
		if (!seen.has(r.id)) {
			seen.add(r.id);
			if (r.id === 'ByServiceCategory') {
				result.push(makeGraphRule({ ByServiceCategory: { categories: [], title: null } }));
			} else if (r.id === 'ByTag') {
				result.push(makeGraphRule({ ByTag: { tag_ids: [], title: null } }));
			} else {
				result.push(makeGraphRule(r.id as string));
			}
		}
	}
	return result;
}

// Legacy default for backward compatibility
export const defaultElementRules: ElementGraphRule[] = getUnionDefaultElementRules();

type ServiceCategory = components['schemas']['ServiceCategory'];

/**
 * Compute the default hidden service categories for a perspective + use case.
 * Uses the `application_relevant_use_cases` metadata from service-categories.json.
 * Categories whose relevance list does NOT include the org's use case are hidden.
 */
function getDefaultHiddenCategories(
	perspective: TopologyPerspective,
	useCase: string
): ServiceCategory[] {
	const hasCategoryFilter = (
		perspectives.getMetadata(perspective) as { category_filter?: boolean } | null
	)?.category_filter;

	if (!hasCategoryFilter) {
		return ['OpenPorts'];
	}

	const hidden: ServiceCategory[] = ['OpenPorts'];
	for (const cat of serviceCategoriesJson) {
		const meta = cat.metadata as ServiceCategoryMetadata | null;
		if (meta && !meta.application_relevant_use_cases.includes(useCase)) {
			hidden.push(cat.id as ServiceCategory);
		}
	}
	return hidden;
}

export function getDefaultTopologyOptions(
	perspective: TopologyPerspective,
	useCase: string = 'other'
): TopologyOptions {
	return {
		local: {
			hide_edge_types: getDefaultHiddenEdgeTypes(perspective),
			no_fade_edges: false,
			hide_resize_handles: false,
			bundle_edges: true,
			tag_filter: {
				hidden_host_tag_ids: [],
				hidden_service_tag_ids: [],
				hidden_subnet_tag_ids: []
			},
			show_minimap: true
		},
		request: {
			hide_ports: false,
			hide_vm_title_on_docker_container: false,
			hide_service_categories: getDefaultHiddenCategories(perspective, useCase),
			container_rules: getDefaultContainerRules(perspective),
			element_rules: getDefaultElementRules(perspective),
			perspective
		}
	};
}

/** @deprecated Use getDefaultTopologyOptions('L3Logical') */
export const defaultTopologyOptions: TopologyOptions = getDefaultTopologyOptions('L3Logical');

const ALL_PERSPECTIVES: TopologyPerspective[] = perspectivesJson.map(
	(p) => p.id as TopologyPerspective
);

function buildDefaultPerPerspectiveOptions(): PerPerspectiveOptions {
	return Object.fromEntries(
		ALL_PERSPECTIVES.map((p) => [p, getDefaultTopologyOptions(p)])
	) as PerPerspectiveOptions;
}

/**
 * Query hook for fetching all topologies
 */
export function useTopologiesQuery(enabled?: () => boolean) {
	return createQuery(() => ({
		queryKey: queryKeys.topology.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/v1/topology', {
				params: { query: { limit: 0 } }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch topologies');
			}
			return data.data;
		},
		...(enabled ? { enabled } : {})
	}));
}

/**
 * Query hook for fetching a single topology
 */
export function useTopologyQuery(id: () => string | undefined) {
	return createQuery(() => ({
		queryKey: queryKeys.topology.detail(id() ?? ''),
		queryFn: async () => {
			const topologyId = id();
			if (!topologyId) {
				throw new Error('No topology ID provided');
			}
			const { data } = await apiClient.GET('/api/v1/topology/{id}', {
				params: { path: { id: topologyId } }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch topology');
			}
			return data.data;
		},
		enabled: () => !!id()
	}));
}

/**
 * Mutation hook for creating a topology
 */
export function useCreateTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			const { data } = await apiClient.POST('/api/v1/topology', { body: topology });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create topology');
			}
			return data.data;
		},
		onSuccess: (newTopology: Topology) => {
			queryClient.setQueryData<Topology[]>(queryKeys.topology.all, (old) =>
				old ? [...old, newTopology] : [newTopology]
			);
		}
	}));
}

/**
 * Mutation hook for updating a topology
 * Note: Updated topology returns through SSE, so we don't update cache here
 */
export function useUpdateTopologyMutation() {
	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			await apiClient.PUT('/api/v1/topology/{id}', {
				params: { path: { id: topology.id } },
				body: topology
			});
			return topology;
		}
	}));
}

/**
 * Mutation hook for deleting a topology
 */
export function useDeleteTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/v1/topology/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete topology');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<Topology[]>(
				queryKeys.topology.all,
				(old) => old?.filter((t) => t.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for refreshing a topology
 * Note: Updated topology returns through SSE
 * Uses lightweight request - only sends fields the server actually needs
 */
export function useRefreshTopologyMutation() {
	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			await apiClient.POST('/api/v1/topology/{id}/refresh', {
				params: { path: { id: topology.id } },
				body: {
					network_id: topology.network_id,
					options: buildOptionsForApi(),
					nodes: [],
					edges: []
				}
			});
			return topology.id;
		}
	}));
}

/**
 * Mutation hook for rebuilding a topology
 * Note: Updated topology returns through SSE
 * Uses lightweight request - only sends fields the server actually needs
 * (network_id, options, nodes/edges for position preservation)
 */
export function useRebuildTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			await apiClient.POST('/api/v1/topology/{id}/rebuild', {
				params: { path: { id: topology.id } },
				body: {
					network_id: topology.network_id,
					options: buildOptionsForApi(),
					nodes: topology.nodes,
					edges: topology.edges
				}
			});
			return topology.id;
		},
		onSuccess: () => {
			const org = queryClient.getQueryData<Organization>(queryKeys.organizations.current());
			if (org && !org.onboarding.includes('FirstTopologyRebuild')) {
				queryClient.invalidateQueries({ queryKey: queryKeys.organizations.current() });
			}
		}
	}));
}

/**
 * Mutation hook for locking a topology
 */
export function useLockTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			const { data } = await apiClient.POST('/api/v1/topology/{id}/lock', {
				params: { path: { id: topology.id } }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to lock topology');
			}
			return data.data;
		},
		onSuccess: (updatedTopology: Topology) => {
			queryClient.setQueryData<Topology[]>(
				queryKeys.topology.all,
				(old) => old?.map((t) => (t.id === updatedTopology.id ? updatedTopology : t)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for unlocking a topology
 */
export function useUnlockTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			const { data } = await apiClient.POST('/api/v1/topology/{id}/unlock', {
				params: { path: { id: topology.id } }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to unlock topology');
			}
			return data.data;
		},
		onSuccess: (updatedTopology: Topology) => {
			queryClient.setQueryData<Topology[]>(
				queryKeys.topology.all,
				(old) => old?.map((t) => (t.id === updatedTopology.id ? updatedTopology : t)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for updating a single node's position
 * Lightweight endpoint - only sends node ID and position instead of full topology
 * Fixes HTTP 413 errors on drag operations for large topologies
 */
export function useUpdateNodePositionMutation() {
	return createMutation(() => ({
		mutationFn: async (params: {
			topologyId: string;
			networkId: string;
			nodeId: string;
			position: { x: number; y: number };
		}) => {
			const { data } = await apiClient.POST('/api/v1/topology/{id}/node-position', {
				params: { path: { id: params.topologyId } },
				body: {
					network_id: params.networkId,
					node_id: params.nodeId,
					position: params.position
				}
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to update node position');
			}
		}
	}));
}

/**
 * Mutation hook for updating a node's size and position (resize)
 * Lightweight endpoint - only sends node ID, size, and position instead of full topology
 * Fixes HTTP 413 errors on resize operations for large topologies
 */
export function useUpdateNodeResizeMutation() {
	return createMutation(() => ({
		mutationFn: async (params: {
			topologyId: string;
			networkId: string;
			nodeId: string;
			size: { x: number; y: number };
			position: { x: number; y: number };
		}) => {
			const { data } = await apiClient.POST('/api/v1/topology/{id}/node-resize', {
				params: { path: { id: params.topologyId } },
				body: {
					network_id: params.networkId,
					node_id: params.nodeId,
					size: params.size,
					position: params.position
				}
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to resize node');
			}
		}
	}));
}

/**
 * Mutation hook for updating an edge's handles
 * Lightweight endpoint - only sends edge ID and handles instead of full topology
 * Fixes HTTP 413 errors on edge reconnect operations for large topologies
 */
export function useUpdateEdgeHandlesMutation() {
	return createMutation(() => ({
		mutationFn: async (params: {
			topologyId: string;
			networkId: string;
			edgeId: string;
			sourceHandle: 'Top' | 'Bottom' | 'Left' | 'Right';
			targetHandle: 'Top' | 'Bottom' | 'Left' | 'Right';
		}) => {
			const { data } = await apiClient.POST('/api/v1/topology/{id}/edge-handles', {
				params: { path: { id: params.topologyId } },
				body: {
					network_id: params.networkId,
					edge_id: params.edgeId,
					source_handle: params.sourceHandle,
					target_handle: params.targetHandle
				}
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to update edge handles');
			}
		}
	}));
}

/**
 * Mutation hook for updating topology metadata (name, parent)
 * Lightweight endpoint - only sends metadata fields instead of full topology
 * Fixes HTTP 413 errors on metadata edit operations for large topologies
 */
export function useUpdateMetadataMutation() {
	return createMutation(() => ({
		mutationFn: async (params: {
			topologyId: string;
			networkId: string;
			name: string;
			parentId: string | null;
		}) => {
			const { data } = await apiClient.POST('/api/v1/topology/{id}/metadata', {
				params: { path: { id: params.topologyId } },
				body: {
					network_id: params.networkId,
					name: params.name,
					parent_id: params.parentId
				}
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to update topology metadata');
			}
		}
	}));
}

/**
 * Helper to update topologies in the query cache (for SSE updates)
 */
export function updateTopologyInCache(
	queryClient: ReturnType<typeof useQueryClient>,
	topology: Topology
) {
	queryClient.setQueryData<Topology[]>(
		queryKeys.topology.all,
		(old) => old?.map((t) => (t.id === topology.id ? topology : t)) ?? []
	);
}

/**
 * Create empty topology form data
 */
export function createEmptyTopologyFormData(networkId: string): Topology {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		name: '',
		network_id: networkId,
		edges: [],
		nodes: [],
		options: structuredClone(defaultTopologyOptions),
		hosts: [],
		interfaces: [],
		services: [],
		subnets: [],
		dependencies: [],
		ports: [],
		bindings: [],
		is_stale: false,
		last_refreshed: utcTimeZoneSentinel,
		is_locked: false,
		removed_dependencies: [],
		removed_hosts: [],
		removed_interfaces: [],
		removed_services: [],
		removed_subnets: [],
		removed_bindings: [],
		removed_ports: [],
		if_entries: [],
		removed_if_entries: [],
		locked_at: null,
		locked_by: null,
		parent_id: null,
		tags: [],
		entity_tags: []
	};
}

// ============================================================================
// UI State (not server data - kept as Svelte stores)
// ============================================================================

import { browser } from '$app/environment';
import { type Edge, type Node } from '@xyflow/svelte';

const EXPANDED_STORAGE_KEY = 'scanopy_topology_options_expanded_state';
const AUTO_REBUILD_STORAGE_KEY = 'scanopy_topology_auto_rebuild';
const PREFERRED_NETWORK_KEY = 'scanopy_preferred_network_id';

// UI-only state
export const selectedTopologyId = writable<string | null>(null);
export const selectedNode = writable<Node | null>(null);
export const selectedEdge = writable<Edge | null>(null);
export const selectedNodes = writable<Node[]>([]);
export const previewEdges = writable<Edge[]>([]);
export const autoRebuild = writable<boolean>(loadAutoRebuildFromStorage());
export const activePerspective = writable<TopologyPerspective>('L3Logical');

// Internal per-perspective options record (hydrated from topology on load)
const perPerspectiveOptions = writable<PerPerspectiveOptions>(buildDefaultPerPerspectiveOptions());

// Shared element rules — cross-perspective, single source of truth.
// Initialized with union defaults; hydrated from topology on load.
export const sharedElementRules = writable<ElementGraphRule[]>(getUnionDefaultElementRules());

// Public store: resolves to the active perspective's options with shared element rules
// filtered to only those applicable to the active perspective (for display).
export const topologyOptions = derived(
	[perPerspectiveOptions, activePerspective, sharedElementRules],
	([$allOptions, $perspective, $elementRules]) => {
		const opts = $allOptions[$perspective];
		const applicableRules = $elementRules.filter((gr) => {
			const ruleId = typeof gr.rule === 'string' ? gr.rule : Object.keys(gr.rule)[0];
			const meta = _elementRuleTypes.find((r) => r.id === ruleId);
			return (meta?.metadata as { perspectives?: string[] })?.perspectives?.includes($perspective);
		});
		return {
			...opts,
			request: {
				...opts.request,
				element_rules: applicableRules
			}
		};
	}
);

// Helper to update the active perspective's options
export function updateTopologyOptions(
	updater: (current: TopologyOptions) => TopologyOptions
): void {
	const perspective = get(activePerspective);
	perPerspectiveOptions.update((all) => ({
		...all,
		[perspective]: updater(all[perspective])
	}));
}

// Writable-like setter for the active perspective's options (for compatibility)
export function setTopologyOptions(options: TopologyOptions): void {
	const perspective = get(activePerspective);
	perPerspectiveOptions.update((all) => ({
		...all,
		[perspective]: options
	}));
}

// Update shared element rules (cross-perspective)
export function updateSharedElementRules(
	updater: (current: ElementGraphRule[]) => ElementGraphRule[]
): void {
	sharedElementRules.update(updater);
}

/**
 * Build options for API requests. Sends ALL element rules (unfiltered) so the
 * backend stores the full set. Includes perspective_overrides to persist
 * per-perspective container rules.
 */
function buildOptionsForApi(): TopologyOptions {
	const opts = get(topologyOptions);
	const currentPerspective = get(activePerspective);
	const allOpts = get(perPerspectiveOptions);

	// Build perspective overrides for other perspectives' container rules
	const overrides: Record<string, { container_rules?: unknown[] }> = {};
	for (const [p, pOpts] of Object.entries(allOpts)) {
		if (p !== currentPerspective) {
			overrides[p] = { container_rules: pOpts.request.container_rules };
		}
	}

	return sanitizeOptionsForApi({
		...opts,
		request: {
			...opts.request,
			element_rules: get(sharedElementRules),
			perspective_overrides: Object.keys(overrides).length > 0 ? overrides : undefined
		}
	} as TopologyOptions);
}

/**
 * Hydrate reactive stores from a topology's backend-stored options.
 * Called on initial topology selection. SSE updates only hydrate rules,
 * not perspective (to avoid resetting user's perspective switch mid-flight).
 */
let hydrating = false;
export function hydrateStoresFromTopology(topology: Topology, isInitial = true): void {
	hydrating = true;
	try {
		const opts = topology.options;
		const storedPerspective = opts.request.perspective as TopologyPerspective;

		// Only set perspective on initial load — not on SSE updates, which would
		// revert the user's perspective switch mid-flight
		if (isInitial) {
			activePerspective.set(storedPerspective);
		}

		// Set element rules from topology (the full unfiltered set)
		if (opts.request.element_rules?.length) {
			sharedElementRules.set(opts.request.element_rules as ElementGraphRule[]);
		}

		// Build per-perspective options: current from topology, others from overrides or defaults
		const allOpts = buildDefaultPerPerspectiveOptions();
		allOpts[storedPerspective] = opts as TopologyOptions;

		const overrides = (opts.request as Record<string, unknown>).perspective_overrides as
			| Record<string, { container_rules?: ContainerGraphRule[] }>
			| undefined;
		if (overrides) {
			for (const [p, pOverrides] of Object.entries(overrides)) {
				const perspective = p as TopologyPerspective;
				if (
					perspective !== storedPerspective &&
					allOpts[perspective] &&
					pOverrides.container_rules
				) {
					allOpts[perspective] = {
						...allOpts[perspective],
						request: {
							...allOpts[perspective].request,
							container_rules: pOverrides.container_rules
						}
					};
				}
			}
		}

		perPerspectiveOptions.set(allOpts);
	} finally {
		hydrating = false;
	}
}

export const optionsPanelExpanded = writable<boolean>(loadExpandedFromStorage());

/**
 * Set a preferred network to select when topology loads.
 * Used after onboarding to ensure the scanned network's topology is shown.
 */
export function setPreferredNetwork(networkId: string): void {
	if (browser) {
		localStorage.setItem(PREFERRED_NETWORK_KEY, networkId);
	}
}

/**
 * Get and clear the preferred network (one-time use)
 */
export function consumePreferredNetwork(): string | null {
	if (!browser) return null;
	const preferred = localStorage.getItem(PREFERRED_NETWORK_KEY);
	if (preferred) {
		localStorage.removeItem(PREFERRED_NETWORK_KEY);
	}
	return preferred;
}

export function resetTopologyOptions(): void {
	perPerspectiveOptions.set(buildDefaultPerPerspectiveOptions());
	sharedElementRules.set(getUnionDefaultElementRules());
	if (browser) {
		localStorage.removeItem(EXPANDED_STORAGE_KEY);
	}
}

export function hasConflicts(topology: Topology): boolean {
	return (
		topology.removed_hosts.length > 0 ||
		topology.removed_services.length > 0 ||
		topology.removed_subnets.length > 0 ||
		topology.removed_bindings.length > 0 ||
		topology.removed_ports.length > 0 ||
		topology.removed_interfaces.length > 0 ||
		topology.removed_dependencies.length > 0
	);
}

function loadExpandedFromStorage(): boolean {
	if (!browser) return false;

	try {
		const stored = localStorage.getItem(EXPANDED_STORAGE_KEY);
		if (stored) {
			return JSON.parse(stored);
		}
	} catch (error) {
		console.warn('Failed to load topology expanded state from localStorage:', error);
	}
	return false;
}

function saveExpandedToStorage(expanded: boolean): void {
	if (!browser) return;

	try {
		localStorage.setItem(EXPANDED_STORAGE_KEY, JSON.stringify(expanded));
	} catch (error) {
		console.error('Failed to save topology expanded state to localStorage:', error);
	}
}

function loadAutoRebuildFromStorage(): boolean {
	if (!browser) return true;

	try {
		const stored = localStorage.getItem(AUTO_REBUILD_STORAGE_KEY);
		if (stored !== null) {
			return JSON.parse(stored);
		}
	} catch (error) {
		console.warn('Failed to load auto rebuild state from localStorage:', error);
	}
	return true;
}

function saveAutoRebuildToStorage(value: boolean): void {
	if (!browser) return;

	try {
		localStorage.setItem(AUTO_REBUILD_STORAGE_KEY, JSON.stringify(value));
	} catch (error) {
		console.error('Failed to save auto rebuild state to localStorage:', error);
	}
}

// Set up subscriptions for rebuild triggers and UI pref persistence
let optionsInitialized = false;
let expandedInitialized = false;
let autoRebuildInitialized = false;
let perspectiveInitialized = false;

if (browser) {
	let optionsRebuildTimeout: ReturnType<typeof setTimeout>;
	perPerspectiveOptions.subscribe(() => {
		if (optionsInitialized && !hydrating) {
			// Trigger a debounced rebuild when options change
			clearTimeout(optionsRebuildTimeout);
			optionsRebuildTimeout = setTimeout(() => {
				if (!get(autoRebuild)) return;
				const topologyId = get(selectedTopologyId);
				if (!topologyId) return;

				const topologies = queryClient.getQueryData<Topology[]>(queryKeys.topology.all);
				const topology = topologies?.find((t) => t.id === topologyId);
				if (!topology) return;

				apiClient.POST('/api/v1/topology/{id}/rebuild', {
					params: { path: { id: topologyId } },
					body: {
						network_id: topology.network_id,
						options: buildOptionsForApi(),
						nodes: topology.nodes,
						edges: topology.edges
					}
				});
			}, 500);
		}
		optionsInitialized = true;
	});

	optionsPanelExpanded.subscribe((expanded) => {
		if (expandedInitialized) {
			saveExpandedToStorage(expanded);
		}
		expandedInitialized = true;
	});

	autoRebuild.subscribe((value) => {
		if (autoRebuildInitialized) {
			saveAutoRebuildToStorage(value);
		}
		autoRebuildInitialized = true;
	});

	// Trigger a rebuild when the active perspective changes
	activePerspective.subscribe(() => {
		if (perspectiveInitialized && !hydrating) {
			const topologyId = get(selectedTopologyId);
			if (!topologyId) return;

			const topologies = queryClient.getQueryData<Topology[]>(queryKeys.topology.all);
			const topology = topologies?.find((t) => t.id === topologyId);
			if (!topology) return;

			apiClient.POST('/api/v1/topology/{id}/rebuild', {
				params: { path: { id: topologyId } },
				body: {
					network_id: topology.network_id,
					options: buildOptionsForApi(),
					nodes: topology.nodes,
					edges: topology.edges
				}
			});
		}
		perspectiveInitialized = true;
	});
}

// ============================================================================
// Topology SSE Manager
// ============================================================================

class TopologySSEManager extends BaseSSEManager<Topology> {
	private stalenessTimers: Map<string, ReturnType<typeof setTimeout>> = new Map();
	private readonly DEBOUNCE_MS = 300;
	private readonly REBUILD_DEBOUNCE_MS = 2000;

	protected createConfig(): SSEConfig<Topology> {
		return {
			url: '/api/v1/topology/stream',
			onMessage: (update) => {
				// If the update says it's NOT stale, apply immediately (it's a full refresh)
				if (!update.is_stale) {
					this.applyFullUpdate(update);
					return;
				}

				// For stale updates with autoRebuild enabled, trigger a debounced rebuild
				if (get(autoRebuild)) {
					const currentId = get(selectedTopologyId);
					if (currentId === update.id && !update.is_locked) {
						const timerKey = `rebuild:${update.id}`;
						const existingTimer = this.stalenessTimers.get(timerKey);
						if (existingTimer) {
							clearTimeout(existingTimer);
						}
						const timer = setTimeout(() => {
							apiClient.POST('/api/v1/topology/{id}/rebuild', {
								params: { path: { id: update.id } },
								body: {
									network_id: update.network_id,
									options: buildOptionsForApi(),
									nodes: update.nodes,
									edges: update.edges
								}
							});
							this.stalenessTimers.delete(timerKey);
						}, this.REBUILD_DEBOUNCE_MS);
						this.stalenessTimers.set(timerKey, timer);
					}
					return;
				}

				// For staleness updates, debounce them
				const existingTimer = this.stalenessTimers.get(update.id);
				if (existingTimer) {
					clearTimeout(existingTimer);
				}

				const timer = setTimeout(() => {
					this.applyPartialUpdate(update.id, {
						removed_dependencies: update.removed_dependencies,
						removed_hosts: update.removed_hosts,
						removed_services: update.removed_services,
						removed_subnets: update.removed_subnets,
						removed_bindings: update.removed_bindings,
						removed_interfaces: update.removed_interfaces,
						removed_ports: update.removed_ports,
						is_stale: update.is_stale,
						options: update.options
					});
					this.stalenessTimers.delete(update.id);
				}, this.DEBOUNCE_MS);

				this.stalenessTimers.set(update.id, timer);
			},
			onError: (error) => {
				console.error('Topology SSE error:', error);
			},
			onOpen: () => {}
		};
	}

	private applyFullUpdate(update: Topology) {
		queryClient.setQueryData<Topology[]>(queryKeys.topology.all, (old) => {
			if (!old) return [update];
			return old.map((topo) => (topo.id === update.id ? update : topo));
		});

		// Hydrate stores from the updated topology if it's the selected one.
		// Not initial — don't reset perspective on SSE updates.
		if (update.id === get(selectedTopologyId)) {
			hydrateStoresFromTopology(update, false);
		}

		// Invalidate org cache until FirstTopologyRebuild milestone appears
		const org = queryClient.getQueryData<Organization>(queryKeys.organizations.current());
		if (org && !org.onboarding.includes('FirstTopologyRebuild')) {
			queryClient.invalidateQueries({ queryKey: queryKeys.organizations.current() });
		}
	}

	private applyPartialUpdate(topologyId: string, updates: Partial<Topology>) {
		queryClient.setQueryData<Topology[]>(queryKeys.topology.all, (old) => {
			if (!old) return [];
			return old.map((topo) => (topo.id === topologyId ? { ...topo, ...updates } : topo));
		});
	}
}

export const topologySSEManager = new TopologySSEManager();
