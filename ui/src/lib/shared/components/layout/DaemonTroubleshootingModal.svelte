<script lang="ts">
	import GenericModal from './GenericModal.svelte';
	import SupportOptions from '$lib/features/support/SupportOptions.svelte';

	let {
		isOpen = false,
		onClose
	}: {
		isOpen?: boolean;
		onClose: () => void;
	} = $props();
</script>

<GenericModal title="Daemon Troubleshooting" {isOpen} {onClose} size="sm">
	<div class="p-6">
		<SupportOptions isTroubleshooting={true} hasEmailSupport={false} />
	</div>
</GenericModal>
