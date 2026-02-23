<script lang="ts">
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import type { FormValue } from '$lib/shared/components/forms/validators';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import { SvelteSet } from 'svelte/reactivity';
	import { common_documentation } from '$lib/paraglide/messages';
	import { fieldDefs, sectionDefs } from '../../../config';

	interface Props {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		form: { Field: any };
		formValues: Record<string, string | number | boolean>;
	}

	let { form, formValues }: Props = $props();

	const advancedFieldDefs = fieldDefs.filter((d) => d.section);

	// Get unique section names in order of appearance (compare by return value, not function reference)
	const sectionNames = [...new Set(advancedFieldDefs.map((d) => d.section!()))];

	// Group advanced fields by section (compare by return value)
	const advancedSections = sectionNames.map((name) => ({
		name: () => name,
		fields: advancedFieldDefs.filter((d) => d.section!() === name)
	}));

	// Track which sections are expanded (default: all collapsed)
	let expandedSections = new SvelteSet<string>();

	function toggleSection(name: string) {
		if (expandedSections.has(name)) {
			expandedSections.delete(name);
		} else {
			expandedSections.add(name);
		}
	}

	// Get validators for a field
	function getValidators(fieldId: string) {
		const def = fieldDefs.find((d) => d.id === fieldId);
		if (!def?.validators || def.validators.length === 0) return {};

		return {
			onBlur: ({ value }: { value: FormValue }) => {
				for (const validator of def.validators!) {
					const error = validator(value);
					if (error) return error;
				}
				return undefined;
			}
		};
	}
</script>

<div class="space-y-6">
	<!-- eslint-disable-next-line svelte/no-at-html-tags -- trusted i18n content -->
	<p class="docs-hint text-tertiary text-xs">{@html common_documentation()}</p>

	{#each advancedSections as section (section.name)}
		{@const sectionName = section.name()}
		{@const isExpanded = expandedSections.has(sectionName)}
		{@const sectionDef = sectionDefs[sectionName]}
		{@const description = sectionDef?.description()}
		<div class="card">
			<button
				type="button"
				class="flex w-full items-center justify-between text-left focus:outline-none"
				onclick={() => toggleSection(sectionName)}
				aria-expanded={isExpanded}
			>
				<div>
					<div class="text-secondary text-m font-medium">{sectionName}</div>
					{#if description}
						<p class="text-tertiary mt-0.5 text-xs">{description}</p>
					{/if}
				</div>
				{#if isExpanded}
					<ChevronDown class="text-secondary h-4 w-4 flex-shrink-0" />
				{:else}
					<ChevronRight class="text-secondary h-4 w-4 flex-shrink-0" />
				{/if}
			</button>

			{#if isExpanded}
				{#if sectionDef?.docsHint}
					<!-- eslint-disable-next-line svelte/no-at-html-tags -- trusted i18n content -->
					<p class="docs-hint text-tertiary mt-3 text-xs">{@html sectionDef.docsHint()}</p>
				{/if}
				<div class="mt-3 grid grid-cols-2 gap-4">
					{#each section.fields as def (def.id)}
						{#if !def.showWhen || def.showWhen(formValues)}
							{#if def.docsOnly}
								<div></div>
							{:else if def.type === 'string'}
								<form.Field name={def.id} validators={getValidators(def.id)}>
									{#snippet children(field: AnyFieldApi)}
										<TextInput
											label={def.label()}
											{field}
											id={def.id}
											placeholder={String(
												typeof def.placeholder === 'function'
													? def.placeholder()
													: (def.placeholder ?? '')
											)}
											helpText={def.helpText()}
										/>
									{/snippet}
								</form.Field>
							{:else if def.type === 'number'}
								<form.Field name={def.id} validators={getValidators(def.id)}>
									{#snippet children(field: AnyFieldApi)}
										<TextInput
											label={def.label()}
											{field}
											id={def.id}
											type="number"
											placeholder={String(
												typeof def.placeholder === 'function'
													? def.placeholder()
													: (def.placeholder ?? '')
											)}
											helpText={def.helpText()}
										/>
									{/snippet}
								</form.Field>
							{:else if def.type === 'select'}
								<form.Field name={def.id}>
									{#snippet children(field: AnyFieldApi)}
										<SelectInput
											label={def.label()}
											{field}
											id={def.id}
											options={(def.options ?? []).map((opt) => ({
												value: opt.value,
												label: opt.label()
											}))}
											helpText={def.helpText()}
										/>
									{/snippet}
								</form.Field>
							{:else if def.type === 'boolean'}
								<form.Field name={def.id}>
									{#snippet children(field: AnyFieldApi)}
										<Checkbox label={def.label()} {field} id={def.id} helpText={def.helpText()} />
									{/snippet}
								</form.Field>
							{/if}
						{/if}
					{/each}
				</div>
			{/if}
		</div>
	{/each}
</div>

<style>
	.docs-hint :global(a) {
		color: var(--color-blue-500, #3b82f6);
	}
	.docs-hint :global(a:hover) {
		text-decoration: underline;
	}
</style>
