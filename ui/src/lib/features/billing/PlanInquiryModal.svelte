<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import { submitForm } from '$lib/shared/components/forms/form-context';
	import { email as emailValidatorFn, required } from '$lib/shared/components/forms/validators';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';
	import {
		billing_inquiryLabel,
		billing_inquiryPlaceholder,
		billing_requestInfo,
		billing_sendRequest,
		common_cancel,
		common_email,
		common_sending
	} from '$lib/paraglide/messages';

	interface Props {
		isOpen?: boolean;
		planName?: string;
		userEmail?: string;
		onClose: () => void;
		onSubmit: (email: string, message: string) => void | Promise<void>;
	}

	let { isOpen = false, planName = '', userEmail = '', onClose, onSubmit }: Props = $props();

	let loading = $state(false);

	function getDefaultValues() {
		return {
			email: userEmail,
			message: ''
		};
	}

	const form = createForm(() => ({
		defaultValues: getDefaultValues(),
		onSubmit: async ({ value }) => {
			loading = true;
			try {
				await onSubmit(value.email, value.message);
				onClose();
			} finally {
				loading = false;
			}
		}
	}));

	function handleOpen() {
		form.reset(getDefaultValues());
	}

	async function handleSubmit() {
		await submitForm(form);
	}
</script>

<GenericModal
	title={billing_requestInfo({ planName })}
	{isOpen}
	{onClose}
	onOpen={handleOpen}
	size="md"
	showCloseButton={true}
>
	<form
		onsubmit={(e) => {
			e.preventDefault();
			e.stopPropagation();
			handleSubmit();
		}}
		class="flex min-h-0 flex-1 flex-col"
	>
		<div class="flex-1 overflow-auto p-6">
			<div class="space-y-4">
				<form.Field
					name="email"
					validators={{
						onBlur: ({ value }) => required(value) || emailValidatorFn(value)
					}}
				>
					{#snippet children(field)}
						<TextInput
							label={common_email()}
							id="inquiry-email"
							{field}
							placeholder="your@email.com"
							required
						/>
					{/snippet}
				</form.Field>

				<form.Field name="message">
					{#snippet children(field)}
						<TextArea
							label={billing_inquiryLabel()}
							id="inquiry-message"
							{field}
							placeholder={billing_inquiryPlaceholder({ planName })}
							rows={5}
						/>
					{/snippet}
				</form.Field>
			</div>
		</div>

		<div class="modal-footer">
			<div class="flex items-center justify-end gap-3">
				<button type="button" disabled={loading} onclick={onClose} class="btn-secondary">
					{common_cancel()}
				</button>
				<button type="submit" disabled={loading} class="btn-primary">
					{loading ? common_sending() : billing_sendRequest()}
				</button>
			</div>
		</div>
	</form>
</GenericModal>
