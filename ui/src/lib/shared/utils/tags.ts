/**
 * Compute the intersection of tags across multiple items.
 * Returns tags that ALL items share.
 */
export function computeCommonTags(items: { tags: string[] }[]): string[] {
	if (items.length === 0) return [];
	let common = new Set(items[0].tags);
	for (let i = 1; i < items.length; i++) {
		const itemTags = new Set(items[i].tags);
		common = new Set([...common].filter((tag) => itemTags.has(tag)));
	}
	return Array.from(common);
}
