<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import TagPickerInline from '$lib/features/tags/components/TagPickerInline.svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import type { TopologyEditState } from '$lib/features/topology/state';
	import type {
		ElementRenderContext,
		ContainerRenderContext
	} from '$lib/features/topology/resolvers';
	import { useTagsQuery, type EntityDiscriminants } from '$lib/features/tags/queries';
	import { common_tags } from '$lib/paraglide/messages';

	/* eslint-disable @typescript-eslint/no-unused-vars -- component contract props */
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
	/* eslint-enable @typescript-eslint/no-unused-vars */

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
		if (elementContext) {
			if (elementContext.elementType === 'Interface') return elementContext.host?.tags ?? [];
			if (elementContext.elementType === 'Service' && elementContext.services.length > 0) {
				return elementContext.services[0].tags;
			}
		}
		if (containerContext?.subnet) return containerContext.subnet.tags;
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
</script>

{#if entityId && entityType}
	<div>
		<span class="text-secondary mb-2 block text-sm font-medium">{common_tags()}</span>
		<TagPickerInline
			{selectedTagIds}
			{entityId}
			{entityType}
			disabled={!editState.isEditable}
			availableTags={isReadonly ? entityTags : entityTags}
		/>
	</div>
{/if}
