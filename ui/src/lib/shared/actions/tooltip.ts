/**
 * Svelte action that shows a fixed-position tooltip on hover.
 * Reads tooltip text from the element's data-tooltip attribute.
 * Uses position:fixed and appends to document.body to escape overflow containers.
 */
export function tooltip(node: HTMLElement) {
	let tip: HTMLDivElement | null = null;

	function show() {
		const text = node.getAttribute('data-tooltip');
		if (!text) return;

		tip = document.createElement('div');
		tip.textContent = text;
		Object.assign(tip.style, {
			position: 'fixed',
			zIndex: '9999',
			maxWidth: '250px',
			padding: '6px 10px',
			borderRadius: '6px',
			fontSize: '12px',
			lineHeight: '1.25',
			color: 'rgb(229 231 235)',
			background: 'rgb(17 24 39)',
			border: '1px solid rgb(55 65 81)',
			boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.3)',
			pointerEvents: 'none',
			whiteSpace: 'normal',
			wordWrap: 'break-word',
			transform: 'translateX(-50%) translateY(-100%)'
		});
		document.body.appendChild(tip);

		const rect = node.getBoundingClientRect();
		tip.style.left = `${rect.left + rect.width / 2}px`;
		tip.style.top = `${rect.top - 6}px`;
	}

	function hide() {
		tip?.remove();
		tip = null;
	}

	node.addEventListener('mouseenter', show);
	node.addEventListener('mouseleave', hide);

	return {
		destroy() {
			node.removeEventListener('mouseenter', show);
			node.removeEventListener('mouseleave', hide);
			tip?.remove();
		}
	};
}
