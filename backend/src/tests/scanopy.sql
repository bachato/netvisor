--
-- PostgreSQL database dump
--

\restrict AlEcTe54KvjIVAbEl3Comh2kUjxwqgNUhbkNVehuDbujiub7HFYPtzE8yeBHlYj

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.7

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
ALTER TABLE IF EXISTS ONLY public.snmp_credentials DROP CONSTRAINT IF EXISTS snmp_credentials_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_topology_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_snmp_credential_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_subnet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.if_entries DROP CONSTRAINT IF EXISTS if_entries_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.if_entries DROP CONSTRAINT IF EXISTS if_entries_neighbor_if_entry_id_fkey;
ALTER TABLE IF EXISTS ONLY public.if_entries DROP CONSTRAINT IF EXISTS if_entries_neighbor_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.if_entries DROP CONSTRAINT IF EXISTS if_entries_interface_id_fkey;
ALTER TABLE IF EXISTS ONLY public.if_entries DROP CONSTRAINT IF EXISTS if_entries_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_snmp_credential_id_fkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.group_bindings DROP CONSTRAINT IF EXISTS group_bindings_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.group_bindings DROP CONSTRAINT IF EXISTS group_bindings_binding_id_fkey;
ALTER TABLE IF EXISTS ONLY public.entity_tags DROP CONSTRAINT IF EXISTS entity_tags_tag_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_daemon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_api_key_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_service_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_port_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_interface_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_network_id_fkey;
DROP TRIGGER IF EXISTS reassign_daemons_before_user_delete ON public.users;
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
DROP INDEX IF EXISTS public.idx_snmp_credentials_org;
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
DROP INDEX IF EXISTS public.idx_networks_snmp_credential;
DROP INDEX IF EXISTS public.idx_networks_owner_organization;
DROP INDEX IF EXISTS public.idx_invites_organization;
DROP INDEX IF EXISTS public.idx_invites_expires_at;
DROP INDEX IF EXISTS public.idx_interfaces_subnet;
DROP INDEX IF EXISTS public.idx_interfaces_network;
DROP INDEX IF EXISTS public.idx_interfaces_host_mac;
DROP INDEX IF EXISTS public.idx_interfaces_host;
DROP INDEX IF EXISTS public.idx_if_entries_network;
DROP INDEX IF EXISTS public.idx_if_entries_neighbor_if_entry;
DROP INDEX IF EXISTS public.idx_if_entries_neighbor_host;
DROP INDEX IF EXISTS public.idx_if_entries_mac_address;
DROP INDEX IF EXISTS public.idx_if_entries_interface;
DROP INDEX IF EXISTS public.idx_if_entries_host;
DROP INDEX IF EXISTS public.idx_hosts_snmp_credential;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_hosts_chassis_id;
DROP INDEX IF EXISTS public.idx_groups_network;
DROP INDEX IF EXISTS public.idx_group_bindings_group;
DROP INDEX IF EXISTS public.idx_group_bindings_binding;
DROP INDEX IF EXISTS public.idx_entity_tags_tag_id;
DROP INDEX IF EXISTS public.idx_entity_tags_entity;
DROP INDEX IF EXISTS public.idx_discovery_network;
DROP INDEX IF EXISTS public.idx_discovery_daemon;
DROP INDEX IF EXISTS public.idx_daemons_network;
DROP INDEX IF EXISTS public.idx_daemons_api_key;
DROP INDEX IF EXISTS public.idx_daemon_host_id;
DROP INDEX IF EXISTS public.idx_bindings_service;
DROP INDEX IF EXISTS public.idx_bindings_port;
DROP INDEX IF EXISTS public.idx_bindings_network;
DROP INDEX IF EXISTS public.idx_bindings_interface;
DROP INDEX IF EXISTS public.idx_api_keys_network;
DROP INDEX IF EXISTS public.idx_api_keys_key;
ALTER TABLE IF EXISTS ONLY tower_sessions.session DROP CONSTRAINT IF EXISTS session_pkey;
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
ALTER TABLE IF EXISTS ONLY public.snmp_credentials DROP CONSTRAINT IF EXISTS snmp_credentials_pkey;
ALTER TABLE IF EXISTS ONLY public.snmp_credentials DROP CONSTRAINT IF EXISTS snmp_credentials_organization_id_name_key;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_pkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_host_id_port_number_protocol_key;
ALTER TABLE IF EXISTS ONLY public.organizations DROP CONSTRAINT IF EXISTS organizations_pkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_pkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_pkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_pkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_host_id_subnet_id_ip_address_key;
ALTER TABLE IF EXISTS ONLY public.if_entries DROP CONSTRAINT IF EXISTS if_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.if_entries DROP CONSTRAINT IF EXISTS if_entries_host_id_if_index_key;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_pkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_pkey;
ALTER TABLE IF EXISTS ONLY public.group_bindings DROP CONSTRAINT IF EXISTS group_bindings_pkey;
ALTER TABLE IF EXISTS ONLY public.group_bindings DROP CONSTRAINT IF EXISTS group_bindings_group_id_binding_id_key;
ALTER TABLE IF EXISTS ONLY public.entity_tags DROP CONSTRAINT IF EXISTS entity_tags_pkey;
ALTER TABLE IF EXISTS ONLY public.entity_tags DROP CONSTRAINT IF EXISTS entity_tags_entity_id_entity_type_tag_id_key;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_pkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_pkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_pkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_pkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_key_key;
ALTER TABLE IF EXISTS ONLY public._sqlx_migrations DROP CONSTRAINT IF EXISTS _sqlx_migrations_pkey;
DROP TABLE IF EXISTS tower_sessions.session;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_network_access;
DROP TABLE IF EXISTS public.user_api_keys;
DROP TABLE IF EXISTS public.user_api_key_network_access;
DROP TABLE IF EXISTS public.topologies;
DROP TABLE IF EXISTS public.tags;
DROP TABLE IF EXISTS public.subnets;
DROP TABLE IF EXISTS public.snmp_credentials;
DROP TABLE IF EXISTS public.shares;
DROP TABLE IF EXISTS public.services;
DROP TABLE IF EXISTS public.ports;
DROP TABLE IF EXISTS public.organizations;
DROP TABLE IF EXISTS public.networks;
DROP TABLE IF EXISTS public.invites;
DROP TABLE IF EXISTS public.interfaces;
DROP TABLE IF EXISTS public.if_entries;
DROP TABLE IF EXISTS public.hosts;
DROP TABLE IF EXISTS public.groups;
DROP TABLE IF EXISTS public.group_bindings;
DROP TABLE IF EXISTS public.entity_tags;
DROP TABLE IF EXISTS public.discovery;
DROP TABLE IF EXISTS public.daemons;
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
    interface_id uuid,
    port_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT bindings_binding_type_check CHECK ((binding_type = ANY (ARRAY['Interface'::text, 'Port'::text]))),
    CONSTRAINT valid_binding CHECK ((((binding_type = 'Interface'::text) AND (interface_id IS NOT NULL) AND (port_id IS NULL)) OR ((binding_type = 'Port'::text) AND (port_id IS NOT NULL))))
);


ALTER TABLE public.bindings OWNER TO postgres;

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
    is_unreachable boolean DEFAULT false NOT NULL
);


ALTER TABLE public.daemons OWNER TO postgres;

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
    updated_at timestamp with time zone NOT NULL
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
-- Name: group_bindings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_bindings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid NOT NULL,
    binding_id uuid NOT NULL,
    "position" integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.group_bindings OWNER TO postgres;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    source jsonb NOT NULL,
    color text NOT NULL,
    edge_style text DEFAULT '"SmoothStep"'::text,
    group_type text NOT NULL
);


ALTER TABLE public.groups OWNER TO postgres;

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
    snmp_credential_id uuid
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
-- Name: COLUMN hosts.snmp_credential_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.hosts.snmp_credential_id IS 'Per-host SNMP credential override (null = use network default)';


--
-- Name: if_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.if_entries (
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
    interface_id uuid,
    neighbor_if_entry_id uuid,
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
    CONSTRAINT chk_neighbor_exclusive CHECK (((neighbor_if_entry_id IS NULL) OR (neighbor_host_id IS NULL)))
);


ALTER TABLE public.if_entries OWNER TO postgres;

--
-- Name: TABLE if_entries; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.if_entries IS 'SNMP ifTable entries - physical/logical interfaces on network devices';


--
-- Name: COLUMN if_entries.if_index; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.if_index IS 'SNMP ifIndex - stable identifier within device';


--
-- Name: COLUMN if_entries.if_descr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.if_descr IS 'SNMP ifDescr - interface description (e.g., GigabitEthernet0/1)';


--
-- Name: COLUMN if_entries.if_alias; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.if_alias IS 'SNMP ifAlias - user-configured description';


--
-- Name: COLUMN if_entries.if_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.if_type IS 'SNMP ifType - IANAifType integer (6=ethernet, 24=loopback, etc.)';


--
-- Name: COLUMN if_entries.speed_bps; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.speed_bps IS 'Interface speed from ifSpeed/ifHighSpeed in bits per second';


--
-- Name: COLUMN if_entries.admin_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.admin_status IS 'SNMP ifAdminStatus: 1=up, 2=down, 3=testing';


--
-- Name: COLUMN if_entries.oper_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.oper_status IS 'SNMP ifOperStatus: 1=up, 2=down, 3=testing, 4=unknown, 5=dormant, 6=notPresent, 7=lowerLayerDown';


--
-- Name: COLUMN if_entries.interface_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.interface_id IS 'FK to Interface entity when this ifEntry has an IP address (must be on same host)';


--
-- Name: COLUMN if_entries.neighbor_if_entry_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.neighbor_if_entry_id IS 'Full neighbor resolution: FK to remote IfEntry discovered via LLDP/CDP';


--
-- Name: COLUMN if_entries.neighbor_host_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.neighbor_host_id IS 'Partial neighbor resolution: FK to remote Host when specific port is unknown';


--
-- Name: COLUMN if_entries.lldp_mgmt_addr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.lldp_mgmt_addr IS 'LLDP remote management address (lldpRemManAddr)';


--
-- Name: COLUMN if_entries.lldp_sys_desc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.lldp_sys_desc IS 'LLDP remote system description (lldpRemSysDesc)';


--
-- Name: COLUMN if_entries.cdp_device_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.cdp_device_id IS 'CDP cache remote device ID (typically hostname)';


--
-- Name: COLUMN if_entries.cdp_port_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.cdp_port_id IS 'CDP cache remote port ID string';


--
-- Name: COLUMN if_entries.cdp_platform; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.cdp_platform IS 'CDP cache remote device platform (e.g., Cisco IOS)';


--
-- Name: COLUMN if_entries.cdp_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.if_entries.cdp_address IS 'CDP cache remote device management IP address';


--
-- Name: interfaces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interfaces (
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


ALTER TABLE public.interfaces OWNER TO postgres;

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
-- Name: networks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.networks (
    id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    organization_id uuid NOT NULL,
    snmp_credential_id uuid
);


ALTER TABLE public.networks OWNER TO postgres;

--
-- Name: COLUMN networks.organization_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.networks.organization_id IS 'The organization that owns and pays for this network';


--
-- Name: COLUMN networks.snmp_credential_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.networks.snmp_credential_id IS 'Default SNMP credential for this network (presence enables SNMP discovery)';


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
    hubspot_company_id text
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
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shares OWNER TO postgres;

--
-- Name: snmp_credentials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.snmp_credentials (
    id uuid NOT NULL,
    organization_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    version text DEFAULT 'V2c'::text NOT NULL,
    community text NOT NULL
);


ALTER TABLE public.snmp_credentials OWNER TO postgres;

--
-- Name: TABLE snmp_credentials; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.snmp_credentials IS 'SNMP credentials scoped to organization, reusable across networks';


--
-- Name: COLUMN snmp_credentials.version; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.snmp_credentials.version IS 'SNMP version: V2c (MVP), V3 (future)';


--
-- Name: COLUMN snmp_credentials.community; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.snmp_credentials.community IS 'SNMPv2c community string (encrypted)';


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
    source jsonb NOT NULL
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
    color text NOT NULL
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
    groups jsonb NOT NULL,
    is_stale boolean,
    last_refreshed timestamp with time zone DEFAULT now() NOT NULL,
    is_locked boolean,
    locked_at timestamp with time zone,
    locked_by uuid,
    removed_hosts uuid[],
    removed_services uuid[],
    removed_subnets uuid[],
    removed_groups uuid[],
    parent_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL,
    interfaces jsonb DEFAULT '[]'::jsonb NOT NULL,
    removed_interfaces uuid[] DEFAULT '{}'::uuid[],
    ports jsonb DEFAULT '[]'::jsonb NOT NULL,
    removed_ports uuid[] DEFAULT '{}'::uuid[],
    bindings jsonb DEFAULT '[]'::jsonb NOT NULL,
    removed_bindings uuid[] DEFAULT '{}'::uuid[],
    if_entries jsonb DEFAULT '[]'::jsonb NOT NULL,
    removed_if_entries uuid[] DEFAULT '{}'::uuid[]
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
    password_reset_expires timestamp with time zone
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
20251006215000	users	2026-02-01 17:15:40.541486+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3504916
20251006215100	networks	2026-02-01 17:15:40.546601+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4880307
20251006215151	create hosts	2026-02-01 17:15:40.551942+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3902256
20251006215155	create subnets	2026-02-01 17:15:40.55621+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3714437
20251006215201	create groups	2026-02-01 17:15:40.56028+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3996814
20251006215204	create daemons	2026-02-01 17:15:40.564622+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4173661
20251006215212	create services	2026-02-01 17:15:40.569142+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4807342
20251029193448	user-auth	2026-02-01 17:15:40.574268+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6079671
20251030044828	daemon api	2026-02-01 17:15:40.580671+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1645183
20251030170438	host-hide	2026-02-01 17:15:40.582618+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1072097
20251102224919	create discovery	2026-02-01 17:15:40.583958+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11030649
20251106235621	normalize-daemon-cols	2026-02-01 17:15:40.595331+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1999934
20251107034459	api keys	2026-02-01 17:15:40.59776+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8359997
20251107222650	oidc-auth	2026-02-01 17:15:40.606467+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	27750302
20251110181948	orgs-billing	2026-02-01 17:15:40.63453+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10887623
20251113223656	group-enhancements	2026-02-01 17:15:40.645817+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1027102
20251117032720	daemon-mode	2026-02-01 17:15:40.647159+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1105909
20251118143058	set-default-plan	2026-02-01 17:15:40.648574+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1186980
20251118225043	save-topology	2026-02-01 17:15:40.65009+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8883121
20251123232748	network-permissions	2026-02-01 17:15:40.659293+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	3069025
20251125001342	billing-updates	2026-02-01 17:15:40.662665+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	936935
20251128035448	org-onboarding-status	2026-02-01 17:15:40.663898+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1408863
20251129180942	nfs-consolidate	2026-02-01 17:15:40.665647+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1217567
20251206052641	discovery-progress	2026-02-01 17:15:40.667154+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1628452
20251206202200	plan-fix	2026-02-01 17:15:40.669059+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	936053
20251207061341	daemon-url	2026-02-01 17:15:40.670277+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2441826
20251210045929	tags	2026-02-01 17:15:40.673027+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8839171
20251210175035	terms	2026-02-01 17:15:40.68224+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	957951
20251213025048	hash-keys	2026-02-01 17:15:40.683502+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	11913674
20251214050638	scanopy	2026-02-01 17:15:40.695764+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1661507
20251215215724	topo-scanopy-fix	2026-02-01 17:15:40.697751+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	781875
20251217153736	category rename	2026-02-01 17:15:40.69882+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1713651
20251218053111	invite-persistence	2026-02-01 17:15:40.700829+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5249071
20251219211216	create shares	2026-02-01 17:15:40.706397+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6742375
20251220170928	permissions-cleanup	2026-02-01 17:15:40.713488+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1433108
20251220180000	commercial-to-community	2026-02-01 17:15:40.715217+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	861737
20251221010000	cleanup subnet type	2026-02-01 17:15:40.716373+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	879946
20251221020000	remove host target	2026-02-01 17:15:40.717578+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	3005829
20251221030000	user network access	2026-02-01 17:15:40.720998+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7033774
20251221040000	interfaces table	2026-02-01 17:15:40.728472+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9596759
20251221050000	ports table	2026-02-01 17:15:40.738425+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	8807309
20251221060000	bindings table	2026-02-01 17:15:40.747539+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	10574510
20251221070000	group bindings	2026-02-01 17:15:40.758579+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6213329
20251222020000	tag cascade delete	2026-02-01 17:15:40.76505+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1316250
20251223232524	network remove default	2026-02-01 17:15:40.766832+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	999771
20251225100000	color enum	2026-02-01 17:15:40.768108+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1296665
20251227010000	topology snapshot migration	2026-02-01 17:15:40.769741+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4354779
20251228010000	user api keys	2026-02-01 17:15:40.774401+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	11086052
20251230160000	daemon version and maintainer	2026-02-01 17:15:40.785938+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	2696752
20260103000000	service position	2026-02-01 17:15:40.789002+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	1912581
20260106000000	interface mac index	2026-02-01 17:15:40.791242+00	t	\\xa26248372a1e31af46a9c6fbdaef178982229e2ceeb90cc6a289d5764f87a38747294b3adf5f21276b5d171e42bdb6ac	1716877
20260106204402	entity tags junction	2026-02-01 17:15:40.793284+00	t	\\xf73c604f9f0b8db065d990a861684b0dbd62c3ef9bead120c68431c933774de56491a53f021e79f09801680152f5a08a	12285176
20260108033856	fix entity tags json format	2026-02-01 17:15:40.805903+00	t	\\x197eaa063d4f96dd0e897ad8fd96cc1ba9a54dda40a93a5c12eac14597e4dea4c806dd0a527736fb5807b7a8870d9916	1427498
20260110000000	email verification	2026-02-01 17:15:40.807619+00	t	\\xb8da8433f58ba4ce846b9fa0c2551795747a8473ad10266b19685504847458ea69d27a0ce430151cfb426f5f5fb6ac3a	3298813
20260114145808	daemon user fk set null	2026-02-01 17:15:40.811244+00	t	\\x57b060be9fc314d7c5851c75661ca8269118feea6cf7ee9c61b147a0e117c4d39642cf0d1acdf7a723a9a76066c1b8ff	997828
20260116010000	snmp credentials	2026-02-01 17:15:40.812836+00	t	\\x6f3971cf194d56883c61fa795406a8ab568307ed86544920d098b32a6a1ebb7effcb5ec38a70fdc9b617eff92d63d51e	6930204
20260116020000	host snmp fields	2026-02-01 17:15:40.820124+00	t	\\xf2f088c13ab0dd34e1cb1e5327b0b4137440b0146e5ce1e78b8d2dfa05d9b5a12a328eeb807988453a8a43ad8a1c95ba	4218756
20260116030000	if entries	2026-02-01 17:15:40.824686+00	t	\\xa58391708f8b21901ab9250af528f638a6055462f70ffddfd7c451433aacdabd62825546fa8be108f23a3cae78b8ae28	14904632
20260116100000	daemon api key link	2026-02-01 17:15:40.840017+00	t	\\x41088aa314ab173344a6b416280721806b2f296a32a8d8cae58c7e5717f389fe599134ed03980ed97e4b7659e99c4f82	3458881
20260131190000	add hubspot company id	2026-02-01 17:15:40.843809+00	t	\\x4326f95f4954e176157c1c3e034074a3e5c44da4d60bbd7a9e4b6238c9ef52a30f8b38d3c887864b6e4c1163dc062beb	919592
20260201021238	fix service acronym capitalization	2026-02-01 17:15:40.845047+00	t	\\x88b010ac8f0223d880ea6a730f11dc6d27fa5de9d8747de3431e46d59f1dbf2f72ae4a87c2e52c32152549f5c1f96bb2	1710925
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, plaintext) FROM stdin;
b035084b-581a-4fcf-852b-e28f678015d2	6aaf1cf89930da8fc67568f4392b5e2190d38c53d55a235583a34f26a1121217	82606870-9d3d-4c88-9586-8029c4311900	scanopy-daemon-serverpoll API Key	2026-02-01 17:22:01.88903+00	2026-02-01 17:22:01.88903+00	2026-02-01 17:30:40.99775+00	\N	t	scp_d_iEesNyfJj13KKsddr9j3R8ZHRoCWep9y
9dd23bc5-f444-43e1-bc39-ea8c5c925c94	5c51916b368b7941564a35fa661de93bb491b521bda656817aca46450e7e8fbb	82606870-9d3d-4c88-9586-8029c4311900	Compat Test API Key	2026-02-01 17:22:02.800375+00	2026-02-01 17:22:02.800375+00	2026-02-01 17:22:06.097467+00	\N	t	\N
5d79504f-37cf-4a7c-b1ba-dd7fea91dedd	72f77aecc38d3ff03342e6793b060b7060e95d34bbd5a602111e5d734c32a903	82606870-9d3d-4c88-9586-8029c4311900	Integrated Daemon API Key	2026-02-01 17:15:46.129862+00	2026-02-01 17:15:46.129862+00	2026-02-01 17:30:28.463296+00	\N	t	\N
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
c1ddada9-bbde-4a31-9fbb-c042f51d012c	82606870-9d3d-4c88-9586-8029c4311900	5711cdbb-058e-4624-b380-9f532b086b8c	Port	82747a02-52ec-4e32-b2d6-9e80ad264cd8	cbd2decf-015d-4af6-987f-a86ff0df4cf8	2026-02-01 17:22:10.931508+00	2026-02-01 17:22:10.931508+00
7d8e61ef-6673-46e8-a8bf-e9557788f94e	82606870-9d3d-4c88-9586-8029c4311900	5b1d3f9f-8f1d-4eae-b244-9064e1a9347b	Port	d0328b46-56b5-450d-b9ff-55f249f0fa64	57ac68b3-d686-4c79-9838-d9d540c3f534	2026-02-01 17:28:32.422736+00	2026-02-01 17:28:32.422736+00
315e3045-8d83-4fda-bbe6-832306dfaeb2	82606870-9d3d-4c88-9586-8029c4311900	fb1d10ae-2420-4b39-82f2-a8040e830bd0	Port	d0328b46-56b5-450d-b9ff-55f249f0fa64	ef2acc93-fd50-4719-8fc0-d27b9922754e	2026-02-01 17:28:35.37225+00	2026-02-01 17:28:35.37225+00
682ead23-d5d9-4131-8f85-8e926183b97d	82606870-9d3d-4c88-9586-8029c4311900	909a9987-59a4-43ce-9a0d-d6d98ccc4e10	Port	cfff8063-98f1-40c9-bd26-2f6cc9e2ab09	1cacaa3f-25e7-4243-8a4b-7c1d1cde9d93	2026-02-01 17:29:04.06415+00	2026-02-01 17:29:04.06415+00
5ae02099-70ee-4e60-a6e3-cadd030a139f	82606870-9d3d-4c88-9586-8029c4311900	57d51c4e-ed1e-4425-8381-7a1b7f84ef51	Port	55afdb2c-9a9a-473a-bdea-7be4567ea430	3e56e048-b5a2-463e-8539-c739ff5ed8fb	2026-02-01 17:28:48.071625+00	2026-02-01 17:28:48.071625+00
0c5f2a6a-a784-48ad-a11a-74a725dd3c71	82606870-9d3d-4c88-9586-8029c4311900	aeeb9288-ca19-4f33-ab57-b43630501a3d	Port	d14966c0-91d0-40db-ab68-218dd04b674e	2f651630-3bfe-4464-b1a4-ad5dcd4db0ce	2026-02-01 17:29:23.635886+00	2026-02-01 17:29:23.635886+00
4a166ce0-a7de-48d8-bb18-a13ef31bd1d4	82606870-9d3d-4c88-9586-8029c4311900	9fdacfc6-5d18-4376-a1c7-8afe6d1e64e0	Port	8dbaab9f-b927-42b3-8b9d-2d9026373fe3	db975840-0950-4f8a-88e3-a98a27612aa9	2026-02-01 17:29:42.052613+00	2026-02-01 17:29:42.052613+00
b2e3d4be-dec1-489d-b7a0-d861b569e9fd	82606870-9d3d-4c88-9586-8029c4311900	6368be5a-8e80-4f93-9dfb-74310f34e111	Port	8dbaab9f-b927-42b3-8b9d-2d9026373fe3	9ebd4656-28d1-4c86-a0fb-fd5c3c4b9f1b	2026-02-01 17:29:42.796204+00	2026-02-01 17:29:42.796204+00
6eba0249-951f-4bd7-b7cd-b4bd29c603fb	82606870-9d3d-4c88-9586-8029c4311900	81976797-7a61-4f6c-b1bd-e4e041739ed2	Port	8dbaab9f-b927-42b3-8b9d-2d9026373fe3	8f18834b-ee37-4488-8e25-11c8bb4f1c31	2026-02-01 17:29:45.669163+00	2026-02-01 17:29:45.669163+00
65a0eabf-344a-4013-9c56-bd89a71af9d8	82606870-9d3d-4c88-9586-8029c4311900	1f68dd26-51ba-4afc-80c3-8ff0f914bbac	Port	8dbaab9f-b927-42b3-8b9d-2d9026373fe3	73db4064-7944-46f4-822e-87ce1189388b	2026-02-01 17:29:45.669354+00	2026-02-01 17:29:45.669354+00
5d5823b1-cded-433f-a122-5d4b97458ff7	82606870-9d3d-4c88-9586-8029c4311900	1f68dd26-51ba-4afc-80c3-8ff0f914bbac	Port	8dbaab9f-b927-42b3-8b9d-2d9026373fe3	79ee49ff-1514-40b3-bcd9-8be79c846820	2026-02-01 17:29:45.669355+00	2026-02-01 17:29:45.669355+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, version, user_id, api_key_id, is_unreachable) FROM stdin;
051e03d5-56bf-4363-b44c-abeb9e7fec8c	82606870-9d3d-4c88-9586-8029c4311900	d73829f7-d908-4964-86cd-b219ef3383bd	2026-02-01 17:15:46.238778+00	2026-02-01 17:30:28.465618+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["94b21cfc-8ecd-40c0-9f4e-be72aa4872f7"]}	2026-02-01 17:15:46.238778+00	"daemon_poll"		scanopy-daemon	0.14.0	72339403-d9ae-4557-94cb-e71bf75fc0f5	\N	f
aaea418e-66f0-4abc-8201-01c6b106148b	82606870-9d3d-4c88-9586-8029c4311900	e8dac647-021e-4f3b-a667-b733576614f9	2026-02-01 17:22:01.892116+00	2026-02-01 17:30:40.902153+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["f6570079-8f33-4188-90f0-07a80576723a"]}	2026-02-01 17:22:01.892116+00	"server_poll"	http://daemon-serverpoll:60074	scanopy-daemon-serverpoll	0.14.0	72339403-d9ae-4557-94cb-e71bf75fc0f5	b035084b-581a-4fcf-852b-e28f678015d2	f
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
d8c843c5-2344-4779-bb3a-ed93696641b0	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "d73829f7-d908-4964-86cd-b219ef3383bd"}	Self Report	2026-02-01 17:15:46.245033+00	2026-02-01 17:15:46.245033+00
1a1a06c4-403c-4f36-85ae-ea5a87958494	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery	2026-02-01 17:15:46.248737+00	2026-02-01 17:15:46.248737+00
3fc2f95c-d1f8-4bf1-ab8e-c0fbc4c864ba	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "0b9d820c-82cf-4eb1-a7f4-92410dfc3bff", "started_at": "2026-02-01T17:15:58.480886957Z", "finished_at": "2026-02-01T17:15:58.527713010Z", "discovery_type": {"type": "SelfReport", "host_id": "d73829f7-d908-4964-86cd-b219ef3383bd"}}}	{"type": "SelfReport", "host_id": "d73829f7-d908-4964-86cd-b219ef3383bd"}	Self Report	2026-02-01 17:15:58.480886+00	2026-02-01 17:15:58.533288+00
39bd4e70-1942-4d0f-9df5-b70343d6f4cc	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "007ac802-0064-4cd5-b054-b816ec2f536d", "started_at": "2026-02-01T17:16:28.479371948Z", "finished_at": "2026-02-01T17:22:01.511721420Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery	2026-02-01 17:16:28.479371+00	2026-02-01 17:22:01.516248+00
966fa361-c08a-4904-aa8f-a0dad57056c3	82606870-9d3d-4c88-9586-8029c4311900	aaea418e-66f0-4abc-8201-01c6b106148b	{"type": "AdHoc", "last_run": "2026-02-01T17:22:08.363029724Z"}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	ServerPoll Integration Test Discovery	2026-02-01 17:22:08.354187+00	2026-02-01 17:22:08.354187+00
0e7bc21c-6866-44f4-bf15-c06514d9bb93	82606870-9d3d-4c88-9586-8029c4311900	aaea418e-66f0-4abc-8201-01c6b106148b	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "e8dac647-021e-4f3b-a667-b733576614f9"}	Self Report	2026-02-01 17:22:10.905737+00	2026-02-01 17:22:10.905737+00
511fab34-2e0c-4c2d-8ddc-d2dfb3180f13	82606870-9d3d-4c88-9586-8029c4311900	aaea418e-66f0-4abc-8201-01c6b106148b	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery	2026-02-01 17:22:10.907848+00	2026-02-01 17:22:10.907848+00
1b12465c-dfec-42e1-8b72-542fd6dd3ac7	82606870-9d3d-4c88-9586-8029c4311900	aaea418e-66f0-4abc-8201-01c6b106148b	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "5b19fece-cb82-45d8-a676-df53cc38a014", "started_at": "2026-02-01T17:22:10.918244856Z", "finished_at": "2026-02-01T17:23:46.032281108Z", "discovery_type": {"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}}}	{"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}	Self Report	2026-02-01 17:22:10.918244+00	2026-02-01 17:23:46.039864+00
3a5a10a6-0053-41df-a0e6-ab6467ab7950	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "1a182cd9-9710-482e-8645-d95c40db018a", "started_at": "2026-01-26T14:03:24.338877430Z", "finished_at": "2026-02-01T17:27:40.896358269Z", "discovery_type": {"type": "SelfReport", "host_id": "7891ed81-377c-4eca-b05e-bc8a17129f90"}}}	{"type": "SelfReport", "host_id": "7891ed81-377c-4eca-b05e-bc8a17129f90"}	Discovery Run (Stalled)	2026-01-26 14:03:24.338877+00	2026-02-01 17:27:40.896358+00
3d04d8a2-03ee-4419-aeab-3fca2d998a84	82606870-9d3d-4c88-9586-8029c4311900	aaea418e-66f0-4abc-8201-01c6b106148b	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "5b19fece-cb82-45d8-a676-df53cc38a014", "started_at": "2026-02-01T17:22:10.918244856Z", "finished_at": "2026-02-01T17:23:46.032281108Z", "discovery_type": {"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}}}	{"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}	Self Report	2026-02-01 17:22:10.918244+00	2026-02-01 17:24:10.907029+00
7cad6965-72fc-42ea-8577-d853bb746fe9	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "7c314669-ec4f-4719-9e7e-2c579c7d9cd6", "started_at": "2026-01-25T23:12:40.158142587Z", "finished_at": "2026-02-01T17:27:40.896358269Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-01-25 23:12:40.158142+00	2026-02-01 17:27:40.896358+00
a8f11c23-80b0-4fee-974c-39127ec7b269	82606870-9d3d-4c88-9586-8029c4311900	aaea418e-66f0-4abc-8201-01c6b106148b	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "5b19fece-cb82-45d8-a676-df53cc38a014", "started_at": "2026-02-01T17:22:10.918244856Z", "finished_at": "2026-02-01T17:23:46.032281108Z", "discovery_type": {"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}}}	{"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}	Self Report	2026-02-01 17:22:10.918244+00	2026-02-01 17:24:40.90659+00
f0e89d68-eed2-4229-9566-338c3acd3b45	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "580379b9-0101-428f-baef-843afbc5dfee", "started_at": "2026-01-26T14:03:54.326189222Z", "finished_at": "2026-02-01T17:27:40.896358269Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-01-26 14:03:54.326189+00	2026-02-01 17:27:40.896358+00
d2e40391-363a-4633-8574-f9ebe0847b94	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "adfad9b0-e25d-4bd4-88bc-e0ecc0f3f4a4", "started_at": "2026-01-26T13:51:30.181086877Z", "finished_at": "2026-02-01T17:27:40.896358269Z", "discovery_type": {"type": "SelfReport", "host_id": "01d97cc8-84d8-4806-877f-52bfd29791f8"}}}	{"type": "SelfReport", "host_id": "01d97cc8-84d8-4806-877f-52bfd29791f8"}	Discovery Run (Stalled)	2026-01-26 13:51:30.181086+00	2026-02-01 17:27:40.896358+00
f07cd0bd-f8fd-44a8-9e1b-f9d4cdf823b3	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "007ac802-0064-4cd5-b054-b816ec2f536d", "started_at": "2026-02-01T17:16:28.479371948Z", "finished_at": "2026-02-01T17:27:40.896358269Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-02-01 17:16:28.479371+00	2026-02-01 17:27:40.896358+00
9ff54a1c-ecb4-483c-a5bf-b7e1b0dee29a	82606870-9d3d-4c88-9586-8029c4311900	aaea418e-66f0-4abc-8201-01c6b106148b	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "43665ecf-daac-42e6-9379-8d3a893d6695", "started_at": "2026-02-01T17:24:40.965047661Z", "finished_at": "2026-02-01T17:30:40.996346235Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery	2026-02-01 17:24:40.965047+00	2026-02-01 17:30:41.001969+00
3301bc83-f873-4fe4-a31e-486a0f0399dd	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "f5a833cc-002f-41e1-b540-c0a623d6775c", "started_at": "2026-01-25T23:12:10.196614920Z", "finished_at": "2026-02-01T17:27:40.896358269Z", "discovery_type": {"type": "SelfReport", "host_id": "7c51d243-60ef-4994-b7db-fa41b23b3644"}}}	{"type": "SelfReport", "host_id": "7c51d243-60ef-4994-b7db-fa41b23b3644"}	Discovery Run (Stalled)	2026-01-25 23:12:10.196614+00	2026-02-01 17:27:40.896358+00
619db449-53dd-43ab-a8ef-7f4c98a87e2b	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "f7531810-14a6-48d2-aa0f-8b4e9e97d176", "started_at": "2026-01-26T13:52:00.181047960Z", "finished_at": "2026-02-01T17:27:40.896358269Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-01-26 13:52:00.181047+00	2026-02-01 17:27:40.896358+00
c14544a7-6f40-49c0-9ef0-5ab9830fdaef	82606870-9d3d-4c88-9586-8029c4311900	051e03d5-56bf-4363-b44c-abeb9e7fec8c	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "051e03d5-56bf-4363-b44c-abeb9e7fec8c", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "session_id": "0b9d820c-82cf-4eb1-a7f4-92410dfc3bff", "started_at": "2026-02-01T17:15:58.480886957Z", "finished_at": "2026-02-01T17:27:40.896358269Z", "discovery_type": {"type": "SelfReport", "host_id": "d73829f7-d908-4964-86cd-b219ef3383bd"}}}	{"type": "SelfReport", "host_id": "d73829f7-d908-4964-86cd-b219ef3383bd"}	Discovery Run (Stalled)	2026-02-01 17:15:58.480886+00	2026-02-01 17:27:40.896358+00
\.


--
-- Data for Name: entity_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_tags (id, entity_id, entity_type, tag_id, created_at) FROM stdin;
8c4b9c0a-d9ad-43ec-8769-7ba600d841b8	5b1d3f9f-8f1d-4eae-b244-9064e1a9347b	"Service"	01e318f1-cc71-4d56-9605-34f49b41b6dc	2026-02-01 17:30:41.023984+00
\.


--
-- Data for Name: group_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_bindings (id, group_id, binding_id, "position", created_at) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, created_at, updated_at, source, color, edge_style, group_type) FROM stdin;
cf1f8ebf-38e8-487a-91dd-d07dbf72ada2	82606870-9d3d-4c88-9586-8029c4311900		\N	2026-02-01 17:30:41.025874+00	2026-02-01 17:30:41.025874+00	{"type": "Manual"}	Yellow	"SmoothStep"	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden, sys_descr, sys_object_id, sys_location, sys_contact, management_url, chassis_id, snmp_credential_id) FROM stdin;
5ec565a7-0299-4c07-8501-a998b7ab7a80	82606870-9d3d-4c88-9586-8029c4311900	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-01T17:29:07.700011294Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-01 17:29:07.700013+00	2026-02-01 17:29:07.700013+00	f	\N	\N	\N	\N	\N	\N	\N
a9590643-88e0-45c1-8420-738ed98070ba	82606870-9d3d-4c88-9586-8029c4311900	2fbecee5d7a0	2fbecee5d7a0	Scanopy daemon	{"type": "Discovery", "metadata": [{"date": "2026-02-01T17:22:10.931492689Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b"}]}	null	2026-02-01 17:22:10.931495+00	2026-02-01 17:22:10.931495+00	f	\N	\N	\N	\N	\N	\N	\N
1309a713-da9f-4ef4-b5f7-893cbbbaebf3	82606870-9d3d-4c88-9586-8029c4311900	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-01T17:28:19.158130312Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-01 17:28:19.158132+00	2026-02-01 17:28:19.158132+00	f	\N	\N	\N	\N	\N	\N	\N
07e159fd-7267-43d4-9032-d5f3605d3881	82606870-9d3d-4c88-9586-8029c4311900	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-01T17:28:51.719387684Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-01 17:28:51.719389+00	2026-02-01 17:28:51.719389+00	f	\N	\N	\N	\N	\N	\N	\N
839103a0-eb69-40a7-a924-2cc0fa246a70	82606870-9d3d-4c88-9586-8029c4311900	scanopy-daemon-1.scanopy_scanopy-dev	scanopy-daemon-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-01T17:28:35.510918617Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-01 17:28:35.510921+00	2026-02-01 17:28:35.510921+00	f	\N	\N	\N	\N	\N	\N	\N
4fddccd5-7840-408a-8fae-c5e462655fbc	82606870-9d3d-4c88-9586-8029c4311900	runnervmkj6or	runnervmkj6or	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-01T17:29:29.694825784Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-01 17:29:29.694829+00	2026-02-01 17:29:29.694829+00	f	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: if_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.if_entries (id, host_id, network_id, created_at, updated_at, if_index, if_descr, if_alias, if_type, speed_bps, admin_status, oper_status, mac_address, interface_id, neighbor_if_entry_id, neighbor_host_id, lldp_chassis_id, lldp_port_id, lldp_sys_name, lldp_port_desc, lldp_mgmt_addr, lldp_sys_desc, cdp_device_id, cdp_port_id, cdp_platform, cdp_address) FROM stdin;
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
82747a02-52ec-4e32-b2d6-9e80ad264cd8	82606870-9d3d-4c88-9586-8029c4311900	a9590643-88e0-45c1-8420-738ed98070ba	f6570079-8f33-4188-90f0-07a80576723a	172.25.0.7	72:88:c9:6b:bc:7e	eth0	0	2026-02-01 17:22:10.924008+00	2026-02-01 17:22:10.924008+00
d0328b46-56b5-450d-b9ff-55f249f0fa64	82606870-9d3d-4c88-9586-8029c4311900	1309a713-da9f-4ef4-b5f7-893cbbbaebf3	f6570079-8f33-4188-90f0-07a80576723a	172.25.0.5	b2:dd:36:5b:2b:35	\N	0	2026-02-01 17:28:19.158096+00	2026-02-01 17:28:19.158096+00
cfff8063-98f1-40c9-bd26-2f6cc9e2ab09	82606870-9d3d-4c88-9586-8029c4311900	07e159fd-7267-43d4-9032-d5f3605d3881	f6570079-8f33-4188-90f0-07a80576723a	172.25.0.3	8a:d3:99:b8:11:9e	\N	0	2026-02-01 17:28:51.719357+00	2026-02-01 17:28:51.719357+00
55afdb2c-9a9a-473a-bdea-7be4567ea430	82606870-9d3d-4c88-9586-8029c4311900	839103a0-eb69-40a7-a924-2cc0fa246a70	f6570079-8f33-4188-90f0-07a80576723a	172.25.0.4	6a:ef:d7:49:29:bd	\N	0	2026-02-01 17:28:35.510886+00	2026-02-01 17:28:35.510886+00
d14966c0-91d0-40db-ab68-218dd04b674e	82606870-9d3d-4c88-9586-8029c4311900	5ec565a7-0299-4c07-8501-a998b7ab7a80	f6570079-8f33-4188-90f0-07a80576723a	172.25.0.6	f2:09:19:12:57:a9	\N	0	2026-02-01 17:29:07.699985+00	2026-02-01 17:29:07.699985+00
8dbaab9f-b927-42b3-8b9d-2d9026373fe3	82606870-9d3d-4c88-9586-8029c4311900	4fddccd5-7840-408a-8fae-c5e462655fbc	f6570079-8f33-4188-90f0-07a80576723a	172.25.0.1	ea:36:9c:a3:e7:a4	\N	0	2026-02-01 17:29:29.694791+00	2026-02-01 17:29:29.694791+00
\.


--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invites (id, organization_id, permissions, network_ids, url, created_by, created_at, updated_at, expires_at, send_to) FROM stdin;
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, organization_id, snmp_credential_id) FROM stdin;
82606870-9d3d-4c88-9586-8029c4311900	My Network	2026-02-01 17:15:46.109795+00	2026-02-01 17:15:46.109795+00	e18754a0-a032-41e2-ac41-e7059bc2abf8	\N
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding, hubspot_company_id) FROM stdin;
e18754a0-a032-41e2-ac41-e7059bc2abf8	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2026-02-01 17:15:45.783903+00	2026-02-01 17:15:45.783903+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]	\N
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
cbd2decf-015d-4af6-987f-a86ff0df4cf8	82606870-9d3d-4c88-9586-8029c4311900	a9590643-88e0-45c1-8420-738ed98070ba	60074	Tcp	Custom	2026-02-01 17:22:10.931312+00	2026-02-01 17:22:10.931312+00
57ac68b3-d686-4c79-9838-d9d540c3f534	82606870-9d3d-4c88-9586-8029c4311900	1309a713-da9f-4ef4-b5f7-893cbbbaebf3	8123	Tcp	Custom	2026-02-01 17:28:32.422726+00	2026-02-01 17:28:32.422726+00
ef2acc93-fd50-4719-8fc0-d27b9922754e	82606870-9d3d-4c88-9586-8029c4311900	1309a713-da9f-4ef4-b5f7-893cbbbaebf3	18555	Tcp	Custom	2026-02-01 17:28:35.37224+00	2026-02-01 17:28:35.37224+00
1cacaa3f-25e7-4243-8a4b-7c1d1cde9d93	82606870-9d3d-4c88-9586-8029c4311900	07e159fd-7267-43d4-9032-d5f3605d3881	60072	Tcp	Custom	2026-02-01 17:29:04.06414+00	2026-02-01 17:29:04.06414+00
3e56e048-b5a2-463e-8539-c739ff5ed8fb	82606870-9d3d-4c88-9586-8029c4311900	839103a0-eb69-40a7-a924-2cc0fa246a70	60073	Tcp	Custom	2026-02-01 17:28:48.071616+00	2026-02-01 17:28:48.071616+00
2f651630-3bfe-4464-b1a4-ad5dcd4db0ce	82606870-9d3d-4c88-9586-8029c4311900	5ec565a7-0299-4c07-8501-a998b7ab7a80	5432	Tcp	PostgreSQL	2026-02-01 17:29:23.635877+00	2026-02-01 17:29:23.635877+00
db975840-0950-4f8a-88e3-a98a27612aa9	82606870-9d3d-4c88-9586-8029c4311900	4fddccd5-7840-408a-8fae-c5e462655fbc	60072	Tcp	Custom	2026-02-01 17:29:42.052602+00	2026-02-01 17:29:42.052602+00
9ebd4656-28d1-4c86-a0fb-fd5c3c4b9f1b	82606870-9d3d-4c88-9586-8029c4311900	4fddccd5-7840-408a-8fae-c5e462655fbc	8123	Tcp	Custom	2026-02-01 17:29:42.796193+00	2026-02-01 17:29:42.796193+00
8f18834b-ee37-4488-8e25-11c8bb4f1c31	82606870-9d3d-4c88-9586-8029c4311900	4fddccd5-7840-408a-8fae-c5e462655fbc	22	Tcp	Ssh	2026-02-01 17:29:45.669153+00	2026-02-01 17:29:45.669153+00
73db4064-7944-46f4-822e-87ce1189388b	82606870-9d3d-4c88-9586-8029c4311900	4fddccd5-7840-408a-8fae-c5e462655fbc	5435	Tcp	Custom	2026-02-01 17:29:45.669348+00	2026-02-01 17:29:45.669348+00
79ee49ff-1514-40b3-bcd9-8be79c846820	82606870-9d3d-4c88-9586-8029c4311900	4fddccd5-7840-408a-8fae-c5e462655fbc	60074	Tcp	Custom	2026-02-01 17:29:45.669351+00	2026-02-01 17:29:45.669351+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, "position") FROM stdin;
5711cdbb-058e-4624-b380-9f532b086b8c	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:22:10.931512+00	2026-02-01 17:22:10.931512+00	Scanopy Daemon	a9590643-88e0-45c1-8420-738ed98070ba	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-02-01T17:22:10.931511473Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b"}]}	0
5b1d3f9f-8f1d-4eae-b244-9064e1a9347b	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:28:32.422741+00	2026-02-01 17:28:32.422741+00	Home Assistant	1309a713-da9f-4ef4-b5f7-893cbbbaebf3	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-01T17:28:32.422717887Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
fb1d10ae-2420-4b39-82f2-a8040e830bd0	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:28:35.372254+00	2026-02-01 17:28:35.372254+00	Unclaimed Open Ports	1309a713-da9f-4ef4-b5f7-893cbbbaebf3	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-01T17:28:35.372233991Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	1
909a9987-59a4-43ce-9a0d-d6d98ccc4e10	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:29:04.064154+00	2026-02-01 17:29:04.064154+00	Scanopy Server	07e159fd-7267-43d4-9032-d5f3605d3881	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-01T17:29:04.064133340Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
57d51c4e-ed1e-4425-8381-7a1b7f84ef51	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:28:48.071628+00	2026-02-01 17:28:48.071628+00	Scanopy Daemon	839103a0-eb69-40a7-a924-2cc0fa246a70	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.4:60073/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-01T17:28:48.071609659Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
aeeb9288-ca19-4f33-ab57-b43630501a3d	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:29:23.63589+00	2026-02-01 17:29:23.63589+00	PostgreSQL	5ec565a7-0299-4c07-8501-a998b7ab7a80	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-01T17:29:23.635870754Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
9fdacfc6-5d18-4376-a1c7-8afe6d1e64e0	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:29:42.052617+00	2026-02-01 17:29:42.052617+00	Scanopy Server	4fddccd5-7840-408a-8fae-c5e462655fbc	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-01T17:29:42.052593791Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
6368be5a-8e80-4f93-9dfb-74310f34e111	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:29:42.796208+00	2026-02-01 17:29:42.796208+00	Home Assistant	4fddccd5-7840-408a-8fae-c5e462655fbc	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-01T17:29:42.796185896Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	1
81976797-7a61-4f6c-b1bd-e4e041739ed2	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:29:45.669169+00	2026-02-01 17:29:45.669169+00	SSH	4fddccd5-7840-408a-8fae-c5e462655fbc	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-01T17:29:45.669144404Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	2
1f68dd26-51ba-4afc-80c3-8ff0f914bbac	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:29:45.669358+00	2026-02-01 17:29:45.669358+00	Unclaimed Open Ports	4fddccd5-7840-408a-8fae-c5e462655fbc	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-01T17:29:45.669345819Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	3
\.


--
-- Data for Name: shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shares (id, topology_id, network_id, created_by, name, is_enabled, expires_at, password_hash, allowed_domains, options, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: snmp_credentials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.snmp_credentials (id, organization_id, created_at, updated_at, name, version, community) FROM stdin;
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
f6570079-8f33-4188-90f0-07a80576723a	82606870-9d3d-4c88-9586-8029c4311900	2026-02-01 17:22:07.987782+00	2026-02-01 17:22:07.987782+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-02-01T17:22:07.987778408Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "6518212c-bc34-407a-b895-6f7ba927bd85"}]}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
01e318f1-cc71-4d56-9605-34f49b41b6dc	e18754a0-a032-41e2-ac41-e7059bc2abf8	Integration Test Tag	\N	2026-02-01 17:30:41.012365+00	2026-02-01 17:30:41.012365+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings, if_entries, removed_if_entries) FROM stdin;
699f5cd5-402a-452a-b1f5-e7c5910ba837	82606870-9d3d-4c88-9586-8029c4311900	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "a9590643-88e0-45c1-8420-738ed98070ba", "name": "2fbecee5d7a0", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-02-01T17:22:10.931492689Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b"}]}, "hostname": "2fbecee5d7a0", "created_at": "2026-02-01T17:22:10.931495Z", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "updated_at": "2026-02-01T17:22:10.931495Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "1309a713-da9f-4ef4-b5f7-893cbbbaebf3", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-02-01T17:28:19.158130312Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2026-02-01T17:28:19.158132Z", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "updated_at": "2026-02-01T17:28:19.158132Z", "description": null, "virtualization": null}, {"id": "839103a0-eb69-40a7-a924-2cc0fa246a70", "name": "scanopy-daemon-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-02-01T17:28:35.510918617Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-daemon-1.scanopy_scanopy-dev", "created_at": "2026-02-01T17:28:35.510921Z", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "updated_at": "2026-02-01T17:28:35.510921Z", "description": null, "virtualization": null}, {"id": "07e159fd-7267-43d4-9032-d5f3605d3881", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-02-01T17:28:51.719387684Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2026-02-01T17:28:51.719389Z", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "updated_at": "2026-02-01T17:28:51.719389Z", "description": null, "virtualization": null}, {"id": "5ec565a7-0299-4c07-8501-a998b7ab7a80", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-02-01T17:29:07.700011294Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2026-02-01T17:29:07.700013Z", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "updated_at": "2026-02-01T17:29:07.700013Z", "description": null, "virtualization": null}, {"id": "4fddccd5-7840-408a-8fae-c5e462655fbc", "name": "runnervmkj6or", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-02-01T17:29:29.694825784Z", "type": "Network", "daemon_id": "aaea418e-66f0-4abc-8201-01c6b106148b", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmkj6or", "created_at": "2026-02-01T17:29:29.694829Z", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "updated_at": "2026-02-01T17:29:29.694829Z", "description": null, "virtualization": null}, {"id": "d82f9ec2-c823-4307-ad01-9de2affc2988", "name": "Updated Host", "tags": [], "hidden": false, "source": {"type": "Manual"}, "hostname": "test.local", "created_at": "2026-02-01T17:30:41.659726Z", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "updated_at": "2026-02-01T17:30:41.678350Z", "description": null, "virtualization": null}]	[{"id": "f6570079-8f33-4188-90f0-07a80576723a", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-02-01T17:22:07.987778408Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "6518212c-bc34-407a-b895-6f7ba927bd85"}]}, "created_at": "2026-02-01T17:22:07.987782Z", "network_id": "82606870-9d3d-4c88-9586-8029c4311900", "updated_at": "2026-02-01T17:22:07.987782Z", "description": null, "subnet_type": "Lan"}]	[]	[]	t	2026-02-01 17:15:46.128296+00	f	\N	\N	{78c36d0b-32ad-46df-a2b7-fcf9653490f6,d82f9ec2-c823-4307-ad01-9de2affc2988,79b5196a-bcef-42fe-9597-32d447673a77}	{45c1482d-918a-4e88-8142-0aa81e2b17e4}	{4903d7b4-2ba5-4693-8d23-2202cc9f4de1}	{04c680ff-7752-4ed3-a9a1-dccd116024ee}	\N	2026-02-01 17:15:46.116034+00	2026-02-01 17:15:46.116034+00	{}	[]	{}	[]	{}	[]	{}	[]	{}
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

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, tags, terms_accepted_at, email_verified, email_verification_token, email_verification_expires, password_reset_token, password_reset_expires) FROM stdin;
72339403-d9ae-4557-94cb-e71bf75fc0f5	2026-02-01 17:15:46.065039+00	2026-02-01 17:15:46.065039+00	$argon2id$v=19$m=19456,t=2,p=1$N8Jr836sGEzERUNCKlpZ0w$yZ1VgBFufvRq2i8tNLr7iouplCwNdgxsxtn+Z0zibd4	\N	\N	\N	user@gmail.com	e18754a0-a032-41e2-ac41-e7059bc2abf8	Owner	{}	\N	t	\N	\N	\N	\N
a092d955-665d-4373-82a5-bdcf91195d5a	2026-02-01 17:30:42.464423+00	2026-02-01 17:30:42.464423+00	\N	\N	\N	\N	user@example.com	e18754a0-a032-41e2-ac41-e7059bc2abf8	Owner	{}	\N	f	\N	\N	\N	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
PySONDAvQLAcRjk5sg5ohg	\\x93c41086680eb23939461cb0402f30348e243f81a7757365725f6964d92437323333393430332d643961652d343535372d393463622d65373162663735666330663599cd07ea27110f2ece0f643a3c000000	2026-02-08 17:15:46.258226+00
Gyrlt9iPyfHqKo_RRljbRQ	\\x93c41045db5846d18f2aeaf1c98fd8b7e52a1b82ad70656e64696e675f736574757082a86e6574776f726b739183a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92430343732373861662d306462642d346435302d623932352d653035633330653737653932ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92437323333393430332d643961652d343535372d393463622d65373162663735666330663599cd07ea27111602ce2f95129a000000	2026-02-08 17:22:02.798298+00
UPjmBlwI9X9BA4ZUMBnP4g	\\x93c410e2cf1930548603417ff5085c06e6f85082a7757365725f6964d92437323333393430332d643961652d343535372d393463622d653731626637356663306635ad70656e64696e675f736574757082a86e6574776f726b739183a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92439343766653130362d646331302d343139362d626562632d653266343432646236396562ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6e99cd07ea27111606ce2618fbae000000	2026-02-08 17:22:06.639171+00
u4Dd2bqFvX3WQ5i8Q2lDoA	\\x93c410a0436943bc9843d67dbd85bad9dd80bb82ad70656e64696e675f736574757082a86e6574776f726b739183a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92463303035373366612d316466342d343936662d383033642d663936636465393861663035ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92437323333393430332d643961652d343535372d393463622d65373162663735666330663599cd07ea27111e29ce24d168a9000000	2026-02-08 17:30:41.617703+00
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
-- Name: daemons daemons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_pkey PRIMARY KEY (id);


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
-- Name: group_bindings group_bindings_group_id_binding_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_bindings
    ADD CONSTRAINT group_bindings_group_id_binding_id_key UNIQUE (group_id, binding_id);


--
-- Name: group_bindings group_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_bindings
    ADD CONSTRAINT group_bindings_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: if_entries if_entries_host_id_if_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.if_entries
    ADD CONSTRAINT if_entries_host_id_if_index_key UNIQUE (host_id, if_index);


--
-- Name: if_entries if_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.if_entries
    ADD CONSTRAINT if_entries_pkey PRIMARY KEY (id);


--
-- Name: interfaces interfaces_host_id_subnet_id_ip_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_host_id_subnet_id_ip_address_key UNIQUE (host_id, subnet_id, ip_address);


--
-- Name: interfaces interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_pkey PRIMARY KEY (id);


--
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


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
-- Name: snmp_credentials snmp_credentials_organization_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.snmp_credentials
    ADD CONSTRAINT snmp_credentials_organization_id_name_key UNIQUE (organization_id, name);


--
-- Name: snmp_credentials snmp_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.snmp_credentials
    ADD CONSTRAINT snmp_credentials_pkey PRIMARY KEY (id);


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
-- Name: idx_bindings_interface; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bindings_interface ON public.bindings USING btree (interface_id);


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
-- Name: idx_group_bindings_binding; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_bindings_binding ON public.group_bindings USING btree (binding_id);


--
-- Name: idx_group_bindings_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_group_bindings_group ON public.group_bindings USING btree (group_id);


--
-- Name: idx_groups_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_groups_network ON public.groups USING btree (network_id);


--
-- Name: idx_hosts_chassis_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hosts_chassis_id ON public.hosts USING btree (chassis_id);


--
-- Name: idx_hosts_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hosts_network ON public.hosts USING btree (network_id);


--
-- Name: idx_hosts_snmp_credential; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hosts_snmp_credential ON public.hosts USING btree (snmp_credential_id);


--
-- Name: idx_if_entries_host; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_if_entries_host ON public.if_entries USING btree (host_id);


--
-- Name: idx_if_entries_interface; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_if_entries_interface ON public.if_entries USING btree (interface_id);


--
-- Name: idx_if_entries_mac_address; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_if_entries_mac_address ON public.if_entries USING btree (mac_address);


--
-- Name: idx_if_entries_neighbor_host; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_if_entries_neighbor_host ON public.if_entries USING btree (neighbor_host_id);


--
-- Name: idx_if_entries_neighbor_if_entry; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_if_entries_neighbor_if_entry ON public.if_entries USING btree (neighbor_if_entry_id);


--
-- Name: idx_if_entries_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_if_entries_network ON public.if_entries USING btree (network_id);


--
-- Name: idx_interfaces_host; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_host ON public.interfaces USING btree (host_id);


--
-- Name: idx_interfaces_host_mac; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_host_mac ON public.interfaces USING btree (host_id, mac_address) WHERE (mac_address IS NOT NULL);


--
-- Name: idx_interfaces_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_network ON public.interfaces USING btree (network_id);


--
-- Name: idx_interfaces_subnet; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_interfaces_subnet ON public.interfaces USING btree (subnet_id);


--
-- Name: idx_invites_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invites_expires_at ON public.invites USING btree (expires_at);


--
-- Name: idx_invites_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invites_organization ON public.invites USING btree (organization_id);


--
-- Name: idx_networks_owner_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_networks_owner_organization ON public.networks USING btree (organization_id);


--
-- Name: idx_networks_snmp_credential; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_networks_snmp_credential ON public.networks USING btree (snmp_credential_id);


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
-- Name: idx_snmp_credentials_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_snmp_credentials_org ON public.snmp_credentials USING btree (organization_id);


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
    ADD CONSTRAINT bindings_interface_id_fkey FOREIGN KEY (interface_id) REFERENCES public.interfaces(id) ON DELETE CASCADE;


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
-- Name: group_bindings group_bindings_binding_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_bindings
    ADD CONSTRAINT group_bindings_binding_id_fkey FOREIGN KEY (binding_id) REFERENCES public.bindings(id) ON DELETE CASCADE;


--
-- Name: group_bindings group_bindings_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_bindings
    ADD CONSTRAINT group_bindings_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: groups groups_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: hosts hosts_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: hosts hosts_snmp_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_snmp_credential_id_fkey FOREIGN KEY (snmp_credential_id) REFERENCES public.snmp_credentials(id) ON DELETE SET NULL;


--
-- Name: if_entries if_entries_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.if_entries
    ADD CONSTRAINT if_entries_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: if_entries if_entries_interface_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.if_entries
    ADD CONSTRAINT if_entries_interface_id_fkey FOREIGN KEY (interface_id) REFERENCES public.interfaces(id) ON DELETE SET NULL;


--
-- Name: if_entries if_entries_neighbor_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.if_entries
    ADD CONSTRAINT if_entries_neighbor_host_id_fkey FOREIGN KEY (neighbor_host_id) REFERENCES public.hosts(id) ON DELETE SET NULL;


--
-- Name: if_entries if_entries_neighbor_if_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.if_entries
    ADD CONSTRAINT if_entries_neighbor_if_entry_id_fkey FOREIGN KEY (neighbor_if_entry_id) REFERENCES public.if_entries(id) ON DELETE SET NULL;


--
-- Name: if_entries if_entries_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.if_entries
    ADD CONSTRAINT if_entries_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: interfaces interfaces_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: interfaces interfaces_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: interfaces interfaces_subnet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interfaces
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
-- Name: networks networks_snmp_credential_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT networks_snmp_credential_id_fkey FOREIGN KEY (snmp_credential_id) REFERENCES public.snmp_credentials(id) ON DELETE SET NULL;


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
-- Name: snmp_credentials snmp_credentials_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.snmp_credentials
    ADD CONSTRAINT snmp_credentials_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


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
-- PostgreSQL database dump complete
--

\unrestrict AlEcTe54KvjIVAbEl3Comh2kUjxwqgNUhbkNVehuDbujiub7HFYPtzE8yeBHlYj

