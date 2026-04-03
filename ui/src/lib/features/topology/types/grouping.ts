// Stub types matching the backend GroupingRule shape.
// These will be replaced by generated types after `make generate-types` runs post-merge.

export type GroupingRule =
	| { BySubnet: { title: string | null } }
	| { ByServiceCategory: { categories: string[]; title: string | null } }
	| { ByVirtualizingService: { title: string | null } }
	| { ByTag: { tag_ids: string[]; title: string | null } };

export type GroupingRuleType = 'BySubnet' | 'ByServiceCategory' | 'ByVirtualizingService' | 'ByTag';

export function getGroupingRuleType(rule: GroupingRule): GroupingRuleType {
	if ('BySubnet' in rule) return 'BySubnet';
	if ('ByServiceCategory' in rule) return 'ByServiceCategory';
	if ('ByVirtualizingService' in rule) return 'ByVirtualizingService';
	return 'ByTag';
}

export function getGroupingRuleTitle(rule: GroupingRule): string | null {
	if ('BySubnet' in rule) return rule.BySubnet.title;
	if ('ByServiceCategory' in rule) return rule.ByServiceCategory.title;
	if ('ByVirtualizingService' in rule) return rule.ByVirtualizingService.title;
	return rule.ByTag.title;
}

export function setGroupingRuleTitle(rule: GroupingRule, title: string | null): GroupingRule {
	if ('BySubnet' in rule) return { BySubnet: { ...rule.BySubnet, title } };
	if ('ByServiceCategory' in rule)
		return { ByServiceCategory: { ...rule.ByServiceCategory, title } };
	if ('ByVirtualizingService' in rule)
		return { ByVirtualizingService: { ...rule.ByVirtualizingService, title } };
	return { ByTag: { ...rule.ByTag, title } };
}
