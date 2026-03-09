<script lang="ts" module>
	import { concepts, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { hoveredServiceCategory } from '$lib/features/topology/interactions';
	import { topologyOptions } from '$lib/features/topology/queries';
	import type { Port } from '$lib/features/hosts/types/base';
	import type { components } from '$lib/api/schema';
	type ServiceCategory = components['schemas']['ServiceCategory'];

	export interface ServiceDisplayContext {
		interfaceId?: string | null;
		ports?: Port[];
		showEntityTagPicker?: boolean;
		tagPickerDisabled?: boolean;
	}

	export const ServiceDisplay: EntityDisplayComponent<Service, ServiceDisplayContext> = {
		getId: (service: Service) => service.id,
		getLabel: (service: Service) => service.name,
		getDescription: (service: Service, context) => {
			let descriptionItems = [];

			// Show service definition name if different from service name
			const defName = serviceDefinitions.getName(service.service_definition);
			if (defName && defName !== service.name) {
				descriptionItems.push(defName);
			}

			// Filter bindings relevant to the interface(s)
			let bindingsOnInterface = service.bindings.filter((b) =>
				b.interface_id ? context.interfaceId == b.interface_id || context.interfaceId == null : true
			);

			// Show actual port numbers when ports are available in context
			if (context.ports && context.ports.length > 0) {
				const portBindings = bindingsOnInterface.filter((b) => b.type === 'Port');
				let bindingDescriptions: string[] = [];

				if (portBindings.length > 0) {
					for (const binding of portBindings) {
						const port = binding.port_id
							? context.ports.find((p) => p.id === binding.port_id)
							: null;

						if (port) {
							bindingDescriptions.push(formatPort(port));
						}
					}
				}

				if (bindingDescriptions.length > 0) {
					descriptionItems.push(bindingDescriptions.join(', '));
				}
			} else {
				// No ports in context - show binding count
				if (bindingsOnInterface.length > 0) {
					descriptionItems.push(
						`${bindingsOnInterface.length} binding${bindingsOnInterface.length > 1 ? 's' : ''}`
					);
				}
			}

			return descriptionItems.join(' · ');
		},
		getIcon: (service: Service) => {
			return serviceDefinitions.getIconComponent(service.service_definition);
		},
		getIconColor: (service: Service) =>
			serviceDefinitions.getColorHelper(service.service_definition).icon,
		getTags: (service: Service) => {
			let tags: TagProps[] = [];

			// Add category tag
			const category = serviceDefinitions.getCategory(service.service_definition);
			if (category) {
				const categoryColor = serviceDefinitions.getColorHelper(service.service_definition).color;
				tags.push({
					label: category,
					color: categoryColor,
					onmouseenter: () => {
						hoveredServiceCategory.set({ category, color: categoryColor });
					},
					onmouseleave: () => {
						hoveredServiceCategory.set(null);
					},
					onclick: () => {
						const cat = category as ServiceCategory;
						topologyOptions.update((opts) => {
							const hidden = opts.request.hide_service_categories ?? [];
							if (!hidden.includes(cat)) {
								return {
									...opts,
									request: {
										...opts.request,
										hide_service_categories: [...hidden, cat]
									}
								};
							}
							return opts;
						});
					}
				});
			}

			if (service.virtualization) {
				tags.push({
					label: service.virtualization.type,
					color: concepts.getColorHelper('Virtualization').color
				});
			}

			return tags;
		},
		getTagPickerProps: (service: Service, context: ServiceDisplayContext) => {
			if (!context.showEntityTagPicker) return null;
			return {
				selectedTagIds: service.tags,
				entityId: service.id,
				entityType: 'Service' as const
			};
		},
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityDisplayComponent } from '../types';
	import type { Service } from '$lib/features/services/types/base';
	import type { TagProps } from '$lib/shared/components/data/types';
	import { formatPort } from '$lib/shared/utils/formatting';

	interface Props {
		item: Service;
		context: ServiceDisplayContext;
	}

	let { item, context }: Props = $props();
</script>

<ListSelectItem {item} {context} displayComponent={ServiceDisplay} />
