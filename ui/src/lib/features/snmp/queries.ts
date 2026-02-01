/**
 * TanStack Query hooks for SNMP Credentials
 *
 * Provides query and mutation hooks for managing SNMP credentials.
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { SnmpCredential } from './types/base';
import {
	snmp_failedToBulkDelete,
	snmp_failedToCreate,
	snmp_failedToDelete,
	snmp_failedToFetch,
	snmp_failedToFetchSingle,
	snmp_failedToUpdate
} from '$lib/paraglide/messages';

/**
 * Query hook for fetching all SNMP credentials
 */
export function useSnmpCredentialsQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.snmpCredentials.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/v1/snmp-credentials', {
				params: { query: { limit: 0 } }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || snmp_failedToFetch());
			}
			return data.data;
		}
	}));
}

/**
 * Query hook for fetching a single SNMP credential by ID
 */
export function useSnmpCredentialQuery(id: string) {
	return createQuery(() => ({
		queryKey: queryKeys.snmpCredentials.detail(id),
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/v1/snmp-credentials/{id}', {
				params: { path: { id } }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || snmp_failedToFetchSingle());
			}
			return data.data;
		},
		enabled: !!id
	}));
}

/**
 * Mutation hook for creating an SNMP credential
 */
export function useCreateSnmpCredentialMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (credential: SnmpCredential) => {
			const { data } = await apiClient.POST('/api/v1/snmp-credentials', { body: credential });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || snmp_failedToCreate());
			}
			return data.data;
		},
		onSuccess: (newCredential: SnmpCredential) => {
			queryClient.setQueryData<SnmpCredential[]>(queryKeys.snmpCredentials.all, (old) =>
				old ? [...old, newCredential] : [newCredential]
			);
		}
	}));
}

/**
 * Mutation hook for updating an SNMP credential
 */
export function useUpdateSnmpCredentialMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (credential: SnmpCredential) => {
			const { data } = await apiClient.PUT('/api/v1/snmp-credentials/{id}', {
				params: { path: { id: credential.id } },
				body: credential
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || snmp_failedToUpdate());
			}
			return data.data;
		},
		onSuccess: (updatedCredential: SnmpCredential) => {
			queryClient.setQueryData<SnmpCredential[]>(
				queryKeys.snmpCredentials.all,
				(old) => old?.map((c) => (c.id === updatedCredential.id ? updatedCredential : c)) ?? []
			);
			queryClient.setQueryData(
				queryKeys.snmpCredentials.detail(updatedCredential.id),
				updatedCredential
			);
		}
	}));
}

/**
 * Mutation hook for deleting an SNMP credential
 */
export function useDeleteSnmpCredentialMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/v1/snmp-credentials/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || snmp_failedToDelete());
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<SnmpCredential[]>(
				queryKeys.snmpCredentials.all,
				(old) => old?.filter((c) => c.id !== id) ?? []
			);
			queryClient.removeQueries({ queryKey: queryKeys.snmpCredentials.detail(id) });
		}
	}));
}

/**
 * Mutation hook for bulk deleting SNMP credentials
 */
export function useBulkDeleteSnmpCredentialsMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/v1/snmp-credentials/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || snmp_failedToBulkDelete());
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<SnmpCredential[]>(
				queryKeys.snmpCredentials.all,
				(old) => old?.filter((c) => !ids.includes(c.id)) ?? []
			);
			ids.forEach((id) => {
				queryClient.removeQueries({ queryKey: queryKeys.snmpCredentials.detail(id) });
			});
		}
	}));
}
