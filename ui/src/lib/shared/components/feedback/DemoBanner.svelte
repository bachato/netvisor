<script lang="ts">
	import { Rocket } from 'lucide-svelte';
</script>

<div
	class="border-b border-blue-300 bg-blue-100 px-4 py-2 dark:border-blue-600/30 dark:bg-blue-900/20"
>
	<div class="mx-auto flex items-center justify-center gap-2 text-sm">
		<Rocket class="h-4 w-4 shrink-0 text-blue-700 dark:text-blue-300" />
		<span class="text-blue-700 dark:text-blue-300">
			You're exploring the demo. Ready to map your own network?
		</span>
		<a
			href="https://app.scanopy.net/onboarding"
			target="_blank"
			rel="noopener noreferrer"
			class="ml-2 rounded px-2 py-0.5 text-xs font-medium text-blue-700 underline hover:no-underline dark:text-blue-300"
		>
			Create Account
		</a>
	</div>
</div>
