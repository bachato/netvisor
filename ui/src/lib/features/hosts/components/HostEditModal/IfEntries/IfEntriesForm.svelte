<script lang="ts">
	import type { HostFormData, IfEntry } from '$lib/features/hosts/types/base';
	import { getOperStatusLabels } from '$lib/features/snmp/types/base';
	import IfEntryConfigPanel from './IfEntryConfigPanel.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import {
		common_unknown,
		hosts_ifEntries_noInterfaces,
		hosts_ifEntries_noInterfacesHelp,
		hosts_ifEntries_selectToView,
		hosts_ifEntries_subtitle,
		hosts_ifEntries_title
	} from '$lib/paraglide/messages';

	interface Props {
		formData: HostFormData;
	}

	let { formData }: Props = $props();

	let selectedIfEntry = $state<IfEntry | null>(null);

	// Sort if_entries by if_index
	let sortedIfEntries = $derived(
		[...(formData.if_entries ?? [])].sort((a, b) => a.if_index - b.if_index)
	);

	function handleSelect(entry: IfEntry) {
		selectedIfEntry = entry;
	}

	function getEntryLabel(entry: IfEntry): string {
		return entry.if_descr || `Interface ${entry.if_index}`;
	}

	function getEntryDescription(entry: IfEntry): string {
		const operStatusLabels = getOperStatusLabels();
		const status = entry.oper_status ? operStatusLabels[entry.oper_status] : common_unknown();
		return `Index ${entry.if_index} - ${status}`;
	}

	function getStatusColor(entry: IfEntry): string {
		if (entry.oper_status === 'Up') return 'text-green-400';
		if (entry.oper_status === 'Down') return 'text-red-400';
		return 'text-yellow-400';
	}

	// Get icon component for empty state
	const IfEntryIcon = entities.getIconComponent('IfEntry');
</script>

<div class="flex h-full">
	{#if sortedIfEntries.length === 0}
		<div class="flex flex-1 items-center justify-center p-6">
			<div class="text-center">
				<div class="text-secondary mb-2">
					<IfEntryIcon class="mx-auto h-12 w-12 opacity-50" />
				</div>
				<h3 class="text-primary text-lg font-medium">{hosts_ifEntries_noInterfaces()}</h3>
				<p class="text-muted mt-1 text-sm">
					{hosts_ifEntries_noInterfacesHelp()}
				</p>
			</div>
		</div>
	{:else}
		<!-- Left panel: List of IfEntries -->
		<div class="w-80 flex-shrink-0 overflow-y-auto border-r border-gray-700">
			<div class="border-b border-gray-700 p-4">
				<h3 class="text-primary text-sm font-medium">
					{hosts_ifEntries_title({ count: sortedIfEntries.length })}
				</h3>
				<p class="text-muted mt-1 text-xs">{hosts_ifEntries_subtitle()}</p>
			</div>
			<ul class="divide-y divide-gray-700">
				{#each sortedIfEntries as entry (entry.id)}
					<li>
						<button
							type="button"
							onclick={() => handleSelect(entry)}
							class="w-full px-4 py-3 text-left transition-colors hover:bg-gray-800/50 {selectedIfEntry?.id ===
							entry.id
								? 'bg-gray-800'
								: ''}"
						>
							<div class="flex items-center justify-between">
								<div class="min-w-0 flex-1">
									<p class="text-primary truncate text-sm font-medium">
										{getEntryLabel(entry)}
									</p>
									<p class="text-muted truncate text-xs">
										{getEntryDescription(entry)}
									</p>
								</div>
								<div class="ml-2 flex-shrink-0">
									<span
										class="inline-flex h-2 w-2 rounded-full {getStatusColor(
											entry
										)} {entry.oper_status === 'Up'
											? 'bg-green-400'
											: entry.oper_status === 'Down'
												? 'bg-red-400'
												: 'bg-yellow-400'}"
									></span>
								</div>
							</div>
						</button>
					</li>
				{/each}
			</ul>
		</div>

		<!-- Right panel: IfEntry details -->
		<div class="flex-1 overflow-y-auto">
			{#if selectedIfEntry}
				<IfEntryConfigPanel ifEntry={selectedIfEntry} />
			{:else}
				<div class="flex h-full items-center justify-center p-6">
					<p class="text-muted text-sm">{hosts_ifEntries_selectToView()}</p>
				</div>
			{/if}
		</div>
	{/if}
</div>
