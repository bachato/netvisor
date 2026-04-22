<script lang="ts">
	import { Clock } from 'lucide-svelte';
	import { license_expiringBanner } from '$lib/paraglide/messages';
	import AppBanner from './AppBanner.svelte';

	let { intendedExpiry }: { intendedExpiry: string } = $props();
</script>

<AppBanner variant="info" icon={Clock} body={license_expiringBanner({ intendedExpiry })} />
