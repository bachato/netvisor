import type { components } from '$lib/api/schema';

// Re-export generated types
export type LoginRequest = components['schemas']['LoginRequest'];
export type RegisterRequest = components['schemas']['RegisterRequest'];
export type SetupRequest = components['schemas']['SetupRequest'];
export type SetupResponse = components['schemas']['SetupResponse'];
export type ForgotPasswordRequest = components['schemas']['ForgotPasswordRequest'];
export type ResetPasswordRequest = components['schemas']['ResetPasswordRequest'];
export type VerifyEmailRequest = components['schemas']['VerifyEmailRequest'];
export type ResendVerificationRequest = components['schemas']['ResendVerificationRequest'];

// NetworkSetup extended with optional id (assigned after setup API returns network_ids)
export type NetworkSetup = components['schemas']['NetworkSetup'] & {
	id?: string;
};

// Frontend-only types (not in backend)
export interface SessionUser {
	user_id: string;
	name: string;
}

// Onboarding use case types
export type UseCase = 'homelab' | 'company' | 'msp';

// Consolidated use case configuration
// Icons are mapped separately in components (Svelte component references)
export interface UseCaseConfig {
	label: string;
	description: string;
	orgLabel: string;
	orgPlaceholder: string;
	networkLabel: string;
	networkPlaceholder: string;
	colors: {
		ring: string;
		bg: string;
		text: string;
	};
}

export const USE_CASES: Record<UseCase, UseCaseConfig> = {
	homelab: {
		label: 'Homelab',
		description: 'Home network, NAS, Raspberry Pi, smart devices',
		orgLabel: 'What should we call your setup?',
		orgPlaceholder: 'My Homelab',
		networkLabel: 'Network name',
		networkPlaceholder: 'Home Network',
		colors: {
			ring: 'ring-emerald-500',
			bg: 'bg-emerald-500/20',
			text: 'text-emerald-400'
		}
	},
	company: {
		label: 'Company',
		description: 'Office network, servers, workstations',
		orgLabel: 'Organization name',
		orgPlaceholder: 'Acme Inc',
		networkLabel: 'Network / Location',
		networkPlaceholder: 'HQ, Branch Office',
		colors: {
			ring: 'ring-blue-500',
			bg: 'bg-blue-500/20',
			text: 'text-blue-400'
		}
	},
	msp: {
		label: 'MSP / IT Service Provider',
		description: 'Client networks across multiple locations',
		orgLabel: 'Your company name',
		orgPlaceholder: 'Acme MSP',
		networkLabel: 'Customer network',
		networkPlaceholder: 'Customer - Location',
		colors: {
			ring: 'ring-violet-500',
			bg: 'bg-violet-500/20',
			text: 'text-violet-400'
		}
	}
};
