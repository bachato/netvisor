import type { components } from '$lib/api/schema';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import {
	common_unknown,
	snmp_adminStatusDown,
	snmp_adminStatusTesting,
	snmp_adminStatusUp,
	snmp_operStatusDormant,
	snmp_operStatusDown,
	snmp_operStatusLowerLayerDown,
	snmp_operStatusNotPresent,
	snmp_operStatusTesting,
	snmp_operStatusUp
} from '$lib/paraglide/messages';

export type SnmpCredential = components['schemas']['SnmpCredential'];
export type SnmpCredentialBase = components['schemas']['SnmpCredentialBase'];
export type SnmpVersion = components['schemas']['SnmpVersion'];
export type IfEntry = components['schemas']['IfEntry'];
export type IfAdminStatus = components['schemas']['IfAdminStatus'];
export type IfOperStatus = components['schemas']['IfOperStatus'];

export function createDefaultSnmpCredential(organization_id: string): SnmpCredential {
	return {
		name: '',
		version: 'V2c',
		community: '',
		organization_id,
		tags: [],
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel
	};
}

/**
 * Get human-readable labels for SNMP admin status
 */
export function getAdminStatusLabels(): Record<IfAdminStatus, string> {
	return {
		Up: snmp_adminStatusUp(),
		Down: snmp_adminStatusDown(),
		Testing: snmp_adminStatusTesting()
	};
}

/**
 * Get human-readable labels for SNMP operational status
 */
export function getOperStatusLabels(): Record<IfOperStatus, string> {
	return {
		Up: snmp_operStatusUp(),
		Down: snmp_operStatusDown(),
		Testing: snmp_operStatusTesting(),
		Unknown: common_unknown(),
		Dormant: snmp_operStatusDormant(),
		NotPresent: snmp_operStatusNotPresent(),
		LowerLayerDown: snmp_operStatusLowerLayerDown()
	};
}

/**
 * Human-readable labels for SNMP admin status
 * @deprecated Use getAdminStatusLabels() instead for proper i18n support
 */
export const ADMIN_STATUS_LABELS: Record<IfAdminStatus, string> = {
	Up: 'Admin Up',
	Down: 'Admin Down',
	Testing: 'Testing'
};

/**
 * Human-readable labels for SNMP operational status
 * @deprecated Use getOperStatusLabels() instead for proper i18n support
 */
export const OPER_STATUS_LABELS: Record<IfOperStatus, string> = {
	Up: 'Up',
	Down: 'Down',
	Testing: 'Testing',
	Unknown: 'Unknown',
	Dormant: 'Dormant',
	NotPresent: 'Not Present',
	LowerLayerDown: 'Lower Layer Down'
};
