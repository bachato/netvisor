import { writable, get } from 'svelte/store';
import type { UseCase, NetworkSetup } from '../types/base';

export interface OnboardingState {
	useCase: UseCase | null;
	organizationName: string;
	network: NetworkSetup;
	populateSeedData: boolean;
	// Referral source (Cloud only, not persisted to DB)
	referralSource: string | null;
	referralSourceOther: string | null;
}

const STORAGE_KEY = 'scanopy_onboarding';

// Fields to persist to localStorage (for billing page autofill)
interface PersistedState {
	useCase: UseCase | null;
}

function loadPersistedState(): PersistedState {
	if (typeof window === 'undefined') {
		return { useCase: null };
	}
	try {
		const stored = localStorage.getItem(STORAGE_KEY);
		if (stored) {
			const parsed = JSON.parse(stored);
			return {
				useCase: parsed.useCase ?? null
			};
		}
	} catch {
		// Ignore localStorage errors
	}
	return { useCase: null };
}

function savePersistedState(state: PersistedState): void {
	if (typeof window === 'undefined') return;
	try {
		localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
	} catch {
		// Ignore localStorage errors
	}
}

const persisted = loadPersistedState();

const initialState: OnboardingState = {
	useCase: persisted.useCase,
	organizationName: '',
	network: { name: '' },
	populateSeedData: true,
	referralSource: null,
	referralSourceOther: null
};

function createOnboardingStore() {
	const { subscribe, update } = writable<OnboardingState>({ ...initialState });

	// Helper to update and persist
	function updateAndPersist(updater: (state: OnboardingState) => OnboardingState): void {
		update((state) => {
			const newState = updater(state);
			savePersistedState({
				useCase: newState.useCase
			});
			return newState;
		});
	}

	return {
		subscribe,
		// Reset clears most state but preserves useCase for billing page
		reset: () =>
			updateAndPersist((state) => ({
				...initialState,
				network: { name: '' },
				useCase: state.useCase // Preserve for billing page
			})),

		setUseCase: (useCase: UseCase) =>
			updateAndPersist((state) => ({
				...state,
				useCase
			})),

		setOrganizationName: (name: string) =>
			update((state) => ({
				...state,
				organizationName: name
			})),

		setNetwork: (network: NetworkSetup) =>
			update((state) => ({
				...state,
				network
			})),

		setNetworkId: (networkId: string) =>
			update((state) => ({
				...state,
				network: { ...state.network, id: networkId }
			})),

		setPopulateSeedData: (populate: boolean) =>
			update((state) => ({
				...state,
				populateSeedData: populate
			})),

		setReferralSource: (referralSource: string | null, referralSourceOther: string | null) =>
			update((state) => ({
				...state,
				referralSource,
				referralSourceOther
			})),

		// Get the current state synchronously
		getState: () => get({ subscribe })
	};
}

export const onboardingStore = createOnboardingStore();
