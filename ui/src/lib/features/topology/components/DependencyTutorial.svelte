<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ChecklistItem from '$lib/shared/components/data/ChecklistItem.svelte';
	import ElementNodeCard from './visualization/ElementNodeCard.svelte';
	import { selectedNodes, OPTIONS_PANEL_WIDTH_PX, OPTIONS_PANEL_LEFT_OFFSET_PX } from '../queries';
	import { dependencyTypes, serviceDefinitions, entities } from '$lib/shared/stores/metadata';
	import { browser } from '$app/environment';
	import {
		TUTORIAL_SERVICES,
		TUTORIAL_XYFLOW_NODES
	} from './dependency-tutorial-data';
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

	const hostIconClass = entities.getColorHelper('Host').icon;

	// Prepare display data for each tutorial node
	const tutorialCards = TUTORIAL_SERVICES.map((svc) => ({
		...svc,
		services: [
			{
				name: svc.label,
				icon: serviceDefinitions.getIconComponent(svc.serviceDefinition),
				iconClass: hostIconClass
			}
		]
	}));

	// Track which nodes the user has clicked
	let clickedNodeIds = $state(new Set<string>());

	function handleNodeClick(svc: (typeof TUTORIAL_SERVICES)[number]) {
		if (clickedNodeIds.has(svc.id)) return;
		const updated = new Set(clickedNodeIds);
		updated.add(svc.id);
		clickedNodeIds = updated;

		const xyNode = TUTORIAL_XYFLOW_NODES.find((n) => n.id === svc.id);
		if (xyNode) {
			selectedNodes.set([...$selectedNodes, xyNode]);
		}
	}

	// Offset modal to the right of the options panel
	const modalLeftOffset = OPTIONS_PANEL_WIDTH_PX + OPTIONS_PANEL_LEFT_OFFSET_PX + 16;

	let step1Done = $derived(clickedNodeIds.size >= 1);
	let step2Done = $derived(clickedNodeIds.size >= 3);
	let step3Done = $derived(dependencyTypeToggled);

	const RequestPathIcon = dependencyTypes.getIconComponent('RequestPath');
	const HubAndSpokeIcon = dependencyTypes.getIconComponent('HubAndSpoke');

	let selectionDots = $derived(TUTORIAL_SERVICES.map((n) => clickedNodeIds.has(n.id)));
</script>

<!-- Shroud over the topology viewer -->
<div class="absolute inset-0 z-20 bg-black/60 backdrop-blur-sm"></div>

<!-- Modal anchored to topology view -->
<div class="tutorial-anchor" style="--tutorial-offset: {modalLeftOffset}px;">
	<GenericModal
		title={topology_tutorialTitle()}
		isOpen={true}
		showCloseButton={false}
		preventCloseOnClickOutside={true}
		showBackdrop={false}
		size="lg"
	>
		<div class="flex flex-col p-6">
			<!-- Mini topology area with dot background -->
			<div class="tutorial-canvas relative mb-6 h-56 overflow-hidden rounded-xl">
				<!-- Triangle layout: top-center, bottom-left, bottom-right -->
				<button
					class="absolute cursor-pointer"
					style="top: 12px; left: 50%; transform: translateX(-50%);"
					onclick={() => handleNodeClick(TUTORIAL_SERVICES[0])}
					disabled={clickedNodeIds.has(TUTORIAL_SERVICES[0].id)}
				>
					<ElementNodeCard
						headerText={tutorialCards[0].hostName}
						services={tutorialCards[0].services}
						selected={clickedNodeIds.has(TUTORIAL_SERVICES[0].id)}
					/>
				</button>

				<button
					class="absolute cursor-pointer"
					style="bottom: 12px; left: 12%;"
					onclick={() => handleNodeClick(TUTORIAL_SERVICES[1])}
					disabled={clickedNodeIds.has(TUTORIAL_SERVICES[1].id)}
				>
					<ElementNodeCard
						headerText={tutorialCards[1].hostName}
						services={tutorialCards[1].services}
						selected={clickedNodeIds.has(TUTORIAL_SERVICES[1].id)}
					/>
				</button>

				<button
					class="absolute cursor-pointer"
					style="bottom: 12px; right: 12%;"
					onclick={() => handleNodeClick(TUTORIAL_SERVICES[2])}
					disabled={clickedNodeIds.has(TUTORIAL_SERVICES[2].id)}
				>
					<ElementNodeCard
						headerText={tutorialCards[2].hostName}
						services={tutorialCards[2].services}
						selected={clickedNodeIds.has(TUTORIAL_SERVICES[2].id)}
					/>
				</button>
			</div>

			<!-- Selection progress dots -->
			<div class="mb-3 flex items-center gap-0.5">
				{#each selectionDots as filled}
					<span
						class="inline-block h-1.5 w-1.5 rounded-full {filled
							? 'bg-green-400'
							: 'bg-gray-300 dark:bg-gray-600'}"
					></span>
				{/each}
			</div>

			<!-- Step checklist -->
			<div class="space-y-0">
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
			<div class="mt-4 text-center">
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
	.tutorial-anchor :global(.modal-page) {
		position: absolute;
		z-index: 20;
		left: var(--tutorial-offset);
		right: 0;
		top: 0;
		bottom: 0;
	}

	.tutorial-canvas {
		background-color: var(--color-topology-bg, #0f1117);
		background-image: radial-gradient(circle, var(--color-border) 1px, transparent 1px);
		background-size: 50px 50px;
	}
</style>
