<script lang="ts">
	import { Rocket } from 'lucide-svelte';
	import AppBanner from './AppBanner.svelte';
</script>

<AppBanner
	variant="info"
	icon={Rocket}
	body="You're exploring the demo. Ready to map your own network?"
>
	{#snippet actions()}
		<a
			href="https://app.scanopy.net/onboarding"
			target="_blank"
			rel="noopener noreferrer"
			class="ml-2 rounded px-2 py-0.5 text-xs font-medium underline hover:no-underline"
		>
			Create Account
		</a>
	{/snippet}
</AppBanner>
