<script lang="ts" module>
	import type { Topology } from '../../../../types/base';

	export interface BindingPickerService {
		serviceId: string;
		serviceName: string;
		hostName: string;
		/**
		 * Optional IP-address scope. If set, candidate bindings are filtered to those whose
		 * `ip_address_id` matches this value or is null (i.e. all-IPs binding).
		 */
		ipAddressIdFilter?: string | null;
		/** Optional display label for the IP scope, shown as a subtitle. */
		ipScopeLabel?: string;
	}

	export interface BindingOption {
		id: string;
		label: string;
	}

	export function buildBindingOptions(
		topology: Topology,
		serviceId: string,
		ipAddressIdFilter: string | null | undefined
	): BindingOption[] {
		const service = topology.services.find((s) => s.id === serviceId);
		if (!service) return [];
		const options: BindingOption[] = [];
		for (const binding of service.bindings) {
			if (ipAddressIdFilter != null) {
				if (binding.ip_address_id !== ipAddressIdFilter && binding.ip_address_id !== null) {
					continue;
				}
			}
			const portInfo =
				binding.type === 'Port' && binding.port_id
					? (() => {
							const port = topology.ports.find((p) => p.id === binding.port_id);
							return port ? `:${port.number}/${port.protocol}` : '';
						})()
					: '';
			const ipInfo = binding.ip_address_id
				? (() => {
						const ip = topology.ip_addresses.find((i) => i.id === binding.ip_address_id);
						return ip ? ` @ ${ip.ip_address}` : '';
					})()
				: '';
			options.push({
				id: binding.id,
				label: `${service.name}${portInfo}${ipInfo}`
			});
		}
		return options;
	}
</script>

<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import { topology_multiSelectNoBindings, common_bindings } from '$lib/paraglide/messages';

	let {
		topology,
		services,
		onChange,
		disabled = false
	}: {
		topology: Topology;
		services: BindingPickerService[];
		/** Emits the full map of serviceId → bindingId (null when not yet picked). */
		onChange: (selections: Record<string, string | null>) => void;
		disabled?: boolean;
	} = $props();

	let serviceOptions = $derived(
		services.map((s) => ({
			service: s,
			options: buildBindingOptions(topology, s.serviceId, s.ipAddressIdFilter)
		}))
	);

	function initialValues(): Record<string, string> {
		const out: Record<string, string> = {};
		for (const { service, options } of serviceOptions) {
			out[service.serviceId] = options.length === 1 ? options[0].id : '';
		}
		return out;
	}

	const form = createForm(() => ({
		defaultValues: initialValues(),
		onSubmit: () => {}
	}));

	$effect(() => {
		const keyList = services.map((s) => s.serviceId).join('|');
		void keyList;
		form.reset(initialValues());
	});

	$effect(() => {
		const values = form.state.values;
		const out: Record<string, string | null> = {};
		for (const s of services) out[s.serviceId] = values[s.serviceId] || null;
		onChange(out);
	});
</script>

<div class="space-y-2">
	{#each serviceOptions as entry (entry.service.serviceId)}
		{@const service = entry.service}
		{@const options = entry.options}
		<div class="card card-static space-y-1 p-2">
			<div class="text-primary truncate text-xs font-medium">
				{service.serviceName}
			</div>
			<div class="text-tertiary truncate text-[10px]">
				{service.hostName}{service.ipScopeLabel ? ` — ${service.ipScopeLabel}` : ''}
			</div>
			{#if options.length === 0}
				<div class="text-tertiary text-xs italic">
					{topology_multiSelectNoBindings()}
				</div>
			{:else if options.length === 1}
				<div class="text-secondary text-xs">
					{options[0].label}
				</div>
			{:else}
				<form.Field name={service.serviceId}>
					{#snippet children(field)}
						<SelectInput
							label=""
							id="binding-{service.serviceId}"
							{field}
							{disabled}
							required
							options={[
								{ value: '', label: common_bindings(), disabled: true },
								...options.map((o) => ({ value: o.id, label: o.label }))
							]}
						/>
					{/snippet}
				</form.Field>
			{/if}
		</div>
	{/each}
</div>
