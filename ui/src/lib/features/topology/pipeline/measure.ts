import { tick } from 'svelte';
import type { Node, Edge } from '@xyflow/svelte';
import type { LayoutState, PrepareResult, XY } from './types';

export interface MeasureCallbacks {
	setMeasuring: (v: boolean) => void;
	setNodes: (n: Node[]) => void;
	setEdges: (e: Edge[]) => void;
	buildMeasureNodes: () => Node[];
}

/**
 * Resolve element/container sizes for ELK layout. Uses cached sizes when
 * available, falls back to a full DOM measurement pass.
 *
 * @returns Size map, or null if the pipeline became stale during async measurement.
 */
export async function resolveNodeSizes(
	state: LayoutState,
	prep: PrepareResult,
	getNodes: () => Node[],
	containerElement: HTMLDivElement,
	isStale: () => boolean,
	callbacks: MeasureCallbacks
): Promise<Map<string, XY> | null> {
	const { collapsed, visibleNodes, isViewTransition, needsElkForExpand, isNewStructure } = prep;
	const viewCacheKey = `${prep.currentView}:${prep.topologyId}`;

	const elementNodeSizes = new Map<string, XY>();

	// Try cached sizes first
	const cachedSizes = isViewTransition ? state.viewSizeCache.get(viewCacheKey) : undefined;
	const expandCachedSizes =
		needsElkForExpand && !isNewStructure ? state.viewSizeCache.get(viewCacheKey) : undefined;

	if (isViewTransition && cachedSizes) {
		for (const node of visibleNodes) {
			const cached = cachedSizes.get(node.id);
			elementNodeSizes.set(node.id, cached ?? { x: 250, y: 100 });
		}
	} else if (expandCachedSizes) {
		for (const node of visibleNodes) {
			const cached = expandCachedSizes.get(node.id);
			elementNodeSizes.set(node.id, cached ?? { x: 250, y: 100 });
		}
	} else if (state.containerSizeCache.size > 0) {
		// Use cached container sizes + SvelteFlow computed element sizes
		const liveNodes = getNodes();
		let elemHits = 0;
		let elemMisses = 0;
		for (const n of liveNodes) {
			// eslint-disable-next-line @typescript-eslint/no-explicit-any -- @xyflow Node has runtime .computed not in type defs
			const w = (n as any).computed?.width ?? n.width;
			// eslint-disable-next-line @typescript-eslint/no-explicit-any -- @xyflow Node has runtime .computed not in type defs
			const h = (n as any).computed?.height ?? n.height;
			if (w && h) {
				elementNodeSizes.set(n.id, { x: w, y: h });
				elemHits++;
			} else {
				elemMisses++;
			}
		}

		// Override containers with cached sizes for their current state
		let cacheHits = 0;
		let cacheMisses = 0;
		for (const node of visibleNodes) {
			if (node.node_type === 'Container') {
				const cache = state.containerSizeCache.get(node.id);
				const isCollapsed = collapsed.has(node.id);
				const cached = isCollapsed ? cache?.collapsed : cache?.expanded;
				if (cached) {
					elementNodeSizes.set(node.id, cached);
					cacheHits++;
				} else {
					cacheMisses++;
					console.log(
						`[CACHE-MISS] ${node.id.substring(0, 8)} collapsed=${isCollapsed} cache=${JSON.stringify(cache)}`
					);
				}
			}
		}

		// Fill missing elements from viewSizeCache
		const viewCache = state.viewSizeCache.get(viewCacheKey);
		if (viewCache && elemMisses > 0) {
			for (const node of visibleNodes) {
				if (!elementNodeSizes.has(node.id)) {
					const cached = viewCache.get(node.id);
					if (cached) {
						elementNodeSizes.set(node.id, cached);
						elemMisses--;
						elemHits++;
					}
				}
			}
		}

		console.log(
			`[CACHE] elemHits=${elemHits} elemMisses=${elemMisses} containerHits=${cacheHits} containerMisses=${cacheMisses} cacheSize=${state.containerSizeCache.size} viewCache=${viewCache?.size ?? 0}`
		);

		// If any containers are missing from cache, fall through to full measurement
		if (cacheMisses > 0) {
			elementNodeSizes.clear();
		}
	}

	// Full DOM measurement pass if no cache
	if (elementNodeSizes.size === 0) {
		callbacks.setMeasuring(true);
		callbacks.setEdges([]);
		callbacks.setNodes(callbacks.buildMeasureNodes());
		await tick();
		await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
		if (isStale()) {
			callbacks.setMeasuring(false);
			return null;
		}

		if (containerElement) {
			const nodeEls = containerElement.querySelectorAll('.svelte-flow__node');
			for (const el of nodeEls) {
				const id = (el as HTMLElement).dataset.id;
				if (id) {
					const htmlEl = el as HTMLElement;
					elementNodeSizes.set(id, {
						x: htmlEl.offsetWidth || 250,
						y: htmlEl.offsetHeight || 100
					});
				}
			}
		}

		// Populate container size cache from this measurement
		for (const [id, size] of elementNodeSizes) {
			if (state.layoutGraph?.containers.has(id)) {
				const entry = state.containerSizeCache.get(id) ?? {};
				if (collapsed.has(id)) {
					entry.collapsed = { ...size };
				} else {
					entry.expanded = { ...size };
				}
				state.containerSizeCache.set(id, entry);
			}
		}
	}

	return elementNodeSizes;
}
