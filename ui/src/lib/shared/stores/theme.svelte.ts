const STORAGE_KEY = 'scanopy-theme';

export type ThemeMode = 'system' | 'light' | 'dark';
export type ResolvedTheme = 'light' | 'dark';

let themeMode = $state<ThemeMode>('system');
let systemPrefersDark = $state(
	typeof window !== 'undefined' ? window.matchMedia('(prefers-color-scheme: dark)').matches : true
);

const resolvedTheme = $derived<ResolvedTheme>(
	themeMode === 'system' ? (systemPrefersDark ? 'dark' : 'light') : themeMode
);

// Initialize from localStorage and set up listeners (browser only)
if (typeof window !== 'undefined') {
	const stored = localStorage.getItem(STORAGE_KEY) as ThemeMode | null;
	if (stored === 'light' || stored === 'dark' || stored === 'system') {
		themeMode = stored;
	}

	// Update reactive state when OS preference changes
	window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
		systemPrefersDark = e.matches;
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
