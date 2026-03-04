import { writable } from 'svelte/store';
import type { UpgradeFeature } from '$lib/shared/stores/metadata';

// When true, closing the billing modal should reopen the settings modal
export const reopenSettingsAfterBilling = writable(false);

/** Context for feature-specific upgrade CTAs. Set before opening billing modal. */
export const upgradeContext = writable<{ feature: UpgradeFeature } | null>(null);
