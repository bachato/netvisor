const STORAGE_KEY = 'scanopy-theme';

export type ThemeMode = 'system' | 'light' | 'dark';
export type ResolvedTheme = 'light' | 'dark';

let themeMode = $state<ThemeMode>('system');

function getSystemTheme(): ResolvedTheme {
	if (typeof window === 'undefined') return 'dark';
	return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

let resolvedTheme = $derived<ResolvedTheme>(themeMode === 'system' ? getSystemTheme() : themeMode);

// Initialize from localStorage and set up listeners (browser only)
if (typeof window !== 'undefined') {
	const stored = localStorage.getItem(STORAGE_KEY) as ThemeMode | null;
	if (stored === 'light' || stored === 'dark' || stored === 'system') {
		themeMode = stored;
	}

	// Re-evaluate when OS preference changes
	window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
		// Trigger reactivity by re-assigning when in system mode
		if (themeMode === 'system') {
			themeMode = 'system';
		}
	});

	// Apply theme to DOM whenever resolvedTheme changes
	$effect.root(() => {
		$effect(() => {
			document.documentElement.classList.toggle('dark', resolvedTheme === 'dark');
			document.documentElement.style.colorScheme = resolvedTheme;
		});
	});
}

export function setTheme(mode: ThemeMode) {
	themeMode = mode;
	localStorage.setItem(STORAGE_KEY, mode);
}

export function getThemeMode(): ThemeMode {
	return themeMode;
}

export function getResolvedTheme(): ResolvedTheme {
	return resolvedTheme;
}

export const themeStore = {
	get themeMode() {
		return themeMode;
	},
	get resolvedTheme() {
		return resolvedTheme;
	},
	setTheme
};
