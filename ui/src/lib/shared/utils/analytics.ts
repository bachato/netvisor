import posthog from 'posthog-js';
import { queryClient, queryKeys } from '$lib/api/query-client';
import type { Organization } from '$lib/features/organizations/types';
import type { PublicServerConfig } from '$lib/shared/stores/config-query';
import type { components } from '$lib/api/schema';

type TelemetryOperation = components['schemas']['TelemetryOperation'];

/**
 * Check if the current organization is in demo mode.
 * Demo users should not have their data tracked.
 */
export function isDemo(): boolean {
	const org = queryClient.getQueryData<Organization | null>(queryKeys.organizations.current());
	return org?.plan?.type === 'Demo';
}

/**
 * Check if an onboarding operation has already been completed.
 * Used to ensure "first_*" events only fire once.
 */
export function hasCompletedOnboarding(operation: TelemetryOperation): boolean {
	const org = queryClient.getQueryData<Organization | null>(queryKeys.organizations.current());
	return org?.onboarding?.includes(operation) ?? false;
}

/**
 * Track an analytics event via PostHog.
 * PostHog is already initialized in +layout.svelte, this is just a helper.
 * In demo mode, events are tracked with a demo=true flag.
 *
 * Events focused on understanding friction:
 * - onboarding_blocker_selected - What's blocking users?
 * - onboarding_blocker_resolved - Did resolution help?
 * - onboarding_compatibility_issue - Only when incompatible
 * - onboarding_feedback_submitted - "Something else" friction
 */
export function trackEvent(event: string, properties?: Record<string, unknown>) {
	if (posthog.__loaded) {
		posthog.capture(event, properties);
	}
}

const ONCE_PREFIX = 'scanopy_tracked_';

/**
 * Track an event only once per browser (persisted via localStorage).
 * Useful for "first_*" milestone events where the backend may have already
 * updated state by the time the frontend detects the condition.
 */
export function trackEventOnce(event: string, properties?: Record<string, unknown>) {
	if (typeof localStorage === 'undefined') return;

	const key = `${ONCE_PREFIX}${event}`;
	if (localStorage.getItem(key)) return;

	trackEvent(event, properties);
	localStorage.setItem(key, 'true');
}

/**
 * Identify a user in PostHog.
 * Links all events to this user's profile.
 * Safe to call multiple times - PostHog deduplicates.
 * Skips identification in demo mode.
 */
export function identifyUser(userId: string, email: string, organizationId: string) {
	if (isDemo()) return;
	if (posthog.__loaded) {
		posthog.identify(userId, {
			email,
			organization_id: organizationId
		});
	}
}

/**
 * Reset PostHog identity on logout.
 * Unlinks future events from the user.
 */
export function resetIdentity() {
	if (posthog.__loaded) {
		posthog.reset();
	}
}

/**
 * Track a user event in Plunk for email marketing.
 * Uses the public key from server config.
 * Skips tracking in demo mode.
 */
export async function trackPlunkEvent(
	event: string,
	email: string,
	subscribed: boolean
): Promise<void> {
	if (isDemo()) return;

	const cfg = queryClient.getQueryData<PublicServerConfig>(queryKeys.config.all);
	const plunkKey = cfg?.plunk_key;

	if (!plunkKey) {
		return;
	}

	try {
		await fetch('https://next-api.useplunk.com/v1/track', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				Authorization: `Bearer ${plunkKey}`
			},
			body: JSON.stringify({
				event,
				email,
				subscribed
			})
		});
	} catch (error) {
		// Silently fail - email tracking is not critical
		console.warn('Failed to track Plunk event:', error);
	}
}
