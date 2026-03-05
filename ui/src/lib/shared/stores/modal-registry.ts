import { writable } from 'svelte/store';
import type { EntityDiscriminants } from '$lib/api/entities';
import { entityUIConfig } from '$lib/shared/entity-ui-config';

export interface ModalState {
	name: string | null;
	id: string | null;
	tab: string | null;
	subEntityId: string | null;
}

const EMPTY_STATE: ModalState = { name: null, id: null, tab: null, subEntityId: null };

export const modalState = writable<ModalState>({ ...EMPTY_STATE });

/**
 * Open a modal by name. Updates the store and URL search params.
 */
export function openModal(
	name: string,
	opts?: { id?: string; tab?: string; subEntityId?: string }
): void {
	const state: ModalState = {
		name,
		id: opts?.id ?? null,
		tab: opts?.tab ?? null,
		subEntityId: opts?.subEntityId ?? null
	};
	modalState.set(state);
	syncToUrl(state);
}

/**
 * Close the current modal. Clears the store and URL search params.
 */
export function closeModal(): void {
	modalState.set({ ...EMPTY_STATE });
	syncToUrl(EMPTY_STATE);
}

/**
 * Update the active tab in the current modal. Updates store and URL.
 */
export function setModalTab(tab: string): void {
	modalState.update((s) => {
		const next = { ...s, tab };
		syncToUrl(next);
		return next;
	});
}

/**
 * Read URL params into the modal store. Call once after app initialization.
 */
export function initModalFromUrl(): void {
	if (typeof window === 'undefined') return;
	const params = new URLSearchParams(window.location.search);
	const name = params.get('modal');
	if (!name) return;
	const state: ModalState = {
		name,
		id: params.get('id'),
		tab: params.get('tab'),
		subEntityId: params.get('subEntityId')
	};
	modalState.set(state);
}

/**
 * Navigate to an entity's tab and open its edit modal.
 * For sub-entities (Interface, IfEntry, etc.), opens the parent Host's modal on the relevant tab.
 */
export function navigateToEntity(
	entityType: EntityDiscriminants,
	entityId: string,
	data?: Record<string, unknown>
): void {
	const config = entityUIConfig[entityType];
	if (!config) return;

	if (config.modalName) {
		window.location.hash = config.tabId;
		openModal(config.modalName, { id: entityId });
	} else if (config.parentType && config.parentIdField && data) {
		const parentConfig = entityUIConfig[config.parentType];
		const parentId = data[config.parentIdField] as string | undefined;
		if (parentConfig?.modalName && parentId) {
			window.location.hash = parentConfig.tabId;
			openModal(parentConfig.modalName, {
				id: parentId,
				tab: config.modalTab,
				subEntityId: entityId
			});
		}
	} else {
		// Entity has no modal — just navigate to its tab
		window.location.hash = config.tabId;
	}
}

/**
 * Pure helper for deep-link effects in Tab components.
 * Returns the entity to edit (T), null for create mode, or undefined for no action.
 */
export function resolveModalDeepLink<T extends { id: string }>(
	state: ModalState,
	modalName: string,
	data: T[],
	isOpen: boolean,
	editingId: string | null | undefined,
	validate?: (entity: T) => boolean
): T | null | undefined {
	if (state.name !== modalName) return undefined;

	if (!isOpen) {
		if (state.id) {
			const entity = data.find((e) => e.id === state.id);
			if (entity && (!validate || validate(entity))) return entity;
		} else {
			return null; // Create mode
		}
	} else if (state.id && state.id !== editingId) {
		const entity = data.find((e) => e.id === state.id);
		if (entity && (!validate || validate(entity))) return entity;
	}

	return undefined;
}

function syncToUrl(state: ModalState): void {
	if (typeof window === 'undefined') return;
	const url = new URL(window.location.href);
	if (state.name) {
		url.searchParams.set('modal', state.name);
		if (state.id) {
			url.searchParams.set('id', state.id);
		} else {
			url.searchParams.delete('id');
		}
		if (state.tab) {
			url.searchParams.set('tab', state.tab);
		} else {
			url.searchParams.delete('tab');
		}
		if (state.subEntityId) {
			url.searchParams.set('subEntityId', state.subEntityId);
		} else {
			url.searchParams.delete('subEntityId');
		}
	} else {
		url.searchParams.delete('modal');
		url.searchParams.delete('id');
		url.searchParams.delete('tab');
		url.searchParams.delete('subEntityId');
	}
	window.history.replaceState({}, '', url.toString());
}
