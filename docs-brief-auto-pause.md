# Auto-Pause for Scheduled Scans

## What is auto-pause?

Auto-pause is a safeguard that automatically disables a scheduled scan after it fails three times in a row due to session stalls. This prevents scans from repeatedly running against daemons that are offline, uninstalled, or otherwise unable to complete work.

## How it works

1. Each scheduled discovery tracks a `consecutive_failures` counter.
2. When a scan session stalls (no progress for 5 minutes), the server terminates it as "Failed" and increments the counter.
3. When the counter reaches **3**, the scheduled discovery is automatically disabled ("auto-paused") and the cron job is removed from the scheduler.
4. The organization owner receives an email notification explaining the pause and linking to daemon troubleshooting.
5. When a scan completes successfully, the counter resets to 0.

Only **stall failures** count toward auto-pause. Daemon-reported errors and user-initiated cancellations do not increment the counter.

## Common causes

- **Daemon offline or uninstalled** — the daemon is no longer running on the target machine.
- **Network unreachable** — the daemon cannot reach the target network or subnets.
- **Daemon overloaded** — the daemon is unable to respond to session requests within the 5-minute timeout.

## How to troubleshoot

1. Navigate to **Daemons** and check the status of the daemon assigned to the failing scan.
2. If the daemon shows as "Standby" or "Unreachable", the daemon process may need to be restarted or reinstalled on the target machine.
3. Verify network connectivity from the daemon host to the scan targets.
4. Check daemon logs for errors (typically at `/var/log/scanopy-daemon/` or in the daemon's Docker container logs).

For detailed troubleshooting steps, see: https://scanopy.net/docs/setting-up-daemons/troubleshooting-scans/

## How to unpause

1. Navigate to **Discoveries** and find the auto-paused scan (shown with a red "Auto-paused" tag).
2. Click the **Power** icon on the card to re-enable the scan, or open the scan's edit modal and toggle the Enabled switch.
3. Re-enabling resets the failure counter to 0 and re-adds the cron job to the scheduler.

Before re-enabling, ensure the underlying issue (daemon offline, network unreachable) has been resolved — otherwise the scan will be auto-paused again after 3 more stall failures.
