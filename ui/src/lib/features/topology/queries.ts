/**
 * TanStack Query hooks for Topology
 *
 * Note: UI state (selected nodes/edges, options panel, localStorage preferences)
 * remains in local component state or a separate UI store.
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryClient, queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Topology, TopologyEdge, TopologyOptions } from './types/base';
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
import viewsJson from '$lib/data/views.json';
import { getIrrelevantServiceCategories } from '$lib/shared/stores/metadata';
import { common_infrastructure } from '$lib/paraglide/messages';

export type TopologyView = components['schemas']['TopologyView'];

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

type ServiceCategory = components['schemas']['ServiceCategory'];
type TopologyLocalOptions = components['schemas']['TopologyLocalOptions'];

/** Get the org's use case from the query cache, defaulting to 'other' */
export function getOrgUseCase(): string {
	const org = queryClient.getQueryData<Organization>(queryKeys.organizations.current());
	return org?.use_case ?? 'other';
}

/**
 * Get categories that are irrelevant for the org's use case (for grouping into
 * the "Infrastructure Services" ByServiceCategory element rule).
 */
function getIrrelevantCategories(useCase: string): ServiceCategory[] {
	return [...getIrrelevantServiceCategories(useCase)] as ServiceCategory[];
}

/**
 * Find the infrastructure rule ID from the current topology options
 * by looking for the ByServiceCategory rule with is_infra_rule: true.
 * Derives the ID on each call — no stale state possible.
 */
export function getInfrastructureRuleId(): string | null {
	const opts = get(topologyOptionsStore);
	for (const rule of opts.request.element_rules ?? []) {
		if (
			typeof rule.rule === 'object' &&
			'ByServiceCategory' in rule.rule &&
			rule.rule.ByServiceCategory.is_infra_rule
		) {
			return rule.id;
		}
	}
	return null;
}

const ALL_VIEWS: TopologyView[] = viewsJson.map((p) => p.id as TopologyView);

/** Default local options for a given view (UI-only, not sent to backend as rules) */
function getDefaultLocalOptions(view: TopologyView): TopologyLocalOptions {
	return {
		hide_edge_types: getDefaultHiddenEdgeTypes(view),
		no_fade_edges: false,
		bundle_edges: true,
		tag_filter: {
			hidden_host_tag_ids: [],
			hidden_service_tag_ids: [],
			hidden_subnet_tag_ids: []
		},
		show_minimap: true
	};
}

/** Build default per-view local options */
function initDefaultLocalOptions(): Record<TopologyView, TopologyLocalOptions> {
	return Object.fromEntries(ALL_VIEWS.map((p) => [p, getDefaultLocalOptions(p)])) as Record<
		TopologyView,
		TopologyLocalOptions
	>;
}

/**
 * Default request options matching the backend's TopologyRequestOptions::default().
 * Container rules and hidden categories are per-view HashMaps.
 * Element rules are shared cross-view.
 */
function defaultRequestOptions(): components['schemas']['TopologyRequestOptions'] {
	// Build container rules per view from fixture metadata
	const containerRules: Record<string, ContainerGraphRule[]> = {};
	for (const p of ALL_VIEWS) {
		containerRules[p] = _containerRuleTypes
			.filter((r) => (r.metadata as { views?: string[] })?.views?.includes(p))
			.map((r) => {
				if (r.id === 'ByApplication') {
					return makeGraphRule({ ByApplication: { tag_ids: [] } } as ContainerRule);
				}
				return makeGraphRule(r.id as ContainerRule);
			});
	}

	// Element rules: one of each type (shared cross-view)
	const seen = new Set<string>();
	const elementRules: ElementGraphRule[] = [];
	for (const r of _elementRuleTypes) {
		if (!seen.has(r.id)) {
			seen.add(r.id);
			if (r.id === 'ByServiceCategory') {
				const rule = makeGraphRule({
					ByServiceCategory: {
						categories: getIrrelevantCategories(getOrgUseCase()),
						title: common_infrastructure()
					}
				});
				elementRules.push(rule);
			} else if (r.id === 'ByTag') {
				elementRules.push(makeGraphRule({ ByTag: { tag_ids: [], title: null } }));
			} else {
				elementRules.push(makeGraphRule(r.id as string));
			}
		}
	}

	// Hidden categories: OpenPorts for all views (use-case-aware filtering
	// is handled by the ByServiceCategory element rule instead)
	const hideServiceCategories: Record<string, ServiceCategory[]> = {};
	for (const p of ALL_VIEWS) {
		hideServiceCategories[p] = ['OpenPorts'];
	}

	return {
		hide_ports: false,
		hide_service_categories: hideServiceCategories,
		container_rules: containerRules,
		element_rules: elementRules,
		view: 'L3Logical'
	};
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
		options: {
			local: getDefaultLocalOptions('L3Logical'),
			request: defaultRequestOptions()
		},
		hosts: [],
		ip_addresses: [],
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
		removed_ip_addresses: [],
		removed_services: [],
		removed_subnets: [],
		removed_bindings: [],
		removed_ports: [],
		interfaces: [],
		removed_interfaces: [],
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
export const activeView = writable<TopologyView>('L3Logical');

// ============================================================================
// URL Param Sync
// ============================================================================

const VALID_VIEWS: Set<string> = new Set(viewsJson.map((v) => v.id));

/** Read topology ID and view from current URL search params. */
export function getTopologyParamsFromUrl(): {
	topologyId: string | null;
	view: TopologyView | null;
} {
	if (!browser) return { topologyId: null, view: null };
	const params = new URLSearchParams(window.location.search);
	const topologyId = params.get('topologyId');
	const viewParam = params.get('view');
	const view = viewParam && VALID_VIEWS.has(viewParam) ? (viewParam as TopologyView) : null;
	return { topologyId, view };
}

/** Update URL search params to reflect current topology state. Uses replaceState (no history entry). */
function syncTopologyParamsToUrl(topologyId: string | null, view: TopologyView): void {
	if (!browser) return;
	const url = new URL(window.location.href);
	if (topologyId) {
		url.searchParams.set('topologyId', topologyId);
	} else {
		url.searchParams.delete('topologyId');
	}
	url.searchParams.set('view', view);
	window.history.replaceState(window.history.state, '', url.toString());
}

/** Push a new history entry with updated topology params. For user-initiated changes. */
export function pushTopologyParams(topologyId: string | null, view: TopologyView): void {
	if (!browser) return;
	const url = new URL(window.location.href);
	if (topologyId) {
		url.searchParams.set('topologyId', topologyId);
	} else {
		url.searchParams.delete('topologyId');
	}
	url.searchParams.set('view', view);
	window.history.pushState({}, '', url.toString());
}

// Single source of truth for topology options.
// request: backend state (container_rules/hide_service_categories are per-view HashMaps)
// perViewLocal: UI-only local options per view
const topologyOptionsStore = writable<{
	request: components['schemas']['TopologyRequestOptions'];
	perViewLocal: Record<TopologyView, TopologyLocalOptions>;
}>({
	request: defaultRequestOptions(),
	perViewLocal: initDefaultLocalOptions()
});

// Derived: element rules from the single store (for GroupingRuleEditor)
export const sharedElementRules = derived(topologyOptionsStore, ($store) => {
	return ($store.request.element_rules ?? []) as ElementGraphRule[];
});

// Public derived store: projects the active view's slice of topology options
export const topologyOptions = derived([topologyOptionsStore, activeView], ([$store, $view]) => ({
	local: $store.perViewLocal[$view],
	request: {
		...$store.request,
		view: $view
	}
}));

// Helper to update the active view's local options or request scalars
export function updateTopologyOptions(
	updater: (current: TopologyOptions) => TopologyOptions
): void {
	const view = get(activeView);
	topologyOptionsStore.update((store) => {
		const currentOpts: TopologyOptions = {
			local: store.perViewLocal[view],
			request: { ...store.request, view: view }
		};
		const updated = updater(currentOpts);
		return {
			request: { ...updated.request },
			perViewLocal: {
				...store.perViewLocal,
				[view]: updated.local
			}
		};
	});
}

// Update shared element rules (cross-view)
export function updateSharedElementRules(
	updater: (current: ElementGraphRule[]) => ElementGraphRule[]
): void {
	topologyOptionsStore.update((store) => ({
		...store,
		request: {
			...store.request,
			element_rules: updater((store.request.element_rules ?? []) as ElementGraphRule[])
		}
	}));
}

/**
 * Build options for API requests. Reads directly from the source store —
 * container_rules and hide_service_categories are already per-view HashMaps.
 */
function buildOptionsForApi(): TopologyOptions {
	const store = get(topologyOptionsStore);
	const view = get(activeView);
	return sanitizeOptionsForApi({
		local: store.perViewLocal[view],
		request: {
			...store.request,
			view: view
		}
	});
}

/**
 * Hydrate stores from a topology's backend-stored options.
 * Called on initial topology selection and SSE updates.
 * SSE updates preserve the user's view and local options for other views.
 */
let hydrating = false;
export function hydrateStoresFromTopology(topology: Topology, isInitial = true): void {
	hydrating = true;
	try {
		const opts = topology.options;
		const storedView = opts.request.view as TopologyView;

		// Only set view on initial load — not on SSE updates, which would
		// revert the user's view switch mid-flight
		if (isInitial) {
			activeView.set(storedView);
		}

		if (isInitial) {
			const request = { ...opts.request };

			// Enrich ByServiceCategory with use-case-aware irrelevant categories
			const useCase = getOrgUseCase();
			const irrelevant = getIrrelevantCategories(useCase);
			const elementRules = [...(request.element_rules ?? [])];
			for (let i = 0; i < elementRules.length; i++) {
				const rule = elementRules[i].rule;
				if (typeof rule === 'object' && 'ByServiceCategory' in rule) {
					elementRules[i] = {
						...elementRules[i],
						rule: {
							ByServiceCategory: {
								...rule.ByServiceCategory,
								categories: irrelevant,
								title: common_infrastructure()
							}
						}
					};
					break;
				}
			}
			request.element_rules = elementRules;

			// Full hydration: use backend request options + default local options
			topologyOptionsStore.set({
				request,
				perViewLocal: {
					...initDefaultLocalOptions(),
					[storedView]: opts.local
				}
			});
		} else {
			// SSE update or topology switch: update request options, preserve
			// all client-side local options. Local options (hide_edge_types,
			// bundle_edges, etc.) are client-side state — the server returns
			// whatever was last sent, which may be stale.
			topologyOptionsStore.update((current) => ({
				request: opts.request,
				perViewLocal: current.perViewLocal
			}));
		}
	} finally {
		hydrating = false;
	}
}

export const optionsPanelExpanded = writable<boolean>(loadExpandedFromStorage());

/** Expanded options panel width in px (Tailwind w-96 = 384px). Used by the panel and panel-aware fitView. */
export const OPTIONS_PANEL_WIDTH_PX = 384;

/** Left offset of the options panel (Tailwind left-4 = 16px). */
export const OPTIONS_PANEL_LEFT_OFFSET_PX = 16;

/** Total left padding for fitView when panel is open: panel width + offset + gap. */
export const OPTIONS_PANEL_FITVIEW_PADDING_PX =
	OPTIONS_PANEL_WIDTH_PX + OPTIONS_PANEL_LEFT_OFFSET_PX + 16;

/** Lookup map from aggregated edge ID to its original edges. Populated by BaseTopologyViewer during collapse. */
export const aggregatedEdgeOriginals = writable<Map<string, TopologyEdge[]>>(new Map());

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
	topologyOptionsStore.set({
		request: defaultRequestOptions(),
		perViewLocal: initDefaultLocalOptions()
	});
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
let viewInitialized = false;

if (browser) {
	let rebuildTimeout: ReturnType<typeof setTimeout>;

	function triggerRebuild(debounceMs = 500, force = false): void {
		clearTimeout(rebuildTimeout);
		rebuildTimeout = setTimeout(() => {
			if (!force && !get(autoRebuild)) return;
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
		}, debounceMs);
	}

	topologyOptionsStore.subscribe(() => {
		if (optionsInitialized && !hydrating) {
			triggerRebuild();
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

	activeView.subscribe(() => {
		if (viewInitialized && !hydrating) {
			triggerRebuild(0, true);
		}
		viewInitialized = true;
	});

	// Sync stores → URL (replaceState, no history entry)
	// User-initiated changes use pushTopologyParams from TopologyTab instead.
	selectedTopologyId.subscribe((id) => {
		if (id !== null) {
			syncTopologyParamsToUrl(id, get(activeView));
		}
	});
	activeView.subscribe((view) => {
		const id = get(selectedTopologyId);
		if (id !== null) {
			syncTopologyParamsToUrl(id, view);
		}
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
		// Not initial — don't reset view on SSE updates.
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
