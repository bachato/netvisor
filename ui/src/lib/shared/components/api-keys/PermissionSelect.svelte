<script lang="ts">
	/**
	 * Shared component for selecting user permissions
	 * Used by user API keys, user invites, and user management
	 *
	 * Filters available permission options based on the current user's permissions
	 * (users can only grant permissions equal to or less than their own)
	 */
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import { permissions } from '$lib/shared/stores/metadata';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import type { UserOrgPermissions } from '$lib/features/users/types';
	import type { AnyFieldApi } from '@tanstack/svelte-form';

	interface Props {
		/** TanStack Form field for the permission value */
		field: AnyFieldApi;
		/** Label for the select input */
		label?: string;
		/** Help text to display below the input */
		helpText?: string;
		/** Whether the input is disabled */
		disabled?: boolean;
		/** Optional filter to further restrict available permissions */
		permissionFilter?: (permissionId: string) => boolean;
	}

	let {
		field,
		label = 'Permissions Level',
		helpText = 'Choose the access level',
		disabled = false,
		permissionFilter
	}: Props = $props();

	// Get current user to determine which permissions they can grant
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	// Build permission options based on what current user can manage
	let permissionOptions = $derived(
		permissions
			.getItems()
			.filter((p) => {
				// First check if current user can manage this permission level
				if (!currentUser) return false;
				const canManage = permissions
					.getMetadata(currentUser.permissions)
					.can_manage_user_permissions.includes(p.id);
				if (!canManage) return false;

				// Apply any additional filter
				if (permissionFilter && !permissionFilter(p.id)) return false;

				return true;
			})
			.map((p) => ({
				value: p.id,
				label: p.name ?? '',
				description: p.description ?? ''
			}))
	);
</script>

<SelectInput
	{label}
	id="permissions"
	{field}
	options={permissionOptions}
	{disabled}
	{helpText}
/>
