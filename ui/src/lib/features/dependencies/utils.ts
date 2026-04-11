import type { DependencyType } from './types/base';

type NameGenerator = (names: string[]) => string;

const nameGenerators: Record<DependencyType, NameGenerator> = {
	RequestPath: (names) => {
		if (names.length === 0) return '';
		if (names.length === 1) return names[0];
		return `${names[0]} → ${names[names.length - 1]}`;
	},
	HubAndSpoke: (names) => {
		if (names.length === 0) return '';
		return `${names[0]} Hub`;
	}
};

/**
 * Generate a default dependency name from the selected element names.
 * @param type - The dependency type
 * @param names - Ordered display names of the selected elements
 */
export function generateDependencyName(type: DependencyType, names: string[]): string {
	return nameGenerators[type](names);
}
