<script lang="ts">
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import { AVAILABLE_COLORS, type Color } from '$lib/shared/utils/styling';
	import { createDefaultTag } from '$lib/features/tags/types/base';
	import type { Tag as TagType } from '$lib/features/tags/types/base';
	import { useCreateTagMutation, useDeleteTagMutation } from '$lib/features/tags/queries';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { getSuggestions } from '../suggestions';
	import { concepts } from '$lib/shared/stores/metadata';
	import {
		appWizard_createYourOwn,
		appWizard_defineGroupsDescription,
		appWizard_noGroupsYet,
		appWizard_suggestedGroups,
		appWizard_mspAddClient,
		appWizard_mspClientPlaceholder,
		appWizard_mspClientExplanation
	} from '$lib/paraglide/messages';
	import { createForm } from '@tanstack/svelte-form';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';

	let {
		appGroupTags
	}: {
		appGroupTags: TagType[];
	} = $props();

	const organizationQuery = useOrganizationQuery();
	const createTagMutation = useCreateTagMutation();
	const deleteTagMutation = useDeleteTagMutation();

	let organization = $derived(organizationQuery.data);
	let useCase = $derived(organization?.use_case ?? null);
	let isMsp = $derived(useCase === 'msp');

	let suggestions = $derived(getSuggestions(useCase));
	let existingNames = $derived(new Set(appGroupTags.map((t) => t.name.toLowerCase())));
	let availableSuggestions = $derived(
		suggestions.filter((s) => !existingNames.has(s.toLowerCase()))
	);

	// Stable color per suggestion so each is different
	function getSuggestionColor(index: number): Color {
		return AVAILABLE_COLORS[index % AVAILABLE_COLORS.length];
	}

	let isCreating = $state(false);

	function getRandomColor(): Color {
		return AVAILABLE_COLORS[Math.floor(Math.random() * AVAILABLE_COLORS.length)];
	}

	async function createAppGroupTag(name: string) {
		if (!organization || isCreating) return;
		const trimmed = name.trim();
		if (!trimmed || existingNames.has(trimmed.toLowerCase())) return;

		isCreating = true;
		try {
			const tag = createDefaultTag(organization.id);
			tag.name = trimmed;
			tag.color = getRandomColor();
			(tag as TagType & { is_application_group: boolean }).is_application_group = true;
			await createTagMutation.mutateAsync(tag);
		} finally {
			isCreating = false;
		}
	}

	async function deleteAppGroupTag(tagId: string) {
		await deleteTagMutation.mutateAsync(tagId);
	}

	// MSP client name form
	const clientForm = createForm(() => ({
		defaultValues: { clientName: '' },
		onSubmit: async ({ value }) => {
			await createAppGroupTag(value.clientName);
			clientForm.reset();
		}
	}));
</script>

<div class="space-y-6">
	<p class="text-secondary text-sm">
		{appWizard_defineGroupsDescription()}
	</p>

	<!-- Suggested groups as application-styled tags -->
	{#if availableSuggestions.length > 0}
		<div>
			<h3 class="text-secondary mb-2 text-xs font-medium uppercase tracking-wide">
				{appWizard_suggestedGroups()}
			</h3>
			<div class="flex flex-wrap gap-2">
				{#each availableSuggestions as suggestion, i (suggestion)}
					<button
						type="button"
						class="cursor-pointer"
						onclick={() => createAppGroupTag(suggestion)}
						disabled={isCreating}
					>
						<Tag
							label={suggestion}
							color={getSuggestionColor(i)}
							icon={concepts.getIconComponent('Application')}
							isShiny={true}
							pill={true}
						/>
					</button>
				{/each}
			</div>
		</div>
	{/if}

	<!-- MSP client input -->
	{#if isMsp}
		<div>
			<p class="text-tertiary mb-2 text-sm">{appWizard_mspClientExplanation()}</p>
			<form
				onsubmit={(e) => {
					e.preventDefault();
					e.stopPropagation();
					clientForm.handleSubmit();
				}}
				class="flex items-end gap-2"
			>
				<div class="flex-1">
					<clientForm.Field name="clientName">
						{#snippet children(field)}
							<TextInput
								label=""
								id="client-name"
								{field}
								placeholder={appWizard_mspClientPlaceholder()}
								disabled={isCreating}
							/>
						{/snippet}
					</clientForm.Field>
				</div>
				<button type="submit" class="btn-primary" disabled={isCreating}>
					{appWizard_mspAddClient()}
				</button>
			</form>
		</div>
	{/if}

	<!-- Custom group entry via TagPickerInline -->
	<div>
		<h3 class="text-secondary mb-2 text-xs font-medium uppercase tracking-wide">
			{appWizard_createYourOwn()}
		</h3>
		<TagPickerInline
			selectedTagIds={appGroupTags.map((t) => t.id)}
			onAdd={() => {}}
			onRemove={(tagId) => deleteAppGroupTag(tagId)}
			createAsApplicationGroup={true}
		/>
	</div>

	<!-- Empty state -->
	{#if appGroupTags.length === 0}
		<p class="text-tertiary text-center text-sm italic">
			{appWizard_noGroupsYet()}
		</p>
	{/if}
</div>
