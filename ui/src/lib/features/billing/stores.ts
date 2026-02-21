import { writable } from 'svelte/store';

// When true, closing the billing modal should reopen the settings modal
export const reopenSettingsAfterBilling = writable(false);
