/**
 * Shared topology context resolver.
 *
 * Components rendered inside the topology viewer need access to the current
 * topology. In the **app** this comes from an authenticated TanStack Query
 * keyed by `selectedTopologyId`. In **share/embed** pages it comes from a
 * Svelte context store set by ReadOnlyTopologyViewer (no auth needed).
 *
 * `useTopology()` detects which mode we're in and returns a consistent
 * interface so every consumer doesn't have to wire this up manually.
 */

import { getContext } from 'svelte';
import { derived, get, type Readable, type Writable } from 'svelte/store';
import { useTopologiesQuery, selectedTopologyId } from './queries';
import type { Topology } from './types/base';

export interface TopologyHandle {
	/** Reactive store containing the current topology (may be undefined during loading). */
	topology: Readable<Topology | undefined>;
	/** Whether we're in a read-only context (share/embed). */
	isReadonly: boolean;
}

/**
 * Returns the current topology and readonly flag.
 *
 * Must be called during component initialization (uses `getContext`).
 * - Share/embed: reads from the `'topology'` context store, no API call.
 * - App: enables `useTopologiesQuery` and resolves via `selectedTopologyId`.
 */
export function useTopology(): TopologyHandle {
	const ctx = getContext<Writable<Topology> | undefined>('topology');

	if (ctx) {
		return {
			topology: derived(ctx, ($t) => $t),
			isReadonly: true
		};
	}

	const query = useTopologiesQuery();
	return {
		topology: derived([query, selectedTopologyId], ([$q, $id]) => {
			const data = ($q as { data?: Topology[] }).data ?? [];
			return data.find((t) => t.id === $id);
		}),
		isReadonly: false
	};
}
