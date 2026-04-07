<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import type { ElementRenderContext } from '$lib/features/topology/resolvers';
	import {
		common_interfaces,
		inspector_otherInterface,
		inspector_otherInterfaces
	} from '$lib/paraglide/messages';

	/* eslint-disable @typescript-eslint/no-unused-vars -- component contract props */
	let {
		node,
		topology,
		elementContext
	}: {
		node: Node;
		topology: Topology;
		elementContext?: ElementRenderContext;
	} = $props();
	/* eslint-enable @typescript-eslint/no-unused-vars */

	let isInterfaceElement = $derived(!!elementContext?.interfaceId);

	let otherInterfaces = $derived(
		topology.interfaces.filter(
			(i) =>
				i.host_id === elementContext?.hostId &&
				(!isInterfaceElement || i.id !== elementContext?.interfaceId)
		)
	);

	let interfaceContext = $derived({ subnets: topology.subnets });
</script>

{#if otherInterfaces.length > 0}
	<div>
		<span class="text-secondary mb-2 block text-sm font-medium">
			{isInterfaceElement
				? otherInterfaces.length > 1
					? inspector_otherInterfaces()
					: inspector_otherInterface()
				: common_interfaces()}
		</span>
		<div class="space-y-1">
			{#each otherInterfaces as iface (iface.id)}
				<div class="card card-static">
					<EntityDisplayWrapper
						context={interfaceContext}
						item={iface}
						displayComponent={InterfaceDisplay}
					/>
				</div>
			{/each}
		</div>
	</div>
{/if}
