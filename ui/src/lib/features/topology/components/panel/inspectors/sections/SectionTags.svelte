<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import type { Topology } from '$lib/features/topology/types/base';
	import type { TopologyEditState } from '$lib/features/topology/state';
	import type {
		ElementRenderContext,
		ContainerRenderContext
	} from '$lib/features/topology/resolvers';
	import type { EntityDiscriminants } from '$lib/features/tags/queries';
	import { activePerspective } from '$lib/features/topology/queries';
	import { common_tags, tags_applicationGroup } from '$lib/paraglide/messages';

	// eslint-disable-next-line @typescript-eslint/no-unused-vars
	let {
		node,
		topology,
		editState,
		elementContext,
		containerContext
	}: {
		node: Node;
		topology: Topology;
		editState: TopologyEditState;
		elementContext?: ElementRenderContext;
		containerContext?: ContainerRenderContext;
	} = $props();

	let isReadonly = $derived(editState.isReadonly);

	// Determine the entity for tagging based on context
	let entityId = $derived.by((): string | undefined => {
		if (elementContext) {
			if (elementContext.elementType === 'Interface') return elementContext.hostId;
			if (elementContext.services.length > 0) return elementContext.services[0].id;
		}
		if (containerContext?.subnet) return containerContext.subnet.id;
		return undefined;
	});

	let entityType = $derived.by((): EntityDiscriminants | undefined => {
		if (elementContext) {
			if (elementContext.elementType === 'Interface') return 'Host';
			return 'Service';
		}
		if (containerContext?.subnet) return 'Subnet';
		return undefined;
	});

	let selectedTagIds = $derived.by((): string[] => {
		if (elementContext?.elementType === 'Interface' && elementContext.host) {
			return elementContext.host.tags;
		}
		if (elementContext?.elementType === 'Service' && elementContext.services.length > 0) {
			return elementContext.services[0].tags;
		}
		if (containerContext?.subnet) return containerContext.subnet.tags;
		return [];
	});

	// Show app-group picker for Service elements in Application perspective
	let showAppGroupPicker = $derived(
		$activePerspective === 'Application' && entityType === 'Service'
	);

	// App-group tags for the picker
	const tagsQuery = useTagsQuery();
	let allTags = $derived(tagsQuery.data ?? []);
	let appGroupTags = $derived(allTags.filter((t) => t.is_application_group));
	let appGroupTagIds = $derived(new Set(appGroupTags.map((t) => t.id)));

	// Non-app-group tags for the regular picker (filter out app-group tags)
	let nonAppGroupTags = $derived(allTags.filter((t) => !t.is_application_group));

	// App-group selected tags (only app-group tag IDs from entity's tags)
	let selectedAppGroupTagIds = $derived(selectedTagIds.filter((id) => appGroupTagIds.has(id)));
	let hasAppGroupTag = $derived(selectedAppGroupTagIds.length > 0);

	// If already tagged, only show current tag (for removal). Otherwise show all app-group tags.
	let appGroupAvailableTags = $derived(
		hasAppGroupTag
			? appGroupTags.filter((t) => selectedAppGroupTagIds.includes(t.id))
			: appGroupTags
	);
</script>

{#if entityId && entityType}
	<div>
		<span class="text-secondary mb-2 block text-sm font-medium">{common_tags()}</span>
		<TagPickerInline
			{selectedTagIds}
			{entityId}
			{entityType}
			disabled={!editState.isEditable}
			availableTags={isReadonly ? topology.entity_tags : nonAppGroupTags}
		/>
	</div>

	{#if showAppGroupPicker}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">{tags_applicationGroup()}</span>
			<TagPickerInline
				selectedTagIds={selectedAppGroupTagIds}
				{entityId}
				{entityType}
				disabled={!editState.isEditable}
				availableTags={appGroupAvailableTags}
				allowCreate={false}
			/>
		</div>
	{/if}
{/if}
