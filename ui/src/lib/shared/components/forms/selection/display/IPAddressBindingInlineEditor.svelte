<script lang="ts">
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { formatIPAddress } from '$lib/features/hosts/queries';
	import { useIPAddressesQuery } from '$lib/features/ip-addresses/queries';
	import { useSubnetsQuery, isContainerSubnet } from '$lib/features/subnets/queries';
	import type { HostFormData } from '$lib/features/hosts/types/base';
	import type { IPAddressBinding, Service } from '$lib/features/services/types/base';

	// TanStack Query hooks
	const ipAddressesQuery = useIPAddressesQuery();
	const subnetsQuery = useSubnetsQuery();
	let ipAddressesData = $derived(ipAddressesQuery.data ?? []);
	let subnetsData = $derived(subnetsQuery.data ?? []);

	// Helper to check if subnet is a container subnet
	let isContainerSubnetFn = $derived((subnetId: string) => {
		const subnet = subnetsData.find((s) => s.id === subnetId);
		return subnet ? isContainerSubnet(subnet) : false;
	});

	interface Props {
		binding: IPAddressBinding;
		onUpdate?: (updates: Partial<IPAddressBinding>) => void;
		service?: Service;
		host?: HostFormData;
	}

	let { binding, onUpdate = () => {}, service = undefined, host = undefined }: Props = $props();

	// IP address binding must have an ip_address_id - look up from host form data first (for unsaved hosts),
	// then fall back to query data (for saved hosts)
	let ipAddr = $derived(
		binding.ip_address_id
			? (host?.ip_addresses.find((i) => i.id === binding.ip_address_id) ??
					ipAddressesData.find((i) => i.id === binding.ip_address_id))
			: null
	);

	// Check if this service has a Port binding on "All Interfaces" (ip_address_id === null)
	let hasPortBindingOnAllIPAddresses = $derived(
		service?.bindings.some((b) => b.type === 'Port' && b.ip_address_id === null) ?? false
	);

	// Create interface options with disabled state
	let ipAddressOptions = $derived(
		host?.ip_addresses.map((ipAddr) => {
			// Can't add IP address binding if service has Port binding on "All Interfaces"
			if (hasPortBindingOnAllIPAddresses && ipAddr.id !== binding.ip_address_id) {
				return {
					ipAddr,
					disabled: true,
					reason: 'Service has Port binding on all IP addresses'
				};
			}

			// Can't select if THIS service has Port bindings on this specific interface
			const thisServiceHasPortBindings = service?.bindings.some(
				(b) => b.type === 'Port' && b.ip_address_id === ipAddr.id
			);
			if (thisServiceHasPortBindings && ipAddr.id !== binding.ip_address_id) {
				return {
					ipAddr,
					disabled: true,
					reason: 'This service has Port bindings on this IP address'
				};
			}

			return {
				ipAddr,
				disabled: false,
				reason: null
			};
		}) || []
	);

	// Local state for the select value
	let selectedValue = $derived(binding.ip_address_id ?? '');

	// Handle selection change
	function handleChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const newValue = target.value;
		selectedValue = newValue;

		if (newValue !== binding.ip_address_id) {
			onUpdate({ ip_address_id: newValue });
		}
	}
</script>

<!-- svelte-ignore a11y_click_events_have_key_events, a11y_no_static_element_interactions -->
<div class="flex-1" onclick={(e) => e.stopPropagation()}>
	<div class="text-secondary mb-1 block text-xs font-medium">IP Address Binding</div>

	{#if !service}
		<div class="text-danger rounded border border-red-600 bg-red-900/20 px-2 py-1 text-xs">
			Service not found
		</div>
	{:else if !host}
		<div class="text-danger rounded border border-red-600 bg-red-900/20 px-2 py-1 text-xs">
			Host not found
		</div>
	{:else}
		<div class="flex gap-3">
			<div class="flex-1">
				{#if host.ip_addresses && host.ip_addresses.length === 0}
					<InlineWarning title="" body="No IP addresses configured on host" />
				{:else if host.ip_addresses && host.ip_addresses.length === 1}
					<!-- Single IP address - show as read-only -->
					<div
						class="text-secondary rounded px-2 py-1 text-sm"
						style="border: 1px solid var(--color-border-input); background: var(--color-bg-input)"
					>
						{ipAddr ? formatIPAddress(ipAddr, isContainerSubnetFn) : 'Unknown IP Address'}
					</div>
				{:else if host.ip_addresses.length > 0}
					<!-- Multiple IP addresses - show as dropdown -->
					<select class="input-field w-full" value={selectedValue} onchange={handleChange}>
						{#each ipAddressOptions as { ipAddr, disabled, reason } (ipAddr.id)}
							<option value={ipAddr.id} {disabled}>
								{formatIPAddress(ipAddr, isContainerSubnetFn)}{disabled && reason
									? ` - ${reason}`
									: ''}
							</option>
						{/each}
					</select>
				{/if}
			</div>
		</div>
	{/if}
</div>
