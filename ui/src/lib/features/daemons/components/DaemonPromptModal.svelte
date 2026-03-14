<script lang="ts">
	import { draw, fade, scale } from 'svelte/transition';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import { useConfigQuery, isCloud } from '$lib/shared/stores/config-query';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { createForm } from '@tanstack/svelte-form';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import {
		common_other,
		common_reddit,
		common_youtube,
		daemons_promptTitle,
		daemons_promptBody,
		daemons_promptSkip,
		daemons_promptGetStarted,
		onboarding_howDidYouHear,
		onboarding_referralSource_blogArticle,
		onboarding_referralSource_hackerNews,
		onboarding_referralSource_otherPlaceholder,
		onboarding_referralSource_preferNotToSay,
		onboarding_referralSource_searchEngine,
		onboarding_referralSource_selfHosted,
		onboarding_referralSource_socialMedia,
		onboarding_referralSource_wordOfMouth
	} from '$lib/paraglide/messages';

	let {
		isOpen,
		onInstall,
		onSkip
	}: {
		isOpen: boolean;
		onInstall: () => void;
		onSkip: () => void;
	} = $props();

	const configQuery = useConfigQuery();
	let showReferralSource = $derived(configQuery.data != null && isCloud(configQuery.data));

	const referralSourceOptions = [
		{ value: '', label: onboarding_howDidYouHear(), disabled: true },
		{ value: 'search_engine', label: onboarding_referralSource_searchEngine() },
		{ value: 'youtube', label: common_youtube() },
		{ value: 'blog_article', label: onboarding_referralSource_blogArticle() },
		{ value: 'reddit', label: common_reddit() },
		{ value: 'hacker_news', label: onboarding_referralSource_hackerNews() },
		{ value: 'social_media', label: onboarding_referralSource_socialMedia() },
		{ value: 'word_of_mouth', label: onboarding_referralSource_wordOfMouth() },
		{ value: 'self_hosted', label: onboarding_referralSource_selfHosted() },
		{ value: 'other', label: common_other() },
		{ value: 'prefer_not_to_say', label: onboarding_referralSource_preferNotToSay() }
	];

	const form = createForm(() => ({
		defaultValues: {
			referralSource: '',
			referralSourceOther: ''
		},
		onSubmit: async () => {}
	}));

	function trackReferralSource() {
		const source = form.state.values.referralSource;
		if (source) {
			trackEvent('onboarding_referral_source', {
				referral_source: source,
				referral_source_other: form.state.values.referralSourceOther || undefined
			});
		}
	}

	function handleInstall() {
		trackReferralSource();
		onInstall();
	}

	function handleSkip() {
		trackReferralSource();
		onSkip();
	}
</script>

<GenericModal
	{isOpen}
	title={daemons_promptTitle()}
	size="md"
	onClose={handleSkip}
	showCloseButton={false}
	preventCloseOnClickOutside={true}
>
	<div class="flex min-h-0 flex-1 flex-col">
		<div class="flex-1 overflow-auto p-6">
			<div class="space-y-6">
				<!-- Animated node discovery visual -->
				<div class="flex h-32 items-center justify-center">
					<svg width="200" height="100" viewBox="0 0 200 100">
						{#if isOpen}
							<!-- Lines -->
							<line
								x1="40"
								y1="30"
								x2="100"
								y2="50"
								class="discovery-line"
								in:draw={{ delay: 800, duration: 500 }}
							/>
							<line
								x1="100"
								y1="50"
								x2="160"
								y2="25"
								class="discovery-line"
								in:draw={{ delay: 1200, duration: 500 }}
							/>
							<line
								x1="100"
								y1="50"
								x2="130"
								y2="80"
								class="discovery-line"
								in:draw={{ delay: 1600, duration: 500 }}
							/>

							<!-- Nodes -->
							<g in:fade={{ delay: 200, duration: 400 }}>
								<g in:scale={{ start: 0, delay: 200, duration: 400 }}>
									<circle cx="40" cy="30" r="6" class="fill-primary-500" />
								</g>
							</g>
							<g in:fade={{ delay: 500, duration: 400 }}>
								<g in:scale={{ start: 0, delay: 500, duration: 400 }}>
									<circle cx="100" cy="50" r="6" class="fill-primary-500" />
								</g>
							</g>
							<g in:fade={{ delay: 800, duration: 400 }}>
								<g in:scale={{ start: 0, delay: 800, duration: 400 }}>
									<circle cx="160" cy="25" r="6" class="fill-primary-500" />
								</g>
							</g>
							<g in:fade={{ delay: 1100, duration: 400 }}>
								<g in:scale={{ start: 0, delay: 1100, duration: 400 }}>
									<circle cx="130" cy="80" r="6" class="fill-primary-500" />
								</g>
							</g>
						{/if}
					</svg>
				</div>

				<p class="text-secondary text-sm">{daemons_promptBody()}</p>

				{#if showReferralSource}
					<div class="card card-static">
						<form.Field name="referralSource">
							{#snippet children(field)}
								<SelectInput
									label={onboarding_howDidYouHear()}
									id="referral-source"
									{field}
									options={referralSourceOptions}
								/>
							{/snippet}
						</form.Field>
						{#if form.state.values.referralSource === 'other'}
							<div class="mt-3">
								<form.Field name="referralSourceOther">
									{#snippet children(field)}
										<TextInput
											label=""
											id="referral-source-other"
											{field}
											placeholder={onboarding_referralSource_otherPlaceholder()}
										/>
									{/snippet}
								</form.Field>
							</div>
						{/if}
					</div>
				{/if}
			</div>
		</div>

		<div class="modal-footer">
			<div class="flex items-center justify-end gap-3">
				<button type="button" class="btn-secondary" onclick={handleSkip}>
					{daemons_promptSkip()}
				</button>
				<button type="button" class="btn-primary" onclick={handleInstall}>
					{daemons_promptGetStarted()}
				</button>
			</div>
		</div>
	</div>
</GenericModal>

<style>
	.discovery-line {
		stroke: rgb(var(--color-primary-500));
		stroke-width: 1.5;
	}
</style>
