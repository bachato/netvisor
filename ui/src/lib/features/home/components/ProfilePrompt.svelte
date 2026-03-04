<script lang="ts">
	import type { components } from '$lib/api/schema';
	import type { PublicServerConfig } from '$lib/shared/stores/config-query';
	import { useProfileUpdateMutation } from '$lib/features/auth/queries';

	type Organization = components['schemas']['Organization'];
	type OnboardingOperation = components['schemas']['OnboardingOperation'];

	let {
		organization,
		configData = null
	}: {
		organization: Organization;
		configData?: PublicServerConfig | null;
	} = $props();

	const onboarding = $derived(organization.onboarding ?? []);
	const has = (op: OnboardingOperation) => onboarding.includes(op);

	const isCloud = $derived(configData?.deployment_type === 'cloud');

	const visible = $derived(has('FirstDiscoveryCompleted') && !has('ProfileCompleted') && isCloud);

	const profileMutation = useProfileUpdateMutation();

	const roleOptions = [
		{ value: '', label: 'Select your role' },
		{ value: 'it_admin', label: 'IT Admin' },
		{ value: 'network_engineer', label: 'Network Engineer' },
		{ value: 'devops', label: 'DevOps' },
		{ value: 'manager', label: 'Manager / Director' },
		{ value: 'executive', label: 'Owner / Executive' },
		{ value: 'other', label: 'Other' }
	];

	const companySizeOptions = [
		{ value: '', label: 'Select company size' },
		{ value: '1-10', label: '1-10 employees' },
		{ value: '11-25', label: '11-25 employees' },
		{ value: '26-50', label: '26-50 employees' },
		{ value: '51-100', label: '51-100 employees' },
		{ value: '101-250', label: '101-250 employees' },
		{ value: '251-500', label: '251-500 employees' },
		{ value: '501-1000', label: '501-1000 employees' },
		{ value: '1001+', label: '1001+ employees' }
	];

	let jobTitle = $state('');
	let companySize = $state('');

	function dismiss() {
		// Submit empty payload — still records ProfileCompleted milestone
		profileMutation.mutate({ job_title: undefined, company_size: undefined });
	}

	function submit() {
		profileMutation.mutate({
			job_title: jobTitle || undefined,
			company_size: companySize || undefined
		});
	}
</script>

{#if visible}
	<section>
		<div class="rounded-lg border border-blue-600/30 bg-blue-900/20 p-4">
			<div class="flex items-center justify-between">
				<div>
					<h3 class="text-primary text-sm font-semibold">Tell us about your team</h3>
					<p class="text-secondary mt-1 text-xs">Helps us prioritize features for your use case.</p>
				</div>
				<button onclick={dismiss} class="text-tertiary hover:text-secondary text-sm">
					Dismiss
				</button>
			</div>
			<div class="mt-3 grid gap-3 sm:grid-cols-2">
				<select bind:value={jobTitle} class="input text-sm">
					{#each roleOptions as option (option.value)}
						<option value={option.value}>{option.label}</option>
					{/each}
				</select>
				<select bind:value={companySize} class="input text-sm">
					{#each companySizeOptions as option (option.value)}
						<option value={option.value}>{option.label}</option>
					{/each}
				</select>
			</div>
			<button onclick={submit} class="btn-primary mt-3 text-sm">Submit</button>
		</div>
	</section>
{/if}
