import type { components } from '$lib/api/schema';

export type GraphRule<T> = { id: string; rule: T };
export type ContainerRule = components['schemas']['GraphRule_ContainerRule']['rule'];
export type ElementRule = components['schemas']['GraphRule_ElementRule']['rule'];
export type ContainerGraphRule = components['schemas']['GraphRule_ContainerRule'];
export type ElementGraphRule = components['schemas']['GraphRule_ElementRule'];

export type ElementRuleType = 'ByServiceCategory' | 'ByTag';

export function getElementRuleType(rule: ElementRule): ElementRuleType {
	if ('ByServiceCategory' in rule) return 'ByServiceCategory';
	return 'ByTag';
}

export function getElementRuleTitle(rule: ElementRule): string | null | undefined {
	if ('ByServiceCategory' in rule) return rule.ByServiceCategory.title;
	return rule.ByTag.title;
}

export function setElementRuleTitle(rule: ElementRule, title: string | null): ElementRule {
	if ('ByServiceCategory' in rule)
		return { ByServiceCategory: { ...rule.ByServiceCategory, title } };
	return { ByTag: { ...rule.ByTag, title } };
}

export function makeGraphRule<T>(rule: T): GraphRule<T> {
	return { id: crypto.randomUUID(), rule };
}
