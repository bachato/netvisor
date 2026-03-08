<script lang="ts">
	import { AlertTriangle } from 'lucide-svelte';
	import { useResendVerificationMutation } from '$lib/features/auth/queries';
	import { pushSuccess } from '$lib/shared/stores/feedback';

	let { email }: { email: string } = $props();

	let dismissed = $state(false);

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

{#if !dismissed}
	<div
		class="sticky top-0 z-50 border-b border-yellow-300 bg-yellow-100 px-4 py-2 dark:border-yellow-600/30 dark:bg-yellow-900/20"
	>
		<div class="mx-auto flex items-center justify-center gap-2 text-sm">
			<AlertTriangle class="h-4 w-4 shrink-0 text-warning" />
			<span class="text-warning">
				Please verify your email. Check your inbox for a verification link.
			</span>
			<button
				onclick={handleResend}
				disabled={resendMutation.isPending}
				class="ml-2 rounded px-2 py-0.5 text-xs font-medium text-warning underline hover:no-underline disabled:opacity-50"
			>
				{resendMutation.isPending ? 'Sending...' : 'Resend'}
			</button>
			<button
				onclick={() => (dismissed = true)}
				class="ml-2 shrink-0 rounded p-0.5 text-warning transition-colors hover:bg-white/10"
				aria-label="Dismiss"
			>
				&times;
			</button>
		</div>
	</div>
{/if}
