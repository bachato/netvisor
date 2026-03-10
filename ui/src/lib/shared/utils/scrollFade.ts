/**
 * Svelte action: adds top/bottom fade via mask-image when content overflows.
 * Usage: <div use:scrollFade class="max-h-32 overflow-y-auto">
 */
export function scrollFade(node: HTMLElement) {
	const FADE = '1.5rem';

	function update() {
		const { scrollTop, scrollHeight, clientHeight } = node;
		const isScrollable = scrollHeight - clientHeight > 1;

		if (!isScrollable) {
			node.style.maskImage = '';
			node.style.webkitMaskImage = '';
			return;
		}

		const atTop = scrollTop <= 1;
		const atBottom = scrollTop + clientHeight >= scrollHeight - 1;

		let mask: string;
		if (atTop) {
			mask = `linear-gradient(to bottom, black calc(100% - ${FADE}), transparent)`;
		} else if (atBottom) {
			mask = `linear-gradient(to bottom, transparent, black ${FADE})`;
		} else {
			mask = `linear-gradient(to bottom, transparent, black ${FADE}, black calc(100% - ${FADE}), transparent)`;
		}

		node.style.maskImage = mask;
		node.style.webkitMaskImage = mask;
	}

	requestAnimationFrame(update);
	node.addEventListener('scroll', update, { passive: true });
	const ro = new ResizeObserver(update);
	ro.observe(node);

	return {
		destroy() {
			node.removeEventListener('scroll', update);
			ro.disconnect();
			node.style.maskImage = '';
			node.style.webkitMaskImage = '';
		}
	};
}
