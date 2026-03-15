<script lang="ts">
	import { onMount } from 'svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { COLOR_MAP, type Color } from '$lib/shared/utils/styling';

	let { active = true }: { active?: boolean } = $props();

	let canvas: HTMLCanvasElement;
	let animationId: number;
	let mouseX = -1000;
	let mouseY = -1000;

	let scanX = -30;
	const SCAN_SPEED = 2.2;
	const PAUSE_FRAMES = 240;
	let pauseCounter = 0;

	// Resolve the Discovery entity color for the scan line
	function getScanRgb(): string {
		return entities.getColorHelper('Discovery').rgb;
	}

	// Extract r,g,b integers from an "rgb(r, g, b)" string
	function parseRgb(rgb: string): [number, number, number] {
		const m = rgb.match(/(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/);
		return m ? [+m[1], +m[2], +m[3]] : [107, 114, 128];
	}

	function colorRgb(color: Color): string {
		return COLOR_MAP[color].rgb;
	}

	const LAYOUT_W = 455;

	interface TopoNode {
		id: number;
		homeX: number;
		homeY: number;
		x: number;
		y: number;
		w: number;
		h: number;
		color: Color;
		label: string;
		sublabel?: string;
		subnet: number;
		revealedAt: number;
	}

	interface Edge {
		from: number;
		to: number;
	}

	interface Subnet {
		x: number;
		y: number;
		w: number;
		h: number;
		label: string;
		color: Color;
		revealedAt: number;
	}

	const subnets: Subnet[] = [
		{ x: 18, y: 30, w: 200, h: 145, label: '10.0.1.0/24', color: 'Cyan', revealedAt: 0 },
		{ x: 240, y: 22, w: 195, h: 155, label: '10.0.2.0/24', color: 'Purple', revealedAt: 0 }
	];

	const NODE_W = 62;
	const NODE_H = 36;

	const nodes: TopoNode[] = [
		{
			id: 0,
			homeX: 42,
			homeY: 60,
			x: 42,
			y: 60,
			w: NODE_W,
			h: NODE_H,
			color: 'Blue',
			label: 'gateway',
			sublabel: '.1',
			subnet: 0,
			revealedAt: 0
		},
		{
			id: 1,
			homeX: 132,
			homeY: 56,
			x: 132,
			y: 56,
			w: NODE_W,
			h: NODE_H,
			color: 'Emerald',
			label: 'web-srv',
			sublabel: '.10',
			subnet: 0,
			revealedAt: 0
		},
		{
			id: 2,
			homeX: 42,
			homeY: 120,
			x: 42,
			y: 120,
			w: NODE_W,
			h: NODE_H,
			color: 'Emerald',
			label: 'db-01',
			sublabel: '.20',
			subnet: 0,
			revealedAt: 0
		},
		{
			id: 3,
			homeX: 132,
			homeY: 120,
			x: 132,
			y: 120,
			w: NODE_W,
			h: NODE_H,
			color: 'Orange',
			label: 'nas',
			sublabel: '.30',
			subnet: 0,
			revealedAt: 0
		},
		{
			id: 4,
			homeX: 264,
			homeY: 52,
			x: 264,
			y: 52,
			w: NODE_W,
			h: NODE_H,
			color: 'Blue',
			label: 'core-sw',
			sublabel: '.1',
			subnet: 1,
			revealedAt: 0
		},
		{
			id: 5,
			homeX: 354,
			homeY: 52,
			x: 354,
			y: 52,
			w: NODE_W,
			h: NODE_H,
			color: 'Pink',
			label: 'monitor',
			sublabel: '.5',
			subnet: 1,
			revealedAt: 0
		},
		{
			id: 6,
			homeX: 264,
			homeY: 122,
			x: 264,
			y: 122,
			w: NODE_W,
			h: NODE_H,
			color: 'Emerald',
			label: 'app-srv',
			sublabel: '.11',
			subnet: 1,
			revealedAt: 0
		},
		{
			id: 7,
			homeX: 354,
			homeY: 122,
			x: 354,
			y: 122,
			w: NODE_W,
			h: NODE_H,
			color: 'Orange',
			label: 'printer',
			sublabel: '.50',
			subnet: 1,
			revealedAt: 0
		}
	];

	const edges: Edge[] = [
		{ from: 0, to: 1 },
		{ from: 0, to: 2 },
		{ from: 1, to: 3 },
		{ from: 0, to: 4 },
		{ from: 4, to: 5 },
		{ from: 4, to: 6 },
		{ from: 6, to: 7 }
	];

	function handleMouseMove(e: MouseEvent) {
		const rect = canvas.getBoundingClientRect();
		mouseX = e.clientX - rect.left;
		mouseY = e.clientY - rect.top;
	}

	function handleMouseLeave() {
		mouseX = -1000;
		mouseY = -1000;
	}

	function easeOut(t: number): number {
		return 1 - (1 - t) * (1 - t);
	}

	function drawRoundedRect(
		ctx: CanvasRenderingContext2D,
		x: number,
		y: number,
		w: number,
		h: number,
		r: number
	) {
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

		// Advance scan line, loop after pause
		if (scanX > LAYOUT_W + 40) {
			pauseCounter++;
			if (pauseCounter >= PAUSE_FRAMES) {
				scanX = -30;
				pauseCounter = 0;
				for (const s of subnets) s.revealedAt = 0;
				for (const n of nodes) {
					n.revealedAt = 0;
					n.x = n.homeX;
					n.y = n.homeY;
				}
			}
		} else {
			scanX += SCAN_SPEED;
		}

		// Update reveal state
		for (const subnet of subnets) {
			if (scanX >= subnet.x && subnet.revealedAt < 1) {
				subnet.revealedAt = Math.min(1, subnet.revealedAt + 0.06);
			}
		}
		for (const node of nodes) {
			const nodeCx = node.homeX + node.w / 2;
			if (scanX >= nodeCx && node.revealedAt < 1) {
				node.revealedAt = Math.min(1, node.revealedAt + 0.08);
			}
		}

		// Mouse displacement
		const MOUSE_RADIUS = 100;
		const MOUSE_STRENGTH = 12;
		for (const node of nodes) {
			if (node.revealedAt <= 0) {
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
				const t = 1 - dist / MOUSE_RADIUS;
				const push = t * t * MOUSE_STRENGTH;
				offsetX = (dx / dist) * push;
				offsetY = (dy / dist) * push;
			}

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

		// Scan line color from Discovery entity
		const scanRgb = getScanRgb();
		const [sr, sg, sb] = parseRgb(scanRgb);
		const scanBeamColor = isDark ? `rgba(${sr},${sg},${sb},0.15)` : `rgba(${sr},${sg},${sb},0.1)`;
		const scanLineColor = isDark ? `rgba(${sr},${sg},${sb},0.5)` : `rgba(${sr},${sg},${sb},0.35)`;

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
			const ra = easeOut(subnet.revealedAt);
			if (ra <= 0) continue;

			ctx.save();
			ctx.globalAlpha = ra;
			drawRoundedRect(ctx, subnet.x, subnet.y, subnet.w, subnet.h, 10);
			ctx.fillStyle = nodeBg;
			ctx.fill();
			ctx.strokeStyle = borderColor;
			ctx.lineWidth = 1;
			ctx.stroke();

			ctx.font = '600 8.5px ui-monospace, monospace';
			ctx.fillStyle = colorRgb(subnet.color);
			ctx.fillText(subnet.label, subnet.x + 10, subnet.y + 14);
			ctx.restore();
		}

		// Edges
		for (const edge of edges) {
			const from = nodes[edge.from];
			const to = nodes[edge.to];
			const ea = Math.min(from.revealedAt, to.revealedAt);
			if (ea <= 0) continue;

			const fx = from.x + from.w / 2;
			const fy = from.y + from.h / 2;
			const tx = to.x + to.w / 2;
			const ty = to.y + to.h / 2;

			ctx.save();
			ctx.globalAlpha = easeOut(ea);
			ctx.beginPath();
			ctx.moveTo(fx, fy);
			ctx.lineTo(fx + (tx - fx) * ea, fy + (ty - fy) * ea);
			ctx.strokeStyle = edgeColor;
			ctx.lineWidth = 1;
			ctx.stroke();
			ctx.restore();
		}

		// Nodes
		for (const node of nodes) {
			const ra = easeOut(node.revealedAt);
			if (ra <= 0) continue;

			ctx.save();
			ctx.globalAlpha = ra;

			const cx = node.x + node.w / 2;
			const cy = node.y + node.h / 2;
			const sw = node.w * ra;
			const sh = node.h * ra;
			const sx = cx - sw / 2;
			const sy = cy - sh / 2;

			drawRoundedRect(ctx, sx, sy, sw, sh, 7);
			ctx.fillStyle = nodeBg;
			ctx.fill();
			ctx.strokeStyle = borderColor;
			ctx.lineWidth = 1;
			ctx.stroke();

			if (ra > 0.7) {
				// Color accent bar
				ctx.save();
				ctx.beginPath();
				drawRoundedRect(ctx, sx, sy, sw, 3, 0);
				ctx.clip();
				drawRoundedRect(ctx, sx, sy, sw, 5, 5);
				ctx.fillStyle = colorRgb(node.color);
				ctx.fill();
				ctx.restore();

				// Label
				ctx.font = '600 8px ui-sans-serif, system-ui, sans-serif';
				ctx.fillStyle = textMuted;
				ctx.textAlign = 'center';
				ctx.fillText(node.label, cx, cy + 1);

				if (node.sublabel) {
					ctx.font = '400 7px ui-monospace, monospace';
					ctx.fillStyle = isDark ? 'rgba(255,255,255,0.25)' : 'rgba(0,0,0,0.2)';
					ctx.fillText(node.sublabel, cx, cy + 11);
				}
			}

			ctx.restore();
		}

		// Scan beam + line — drawn on top of everything
		if (scanX >= -30 && scanX <= LAYOUT_W + 40) {
			const beamWidth = 50;
			const beamGrad = ctx.createLinearGradient(scanX - beamWidth, 0, scanX, 0);
			beamGrad.addColorStop(0, `rgba(${sr},${sg},${sb},0)`);
			beamGrad.addColorStop(1, scanBeamColor);
			ctx.fillStyle = beamGrad;
			ctx.fillRect(scanX - beamWidth, 0, beamWidth, h);

			ctx.beginPath();
			ctx.moveTo(scanX, 0);
			ctx.lineTo(scanX, h);
			ctx.strokeStyle = scanLineColor;
			ctx.lineWidth = 1.5;
			ctx.stroke();
		}

		// Bottom gradient fade
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
