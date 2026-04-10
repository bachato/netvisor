<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { InterfaceBinding, Service } from '$lib/features/services/types/base';
	import type { HostFormData, Interface } from '$lib/features/hosts/types/base';
	import type { EntityDisplayComponent } from '../types';
	import IPAddressBindingInlineEditor from './IPAddressBindingInlineEditor.svelte';

	// Context for binding display within form editing
	export interface IPAddressBindingDisplayContext {
		service: Service;
		host: HostFormData;
		services: Service[];
		interfaces: Interface[];
		isContainerSubnet: (subnetId: string) => boolean;
	}

	// Helper to format interface for display
	function formatInterfaceForBinding(
		iface: Interface,
		isContainerSubnet: (subnetId: string) => boolean
	): string {
		return isContainerSubnet(iface.subnet_id)
			? (iface.name ?? iface.ip_address)
			: (iface.name ? iface.name + ': ' : '') + iface.ip_address;
	}

	export const IPAddressBindingDisplay: EntityDisplayComponent<
		InterfaceBinding,
		IPAddressBindingDisplayContext
	> = {
		getId: (binding: InterfaceBinding) => binding.id,
		getLabel: (binding: InterfaceBinding, context: IPAddressBindingDisplayContext) => {
			const interfacesData = context?.interfaces ?? [];
			const isContainerSubnetFn = context?.isContainerSubnet ?? (() => false);
			const iface = interfacesData.find((i) => i.id === binding.interface_id);
			const interfaceFormatted = iface
				? formatInterfaceForBinding(iface, isContainerSubnetFn)
				: 'Unknown Interface';
			return interfaceFormatted;
		},
		getDescription: () => '',
		getIcon: () => entities.getIconComponent('Interface'),
		getIconColor: () => entities.getColorHelper('Interface').icon,
		getTags: () => [],
		getCategory: (binding: InterfaceBinding, context: IPAddressBindingDisplayContext) => {
			const servicesData = context?.services ?? [];
			const service = servicesData.find((s) => s.bindings.some((b) => b.id === binding.id));
			if (!service) return null;

			const serviceType = serviceDefinitions.getItem(service.service_definition);
			return serviceType?.category || null;
		},
		supportsInlineEdit: true,
		InlineEditorComponent: IPAddressBindingInlineEditor
	};
</script>

<script lang="ts">
	import ListSelectItem from '../ListSelectItem.svelte';

	export let item: InterfaceBinding;
	export let context: IPAddressBindingDisplayContext;
</script>

<ListSelectItem {item} {context} displayComponent={IPAddressBindingDisplay} />
