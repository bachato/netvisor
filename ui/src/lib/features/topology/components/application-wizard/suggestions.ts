/**
 * Suggested application group names based on organization use case.
 */
export const USE_CASE_SUGGESTIONS: Record<string, string[]> = {
	homelab: [
		'Media Stack',
		'Home Automation',
		'Monitoring',
		'Network Infrastructure',
		'Development',
		'Smart Home'
	],
	company: ['Production', 'Staging', 'Internal Tools', 'Monitoring', 'CI/CD', 'Shared Services'],
	msp: ['Shared Infrastructure', 'Monitoring']
};

export const DEFAULT_SUGGESTIONS = [
	'Web Services',
	'Database',
	'Monitoring',
	'Storage',
	'Infrastructure'
];

export function getSuggestions(useCase: string | null | undefined): string[] {
	if (useCase && useCase in USE_CASE_SUGGESTIONS) {
		return USE_CASE_SUGGESTIONS[useCase];
	}
	return DEFAULT_SUGGESTIONS;
}
