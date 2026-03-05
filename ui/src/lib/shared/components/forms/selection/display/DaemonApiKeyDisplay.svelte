<script lang="ts" module>
	export const DaemonApiKeyDisplay: EntityDisplayComponent<DaemonApiKey, object> = {
		getId: (key) => key.id,
		getLabel: (key) => key.name,
		getDescription: (key) =>
			key.last_used ? `Last used ${formatTimestamp(key.last_used)}` : 'Never used',
		getIcon: () => entities.getIconComponent('DaemonApiKey'),
		getIconColor: () => entities.getColorHelper('DaemonApiKey').icon,
		getTags: (key) => [
			key.is_enabled
				? { label: 'Enabled', color: toColor('green') }
				: { label: 'Disabled', color: toColor('red') }
		],
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityDisplayComponent } from '../types';
	import type { DaemonApiKey } from '$lib/features/daemon_api_keys/types/base';
	import { entities } from '$lib/shared/stores/metadata';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { toColor } from '$lib/shared/utils/styling';

	interface Props {
		item: DaemonApiKey;
		context?: object;
	}

	let { item, context = {} }: Props = $props();
</script>

<ListSelectItem {item} {context} displayComponent={DaemonApiKeyDisplay} />
