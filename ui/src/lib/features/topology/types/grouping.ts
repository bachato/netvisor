import type { components } from '$lib/api/schema';

export type ContainerRule = components['schemas']['ContainerRule'];
export type LeafRule = components['schemas']['LeafRule'];

export type LeafRuleType = 'ByServiceCategory' | 'ByTag';

export function getLeafRuleType(rule: LeafRule): LeafRuleType {
	if ('ByServiceCategory' in rule) return 'ByServiceCategory';
	return 'ByTag';
}

export function getLeafRuleTitle(rule: LeafRule): string | null | undefined {
	if ('ByServiceCategory' in rule) return rule.ByServiceCategory.title;
	return rule.ByTag.title;
}

export function setLeafRuleTitle(rule: LeafRule, title: string | null): LeafRule {
	if ('ByServiceCategory' in rule)
		return { ByServiceCategory: { ...rule.ByServiceCategory, title } };
	return { ByTag: { ...rule.ByTag, title } };
}
