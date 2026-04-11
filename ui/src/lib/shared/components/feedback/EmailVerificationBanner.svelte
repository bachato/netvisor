<script lang="ts">
	import { AlertTriangle } from 'lucide-svelte';
	import { useResendVerificationMutation } from '$lib/features/auth/queries';
	import { pushSuccess } from '$lib/shared/stores/feedback';
	import AppBanner from './AppBanner.svelte';

	let { email }: { email: string } = $props();

	const resendMutation = useResendVerificationMutation();

	async function handleResend() {
		try {
			await resendMutation.mutateAsync({ email });
			pushSuccess('Verification email sent. Check your inbox.');
		} catch {
			// Error handled by mutation
		}
	}
</script>

<AppBanner variant="warning" icon={AlertTriangle}>
	Please verify your email. Check your inbox for a verification link.
	{#snippet actions()}
		<button
			onclick={handleResend}
			disabled={resendMutation.isPending}
			class="ml-2 rounded px-2 py-0.5 text-xs font-medium underline hover:no-underline disabled:opacity-50"
		>
			{resendMutation.isPending ? 'Sending...' : 'Resend'}
		</button>
	{/snippet}
</AppBanner>
