<script lang="ts">
	import { topologyOptions } from '$lib/features/topology/queries';

	let {
		label,
		helpText = '',
		path,
		optionKey
	}: {
		label: string;
		helpText?: string;
		path: 'local' | 'request';
		optionKey: string;
	} = $props();

	let checked = $derived(
		path === 'local'
			? !!($topologyOptions.local as Record<string, unknown>)[optionKey]
			: !!($topologyOptions.request as Record<string, unknown>)[optionKey]
	);

	function toggle() {
		topologyOptions.update((opts) => {
			if (path === 'local') {
				// eslint-disable-next-line @typescript-eslint/no-explicit-any
				(opts.local as any)[optionKey] = !checked;
			} else {
				// eslint-disable-next-line @typescript-eslint/no-explicit-any
				(opts.request as any)[optionKey] = !checked;
			}
			return opts;
		});
	}
</script>

<div>
	<label class="flex cursor-pointer items-center gap-2">
		<input type="checkbox" class="checkbox-card h-4 w-4" {checked} onchange={toggle} />
		<span class="text-secondary text-sm">{label}</span>
	</label>
	{#if helpText}
		<p class="text-tertiary ml-6 mt-1 text-xs">{helpText}</p>
	{/if}
</div>
