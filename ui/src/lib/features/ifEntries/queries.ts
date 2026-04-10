/**
 * TanStack Query hooks for Interfaces
 *
 * Interfaces are child entities populated by the hosts query.
 * This file provides read-only access to the interfaces cache.
 */

import { createQuery, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import type { Interface } from '$lib/features/hosts/types/base';

// Re-export type for convenience
export type { Interface };

/**
 * Query hook for accessing the interfaces cache
 * This cache is populated by useHostsQuery - it does not fetch directly
 */
export function useIfEntriesQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.interfaces.all,
		initialData: [] as Interface[],
		staleTime: Infinity,
		refetchOnMount: false,
		refetchOnWindowFocus: false,
		enabled: false
	}));
}

/**
 * Get interfaces for a specific host from the cache
 */
export function getIfEntriesForHostFromCache(
	queryClient: ReturnType<typeof useQueryClient>,
	hostId: string
): Interface[] {
	const interfaces = queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
	return interfaces.filter((e) => e.host_id === hostId);
}

/**
 * Get a single interface by ID from the cache
 */
export function getIfEntryByIdFromCache(
	queryClient: ReturnType<typeof useQueryClient>,
	id: string
): Interface | null {
	const interfaces = queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
	return interfaces.find((e) => e.id === id) ?? null;
}
