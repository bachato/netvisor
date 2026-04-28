--
-- PostgreSQL database dump
--

\restrict XuwkCQsxhUg96dAEEdmYZXza5gdBFLj9QGRpi3y4pZ3scqnua3BOeHdPMXKsP56

-- Dumped from database version 17.9
-- Dumped by pg_dump version 17.9

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.vlans DROP CONSTRAINT IF EXISTS vlans_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.vlans DROP CONSTRAINT IF EXISTS vlans_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_network_access DROP CONSTRAINT IF EXISTS user_network_access_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_network_access DROP CONSTRAINT IF EXISTS user_network_access_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_api_keys DROP CONSTRAINT IF EXISTS user_api_keys_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_api_keys DROP CONSTRAINT IF EXISTS user_api_keys_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_api_key_network_access DROP CONSTRAINT IF EXISTS user_api_key_network_access_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_api_key_network_access DROP CONSTRAINT IF EXISTS user_api_key_network_access_api_key_id_fkey;
ALTER TABLE IF EXISTS ONLY public.topologies DROP CONSTRAINT IF EXISTS topologies_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tags DROP CONSTRAINT IF EXISTS tags_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subnet_vlans DROP CONSTRAINT IF EXISTS subnet_vlans_vlan_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subnet_vlans DROP CONSTRAINT IF EXISTS subnet_vlans_subnet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_topology_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.network_credentials DROP CONSTRAINT IF EXISTS network_credentials_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.network_credentials DROP CONSTRAINT IF EXISTS network_credentials_credential_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.ip_addresses DROP CONSTRAINT IF EXISTS interfaces_subnet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ip_addresses DROP CONSTRAINT IF EXISTS interfaces_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ip_addresses DROP CONSTRAINT IF EXISTS interfaces_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS if_entries_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS if_entries_neighbor_if_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS if_entries_neighbor_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS if_entries_native_vlan_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS if_entries_interface_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS if_entries_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.host_credentials DROP CONSTRAINT IF EXISTS host_credentials_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.host_credentials DROP CONSTRAINT IF EXISTS host_credentials_credential_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dependencies DROP CONSTRAINT IF EXISTS groups_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dependency_members DROP CONSTRAINT IF EXISTS group_bindings_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dependency_members DROP CONSTRAINT IF EXISTS group_bindings_binding_id_fkey;
ALTER TABLE IF EXISTS ONLY public.entity_tags DROP CONSTRAINT IF EXISTS entity_tags_tag_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_daemon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dependency_members DROP CONSTRAINT IF EXISTS dependency_members_service_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_api_key_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credentials DROP CONSTRAINT IF EXISTS credentials_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_service_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_port_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_interface_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_network_id_fkey;
DROP TRIGGER IF EXISTS reassign_daemons_before_user_delete ON public.users;
DROP INDEX IF EXISTS public.idx_vlans_organization;
DROP INDEX IF EXISTS public.idx_vlans_network_number;
DROP INDEX IF EXISTS public.idx_vlans_network;
DROP INDEX IF EXISTS public.idx_users_password_reset_token;
DROP INDEX IF EXISTS public.idx_users_organization;
DROP INDEX IF EXISTS public.idx_users_oidc_provider_subject;
DROP INDEX IF EXISTS public.idx_users_email_verification_token;
DROP INDEX IF EXISTS public.idx_users_email_lower;
DROP INDEX IF EXISTS public.idx_user_network_access_user;
DROP INDEX IF EXISTS public.idx_user_network_access_network;
DROP INDEX IF EXISTS public.idx_user_api_keys_user;
DROP INDEX IF EXISTS public.idx_user_api_keys_org;
DROP INDEX IF EXISTS public.idx_user_api_keys_key;
DROP INDEX IF EXISTS public.idx_user_api_key_network_access_network;
DROP INDEX IF EXISTS public.idx_user_api_key_network_access_key;
DROP INDEX IF EXISTS public.idx_topologies_network;
DROP INDEX IF EXISTS public.idx_tags_organization;
DROP INDEX IF EXISTS public.idx_tags_org_name;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_subnet_vlans_vlan;
DROP INDEX IF EXISTS public.idx_subnet_vlans_subnet;
DROP INDEX IF EXISTS public.idx_shares_topology;
DROP INDEX IF EXISTS public.idx_shares_network;
DROP INDEX IF EXISTS public.idx_shares_enabled;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_position;
DROP INDEX IF EXISTS public.idx_services_host_id;
DROP INDEX IF EXISTS public.idx_ports_number;
DROP INDEX IF EXISTS public.idx_ports_network;
DROP INDEX IF EXISTS public.idx_ports_host;
DROP INDEX IF EXISTS public.idx_organizations_stripe_customer;
DROP INDEX IF EXISTS public.idx_networks_owner_organization;
DROP INDEX IF EXISTS public.idx_ip_addresses_subnet;
DROP INDEX IF EXISTS public.idx_ip_addresses_network;
DROP INDEX IF EXISTS public.idx_ip_addresses_host_mac;
DROP INDEX IF EXISTS public.idx_ip_addresses_host;
DROP INDEX IF EXISTS public.idx_invites_organization;
DROP INDEX IF EXISTS public.idx_invites_expires_at;
DROP INDEX IF EXISTS public.idx_interfaces_network;
DROP INDEX IF EXISTS public.idx_interfaces_neighbor_interface;
DROP INDEX IF EXISTS public.idx_interfaces_neighbor_host;
DROP INDEX IF EXISTS public.idx_interfaces_mac_address;
DROP INDEX IF EXISTS public.idx_interfaces_ip_address;
DROP INDEX IF EXISTS public.idx_interfaces_host_name;
DROP INDEX IF EXISTS public.idx_interfaces_host_if_index;
DROP INDEX IF EXISTS public.idx_interfaces_host;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_hosts_chassis_id;
DROP INDEX IF EXISTS public.idx_groups_network;
DROP INDEX IF EXISTS public.idx_entity_tags_tag_id;
DROP INDEX IF EXISTS public.idx_entity_tags_entity;
DROP INDEX IF EXISTS public.idx_discovery_network;
DROP INDEX IF EXISTS public.idx_discovery_daemon;
DROP INDEX IF EXISTS public.idx_dependency_members_service;
DROP INDEX IF EXISTS public.idx_dependency_members_dependency;
DROP INDEX IF EXISTS public.idx_dependency_members_binding;
DROP INDEX IF EXISTS public.idx_daemons_network;
DROP INDEX IF EXISTS public.idx_daemons_api_key;
DROP INDEX IF EXISTS public.idx_daemon_host_id;
DROP INDEX IF EXISTS public.idx_credentials_type;
DROP INDEX IF EXISTS public.idx_credentials_org;
DROP INDEX IF EXISTS public.idx_bindings_service;
DROP INDEX IF EXISTS public.idx_bindings_port;
DROP INDEX IF EXISTS public.idx_bindings_network;
DROP INDEX IF EXISTS public.idx_bindings_ip_address;
DROP INDEX IF EXISTS public.idx_api_keys_network;
DROP INDEX IF EXISTS public.idx_api_keys_key;
ALTER TABLE IF EXISTS ONLY tower_sessions.session DROP CONSTRAINT IF EXISTS session_pkey;
ALTER TABLE IF EXISTS ONLY public.vlans DROP CONSTRAINT IF EXISTS vlans_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.user_network_access DROP CONSTRAINT IF EXISTS user_network_access_user_id_network_id_key;
ALTER TABLE IF EXISTS ONLY public.user_network_access DROP CONSTRAINT IF EXISTS user_network_access_pkey;
ALTER TABLE IF EXISTS ONLY public.user_api_keys DROP CONSTRAINT IF EXISTS user_api_keys_pkey;
ALTER TABLE IF EXISTS ONLY public.user_api_keys DROP CONSTRAINT IF EXISTS user_api_keys_key_key;
ALTER TABLE IF EXISTS ONLY public.user_api_key_network_access DROP CONSTRAINT IF EXISTS user_api_key_network_access_pkey;
ALTER TABLE IF EXISTS ONLY public.user_api_key_network_access DROP CONSTRAINT IF EXISTS user_api_key_network_access_api_key_id_network_id_key;
ALTER TABLE IF EXISTS ONLY public.topologies DROP CONSTRAINT IF EXISTS topologies_pkey;
ALTER TABLE IF EXISTS ONLY public.tags DROP CONSTRAINT IF EXISTS tags_pkey;
ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_pkey;
ALTER TABLE IF EXISTS ONLY public.subnet_vlans DROP CONSTRAINT IF EXISTS subnet_vlans_subnet_id_vlan_id_key;
ALTER TABLE IF EXISTS ONLY public.subnet_vlans DROP CONSTRAINT IF EXISTS subnet_vlans_pkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_pkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_host_id_port_number_protocol_key;
ALTER TABLE IF EXISTS ONLY public.organizations DROP CONSTRAINT IF EXISTS organizations_pkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_pkey;
ALTER TABLE IF EXISTS ONLY public.network_credentials DROP CONSTRAINT IF EXISTS network_credentials_pkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_pkey;
ALTER TABLE IF EXISTS ONLY public.ip_addresses DROP CONSTRAINT IF EXISTS interfaces_pkey;
ALTER TABLE IF EXISTS ONLY public.ip_addresses DROP CONSTRAINT IF EXISTS interfaces_host_id_subnet_id_ip_address_key;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS if_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_pkey;
ALTER TABLE IF EXISTS ONLY public.host_credentials DROP CONSTRAINT IF EXISTS host_credentials_pkey;
ALTER TABLE IF EXISTS ONLY public.dependencies DROP CONSTRAINT IF EXISTS groups_pkey;
ALTER TABLE IF EXISTS ONLY public.dependency_members DROP CONSTRAINT IF EXISTS group_bindings_pkey;
ALTER TABLE IF EXISTS ONLY public.entity_tags DROP CONSTRAINT IF EXISTS entity_tags_pkey;
ALTER TABLE IF EXISTS ONLY public.entity_tags DROP CONSTRAINT IF EXISTS entity_tags_entity_id_entity_type_tag_id_key;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_pkey;
ALTER TABLE IF EXISTS ONLY public.dependency_members DROP CONSTRAINT IF EXISTS dependency_members_dep_service_unique;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_pkey;
ALTER TABLE IF EXISTS ONLY public.credentials DROP CONSTRAINT IF EXISTS credentials_pkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_pkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_pkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_key_key;
ALTER TABLE IF EXISTS ONLY public._sqlx_migrations DROP CONSTRAINT IF EXISTS _sqlx_migrations_pkey;
DROP TABLE IF EXISTS tower_sessions.session;
DROP TABLE IF EXISTS public.vlans;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_network_access;
DROP TABLE IF EXISTS public.user_api_keys;
DROP TABLE IF EXISTS public.user_api_key_network_access;
DROP TABLE IF EXISTS public.topologies;
DROP TABLE IF EXISTS public.tags;
DROP TABLE IF EXISTS public.subnets;
DROP TABLE IF EXISTS public.subnet_vlans;
DROP TABLE IF EXISTS public.shares;
DROP TABLE IF EXISTS public.services;
DROP TABLE IF EXISTS public.ports;
DROP TABLE IF EXISTS public.organizations;
DROP TABLE IF EXISTS public.networks;
DROP TABLE IF EXISTS public.network_credentials;
DROP TABLE IF EXISTS public.ip_addresses;
DROP TABLE IF EXISTS public.invites;
DROP TABLE IF EXISTS public.interfaces;
DROP TABLE IF EXISTS public.hosts;
DROP TABLE IF EXISTS public.host_credentials;
DROP TABLE IF EXISTS public.entity_tags;
DROP TABLE IF EXISTS public.discovery;
DROP TABLE IF EXISTS public.dependency_members;
DROP TABLE IF EXISTS public.dependencies;
DROP TABLE IF EXISTS public.daemons;
DROP TABLE IF EXISTS public.credentials;
DROP TABLE IF EXISTS public.bindings;
DROP TABLE IF EXISTS public.api_keys;
DROP TABLE IF EXISTS public._sqlx_migrations;
DROP FUNCTION IF EXISTS public.reassign_daemons_on_user_delete();
DROP EXTENSION IF EXISTS pgcrypto;
DROP SCHEMA IF EXISTS tower_sessions;
--
-- Name: tower_sessions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tower_sessions;


ALTER SCHEMA tower_sessions OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: reassign_daemons_on_user_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reassign_daemons_on_user_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_owner_id UUID;
BEGIN
    SELECT id INTO new_owner_id
    FROM users
    WHERE organization_id = OLD.organization_id
      AND permissions = 'Owner'
      AND id != OLD.id
    ORDER BY created_at ASC
    LIMIT 1;

    IF new_owner_id IS NOT NULL THEN
        UPDATE daemons
        SET user_id = new_owner_id
        WHERE user_id = OLD.id;
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.reassign_daemons_on_user_delete() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _sqlx_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._sqlx_migrations (
    version bigint NOT NULL,
    description text NOT NULL,
    installed_on timestamp with time zone DEFAULT now() NOT NULL,
    success boolean NOT NULL,
    checksum bytea NOT NULL,
    execution_time bigint NOT NULL
);


ALTER TABLE public._sqlx_migrations OWNER TO postgres;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_keys (
    id uuid NOT NULL,
    key text NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used timestamp with time zone,
    expires_at timestamp with time zone,
    is_enabled boolean DEFAULT true NOT NULL,
    plaintext text
);


ALTER TABLE public.api_keys OWNER TO postgres;

--
-- Name: bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bindings (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    service_id uuid NOT NULL,
    binding_type text NOT NULL,
    ip_address_id uuid,
    port_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT bindings_binding_type_check CHECK ((binding_type = ANY (ARRAY['IPAddress'::text, 'Port'::text]))),
    CONSTRAINT valid_binding CHECK ((((binding_type = 'IPAddress'::text) AND (ip_address_id IS NOT NULL) AND (port_id IS NULL)) OR ((binding_type = 'Port'::text) AND (port_id IS NOT NULL))))
);


ALTER TABLE public.bindings OWNER TO postgres;

--
-- Name: credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.credentials (
    id uuid NOT NULL,
    organization_id uuid NOT NULL,
    name text NOT NULL,
    credential_type jsonb NOT NULL,
    target_ips inet[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.credentials OWNER TO postgres;

--
-- Name: daemons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.daemons (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    host_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    last_seen timestamp with time zone,
    capabilities jsonb DEFAULT '{}'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    mode text DEFAULT '"Push"'::text,
    url text NOT NULL,
    name text,
    version text,
    user_id uuid NOT NULL,
    api_key_id uuid,
    is_unreachable boolean DEFAULT false NOT NULL,
    standby boolean DEFAULT false NOT NULL,
    standby_cleared_at timestamp with time zone
);


ALTER TABLE public.daemons OWNER TO postgres;

--
-- Name: dependencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dependencies (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    source jsonb NOT NULL,
    color text NOT NULL,
    edge_style text DEFAULT '"SmoothStep"'::text,
    dependency_type text NOT NULL,
    member_type text DEFAULT 'Bindings'::text NOT NULL
);


ALTER TABLE public.dependencies OWNER TO postgres;

--
-- Name: dependency_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dependency_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    dependency_id uuid NOT NULL,
    binding_id uuid,
    "position" integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    service_id uuid NOT NULL
);


ALTER TABLE public.dependency_members OWNER TO postgres;

--
-- Name: discovery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discovery (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    daemon_id uuid NOT NULL,
    run_type jsonb NOT NULL,
    discovery_type jsonb NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    scan_count integer DEFAULT 0 NOT NULL,
    force_full_scan boolean DEFAULT false NOT NULL,
    pending_credential_ids uuid[] DEFAULT '{}'::uuid[] NOT NULL
);


ALTER TABLE public.discovery OWNER TO postgres;

--
-- Name: entity_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entity_tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_id uuid NOT NULL,
    entity_type character varying(50) NOT NULL,
    tag_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.entity_tags OWNER TO postgres;

--
-- Name: host_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.host_credentials (
    host_id uuid NOT NULL,
    credential_id uuid NOT NULL,
    ip_address_ids uuid[]
);


ALTER TABLE public.host_credentials OWNER TO postgres;

--
-- Name: hosts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hosts (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    hostname text,
    description text,
    source jsonb NOT NULL,
    virtualization jsonb,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    hidden boolean DEFAULT false,
    sys_descr text,
    sys_object_id text,
    sys_location text,
    sys_contact text,
    management_url text,
    chassis_id text,
    manufacturer text,
    model text,
    serial_number text,
    sys_name text
);


ALTER TABLE public.hosts OWNER TO postgres;

--
-- Name: COLUMN hosts.sys_descr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.hosts.sys_descr IS 'SNMP sysDescr.0 - full system description';


--
-- Name: COLUMN hosts.sys_object_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.hosts.sys_object_id IS 'SNMP sysObjectID.0 - vendor OID for device identification';


--
-- Name: COLUMN hosts.sys_location; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.hosts.sys_location IS 'SNMP sysLocation.0 - physical location';


--
-- Name: COLUMN hosts.sys_contact; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.hosts.sys_contact IS 'SNMP sysContact.0 - admin contact info';


--
-- Name: COLUMN hosts.management_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.hosts.management_url IS 'URL for device management interface (manual or discovered)';


--
-- Name: COLUMN hosts.chassis_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.hosts.chassis_id IS 'LLDP lldpLocChassisId - globally unique device identifier for deduplication';


--
-- Name: interfaces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interfaces (
    id uuid NOT NULL,
    host_id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    if_index integer NOT NULL,
    if_descr text NOT NULL,
    if_alias text,
    if_type integer NOT NULL,
    speed_bps bigint,
    admin_status integer NOT NULL,
    oper_status integer NOT NULL,
    mac_address macaddr,
    ip_address_id uuid,
    neighbor_interface_id uuid,
    neighbor_host_id uuid,
    lldp_chassis_id jsonb,
    lldp_port_id jsonb,
    lldp_sys_name text,
    lldp_port_desc text,
    lldp_mgmt_addr inet,
    lldp_sys_desc text,
    cdp_device_id text,
    cdp_port_id text,
    cdp_platform text,
    cdp_address inet,
    if_name text,
    fdb_macs jsonb,
    native_vlan_id uuid,
    vlan_ids jsonb,
    CONSTRAINT chk_neighbor_exclusive CHECK (((neighbor_interface_id IS NULL) OR (neighbor_host_id IS NULL)))
);


ALTER TABLE public.interfaces OWNER TO postgres;

--
-- Name: TABLE interfaces; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.interfaces IS 'SNMP ifTable entries - physical/logical interfaces on network devices';


--
-- Name: COLUMN interfaces.if_index; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.if_index IS 'SNMP ifIndex - stable identifier within device';


--
-- Name: COLUMN interfaces.if_descr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.if_descr IS 'SNMP ifDescr - interface description (e.g., GigabitEthernet0/1)';


--
-- Name: COLUMN interfaces.if_alias; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.if_alias IS 'SNMP ifAlias - user-configured description';


--
-- Name: COLUMN interfaces.if_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.if_type IS 'SNMP ifType - IANAifType integer (6=ethernet, 24=loopback, etc.)';


--
-- Name: COLUMN interfaces.speed_bps; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.speed_bps IS 'Interface speed from ifSpeed/ifHighSpeed in bits per second';


--
-- Name: COLUMN interfaces.admin_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.admin_status IS 'SNMP ifAdminStatus: 1=up, 2=down, 3=testing';


--
-- Name: COLUMN interfaces.oper_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.oper_status IS 'SNMP ifOperStatus: 1=up, 2=down, 3=testing, 4=unknown, 5=dormant, 6=notPresent, 7=lowerLayerDown';


--
-- Name: COLUMN interfaces.ip_address_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.ip_address_id IS 'FK to Interface entity when this ifEntry has an IP address (must be on same host)';


--
-- Name: COLUMN interfaces.neighbor_interface_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.neighbor_interface_id IS 'Full neighbor resolution: FK to remote IfEntry discovered via LLDP/CDP';


--
-- Name: COLUMN interfaces.neighbor_host_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.neighbor_host_id IS 'Partial neighbor resolution: FK to remote Host when specific port is unknown';


--
-- Name: COLUMN interfaces.lldp_mgmt_addr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.lldp_mgmt_addr IS 'LLDP remote management address (lldpRemManAddr)';


--
-- Name: COLUMN interfaces.lldp_sys_desc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.lldp_sys_desc IS 'LLDP remote system description (lldpRemSysDesc)';


--
-- Name: COLUMN interfaces.cdp_device_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.cdp_device_id IS 'CDP cache remote device ID (typically hostname)';


--
-- Name: COLUMN interfaces.cdp_port_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.cdp_port_id IS 'CDP cache remote port ID string';


--
-- Name: COLUMN interfaces.cdp_platform; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.cdp_platform IS 'CDP cache remote device platform (e.g., Cisco IOS)';


--
-- Name: COLUMN interfaces.cdp_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.interfaces.cdp_address IS 'CDP cache remote device management IP address';


--
-- Name: invites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invites (
    id uuid NOT NULL,
    organization_id uuid NOT NULL,
    permissions text NOT NULL,
    network_ids uuid[] NOT NULL,
    url text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    send_to text
);


ALTER TABLE public.invites OWNER TO postgres;

--
-- Name: ip_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ip_addresses (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    host_id uuid NOT NULL,
    subnet_id uuid NOT NULL,
    ip_address inet NOT NULL,
    mac_address macaddr,
    name text,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ip_addresses OWNER TO postgres;

--
-- Name: TABLE ip_addresses; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.ip_addresses IS 'IP addresses assigned to hosts on subnets';


--
-- Name: network_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.network_credentials (
    network_id uuid NOT NULL,
    credential_id uuid NOT NULL
);


ALTER TABLE public.network_credentials OWNER TO postgres;

--
-- Name: networks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.networks (
    id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    organization_id uuid NOT NULL
);


ALTER TABLE public.networks OWNER TO postgres;

--
-- Name: COLUMN networks.organization_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.networks.organization_id IS 'The organization that owns and pays for this network';


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    stripe_customer_id text,
    plan jsonb NOT NULL,
    plan_status text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    onboarding jsonb DEFAULT '[]'::jsonb,
    brevo_company_id text,
    has_payment_method boolean DEFAULT false NOT NULL,
    trial_end_date timestamp with time zone,
    plan_limit_notifications jsonb DEFAULT '{}'::jsonb NOT NULL,
    use_case text
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: TABLE organizations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.organizations IS 'Organizations that own networks and have Stripe subscriptions';


--
-- Name: COLUMN organizations.plan; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.plan IS 'The current billing plan for the organization (e.g., Community, Pro)';


--
-- Name: ports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ports (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    host_id uuid NOT NULL,
    port_number integer NOT NULL,
    protocol text NOT NULL,
    port_type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ports_port_number_check CHECK (((port_number >= 0) AND (port_number <= 65535))),
    CONSTRAINT ports_protocol_check CHECK ((protocol = ANY (ARRAY['Tcp'::text, 'Udp'::text])))
);


ALTER TABLE public.ports OWNER TO postgres;

--
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    host_id uuid NOT NULL,
    service_definition text NOT NULL,
    virtualization jsonb,
    source jsonb NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.services OWNER TO postgres;

--
-- Name: shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shares (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    topology_id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_by uuid NOT NULL,
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    expires_at timestamp with time zone,
    password_hash text,
    allowed_domains text[],
    options jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    enabled_views jsonb
);


ALTER TABLE public.shares OWNER TO postgres;

--
-- Name: subnet_vlans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subnet_vlans (
    id uuid NOT NULL,
    subnet_id uuid NOT NULL,
    vlan_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.subnet_vlans OWNER TO postgres;

--
-- Name: subnets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subnets (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    cidr text NOT NULL,
    name text NOT NULL,
    description text,
    subnet_type text NOT NULL,
    source jsonb NOT NULL,
    virtualization jsonb
);


ALTER TABLE public.subnets OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    id uuid NOT NULL,
    organization_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    color text NOT NULL,
    is_application boolean DEFAULT false NOT NULL
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: topologies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.topologies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    edges jsonb NOT NULL,
    nodes jsonb NOT NULL,
    options jsonb NOT NULL,
    hosts jsonb NOT NULL,
    subnets jsonb NOT NULL,
    services jsonb NOT NULL,
    dependencies jsonb NOT NULL,
    is_stale boolean,
    last_refreshed timestamp with time zone DEFAULT now() NOT NULL,
    is_locked boolean,
    locked_at timestamp with time zone,
    locked_by uuid,
    removed_hosts uuid[],
    removed_services uuid[],
    removed_subnets uuid[],
    removed_dependencies uuid[],
    parent_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL,
    ip_addresses jsonb DEFAULT '[]'::jsonb NOT NULL,
    removed_ip_addresses uuid[] DEFAULT '{}'::uuid[],
    ports jsonb DEFAULT '[]'::jsonb NOT NULL,
    removed_ports uuid[] DEFAULT '{}'::uuid[],
    bindings jsonb DEFAULT '[]'::jsonb NOT NULL,
    removed_bindings uuid[] DEFAULT '{}'::uuid[],
    interfaces jsonb DEFAULT '[]'::jsonb NOT NULL,
    removed_interfaces uuid[] DEFAULT '{}'::uuid[],
    entity_tags jsonb DEFAULT '[]'::jsonb NOT NULL,
    vlans jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE public.topologies OWNER TO postgres;

--
-- Name: user_api_key_network_access; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_api_key_network_access (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    api_key_id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_api_key_network_access OWNER TO postgres;

--
-- Name: user_api_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_api_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    user_id uuid NOT NULL,
    organization_id uuid NOT NULL,
    permissions text DEFAULT 'Viewer'::text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used timestamp with time zone,
    expires_at timestamp with time zone,
    is_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.user_api_keys OWNER TO postgres;

--
-- Name: user_network_access; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_network_access (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_network_access OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    password_hash text,
    oidc_provider text,
    oidc_subject text,
    oidc_linked_at timestamp with time zone,
    email text NOT NULL,
    organization_id uuid NOT NULL,
    permissions text DEFAULT 'Member'::text NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL,
    terms_accepted_at timestamp with time zone,
    email_verified boolean DEFAULT false NOT NULL,
    email_verification_token text,
    email_verification_expires timestamp with time zone,
    password_reset_token text,
    password_reset_expires timestamp with time zone,
    pending_email text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: COLUMN users.organization_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.organization_id IS 'The single organization this user belongs to';


--
-- Name: COLUMN users.permissions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.permissions IS 'User role within their organization: Owner, Member, Viewer';


--
-- Name: vlans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vlans (
    id uuid NOT NULL,
    vlan_number smallint NOT NULL,
    name text NOT NULL,
    description text,
    network_id uuid NOT NULL,
    organization_id uuid NOT NULL,
    source jsonb DEFAULT '"Manual"'::jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.vlans OWNER TO postgres;

--
-- Name: session; Type: TABLE; Schema: tower_sessions; Owner: postgres
--

CREATE TABLE tower_sessions.session (
    id text NOT NULL,
    data bytea NOT NULL,
    expiry_date timestamp with time zone NOT NULL
);


ALTER TABLE tower_sessions.session OWNER TO postgres;

--
-- Data for Name: _sqlx_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._sqlx_migrations (version, description, installed_on, success, checksum, execution_time) FROM stdin;
20251006215000	users	2026-04-28 19:08:56.081153+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	4122528
20251006215100	networks	2026-04-28 19:08:56.086041+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4804731
20251006215151	create hosts	2026-04-28 19:08:56.091355+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4574728
20251006215155	create subnets	2026-04-28 19:08:56.096452+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4418204
20251006215201	create groups	2026-04-28 19:08:56.101412+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4957869
20251006215204	create daemons	2026-04-28 19:08:56.106939+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	5550965
20251006215212	create services	2026-04-28 19:08:56.11306+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	6166523
20251029193448	user-auth	2026-04-28 19:08:56.119781+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	4958561
20251030044828	daemon api	2026-04-28 19:08:56.125241+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1737149
20251030170438	host-hide	2026-04-28 19:08:56.127488+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1547672
20251102224919	create discovery	2026-04-28 19:08:56.129562+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10963501
20251106235621	normalize-daemon-cols	2026-04-28 19:08:56.141079+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	2471330
20251107034459	api keys	2026-04-28 19:08:56.144092+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7991718
20251107222650	oidc-auth	2026-04-28 19:08:56.152636+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	22465994
20251110181948	orgs-billing	2026-04-28 19:08:56.175691+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	12377812
20251113223656	group-enhancements	2026-04-28 19:08:56.188675+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1467441
20251117032720	daemon-mode	2026-04-28 19:08:56.190717+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1492418
20251118143058	set-default-plan	2026-04-28 19:08:56.192781+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1599189
20251118225043	save-topology	2026-04-28 19:08:56.194951+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	10528090
20251123232748	network-permissions	2026-04-28 19:08:56.206065+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	3781606
20251125001342	billing-updates	2026-04-28 19:08:56.210375+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1282233
20251128035448	org-onboarding-status	2026-04-28 19:08:56.212234+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	2133304
20251129180942	nfs-consolidate	2026-04-28 19:08:56.214872+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1591604
20251206052641	discovery-progress	2026-04-28 19:08:56.21699+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1855432
20251206202200	plan-fix	2026-04-28 19:08:56.219378+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	1260653
20251207061341	daemon-url	2026-04-28 19:08:56.221155+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2763600
20251210045929	tags	2026-04-28 19:08:56.224466+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	10877598
20251210175035	terms	2026-04-28 19:08:56.235922+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	1261865
20251213025048	hash-keys	2026-04-28 19:08:56.23772+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9932480
20251214050638	scanopy	2026-04-28 19:08:56.248244+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1761766
20251215215724	topo-scanopy-fix	2026-04-28 19:08:56.250598+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	1075812
20251217153736	category rename	2026-04-28 19:08:56.252196+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	2240386
20251218053111	invite-persistence	2026-04-28 19:08:56.254966+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	6148680
20251219211216	create shares	2026-04-28 19:08:56.261692+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	8204168
20251220170928	permissions-cleanup	2026-04-28 19:08:56.270478+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1749151
20251220180000	commercial-to-community	2026-04-28 19:08:56.272808+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	1104599
20251221010000	cleanup subnet type	2026-04-28 19:08:56.274434+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	1133162
20251221020000	remove host target	2026-04-28 19:08:56.276098+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	1354128
20251221030000	user network access	2026-04-28 19:08:56.277994+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7621111
20251221040000	interfaces table	2026-04-28 19:08:56.286203+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	11773234
20251221050000	ports table	2026-04-28 19:08:56.298599+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	10906233
20251221060000	bindings table	2026-04-28 19:08:56.310124+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	12944888
20251221070000	group bindings	2026-04-28 19:08:56.323686+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	7606693
20251222020000	tag cascade delete	2026-04-28 19:08:56.33183+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1522715
20251223232524	network remove default	2026-04-28 19:08:56.333862+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1280830
20251225100000	color enum	2026-04-28 19:08:56.335661+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1686621
20251227010000	topology snapshot migration	2026-04-28 19:08:56.33783+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4444984
20251228010000	user api keys	2026-04-28 19:08:56.342766+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	13722193
20251230160000	daemon version and maintainer	2026-04-28 19:08:56.357104+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	3270424
20260103000000	service position	2026-04-28 19:08:56.360944+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	2478254
20260106000000	interface mac index	2026-04-28 19:08:56.363945+00	t	\\xa26248372a1e31af46a9c6fbdaef178982229e2ceeb90cc6a289d5764f87a38747294b3adf5f21276b5d171e42bdb6ac	2268018
20260106204402	entity tags junction	2026-04-28 19:08:56.366774+00	t	\\xf73c604f9f0b8db065d990a861684b0dbd62c3ef9bead120c68431c933774de56491a53f021e79f09801680152f5a08a	14983875
20260108033856	fix entity tags json format	2026-04-28 19:08:56.382355+00	t	\\x197eaa063d4f96dd0e897ad8fd96cc1ba9a54dda40a93a5c12eac14597e4dea4c806dd0a527736fb5807b7a8870d9916	1888534
20260110000000	email verification	2026-04-28 19:08:56.384754+00	t	\\xb8da8433f58ba4ce846b9fa0c2551795747a8473ad10266b19685504847458ea69d27a0ce430151cfb426f5f5fb6ac3a	4309519
20260114145808	daemon user fk set null	2026-04-28 19:08:56.392043+00	t	\\x57b060be9fc314d7c5851c75661ca8269118feea6cf7ee9c61b147a0e117c4d39642cf0d1acdf7a723a9a76066c1b8ff	1401477
20260116010000	snmp credentials	2026-04-28 19:08:56.393959+00	t	\\x6f3971cf194d56883c61fa795406a8ab568307ed86544920d098b32a6a1ebb7effcb5ec38a70fdc9b617eff92d63d51e	8323813
20260116020000	host snmp fields	2026-04-28 19:08:56.40286+00	t	\\xf2f088c13ab0dd34e1cb1e5327b0b4137440b0146e5ce1e78b8d2dfa05d9b5a12a328eeb807988453a8a43ad8a1c95ba	5146554
20260116030000	if entries	2026-04-28 19:08:56.408615+00	t	\\xa58391708f8b21901ab9250af528f638a6055462f70ffddfd7c451433aacdabd62825546fa8be108f23a3cae78b8ae28	15554609
20260116100000	daemon api key link	2026-04-28 19:08:56.42482+00	t	\\x41088aa314ab173344a6b416280721806b2f296a32a8d8cae58c7e5717f389fe599134ed03980ed97e4b7659e99c4f82	3793268
20260131190000	add hubspot company id	2026-04-28 19:08:56.429149+00	t	\\x4326f95f4954e176157c1c3e034074a3e5c44da4d60bbd7a9e4b6238c9ef52a30f8b38d3c887864b6e4c1163dc062beb	1130258
20260201021238	fix service acronym capitalization	2026-04-28 19:08:56.430777+00	t	\\x88b010ac8f0223d880ea6a730f11dc6d27fa5de9d8747de3431e46d59f1dbf2f72ae4a87c2e52c32152549f5c1f96bb2	1805939
20260204004436	add entity tags to topology	2026-04-28 19:08:56.433093+00	t	\\x3eff1a1490e77065ec861ef1b9aad8c55de0170106a42720f7931b3929b179122b16e44390b2652771bf91bba32a7757	1568261
20260205120000	billing overhaul	2026-04-28 19:08:56.435167+00	t	\\xbf850cfa0c40a3c65f574efd15fd55a4b702296203d28077a09d1c22076fee8601f2b78345aef370ab9163657de767ab	2526534
20260205183207	rename hubspot to brevo	2026-04-28 19:08:56.438232+00	t	\\x4678a7d80215e5eafb5e80af0daa20e2868a3b4f2112e88cb1b2b9efc87d63de3fb96c133f359b224c658789ae4b0d13	1259029
20260221120000	add plan limit notifications	2026-04-28 19:08:56.439991+00	t	\\xef770dac07e1d80888832f33184dc46c1d3b8185b91c507cb404468d6ad8c29cacf455178801c67aa27b6a626d3ad82d	1495494
20260222120000	add pending email	2026-04-28 19:08:56.442015+00	t	\\xddd220f7602c44548d56849c0a8d081ecd1da1383374a11e3e227c7d9becb73a49f5e5bb09ed65901c16df4c16e913e5	1217381
20260301120000	add if name to if entries	2026-04-28 19:08:56.443775+00	t	\\xc9fc0a2b77ecbf0e1d5ab292c4fe162a26113468c878dfd26a3c63d89c0ee1957ca328ecfe25c611867a0e73780f0cb6	1201951
20260306002816	cleanup standby	2026-04-28 19:08:56.445477+00	t	\\x01b0c236a8a4d0d97f0f633b18f8cbdb92b6d72063289989b90a1b7b6b303e65e0557eb09927b2580dcb7e8ee5966c75	1271121
20260309120000	add org use case	2026-04-28 19:08:56.44724+00	t	\\xdb8c8a2f0f9416ba3b687fc75453d7c12c50a6f386b4784d21bd6adfc4a4a7556c637c25cf116118402bbd12c0d5aafe	1183386
20260313120000	snmp extended discovery	2026-04-28 19:08:56.448935+00	t	\\xc4e72539099de1b830d87a169bfbabba4b8fb378a3c4c4a1dfca698adf3e403d750040d784c26d9fa343be2908064c9d	2102607
20260315120000	universal credentials	2026-04-28 19:08:56.451629+00	t	\\x87dc6f39202e81d5555df78a9d056b143f11bd22e6d7f483065f605e242a360902c72c4d5a49717e7fcc24a366bb5ff5	23091793
20260315120001	discovery scan settings	2026-04-28 19:08:56.475407+00	t	\\xe9da183fdd8e04e574f553f61f6f33efa046cdae38c846c8077b06c5260446fb4aa39da2449bda7f1d8cf3aa9f16e158	1356973
20260315120002	backfill org created milestone	2026-04-28 19:08:56.477252+00	t	\\x14f886a19773cd2263d86f88479be460d21f071d5212e3789c5c40b6415c293fc7d06c7b138351cc42108f89a14fe745	1186353
20260316120000	fix jsonb null if entries	2026-04-28 19:08:56.478954+00	t	\\x65c358069710f7f86d6a3e257e658c2f241cc376433c3a0317b0ec9e1876a66f9738cb65c6ab1a5c197fe40d5aa2aa2b	2100142
20260319120000	rename snmp to snmpv2c	2026-04-28 19:08:56.481619+00	t	\\xdce5c9461f402e1672607078b2c571f0eb30b51d46f8e9414d8909efb40693f543e49e560cb7d703db274515043aa08e	1546971
20260321120000	add discovery scan count	2026-04-28 19:08:56.484658+00	t	\\x6c8201ab453a51632176d534c6604e0818e28a8a4a153e33e254f4dac0f9b67c9db394082cb663ff1b25941229cf96fc	2372585
20260329120000	backfill subnet virtualization	2026-04-28 19:08:56.48758+00	t	\\xeac50ded27603dbb5e8773604a52143c9fa8654263e7dd12d3d128ce972c2feed84600e36b2e7a79525b58c44d2ad9d3	2275892
20260402120000	rename topology node types	2026-04-28 19:08:56.490521+00	t	\\xc4ba06868add823f83ff1948091bdfe17dbdde80bbec6fe2cf8da2b3689aeeebbe9e9de01b1292bff3c98a74d9e6279f	1057510
20260403120000	topology grouping rules	2026-04-28 19:08:56.492101+00	t	\\x00799da1206d7c3b3c3db90b7d14437cc054ed2d7273020342e562c619a671e008ff4fdf0365170440b392956949e730	1413099
20260405120000	rename groups to dependencies	2026-04-28 19:08:56.494025+00	t	\\x9ce895b456366bf6e54316b22cabd2803aa542dd3733fffa680f0a3af5c4c55a612c5ee511371206921869b7f271c35b	10216394
20260406120000	add tag is application group	2026-04-28 19:08:56.504888+00	t	\\xb7a71e5fdd96ca46c9c7577003309050a93bc53ad192ac5df78e7621f3ed64f07fb29b4658f17af55732cf6dfb7958c2	1431473
20260406130000	add vlans	2026-04-28 19:08:56.506827+00	t	\\x5b3e5d10578d90b5175e5718a28d7147a21b99af2fb3e0ed171d20ee8fd8838c290f648dafdd3b72ef60ff487f7f2494	13439037
20260409000000	add vlans to topologies	2026-04-28 19:08:56.520988+00	t	\\x5e0b9dc670580ceec3aa6eae005a39f98733fc27dc574b7f3922f4297813facd5d610af953dfec13e09d0b99eceb3865	1521353
20260410000000	rename interfaces and if entries	2026-04-28 19:08:56.52301+00	t	\\x07f54a59869f458f41f45d75f250aee26b20a426f1ec29930606841770194d6aea0e9e6253a6375fbeebcf9b49121224	7386429
20260414000000	add share enabled views	2026-04-28 19:08:56.531009+00	t	\\xc56514355a5977c3242e728e7f5a2533e7b4a5cf8a7ce7757e412e51f1ad85e96d65c13ccd96d050be4a07799b9aef57	1241557
20260415120000	rename onboarding first group created	2026-04-28 19:08:56.532774+00	t	\\x2c17035835d3ead105b76d98688c0b7bd328abdaf9f721d70d057c8afdf438819e93da56707deea5b469b81a7b84d5d7	1036661
20260417000000	reindex interfaces identity	2026-04-28 19:08:56.534332+00	t	\\x10701e13bc3d838e2ec4a856555ebf338173792f220c405996d3c77e7987e9806798ca0328eb6259e4a62b7e05665b25	4254877
20260418000000	add standby cleared at to daemons	2026-04-28 19:08:56.539109+00	t	\\x547807de451d015a4ce1438796d5b95e2b98043c521015a21239f6778d10a8d3bf7d8b14e278e09aa0105f1935ad4181	1162047
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, plaintext) FROM stdin;
b17f8145-5b33-437b-acdf-aff8dd86e681	b3a4a9774779375ffa5a23b57a5ead01778a9d418ed0a6eaf0930f50a991bf96	a9101e7c-c74f-44a7-8f2c-86a9b202a012	Integrated Daemon API Key	2026-04-28 19:08:58.120122+00	2026-04-28 19:08:58.120122+00	2026-04-28 19:13:40.556623+00	\N	t	\N
37e3a835-c3df-4334-a911-2783ec07eb1a	d6bc86ae1c7d9b1196325e6c91d31dec383727d32a95a5da86ec3cafc96610b6	a9101e7c-c74f-44a7-8f2c-86a9b202a012	scanopy-daemon-serverpoll API Key	2026-04-28 19:10:03.205217+00	2026-04-28 19:10:03.205217+00	2026-04-28 19:13:57.858951+00	\N	t	scp_d_WyJenlKHFrh3O9ooZn7Y318I6KF7SeLN
77f7a8df-9ab4-4354-a559-954186438273	adc5194ed06aff8d42ca1cd28b352fdafeda576820e8de7b860e0abe22398f96	a9101e7c-c74f-44a7-8f2c-86a9b202a012	Compat Test API Key	2026-04-28 19:13:28.679613+00	2026-04-28 19:13:28.679613+00	2026-04-28 19:13:46.042486+00	\N	t	\N
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, ip_address_id, port_id, created_at, updated_at) FROM stdin;
cbe346de-dcb5-4645-b0d3-820574c89ef5	a9101e7c-c74f-44a7-8f2c-86a9b202a012	1dcd9cf1-c3d1-4538-bd38-f8976ae2d22e	Port	981d10e0-f17d-4dca-99aa-e5ca7a0c74ce	c9e22f9a-e030-4033-8dba-cdfabd0f9b10	2026-02-02 19:01:57.822249+00	2026-02-02 19:01:57.822249+00
\.


--
-- Data for Name: credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.credentials (id, organization_id, name, credential_type, target_ips, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, version, user_id, api_key_id, is_unreachable, standby, standby_cleared_at) FROM stdin;
8cab808e-7aba-49fc-b25d-2b734277ec79	a9101e7c-c74f-44a7-8f2c-86a9b202a012	dd6f90d2-d1df-49c8-bba4-cf36f7343201	2026-04-28 19:08:58.152064+00	2026-04-28 19:13:45.951692+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["3c01d70b-8334-4bcd-912d-d2a874de3344"]}	2026-04-28 19:08:58.152064+00	"daemon_poll"		scanopy-daemon	0.14.2	2b8d04d6-6fbb-4971-9a46-954a73e088c1	\N	f	f	\N
412203a9-366b-4fad-98f0-50d2c047583a	a9101e7c-c74f-44a7-8f2c-86a9b202a012	c16a9026-e029-4161-8963-20186c87d56c	2026-04-28 19:10:03.209165+00	2026-04-28 19:13:57.865045+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["3c01d70b-8334-4bcd-912d-d2a874de3344", "3c9343a9-cd9f-4946-b16a-b17efba0e278"]}	2026-04-28 19:10:03.209165+00	"server_poll"	http://daemon-serverpoll:60074	scanopy-daemon-serverpoll	0.16.2	2b8d04d6-6fbb-4971-9a46-954a73e088c1	37e3a835-c3df-4334-a911-2783ec07eb1a	f	f	2026-04-28 19:13:57.865046+00
\.


--
-- Data for Name: dependencies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dependencies (id, network_id, name, description, created_at, updated_at, source, color, edge_style, dependency_type, member_type) FROM stdin;
b1439187-de40-4f3d-b322-d8f16403eb97	a9101e7c-c74f-44a7-8f2c-86a9b202a012		\N	2026-04-28 19:13:27.749193+00	2026-04-28 19:13:27.749193+00	{"type": "Manual"}	Yellow	"SmoothStep"	RequestPath	Services
\.


--
-- Data for Name: dependency_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dependency_members (id, dependency_id, binding_id, "position", created_at, service_id) FROM stdin;
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, scan_count, force_full_scan, pending_credential_ids) FROM stdin;
ff17792b-b48a-406e-b52d-9ca3815a3f85	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Scheduled", "enabled": true, "last_run": "2026-04-28T19:08:58.161926467Z", "timezone": null, "cron_schedule": "0 0 0 * * 0"}	{"type": "Unified", "host_id": "dd6f90d2-d1df-49c8-bba4-cf36f7343201", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:08:58.15959+00	2026-04-28 19:10:02.818039+00	1	f	{}
5e2345ff-fcf1-458b-b998-1ed4b7b5de22	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "c30ae4d6-aa01-4253-94db-acdabf3a54e4", "started_at": "2026-04-28T19:09:10.681879638Z", "finished_at": "2026-04-28T19:10:02.803061976Z", "discovery_id": "ff17792b-b48a-406e-b52d-9ca3815a3f85", "discovery_type": {"type": "Unified", "host_id": "dd6f90d2-d1df-49c8-bba4-cf36f7343201", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": 5, "estimated_remaining_secs": 30}}	{"type": "Unified", "host_id": "dd6f90d2-d1df-49c8-bba4-cf36f7343201", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:09:10.681879+00	2026-04-28 19:10:02.816394+00	0	f	{}
7c7a9777-abb3-4450-8919-0a4b7be81973	a9101e7c-c74f-44a7-8f2c-86a9b202a012	412203a9-366b-4fad-98f0-50d2c047583a	{"type": "Scheduled", "enabled": true, "last_run": "2026-04-28T19:10:26.610081257Z", "timezone": null, "cron_schedule": "0 0 0 * * 0"}	{"type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:10:26.607906+00	2026-04-28 19:10:26.610081+00	0	f	{}
774494b8-85ff-468c-afb6-0d7b65d4c042	a9101e7c-c74f-44a7-8f2c-86a9b202a012	412203a9-366b-4fad-98f0-50d2c047583a	{"type": "AdHoc", "last_run": "2026-04-28T19:10:03.605073073Z"}	{"type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	ServerPoll Integration Test Discovery	2026-04-28 19:10:03.592401+00	2026-04-28 19:13:27.703788+00	1	f	{}
bb76b176-e846-4577-ba1c-0b129c03b53a	a9101e7c-c74f-44a7-8f2c-86a9b202a012	412203a9-366b-4fad-98f0-50d2c047583a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "8dab7a99-5955-498a-b597-5e7bb0e5d62a", "started_at": "2026-04-28T19:10:56.673393389Z", "finished_at": "2026-04-28T19:13:27.688523567Z", "discovery_id": "774494b8-85ff-468c-afb6-0d7b65d4c042", "discovery_type": {"type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": 5, "estimated_remaining_secs": 30}}	{"type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:10:56.673393+00	2026-04-28 19:13:27.702801+00	0	f	{}
594a9632-4441-42ca-8978-caa6414bf8e8	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 5, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "2abdbee0-ac03-472c-b137-4321f33f03ca", "started_at": "2026-04-28T19:13:47.042173662Z", "finished_at": "2026-04-28T19:13:47.051218082Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Unified", "host_id": "d4cf5d4f-39ce-4bc8-9692-0398c5897364", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Unified", "host_id": "d4cf5d4f-39ce-4bc8-9692-0398c5897364", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:13:47.042173+00	2026-04-28 19:13:47.060183+00	0	f	{}
3c73d6fb-53ed-4b19-8861-afbc79cfd862	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "bbe36108-56c4-4d82-9087-e577842ff202", "started_at": "2026-04-28T19:13:48.854908474Z", "finished_at": "2026-04-28T19:13:48.864913886Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:48.854908+00	2026-04-28 19:13:48.875808+00	0	f	{}
d9b7660d-e1ff-4a1a-8783-e715c5d8d76e	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "abba33fb-bf1f-4e8b-985f-6a2d0b5d0380", "started_at": "2026-04-28T19:13:47.216391135Z", "finished_at": "2026-04-28T19:13:47.226060104Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:47.216391+00	2026-04-28 19:13:47.239013+00	0	f	{}
f3b772ed-aa75-4409-83a5-b0c3e6cff89a	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "b64df0ca-f173-4ba8-a48b-edf7e372974a", "started_at": "2026-04-28T19:13:47.485735030Z", "finished_at": "2026-04-28T19:13:47.495690278Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "SelfReport", "host_id": "09900acc-93fd-4af9-8a9b-9f45ace7475c"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "SelfReport", "host_id": "09900acc-93fd-4af9-8a9b-9f45ace7475c"}	Self Report — My Network	2026-04-28 19:13:47.485735+00	2026-04-28 19:13:47.504889+00	0	f	{}
2c713591-9521-41ed-bac0-3d5cd735a6b7	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "59fba01e-fefd-4c66-9ef2-a85c0e76a811", "started_at": "2026-04-28T19:13:47.763597271Z", "finished_at": "2026-04-28T19:13:47.774454252Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:47.763597+00	2026-04-28 19:13:47.785574+00	0	f	{}
a55adc35-0147-4d58-962a-5db9dc955d59	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "10fdd8f4-03b6-44ea-adb6-27e74136b365", "started_at": "2026-04-28T19:13:48.040118948Z", "finished_at": "2026-04-28T19:13:48.050693247Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:48.040118+00	2026-04-28 19:13:48.061715+00	0	f	{}
d92bce34-6e9c-4f2f-8e5e-136a8d9e7b8a	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "4273fe18-d031-4977-950e-ad5a49d2ea8e", "started_at": "2026-04-28T19:13:48.315455631Z", "finished_at": "2026-04-28T19:13:48.326226462Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:48.315455+00	2026-04-28 19:13:48.337327+00	0	f	{}
980d3f55-912d-4ac1-ae3c-588a65ca5684	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "3b0868af-d558-45e3-b688-2cf55472b6ee", "started_at": "2026-04-28T19:13:49.129221641Z", "finished_at": "2026-04-28T19:13:49.138879902Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:49.129221+00	2026-04-28 19:13:49.149046+00	0	f	{}
1a646907-f2a2-4abd-b18c-2c93278957f9	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "0ffe5496-d64e-41a0-ab86-ff28eed28819", "started_at": "2026-04-28T19:13:51.046636580Z", "finished_at": "2026-04-28T19:13:51.057257995Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:51.046636+00	2026-04-28 19:13:51.067953+00	0	f	{}
c120a99f-e63b-4538-88f9-567d57cbfd2a	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "f2d5414b-3369-4280-929d-5422dd11a4b4", "started_at": "2026-04-28T19:13:52.401098575Z", "finished_at": "2026-04-28T19:13:52.412083917Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "SelfReport", "host_id": "8f6b3991-b3ef-4d1d-9708-d2f57289a34f"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "SelfReport", "host_id": "8f6b3991-b3ef-4d1d-9708-d2f57289a34f"}	Self Report — My Network	2026-04-28 19:13:52.401098+00	2026-04-28 19:13:52.4202+00	0	f	{}
0725a4f5-52c6-4ef7-80da-14f3ce823720	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "5b19fece-cb82-45d8-a676-df53cc38a014", "started_at": "2026-04-28T19:13:48.583223975Z", "finished_at": "2026-04-28T19:13:48.592516449Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}	Self Report — My Network	2026-04-28 19:13:48.583223+00	2026-04-28 19:13:48.601399+00	0	f	{}
9c3bc1b1-3d32-4e67-b10a-a568e07740d7	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "27ff5779-08b0-4970-aebd-04649d27c725", "started_at": "2026-04-28T19:13:54.054084811Z", "finished_at": "2026-04-28T19:13:54.065613426Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:54.054084+00	2026-04-28 19:13:54.076803+00	0	f	{}
13bf319d-0843-4df1-b942-7ed1bb317ad6	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "5bd5e93e-a606-4c6e-b159-b04879bdd801", "started_at": "2026-04-28T19:13:49.403644348Z", "finished_at": "2026-04-28T19:13:49.414622018Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:49.403644+00	2026-04-28 19:13:49.425963+00	0	f	{}
15ecdceb-5940-4d0d-ae61-745ff1747ab9	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "6845dcc8-6ea0-47af-9ce3-054b8cf1f667", "started_at": "2026-04-28T19:13:49.670622507Z", "finished_at": "2026-04-28T19:13:49.680237888Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "SelfReport", "host_id": "1438e666-92b6-4fad-bc37-aa2717d9ba42"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "SelfReport", "host_id": "1438e666-92b6-4fad-bc37-aa2717d9ba42"}	Self Report — My Network	2026-04-28 19:13:49.670622+00	2026-04-28 19:13:49.689262+00	0	f	{}
8d2fe66f-7d22-49d8-9b5f-49e9f19cacc1	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 5, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "b049b806-80fc-4dc5-9400-f19f9a9857ff", "started_at": "2026-04-28T19:13:50.044074300Z", "finished_at": "2026-04-28T19:13:50.052993034Z", "discovery_id": "0f49ac2a-3bcc-4880-8623-073c6e609c41", "discovery_type": {"type": "Unified", "host_id": "37d3a1d8-b76b-4e2e-96e0-74362358f4f4", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Unified", "host_id": "37d3a1d8-b76b-4e2e-96e0-74362358f4f4", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:13:50.044074+00	2026-04-28 19:13:50.061019+00	0	f	{}
c484e127-bc91-42fc-a746-53a4c4a04b5c	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "857fbace-0358-4642-8ca0-b14bb999f353", "started_at": "2026-04-28T19:13:50.488728566Z", "finished_at": "2026-04-28T19:13:50.500210994Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:50.488728+00	2026-04-28 19:13:50.511656+00	0	f	{}
8afb1f78-830a-40fa-a9d5-ae7d6fe050e6	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "7f54ecab-3771-4583-a7d0-f12569030e17", "started_at": "2026-04-28T19:13:51.589810790Z", "finished_at": "2026-04-28T19:13:51.600749099Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "SelfReport", "host_id": "f738b076-a24e-4db2-800c-a0f10bb44b16"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "SelfReport", "host_id": "f738b076-a24e-4db2-800c-a0f10bb44b16"}	Self Report — My Network	2026-04-28 19:13:51.58981+00	2026-04-28 19:13:51.610961+00	0	f	{}
cc215c9b-13e0-4f3b-87c3-cbc58941b268	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 5, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "d2c685dd-56ad-4d49-9d36-c64b0483a15a", "started_at": "2026-04-28T19:13:51.965981309Z", "finished_at": "2026-04-28T19:13:51.975465736Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Unified", "host_id": "5a5b21eb-2566-4e13-83d8-00cb2675bde6", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Unified", "host_id": "5a5b21eb-2566-4e13-83d8-00cb2675bde6", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:13:51.965981+00	2026-04-28 19:13:51.983572+00	0	f	{}
036701b9-c095-4bf3-af41-49e6d9dada44	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 5, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "d2b26f9b-0329-4191-8a60-58cf3c796dba", "started_at": "2026-04-28T19:13:52.238838238Z", "finished_at": "2026-04-28T19:13:52.248970265Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Unified", "host_id": "9f1349e1-04dc-47e8-9a78-0c483e2a16a6", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Unified", "host_id": "9f1349e1-04dc-47e8-9a78-0c483e2a16a6", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:13:52.238838+00	2026-04-28 19:13:52.257403+00	0	f	{}
5fe23e5a-ae31-43ee-a93f-f3a56bf8494d	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "969d115c-0112-4ba3-8757-bb1ece340112", "started_at": "2026-04-28T19:13:50.214147553Z", "finished_at": "2026-04-28T19:13:50.224824472Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:50.214147+00	2026-04-28 19:13:50.236246+00	0	f	{}
6b09a3a0-5a98-4989-a0ff-a7786c33ef3c	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "c10d2eae-1267-4023-997e-5a51fdf97281", "started_at": "2026-04-28T19:13:50.765518507Z", "finished_at": "2026-04-28T19:13:50.775634580Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:50.765518+00	2026-04-28 19:13:50.786539+00	0	f	{}
15dee8ed-36c2-47f0-98f9-141f6caab76e	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "22ea697f-065c-4d2e-a81f-0809764aad01", "started_at": "2026-04-28T19:13:51.321164002Z", "finished_at": "2026-04-28T19:13:51.331786714Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:51.321164+00	2026-04-28 19:13:51.342605+00	0	f	{}
477e881a-0fc6-4a03-bd06-4237901e0a68	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "f2d5414b-3369-4280-929d-5422dd11a4b4", "started_at": "2026-04-28T19:13:54.872387641Z", "finished_at": "2026-04-28T19:13:54.886365074Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "SelfReport", "host_id": "8f6b3991-b3ef-4d1d-9708-d2f57289a34f"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "SelfReport", "host_id": "8f6b3991-b3ef-4d1d-9708-d2f57289a34f"}	Self Report — My Network	2026-04-28 19:13:54.872387+00	2026-04-28 19:13:54.902313+00	0	f	{}
a9f5b5f8-6228-47f7-b85c-08ba27c92746	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 5, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "6465c546-3856-4e33-9cd0-5b8a8d99d55b", "started_at": "2026-04-28T19:13:52.776756051Z", "finished_at": "2026-04-28T19:13:52.786820801Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Unified", "host_id": "5ef6e4af-f8ab-48d8-9b0e-6f4b93a49ef0", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Unified", "host_id": "5ef6e4af-f8ab-48d8-9b0e-6f4b93a49ef0", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:13:52.776756+00	2026-04-28 19:13:52.795143+00	0	f	{}
a00452fc-32c4-431a-95db-048dd1734bcb	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 5, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "34fe487d-22ef-418c-9099-42fa3376ded0", "started_at": "2026-04-28T19:13:53.051638952Z", "finished_at": "2026-04-28T19:13:53.061076793Z", "discovery_id": "6b552988-a1be-4f68-8187-f69624148974", "discovery_type": {"type": "Unified", "host_id": "e9d19327-eb77-47c7-85d4-e590c7aa90a1", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Unified", "host_id": "e9d19327-eb77-47c7-85d4-e590c7aa90a1", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:13:53.051638+00	2026-04-28 19:13:53.069241+00	0	f	{}
3995c5db-165f-4637-866d-4bb0aa9a09cd	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "ec9dc330-67d0-4ce5-94d8-506859c74940", "started_at": "2026-04-28T19:13:53.222699350Z", "finished_at": "2026-04-28T19:13:53.234413064Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:53.222699+00	2026-04-28 19:13:53.245489+00	0	f	{}
4e096e48-0a48-4277-ae1d-39d477455f9d	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "34c804c2-c01c-4104-a3b3-e31ae6dd0b6f", "started_at": "2026-04-28T19:13:54.596877638Z", "finished_at": "2026-04-28T19:13:54.609262885Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:54.596877+00	2026-04-28 19:13:54.621261+00	0	f	{}
95c88514-1dab-4fe1-a80a-1630036d9c2a	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "5e741620-3de9-476c-86e7-7ce656d0a5a8", "started_at": "2026-04-28T19:13:53.499245401Z", "finished_at": "2026-04-28T19:13:53.510296679Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery — My Network	2026-04-28 19:13:53.499245+00	2026-04-28 19:13:53.521443+00	0	f	{}
1786c8c9-b90f-474f-b724-efd89a016738	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 5, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "032af69a-4335-4c54-ac9c-8941c44050a3", "started_at": "2026-04-28T19:13:53.881386117Z", "finished_at": "2026-04-28T19:13:53.891212338Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "Unified", "host_id": "39d3169e-1a02-41e6-b3c6-db9716ae6ad4", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "Unified", "host_id": "39d3169e-1a02-41e6-b3c6-db9716ae6ad4", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}	Discovery	2026-04-28 19:13:53.881386+00	2026-04-28 19:13:53.899563+00	0	f	{}
426b94ba-f998-4908-adc2-7563d83028ed	a9101e7c-c74f-44a7-8f2c-86a9b202a012	8cab808e-7aba-49fc-b25d-2b734277ec79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "session_id": "c8c6530c-aaff-4d7c-a872-ba4457906d77", "started_at": "2026-04-28T19:13:54.322575273Z", "finished_at": "2026-04-28T19:13:54.333415Z", "discovery_id": "00000000-0000-0000-0000-000000000000", "discovery_type": {"type": "SelfReport", "host_id": "cc741d90-bcc0-4653-b38b-52b23f9e6a61"}, "hosts_discovered": null, "estimated_remaining_secs": null}}	{"type": "SelfReport", "host_id": "cc741d90-bcc0-4653-b38b-52b23f9e6a61"}	Self Report — My Network	2026-04-28 19:13:54.322575+00	2026-04-28 19:13:54.342621+00	0	f	{}
\.


--
-- Data for Name: entity_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_tags (id, entity_id, entity_type, tag_id, created_at) FROM stdin;
376e7274-37db-40e9-bf8f-ee12491731c9	2f56895c-4235-4052-98c9-fb3a97a94c4f	"Service"	16076369-b3b6-4668-9103-67974c1a3d2c	2026-04-28 19:13:27.739093+00
\.


--
-- Data for Name: host_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.host_credentials (host_id, credential_id, ip_address_ids) FROM stdin;
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden, sys_descr, sys_object_id, sys_location, sys_contact, management_url, chassis_id, manufacturer, model, serial_number, sys_name) FROM stdin;
37e5888d-4a4e-4ca3-908c-a8939cc75bdd	a9101e7c-c74f-44a7-8f2c-86a9b202a012	f7627b151529	f7627b151529	Scanopy daemon	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:01:57.822232414Z", "type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd", "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79"}]}	null	2026-02-02 19:01:57.822235+00	2026-02-02 19:01:57.822235+00	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, host_id, network_id, created_at, updated_at, if_index, if_descr, if_alias, if_type, speed_bps, admin_status, oper_status, mac_address, ip_address_id, neighbor_interface_id, neighbor_host_id, lldp_chassis_id, lldp_port_id, lldp_sys_name, lldp_port_desc, lldp_mgmt_addr, lldp_sys_desc, cdp_device_id, cdp_port_id, cdp_platform, cdp_address, if_name, fdb_macs, native_vlan_id, vlan_ids) FROM stdin;
\.


--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invites (id, organization_id, permissions, network_ids, url, created_by, created_at, updated_at, expires_at, send_to) FROM stdin;
\.


--
-- Data for Name: ip_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ip_addresses (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
981d10e0-f17d-4dca-99aa-e5ca7a0c74ce	a9101e7c-c74f-44a7-8f2c-86a9b202a012	37e5888d-4a4e-4ca3-908c-a8939cc75bdd	3c01d70b-8334-4bcd-912d-d2a874de3344	172.25.0.4	36:cf:1e:78:da:59	eth0	0	2026-02-02 19:01:57.8134+00	2026-02-02 19:01:57.8134+00
\.


--
-- Data for Name: network_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.network_credentials (network_id, credential_id) FROM stdin;
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, organization_id) FROM stdin;
a9101e7c-c74f-44a7-8f2c-86a9b202a012	My Network	2026-04-28 19:08:58.095312+00	2026-04-28 19:08:58.095312+00	edb3927c-a982-43b6-bc72-f791fd69cb26
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding, brevo_company_id, has_payment_method, trial_end_date, plan_limit_notifications, use_case) FROM stdin;
edb3927c-a982-43b6-bc72-f791fd69cb26	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "host_cents": null, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_hosts": null, "included_seats": null, "included_networks": null}	active	2026-04-28 19:08:58.083366+00	2026-04-28 19:08:58.083366+00	["OnboardingModalCompleted", "OrgCreated", "FirstDaemonRegistered", "FirstHostDiscovered", "FirstDiscoveryCompleted", "FirstTagCreated", "FirstDependencyCreated", "FirstUserApiKeyCreated", "SecondNetworkCreated"]	\N	f	\N	{"hosts": "None", "seats": "None", "networks": "None"}	other
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
c9e22f9a-e030-4033-8dba-cdfabd0f9b10	a9101e7c-c74f-44a7-8f2c-86a9b202a012	37e5888d-4a4e-4ca3-908c-a8939cc75bdd	60073	Tcp	Custom	2026-02-02 19:01:57.82206+00	2026-02-02 19:01:57.82206+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, "position") FROM stdin;
1dcd9cf1-c3d1-4538-bd38-f8976ae2d22e	a9101e7c-c74f-44a7-8f2c-86a9b202a012	2026-02-02 19:01:57.822253+00	2026-02-02 19:01:57.822253+00	Scanopy Daemon	37e5888d-4a4e-4ca3-908c-a8939cc75bdd	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-02-02T19:01:57.822252701Z", "type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd", "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79"}]}	0
\.


--
-- Data for Name: shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shares (id, topology_id, network_id, created_by, name, is_enabled, expires_at, password_hash, allowed_domains, options, created_at, updated_at, enabled_views) FROM stdin;
\.


--
-- Data for Name: subnet_vlans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnet_vlans (id, subnet_id, vlan_id, created_at) FROM stdin;
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, virtualization) FROM stdin;
3c01d70b-8334-4bcd-912d-d2a874de3344	a9101e7c-c74f-44a7-8f2c-86a9b202a012	2026-02-02 19:01:57.798041+00	2026-02-02 19:01:57.798041+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:01:57.798036957Z", "type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd", "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79"}]}	null
3c9343a9-cd9f-4946-b16a-b17efba0e278	a9101e7c-c74f-44a7-8f2c-86a9b202a012	2026-04-28 19:13:56.596105+00	2026-04-28 19:13:56.596105+00	"127.0.0.0/8"	127.0.0.0/8	\N	Loopback	{"type": "Discovery", "metadata": [{"date": "2026-04-28T19:13:56.596101838Z", "type": "SelfReport", "host_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79"}]}	null
81a31053-a411-421f-a28f-e597e3767c94	a9101e7c-c74f-44a7-8f2c-86a9b202a012	2026-04-28 19:13:56.88449+00	2026-04-28 19:13:56.88449+00	"10.1.0.0/24"	Blocked Subnet	\N	Lan	{"type": "System"}	null
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color, is_application) FROM stdin;
16076369-b3b6-4668-9103-67974c1a3d2c	edb3927c-a982-43b6-bc72-f791fd69cb26	Integration Test Tag	\N	2026-04-28 19:13:27.717782+00	2026-04-28 19:13:27.717782+00	Yellow	f
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, dependencies, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_dependencies, parent_id, created_at, updated_at, tags, ip_addresses, removed_ip_addresses, ports, removed_ports, bindings, removed_bindings, interfaces, removed_interfaces, entity_tags, vlans) FROM stdin;
2915ac4e-1a3a-4ab8-8419-910ec586accb	a9101e7c-c74f-44a7-8f2c-86a9b202a012	My Topology	[]	[]	{"local": {"tag_filter": {"hidden_host_tag_ids": [], "hidden_subnet_tag_ids": [], "hidden_service_tag_ids": []}, "bundle_edges": true, "show_minimap": true, "no_fade_edges": false, "hide_edge_types": ["Hypervisor"]}, "request": {"view": "L3Logical", "element_rules": [{"id": "8c57934d-056e-4215-a39d-114bc825ba70", "rule": "ByTrunkPort"}, {"id": "275b3b64-282e-4732-a77d-11e2d7675768", "rule": "ByVLAN"}, {"id": "546383c6-2564-40cc-b368-895a8f993938", "rule": "ByPortOpStatus"}, {"id": "32abb83e-4189-419b-be6f-f3986fdceff5", "rule": {"ByServiceCategory": {"title": "Infrastructure", "categories": ["NetworkCore", "NetworkAccess", "RemoteAccess", "Workstation", "Mobile", "Printer", "OpenPorts"], "is_infra_rule": true}}}, {"id": "f578a330-873d-4ea6-bb8a-e2472b50427b", "rule": {"ByTag": {"title": null, "tag_ids": []}}}, {"id": "51da4cd2-bc3a-45b3-99b2-05d76d65cab1", "rule": "ByHypervisor"}, {"id": "cf16d568-bb03-4a24-a005-d7bedea37b19", "rule": "ByContainerRuntime"}, {"id": "eda73671-c537-4614-8f58-8df19a26bd29", "rule": "ByStack"}], "hide_entities": {}, "container_rules": {"L3Logical": [{"id": "6df6cb84-c400-485e-b7dc-3b3ba270d269", "rule": "BySubnet"}, {"id": "5387cb5f-705b-4463-9551-b031dba1f0f0", "rule": "MergeDockerBridges"}], "Workloads": [{"id": "9579ee1a-f914-47b8-92ca-501dfea33781", "rule": "ByHost"}], "L2Physical": [{"id": "9579ee1a-f914-47b8-92ca-501dfea33781", "rule": "ByHost"}], "Application": [{"id": "97e9c498-ee10-4ce7-9583-a60319ece7c3", "rule": {"ByApplication": {"tag_ids": []}}}]}, "hide_metadata_values": {"L3Logical": {"Service": {"Category": ["OpenPorts"]}}, "Workloads": {"Service": {"Category": ["OpenPorts"]}}, "L2Physical": {"Service": {"Category": ["OpenPorts"]}}, "Application": {"Service": {"Category": ["OpenPorts"]}}}}}	[]	[{"id": "3c01d70b-8334-4bcd-912d-d2a874de3344", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-02-02T19:01:57.798036957Z", "type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd", "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79"}]}, "created_at": "2026-02-02T19:01:57.798041Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-02-02T19:01:57.798041Z", "description": null, "subnet_type": "Lan"}, {"id": "3c9343a9-cd9f-4946-b16a-b17efba0e278", "cidr": "127.0.0.0/8", "name": "127.0.0.0/8", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-04-28T19:13:56.596101838Z", "type": "SelfReport", "host_id": "8cab808e-7aba-49fc-b25d-2b734277ec79", "daemon_id": "8cab808e-7aba-49fc-b25d-2b734277ec79"}]}, "created_at": "2026-04-28T19:13:56.596105Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:13:56.596105Z", "description": null, "subnet_type": "Loopback"}, {"id": "81a31053-a411-421f-a28f-e597e3767c94", "cidr": "10.1.0.0/24", "name": "Blocked Subnet", "tags": [], "source": {"type": "System"}, "created_at": "2026-04-28T19:13:56.884490Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:13:56.884490Z", "description": null, "subnet_type": "Lan"}]	[{"id": "c601f786-35c1-4cb0-b60a-e7985cd8577d", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-04-28T19:10:56.683112764Z", "type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}]}, "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "bindings": [{"id": "d017d6ac-7ac0-4665-a160-53f232f60577", "type": "Port", "port_id": "804d5bde-ede3-4231-a684-9fff69d82f80", "created_at": "2026-04-28T19:10:56.683107Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "c601f786-35c1-4cb0-b60a-e7985cd8577d", "updated_at": "2026-04-28T19:10:56.683107Z", "ip_address_id": "7d7a7d56-cc45-46f1-86a5-40df00f6fd46"}, {"id": "e42cab7e-9395-4264-a315-8502ccc849f3", "type": "Port", "port_id": "804d5bde-ede3-4231-a684-9fff69d82f80", "created_at": "2026-04-28T19:10:56.683110Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "c601f786-35c1-4cb0-b60a-e7985cd8577d", "updated_at": "2026-04-28T19:10:56.683110Z", "ip_address_id": "9b4dece9-4b57-424e-b670-05324c02fede"}], "position": 0, "created_at": "2026-04-28T19:10:56.683113Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:10:56.683113Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "2f56895c-4235-4052-98c9-fb3a97a94c4f", "name": "Home Assistant", "tags": ["16076369-b3b6-4668-9103-67974c1a3d2c"], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-04-28T19:12:37.193817272Z", "type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}]}, "host_id": "0f8fcd02-2be6-46f6-9b83-4000503a9cd7", "bindings": [{"id": "5243b246-666a-4529-9813-5adbefc4b9fe", "type": "Port", "port_id": "befbe7ee-22dc-4407-bcdc-f89d89b4444c", "created_at": "2026-04-28T19:12:37.193830Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "2f56895c-4235-4052-98c9-fb3a97a94c4f", "updated_at": "2026-04-28T19:12:37.193830Z", "ip_address_id": "361889ee-fdff-437b-9f27-3a254dfbef57"}], "position": 0, "created_at": "2026-04-28T19:12:37.193834Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:12:37.193834Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "45967e0b-52ff-464c-8c0b-35ded1bdfb85", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-04-28T19:12:37.271574885Z", "type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}]}, "host_id": "2dde5dd6-3392-4c86-ac81-4bf8f11fb26e", "bindings": [{"id": "64a5857b-875e-4901-bc1f-a3d7b345ebda", "type": "Port", "port_id": "3734cd06-7627-466f-bde3-f3285462070e", "created_at": "2026-04-28T19:12:37.271587Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "45967e0b-52ff-464c-8c0b-35ded1bdfb85", "updated_at": "2026-04-28T19:12:37.271587Z", "ip_address_id": "f0f2dcf7-a36e-4b9b-bc85-f411b94054e7"}], "position": 0, "created_at": "2026-04-28T19:12:37.271591Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:12:37.271591Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "41dc0df5-4c00-4355-b4c5-a619bfd9c81b", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.4:60073/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-04-28T19:12:37.272836458Z", "type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}]}, "host_id": "1da50b62-cc81-4486-ad04-1bffccfac763", "bindings": [{"id": "ec0310c5-abea-495d-99a3-5d0bfd63684e", "type": "Port", "port_id": "96af81f3-ff2d-4dda-8e42-f12632be46d3", "created_at": "2026-04-28T19:12:37.272845Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "41dc0df5-4c00-4355-b4c5-a619bfd9c81b", "updated_at": "2026-04-28T19:12:37.272845Z", "ip_address_id": "fcf36003-c1bc-47e0-84e0-b627b0d04b53"}], "position": 0, "created_at": "2026-04-28T19:12:37.272848Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:12:37.272848Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "8c34b3b5-920c-4618-b3e2-deafcaf94dca", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-04-28T19:12:37.295385907Z", "type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}]}, "host_id": "392758eb-8602-4675-8648-9559ba9f8fd9", "bindings": [{"id": "ede2097e-06fc-44de-b8b5-2462957e20c5", "type": "Port", "port_id": "2a148539-b354-402d-9282-f53ba03cbe2e", "created_at": "2026-04-28T19:12:37.295395Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "8c34b3b5-920c-4618-b3e2-deafcaf94dca", "updated_at": "2026-04-28T19:12:37.295395Z", "ip_address_id": "6fa590c8-be1a-48d3-ad2c-c50edea09de5"}], "position": 0, "created_at": "2026-04-28T19:12:37.295400Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:12:37.295400Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "e48c0b2f-614a-49ab-abac-688bbc2210f3", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-04-28T19:12:47.151853583Z", "type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}]}, "host_id": "55db7c5c-82f9-48ca-b0fc-3917b7db5f00", "bindings": [{"id": "82337989-413f-4a5e-9631-e7d5bf1fd9f4", "type": "Port", "port_id": "e63bb8c2-e260-40f9-8503-b1e0232ff41b", "created_at": "2026-04-28T19:12:47.151865Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "e48c0b2f-614a-49ab-abac-688bbc2210f3", "updated_at": "2026-04-28T19:12:47.151865Z", "ip_address_id": "0cec7326-12d2-4fc4-a796-c2776b3c4e4e"}], "position": 0, "created_at": "2026-04-28T19:12:47.151871Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:12:47.151871Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "5aba5340-1b4b-417a-be8f-f86177d7fc5a", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-04-28T19:12:47.158693974Z", "type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}]}, "host_id": "55db7c5c-82f9-48ca-b0fc-3917b7db5f00", "bindings": [{"id": "2fe6494b-9265-4c41-aaf7-88616ec189b9", "type": "Port", "port_id": "86015533-b78c-4c5e-b3dc-bb9c46827daf", "created_at": "2026-04-28T19:12:47.158702Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "5aba5340-1b4b-417a-be8f-f86177d7fc5a", "updated_at": "2026-04-28T19:12:47.158702Z", "ip_address_id": "0cec7326-12d2-4fc4-a796-c2776b3c4e4e"}], "position": 1, "created_at": "2026-04-28T19:12:47.158705Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:12:47.158705Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "02158a17-fef7-421e-830f-cee546c983cd", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-04-28T19:12:47.160132330Z", "type": "Unified", "host_id": "c16a9026-e029-4161-8963-20186c87d56c", "daemon_id": "412203a9-366b-4fad-98f0-50d2c047583a", "subnet_ids": null, "scan_settings": {"arp_retries": null, "arp_rate_pps": null, "is_full_scan": false, "scan_rate_pps": null, "use_npcap_arp": false, "arp_scan_cutoff": null, "full_scan_interval": null, "port_scan_batch_size": null, "probe_raw_socket_ports": false}, "host_naming_fallback": "BestService"}]}, "host_id": "55db7c5c-82f9-48ca-b0fc-3917b7db5f00", "bindings": [{"id": "3558deb5-74fe-4e36-939f-3399c4f3d504", "type": "Port", "port_id": "19442a3f-ebb1-4f09-b41d-8bc395399894", "created_at": "2026-04-28T19:12:47.160140Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "service_id": "02158a17-fef7-421e-830f-cee546c983cd", "updated_at": "2026-04-28T19:12:47.160140Z", "ip_address_id": "0cec7326-12d2-4fc4-a796-c2776b3c4e4e"}], "position": 2, "created_at": "2026-04-28T19:12:47.160144Z", "network_id": "a9101e7c-c74f-44a7-8f2c-86a9b202a012", "updated_at": "2026-04-28T19:12:47.160144Z", "virtualization": null, "service_definition": "SSH"}]	[]	t	2026-04-28 19:08:58.117202+00	f	\N	\N	{b7744824-5826-4cae-8b3e-87238d0e29f9,9208768f-c799-4dda-80b4-e08caf2c4d45,8907f92f-decd-4686-8abf-409f04e7933f}	{f8f2d23e-9df0-4755-b0ed-b486d9fd34a1}	{662672b7-780a-411b-a045-b2cce7ac1ed0}	{c9d662f2-a63b-42cd-9098-cc9916040e9c}	\N	2026-04-28 19:08:58.102987+00	2026-04-28 19:08:58.102987+00	{}	[]	{}	[]	{}	[]	{}	[]	{}	[]	[]
\.


--
-- Data for Name: user_api_key_network_access; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_api_key_network_access (id, api_key_id, network_id, created_at) FROM stdin;
\.


--
-- Data for Name: user_api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_api_keys (id, key, user_id, organization_id, permissions, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
\.


--
-- Data for Name: user_network_access; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_network_access (id, user_id, network_id, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, tags, terms_accepted_at, email_verified, email_verification_token, email_verification_expires, password_reset_token, password_reset_expires, pending_email) FROM stdin;
2b8d04d6-6fbb-4971-9a46-954a73e088c1	2026-04-28 19:08:58.08588+00	2026-04-28 19:08:58.08588+00	$argon2id$v=19$m=19456,t=2,p=1$aGtstsW0tKFSDrB/eat2NQ$u57WaJR/rfoeXy1438+TITkX5bNfz9CR/+OgFlhmhCY	\N	\N	\N	user@gmail.com	edb3927c-a982-43b6-bc72-f791fd69cb26	Owner	{}	\N	t	\N	\N	\N	\N	\N
4eb75cb1-b9be-4232-ad3c-0f8c2ac6b4c9	2026-04-28 19:13:56.510538+00	2026-04-28 19:13:56.510538+00	\N	\N	\N	\N	user@example.com	edb3927c-a982-43b6-bc72-f791fd69cb26	Owner	{}	\N	f	\N	\N	\N	\N	\N
\.


--
-- Data for Name: vlans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vlans (id, vlan_number, name, description, network_id, organization_id, source, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
ZU6elzTey210fNdSEyCDCQ	\\x93c4100983201352d77c746dcbde34979e4e6581a7757365725f6964d92432623864303464362d366662622d343937312d396134362d39353461373365303838633199cd07ea7d13083ace09f5006a000000	2026-05-05 19:08:58.167051+00
6Z-V960tWZX5HGrceiYtQA	\\x93c410402d267adc6a1cf995592dadf7959fe982a7757365725f6964d92432623864303464362d366662622d343937312d396134362d393534613733653038386331ad70656e64696e675f736574757082a76e6574776f726b83a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92439656439623934322d393334372d343831632d623335612d346561393337633363363665ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6e99cd07ea7d130d1cce285c42e9000000	2026-05-05 19:13:28.677135+00
hmYHLmcOuoCD-uJWZjx1Aw	\\x93c41003753c6656e2fa8380ba0e672e07668682ad70656e64696e675f736574757082a76e6574776f726b83a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92466393330353661612d633866382d346366342d383039352d323761343331376531646637ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92432623864303464362d366662622d343937312d396134362d39353461373365303838633199cd07ea7d130d2ece2091fe5a000000	2026-05-05 19:13:46.546438+00
fG1XSpl0VHYsUs7VeGbu8Q	\\x93c410f1ee6678d5ce522c765474994a576d7c82ad70656e64696e675f736574757082a76e6574776f726b83a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92431346236633061622d316234382d343565662d386562352d386165643166636232653365ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92432623864303464362d366662622d343937312d396134362d39353461373365303838633199cd07ea7d130d37ce1abf4e49000000	2026-05-05 19:13:55.448745+00
\.


--
-- Name: _sqlx_migrations _sqlx_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._sqlx_migrations
    ADD CONSTRAINT _sqlx_migrations_pkey PRIMARY KEY (version);


--
-- Name: api_keys api_keys_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_key_key UNIQUE (key);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: bindings bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bindings
    ADD CONSTRAINT bindings_pkey PRIMARY KEY (id);


--
-- Name: credentials credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_pkey PRIMARY KEY (id);


--
-- Name: daemons daemons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_pkey PRIMARY KEY (id);


--
-- Name: dependency_members dependency_members_dep_service_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dependency_members
    ADD CONSTRAINT dependency_members_dep_service_unique UNIQUE (dependency_id, service_id);


--
-- Name: discovery discovery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discovery
    ADD CONSTRAINT discovery_pkey PRIMARY KEY (id);


--
-- Name: entity_tags entity_tags_entity_id_entity_type_tag_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tags
    ADD CONSTRAINT entity_tags_entity_id_entity_type_tag_id_key UNIQUE (entity_id, entity_type, tag_id);


--
-- Name: entity_tags entity_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tags
    ADD CONSTRAINT entity_tags_pkey PRIMARY KEY (id);


--
-- Name: dependency_members group_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dependency_members
    ADD CONSTRAINT group_bindings_pkey PRIMARY KEY (id);


--
-- Name: dependencies groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dependencies
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: host_credentials host_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.host_credentials
    ADD CONSTRAINT host_credentials_pkey PRIMARY KEY (host_id, credential_id);


--
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: interfaces if_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT if_entries_pkey PRIMARY KEY (id);


--
-- Name: ip_addresses interfaces_host_id_subnet_id_ip_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_addresses
    ADD CONSTRAINT interfaces_host_id_subnet_id_ip_address_key UNIQUE (host_id, subnet_id, ip_address);


--
-- Name: ip_addresses interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_addresses
    ADD CONSTRAINT interfaces_pkey PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


--
-- Name: network_credentials network_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.network_credentials
    ADD CONSTRAINT network_credentials_pkey PRIMARY KEY (network_id, credential_id);


--
-- Name: networks networks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: ports ports_host_id_port_number_protocol_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_host_id_port_number_protocol_key UNIQUE (host_id, port_number, protocol);


--
-- Name: ports ports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


--
-- Name: subnet_vlans subnet_vlans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subnet_vlans
    ADD CONSTRAINT subnet_vlans_pkey PRIMARY KEY (id);


--
-- Name: subnet_vlans subnet_vlans_subnet_id_vlan_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subnet_vlans
    ADD CONSTRAINT subnet_vlans_subnet_id_vlan_id_key UNIQUE (subnet_id, vlan_id);


--
-- Name: subnets subnets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subnets
    ADD CONSTRAINT subnets_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: topologies topologies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topologies
    ADD CONSTRAINT topologies_pkey PRIMARY KEY (id);


--
-- Name: user_api_key_network_access user_api_key_network_access_api_key_id_network_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_api_key_network_access
    ADD CONSTRAINT user_api_key_network_access_api_key_id_network_id_key UNIQUE (api_key_id, network_id);


--
-- Name: user_api_key_network_access user_api_key_network_access_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_api_key_network_access
    ADD CONSTRAINT user_api_key_network_access_pkey PRIMARY KEY (id);


--
-- Name: user_api_keys user_api_keys_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT user_api_keys_key_key UNIQUE (key);


--
-- Name: user_api_keys user_api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT user_api_keys_pkey PRIMARY KEY (id);


--
-- Name: user_network_access user_network_access_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_network_access
    ADD CONSTRAINT user_network_access_pkey PRIMARY KEY (id);


--
-- Name: user_network_access user_network_access_user_id_network_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_network_access
    ADD CONSTRAINT user_network_access_user_id_network_id_key UNIQUE (user_id, network_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vlans vlans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vlans
    ADD CONSTRAINT vlans_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: tower_sessions; Owner: postgres
--

ALTER TABLE ONLY tower_sessions.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: idx_api_keys_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_api_keys_key ON public.api_keys USING btree (key);


--
-- Name: idx_api_keys_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_api_keys_network ON public.api_keys USING btree (network_id);


--
-- Name: idx_bindings_ip_address; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bindings_ip_address ON public.bindings USING btree (ip_address_id);


--
-- Name: idx_bindings_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bindings_network ON public.bindings USING btree (network_id);


--
-- Name: idx_bindings_port; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bindings_port ON public.bindings USING btree (port_id);


--
-- Name: idx_bindings_service; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bindings_service ON public.bindings USING btree (service_id);


--
-- Name: idx_credentials_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credentials_org ON public.credentials USING btree (organization_id);


--
-- Name: idx_credentials_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_credentials_type ON public.credentials USING btree (((credential_type ->> 'type'::text)));


--
-- Name: idx_daemon_host_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemon_host_id ON public.daemons USING btree (host_id);


--
-- Name: idx_daemons_api_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemons_api_key ON public.daemons USING btree (api_key_id) WHERE (api_key_id IS NOT NULL);


--
-- Name: idx_daemons_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemons_network ON public.daemons USING btree (network_id);


--
-- Name: idx_dependency_members_binding; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dependency_members_binding ON public.dependency_members USING btree (binding_id) WHERE (binding_id IS NOT NULL);


--
-- Name: idx_dependency_members_dependency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dependency_members_dependency ON public.dependency_members USING btree (dependency_id);


--
-- Name: idx_dependency_members_service; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dependency_members_service ON public.dependency_members USING btree (service_id);


--
-- Name: idx_discovery_daemon; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_discovery_daemon ON public.discovery USING btree (daemon_id);


--
-- Name: idx_discovery_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_discovery_network ON public.discovery USING btree (network_id);


--
-- Name: idx_entity_tags_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_entity_tags_entity ON public.entity_tags USING btree (entity_id, entity_type);


--
-- Name: idx_entity_tags_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_entity_tags_tag_id ON public.entity_tags USING btree (tag_id);


--
-- Name: idx_groups_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_groups_network ON public.dependencies USING btree (network_id);


--
-- Name: idx_hosts_chassis_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hosts_chassis_id ON public.hosts USING btree (chassis_id);


--
-- Name: idx_hosts_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hosts_network ON public.hosts USING btree (network_id);


--
-- Name: idx_interfaces_host; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_host ON public.interfaces USING btree (host_id);


--
-- Name: idx_interfaces_host_if_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_host_if_index ON public.interfaces USING btree (host_id, if_index);


--
-- Name: idx_interfaces_host_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_interfaces_host_name ON public.interfaces USING btree (host_id, if_name) WHERE (if_name IS NOT NULL);


--
-- Name: idx_interfaces_ip_address; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_ip_address ON public.interfaces USING btree (ip_address_id);


--
-- Name: idx_interfaces_mac_address; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_mac_address ON public.interfaces USING btree (mac_address);


--
-- Name: idx_interfaces_neighbor_host; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_neighbor_host ON public.interfaces USING btree (neighbor_host_id);


--
-- Name: idx_interfaces_neighbor_interface; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_neighbor_interface ON public.interfaces USING btree (neighbor_interface_id);


--
-- Name: idx_interfaces_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_network ON public.interfaces USING btree (network_id);


--
-- Name: idx_invites_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invites_expires_at ON public.invites USING btree (expires_at);


--
-- Name: idx_invites_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invites_organization ON public.invites USING btree (organization_id);


--
-- Name: idx_ip_addresses_host; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ip_addresses_host ON public.ip_addresses USING btree (host_id);


--
-- Name: idx_ip_addresses_host_mac; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ip_addresses_host_mac ON public.ip_addresses USING btree (host_id, mac_address) WHERE (mac_address IS NOT NULL);


--
-- Name: idx_ip_addresses_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ip_addresses_network ON public.ip_addresses USING btree (network_id);


--
-- Name: idx_ip_addresses_subnet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ip_addresses_subnet ON public.ip_addresses USING btree (subnet_id);


--
-- Name: idx_networks_owner_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_networks_owner_organization ON public.networks USING btree (organization_id);


--
-- Name: idx_organizations_stripe_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organizations_stripe_customer ON public.organizations USING btree (stripe_customer_id);


--
-- Name: idx_ports_host; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ports_host ON public.ports USING btree (host_id);


--
-- Name: idx_ports_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ports_network ON public.ports USING btree (network_id);


--
-- Name: idx_ports_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ports_number ON public.ports USING btree (port_number);


--
-- Name: idx_services_host_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_services_host_id ON public.services USING btree (host_id);


--
-- Name: idx_services_host_position; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_services_host_position ON public.services USING btree (host_id, "position");


--
-- Name: idx_services_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_services_network ON public.services USING btree (network_id);


--
-- Name: idx_shares_enabled; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shares_enabled ON public.shares USING btree (is_enabled) WHERE (is_enabled = true);


--
-- Name: idx_shares_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shares_network ON public.shares USING btree (network_id);


--
-- Name: idx_shares_topology; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shares_topology ON public.shares USING btree (topology_id);


--
-- Name: idx_subnet_vlans_subnet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subnet_vlans_subnet ON public.subnet_vlans USING btree (subnet_id);


--
-- Name: idx_subnet_vlans_vlan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subnet_vlans_vlan ON public.subnet_vlans USING btree (vlan_id);


--
-- Name: idx_subnets_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subnets_network ON public.subnets USING btree (network_id);


--
-- Name: idx_tags_org_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_tags_org_name ON public.tags USING btree (organization_id, name);


--
-- Name: idx_tags_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tags_organization ON public.tags USING btree (organization_id);


--
-- Name: idx_topologies_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_topologies_network ON public.topologies USING btree (network_id);


--
-- Name: idx_user_api_key_network_access_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_api_key_network_access_key ON public.user_api_key_network_access USING btree (api_key_id);


--
-- Name: idx_user_api_key_network_access_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_api_key_network_access_network ON public.user_api_key_network_access USING btree (network_id);


--
-- Name: idx_user_api_keys_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_api_keys_key ON public.user_api_keys USING btree (key);


--
-- Name: idx_user_api_keys_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_api_keys_org ON public.user_api_keys USING btree (organization_id);


--
-- Name: idx_user_api_keys_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_api_keys_user ON public.user_api_keys USING btree (user_id);


--
-- Name: idx_user_network_access_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_network_access_network ON public.user_network_access USING btree (network_id);


--
-- Name: idx_user_network_access_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_network_access_user ON public.user_network_access USING btree (user_id);


--
-- Name: idx_users_email_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_email_lower ON public.users USING btree (lower(email));


--
-- Name: idx_users_email_verification_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email_verification_token ON public.users USING btree (email_verification_token) WHERE (email_verification_token IS NOT NULL);


--
-- Name: idx_users_oidc_provider_subject; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_oidc_provider_subject ON public.users USING btree (oidc_provider, oidc_subject) WHERE ((oidc_provider IS NOT NULL) AND (oidc_subject IS NOT NULL));


--
-- Name: idx_users_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_organization ON public.users USING btree (organization_id);


--
-- Name: idx_users_password_reset_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_password_reset_token ON public.users USING btree (password_reset_token) WHERE (password_reset_token IS NOT NULL);


--
-- Name: idx_vlans_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vlans_network ON public.vlans USING btree (network_id);


--
-- Name: idx_vlans_network_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_vlans_network_number ON public.vlans USING btree (network_id, vlan_number);


--
-- Name: idx_vlans_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vlans_organization ON public.vlans USING btree (organization_id);


--
-- Name: users reassign_daemons_before_user_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER reassign_daemons_before_user_delete BEFORE DELETE ON public.users FOR EACH ROW EXECUTE FUNCTION public.reassign_daemons_on_user_delete();


--
-- Name: api_keys api_keys_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: bindings bindings_interface_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bindings
    ADD CONSTRAINT bindings_interface_id_fkey FOREIGN KEY (ip_address_id) REFERENCES public.ip_addresses(id) ON DELETE CASCADE;


--
-- Name: bindings bindings_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bindings
    ADD CONSTRAINT bindings_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: bindings bindings_port_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bindings
    ADD CONSTRAINT bindings_port_id_fkey FOREIGN KEY (port_id) REFERENCES public.ports(id) ON DELETE CASCADE;


--
-- Name: bindings bindings_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bindings
    ADD CONSTRAINT bindings_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


--
-- Name: credentials credentials_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: daemons daemons_api_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_api_key_id_fkey FOREIGN KEY (api_key_id) REFERENCES public.api_keys(id) ON DELETE SET NULL;


--
-- Name: daemons daemons_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: daemons daemons_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: dependency_members dependency_members_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dependency_members
    ADD CONSTRAINT dependency_members_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;


--
-- Name: discovery discovery_daemon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discovery
    ADD CONSTRAINT discovery_daemon_id_fkey FOREIGN KEY (daemon_id) REFERENCES public.daemons(id) ON DELETE CASCADE;


--
-- Name: discovery discovery_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discovery
    ADD CONSTRAINT discovery_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: entity_tags entity_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entity_tags
    ADD CONSTRAINT entity_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: dependency_members group_bindings_binding_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dependency_members
    ADD CONSTRAINT group_bindings_binding_id_fkey FOREIGN KEY (binding_id) REFERENCES public.bindings(id) ON DELETE CASCADE;


--
-- Name: dependency_members group_bindings_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dependency_members
    ADD CONSTRAINT group_bindings_group_id_fkey FOREIGN KEY (dependency_id) REFERENCES public.dependencies(id) ON DELETE CASCADE;


--
-- Name: dependencies groups_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dependencies
    ADD CONSTRAINT groups_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: host_credentials host_credentials_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.host_credentials
    ADD CONSTRAINT host_credentials_credential_id_fkey FOREIGN KEY (credential_id) REFERENCES public.credentials(id) ON DELETE CASCADE;


--
-- Name: host_credentials host_credentials_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.host_credentials
    ADD CONSTRAINT host_credentials_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: hosts hosts_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: interfaces if_entries_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT if_entries_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: interfaces if_entries_interface_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT if_entries_interface_id_fkey FOREIGN KEY (ip_address_id) REFERENCES public.ip_addresses(id) ON DELETE SET NULL;


--
-- Name: interfaces if_entries_native_vlan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT if_entries_native_vlan_id_fkey FOREIGN KEY (native_vlan_id) REFERENCES public.vlans(id) ON DELETE SET NULL;


--
-- Name: interfaces if_entries_neighbor_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT if_entries_neighbor_host_id_fkey FOREIGN KEY (neighbor_host_id) REFERENCES public.hosts(id) ON DELETE SET NULL;


--
-- Name: interfaces if_entries_neighbor_if_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT if_entries_neighbor_if_entry_id_fkey FOREIGN KEY (neighbor_interface_id) REFERENCES public.interfaces(id) ON DELETE SET NULL;


--
-- Name: interfaces if_entries_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT if_entries_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: ip_addresses interfaces_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_addresses
    ADD CONSTRAINT interfaces_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: ip_addresses interfaces_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_addresses
    ADD CONSTRAINT interfaces_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: ip_addresses interfaces_subnet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ip_addresses
    ADD CONSTRAINT interfaces_subnet_id_fkey FOREIGN KEY (subnet_id) REFERENCES public.subnets(id) ON DELETE CASCADE;


--
-- Name: invites invites_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: invites invites_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: network_credentials network_credentials_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.network_credentials
    ADD CONSTRAINT network_credentials_credential_id_fkey FOREIGN KEY (credential_id) REFERENCES public.credentials(id) ON DELETE CASCADE;


--
-- Name: network_credentials network_credentials_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.network_credentials
    ADD CONSTRAINT network_credentials_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: networks organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: ports ports_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: ports ports_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: services services_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: services services_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: shares shares_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shares shares_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: shares shares_topology_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_topology_id_fkey FOREIGN KEY (topology_id) REFERENCES public.topologies(id) ON DELETE CASCADE;


--
-- Name: subnet_vlans subnet_vlans_subnet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subnet_vlans
    ADD CONSTRAINT subnet_vlans_subnet_id_fkey FOREIGN KEY (subnet_id) REFERENCES public.subnets(id) ON DELETE CASCADE;


--
-- Name: subnet_vlans subnet_vlans_vlan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subnet_vlans
    ADD CONSTRAINT subnet_vlans_vlan_id_fkey FOREIGN KEY (vlan_id) REFERENCES public.vlans(id) ON DELETE CASCADE;


--
-- Name: subnets subnets_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subnets
    ADD CONSTRAINT subnets_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: tags tags_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: topologies topologies_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topologies
    ADD CONSTRAINT topologies_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: user_api_key_network_access user_api_key_network_access_api_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_api_key_network_access
    ADD CONSTRAINT user_api_key_network_access_api_key_id_fkey FOREIGN KEY (api_key_id) REFERENCES public.user_api_keys(id) ON DELETE CASCADE;


--
-- Name: user_api_key_network_access user_api_key_network_access_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_api_key_network_access
    ADD CONSTRAINT user_api_key_network_access_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: user_api_keys user_api_keys_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT user_api_keys_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: user_api_keys user_api_keys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT user_api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_network_access user_network_access_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_network_access
    ADD CONSTRAINT user_network_access_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: user_network_access user_network_access_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_network_access
    ADD CONSTRAINT user_network_access_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: vlans vlans_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vlans
    ADD CONSTRAINT vlans_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: vlans vlans_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vlans
    ADD CONSTRAINT vlans_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict XuwkCQsxhUg96dAEEdmYZXza5gdBFLj9QGRpi3y4pZ3scqnua3BOeHdPMXKsP56

