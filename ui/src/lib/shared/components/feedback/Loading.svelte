<script lang="ts">
	import { common_loading } from '$lib/paraglide/messages';

	export let message: string | undefined = undefined;

	$: displayMessage = message ?? common_loading();
</script>

<div class="py-8 text-center">
	<div class="mx-auto h-8 w-8 animate-spin rounded-full border-b-2 border-blue-500"></div>
	<p class="text-secondary mt-2">{displayMessage}</p>
</div>
