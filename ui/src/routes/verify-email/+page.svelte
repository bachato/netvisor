<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { themeStore } from '$lib/shared/stores/theme.svelte';
	import { goto } from '$app/navigation';
	import {
		useVerifyEmailMutation,
		useResendVerificationMutation
	} from '$lib/features/auth/queries';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import { navigate } from '$lib/shared/utils/navigation';
	import { fetchOrganization } from '$lib/features/organizations/queries';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { Mail } from 'lucide-svelte';
	import { resolve } from '$app/paths';

	const verifyMutation = useVerifyEmailMutation();
	const resendMutation = useResendVerificationMutation();

	let isResending = $derived(resendMutation.isPending);

	type Status = 'verifying' | 'success' | 'error' | 'no-token' | 'pending';
	let status = $state<Status>('verifying');
	let errorMessage = $state('');
	let email = $state('');

	onMount(async () => {
		const token = $page.url.searchParams.get('token');
		const emailParam = $page.url.searchParams.get('email');

		if (emailParam) {
			email = emailParam;
		}

		if (!token) {
			// No token - show pending state for resend
			status = emailParam ? 'pending' : 'no-token';
			return;
		}

		try {
			await verifyMutation.mutateAsync({ token });
			status = 'success';
			// Fetch organization data before navigating
			await fetchOrganization();
			// Auto-navigate after delay
			setTimeout(() => navigate(), 2000);
		} catch (e) {
			status = 'error';
			errorMessage = e instanceof Error ? e.message : 'Verification failed';
		}
	});

	async function handleResend() {
		if (!email) return;
		try {
			await resendMutation.mutateAsync({ email });
		} catch {
			// Error handled by mutation
		}
	}

	function handleBackToLogin() {
		goto(resolve('/login'));
	}
</script>

<div class="relative flex min-h-screen flex-col items-center bg-[var(--color-bg-elevated)] p-4">
	<!-- Background image with overlay -->
	<div class="absolute inset-0 z-0">
		<div
			class="h-full w-full bg-cover bg-center bg-no-repeat blur-[2px]"
			style="background-image: url('/images/background-{themeStore.resolvedTheme}.webp')"
		></div>
		<div
			class="absolute inset-0 {themeStore.resolvedTheme === 'dark' ? 'bg-black/30' : 'bg-white/15'}"
		></div>
	</div>

	<!-- Spacer to push modal down -->
	<div class="flex flex-1 items-center justify-center">
		<!-- Modal Content -->
		<div class="relative z-10">
			<GenericModal
				isOpen={true}
				onClose={() => {}}
				showCloseButton={false}
				preventCloseOnClickOutside={true}
				title="Verify Your Email"
			>
				{#snippet headerIcon()}
					<ModalHeaderIcon Icon={Mail} color="Blue" />
				{/snippet}

				{#if status === 'verifying'}
					<div class="p-6 text-center">
						<h2 class="text-primary mb-2 text-xl font-semibold">Verifying your email...</h2>
						<p class="text-tertiary">Please wait while we verify your email address.</p>
					</div>
				{:else if status === 'success'}
					<div class="p-6 text-center">
						<h2 class="text-primary mb-2 text-xl font-semibold">Email Verified!</h2>
						<p class="text-tertiary">Your email has been verified. Redirecting you now...</p>
					</div>
				{:else if status === 'error'}
					<div class="p-6 text-center">
						<h2 class="text-primary mb-2 text-xl font-semibold">Verification Failed</h2>
						<p class="text-tertiary mb-4">{errorMessage}</p>
						{#if email}
							<button
								type="button"
								class="btn-primary w-full"
								onclick={handleResend}
								disabled={isResending}
							>
								{isResending ? 'Sending...' : 'Resend Verification Email'}
							</button>
						{:else}
							<p class="text-muted text-sm">
								Please try registering again or contact support if the problem persists.
							</p>
						{/if}
					</div>
				{:else if status === 'pending'}
					<div class="p-6 text-center">
						<h2 class="text-primary mb-2 text-xl font-semibold">Check Your Email</h2>
						<p class="text-tertiary mb-4">
							We sent a verification link to <span class="text-secondary font-medium">{email}</span
							>. Click the link to verify your account.
						</p>
						<div class="space-y-3">
							<p class="text-muted text-sm">Didn't receive the email?</p>
							<button
								type="button"
								class="btn-secondary w-full"
								onclick={handleResend}
								disabled={isResending}
							>
								{isResending ? 'Sending...' : 'Resend Verification Email'}
							</button>
						</div>
					</div>
				{:else}
					<div class="p-6 text-center">
						<h2 class="text-primary mb-2 text-xl font-semibold">No Verification Token</h2>
						<p class="text-tertiary mb-4">
							Please use the verification link sent to your email, or go back to login.
						</p>
						<button type="button" class="btn-secondary w-full" onclick={handleBackToLogin}>
							Back to Login
						</button>
					</div>
				{/if}
			</GenericModal>
		</div>
	</div>

	<Toast />
</div>
