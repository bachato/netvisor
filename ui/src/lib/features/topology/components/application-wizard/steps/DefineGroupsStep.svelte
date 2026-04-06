<script lang="ts">
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import { AVAILABLE_COLORS, type Color } from '$lib/shared/utils/styling';
	import { createDefaultTag } from '$lib/features/tags/types/base';
	import type { Tag as TagType } from '$lib/features/tags/types/base';
	import { useCreateTagMutation, useDeleteTagMutation } from '$lib/features/tags/queries';
	import { useQueryClient } from '@tanstack/svelte-query';
	import { queryKeys } from '$lib/api/query-client';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { getSuggestions } from '../suggestions';
	import { concepts } from '$lib/shared/stores/metadata';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import {
		appWizard_createYourOwn,
		appWizard_defineGroupsDescription,
		appWizard_noGroupsYet,
		appWizard_suggestedGroups,
		appWizard_mspCallout
	} from '$lib/paraglide/messages';

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

	// Stable color per suggestion based on position in the full suggestions list
	function getSuggestionColor(name: string): Color {
		const idx = suggestions.indexOf(name);
		return AVAILABLE_COLORS[(idx >= 0 ? idx : 0) % AVAILABLE_COLORS.length];
	}

	let isCreating = $state(false);

	function getRandomColor(): Color {
		return AVAILABLE_COLORS[Math.floor(Math.random() * AVAILABLE_COLORS.length)];
	}

	async function createAppGroupTag(name: string, color?: Color) {
		if (!organization || isCreating) return;
		const trimmed = name.trim();
		if (!trimmed || existingNames.has(trimmed.toLowerCase())) return;

		isCreating = true;
		try {
			const tag = createDefaultTag(organization.id);
			tag.name = trimmed;
			tag.color = color ?? getRandomColor();
			(tag as TagType & { is_application_group: boolean }).is_application_group = true;
			await createTagMutation.mutateAsync(tag);
		} finally {
			isCreating = false;
		}
	}

	const queryClient = useQueryClient();

	async function deleteAppGroupTag(tagId: string) {
		await deleteTagMutation.mutateAsync(tagId);
		// Invalidate host/service caches so deleted tag IDs are cleaned up
		queryClient.invalidateQueries({ queryKey: queryKeys.hosts.lists() });
		queryClient.invalidateQueries({ queryKey: queryKeys.services.all });
	}
</script>

<div class="space-y-6">
	<p class="text-secondary text-sm">
		{appWizard_defineGroupsDescription()}
	</p>

	<!-- MSP callout -->
	{#if isMsp}
		<InlineInfo title={appWizard_mspCallout()} dismissableKey="msp-client-callout" />
	{/if}

	<!-- Suggested groups as application-styled tags -->
	{#if availableSuggestions.length > 0}
		<div>
			<h3 class="text-secondary mb-2 text-xs font-medium uppercase tracking-wide">
				{appWizard_suggestedGroups()}
			</h3>
			<div class="flex flex-wrap gap-2">
				{#each availableSuggestions as suggestion (suggestion)}
					{@const suggestionColor = getSuggestionColor(suggestion)}
					<button
						type="button"
						class="cursor-pointer"
						onclick={() => createAppGroupTag(suggestion, suggestionColor)}
						disabled={isCreating}
					>
						<Tag
							label={suggestion}
							color={suggestionColor}
							icon={concepts.getIconComponent('Application')}
							isShiny={true}
							pill={true}
						/>
					</button>
				{/each}
			</div>
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
