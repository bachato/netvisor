<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ChecklistItem from '$lib/shared/components/data/ChecklistItem.svelte';
	import { selectedNodes } from '../queries';
	import { dependencyTypes } from '$lib/shared/stores/metadata';
	import { browser } from '$app/environment';
	import { TUTORIAL_NODES, makeTutorialNode } from './dependency-tutorial-data';
	import {
		topology_tutorialTitle,
		topology_tutorialStep1,
		topology_tutorialStep2,
		topology_tutorialStep3,
		topology_tutorialStep4,
		topology_tutorialSkip
	} from '$lib/paraglide/messages';

	let {
		onDismiss,
		dependencyTypeToggled = false
	}: {
		onDismiss: () => void;
		dependencyTypeToggled?: boolean;
	} = $props();

	const modifier = browser && navigator.platform.includes('Mac') ? '⌘' : 'Ctrl';

	// Track which pseudo-nodes the user has clicked
	let clickedNodeIds = $state(new Set<string>());

	function handleNodeClick(tutorialNode: (typeof TUTORIAL_NODES)[number]) {
		if (clickedNodeIds.has(tutorialNode.id)) return;
		const updated = new Set(clickedNodeIds);
		updated.add(tutorialNode.id);
		clickedNodeIds = updated;

		// Inject into selectedNodes store incrementally
		const fakeNode = makeTutorialNode(tutorialNode);
		const current = [...$selectedNodes];
		current.push(fakeNode);
		selectedNodes.set(current);
	}

	let step1Done = $derived(clickedNodeIds.size >= 1);
	let step2Done = $derived(clickedNodeIds.size >= 3);
	let step3Done = $derived(dependencyTypeToggled);

	// Get dependency type icons from metadata
	const RequestPathIcon = dependencyTypes.getIconComponent('RequestPath');
	const HubAndSpokeIcon = dependencyTypes.getIconComponent('HubAndSpoke');

	// Selection progress dots
	let selectionDots = $derived(TUTORIAL_NODES.map((n) => clickedNodeIds.has(n.id)));
</script>

<!-- Shroud over the topology viewer -->
<div class="absolute inset-0 z-20 bg-black/60 backdrop-blur-sm"></div>

<!-- Modal anchored to topology view -->
<div class="tutorial-anchor">
	<GenericModal
		title={topology_tutorialTitle()}
		isOpen={true}
		showCloseButton={false}
		preventCloseOnClickOutside={true}
		showBackdrop={false}
		size="md"
	>
		<div class="flex flex-col gap-6 p-6">
			<!-- Pseudo-nodes -->
			<div class="flex items-center justify-center gap-4">
				{#each TUTORIAL_NODES as node (node.id)}
					<button
						class="card flex min-w-[120px] items-center justify-center gap-2 px-4 py-3 text-sm font-medium transition-all
							{clickedNodeIds.has(node.id)
							? 'ring-accent/60 bg-accent/10 text-accent ring-2'
							: 'card-static text-secondary hover:text-primary hover:ring-accent/30 cursor-pointer hover:ring-1'}"
						onclick={() => handleNodeClick(node)}
						disabled={clickedNodeIds.has(node.id)}
					>
						{node.label}
					</button>
				{/each}
			</div>

			<!-- Selection progress dots (sidebar checklist pattern) -->
			<div class="flex items-center justify-center gap-0.5">
				{#each selectionDots as filled}
					<span
						class="inline-block h-1.5 w-1.5 rounded-full {filled
							? 'bg-green-400'
							: 'bg-gray-300 dark:bg-gray-600'}"
					></span>
				{/each}
			</div>

			<!-- Step checklist using ChecklistItem -->
			<div>
				<ChecklistItem
					checked={step1Done}
					disabled={step1Done}
					label={topology_tutorialStep1()}
				/>
				<ChecklistItem
					checked={step2Done}
					disabled={step2Done}
					label={topology_tutorialStep2({ modifier })}
				/>
				<ChecklistItem
					checked={step3Done}
					disabled={step3Done || !step2Done}
					label={topology_tutorialStep3()}
				>
					{#snippet labelExtra()}
						<svelte:component this={RequestPathIcon} class="h-3.5 w-3.5" />
						<svelte:component this={HubAndSpokeIcon} class="h-3.5 w-3.5" />
					{/snippet}
				</ChecklistItem>
				<ChecklistItem
					checked={false}
					disabled={!step3Done}
					label={topology_tutorialStep4()}
				/>
			</div>

			<!-- Skip button -->
			<div class="text-center">
				<button
					class="text-secondary hover:text-primary text-xs underline"
					onclick={onDismiss}
				>
					{topology_tutorialSkip()}
				</button>
			</div>
		</div>
	</GenericModal>
</div>

<style>
	/* Override GenericModal's fixed viewport positioning to anchor within the topology view */
	.tutorial-anchor :global(.modal-page) {
		position: absolute;
		z-index: 30;
	}
</style>
