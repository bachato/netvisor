<script lang="ts">
	import { useSubnetsQuery } from '$lib/features/subnets/queries';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import type { DockerDiscovery, NetworkDiscovery, SelfReportDiscovery } from '../../types/api';
	import type { Discovery } from '../../types/base';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { billingPlans, discoveryTypes, subnetTypes } from '$lib/shared/stores/metadata';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import { openModal } from '$lib/shared/stores/modal-registry';
	import { ArrowUpCircle } from 'lucide-svelte';

	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import {
		SimpleOptionDisplay,
		type SimpleOption
	} from '$lib/shared/components/forms/selection/display/SimpleOptionDisplay';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { generateDayTimeCronSchedule } from '../../queries';
	import type { AnyFieldApi } from '@tanstack/svelte-form';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import TimeInput from '$lib/shared/components/forms/input/TimeInput.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import {
		common_fri,
		common_ipAddress,
		common_mon,
		common_sat,
		common_sun,
		common_thu,
		common_time,
		common_timezone,
		common_tue,
		common_wed,
		discovery_adHoc,
		discovery_adHocDescription,
		discovery_allSubnetsScanned,
		discovery_bestService,
		discovery_configuration,
		discovery_daemonHostMissing,
		discovery_daemonHostMissingHelp,
		discovery_discoveryType,
		discovery_dockerScan,
		discovery_hostNameFallback,
		discovery_hostNameFallbackHelp,
		discovery_manualDiscovery,
		discovery_manualDiscoveryHelp,
		discovery_networkScan,
		discovery_nonInterfacedSubnet,
		discovery_nonInterfacedSubnetWarning,
		discovery_runType,
		discovery_scheduleCronExpression,
		discovery_scheduleCronInfo,
		discovery_scheduleConfiguration,
		discovery_scheduleDaysOfWeek,
		discovery_scheduleEditAsCron,
		discovery_scheduleHelp,
		discovery_scheduleResetToDayPicker,
		discovery_scheduleTimezoneHelp,
		discovery_scheduled,
		discovery_scheduledDescription,
		discovery_selectSubnet,
		discovery_selfReport,
		discovery_targetSubnets,
		discovery_targetSubnetsHelp
	} from '$lib/paraglide/messages';

	// Props
	interface Props {
		/* eslint-disable @typescript-eslint/no-explicit-any */
		form: any;
		/* eslint-enable @typescript-eslint/no-explicit-any */
		formData: Discovery;
		readOnly?: boolean;
		daemonHostId: string | null;
		daemon: Daemon;
		rawCronMode?: boolean;
	}

	let {
		form,
		formData = $bindable(),
		readOnly = false,
		daemonHostId,
		daemon,
		rawCronMode = $bindable(false)
	}: Props = $props();

	// Queries
	const organizationQuery = useOrganizationQuery();
	let org = $derived(organizationQuery.data);
	let hasScheduledDiscovery = $derived.by(() => {
		if (!org?.plan?.type) return true;
		return billingPlans.getMetadata(org.plan.type).features.scheduled_discovery;
	});

	const subnetsQuery = useSubnetsQuery();

	// Derived data
	let subnetsData = $derived(subnetsQuery.data ?? []);

	// Discovery type options
	let discoveryTypeOptions = $derived([
		{ value: 'Network', label: discovery_networkScan(), disabled: false },
		{
			value: 'Docker',
			label: discovery_dockerScan(),
			disabled: daemonHostId == null || !daemon.capabilities.has_docker_socket
		},
		{ value: 'SelfReport', label: discovery_selfReport(), disabled: daemonHostId == null }
	]);

	let hostNameFallbackOptions = $derived([
		{ value: 'Ip', label: common_ipAddress() },
		{ value: 'BestService', label: discovery_bestService() }
	]);

	let runTypeOptions: SimpleOption[] = $derived([
		{ value: 'AdHoc', label: discovery_adHoc() },
		{
			value: 'Scheduled',
			label: discovery_scheduled(),
			disabled: !hasScheduledDiscovery,
			tags: !hasScheduledDiscovery
				? [
						{
							label: 'Upgrade',
							color: 'Yellow',
							icon: ArrowUpCircle
						}
					]
				: []
		}
	]);

	// Day-of-week labels (index matches cron: 0=Sun, 1=Mon, ..., 6=Sat)
	// Each entry is called as a function to resolve the i18n string
	const dayLabels = [
		() => common_sun(),
		() => common_mon(),
		() => common_tue(),
		() => common_wed(),
		() => common_thu(),
		() => common_fri(),
		() => common_sat()
	];

	// Timezone options from browser
	let timezoneOptions = $derived(
		Intl.supportedValuesOf('timeZone').map((tz) => ({
			value: tz,
			label: tz
		}))
	);

	// Handle run type changes - update formData when form field changes
	function handleRunTypeChange(value: string) {
		if (value === 'AdHoc' && formData.run_type.type !== 'AdHoc') {
			formData.run_type = {
				type: 'AdHoc',
				last_run: null
			};
		} else if (value === 'Scheduled' && formData.run_type.type !== 'Scheduled') {
			formData.run_type = {
				type: 'Scheduled',
				cron_schedule: '0 0 0 * * *',
				last_run: null,
				enabled: true,
				timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
			};
			rawCronMode = false;
		}
	}

	// Handle discovery type changes - update formData when form field changes
	function handleDiscoveryTypeChange(value: string) {
		if (value === 'Network' && formData.discovery_type.type !== 'Network') {
			formData.discovery_type = {
				type: 'Network',
				subnet_ids: daemon.capabilities.interfaced_subnet_ids,
				host_naming_fallback: 'BestService',
				probe_raw_socket_ports: false
			} as NetworkDiscovery;
		} else if (value === 'Docker' && formData.discovery_type.type !== 'Docker') {
			formData.discovery_type = {
				type: 'Docker',
				host_id: daemonHostId,
				host_naming_fallback: 'BestService'
			} as DockerDiscovery;
		} else if (value === 'SelfReport' && formData.discovery_type.type !== 'SelfReport') {
			formData.discovery_type = {
				type: 'SelfReport',
				host_id: daemonHostId
			} as SelfReportDiscovery;
		}
	}

	// Handle host naming fallback changes
	function handleHostNameFallbackChange(value: string) {
		if (formData.discovery_type.type == 'Docker' || formData.discovery_type.type == 'Network') {
			if (formData.discovery_type.host_naming_fallback !== value) {
				formData.discovery_type = {
					...formData.discovery_type,
					host_naming_fallback: value as 'BestService' | 'Ip'
				};
			}
		}
	}

	// Update cron from day-of-week toggles + time
	function updateCronFromDayTime() {
		if (formData.run_type.type !== 'Scheduled') return;
		const daysStr: string = form.state.values.schedule_days_of_week ?? '0,1,2,3,4,5,6';
		const time: string = form.state.values.schedule_time ?? '00:00';
		const days = daysStr
			.split(',')
			.filter(Boolean)
			.map((d) => parseInt(d));
		const [hour, minute] = time.split(':').map((n) => parseInt(n));
		formData.run_type = {
			...formData.run_type,
			cron_schedule: generateDayTimeCronSchedule(
				days.length > 0 ? days : [0, 1, 2, 3, 4, 5, 6],
				hour || 0,
				minute || 0
			)
		};
	}

	// Handle timezone change
	function handleTimezoneChange(value: string) {
		if (formData.run_type.type === 'Scheduled') {
			formData.run_type = {
				...formData.run_type,
				timezone: value
			};
		}
	}

	// Handle raw cron change
	function handleRawCronChange(value: string) {
		if (formData.run_type.type === 'Scheduled') {
			formData.run_type = {
				...formData.run_type,
				cron_schedule: value
			};
		}
	}

	// Toggle day-of-week selection
	function toggleDay(field: AnyFieldApi, dayIndex: number) {
		if (readOnly) return;
		const current = ((field.state.value as string) ?? '0,1,2,3,4,5,6')
			.split(',')
			.filter(Boolean)
			.map(Number);
		let updated: number[];
		if (current.includes(dayIndex)) {
			if (current.length <= 1) return;
			updated = current.filter((d) => d !== dayIndex);
		} else {
			updated = [...current, dayIndex].sort((a, b) => a - b);
		}
		field.handleChange(updated.join(','));
		if (formData.run_type.type !== 'Scheduled') return;
		const time: string = form.state.values.schedule_time ?? '00:00';
		const [hour, minute] = time.split(':').map((n: string) => parseInt(n));
		formData.run_type = {
			...formData.run_type,
			cron_schedule: generateDayTimeCronSchedule(updated, hour || 0, minute || 0)
		};
	}

	// Helper to check if a day is selected
	function isDaySelected(field: AnyFieldApi, dayIndex: number): boolean {
		return ((field.state.value as string) ?? '0,1,2,3,4,5,6')
			.split(',')
			.filter(Boolean)
			.map(Number)
			.includes(dayIndex);
	}

	// Switch to raw cron mode
	function switchToRawCron() {
		rawCronMode = true;
	}

	// Reset to day picker mode
	function resetToDayPicker() {
		rawCronMode = false;
		// Reset to a standard day+time cron
		const time: string = form.state.values.schedule_time ?? '00:00';
		const [hour, minute] = time.split(':').map((n) => parseInt(n));
		const cron = generateDayTimeCronSchedule([0, 1, 2, 3, 4, 5, 6], hour || 0, minute || 0);
		form.setFieldValue('schedule_days_of_week', '0,1,2,3,4,5,6');
		if (formData.run_type.type === 'Scheduled') {
			formData.run_type = {
				...formData.run_type,
				cron_schedule: cron
			};
			form.setFieldValue('schedule_cron', cron);
		}
	}

	// Subnet management for Network
	let availableSubnets = $derived(
		subnetsData.filter(
			(s) =>
				formData.discovery_type.type === 'Network' &&
				s.network_id == formData.network_id &&
				!formData.discovery_type.subnet_ids?.includes(s.id) &&
				subnetTypes.getMetadata(s.subnet_type).network_scan_discovery_eligible
		)
	);

	let selectedSubnets = $derived(
		formData.discovery_type.type === 'Network' && formData.discovery_type.subnet_ids
			? formData.discovery_type.subnet_ids
					.map((id) => subnetsData.find((s) => s.id === id))
					.filter(Boolean)
			: []
	);

	let nonInterfacedSubnets = $derived(
		formData.discovery_type.type == 'Network' &&
			formData.discovery_type.subnet_ids &&
			formData.discovery_type.subnet_ids.length > 0
			? formData.discovery_type.subnet_ids
					.filter((s) => !daemon.capabilities.interfaced_subnet_ids.includes(s))
					.map((s) => subnetsData.find((subnet) => subnet.id == s))
					.filter((s) => s != undefined)
					.map((s) => s.name + ` (${s.cidr})`)
			: []
	);

	function handleAddSubnet(subnetId: string) {
		if (formData.discovery_type.type === 'Network') {
			const currentIds = formData.discovery_type.subnet_ids || [];
			formData.discovery_type = {
				...formData.discovery_type,
				subnet_ids: [...currentIds, subnetId]
			};
		}
	}

	function handleRemoveSubnet(index: number) {
		if (formData.discovery_type.type === 'Network' && formData.discovery_type.subnet_ids) {
			formData.discovery_type = {
				...formData.discovery_type,
				subnet_ids: formData.discovery_type.subnet_ids.filter((_, i) => i !== index)
			};
		}
	}

	// Services affected by raw socket port filtering
	let rawSocketServiceNames = $derived(
		(serviceDefinitions.getItems() ?? [])
			.filter((s) => s.metadata?.has_raw_socket_endpoint)
			.map((s) => s.name)
			.join(', ')
	);

	// Handle probe_raw_socket_ports toggle
	function handleProbeRawSocketPortsChange(value: boolean) {
		if (formData.discovery_type.type === 'Network') {
			formData.discovery_type = {
				...formData.discovery_type,
				probe_raw_socket_ports: value
			};
		}
	}
</script>

<div class="space-y-6">
	<div class="border-t border-gray-700 pt-6">
		<h3 class="text-primary mb-4 text-lg font-medium">{discovery_configuration()}</h3>

		<div class="space-y-4">
			<!-- Run Type Selection -->
			<form.Field
				name="run_type_type"
				listeners={{
					onChange: ({ value }: { value: string }) => handleRunTypeChange(value)
				}}
			>
				{#snippet children(field: AnyFieldApi)}
					<RichSelect
						label={discovery_runType()}
						selectedValue={field.state.value}
						options={runTypeOptions}
						onSelect={(value) => field.handleChange(value)}
						onDisabledClick={() => openModal('billing-plan')}
						displayComponent={SimpleOptionDisplay}
						disabled={readOnly}
					/>
					<p class="text-tertiary mt-1 text-xs">
						{field.state.value === 'AdHoc'
							? discovery_adHocDescription()
							: discovery_scheduledDescription()}
					</p>
				{/snippet}
			</form.Field>

			<!-- Discovery Type Selection -->
			<form.Field
				name="discovery_type_type"
				listeners={{
					onChange: ({ value }: { value: string }) => handleDiscoveryTypeChange(value)
				}}
			>
				{#snippet children(field: AnyFieldApi)}
					<SelectInput
						label={discovery_discoveryType()}
						id="discovery_type"
						options={discoveryTypeOptions}
						{field}
						disabled={readOnly}
					/>
					<p class="text-tertiary mt-1 text-xs">
						{discoveryTypes.getDescription(field.state.value)}
					</p>
				{/snippet}
			</form.Field>

			{#if daemonHostId == null}
				<InlineWarning
					title={discovery_daemonHostMissing()}
					body={discovery_daemonHostMissingHelp()}
				/>
			{/if}

			<!-- Type-specific configuration -->
			{#if formData.discovery_type.type == 'Docker' || formData.discovery_type.type == 'Network'}
				<form.Field
					name="host_naming_fallback"
					listeners={{
						onChange: ({ value }: { value: string }) => handleHostNameFallbackChange(value)
					}}
				>
					{#snippet children(field: AnyFieldApi)}
						<SelectInput
							label={discovery_hostNameFallback()}
							id="host_name_fallback"
							options={hostNameFallbackOptions}
							{field}
							disabled={readOnly}
							helpText={discovery_hostNameFallbackHelp()}
						/>
					{/snippet}
				</form.Field>
			{/if}

			{#if formData.discovery_type.type === 'Network'}
				<div class="rounded-lg bg-gray-800/50 p-4">
					<ListManager
						label={discovery_targetSubnets()}
						helpText={discovery_targetSubnetsHelp()}
						placeholder={discovery_selectSubnet()}
						emptyMessage={discovery_allSubnetsScanned()}
						allowReorder={false}
						allowItemEdit={() => false}
						showSearch={true}
						options={availableSubnets}
						items={selectedSubnets}
						optionDisplayComponent={SubnetDisplay}
						itemDisplayComponent={SubnetDisplay}
						onAdd={handleAddSubnet}
						onRemove={handleRemoveSubnet}
					/>
				</div>
				{#if nonInterfacedSubnets.length > 0}
					<InlineWarning
						title={discovery_nonInterfacedSubnet()}
						body={discovery_nonInterfacedSubnetWarning({
							subnets: nonInterfacedSubnets.join('\n')
						})}
					/>
				{/if}
				<form.Field
					name="probe_raw_socket_ports"
					listeners={{
						onChange: ({ value }: { value: boolean }) => handleProbeRawSocketPortsChange(value)
					}}
				>
					{#snippet children(field: AnyFieldApi)}
						<Checkbox
							label="Probe raw socket ports (9100-9107)"
							id="probe_raw_socket_ports"
							{field}
							disabled={readOnly}
							helpText={rawSocketServiceNames
								? `May cause ghost printing on JetDirect printers. Required to detect: ${rawSocketServiceNames}`
								: 'May cause ghost printing on JetDirect printers'}
						/>
					{/snippet}
				</form.Field>
			{/if}
		</div>
	</div>

	<!-- Schedule Configuration (only for scheduled runs) -->
	{#if formData.run_type.type === 'Scheduled'}
		<div class="border-t border-gray-700 pt-6">
			<h3 class="text-primary mb-4 text-lg font-medium">{discovery_scheduleConfiguration()}</h3>

			<div class="space-y-4">
				<p class="text-tertiary text-sm">
					{discovery_scheduleHelp()}
				</p>

				{#if rawCronMode}
					<!-- Raw Cron Mode -->
					<form.Field
						name="schedule_cron"
						listeners={{
							onChange: ({ value }: { value: string }) => handleRawCronChange(value)
						}}
					>
						{#snippet children(field: AnyFieldApi)}
							<TextInput
								label={discovery_scheduleCronExpression()}
								id="schedule_cron"
								{field}
								disabled={readOnly}
								placeholder="0 0 0 * * *"
							/>
						{/snippet}
					</form.Field>

					<InlineInfo
						title={discovery_scheduleCronExpression()}
						body={discovery_scheduleCronInfo()}
					/>

					<button
						type="button"
						class="text-sm text-blue-400 hover:text-blue-300"
						onclick={resetToDayPicker}
						disabled={readOnly}
					>
						{discovery_scheduleResetToDayPicker()}
					</button>
				{:else}
					<!-- Day Picker Mode -->
					<form.Field name="schedule_days_of_week">
						{#snippet children(field: AnyFieldApi)}
							<div>
								<label class="text-secondary mb-2 block text-sm font-medium">
									{discovery_scheduleDaysOfWeek()}
								</label>
								<div class="flex gap-1">
									{#each [1, 2, 3, 4, 5, 6, 0] as dayIndex (dayIndex)}
										<button
											type="button"
											class="{isDaySelected(field, dayIndex)
												? 'btn-info'
												: 'btn-secondary'} px-3 py-1.5 text-sm"
											disabled={readOnly}
											onclick={() => toggleDay(field, dayIndex)}
										>
											{dayLabels[dayIndex]()}
										</button>
									{/each}
								</div>
							</div>
						{/snippet}
					</form.Field>

					<form.Field
						name="schedule_time"
						listeners={{
							onChange: () => updateCronFromDayTime()
						}}
					>
						{#snippet children(field: AnyFieldApi)}
							<TimeInput label={common_time()} id="schedule_time" {field} disabled={readOnly} />
						{/snippet}
					</form.Field>

					<button
						type="button"
						class="text-sm text-blue-400 hover:text-blue-300"
						onclick={switchToRawCron}
						disabled={readOnly}
					>
						{discovery_scheduleEditAsCron()}
					</button>
				{/if}

				<!-- Timezone (shown in both modes) -->
				<form.Field
					name="schedule_timezone"
					listeners={{
						onChange: ({ value }: { value: string }) => handleTimezoneChange(value)
					}}
				>
					{#snippet children(field: AnyFieldApi)}
						<SelectInput
							label={common_timezone()}
							id="schedule_timezone"
							options={timezoneOptions}
							{field}
							disabled={readOnly}
							helpText={discovery_scheduleTimezoneHelp()}
						/>
					{/snippet}
				</form.Field>
			</div>
		</div>
	{:else if formData.run_type.type === 'AdHoc'}
		<div class="border-t border-gray-700 pt-6">
			<div class="rounded-lg bg-gray-800/50 p-4">
				<div class="flex items-start gap-3">
					<svg
						class="mt-0.5 h-5 w-5 flex-shrink-0 text-gray-400"
						fill="none"
						stroke="currentColor"
						viewBox="0 0 24 24"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
						/>
					</svg>
					<div>
						<h4 class="mb-1 text-sm font-medium text-gray-300">{discovery_manualDiscovery()}</h4>
						<p class="text-sm text-gray-400">
							{discovery_manualDiscoveryHelp()}
						</p>
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
