/**
 * Perspective-aware inspector panel configuration.
 *
 * To add inspector support for a new perspective:
 * 1) Define section ordering in PerspectiveInspectorConfig on TopologyPerspective (backend: server/topology/types/inspector.rs)
 * 2) Add section components if needed under inspectors/sections/
 * 3) Register the component mapping in this file (SECTION_COMPONENTS)
 * 4) Run `make generate-types` to update frontend types
 */

import type { Component } from 'svelte';
import type { components } from '$lib/api/schema';

import SectionIdentity from './sections/SectionIdentity.svelte';
import SectionIfEntryData from './sections/SectionIfEntryData.svelte';
import SectionServices from './sections/SectionServices.svelte';
import SectionDependencies from './sections/SectionDependencies.svelte';
import SectionHostDetail from './sections/SectionHostDetail.svelte';
import SectionOtherInterfaces from './sections/SectionOtherInterfaces.svelte';
import SectionTags from './sections/SectionTags.svelte';
import SectionPortBindings from './sections/SectionPortBindings.svelte';
import SectionSubnetDetail from './sections/SectionSubnetDetail.svelte';
import SectionElementSummary from './sections/SectionElementSummary.svelte';
import SectionDependencySummary from './sections/SectionDependencySummary.svelte';

type TopologyPerspective = components['schemas']['TopologyPerspective'];

// Mirrors backend DependencyMemberType enum
export type DependencyMemberType = 'Services' | 'Bindings';

// Mirrors backend InspectorSection enum
export type InspectorSection =
	| 'Identity'
	| 'IfEntryData'
	| 'Services'
	| 'Dependencies'
	| 'HostDetail'
	| 'OtherInterfaces'
	| 'Tags'
	| 'PortBindings'
	| 'SubnetDetail'
	| 'ElementSummary'
	| 'DependencySummary';

// Mirrors backend PerspectiveInspectorConfig struct
export interface PerspectiveInspectorConfig {
	element_sections: InspectorSection[];
	container_sections: InspectorSection[];
	bulk_tag_entity: 'Host' | 'Service' | 'Subnet';
	dependency_creation: DependencyMemberType | null;
	show_application_group_picker: boolean;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const SECTION_COMPONENTS: Record<InspectorSection, Component<any>> = {
	Identity: SectionIdentity,
	IfEntryData: SectionIfEntryData,
	Services: SectionServices,
	Dependencies: SectionDependencies,
	HostDetail: SectionHostDetail,
	OtherInterfaces: SectionOtherInterfaces,
	Tags: SectionTags,
	PortBindings: SectionPortBindings,
	SubnetDetail: SectionSubnetDetail,
	ElementSummary: SectionElementSummary,
	DependencySummary: SectionDependencySummary
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function getSectionComponent(section: InspectorSection): Component<any> {
	return SECTION_COMPONENTS[section];
}

/**
 * Get the inspector configuration for a perspective.
 * Mirrors backend TopologyPerspective::inspector_config().
 */
export function getInspectorConfig(perspective: TopologyPerspective): PerspectiveInspectorConfig {
	switch (perspective) {
		case 'l3_logical':
			return {
				element_sections: [
					'Identity',
					'IfEntryData',
					'Services',
					'HostDetail',
					'OtherInterfaces',
					'Tags'
				],
				container_sections: ['SubnetDetail', 'ElementSummary'],
				bulk_tag_entity: 'Host',
				dependency_creation: 'Bindings',
				show_application_group_picker: false
			};
		case 'application':
			return {
				element_sections: ['Identity', 'Dependencies', 'PortBindings', 'Tags'],
				container_sections: ['Identity', 'DependencySummary'],
				bulk_tag_entity: 'Service',
				dependency_creation: 'Services',
				show_application_group_picker: true
			};
		case 'infrastructure':
			return {
				element_sections: ['Identity', 'Services', 'Tags'],
				container_sections: ['Identity', 'ElementSummary'],
				bulk_tag_entity: 'Host',
				dependency_creation: null,
				show_application_group_picker: false
			};
		case 'l2_physical':
			return {
				element_sections: ['Identity', 'IfEntryData', 'Tags'],
				container_sections: ['Identity', 'ElementSummary'],
				bulk_tag_entity: 'Host',
				dependency_creation: null,
				show_application_group_picker: false
			};
	}
}
