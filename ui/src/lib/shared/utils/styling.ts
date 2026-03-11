import * as LucideIcons from 'lucide-svelte';
import type { IconComponent } from './types';
import colors from 'tailwindcss/colors';
import LogoIcon from '$lib/shared/components/data/LogoIcon.svelte';
import type { components } from '$lib/api/schema';

// Use the generated Color type from OpenAPI schema
export type Color = components['schemas']['Color'];

export interface ColorStyle {
	text: string;
	bg: string;
	border: string;
	icon: string;
	ring: string;
	stroke: string;
	color: Color;
	rgb: string; // Added RGB value
}

// Unified color map using dark: variants — Tailwind handles light/dark switching automatically.
// The rgb values use the -500 shade as a middle ground visible on both light and dark backgrounds.
export const COLOR_MAP: Record<Color, ColorStyle> = {
	Pink: {
		color: 'Pink',
		text: 'text-pink-600 dark:text-pink-400',
		bg: 'bg-pink-100 border-pink-300 dark:bg-pink-900/50 dark:border-pink-600',
		border: 'border-pink-300 dark:border-pink-600',
		icon: 'text-pink-600 dark:text-pink-400',
		ring: 'ring-pink-400',
		stroke: 'stroke-pink-600 dark:stroke-pink-400',
		rgb: 'rgb(236, 72, 153)' // pink-500
	},
	Rose: {
		color: 'Rose',
		text: 'text-rose-600 dark:text-rose-400',
		bg: 'bg-rose-100 border-rose-300 dark:bg-rose-900/50 dark:border-rose-600',
		border: 'border-rose-300 dark:border-rose-600',
		icon: 'text-rose-600 dark:text-rose-400',
		ring: 'ring-rose-400',
		stroke: 'stroke-rose-600 dark:stroke-rose-400',
		rgb: 'rgb(244, 63, 94)' // rose-500
	},
	Red: {
		color: 'Red',
		text: 'text-red-600 dark:text-red-400',
		bg: 'bg-red-100 border-red-300 dark:bg-red-900/50 dark:border-red-600',
		border: 'border-red-300 dark:border-red-600',
		icon: 'text-red-600 dark:text-red-400',
		ring: 'ring-red-400',
		stroke: 'stroke-red-600 dark:stroke-red-400',
		rgb: 'rgb(239, 68, 68)' // red-500
	},
	Orange: {
		color: 'Orange',
		text: 'text-orange-600 dark:text-orange-400',
		bg: 'bg-orange-100 border-orange-300 dark:bg-orange-900/50 dark:border-orange-600',
		border: 'border-orange-300 dark:border-orange-600',
		icon: 'text-orange-600 dark:text-orange-400',
		ring: 'ring-orange-400',
		stroke: 'stroke-orange-600 dark:stroke-orange-400',
		rgb: 'rgb(249, 115, 22)' // orange-500
	},
	Yellow: {
		color: 'Yellow',
		text: 'text-yellow-600 dark:text-yellow-400',
		bg: 'bg-yellow-100 border-yellow-300 dark:bg-yellow-900/50 dark:border-yellow-600',
		border: 'border-yellow-300 dark:border-yellow-600',
		icon: 'text-yellow-600 dark:text-yellow-400',
		ring: 'ring-yellow-400',
		stroke: 'stroke-yellow-600 dark:stroke-yellow-400',
		rgb: 'rgb(234, 179, 8)' // yellow-500
	},
	Green: {
		color: 'Green',
		text: 'text-green-600 dark:text-green-400',
		bg: 'bg-green-100 border-green-300 dark:bg-green-900/50 dark:border-green-600',
		border: 'border-green-300 dark:border-green-600',
		icon: 'text-green-600 dark:text-green-400',
		ring: 'ring-green-400',
		stroke: 'stroke-green-600 dark:stroke-green-400',
		rgb: 'rgb(34, 197, 94)' // green-500
	},
	Emerald: {
		color: 'Emerald',
		text: 'text-emerald-600 dark:text-emerald-400',
		bg: 'bg-emerald-100 border-emerald-300 dark:bg-emerald-900/50 dark:border-emerald-600',
		border: 'border-emerald-300 dark:border-emerald-600',
		icon: 'text-emerald-600 dark:text-emerald-400',
		ring: 'ring-emerald-400',
		stroke: 'stroke-emerald-600 dark:stroke-emerald-400',
		rgb: 'rgb(16, 185, 129)' // emerald-500
	},
	Teal: {
		color: 'Teal',
		text: 'text-teal-600 dark:text-teal-400',
		bg: 'bg-teal-100 border-teal-300 dark:bg-teal-900/50 dark:border-teal-600',
		border: 'border-teal-300 dark:border-teal-600',
		icon: 'text-teal-600 dark:text-teal-400',
		ring: 'ring-teal-400',
		stroke: 'stroke-teal-600 dark:stroke-teal-400',
		rgb: 'rgb(20, 184, 166)' // teal-500
	},
	Cyan: {
		color: 'Cyan',
		text: 'text-cyan-600 dark:text-cyan-400',
		bg: 'bg-cyan-100 border-cyan-300 dark:bg-cyan-900/50 dark:border-cyan-600',
		border: 'border-cyan-300 dark:border-cyan-600',
		icon: 'text-cyan-600 dark:text-cyan-400',
		ring: 'ring-cyan-400',
		stroke: 'stroke-cyan-600 dark:stroke-cyan-400',
		rgb: 'rgb(6, 182, 212)' // cyan-500
	},
	Blue: {
		color: 'Blue',
		text: 'text-blue-600 dark:text-blue-400',
		bg: 'bg-blue-100 border-blue-300 dark:bg-blue-900/50 dark:border-blue-600',
		border: 'border-blue-300 dark:border-blue-600',
		icon: 'text-blue-600 dark:text-blue-400',
		ring: 'ring-blue-400',
		stroke: 'stroke-blue-600 dark:stroke-blue-400',
		rgb: 'rgb(59, 130, 246)' // blue-500
	},
	Indigo: {
		color: 'Indigo',
		text: 'text-indigo-600 dark:text-indigo-400',
		bg: 'bg-indigo-100 border-indigo-300 dark:bg-indigo-900/50 dark:border-indigo-600',
		border: 'border-indigo-300 dark:border-indigo-600',
		icon: 'text-indigo-600 dark:text-indigo-400',
		ring: 'ring-indigo-400',
		stroke: 'stroke-indigo-600 dark:stroke-indigo-400',
		rgb: 'rgb(99, 102, 241)' // indigo-500
	},
	Purple: {
		color: 'Purple',
		text: 'text-purple-600 dark:text-purple-400',
		bg: 'bg-purple-100 border-purple-300 dark:bg-purple-900/50 dark:border-purple-600',
		border: 'border-purple-300 dark:border-purple-600',
		icon: 'text-purple-600 dark:text-purple-400',
		ring: 'ring-purple-400',
		stroke: 'stroke-purple-600 dark:stroke-purple-400',
		rgb: 'rgb(168, 85, 247)' // purple-500
	},
	Gray: {
		color: 'Gray',
		text: 'text-gray-600 dark:text-gray-400',
		bg: 'bg-gray-200 border-gray-300 dark:bg-gray-900/50 dark:border-gray-600',
		border: 'border-gray-300 dark:border-gray-600',
		icon: 'text-gray-600 dark:text-gray-400',
		ring: 'ring-gray-400',
		stroke: 'stroke-gray-600 dark:stroke-gray-400',
		rgb: 'rgb(107, 114, 128)' // gray-500
	}
};

// Export available colors array derived from COLOR_MAP keys
export const AVAILABLE_COLORS = Object.keys(COLOR_MAP) as Color[];

// Convert a string to a validated Color, with fallback to 'gray'
export function toColor(value: string | null | undefined): Color {
	if (!value) return 'Gray';
	else {
		const upperValue = value.charAt(0).toUpperCase() + value.slice(1);
		return AVAILABLE_COLORS.includes(upperValue as Color) ? (upperValue as Color) : 'Gray';
	}
}

// Unified color helper - uses dark: variants so Tailwind handles theme switching
export function createColorHelper(colorName: Color | null): ColorStyle {
	const color = colorName && COLOR_MAP[colorName] ? colorName : 'Gray';
	return COLOR_MAP[color];
}

// Icon helper that converts string to component
export function createIconComponent(iconName: string | null): IconComponent {
	if (!iconName || iconName == null) return LucideIcons.HelpCircle;

	// Convert kebab-case to PascalCase for Lucide component names
	const componentName = iconName
		.split('-')
		.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
		.join('');

	// Return the component or fallback
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	return (LucideIcons as any)[componentName] || LucideIcons.HelpCircle;
}

// Icon helper that turns a string into an SVG
export function createLogoIconComponent(
	iconName: string | null,
	iconUrl: string,
	useWhiteBackground: boolean = false
): IconComponent {
	if (!iconName || iconName == null) return LucideIcons.HelpCircle;

	// Create a wrapper component that pre-binds the iconName
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const BoundLogoIcon = ($$payload: any, $$props: Omit<any, 'iconName'>) => {
		return LogoIcon($$payload, { iconName, iconUrl, useWhiteBackground, ...$$props });
	};

	return BoundLogoIcon;
}

// Convenience wrapper that returns both color and icon
export function createStyle(color: Color | null, icon: string | null) {
	return {
		colors: createColorHelper(color),
		IconComponent: createIconComponent(icon),
		iconName: icon
	};
}

/**
 * Converts a Tailwind color string (e.g. "text-blue-400", "bg-blue-900/50", "blue-500")
 * to an rgba() string with optional alpha override.
 */
export function twColorToRgba(twColor: string, alphaOverride?: number): string {
	const match = twColor.match(/([a-zA-Z]+)-(\d{2,3})(?:\/(\d{1,3}))?/);
	if (!match) return 'rgba(0,0,0,0)';

	const [, colorName, shade, opacityRaw] = match;

	const palette = (colors as unknown as Record<string, Record<number, string>>)[colorName];
	if (!palette) return 'rgba(0,0,0,0)';

	const hex = palette[parseInt(shade)];
	if (!hex) return 'rgba(0,0,0,0)';

	const alpha =
		typeof alphaOverride === 'number'
			? alphaOverride
			: opacityRaw
				? parseInt(opacityRaw, 10) / 100
				: 1;

	return hexToRgba(hex, alpha);
}

function hexToRgba(hex: string, alpha = 1): string {
	const cleanHex = hex.replace('#', '');
	const bigint = parseInt(cleanHex, 16);
	const r = (bigint >> 16) & 255;
	const g = (bigint >> 8) & 255;
	const b = bigint & 255;
	return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}
