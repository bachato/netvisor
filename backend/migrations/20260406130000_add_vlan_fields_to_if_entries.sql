-- Add VLAN data fields to if_entries table
ALTER TABLE if_entries ADD COLUMN native_vlan_id SMALLINT;
ALTER TABLE if_entries ADD COLUMN vlan_ids JSONB;
