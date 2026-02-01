<script lang="ts">
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import type { HostFormData } from '$lib/features/hosts/types/base';
	import { hostnameFormat, max, required } from '$lib/shared/components/forms/validators';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';
	import {
		common_description,
		common_hostname,
		common_name,
		common_placeholderHostname,
		hosts_details_descriptionPlaceholder,
		hosts_details_namePlaceholder
	} from '$lib/paraglide/messages';

	interface Props {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		form: { Field: any };
		formData: HostFormData;
	}

	let { form, formData = $bindable() }: Props = $props();

	// Track network_id separately (not a form field, so needs manual sync)
	let selectedNetworkId = $state(formData.network_id);
	$effect(() => {
		formData.network_id = selectedNetworkId;
	});
</script>

<div class="space-y-6 p-6">
	<div class="grid grid-cols-2 gap-6">
		<form.Field
			name="name"
			validators={{
				onBlur: ({ value }: { value: string }) => required(value) || max(100)(value)
			}}
		>
			{#snippet children(field: AnyFieldApi)}
				<TextInput
					label={common_name()}
					id="name"
					placeholder={hosts_details_namePlaceholder()}
					required={true}
					{field}
				/>
			{/snippet}
		</form.Field>

		<form.Field
			name="hostname"
			validators={{
				onBlur: ({ value }: { value: string }) => hostnameFormat(value)
			}}
		>
			{#snippet children(field: AnyFieldApi)}
				<TextInput
					label={common_hostname()}
					id="hostname"
					placeholder={common_placeholderHostname()}
					{field}
				/>
			{/snippet}
		</form.Field>
	</div>

	<SelectNetwork bind:selectedNetworkId />

	<form.Field
		name="description"
		validators={{
			onBlur: ({ value }: { value: string }) => max(500)(value)
		}}
	>
		{#snippet children(field: AnyFieldApi)}
			<TextArea
				label={common_description()}
				id="description"
				placeholder={hosts_details_descriptionPlaceholder()}
				{field}
			/>
		{/snippet}
	</form.Field>

	<TagPicker bind:selectedTagIds={formData.tags} />
</div>
