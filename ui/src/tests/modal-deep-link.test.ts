import { describe, it, expect } from 'vitest';
import { resolveModalDeepLink } from '$lib/shared/stores/modal-registry';
import type { ModalState } from '$lib/shared/stores/modal-registry';

interface TestEntity {
	id: string;
	name: string;
}

const entities: TestEntity[] = [
	{ id: 'aaa', name: 'Alpha' },
	{ id: 'bbb', name: 'Bravo' },
	{ id: 'ccc', name: 'Charlie' }
];

function state(name: string | null, id: string | null = null): ModalState {
	return { name, id, tab: null, subEntityId: null };
}

describe('resolveModalDeepLink', () => {
	it('returns undefined when modal name does not match', () => {
		const result = resolveModalDeepLink(
			state('other-modal', 'aaa'),
			'my-modal',
			entities,
			false,
			null
		);
		expect(result).toBeUndefined();
	});

	it('returns undefined when state name is null', () => {
		const result = resolveModalDeepLink(state(null), 'my-modal', entities, false, null);
		expect(result).toBeUndefined();
	});

	it('returns null for create mode (no id, modal closed)', () => {
		const result = resolveModalDeepLink(state('my-modal'), 'my-modal', entities, false, null);
		expect(result).toBeNull();
	});

	it('returns entity when id matches and modal is closed', () => {
		const result = resolveModalDeepLink(
			state('my-modal', 'bbb'),
			'my-modal',
			entities,
			false,
			null
		);
		expect(result).toEqual({ id: 'bbb', name: 'Bravo' });
	});

	it('returns undefined when id not found in data (data not loaded yet)', () => {
		const result = resolveModalDeepLink(
			state('my-modal', 'zzz'),
			'my-modal',
			entities,
			false,
			null
		);
		expect(result).toBeUndefined();
	});

	it('returns undefined when id not found in empty data array', () => {
		const result = resolveModalDeepLink(state('my-modal', 'aaa'), 'my-modal', [], false, null);
		expect(result).toBeUndefined();
	});

	it('returns entity for entity switch (modal open, different id)', () => {
		const result = resolveModalDeepLink(
			state('my-modal', 'ccc'),
			'my-modal',
			entities,
			true,
			'aaa'
		);
		expect(result).toEqual({ id: 'ccc', name: 'Charlie' });
	});

	it('returns undefined when already editing the same entity', () => {
		const result = resolveModalDeepLink(
			state('my-modal', 'aaa'),
			'my-modal',
			entities,
			true,
			'aaa'
		);
		expect(result).toBeUndefined();
	});

	it('returns undefined when modal is open with no id (create mode already open)', () => {
		const result = resolveModalDeepLink(state('my-modal'), 'my-modal', entities, true, null);
		expect(result).toBeUndefined();
	});

	describe('validate callback', () => {
		const alwaysFail = () => false;
		const alwaysPass = () => true;

		it('returns entity when validate passes', () => {
			const result = resolveModalDeepLink(
				state('my-modal', 'aaa'),
				'my-modal',
				entities,
				false,
				null,
				alwaysPass
			);
			expect(result).toEqual({ id: 'aaa', name: 'Alpha' });
		});

		it('returns undefined when validate fails (modal closed)', () => {
			const result = resolveModalDeepLink(
				state('my-modal', 'aaa'),
				'my-modal',
				entities,
				false,
				null,
				alwaysFail
			);
			expect(result).toBeUndefined();
		});

		it('returns undefined when validate fails during entity switch', () => {
			const result = resolveModalDeepLink(
				state('my-modal', 'bbb'),
				'my-modal',
				entities,
				true,
				'aaa',
				alwaysFail
			);
			expect(result).toBeUndefined();
		});

		it('returns entity when validate passes during entity switch', () => {
			const result = resolveModalDeepLink(
				state('my-modal', 'bbb'),
				'my-modal',
				entities,
				true,
				'aaa',
				alwaysPass
			);
			expect(result).toEqual({ id: 'bbb', name: 'Bravo' });
		});

		it('does not call validate for create mode', () => {
			const result = resolveModalDeepLink(
				state('my-modal'),
				'my-modal',
				entities,
				false,
				null,
				alwaysFail
			);
			expect(result).toBeNull();
		});
	});
});
