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
		common_dependenciesLabel,
		common_hosts,
		common_ipAddresses,
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

	// Use removed_* array lengths directly for total count — these are always
	// accurate even when entities are hidden by server-side filters
	$: totalRemoved =
		topology.removed_hosts.length +
		topology.removed_services.length +
		topology.removed_subnets.length +
		topology.removed_dependencies.length +
		topology.removed_interfaces.length +
		topology.removed_ports.length +
		topology.removed_bindings.length;

	// Resolved entities (for display names)
	$: removedHosts = topology.removed_hosts
		.map((id) => topology.hosts.find((h) => h.id === id))
		.filter((h) => h != undefined);
	$: unresolvedHostCount = topology.removed_hosts.length - removedHosts.length;

	$: removedServices = topology.removed_services
		.map((id) => topology.services.find((s) => s.id === id))
		.filter((s) => s != undefined);
	$: unresolvedServiceCount = topology.removed_services.length - removedServices.length;

	$: removedSubnets = topology.removed_subnets
		.map((id) => topology.subnets.find((s) => s.id === id))
		.filter((s) => s != undefined);
	$: unresolvedSubnetCount = topology.removed_subnets.length - removedSubnets.length;

	$: removedGroups = topology.removed_dependencies
		.map((id) => topology.dependencies.find((g) => g.id === id))
		.filter((g) => g != undefined);
	$: unresolvedGroupCount = topology.removed_dependencies.length - removedGroups.length;

	$: removedInterfaces = topology.removed_interfaces
		.map((id) => topology.interfaces.find((i) => i.id === id))
		.filter((i) => i != undefined);
	$: unresolvedInterfaceCount = topology.removed_interfaces.length - removedInterfaces.length;

	$: removedPorts = topology.removed_ports
		.map((id) => topology.ports.find((p) => p.id === id))
		.filter((p) => p != undefined);
	$: unresolvedPortCount = topology.removed_ports.length - removedPorts.length;

	$: removedBindings = topology.removed_bindings
		.map((id) => topology.bindings.find((b) => b.id === id))
		.filter((b) => b != undefined);
	$: unresolvedBindingCount = topology.removed_bindings.length - removedBindings.length;

	// Build single list with category headers, including unresolved counts
	$: allRemovedEntities = (() => {
		const items: { id: string; name: string }[] = [];

		if (removedHosts.length > 0 || unresolvedHostCount > 0) {
			const names = removedHosts.map((h) => h.name);
			if (unresolvedHostCount > 0) names.push(`(+${unresolvedHostCount} hidden by filters)`);
			items.push({ id: 'hosts-header', name: `${common_hosts()}: ${names.join(', ')}` });
		}

		if (removedServices.length > 0 || unresolvedServiceCount > 0) {
			const names = removedServices.map((s) => s.name);
			if (unresolvedServiceCount > 0) names.push(`(+${unresolvedServiceCount} hidden by filters)`);
			items.push({ id: 'services-header', name: `${common_services()}: ${names.join(', ')}` });
		}

		if (removedSubnets.length > 0 || unresolvedSubnetCount > 0) {
			const names = removedSubnets.map((s) => s.name);
			if (unresolvedSubnetCount > 0) names.push(`(+${unresolvedSubnetCount} hidden by filters)`);
			items.push({ id: 'subnets-header', name: `${common_subnets()}: ${names.join(', ')}` });
		}

		if (removedGroups.length > 0 || unresolvedGroupCount > 0) {
			const names = removedGroups.map((g) => g.name);
			if (unresolvedGroupCount > 0) names.push(`(+${unresolvedGroupCount} hidden by filters)`);
			items.push({
				id: 'groups-header',
				name: `${common_dependenciesLabel()}: ${names.join(', ')}`
			});
		}

		if (removedInterfaces.length > 0 || unresolvedInterfaceCount > 0) {
			const names = removedInterfaces.map((i) => i.ip_address);
			if (unresolvedInterfaceCount > 0)
				names.push(`(+${unresolvedInterfaceCount} hidden by filters)`);
			items.push({
				id: 'interfaces-header',
				name: `${common_ipAddresses()}: ${names.join(', ')}`
			});
		}

		if (removedPorts.length > 0 || unresolvedPortCount > 0) {
			const names = removedPorts.map((p) => `${p.number}/${p.protocol}`);
			if (unresolvedPortCount > 0) names.push(`(+${unresolvedPortCount} hidden by filters)`);
			items.push({ id: 'ports-header', name: `${common_ports()}: ${names.join(', ')}` });
		}

		if (removedBindings.length > 0 || unresolvedBindingCount > 0) {
			const total = removedBindings.length + unresolvedBindingCount;
			items.push({
				id: 'bindings-header',
				name: topology_bindingsRemoved({ count: total })
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
