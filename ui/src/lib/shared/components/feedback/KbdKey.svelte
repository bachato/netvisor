<script lang="ts">
	interface Props {
		key: string;
		size?: 'sm' | 'md' | 'lg';
		class?: string;
	}

	let { key, size = 'md', class: className = '' }: Props = $props();

	const sizeClasses: Record<string, string> = {
		sm: 'min-w-5 h-5 px-1 text-[10px]',
		md: 'min-w-6 h-6 px-1.5 text-xs',
		lg: 'min-w-8 h-8 px-2 text-sm'
	};
</script>

<kbd
	class="inline-flex items-center justify-center rounded border border-gray-300 bg-gray-50 font-mono font-medium text-gray-600 shadow-[0_1px_0_1px_rgba(0,0,0,0.08)] dark:border-gray-600 dark:bg-gray-700 dark:text-gray-300 dark:shadow-[0_1px_0_1px_rgba(0,0,0,0.3)] {sizeClasses[
		size
	]} {className}"
>
	{key}
</kbd>
