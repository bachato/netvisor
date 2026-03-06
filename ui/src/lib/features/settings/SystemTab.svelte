<script lang="ts">
	import { Monitor, Sun, Moon } from 'lucide-svelte';
	import { themeStore } from '$lib/shared/stores/theme.svelte';
	import {
		common_system,
		common_theme,
		common_light,
		common_dark,
		settings_system_themeDesc,
		settings_system_themeSystemDesc,
		settings_system_themeLightDesc,
		settings_system_themeDarkDesc
	} from '$lib/paraglide/messages';

	const options = [
		{
			id: 'system' as const,
			label: common_system(),
			description: settings_system_themeSystemDesc(),
			icon: Monitor
		},
		{
			id: 'light' as const,
			label: common_light(),
			description: settings_system_themeLightDesc(),
			icon: Sun
		},
		{
			id: 'dark' as const,
			label: common_dark(),
			description: settings_system_themeDarkDesc(),
			icon: Moon
		}
	];
</script>

<div class="flex flex-col gap-6 overflow-y-auto p-6">
	<div>
		<h3 class="text-primary text-sm font-semibold">{common_theme()}</h3>
		<p class="text-tertiary mt-1 text-sm">{settings_system_themeDesc()}</p>
	</div>

	<div class="flex flex-col gap-2">
		{#each options as option}
			<button
				class="list-item-hover flex list-item items-center gap-4 text-left {themeStore.themeMode ===
				option.id
					? 'list-item-selected'
					: ''}"
				onclick={() => themeStore.setTheme(option.id)}
			>
				<div class="text-tertiary flex-shrink-0">
					<option.icon size={20} />
				</div>
				<div>
					<div class="text-primary text-sm font-medium">{option.label}</div>
					<div class="text-tertiary text-xs">{option.description}</div>
				</div>
			</button>
		{/each}
	</div>
</div>
