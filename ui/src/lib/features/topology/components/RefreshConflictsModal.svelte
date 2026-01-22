<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import { AlertTriangle, Lock, RefreshCcw } from 'lucide-svelte';
	import type { Topology } from '../types/base';
	import InlineDanger from '$lib/shared/components/feedback/InlineDanger.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import EntityList from '$lib/shared/components/data/EntityList.svelte';
	import {
		common_cancel,
		common_entities,
		common_entity,
		common_groupsLabel,
		common_hosts,
		common_interfaces,
		common_lock,
		common_ports,
		common_rebuild,
		common_services,
		common_subnets,
		common_tip,
		topology_bindingsRemoved,
		topology_entitiesRemoved,
		topology_lockTipBody,
		topology_removedWarning,
		topology_reviewConflicts
	} from '$lib/paraglide/messages';

	export let isOpen: boolean;
	export let topology: Topology;
	export let onConfirm: () => void;
	export let onLock: () => void;
	export let onCancel: () => void;

	// Get removed entity details
	$: removedHosts = topology.removed_hosts
		.map((id) => topology.hosts.find((h) => h.id === id))
		.filter((h) => h != undefined);

	$: removedServices = topology.removed_services
		.map((id) => topology.services.find((s) => s.id === id))
		.filter((s) => s != undefined);

	$: removedSubnets = topology.removed_subnets
		.map((id) => topology.subnets.find((s) => s.id === id))
		.filter((s) => s != undefined);

	$: removedGroups = topology.removed_groups
		.map((id) => topology.groups.find((g) => g.id === id))
		.filter((g) => g != undefined);

	$: removedInterfaces = topology.removed_interfaces
		.map((id) => topology.interfaces.find((i) => i.id === id))
		.filter((i) => i != undefined);

	$: removedPorts = topology.removed_ports
		.map((id) => topology.ports.find((p) => p.id === id))
		.filter((p) => p != undefined);

	$: removedBindings = topology.removed_bindings
		.map((id) => topology.bindings.find((b) => b.id === id))
		.filter((b) => b != undefined);

	$: totalRemoved =
		removedHosts.length +
		removedServices.length +
		removedSubnets.length +
		removedGroups.length +
		removedInterfaces.length +
		removedPorts.length +
		removedBindings.length;

	// Build single list with category headers
	$: allRemovedEntities = (() => {
		const items = [];

		if (removedHosts.length > 0) {
			items.push({
				id: 'hosts-header',
				name: `${common_hosts()}: ${removedHosts.map((h) => h.name).join(', ')}`
			});
		}

		if (removedServices.length > 0) {
			items.push({
				id: 'services-header',
				name: `${common_services()}: ${removedServices.map((s) => s.name).join(', ')}`
			});
		}

		if (removedSubnets.length > 0) {
			items.push({
				id: 'subnets-header',
				name: `${common_subnets()}: ${removedSubnets.map((s) => s.name).join(', ')}`
			});
		}

		if (removedGroups.length > 0) {
			items.push({
				id: 'groups-header',
				name: `${common_groupsLabel()}: ${removedGroups.map((g) => g.name).join(', ')}`
			});
		}

		if (removedInterfaces.length > 0) {
			items.push({
				id: 'interfaces-header',
				name: `${common_interfaces()}: ${removedInterfaces.map((i) => i.ip_address).join(', ')}`
			});
		}

		if (removedPorts.length > 0) {
			items.push({
				id: 'ports-header',
				name: `${common_ports()}: ${removedPorts.map((p) => `${p.number}/${p.protocol}`).join(', ')}`
			});
		}

		if (removedBindings.length > 0) {
			items.push({
				id: 'bindings-header',
				name: topology_bindingsRemoved({ count: removedBindings.length })
			});
		}

		return items;
	})();
</script>

<GenericModal {isOpen} onClose={onCancel} title={topology_reviewConflicts()} size="lg">
	{#snippet headerIcon()}
		<AlertTriangle class="h-6 w-6 text-red-600 dark:text-red-400" />
	{/snippet}

	<div class="space-y-4 p-6">
		<!-- Warning header -->
		<InlineDanger
			title={topology_entitiesRemoved({
				count: totalRemoved,
				entity: totalRemoved === 1 ? common_entity() : common_entities()
			})}
			body={topology_removedWarning()}
		/>

		<!-- List removed entities -->
		<EntityList title="" items={allRemovedEntities} />

		<!-- Info box -->
		<InlineInfo title={common_tip()} body={topology_lockTipBody()} />
	</div>

	{#snippet footer()}
		<div class="modal-footer">
			<div class="flex w-full items-center justify-between">
				<button class="btn-secondary" on:click={onCancel}> {common_cancel()} </button>
				<div class="flex gap-3">
					<button class="btn-primary flex items-center gap-2" on:click={onLock}>
						<Lock class="h-4 w-4" />
						{common_lock()}
					</button>
					<button class="btn-danger flex items-center gap-2" on:click={onConfirm}>
						<RefreshCcw class="h-4 w-4" />
						{common_rebuild()}
					</button>
				</div>
			</div>
		</div>
	{/snippet}
</GenericModal>
