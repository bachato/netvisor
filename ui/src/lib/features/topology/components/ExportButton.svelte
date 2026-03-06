<script lang="ts">
	import { toPng, toSvg } from 'html-to-image';
	import { useSvelteFlow, type Node } from '@xyflow/svelte';
	import { Download, FileImage, FileCode, FileText, Image } from 'lucide-svelte';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { billingPlans } from '$lib/shared/stores/metadata';
	import { isExporting } from '../interactions';
	import {
		topology_createdUsing,
		topology_export,
		topology_exportComplete,
		topology_exportFailed,
		topology_exportPng,
		topology_exportPngDesc,
		topology_exportSvg,
		topology_exportSvgDesc,
		topology_exportMermaid,
		topology_exportMermaidDesc,
		topology_exportConfluence,
		topology_exportConfluenceDesc,
		topology_flowNotFound,
		topology_noNodesToExport
	} from '$lib/paraglide/messages';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { downloadTopologyExport } from '$lib/shared/utils/csvExport';
	import UpgradeBadge from '$lib/shared/components/UpgradeBadge.svelte';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import { openModal } from '$lib/shared/stores/modal-registry';
	import { upgradeContext } from '$lib/features/billing/stores';
	import type { UpgradeFeature } from '$lib/shared/stores/metadata';

	let { topologyId, isShareView = false }: { topologyId: string; isShareView?: boolean } = $props();

	const { getNodes, getEdges, getViewport, setViewport } = useSvelteFlow();

	// TanStack Query for organization
	const organizationQuery = useOrganizationQuery();
	let organization = $derived(organizationQuery.data);

	let hideCreatedWith = $derived.by(() => {
		if (organization && organization.plan && organization.plan.type) {
			return billingPlans.getMetadata(organization.plan.type).features.remove_created_with;
		} else {
			return false;
		}
	});

	let hasSvgExport = $derived(
		organization?.plan ? billingPlans.getMetadata(organization.plan.type).features.svg_export : true
	);

	let hasMermaidExport = $derived(
		organization?.plan
			? billingPlans.getMetadata(organization.plan.type).features.mermaid_export
			: true
	);

	let hasConfluenceExport = $derived(
		organization?.plan
			? billingPlans.getMetadata(organization.plan.type).features.confluence_export
			: true
	);

	let isModalOpen = $state(false);

	function getAbsolutePosition(node: Node, nodes: Node[]) {
		if (node.parentId) {
			const parent = nodes.find((n) => n.id === node.parentId);
			if (parent) {
				return {
					x: parent.position.x + node.position.x,
					y: parent.position.y + node.position.y
				};
			}
		}
		return { x: node.position.x, y: node.position.y };
	}

	function calculateExportBounds() {
		const nodes = getNodes();
		const edges = getEdges();

		if (nodes.length === 0) {
			pushError(topology_noNodesToExport());
			return null;
		}

		const flowElement = document.querySelector('.svelte-flow') as HTMLElement;
		if (!flowElement) {
			pushError(topology_flowNotFound());
			return null;
		}

		const childNodes = nodes.filter((n) => n.parentId);
		const parentNodes = nodes.filter((n) => !n.parentId);
		const parentIdsWithChildren = new Set(childNodes.map((n) => n.parentId));
		const standaloneNodes = parentNodes.filter((n) => !parentIdsWithChildren.has(n.id));

		let minX = Infinity,
			minY = Infinity,
			maxX = -Infinity,
			maxY = -Infinity;

		childNodes.forEach((child) => {
			const absPos = getAbsolutePosition(child, nodes);
			const width = child.measured?.width || child.width || 150;
			const height = child.measured?.height || child.height || 50;
			minX = Math.min(minX, absPos.x);
			minY = Math.min(minY, absPos.y);
			maxX = Math.max(maxX, absPos.x + width);
			maxY = Math.max(maxY, absPos.y + height);
		});

		standaloneNodes.forEach((node) => {
			const x = node.position.x;
			const y = node.position.y;
			const width = node.measured?.width || node.width || 150;
			const height = node.measured?.height || node.height || 50;
			minX = Math.min(minX, x);
			minY = Math.min(minY, y);
			maxX = Math.max(maxX, x + width);
			maxY = Math.max(maxY, y + height);
		});

		const parentBorderMargin = 20;
		parentNodes
			.filter((n) => parentIdsWithChildren.has(n.id))
			.forEach((parent) => {
				minX = Math.min(minX, parent.position.x - parentBorderMargin);
				minY = Math.min(minY, parent.position.y - parentBorderMargin);
			});

		edges.forEach((edge) => {
			const sourceNode = nodes.find((n) => n.id === edge.source);
			const targetNode = nodes.find((n) => n.id === edge.target);
			if (sourceNode && targetNode) {
				const sourcePos = getAbsolutePosition(sourceNode, nodes);
				const targetPos = getAbsolutePosition(targetNode, nodes);
				const sourceCenterX =
					sourcePos.x + (sourceNode.measured?.width || sourceNode.width || 150) / 2;
				const sourceCenterY =
					sourcePos.y + (sourceNode.measured?.height || sourceNode.height || 50) / 2;
				const targetCenterX =
					targetPos.x + (targetNode.measured?.width || targetNode.width || 150) / 2;
				const targetCenterY =
					targetPos.y + (targetNode.measured?.height || targetNode.height || 50) / 2;
				minX = Math.min(minX, sourceCenterX, targetCenterX);
				minY = Math.min(minY, sourceCenterY, targetCenterY);
				maxX = Math.max(maxX, sourceCenterX, targetCenterX);
				maxY = Math.max(maxY, sourceCenterY, targetCenterY);
			}
		});

		const edgeMargin = 150;
		minX -= edgeMargin;
		minY -= edgeMargin;
		maxX += edgeMargin;
		maxY += edgeMargin;

		const boundsWidth = maxX - minX;
		const boundsHeight = maxY - minY;
		const targetZoom = 0.75;
		const imageWidth = Math.round(boundsWidth * targetZoom);
		const imageHeight = Math.round(boundsHeight * targetZoom);
		const boundsCenterX = minX + boundsWidth / 2;
		const boundsCenterY = minY + boundsHeight / 2;
		const x = imageWidth / 2 - boundsCenterX * targetZoom;
		const y = imageHeight / 2 - boundsCenterY * targetZoom;

		return { flowElement, imageWidth, imageHeight, viewport: { x, y, zoom: targetZoom } };
	}

	async function captureImage(format: 'png' | 'svg') {
		const bounds = calculateExportBounds();
		if (!bounds) return;

		const { flowElement, imageWidth, imageHeight, viewport: newViewport } = bounds;
		const originalViewport = getViewport();
		const originalWidth = flowElement.style.width;
		const originalHeight = flowElement.style.height;

		flowElement.style.width = `${imageWidth}px`;
		flowElement.style.height = `${imageHeight}px`;
		setViewport(newViewport, { duration: 0 });
		flowElement.classList.add('hide-for-export');
		isExporting.set(true);

		let watermark = document.createElement('div');

		if (!hideCreatedWith) {
			watermark = document.createElement('div');
			watermark.style.cssText = `
				position: absolute;
				bottom: 15px;
				right: 15px;
				display: flex;
				align-items: center;
				gap: 8px;
				color: rgba(255, 255, 255, 0.5);
				font-size: 14px;
				font-family: system-ui;
				pointer-events: none;
				z-index: 9999;
			`;

			const logo = document.createElement('img');
			logo.src = '/logos/scanopy-logo.png';
			logo.style.cssText = `
				height: 18px;
				width: auto;
			`;

			const text = document.createElement('span');
			text.textContent = topology_createdUsing();

			watermark.appendChild(logo);
			watermark.appendChild(text);
			flowElement.appendChild(watermark);

			await new Promise<void>((resolve) => {
				if (logo.complete) {
					resolve();
				} else {
					logo.onload = () => resolve();
					logo.onerror = () => resolve();
				}
			});
		}

		await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));

		try {
			const options = { width: imageWidth, height: imageHeight, pixelRatio: 2 };
			const dataUrl =
				format === 'svg' ? await toSvg(flowElement, options) : await toPng(flowElement, options);

			const link = document.createElement('a');
			const date = new Date().toISOString().split('T')[0];
			link.download = `scanopy-topology-${date}.${format}`;
			link.href = dataUrl;
			link.click();
			pushSuccess(topology_exportComplete());
			trackEvent('topology_exported', { format });
		} catch (err) {
			console.error('Export failed:', err);
			pushError(topology_exportFailed());
		} finally {
			isExporting.set(false);
			watermark.remove();
			flowElement.classList.remove('hide-for-export');
			flowElement.style.width = originalWidth;
			flowElement.style.height = originalHeight;
			setTimeout(() => setViewport(originalViewport, { duration: 0 }), 50);
		}
	}

	async function handlePngExport() {
		isModalOpen = false;
		await captureImage('png');
	}

	async function handleSvgExport() {
		isModalOpen = false;
		await captureImage('svg');
	}

	async function handleMermaidExport() {
		isModalOpen = false;
		try {
			await downloadTopologyExport(topologyId, 'mermaid');
			pushSuccess(topology_exportComplete());
			trackEvent('topology_exported', { format: 'mermaid' });
		} catch {
			pushError(topology_exportFailed());
		}
	}

	async function handleConfluenceExport() {
		isModalOpen = false;
		try {
			await downloadTopologyExport(topologyId, 'confluence');
			pushSuccess(topology_exportComplete());
			trackEvent('topology_exported', { format: 'confluence' });
		} catch {
			pushError(topology_exportFailed());
		}
	}

	function handleUpgrade(feature: UpgradeFeature) {
		isModalOpen = false;
		trackEvent('upgrade_button_clicked', { feature });
		upgradeContext.set({ feature });
		openModal('billing-plan');
	}
</script>

<button class="btn-secondary flex items-center gap-1" onclick={() => (isModalOpen = true)}>
	<Download class="my-1 h-5 w-5" />
</button>

<GenericModal
	title={topology_export()}
	isOpen={isModalOpen}
	onClose={() => (isModalOpen = false)}
	size="sm"
>
	<div class="flex flex-col gap-1">
		<button
			class="flex items-center gap-3 rounded-lg px-3 py-3 text-left transition-colors hover:bg-zinc-700/50"
			onclick={handlePngExport}
		>
			<Image class="h-5 w-5 flex-shrink-0 text-zinc-400" />
			<div>
				<div class="text-sm font-medium text-zinc-200">{topology_exportPng()}</div>
				<div class="text-xs text-zinc-400">{topology_exportPngDesc()}</div>
			</div>
		</button>

		{#if hasSvgExport}
			<button
				class="flex items-center gap-3 rounded-lg px-3 py-3 text-left transition-colors hover:bg-zinc-700/50"
				onclick={handleSvgExport}
			>
				<FileImage class="h-5 w-5 flex-shrink-0 text-zinc-400" />
				<div>
					<div class="text-sm font-medium text-zinc-200">{topology_exportSvg()}</div>
					<div class="text-xs text-zinc-400">{topology_exportSvgDesc()}</div>
				</div>
			</button>
		{:else if !isShareView}
			<button
				class="flex items-center gap-3 rounded-lg px-3 py-3 text-left transition-colors hover:bg-zinc-700/50"
				onclick={() => handleUpgrade('svg_export')}
			>
				<FileImage class="h-5 w-5 flex-shrink-0 text-zinc-500" />
				<div class="flex-1">
					<div class="flex items-center gap-2 text-sm font-medium text-zinc-400">
						{topology_exportSvg()}
						<UpgradeBadge feature="svg_export" />
					</div>
					<div class="text-xs text-zinc-500">{topology_exportSvgDesc()}</div>
				</div>
			</button>
		{/if}

		{#if hasMermaidExport}
			<button
				class="flex items-center gap-3 rounded-lg px-3 py-3 text-left transition-colors hover:bg-zinc-700/50"
				onclick={handleMermaidExport}
			>
				<FileCode class="h-5 w-5 flex-shrink-0 text-zinc-400" />
				<div>
					<div class="text-sm font-medium text-zinc-200">{topology_exportMermaid()}</div>
					<div class="text-xs text-zinc-400">{topology_exportMermaidDesc()}</div>
				</div>
			</button>
		{:else if !isShareView}
			<button
				class="flex items-center gap-3 rounded-lg px-3 py-3 text-left transition-colors hover:bg-zinc-700/50"
				onclick={() => handleUpgrade('mermaid_export')}
			>
				<FileCode class="h-5 w-5 flex-shrink-0 text-zinc-500" />
				<div class="flex-1">
					<div class="flex items-center gap-2 text-sm font-medium text-zinc-400">
						{topology_exportMermaid()}
						<UpgradeBadge feature="mermaid_export" />
					</div>
					<div class="text-xs text-zinc-500">{topology_exportMermaidDesc()}</div>
				</div>
			</button>
		{/if}

		{#if hasConfluenceExport}
			<button
				class="flex items-center gap-3 rounded-lg px-3 py-3 text-left transition-colors hover:bg-zinc-700/50"
				onclick={handleConfluenceExport}
			>
				<FileText class="h-5 w-5 flex-shrink-0 text-zinc-400" />
				<div>
					<div class="text-sm font-medium text-zinc-200">{topology_exportConfluence()}</div>
					<div class="text-xs text-zinc-400">{topology_exportConfluenceDesc()}</div>
				</div>
			</button>
		{:else if !isShareView}
			<button
				class="flex items-center gap-3 rounded-lg px-3 py-3 text-left transition-colors hover:bg-zinc-700/50"
				onclick={() => handleUpgrade('confluence_export')}
			>
				<FileText class="h-5 w-5 flex-shrink-0 text-zinc-500" />
				<div class="flex-1">
					<div class="flex items-center gap-2 text-sm font-medium text-zinc-400">
						{topology_exportConfluence()}
						<UpgradeBadge feature="confluence_export" />
					</div>
					<div class="text-xs text-zinc-500">{topology_exportConfluenceDesc()}</div>
				</div>
			</button>
		{/if}
	</div>
</GenericModal>
