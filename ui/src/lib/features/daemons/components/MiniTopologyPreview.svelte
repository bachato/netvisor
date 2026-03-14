<script lang="ts">
	import { onMount } from 'svelte';

	let { active = true }: { active?: boolean } = $props();

	let canvas: HTMLCanvasElement;
	let animationId: number;
	let mouseX = -1000;
	let mouseY = -1000;
	let time = 0;
	let appearProgress = 0;

	// Node colors matching the app's entity color palette
	const COLORS = {
		cyan: { fill: '#06b6d4', glow: 'rgba(6, 182, 212, 0.3)' },
		blue: { fill: '#3b82f6', glow: 'rgba(59, 130, 246, 0.3)' },
		emerald: { fill: '#10b981', glow: 'rgba(16, 185, 129, 0.3)' },
		purple: { fill: '#8b5cf6', glow: 'rgba(139, 92, 246, 0.3)' },
		orange: { fill: '#f97316', glow: 'rgba(249, 115, 22, 0.3)' },
		pink: { fill: '#ec4899', glow: 'rgba(236, 72, 153, 0.3)' }
	};

	type ColorKey = keyof typeof COLORS;

	interface TopoNode {
		id: number;
		homeX: number;
		homeY: number;
		x: number;
		y: number;
		vx: number;
		vy: number;
		radius: number;
		color: ColorKey;
		label: string;
		subnet: number; // which subnet group (-1 = standalone)
		appearAt: number; // 0-1 progress when this node appears
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

	// Layout: 2 subnets with hosts inside, plus a router connecting them
	const subnets: Subnet[] = [
		{ x: 20, y: 42, w: 180, h: 130, label: '10.0.1.0/24', color: 'cyan', appearAt: 0.05 },
		{ x: 250, y: 28, w: 175, h: 150, label: '10.0.2.0/24', color: 'purple', appearAt: 0.1 }
	];

	const nodes: TopoNode[] = [
		// Subnet 1 hosts
		{
			id: 0,
			homeX: 55,
			homeY: 75,
			x: 55,
			y: 75,
			vx: 0,
			vy: 0,
			radius: 8,
			color: 'blue',
			label: 'gateway',
			subnet: 0,
			appearAt: 0.15
		},
		{
			id: 1,
			homeX: 140,
			homeY: 70,
			x: 140,
			y: 70,
			vx: 0,
			vy: 0,
			radius: 7,
			color: 'emerald',
			label: 'web-srv',
			subnet: 0,
			appearAt: 0.25
		},
		{
			id: 2,
			homeX: 70,
			homeY: 135,
			x: 70,
			y: 135,
			vx: 0,
			vy: 0,
			radius: 6,
			color: 'emerald',
			label: 'db-01',
			subnet: 0,
			appearAt: 0.3
		},
		{
			id: 3,
			homeX: 155,
			homeY: 138,
			x: 155,
			y: 138,
			vx: 0,
			vy: 0,
			radius: 6,
			color: 'orange',
			label: 'nas',
			subnet: 0,
			appearAt: 0.35
		},
		// Subnet 2 hosts
		{
			id: 4,
			homeX: 290,
			homeY: 65,
			x: 290,
			y: 65,
			vx: 0,
			vy: 0,
			radius: 8,
			color: 'blue',
			label: 'core-sw',
			subnet: 1,
			appearAt: 0.2
		},
		{
			id: 5,
			homeX: 375,
			homeY: 72,
			x: 375,
			y: 72,
			vx: 0,
			vy: 0,
			radius: 6,
			color: 'pink',
			label: 'monitor',
			subnet: 1,
			appearAt: 0.4
		},
		{
			id: 6,
			homeX: 295,
			homeY: 138,
			x: 295,
			y: 138,
			vx: 0,
			vy: 0,
			radius: 7,
			color: 'emerald',
			label: 'app-srv',
			subnet: 1,
			appearAt: 0.35
		},
		{
			id: 7,
			homeX: 385,
			homeY: 142,
			x: 385,
			y: 142,
			vx: 0,
			vy: 0,
			radius: 5,
			color: 'orange',
			label: 'printer',
			subnet: 1,
			appearAt: 0.45
		}
	];

	const edges: Edge[] = [
		// Subnet 1 internal
		{ from: 0, to: 1, appearAt: 0.3 },
		{ from: 0, to: 2, appearAt: 0.35 },
		{ from: 1, to: 3, appearAt: 0.4 },
		// Cross-subnet
		{ from: 0, to: 4, appearAt: 0.45 },
		// Subnet 2 internal
		{ from: 4, to: 5, appearAt: 0.45 },
		{ from: 4, to: 6, appearAt: 0.5 },
		{ from: 6, to: 7, appearAt: 0.55 }
	];

	let hoveredNode: number | null = null;

	function getConnectedNodes(nodeId: number): Set<number> {
		const connected = new Set<number>();
		connected.add(nodeId);
		for (const e of edges) {
			if (e.from === nodeId) connected.add(e.to);
			if (e.to === nodeId) connected.add(e.from);
		}
		return connected;
	}

	function getScale(): number {
		if (!canvas) return 1;
		return canvas.width / canvas.clientWidth;
	}

	function handleMouseMove(e: MouseEvent) {
		const rect = canvas.getBoundingClientRect();
		const s = getScale();
		mouseX = (e.clientX - rect.left) * s;
		mouseY = (e.clientY - rect.top) * s;

		// Hit test for hover
		hoveredNode = null;
		for (const node of nodes) {
			const dx = node.x - mouseX;
			const dy = node.y - mouseY;
			if (dx * dx + dy * dy < (node.radius + 6) * (node.radius + 6)) {
				hoveredNode = node.id;
				break;
			}
		}
	}

	function handleMouseLeave() {
		mouseX = -1000;
		mouseY = -1000;
		hoveredNode = null;
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

		// Update appear progress
		if (appearProgress < 1) {
			appearProgress = Math.min(1, appearProgress + 0.008);
		}
		time += 0.016;

		// Physics: nodes drift toward home, react to mouse
		for (const node of nodes) {
			const nodeAppear = Math.max(0, Math.min(1, (appearProgress - node.appearAt) / 0.2));
			if (nodeAppear <= 0) continue;

			// Spring back to home position
			const dx = node.homeX - node.x;
			const dy = node.homeY - node.y;
			node.vx += dx * 0.03;
			node.vy += dy * 0.03;

			// Mouse repulsion
			const mx = node.x - mouseX;
			const my = node.y - mouseY;
			const md = Math.sqrt(mx * mx + my * my);
			if (md < 80 && md > 0) {
				const force = (80 - md) / 80;
				node.vx += (mx / md) * force * 1.5;
				node.vy += (my / md) * force * 1.5;
			}

			// Gentle ambient float
			node.vx += Math.sin(time * 0.8 + node.id * 1.7) * 0.02;
			node.vy += Math.cos(time * 0.6 + node.id * 2.3) * 0.02;

			// Damping
			node.vx *= 0.85;
			node.vy *= 0.85;

			node.x += node.vx;
			node.y += node.vy;
		}

		// Clear with topology background
		const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
		const bgColor = isDark ? '#15131e' : '#f8fafc';
		const nodeBg = isDark ? '#1a1d29' : '#ffffff';
		const borderColor = isDark ? '#374151' : '#e2e8f0';
		const textColor = isDark ? 'rgba(255,255,255,0.5)' : 'rgba(0,0,0,0.4)';
		const textBright = isDark ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.7)';
		const dotColor = isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.06)';

		ctx.fillStyle = bgColor;
		ctx.fillRect(0, 0, w, h);

		// Dot grid background (like real topology)
		for (let gx = 12; gx < w; gx += 18) {
			for (let gy = 12; gy < h; gy += 18) {
				ctx.fillStyle = dotColor;
				ctx.beginPath();
				ctx.arc(gx, gy, 0.8, 0, Math.PI * 2);
				ctx.fill();
			}
		}

		const connectedSet = hoveredNode !== null ? getConnectedNodes(hoveredNode) : null;

		// Draw subnets
		for (const subnet of subnets) {
			const sa = Math.max(0, Math.min(1, (appearProgress - subnet.appearAt) / 0.15));
			if (sa <= 0) continue;
			const alpha = easeOut(sa);

			ctx.save();
			ctx.globalAlpha = alpha;

			// Subnet container
			drawRoundedRect(ctx, subnet.x, subnet.y, subnet.w, subnet.h, 12);
			ctx.fillStyle = nodeBg;
			ctx.fill();
			ctx.strokeStyle = borderColor;
			ctx.lineWidth = 1;
			ctx.stroke();

			// Subnet label
			ctx.font = '500 9px ui-monospace, monospace';
			ctx.fillStyle = COLORS[subnet.color].fill;
			ctx.fillText(subnet.label, subnet.x + 10, subnet.y + 15);

			ctx.restore();
		}

		// Draw edges
		for (const edge of edges) {
			const ea = Math.max(0, Math.min(1, (appearProgress - edge.appearAt) / 0.15));
			if (ea <= 0) continue;

			const from = nodes[edge.from];
			const to = nodes[edge.to];

			const fromAppear = Math.max(0, Math.min(1, (appearProgress - from.appearAt) / 0.2));
			const toAppear = Math.max(0, Math.min(1, (appearProgress - to.appearAt) / 0.2));
			if (fromAppear <= 0 || toAppear <= 0) continue;

			// Fade if not connected to hovered node
			let edgeAlpha = easeOut(ea);
			if (connectedSet && (!connectedSet.has(edge.from) || !connectedSet.has(edge.to))) {
				edgeAlpha *= 0.15;
			}

			// Draw edge as smooth curve
			const midX = (from.x + to.x) / 2;
			const midY = (from.y + to.y) / 2 - 10;

			// Draw progress (for appearance animation)
			ctx.save();
			ctx.globalAlpha = edgeAlpha;
			ctx.beginPath();
			ctx.moveTo(from.x, from.y);
			ctx.quadraticCurveTo(midX, midY, from.x + (to.x - from.x) * ea, from.y + (to.y - from.y) * ea);
			ctx.strokeStyle = COLORS[from.color].fill;
			ctx.lineWidth = 1.5;
			ctx.stroke();
			ctx.restore();
		}

		// Draw nodes
		for (const node of nodes) {
			const na = Math.max(0, Math.min(1, (appearProgress - node.appearAt) / 0.2));
			if (na <= 0) continue;

			const scale = easeOut(na);
			const isHovered = hoveredNode === node.id;
			const isConnected = connectedSet?.has(node.id) ?? true;
			const nodeAlpha = isConnected ? 1 : 0.2;

			ctx.save();
			ctx.globalAlpha = nodeAlpha * scale;

			const r = node.radius * scale;

			// Glow effect for hovered node
			if (isHovered) {
				ctx.shadowColor = COLORS[node.color].glow;
				ctx.shadowBlur = 16;
			}

			// Node body (filled circle with border, like topology cards)
			ctx.beginPath();
			ctx.arc(node.x, node.y, r, 0, Math.PI * 2);
			ctx.fillStyle = nodeBg;
			ctx.fill();
			ctx.strokeStyle = isHovered ? COLORS[node.color].fill : borderColor;
			ctx.lineWidth = isHovered ? 2 : 1;
			ctx.stroke();

			// Inner colored dot
			ctx.shadowBlur = 0;
			ctx.beginPath();
			ctx.arc(node.x, node.y, r * 0.5, 0, Math.PI * 2);
			ctx.fillStyle = COLORS[node.color].fill;
			ctx.fill();

			// Label
			if (scale > 0.8) {
				ctx.font = '500 8px ui-sans-serif, system-ui, sans-serif';
				ctx.fillStyle = isHovered ? textBright : textColor;
				ctx.textAlign = 'center';
				ctx.fillText(node.label, node.x, node.y + r + 11);
			}

			ctx.restore();
		}

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
	class="h-44 w-full cursor-default rounded-lg"
	style="background: var(--color-topology-bg)"
	onmousemove={handleMouseMove}
	onmouseleave={handleMouseLeave}
></canvas>
