/**
 * Format an estimated remaining time in seconds into a human-readable string.
 */
export function formatEstimatedRemaining(secs: number): string {
	if (secs < 60) {
		return 'less than a minute';
	}

	const minutes = Math.round(secs / 60);

	if (minutes === 1) {
		return 'about 1 minute';
	}

	if (minutes < 60) {
		return `about ${minutes} minutes`;
	}

	const hours = Math.floor(minutes / 60);
	const remainingMinutes = minutes % 60;

	if (hours === 1) {
		if (remainingMinutes === 0) {
			return 'about 1 hour';
		}
		return `about 1 hour ${remainingMinutes} minutes`;
	}

	if (remainingMinutes === 0) {
		return `about ${hours} hours`;
	}

	return `about ${hours} hours ${remainingMinutes} minutes`;
}
