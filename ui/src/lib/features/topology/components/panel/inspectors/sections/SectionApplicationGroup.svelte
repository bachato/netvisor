<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import type { TopologyEditState } from '$lib/features/topology/state';
	import type { ElementRenderContext } from '$lib/features/topology/resolvers';
	import { useTagsQuery, type EntityDiscriminants } from '$lib/features/tags/queries';
	import { concepts } from '$lib/shared/stores/metadata';
	import {
		tags_applicationGroup,
		tags_inheritedFromHost,
		tags_inheritedOverrideHint,
		common_overrides,
		tags_fromHost
	} from '$lib/paraglide/messages';

	/* eslint-disable @typescript-eslint/no-unused-vars -- component contract props */
	let {
		node,
		topology,
		editState,
		elementContext
	}: {
		node: Node;
		topology: Topology;
		editState: TopologyEditState;
		elementContext?: ElementRenderContext;
	} = $props();
	/* eslint-enable @typescript-eslint/no-unused-vars */

	let entityId = $derived.by((): string | undefined => {
		if (elementContext?.services.length) return elementContext.services[0].id;
		return undefined;
	});

	let entityType = $derived('Service' as EntityDiscriminants);

	let selectedTagIds = $derived.by((): string[] => {
		if (elementContext?.services.length) return elementContext.services[0].tags;
		return [];
	});

	// Merge topology entity_tags with tags query cache for newly created tags
	const tagsQuery = useTagsQuery();
	let entityTags = $derived.by(() => {
		const topoTags = topology?.entity_tags ?? [];
		const cachedTags = tagsQuery.data ?? [];
		const topoIds = new Set(topoTags.map((t) => t.id));
		return [...topoTags, ...cachedTags.filter((t) => !topoIds.has(t.id))];
	});

	// App-group tags
	let appGroupTags = $derived(entityTags.filter((t) => t.is_application_group));
	let appGroupTagIds = $derived(new Set(appGroupTags.map((t) => t.id)));

	// Selected app-group tags: direct first, then inherited from host
	let selectedAppGroupTagIds = $derived.by(() => {
		const direct = selectedTagIds.filter((id) => appGroupTagIds.has(id));
		if (direct.length > 0) return direct;
		if (elementContext?.host) {
			return elementContext.host.tags.filter((id) => appGroupTagIds.has(id));
		}
		return [];
	});
	let hasAppGroupTag = $derived(selectedAppGroupTagIds.length > 0);

	// Inherited vs direct vs override
	let isAppGroupInherited = $derived(
		hasAppGroupTag && !selectedTagIds.some((id) => appGroupTagIds.has(id))
	);

	let hostAppGroupTagId = $derived.by(() => {
		if (!elementContext?.host) return null;
		return elementContext.host.tags.find((id) => appGroupTagIds.has(id)) ?? null;
	});

	let isAppGroupOverride = $derived(
		!isAppGroupInherited &&
			hostAppGroupTagId !== null &&
			!selectedAppGroupTagIds.includes(hostAppGroupTagId)
	);

	let hostAppGroupTag = $derived(
		hostAppGroupTagId ? appGroupTags.find((t) => t.id === hostAppGroupTagId) : null
	);

	let currentAppGroupTag = $derived(
		hasAppGroupTag
			? (appGroupTags.find((t) => selectedAppGroupTagIds.includes(t.id)) ?? null)
			: null
	);

	let appGroupAvailableTags = $derived(
		hasAppGroupTag
			? appGroupTags.filter((t) => selectedAppGroupTagIds.includes(t.id))
			: appGroupTags
	);
</script>

{#if entityId}
	<div class="space-y-2">
		<span class="text-secondary block text-sm font-medium">{tags_applicationGroup()}</span>
		<div class="card card-static space-y-2 p-2">
			{#if hasAppGroupTag && currentAppGroupTag}
				<div class="flex flex-wrap items-center gap-1">
					<Tag
						label={currentAppGroupTag.name}
						color={currentAppGroupTag.color}
						icon={concepts.getIconComponent('Application')}
						isShiny={true}
					/>
					{#if isAppGroupInherited}
						<span class="text-tertiary text-xs">{tags_inheritedFromHost()}</span>
					{:else if isAppGroupOverride && hostAppGroupTag}
						<span class="text-tertiary text-xs">{common_overrides()}</span>
						<Tag
							label={hostAppGroupTag.name}
							color={hostAppGroupTag.color}
							icon={concepts.getIconComponent('Application')}
							isShiny={true}
						/>
						<span class="text-tertiary text-xs">{tags_fromHost()}</span>
					{/if}
				</div>
				{#if isAppGroupInherited}
					<p class="text-tertiary text-xs">{tags_inheritedOverrideHint()}</p>
				{/if}
			{/if}
			<TagPickerInline
				selectedTagIds={isAppGroupInherited ? [] : selectedAppGroupTagIds}
				{entityId}
				{entityType}
				disabled={!editState.isEditable}
				availableTags={isAppGroupInherited ? appGroupTags : appGroupAvailableTags}
				allowCreate={false}
			/>
		</div>
	</div>
{/if}
