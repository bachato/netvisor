<script lang="ts">
	import EmptyState from './EmptyState.svelte';
	import { Server } from 'lucide-svelte';
	import { openModal } from '$lib/shared/stores/modal-registry';
	import type { IconComponent } from '$lib/shared/utils/types';

	let { entityName }: { entityName: string } = $props();

	function handleClick() {
		window.location.hash = 'daemons';
		openModal('create-daemon');
	}
</script>

<EmptyState
	IconComponent={Server as IconComponent}
	title="Install a daemon to start discovering {entityName.toLowerCase()} on your network."
	onClick={handleClick}
	cta="Install a Daemon"
/>
