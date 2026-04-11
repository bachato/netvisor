<script lang="ts">
	import { ShieldAlert } from 'lucide-svelte';
	import { license_expiredBanner, license_invalidBanner } from '$lib/paraglide/messages';
	import AppBanner from './AppBanner.svelte';

	let { status }: { status: 'expired' | 'invalid' } = $props();
</script>

<AppBanner variant="danger" icon={ShieldAlert}>
	{status === 'expired' ? license_expiredBanner() : license_invalidBanner()}
</AppBanner>
