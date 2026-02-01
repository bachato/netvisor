/**
 * TanStack Query hooks for IfEntries
 *
 * IfEntries are child entities populated by the hosts query.
 * This file provides read-only access to the ifEntries cache.
 */

import { createQuery, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import type { IfEntry } from '$lib/features/hosts/types/base';

// Re-export type for convenience
export type { IfEntry };

/**
 * Query hook for accessing the ifEntries cache
 * This cache is populated by useHostsQuery - it does not fetch directly
 */
export function useIfEntriesQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.ifEntries.all,
		initialData: [] as IfEntry[],
		staleTime: Infinity,
		refetchOnMount: false,
		refetchOnWindowFocus: false,
		enabled: false
	}));
}

/**
 * Get ifEntries for a specific host from the cache
 */
export function getIfEntriesForHostFromCache(
	queryClient: ReturnType<typeof useQueryClient>,
	hostId: string
): IfEntry[] {
	const ifEntries = queryClient.getQueryData<IfEntry[]>(queryKeys.ifEntries.all) ?? [];
	return ifEntries.filter((e) => e.host_id === hostId);
}

/**
 * Get a single ifEntry by ID from the cache
 */
export function getIfEntryByIdFromCache(
	queryClient: ReturnType<typeof useQueryClient>,
	id: string
): IfEntry | null {
	const ifEntries = queryClient.getQueryData<IfEntry[]>(queryKeys.ifEntries.all) ?? [];
	return ifEntries.find((e) => e.id === id) ?? null;
}
