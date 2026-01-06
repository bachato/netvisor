<script lang="ts">
	import { tweened } from 'svelte/motion';
	import { cubicOut } from 'svelte/easing';

	let { progress }: { progress: number } = $props();

	const animatedProgress = tweened(progress, {
		duration: 500,
		easing: cubicOut
	});

	$effect(() => {
		animatedProgress.set(progress);
	});
</script>

<div
	class="progress-bar relative h-full overflow-hidden rounded-full bg-blue-500"
	style="width: {$animatedProgress}%"
>
	<div class="progress-shimmer absolute inset-0"></div>
</div>

<style>
	.progress-shimmer {
		background: linear-gradient(
			90deg,
			transparent 0%,
			rgba(255, 255, 255, 0.15) 50%,
			transparent 100%
		);
		animation: shimmer 1.5s infinite;
	}

	@keyframes shimmer {
		0% {
			transform: translateX(-100%);
		}
		100% {
			transform: translateX(100%);
		}
	}
</style>
