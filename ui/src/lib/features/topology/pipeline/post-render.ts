import type { LayoutGraph } from '../layout/layout-graph';
import type { XY } from './types';

/**
 * Cache collapsed container sizes after render.
 * Unconstrain width to read natural content size, then restore.
 * Synchronous — no paint between write-read-restore.
 *
 * @returns Number of new collapsed cache entries added.
 */
export function cacheCollapsedSizes(
	containerElement: HTMLDivElement,
	layoutGraph: LayoutGraph,
	collapsed: Set<string>,
	containerSizeCache: Map<string, { collapsed?: XY; expanded?: XY }>
): number {
	let newCollapsedCacheEntries = 0;

	const saved = new Map<HTMLElement, { w: string; h: string }>();
	const nodeEls = containerElement.querySelectorAll('.svelte-flow__node');

	for (const el of nodeEls) {
		const htmlEl = el as HTMLElement;
		const id = htmlEl.dataset.id;
		if (id && layoutGraph.containers.has(id) && collapsed.has(id)) {
			if (!containerSizeCache.get(id)?.collapsed) {
				saved.set(htmlEl, { w: htmlEl.style.width, h: htmlEl.style.height });
				htmlEl.style.width = 'auto';
				htmlEl.style.height = 'auto';
				const inner = htmlEl.querySelector(':scope > .relative') as HTMLElement;
				if (inner) {
					saved.set(inner, { w: inner.style.width, h: inner.style.height });
					inner.style.width = 'auto';
					inner.style.height = 'auto';
				}
			}
		}
	}

	if (saved.size > 0) {
		const samples: string[] = [];
		for (const el of nodeEls) {
			const htmlEl = el as HTMLElement;
			const id = htmlEl.dataset.id;
			if (id && saved.has(htmlEl)) {
				const w = htmlEl.offsetWidth || 250;
				const h = htmlEl.offsetHeight || 100;
				const entry = containerSizeCache.get(id) ?? {};
				entry.collapsed = { x: w, y: h };
				containerSizeCache.set(id, entry);
				newCollapsedCacheEntries++;
				if (samples.length < 5) samples.push(`${id.substring(0, 8)}=${w}x${h}`);
			}
		}
		console.log(`[POST-RENDER-CACHE] ${newCollapsedCacheEntries} collapsed: ${samples.join(', ')}${newCollapsedCacheEntries > 5 ? '...' : ''}`);
		for (const [el, { w, h }] of saved) {
			el.style.width = w;
			el.style.height = h;
		}
	}

	return newCollapsedCacheEntries;
}
