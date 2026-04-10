import { createQuery, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import type { components } from '$lib/api/schema';

export type Interface = components['schemas']['Interface'];

export function useInterfacesQuery() {
	const queryClient = useQueryClient();
	return createQuery(() => ({
		queryKey: queryKeys.interfaces.all,
		queryFn: () => {
			// Interfaces are populated by hosts query - read from cache
			return queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
		}
	}));
}
