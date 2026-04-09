<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import { submitForm } from '$lib/shared/components/forms/form-context';
	import { required, max } from '$lib/shared/components/forms/validators';
	import { pushError } from '$lib/shared/stores/feedback';
	import type { Share } from '../types/base';
	import { useUpdateShareMutation, useDeleteShareMutation } from '../queries';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { billingPlans } from '$lib/shared/stores/metadata';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import DateInput from '$lib/shared/components/forms/input/DateInput.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import UpgradeButton from '$lib/shared/components/UpgradeButton.svelte';
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import { generateShareUrl, generateEmbedCode } from '../queries';
	import { Sun, Moon, Monitor } from 'lucide-svelte';
	import {
		common_delete,
		common_deleting,
		common_enabled,
		common_failedToDelete,
		common_failedToSave,
		common_height,
		common_name,
		common_password,
		common_save,
		common_saving,
		common_theme,
		common_width,
		shares_accessControl,
		shares_allowedDomainsHelp,
		shares_allowedDomainsPlaceholder,
		shares_allowedEmbedDomains,
		shares_cacheInfoBody,
		shares_cacheInfoTitle,
		shares_displayOptions,
		shares_embedCode,
		shares_embedDimensions,
		shares_embedsRequirePlan,
		shares_enabledHelp,
		shares_expirationDate,
		shares_expirationHelp,
		shares_namePlaceholder,
		shares_passwordHelpEdit,
		shares_passwordPlaceholder,
		shares_shareThemeDefault,
		shares_shareThemeLight,
		shares_shareThemeDark,
		shares_shareUrl,
		shares_showExportButton,
		shares_showInspectPanel,
		shares_showMinimap,
		shares_showZoomControls,
		shares_upgradeForEmbeds
	} from '$lib/paraglide/messages';

	let {
		share,
		onDeleted
	}: {
		share: Share;
		onDeleted: () => void;
	} = $props();

	// Mutations
	const updateShareMutation = useUpdateShareMutation();
	const deleteShareMutation = useDeleteShareMutation();

	// TanStack Query for current user and organization
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const organizationQuery = useOrganizationQuery();
	let organization = $derived(organizationQuery.data);

	let loading = $state(false);
	let deleting = $state(false);
	let shareTheme = $state<'default' | 'light' | 'dark'>('default');

	let hasEmbedsFeature = $derived(
		organization?.plan ? billingPlans.getMetadata(organization.plan.type).features.embeds : true
	);

	function getDefaultValues() {
		return {
			name: share.name || '',
			password: '',
			allowed_domains: share.allowed_domains?.join(', ') || '',
			expires_at: share.expires_at || '',
			is_enabled: share.is_enabled ?? true,
			show_zoom_controls: share.options?.show_zoom_controls ?? true,
			show_inspect_panel: share.options?.show_inspect_panel ?? true,
			show_export_button: share.options?.show_export_button ?? true,
			show_minimap: share.options?.show_minimap ?? true,
			embed_width: '800',
			embed_height: '600',
			// Preserve share fields
			id: share.id,
			topology_id: share.topology_id,
			network_id: share.network_id,
			created_by: share.created_by
		};
	}

	// Create form
	const form = createForm(() => ({
		defaultValues: getDefaultValues(),
		onSubmit: async ({ value }) => {
			const formData = {
				id: value.id,
				name: value.name.trim(),
				topology_id: value.topology_id,
				network_id: value.network_id,
				created_by: currentUser?.id || value.created_by,
				allowed_domains: value.allowed_domains.trim()
					? value.allowed_domains
							.split(',')
							.map((d: string) => d.trim())
							.filter(Boolean)
					: null,
				expires_at: value.expires_at || null,
				is_enabled: value.is_enabled,
				options: {
					show_zoom_controls: value.show_zoom_controls,
					show_inspect_panel: value.show_inspect_panel,
					show_export_button: value.show_export_button,
					show_minimap: value.show_minimap
				}
			} as Share;

			loading = true;
			try {
				const password = value.password || undefined;
				await updateShareMutation.mutateAsync({
					id: share.id,
					request: { share: formData, password }
				});
			} catch (error) {
				pushError(error instanceof Error ? error.message : common_failedToSave());
			} finally {
				loading = false;
			}
		}
	}));

	// Reset form when share changes
	$effect(() => {
		if (share?.id) {
			form.reset(getDefaultValues());
			shareTheme = 'default';
		}
	});

	async function handleSubmit() {
		await submitForm(form);
	}

	async function handleDelete() {
		deleting = true;
		try {
			await deleteShareMutation.mutateAsync(share.id);
			onDeleted();
		} catch (error) {
			pushError(error instanceof Error ? error.message : common_failedToDelete());
		} finally {
			deleting = false;
		}
	}

	// For embed code display
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	let formValues = $derived(form.state.values as any);
	let embedWidth = $derived(parseInt(String(formValues.embed_width)) || 800);
	let embedHeight = $derived(parseInt(String(formValues.embed_height)) || 600);
	let themeParam = $derived(shareTheme === 'default' ? undefined : shareTheme) as
		| 'light'
		| 'dark'
		| undefined;
</script>

<form
	onsubmit={(e) => {
		e.preventDefault();
		e.stopPropagation();
		handleSubmit();
	}}
	class="flex min-h-0 flex-1 flex-col"
>
	<div class="flex-1 overflow-auto">
		<div class="space-y-6">
			<InlineInfo
				title={shares_cacheInfoTitle()}
				body={shares_cacheInfoBody()}
				dismissableKey="share-cache-info"
			/>

			<!-- Name -->
			<div class="card card-static">
				<form.Field
					name="name"
					validators={{
						onBlur: ({ value }) => required(value) || max(100)(value)
					}}
				>
					{#snippet children(field)}
						<TextInput
							label={common_name()}
							id="share-name"
							{field}
							placeholder={shares_namePlaceholder()}
							required
						/>
					{/snippet}
				</form.Field>
			</div>

			<div class="card card-static space-y-3">
				<span class="text-secondary text-m">{shares_accessControl()}</span>

				<!-- Password -->
				<form.Field name="password">
					{#snippet children(field)}
						<TextInput
							label={common_password()}
							id="share-password"
							type="password"
							{field}
							placeholder={shares_passwordPlaceholder()}
							helpText={shares_passwordHelpEdit()}
						/>
					{/snippet}
				</form.Field>

				<!-- Enabled & Expiration -->
				<div class="grid grid-cols-2 gap-4">
					<form.Field name="expires_at">
						{#snippet children(field)}
							<DateInput
								{field}
								label={shares_expirationDate()}
								id="expires-at"
								helpText={shares_expirationHelp()}
							/>
						{/snippet}
					</form.Field>
					<div class="flex items-center">
						<form.Field name="is_enabled">
							{#snippet children(field)}
								<Checkbox
									label={common_enabled()}
									id="is-enabled"
									{field}
									helpText={shares_enabledHelp()}
								/>
							{/snippet}
						</form.Field>
					</div>
				</div>

				<!-- Allowed Domains -->
				<form.Field name="allowed_domains">
					{#snippet children(field)}
						<TextInput
							label={shares_allowedEmbedDomains()}
							id="allowed-domains"
							{field}
							placeholder={shares_allowedDomainsPlaceholder()}
							helpText={shares_allowedDomainsHelp()}
						/>
					{/snippet}
				</form.Field>
			</div>

			<div class="card card-static space-y-3">
				<span class="text-secondary text-m">{shares_displayOptions()}</span>
				<form.Field name="show_zoom_controls">
					{#snippet children(field)}
						<Checkbox label={shares_showZoomControls()} id="show-zoom-controls" {field} />
					{/snippet}
				</form.Field>
				<form.Field name="show_inspect_panel">
					{#snippet children(field)}
						<Checkbox label={shares_showInspectPanel()} id="show-inspect-panel" {field} />
					{/snippet}
				</form.Field>
				<form.Field name="show_export_button">
					{#snippet children(field)}
						<Checkbox label={shares_showExportButton()} id="show-export-button" {field} />
					{/snippet}
				</form.Field>
				<form.Field name="show_minimap">
					{#snippet children(field)}
						<Checkbox label={shares_showMinimap()} id="show-minimap" {field} />
					{/snippet}
				</form.Field>
				<div>
					<span class="text-secondary mb-1 block text-sm font-medium">{common_theme()}</span>
					<div class="flex gap-2">
						<button
							type="button"
							class="flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm {shareTheme ===
							'default'
								? 'btn-primary'
								: 'btn-secondary'}"
							onclick={() => (shareTheme = 'default')}
						>
							<Monitor class="h-3.5 w-3.5" />
							{shares_shareThemeDefault()}
						</button>
						<button
							type="button"
							class="flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm {shareTheme ===
							'light'
								? 'btn-primary'
								: 'btn-secondary'}"
							onclick={() => (shareTheme = 'light')}
						>
							<Sun class="h-3.5 w-3.5" />
							{shares_shareThemeLight()}
						</button>
						<button
							type="button"
							class="flex items-center gap-1.5 rounded-md px-3 py-1.5 text-sm {shareTheme === 'dark'
								? 'btn-primary'
								: 'btn-secondary'}"
							onclick={() => (shareTheme = 'dark')}
						>
							<Moon class="h-3.5 w-3.5" />
							{shares_shareThemeDark()}
						</button>
					</div>
				</div>
				<span class="text-secondary block text-sm font-medium">{shares_embedDimensions()}</span>
				<div class="grid grid-cols-2 gap-4">
					<form.Field name="embed_width">
						{#snippet children(field)}
							<TextInput
								label={common_width()}
								id="embed-width"
								type="number"
								{field}
								placeholder="800"
							/>
						{/snippet}
					</form.Field>
					<form.Field name="embed_height">
						{#snippet children(field)}
							<TextInput
								label={common_height()}
								id="embed-height"
								type="number"
								{field}
								placeholder="600"
							/>
						{/snippet}
					</form.Field>
				</div>
			</div>

			<!-- Share URL / Embed Code -->
			<div class="space-y-4">
				<div>
					<span class="text-secondary mb-1 block text-sm font-medium">{shares_shareUrl()}</span>
					<CodeContainer
						language="bash"
						expandable={false}
						code={generateShareUrl(share.id, themeParam)}
					/>
				</div>
				<div class="space-y-2">
					<span class="text-secondary mb-1 block text-sm font-medium">{shares_embedCode()}</span>
					{#if !hasEmbedsFeature}
						<InlineInfo title={shares_embedsRequirePlan()} body={shares_upgradeForEmbeds()} />
						<div class="mt-2">
							<UpgradeButton feature="embeds" />
						</div>
					{:else}
						<CodeContainer
							language="html"
							expandable={false}
							code={generateEmbedCode(share.id, embedWidth, embedHeight, themeParam)}
						/>
					{/if}
				</div>
			</div>
		</div>
	</div>

	<!-- Footer buttons -->
	<div class="mt-4 flex items-center justify-between border-t border-gray-600 pt-4">
		<div>
			<button
				type="button"
				disabled={deleting || loading}
				onclick={handleDelete}
				class="btn-danger"
			>
				{deleting ? common_deleting() : common_delete()}
			</button>
		</div>
		<div>
			<button type="submit" disabled={loading || deleting} class="btn-primary">
				{loading ? common_saving() : common_save()}
			</button>
		</div>
	</div>
</form>
