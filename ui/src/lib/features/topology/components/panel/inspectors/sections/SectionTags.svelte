<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import type { TopologyEditState } from '$lib/features/topology/state';
	import type {
		ElementRenderContext,
		ContainerRenderContext
	} from '$lib/features/topology/resolvers';
	import type { EntityDiscriminants } from '$lib/features/tags/queries';
	import { activePerspective } from '$lib/features/topology/queries';
	import { getInspectorConfig } from '$lib/features/topology/components/panel/inspectors/perspective-config';
	import { concepts } from '$lib/shared/stores/metadata';
	import {
		common_tags,
		tags_applicationGroup,
		tags_inheritedFromHost,
		tags_inheritedOverrideHint,
		tags_overridesFromHost
	} from '$lib/paraglide/messages';

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

	// Show app-group picker when perspective metadata enables it and element is a Service
	let showAppGroupPicker = $derived(
		getInspectorConfig($activePerspective).show_application_group_picker && entityType === 'Service'
	);

	// App-group tags from topology entity_tags
	let entityTags = $derived(topology?.entity_tags ?? []);
	let appGroupTags = $derived(entityTags.filter((t) => t.is_application_group));
	let appGroupTagIds = $derived(new Set(appGroupTags.map((t) => t.id)));

	// Non-app-group tags for the regular picker
	let nonAppGroupTags = $derived(entityTags.filter((t) => !t.is_application_group));

	// Filter app-group tags out of regular picker's selectedTagIds
	let regularSelectedTagIds = $derived(selectedTagIds.filter((id) => !appGroupTagIds.has(id)));

	// App-group selected tags: check direct tags first, then host tags (inheritance)
	let selectedAppGroupTagIds = $derived.by(() => {
		const direct = selectedTagIds.filter((id) => appGroupTagIds.has(id));
		if (direct.length > 0) return direct;
		if (elementContext?.host) {
			return elementContext.host.tags.filter((id) => appGroupTagIds.has(id));
		}
		return [];
	});
	let hasAppGroupTag = $derived(selectedAppGroupTagIds.length > 0);

	// Detect inherited vs direct vs override
	let isAppGroupInherited = $derived(
		hasAppGroupTag && !selectedTagIds.some((id) => appGroupTagIds.has(id))
	);

	// Host's app-group tag (for override detection)
	let hostAppGroupTagId = $derived.by(() => {
		if (!elementContext?.host) return null;
		return elementContext.host.tags.find((id) => appGroupTagIds.has(id)) ?? null;
	});

	// Override: service has direct app-group tag different from host's
	let isAppGroupOverride = $derived(
		!isAppGroupInherited &&
			hostAppGroupTagId !== null &&
			!selectedAppGroupTagIds.includes(hostAppGroupTagId)
	);

	let hostAppGroupTag = $derived(
		hostAppGroupTagId ? appGroupTags.find((t) => t.id === hostAppGroupTagId) : null
	);

	// Current app-group tag object for badge display
	let currentAppGroupTag = $derived(
		hasAppGroupTag
			? (appGroupTags.find((t) => selectedAppGroupTagIds.includes(t.id)) ?? null)
			: null
	);

	// Available tags for picker: if inherited, hide picker. If direct, show for removal.
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
			selectedTagIds={regularSelectedTagIds}
			{entityId}
			{entityType}
			disabled={!editState.isEditable}
			availableTags={isReadonly ? topology.entity_tags : nonAppGroupTags}
		/>
	</div>

	{#if showAppGroupPicker}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">{tags_applicationGroup()}</span>
			{#if hasAppGroupTag && currentAppGroupTag}
				<div class="mb-1 flex flex-wrap items-center gap-1">
					<Tag
						label={currentAppGroupTag.name}
						color={currentAppGroupTag.color}
						icon={concepts.getIconComponent('Application')}
						isShiny={true}
					/>
					{#if isAppGroupInherited}
						<span class="text-tertiary text-xs">{tags_inheritedFromHost()}</span>
					{:else if isAppGroupOverride && hostAppGroupTag}
						<span class="text-tertiary text-xs"
							>{tags_overridesFromHost({ tag: hostAppGroupTag.name })}</span
						>
					{/if}
				</div>
				{#if isAppGroupInherited}
					<p class="text-tertiary mb-1 text-xs">{tags_inheritedOverrideHint()}</p>
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
	{/if}
{/if}
