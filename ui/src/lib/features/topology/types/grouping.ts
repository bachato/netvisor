import type { components } from '$lib/api/schema';

export type GraphRule<T> = { id: string; rule: T };
export type ContainerRule = components['schemas']['GraphRule_ContainerRule']['rule'];
export type ElementRule = components['schemas']['GraphRule_ElementRule']['rule'];
export type ContainerGraphRule = components['schemas']['GraphRule_ContainerRule'];
export type ElementGraphRule = components['schemas']['GraphRule_ElementRule'];

export type ContainerRuleType = 'BySubnet' | 'MergeDockerBridges' | 'ByApplication';

export function getContainerRuleDiscriminant(rule: ContainerRule): ContainerRuleType {
	if (typeof rule === 'string') return rule;
	return Object.keys(rule)[0] as ContainerRuleType;
}

export type ElementRuleType =
	| 'ByServiceCategory'
	| 'ByTag'
	| 'ByHypervisor'
	| 'ByContainerRuntime'
	| 'ByStack';

export function getElementRuleType(rule: ElementRule): ElementRuleType {
	if (typeof rule === 'string') return rule;
	if ('ByServiceCategory' in rule) return 'ByServiceCategory';
	return 'ByTag';
}

export function getElementRuleTitle(rule: ElementRule): string | null | undefined {
	if (typeof rule === 'string') return null;
	if ('ByServiceCategory' in rule) return rule.ByServiceCategory.title;
	return rule.ByTag.title;
}

export function setElementRuleTitle(rule: ElementRule, title: string | null): ElementRule {
	if (typeof rule === 'string') return rule;
	if ('ByServiceCategory' in rule)
		return { ByServiceCategory: { ...rule.ByServiceCategory, title } };
	if ('ByTag' in rule) return { ByTag: { ...rule.ByTag, title } };
	return rule;
}

export function makeGraphRule<T>(rule: T): GraphRule<T> {
	return { id: crypto.randomUUID(), rule };
}
