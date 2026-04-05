<script lang="ts">
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import type { HostDisplayContext } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import type { ServiceDisplayContext } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import type { Host } from '$lib/features/hosts/types/base';
	import type { Tag as TagType } from '$lib/features/tags/types/base';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useServicesCacheQuery } from '$lib/features/services/queries';
	import { useBulkAddTagMutation } from '$lib/features/tags/queries';
	import TagBadge from '$lib/shared/components/data/Tag.svelte';
	import { concepts } from '$lib/shared/stores/metadata';
	import {
		appWizard_assignDescription,
		appWizard_inheritanceNote,
		appWizard_bulkAssign,
		appWizard_selectedCount
	} from '$lib/paraglide/messages';

	let {
		appGroupTags
	}: {
		appGroupTags: TagType[];
	} = $props();

	const hostsQuery = useHostsQuery({ limit: 0 });
	const servicesCacheQuery = useServicesCacheQuery();
	const bulkAddTagMutation = useBulkAddTagMutation();

	let allHosts = $derived(hostsQuery.data?.items ?? []);
	let allServices = $derived(servicesCacheQuery.data ?? []);

	// Selection state
	let selectedHosts: Host[] = $state([]);

	function getHostContext(host: Host): HostDisplayContext {
		const hostServices = allServices.filter((s) => s.host_id === host.id);
		return {
			showEntityTagPicker: true,
			entityTags: appGroupTags,
			services: hostServices
		};
	}

	function getServiceContext(): ServiceDisplayContext {
		return {
			showEntityTagPicker: true,
			entityTags: appGroupTags
		};
	}

	// Bulk assign
	async function handleBulkAssign(tagId: string) {
		const hostIds = selectedHosts.map((h) => h.id);
		if (hostIds.length === 0) return;

		await bulkAddTagMutation.mutateAsync({
			entity_ids: hostIds,
			entity_type: 'Host',
			tag_id: tagId
		});
		selectedHosts = [];
	}
</script>

<div class="flex h-full flex-col space-y-4">
	<p class="text-secondary text-sm">
		{appWizard_assignDescription()}
	</p>

	<p class="text-tertiary text-xs italic">
		{appWizard_inheritanceNote()}
	</p>

	<!-- Host list with ListManager -->
	<div class="min-h-0 flex-1 overflow-y-auto">
		<ListManager
			label=""
			items={allHosts}
			itemDisplayComponent={HostDisplay}
			getItemContext={(host) => getHostContext(host)}
			optionDisplayComponent={HostDisplay}
			allowAddFromOptions={false}
			allowReorder={false}
			allowSelection={true}
			itemClickAction="select"
			bind:selectedItems={selectedHosts}
			allowItemEdit={() => false}
			allowItemRemove={() => false}
		>
			{#snippet itemExpandedSnippet({ item })}
				{@const host = item}
				{@const hostServices = allServices.filter((s) => s.host_id === host.id)}
				{#if hostServices.length > 0}
					<div class="mt-2 w-full space-y-1 border-t border-gray-200 pt-2 dark:border-gray-700">
						{#each hostServices as service (service.id)}
							<div class="pl-8">
								<ListSelectItem
									item={service}
									context={getServiceContext()}
									displayComponent={ServiceDisplay}
								/>
							</div>
						{/each}
					</div>
				{/if}
			{/snippet}
		</ListManager>
	</div>

	<!-- Bulk assign bar -->
	{#if selectedHosts.length > 0}
		<div
			class="card card-static sticky bottom-0 flex items-center gap-3 border-t px-4 py-3 shadow-lg"
		>
			<span class="text-secondary whitespace-nowrap text-sm font-medium">
				{appWizard_selectedCount({ count: String(selectedHosts.length) })}
			</span>
			<span class="text-tertiary text-sm">{appWizard_bulkAssign()}</span>
			<div class="flex flex-wrap gap-2">
				{#each appGroupTags as tag (tag.id)}
					<button
						type="button"
						class="cursor-pointer"
						onclick={() => handleBulkAssign(tag.id)}
						disabled={bulkAddTagMutation.isPending}
					>
						<TagBadge
							label={tag.name}
							color={tag.color}
							icon={concepts.getIconComponent('Application')}
							isShiny={true}
							pill={true}
						/>
					</button>
				{/each}
			</div>
		</div>
	{/if}
</div>
