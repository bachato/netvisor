/**
 * TanStack Query hook for server configuration
 */

import { createQuery } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { components } from '$lib/api/schema';

export type OidcProviderMetadata = components['schemas']['OidcProviderMetadata'];
export type DeploymentType = components['schemas']['DeploymentType'];
export type PublicServerConfig = components['schemas']['PublicConfigResponse'];

export const isLicenseLocked = (cfg: PublicServerConfig) =>
	cfg.license_status === 'expired' || cfg.license_status === 'invalid';

// Helper functions for deployment type checks
export const isCloud = (cfg: PublicServerConfig) => cfg.deployment_type === 'cloud';
export const isCommercial = (cfg: PublicServerConfig) => cfg.deployment_type === 'commercial';
export const isCommunity = (cfg: PublicServerConfig) => cfg.deployment_type === 'community';
export const isSelfHosted = (cfg: PublicServerConfig) =>
	cfg.deployment_type === 'commercial' || cfg.deployment_type === 'community';

/**
 * Query hook for fetching server configuration
 */
export function useConfigQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.config.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/config', {});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch config');
			}
			return data.data as PublicServerConfig;
		},
		staleTime: Infinity, // Config rarely changes
		gcTime: Infinity
	}));
}
