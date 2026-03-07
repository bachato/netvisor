-- Clear all standby flags. The old plan-based standby logic (DaemonPoll feature gating)
-- is dead code since all plans now support daemon_poll. Going forward, standby is set
-- by the server's inactivity check (30 days without a completed discovery).
UPDATE daemons SET standby = false WHERE standby = true;
