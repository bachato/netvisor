<script lang="ts">
	import { Terminal } from 'lucide-svelte';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { useConfigQuery, isCloud } from '$lib/shared/stores/config-query';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import {
		common_install,
		common_other,
		common_reddit,
		common_youtube,
		daemons_promptTitle,
		daemons_promptBody,
		daemons_promptSkip,
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

	let referralSource = $state('');
	let referralSourceOther = $state('');

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

	function trackReferralSource() {
		if (referralSource) {
			trackEvent('onboarding_referral_source', {
				referral_source: referralSource,
				referral_source_other: referralSourceOther || undefined
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

<GenericModal {isOpen} title={daemons_promptTitle()} size="md" onClose={handleSkip}>
	{#snippet headerIcon()}
		<ModalHeaderIcon Icon={Terminal} color="Blue" />
	{/snippet}

	<div class="flex min-h-0 flex-1 flex-col">
		<div class="flex-1 overflow-auto p-6">
			<div class="space-y-6">
				<p class="text-secondary text-sm">{daemons_promptBody()}</p>

				{#if showReferralSource}
					<div class="card card-static">
						<label class="text-secondary mb-1 block text-sm font-medium" for="referral-source">
							{onboarding_howDidYouHear()}
						</label>
						<select id="referral-source" class="input w-full" bind:value={referralSource}>
							{#each referralSourceOptions as option (option.value)}
								<option value={option.value} disabled={option.disabled}>
									{option.label}
								</option>
							{/each}
						</select>
						{#if referralSource === 'other'}
							<div class="mt-3">
								<input
									type="text"
									class="input w-full"
									placeholder={onboarding_referralSource_otherPlaceholder()}
									bind:value={referralSourceOther}
								/>
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
					{common_install()}
				</button>
			</div>
		</div>
	</div>
</GenericModal>
