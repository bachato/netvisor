<script lang="ts">
	import { onMount } from 'svelte';

	let { active = true }: { active?: boolean } = $props();

	let canvas: HTMLCanvasElement;
	let animationId: number;
	let mouseX = -1000;
	let mouseY = -1000;
	let appearProgress = 0;

	const COLORS = {
		cyan: '#06b6d4',
		blue: '#3b82f6',
		emerald: '#10b981',
		purple: '#8b5cf6',
		orange: '#f97316',
		pink: '#ec4899'
	};

	type ColorKey = keyof typeof COLORS;

	interface TopoNode {
		id: number;
		homeX: number;
		homeY: number;
		x: number;
		y: number;
		w: number;
		h: number;
		color: ColorKey;
		label: string;
		sublabel?: string;
		subnet: number;
		appearAt: number;
	}

	interface Edge {
		from: number;
		to: number;
		appearAt: number;
	}

	interface Subnet {
		x: number;
		y: number;
		w: number;
		h: number;
		label: string;
		color: ColorKey;
		appearAt: number;
	}

	const subnets: Subnet[] = [
		{ x: 18, y: 30, w: 200, h: 145, label: '10.0.1.0/24', color: 'cyan', appearAt: 0.05 },
		{ x: 240, y: 22, w: 195, h: 155, label: '10.0.2.0/24', color: 'purple', appearAt: 0.1 }
	];

	const NODE_W = 62;
	const NODE_H = 36;

	const nodes: TopoNode[] = [
		// Subnet 1
		{ id: 0, homeX: 42, homeY: 60, x: 42, y: 60, w: NODE_W, h: NODE_H, color: 'blue', label: 'gateway', sublabel: '.1', subnet: 0, appearAt: 0.15 },
		{ id: 1, homeX: 132, homeY: 56, x: 132, y: 56, w: NODE_W, h: NODE_H, color: 'emerald', label: 'web-srv', sublabel: '.10', subnet: 0, appearAt: 0.25 },
		{ id: 2, homeX: 42, homeY: 120, x: 42, y: 120, w: NODE_W, h: NODE_H, color: 'emerald', label: 'db-01', sublabel: '.20', subnet: 0, appearAt: 0.3 },
		{ id: 3, homeX: 132, homeY: 120, x: 132, y: 120, w: NODE_W, h: NODE_H, color: 'orange', label: 'nas', sublabel: '.30', subnet: 0, appearAt: 0.35 },
		// Subnet 2
		{ id: 4, homeX: 264, homeY: 52, x: 264, y: 52, w: NODE_W, h: NODE_H, color: 'blue', label: 'core-sw', sublabel: '.1', subnet: 1, appearAt: 0.2 },
		{ id: 5, homeX: 354, homeY: 52, x: 354, y: 52, w: NODE_W, h: NODE_H, color: 'pink', label: 'monitor', sublabel: '.5', subnet: 1, appearAt: 0.4 },
		{ id: 6, homeX: 264, homeY: 122, x: 264, y: 122, w: NODE_W, h: NODE_H, color: 'emerald', label: 'app-srv', sublabel: '.11', subnet: 1, appearAt: 0.35 },
		{ id: 7, homeX: 354, homeY: 122, x: 354, y: 122, w: NODE_W, h: NODE_H, color: 'orange', label: 'printer', sublabel: '.50', subnet: 1, appearAt: 0.45 }
	];

	// Cleaner topology: tree structure, no crossing lines
	const edges: Edge[] = [
		{ from: 0, to: 1, appearAt: 0.3 },
		{ from: 0, to: 2, appearAt: 0.35 },
		{ from: 1, to: 3, appearAt: 0.4 },
		{ from: 0, to: 4, appearAt: 0.45 }, // cross-subnet link
		{ from: 4, to: 5, appearAt: 0.5 },
		{ from: 4, to: 6, appearAt: 0.5 },
		{ from: 6, to: 7, appearAt: 0.55 }
	];

	function handleMouseMove(e: MouseEvent) {
		const rect = canvas.getBoundingClientRect();
		mouseX = e.clientX - rect.left;
		mouseY = e.clientY - rect.top;
	}

	function handleMouseLeave() {
		mouseX = -1000;
		mouseY = -1000;
		hoveredNode = null;
	}

	function easeOut(t: number): number {
		return 1 - (1 - t) * (1 - t);
	}

	function drawRoundedRect(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number) {
		ctx.beginPath();
		ctx.moveTo(x + r, y);
		ctx.lineTo(x + w - r, y);
		ctx.quadraticCurveTo(x + w, y, x + w, y + r);
		ctx.lineTo(x + w, y + h - r);
		ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
		ctx.lineTo(x + r, y + h);
		ctx.quadraticCurveTo(x, y + h, x, y + h - r);
		ctx.lineTo(x, y + r);
		ctx.quadraticCurveTo(x, y, x + r, y);
		ctx.closePath();
	}

	function render() {
		if (!canvas) return;
		const ctx = canvas.getContext('2d');
		if (!ctx) return;

		const dpr = window.devicePixelRatio || 1;
		const w = canvas.clientWidth;
		const h = canvas.clientHeight;
		canvas.width = w * dpr;
		canvas.height = h * dpr;
		ctx.scale(dpr, dpr);

		if (appearProgress < 1) {
			appearProgress = Math.min(1, appearProgress + 0.008);
		}

		// Smooth mouse displacement: nodes shift away from cursor proportionally
		const MOUSE_RADIUS = 100;
		const MOUSE_STRENGTH = 12;
		for (const node of nodes) {
			const na = Math.max(0, Math.min(1, (appearProgress - node.appearAt) / 0.2));
			if (na <= 0) {
				node.x = node.homeX;
				node.y = node.homeY;
				continue;
			}

			const cx = node.homeX + node.w / 2;
			const cy = node.homeY + node.h / 2;
			const dx = cx - mouseX;
			const dy = cy - mouseY;
			const dist = Math.sqrt(dx * dx + dy * dy);

			let offsetX = 0;
			let offsetY = 0;
			if (dist < MOUSE_RADIUS && dist > 0) {
				const t = 1 - dist / MOUSE_RADIUS; // 1 at center, 0 at edge
				const push = t * t * MOUSE_STRENGTH; // quadratic falloff
				offsetX = (dx / dist) * push;
				offsetY = (dy / dist) * push;
			}

			// Lerp current position toward target for smoothness
			const targetX = node.homeX + offsetX;
			const targetY = node.homeY + offsetY;
			node.x += (targetX - node.x) * 0.15;
			node.y += (targetY - node.y) * 0.15;
		}

		// Theme
		const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
		const bgColor = isDark ? '#15131e' : '#f8fafc';
		const nodeBg = isDark ? '#1a1d29' : '#ffffff';
		const borderColor = isDark ? '#374151' : '#e2e8f0';
		const textMuted = isDark ? 'rgba(255,255,255,0.45)' : 'rgba(0,0,0,0.35)';
		const dotColor = isDark ? 'rgba(255,255,255,0.04)' : 'rgba(0,0,0,0.05)';
		const edgeColor = isDark ? 'rgba(255,255,255,0.12)' : 'rgba(0,0,0,0.12)';

		// Background
		ctx.fillStyle = bgColor;
		ctx.fillRect(0, 0, w, h);

		// Dot grid
		ctx.fillStyle = dotColor;
		for (let gx = 10; gx < w; gx += 16) {
			for (let gy = 10; gy < h; gy += 16) {
				ctx.beginPath();
				ctx.arc(gx, gy, 0.7, 0, Math.PI * 2);
				ctx.fill();
			}
		}

		// Subnets
		for (const subnet of subnets) {
			const sa = easeOut(Math.max(0, Math.min(1, (appearProgress - subnet.appearAt) / 0.15)));
			if (sa <= 0) continue;

			ctx.save();
			ctx.globalAlpha = sa;
			drawRoundedRect(ctx, subnet.x, subnet.y, subnet.w, subnet.h, 10);
			ctx.fillStyle = nodeBg;
			ctx.fill();
			ctx.strokeStyle = borderColor;
			ctx.lineWidth = 1;
			ctx.stroke();

			ctx.font = '600 8.5px ui-monospace, monospace';
			ctx.fillStyle = COLORS[subnet.color];
			ctx.fillText(subnet.label, subnet.x + 10, subnet.y + 14);
			ctx.restore();
		}

		// Edges — straight lines from node edge to node edge
		for (const edge of edges) {
			const ea = easeOut(Math.max(0, Math.min(1, (appearProgress - edge.appearAt) / 0.2)));
			if (ea <= 0) continue;

			const from = nodes[edge.from];
			const to = nodes[edge.to];
			const fromA = Math.max(0, Math.min(1, (appearProgress - from.appearAt) / 0.2));
			const toA = Math.max(0, Math.min(1, (appearProgress - to.appearAt) / 0.2));
			if (fromA <= 0 || toA <= 0) continue;

			const fx = from.x + from.w / 2;
			const fy = from.y + from.h / 2;
			const tx = to.x + to.w / 2;
			const ty = to.y + to.h / 2;

			ctx.save();
			ctx.globalAlpha = ea;
			ctx.beginPath();
			ctx.moveTo(fx, fy);
			ctx.lineTo(fx + (tx - fx) * ea, fy + (ty - fy) * ea);
			ctx.strokeStyle = edgeColor;
			ctx.lineWidth = 1;
			ctx.stroke();
			ctx.restore();
		}

		// Nodes — rounded rect cards
		for (const node of nodes) {
			const na = easeOut(Math.max(0, Math.min(1, (appearProgress - node.appearAt) / 0.2)));
			if (na <= 0) continue;

			ctx.save();
			ctx.globalAlpha = na;

			// Scale from center for appear animation
			const cx = node.x + node.w / 2;
			const cy = node.y + node.h / 2;
			const sw = node.w * na;
			const sh = node.h * na;
			const sx = cx - sw / 2;
			const sy = cy - sh / 2;

			// Card background
			drawRoundedRect(ctx, sx, sy, sw, sh, 7);
			ctx.fillStyle = nodeBg;
			ctx.fill();
			ctx.strokeStyle = borderColor;
			ctx.lineWidth = 1;
			ctx.stroke();

			if (na > 0.7) {
				// Color accent bar at top
				ctx.save();
				ctx.beginPath();
				drawRoundedRect(ctx, sx, sy, sw, 3, 0);
				ctx.clip();
				drawRoundedRect(ctx, sx, sy, sw, 5, 5);
				ctx.fillStyle = COLORS[node.color];
				ctx.fill();
				ctx.restore();

				// Label
				ctx.font = '600 8px ui-sans-serif, system-ui, sans-serif';
				ctx.fillStyle = textMuted;
				ctx.textAlign = 'center';
				ctx.fillText(node.label, cx, cy + 1);

				// Sublabel (IP suffix)
				if (node.sublabel) {
					ctx.font = '400 7px ui-monospace, monospace';
					ctx.fillStyle = isDark ? 'rgba(255,255,255,0.25)' : 'rgba(0,0,0,0.2)';
					ctx.fillText(node.sublabel, cx, cy + 11);
				}
			}

			ctx.restore();
		}

		// Bottom gradient fade — signals this is decorative, not a real UI
		const fadeH = h * 0.4;
		const grad = ctx.createLinearGradient(0, h - fadeH, 0, h);
		grad.addColorStop(0, 'rgba(0,0,0,0)');
		grad.addColorStop(1, bgColor);
		ctx.fillStyle = grad;
		ctx.fillRect(0, h - fadeH, w, fadeH);

		if (active) {
			animationId = requestAnimationFrame(render);
		}
	}

	onMount(() => {
		if (active) {
			animationId = requestAnimationFrame(render);
		}
		return () => {
			if (animationId) cancelAnimationFrame(animationId);
		};
	});
</script>

<canvas
	bind:this={canvas}
	class="h-48 w-full cursor-default rounded-lg opacity-90"
	style="background: var(--color-topology-bg)"
	onmousemove={handleMouseMove}
	onmouseleave={handleMouseLeave}
></canvas>
