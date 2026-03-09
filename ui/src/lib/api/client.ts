/**
 * Typed API client using openapi-fetch
 *
 * This client provides type-safe API calls based on the OpenAPI spec.
 * It includes middleware for request caching, error handling, and credentials.
 */

import createClient, { type Middleware } from 'openapi-fetch';
import type { paths, components } from './schema';
import { pushError } from '$lib/shared/stores/feedback';
import { translateError, type ApiErrorResponse } from '$lib/i18n/errors';
import { env } from '$env/dynamic/public';

// Re-export schema types for convenience
export type { paths, components };

// Common type aliases
export type ApiMeta = {
	api_version: number;
	server_version: string;
};

export type ApiResponse<T> = {
	success: boolean;
	data: T | null;
	error: string | null;
	meta: ApiMeta;
};

export class ApiError extends Error {
	status: number;
	retryAfter: number | null;
	constructor(message: string, status: number, retryAfter: number | null = null) {
		super(message);
		this.name = 'ApiError';
		this.status = status;
		this.retryAfter = retryAfter;
	}
}

// Global rate limit state — when any request gets 429'd, all requests wait
// Persisted to sessionStorage so it survives page refreshes
let rateLimitedUntil = 0;

if (typeof window !== 'undefined') {
	try {
		const stored = sessionStorage.getItem('rateLimitedUntil');
		if (stored) rateLimitedUntil = parseInt(stored, 10) || 0;
	} catch {
		// sessionStorage may not be available
	}
}

// Tracks when the last request was released from the gate, so each subsequent
// request staggers 200ms after the previous one (not a counter that resets)
let lastGateRelease = 0;
const STAGGER_MS = 200;
const MIN_RATE_LIMIT_MS = 3000; // Minimum wait — Retry-After: 1 is too optimistic for stampedes

function setRateLimitedUntil(until: number) {
	const prev = rateLimitedUntil;
	rateLimitedUntil = Math.max(rateLimitedUntil, until);
	console.log(
		`[rate-limit-gate] SET rateLimitedUntil=${rateLimitedUntil} (was=${prev}, requested=${until}, delay=${rateLimitedUntil - Date.now()}ms)`
	);
	try {
		sessionStorage.setItem('rateLimitedUntil', String(rateLimitedUntil));
	} catch {
		// sessionStorage may not be available
	}
}

export function isRateLimited(): boolean {
	return Date.now() < rateLimitedUntil;
}

export function getRateLimitDelay(): number {
	return Math.max(0, rateLimitedUntil - Date.now());
}

/**
 * Get the server URL based on environment configuration
 */
export function getServerUrl(): string {
	// If API is on a different host/port, use explicit config
	if (env.PUBLIC_SERVER_HOSTNAME && env.PUBLIC_SERVER_HOSTNAME !== 'default') {
		const protocol = env.PUBLIC_SERVER_PROTOCOL || 'http';
		const port = env.PUBLIC_SERVER_PORT ? `:${env.PUBLIC_SERVER_PORT}` : '';
		return `${protocol}://${env.PUBLIC_SERVER_HOSTNAME}${port}`;
	}

	// Otherwise, use the exact same origin as the browser
	if (typeof window !== 'undefined') {
		return window.location.origin;
	}

	// SSR fallback
	return '';
}

// Request cache for debouncing duplicate requests
interface CacheEntry {
	promise: Promise<Response>;
	timestamp: number;
	completed: boolean;
	result?: Response;
}

const requestCache = new Map<string, CacheEntry>();
const DEBOUNCE_MS = 500; // Increased from 250 to reduce rapid invalidation impact
const MAX_CACHE_SIZE = 50; // Limit cache size to prevent memory growth

function getRequestKey(request: Request): string {
	const method = request.method;
	const url = request.url;
	// For GET requests, just use method + url
	// For mutations, we don't cache (each should execute)
	if (method === 'GET') {
		return `${method}:${url}`;
	}
	return ''; // Don't cache mutations
}

function cleanupExpiredRequests() {
	const now = Date.now();
	// Remove expired entries
	for (const [key, cache] of requestCache.entries()) {
		if (now - cache.timestamp > DEBOUNCE_MS) {
			requestCache.delete(key);
		}
	}
	// If still over limit, remove oldest entries
	if (requestCache.size > MAX_CACHE_SIZE) {
		const entries = Array.from(requestCache.entries());
		entries.sort((a, b) => a[1].timestamp - b[1].timestamp);
		const toRemove = entries.slice(0, entries.length - MAX_CACHE_SIZE);
		for (const [key] of toRemove) {
			requestCache.delete(key);
		}
	}
}

/**
 * Rate limit gate middleware - delays requests when globally rate-limited
 *
 * When any request receives a 429, all subsequent requests wait until
 * the rate limit window passes (+ jitter) instead of stampeding at once.
 */
const rateLimitGateMiddleware: Middleware = {
	async onRequest({ request }) {
		const delay = getRateLimitDelay();
		const url = new URL(request.url).pathname;
		if (delay > 0) {
			// Schedule this request after both the rate limit window AND
			// the previous release + stagger. This ensures requests trickle
			// out one at a time, even when 429s keep extending the window.
			const now = Date.now();
			const earliestRelease = Math.max(rateLimitedUntil, lastGateRelease + STAGGER_MS);
			lastGateRelease = earliestRelease;
			const waitTime = earliestRelease - now;
			console.log(
				`[rate-limit-gate] HOLDING ${url} for ${waitTime}ms (rateLimitedUntil=${rateLimitedUntil}, lastRelease=${earliestRelease})`
			);
			if (waitTime > 0) {
				await new Promise((resolve) => setTimeout(resolve, waitTime));
			}
			console.log(`[rate-limit-gate] RELEASING ${url}`);
		} else {
			console.log(
				`[rate-limit-gate] PASS ${url} (rateLimitedUntil=${rateLimitedUntil}, now=${Date.now()})`
			);
		}
		return undefined;
	}
};

/**
 * Caching middleware - debounces identical GET requests within 250ms
 */
const cachingMiddleware: Middleware = {
	async onRequest({ request }) {
		cleanupExpiredRequests();

		const cacheKey = getRequestKey(request);
		if (!cacheKey) return undefined; // Don't cache mutations

		const cached = requestCache.get(cacheKey);
		if (cached) {
			const timeSinceRequest = Date.now() - cached.timestamp;
			if (timeSinceRequest < DEBOUNCE_MS) {
				if (cached.completed && cached.result) {
					// Return cached response (clone to allow re-reading body)
					return cached.result.clone();
				}
				// Request is still in progress, wait for it
				const result = await cached.promise;
				return result.clone();
			}
		}

		return undefined;
	},
	async onResponse({ request, response }) {
		const cacheKey = getRequestKey(request);
		if (!cacheKey) return response;

		// Store in cache
		const entry = requestCache.get(cacheKey);
		if (entry) {
			entry.completed = true;
			entry.result = response.clone();
		}

		return response;
	}
};

/**
 * Error handling middleware - shows toast notifications on errors
 *
 * Uses translateError to display localized error messages when the backend
 * provides an error code. Falls back to the raw error message or HTTP status.
 */
const errorMiddleware: Middleware = {
	async onResponse({ response, options }) {
		if (!response.ok) {
			// Don't show error toasts for 401 (expected when not logged in)
			if (response.status === 401) {
				return response;
			}
			// For 429, set global rate limit gate and throw for TanStack Query retry
			if (response.status === 429) {
				const retryAfterHeader = response.headers.get('Retry-After');
				const retryAfter = retryAfterHeader ? parseInt(retryAfterHeader, 10) : null;
				const headerMs = retryAfter && !isNaN(retryAfter) ? retryAfter * 1000 : 5000;
				const retryAfterMs = Math.max(headerMs, MIN_RATE_LIMIT_MS);
				setRateLimitedUntil(Date.now() + retryAfterMs);
				throw new ApiError(
					'Rate limited',
					429,
					retryAfter && !isNaN(retryAfter) ? retryAfter : null
				);
			}
			try {
				const errorData: ApiErrorResponse = await response.clone().json();
				const errorMsg = translateError(errorData);
				// Only show error if not silenced
				if (!(options as { silenceErrors?: boolean }).silenceErrors) {
					pushError(errorMsg);
				}
			} catch {
				if (!(options as { silenceErrors?: boolean }).silenceErrors) {
					pushError(`HTTP ${response.status}: ${response.statusText}`);
				}
			}
		}
		return response;
	}
};

/**
 * Create the typed API client
 *
 * Note: baseUrl does NOT include '/api' because the OpenAPI schema paths
 * already include the '/api' prefix (e.g., '/api/hosts', '/api/networks').
 */
export const apiClient = createClient<paths>({
	baseUrl: getServerUrl(),
	credentials: 'include',
	headers: {
		'Content-Type': 'application/json'
	}
});

// Add middleware (order matters - rate limit gate first, then caching, then error handling)
apiClient.use(rateLimitGateMiddleware);
apiClient.use(cachingMiddleware);
apiClient.use(errorMiddleware);

export default apiClient;
