<script lang="ts">
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import RadioGroup from '$lib/shared/components/forms/input/RadioGroup.svelte';
	import { RotateCcwKey } from 'lucide-svelte';
	import {
		common_apiKey,
		common_generateKey,
		common_pressGenerateKey,
		daemons_apiKeyHelp,
		daemons_generateNewKey,
		daemons_generateNewKeyHelp,
		daemons_pasteApiKey,
		daemons_useExistingKey,
		daemons_useExistingKeyHelp,
		daemons_useKey
	} from '$lib/paraglide/messages';

	interface Props {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		form: { Field: any };
		formValues: Record<string, string | number | boolean>;
		apiKey: string | null;
		keySet: boolean;
		isServerPoll: boolean;
		onGenerateKey: () => void;
		onUseExistingKey: () => void;
	}

	let { form, formValues, apiKey, keySet, isServerPoll, onGenerateKey, onUseExistingKey }: Props =
		$props();
</script>

<div class="space-y-3 pb-2">
	{#if !isServerPoll}
		<form.Field name="keySource">
			{#snippet children(field: AnyFieldApi)}
				<RadioGroup
					label={common_apiKey()}
					id="key-source"
					{field}
					options={[
						{
							value: 'generate',
							label: daemons_generateNewKey(),
							helpText: daemons_generateNewKeyHelp()
						},
						{
							value: 'existing',
							label: daemons_useExistingKey(),
							helpText: daemons_useExistingKeyHelp()
						}
					]}
					disabled={keySet}
				/>
			{/snippet}
		</form.Field>
	{/if}

	{#if formValues.keySource === 'generate'}
		<!-- Generate new key flow -->
		<div class="flex items-start gap-2">
			<button
				class="btn-primary m-1 flex-shrink-0 self-stretch"
				disabled={keySet}
				type="button"
				onclick={() => onGenerateKey()}
			>
				<RotateCcwKey />
				<span>{common_generateKey()}</span>
			</button>

			<div class="flex-1">
				<CodeContainer
					language="bash"
					expandable={false}
					code={apiKey ? apiKey : common_pressGenerateKey()}
				/>
			</div>
		</div>
		{#if !apiKey}
			<div class="text-tertiary mt-1 text-xs">
				{daemons_apiKeyHelp()}
			</div>
		{/if}
	{:else}
		<!-- Use existing key flow -->
		<form.Field name="existingKeyInput">
			{#snippet children(field: AnyFieldApi)}
				<div class="flex items-center gap-2">
					<div class="flex-1">
						<TextInput
							label=""
							{field}
							id="existing-key-input"
							placeholder={daemons_pasteApiKey()}
							disabled={keySet}
						/>
					</div>
					<button
						class="btn-primary flex-shrink-0"
						disabled={keySet || !String(formValues.existingKeyInput ?? '').trim()}
						type="button"
						onclick={() => onUseExistingKey()}
					>
						<span>{daemons_useKey()}</span>
					</button>
				</div>
			{/snippet}
		</form.Field>
		{#if apiKey}
			<div class="mt-2">
				<CodeContainer language="bash" expandable={false} code={apiKey} />
			</div>
		{/if}
	{/if}
</div>
