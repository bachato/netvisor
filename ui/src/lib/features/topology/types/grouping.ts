import type { components } from '$lib/api/schema';

export type GraphRule<T> = { id: string; rule: T };
export type ContainerRule = components['schemas']['GraphRule_ContainerRule']['rule'];
export type ElementRule = components['schemas']['GraphRule_ElementRule']['rule'];
export type ContainerGraphRule = components['schemas']['GraphRule_ContainerRule'];
export type ElementGraphRule = components['schemas']['GraphRule_ElementRule'];

export type ContainerRuleType = 'BySubnet' | 'ByVirtualizingService' | 'ByApplicationGroup';

export function getContainerRuleDiscriminant(rule: ContainerRule): ContainerRuleType {
	if (typeof rule === 'string') return rule;
	return Object.keys(rule)[0] as ContainerRuleType;
}

export type ElementRuleType = 'ByServiceCategory' | 'ByTag' | 'ByVirtualizer';

export function getElementRuleType(rule: ElementRule): ElementRuleType {
	if (rule === 'ByVirtualizer') return 'ByVirtualizer';
	if (typeof rule === 'object' && 'ByServiceCategory' in rule) return 'ByServiceCategory';
	return 'ByTag';
}

export function getElementRuleTitle(rule: ElementRule): string | null | undefined {
	if (rule === 'ByVirtualizer') return null;
	if (typeof rule === 'object' && 'ByServiceCategory' in rule) return rule.ByServiceCategory.title;
	if (typeof rule === 'object' && 'ByTag' in rule) return rule.ByTag.title;
	return null;
}

export function setElementRuleTitle(rule: ElementRule, title: string | null): ElementRule {
	if (rule === 'ByVirtualizer') return rule;
	if (typeof rule === 'object' && 'ByServiceCategory' in rule)
		return { ByServiceCategory: { ...rule.ByServiceCategory, title } };
	if (typeof rule === 'object' && 'ByTag' in rule) return { ByTag: { ...rule.ByTag, title } };
	return rule;
}

export function makeGraphRule<T>(rule: T): GraphRule<T> {
	return { id: crypto.randomUUID(), rule };
}
