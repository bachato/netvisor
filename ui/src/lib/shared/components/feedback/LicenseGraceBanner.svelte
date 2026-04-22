<script lang="ts">
	import { ShieldAlert } from 'lucide-svelte';
	import { license_graceBanner } from '$lib/paraglide/messages';
	import AppBanner from './AppBanner.svelte';

	let { intendedExpiry, hardExpiry }: { intendedExpiry: string; hardExpiry: string } = $props();
</script>

<AppBanner variant="warning" icon={ShieldAlert}>
	{license_graceBanner({ intendedExpiry, hardExpiry })}
</AppBanner>
