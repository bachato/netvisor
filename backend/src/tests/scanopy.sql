--
-- PostgreSQL database dump
--

\restrict zGHAYp9lYjlSsZ9AWkff8xdG7pyEFVLijNrkKiOVDC0A1OMD62npx9XaTKC5fGl

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
20251006215000	users	2026-02-02 19:01:43.78817+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3897066
20251006215100	networks	2026-02-02 19:01:43.79323+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4711772
20251006215151	create hosts	2026-02-02 19:01:43.798274+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3836372
20251006215155	create subnets	2026-02-02 19:01:43.802497+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4790599
20251006215201	create groups	2026-02-02 19:01:43.807726+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	10624771
20251006215204	create daemons	2026-02-02 19:01:43.818696+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4400503
20251006215212	create services	2026-02-02 19:01:43.823588+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4938234
20251029193448	user-auth	2026-02-02 19:01:43.82884+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	7407832
20251030044828	daemon api	2026-02-02 19:01:43.83658+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1720914
20251030170438	host-hide	2026-02-02 19:01:43.838788+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1151444
20251102224919	create discovery	2026-02-02 19:01:43.840263+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	14539430
20251106235621	normalize-daemon-cols	2026-02-02 19:01:43.855164+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	2351809
20251107034459	api keys	2026-02-02 19:01:43.857883+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	9253248
20251107222650	oidc-auth	2026-02-02 19:01:43.867465+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	31045191
20251110181948	orgs-billing	2026-02-02 19:01:43.898872+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	12288990
20251113223656	group-enhancements	2026-02-02 19:01:43.911556+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1146995
20251117032720	daemon-mode	2026-02-02 19:01:43.913044+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1155391
20251118143058	set-default-plan	2026-02-02 19:01:43.914517+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1237424
20251118225043	save-topology	2026-02-02 19:01:43.916084+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9448802
20251123232748	network-permissions	2026-02-02 19:01:43.925895+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	3756003
20251125001342	billing-updates	2026-02-02 19:01:43.930056+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1001765
20251128035448	org-onboarding-status	2026-02-02 19:01:43.931426+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1540118
20251129180942	nfs-consolidate	2026-02-02 19:01:43.933368+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1322742
20251206052641	discovery-progress	2026-02-02 19:01:43.935018+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1978424
20251206202200	plan-fix	2026-02-02 19:01:43.937309+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	1142617
20251207061341	daemon-url	2026-02-02 19:01:43.938778+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2540209
20251210045929	tags	2026-02-02 19:01:43.941705+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9931491
20251210175035	terms	2026-02-02 19:01:43.951984+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	889395
20251213025048	hash-keys	2026-02-02 19:01:43.953239+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	13665432
20251214050638	scanopy	2026-02-02 19:01:43.967251+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1472501
20251215215724	topo-scanopy-fix	2026-02-02 19:01:43.969013+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	1035768
20251217153736	category rename	2026-02-02 19:01:43.970509+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1749148
20251218053111	invite-persistence	2026-02-02 19:01:43.972656+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5340633
20251219211216	create shares	2026-02-02 19:01:43.978426+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6849443
20251220170928	permissions-cleanup	2026-02-02 19:01:43.9855+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1504962
20251220180000	commercial-to-community	2026-02-02 19:01:43.987303+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	933148
20251221010000	cleanup subnet type	2026-02-02 19:01:43.98857+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	864430
20251221020000	remove host target	2026-02-02 19:01:43.989711+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	996926
20251221030000	user network access	2026-02-02 19:01:43.990991+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7488672
20251221040000	interfaces table	2026-02-02 19:01:43.998923+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9996862
20251221050000	ports table	2026-02-02 19:01:44.009236+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	9194910
20251221060000	bindings table	2026-02-02 19:01:44.018839+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	10932604
20251221070000	group bindings	2026-02-02 19:01:44.030091+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6612682
20251222020000	tag cascade delete	2026-02-02 19:01:44.037077+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1243926
20251223232524	network remove default	2026-02-02 19:01:44.038664+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	995703
20251225100000	color enum	2026-02-02 19:01:44.039935+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1393414
20251227010000	topology snapshot migration	2026-02-02 19:01:44.041681+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4564066
20251228010000	user api keys	2026-02-02 19:01:44.046728+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	12679718
20251230160000	daemon version and maintainer	2026-02-02 19:01:44.059758+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	3129767
20260103000000	service position	2026-02-02 19:01:44.063216+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	2023316
20260106000000	interface mac index	2026-02-02 19:01:44.065807+00	t	\\xa26248372a1e31af46a9c6fbdaef178982229e2ceeb90cc6a289d5764f87a38747294b3adf5f21276b5d171e42bdb6ac	1934522
20260106204402	entity tags junction	2026-02-02 19:01:44.068075+00	t	\\xf73c604f9f0b8db065d990a861684b0dbd62c3ef9bead120c68431c933774de56491a53f021e79f09801680152f5a08a	13886394
20260108033856	fix entity tags json format	2026-02-02 19:01:44.082305+00	t	\\x197eaa063d4f96dd0e897ad8fd96cc1ba9a54dda40a93a5c12eac14597e4dea4c806dd0a527736fb5807b7a8870d9916	1873598
20260110000000	email verification	2026-02-02 19:01:44.084532+00	t	\\xb8da8433f58ba4ce846b9fa0c2551795747a8473ad10266b19685504847458ea69d27a0ce430151cfb426f5f5fb6ac3a	3371048
20260114145808	daemon user fk set null	2026-02-02 19:01:44.0883+00	t	\\x57b060be9fc314d7c5851c75661ca8269118feea6cf7ee9c61b147a0e117c4d39642cf0d1acdf7a723a9a76066c1b8ff	1111149
20260116010000	snmp credentials	2026-02-02 19:01:44.089824+00	t	\\x6f3971cf194d56883c61fa795406a8ab568307ed86544920d098b32a6a1ebb7effcb5ec38a70fdc9b617eff92d63d51e	7563212
20260116020000	host snmp fields	2026-02-02 19:01:44.097963+00	t	\\xf2f088c13ab0dd34e1cb1e5327b0b4137440b0146e5ce1e78b8d2dfa05d9b5a12a328eeb807988453a8a43ad8a1c95ba	4273003
20260116030000	if entries	2026-02-02 19:01:44.102592+00	t	\\xa58391708f8b21901ab9250af528f638a6055462f70ffddfd7c451433aacdabd62825546fa8be108f23a3cae78b8ae28	13150604
20260116100000	daemon api key link	2026-02-02 19:01:44.116082+00	t	\\x41088aa314ab173344a6b416280721806b2f296a32a8d8cae58c7e5717f389fe599134ed03980ed97e4b7659e99c4f82	3442138
20260131190000	add hubspot company id	2026-02-02 19:01:44.119907+00	t	\\x4326f95f4954e176157c1c3e034074a3e5c44da4d60bbd7a9e4b6238c9ef52a30f8b38d3c887864b6e4c1163dc062beb	1007295
20260201021238	fix service acronym capitalization	2026-02-02 19:01:44.121232+00	t	\\x88b010ac8f0223d880ea6a730f11dc6d27fa5de9d8747de3431e46d59f1dbf2f72ae4a87c2e52c32152549f5c1f96bb2	1483802
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, plaintext) FROM stdin;
c269ea27-1d51-4445-be23-ab50575ad6d8	b8420d992ab66215656d58b5778ecb16b0d76d965447adc2af6dee6e2157375c	2f910507-55a0-4c52-a42c-6002b6284e15	Integrated Daemon API Key	2026-02-02 19:01:47.86083+00	2026-02-02 19:01:47.86083+00	2026-02-02 19:16:27.789815+00	\N	t	\N
1b9887e5-083d-440c-9d29-1621b40780ef	9604196b44b372ea90f8ed51f395ad9b27b34987c803df4966ce53403c0ad133	2f910507-55a0-4c52-a42c-6002b6284e15	Compat Test API Key	2026-02-02 19:08:05.093978+00	2026-02-02 19:08:05.093978+00	2026-02-02 19:08:08.851207+00	\N	t	\N
da14fea9-7a06-4515-b497-b8f46abb44dc	658d7b516dd18cbd20558803bd733e159d8330d1b0d974fe816e8c9fe42b1f08	2f910507-55a0-4c52-a42c-6002b6284e15	scanopy-daemon-serverpoll API Key	2026-02-02 19:08:04.211012+00	2026-02-02 19:08:04.211012+00	2026-02-02 19:16:45.267614+00	\N	t	scp_d_TdHtmlSnRcZDZ8rRGbt62JXVuCUAD26U
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
56250efe-c72d-4f06-8655-fa5063a83356	2f910507-55a0-4c52-a42c-6002b6284e15	ff83d0f6-5a66-4ce1-b65d-21a3f24bdc14	Port	e6992b13-0e5c-4ec4-82da-d6c126aed1c1	b45ed9b6-7b1f-4093-8e13-f30a26ba952b	2026-02-02 19:08:14.26644+00	2026-02-02 19:08:14.26644+00
41e1236e-2856-467a-9ae8-be45dc9be40c	2f910507-55a0-4c52-a42c-6002b6284e15	3b495395-bc16-4229-bf82-79bcbc0daba5	Port	628b20f1-e8a2-450c-a75c-e061527ee7be	6d9f5d18-60ca-409a-ba11-8aa986a4d845	2026-02-02 19:14:38.451037+00	2026-02-02 19:14:38.451037+00
3a194302-0d0d-411f-8fe5-cb2aa1e583aa	2f910507-55a0-4c52-a42c-6002b6284e15	ab4995d4-bc76-45db-baf7-673d68e73b41	Port	ede791d4-25dd-4f8b-aa58-c53a64386d79	7cc058bb-d8f3-4f17-a91b-1025faa05dc5	2026-02-02 19:14:46.635503+00	2026-02-02 19:14:46.635503+00
0115519c-34fc-444d-a0da-df4eeae31fdc	2f910507-55a0-4c52-a42c-6002b6284e15	32616a7a-752a-42bb-8161-e463ed0cd342	Port	ede791d4-25dd-4f8b-aa58-c53a64386d79	56a394b7-8bde-4ea2-8558-19e45a262985	2026-02-02 19:14:54.755148+00	2026-02-02 19:14:54.755148+00
d3662400-887d-47f9-9506-5cf853eaa756	2f910507-55a0-4c52-a42c-6002b6284e15	c1a335f5-c0e2-4d5d-89df-eac0fd19b4a3	Port	a115bc41-8df7-462e-acb4-eead9126f8d5	9c89fb84-e125-45e6-951a-574598da006d	2026-02-02 19:14:54.794535+00	2026-02-02 19:14:54.794535+00
d0be9919-676c-4520-80fb-0c20e61c8bcf	2f910507-55a0-4c52-a42c-6002b6284e15	e6030f60-2274-408a-bf32-11ff29f3c2a0	Port	a2e0b704-bc29-4a52-8508-e33973fd5256	82c81c0e-2762-4a1c-91aa-4d5e81776616	2026-02-02 19:15:26.467+00	2026-02-02 19:15:26.467+00
d15390b2-1a68-4646-a050-75da1299284e	2f910507-55a0-4c52-a42c-6002b6284e15	2c70fb41-7c8f-4a5b-a052-822d9b80b31b	Port	4dc5cf49-f1f8-414f-8160-d0ad67079a24	19b9d871-15a8-4ed5-af10-ac75f8e3c83a	2026-02-02 19:15:40.489054+00	2026-02-02 19:15:40.489054+00
80363753-c6c0-4b7c-a0f6-1169df366a60	2f910507-55a0-4c52-a42c-6002b6284e15	67b94308-ee02-4b1b-a8d1-78a0492f7e47	Port	4dc5cf49-f1f8-414f-8160-d0ad67079a24	70c7d00a-11a6-49c6-a4c2-e5582e32c701	2026-02-02 19:15:46.9934+00	2026-02-02 19:15:46.9934+00
539abdcc-df46-4d2b-82f2-031477d1a30f	2f910507-55a0-4c52-a42c-6002b6284e15	ebd95384-3141-4ee7-8bf4-011c280ec68e	Port	4dc5cf49-f1f8-414f-8160-d0ad67079a24	e81f5d5f-4449-4105-a297-14bc5e65db27	2026-02-02 19:15:48.401127+00	2026-02-02 19:15:48.401127+00
34930a04-a681-453e-b6a5-a10575a48c14	2f910507-55a0-4c52-a42c-6002b6284e15	f65afa3a-9995-40d4-bcd5-63ee107fce84	Port	4dc5cf49-f1f8-414f-8160-d0ad67079a24	59ae6e20-5f17-4489-b33e-8d0bcdba11d0	2026-02-02 19:15:48.401499+00	2026-02-02 19:15:48.401499+00
422be19e-5611-4e74-87b9-c632905be7e3	2f910507-55a0-4c52-a42c-6002b6284e15	f65afa3a-9995-40d4-bcd5-63ee107fce84	Port	4dc5cf49-f1f8-414f-8160-d0ad67079a24	2a4fcbcb-f8e1-4996-ac98-69d31345c822	2026-02-02 19:15:48.4015+00	2026-02-02 19:15:48.4015+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, version, user_id, api_key_id, is_unreachable) FROM stdin;
dc0c404c-e549-43a6-be79-05295ee7cb3f	2f910507-55a0-4c52-a42c-6002b6284e15	37e5888d-4a4e-4ca3-908c-a8939cc75bdd	2026-02-02 19:01:47.932119+00	2026-02-02 19:16:27.79353+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["3c01d70b-8334-4bcd-912d-d2a874de3344"]}	2026-02-02 19:01:47.932119+00	"daemon_poll"		scanopy-daemon	0.14.2	f469f7ea-b729-42a4-91c7-9d50aebc40ba	\N	f
5a3fb205-4e82-4368-9d7a-7b48311f1e47	2f910507-55a0-4c52-a42c-6002b6284e15	cb9226cb-17b6-4109-b89c-4199eec310d9	2026-02-02 19:08:04.214709+00	2026-02-02 19:16:44.178154+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["0fe58b78-fe81-4b72-ad06-04aae97ef366"]}	2026-02-02 19:08:04.214709+00	"server_poll"	http://daemon-serverpoll:60074	scanopy-daemon-serverpoll	0.14.2	f469f7ea-b729-42a4-91c7-9d50aebc40ba	da14fea9-7a06-4515-b497-b8f46abb44dc	f
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
d64da63f-0f00-42e4-aa77-cf0189c2731f	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd"}	Self Report	2026-02-02 19:01:47.938138+00	2026-02-02 19:01:47.938138+00
3840e665-d471-4719-b442-d70de7b791f5	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery	2026-02-02 19:01:47.940086+00	2026-02-02 19:01:47.940086+00
66ebef8d-a72e-4971-b032-e921e9debfc8	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "e5274c5c-4478-40d5-86c6-aabbe025f093", "started_at": "2026-02-02T19:01:57.807520644Z", "finished_at": "2026-02-02T19:01:57.851778498Z", "discovery_type": {"type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd"}}}	{"type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd"}	Self Report	2026-02-02 19:01:57.80752+00	2026-02-02 19:01:57.857023+00
3c3dd802-0a39-4b09-8a0d-1523d2226514	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "6619a14f-f0d3-467e-a3bc-85b14f0b7652", "started_at": "2026-02-02T19:02:27.806115362Z", "finished_at": "2026-02-02T19:08:03.836216835Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery	2026-02-02 19:02:27.806115+00	2026-02-02 19:08:03.84151+00
3c819a49-4574-46b5-92f3-da73586e6866	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "f2d5414b-3369-4280-929d-5422dd11a4b4", "started_at": "2026-02-02T19:08:10.104691291Z", "finished_at": "2026-02-02T19:08:10.110939957Z", "discovery_type": {"type": "SelfReport", "host_id": "8f6b3991-b3ef-4d1d-9708-d2f57289a34f"}}}	{"type": "SelfReport", "host_id": "8f6b3991-b3ef-4d1d-9708-d2f57289a34f"}	Self Report	2026-02-02 19:08:10.104691+00	2026-02-02 19:08:10.115409+00
bf4b15f5-eccd-4b0e-bda7-38b95f315770	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "f2d5414b-3369-4280-929d-5422dd11a4b4", "started_at": "2026-02-02T19:08:10.373196811Z", "finished_at": "2026-02-02T19:08:10.379589096Z", "discovery_type": {"type": "SelfReport", "host_id": "8f6b3991-b3ef-4d1d-9708-d2f57289a34f"}}}	{"type": "SelfReport", "host_id": "8f6b3991-b3ef-4d1d-9708-d2f57289a34f"}	Self Report	2026-02-02 19:08:10.373196+00	2026-02-02 19:08:10.385023+00
a943c871-91b5-450c-b9e2-30dc9ac687cb	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "7f54ecab-3771-4583-a7d0-f12569030e17", "started_at": "2026-02-02T19:08:10.639233164Z", "finished_at": "2026-02-02T19:08:10.645093236Z", "discovery_type": {"type": "SelfReport", "host_id": "f738b076-a24e-4db2-800c-a0f10bb44b16"}}}	{"type": "SelfReport", "host_id": "f738b076-a24e-4db2-800c-a0f10bb44b16"}	Self Report	2026-02-02 19:08:10.639233+00	2026-02-02 19:08:10.649245+00
3f21b6aa-1b69-4f3e-b736-def943c4f16c	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "b64df0ca-f173-4ba8-a48b-edf7e372974a", "started_at": "2026-02-02T19:08:10.897531560Z", "finished_at": "2026-02-02T19:08:10.903796534Z", "discovery_type": {"type": "SelfReport", "host_id": "09900acc-93fd-4af9-8a9b-9f45ace7475c"}}}	{"type": "SelfReport", "host_id": "09900acc-93fd-4af9-8a9b-9f45ace7475c"}	Self Report	2026-02-02 19:08:10.897531+00	2026-02-02 19:08:10.907835+00
ac6cbcef-18d4-431e-8d4d-a6ebfaa590ce	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "c8c6530c-aaff-4d7c-a872-ba4457906d77", "started_at": "2026-02-02T19:08:11.158039295Z", "finished_at": "2026-02-02T19:08:11.164336521Z", "discovery_type": {"type": "SelfReport", "host_id": "cc741d90-bcc0-4653-b38b-52b23f9e6a61"}}}	{"type": "SelfReport", "host_id": "cc741d90-bcc0-4653-b38b-52b23f9e6a61"}	Self Report	2026-02-02 19:08:11.158039+00	2026-02-02 19:08:11.168596+00
cef93385-dffd-4cf7-8162-bd02fabce990	2f910507-55a0-4c52-a42c-6002b6284e15	5a3fb205-4e82-4368-9d7a-7b48311f1e47	{"type": "AdHoc", "last_run": "2026-02-02T19:08:11.681015109Z"}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	ServerPoll Integration Test Discovery	2026-02-02 19:08:11.674371+00	2026-02-02 19:08:11.674371+00
018524ab-ba35-4481-9537-3e77be85dae6	2f910507-55a0-4c52-a42c-6002b6284e15	5a3fb205-4e82-4368-9d7a-7b48311f1e47	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "cb9226cb-17b6-4109-b89c-4199eec310d9"}	Self Report	2026-02-02 19:08:14.181927+00	2026-02-02 19:08:14.181927+00
92b0cf57-82fe-4071-a289-c9561e76f1c0	2f910507-55a0-4c52-a42c-6002b6284e15	5a3fb205-4e82-4368-9d7a-7b48311f1e47	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery	2026-02-02 19:08:14.183245+00	2026-02-02 19:08:14.183245+00
e40742ea-c362-4639-b608-d1702357f3a2	2f910507-55a0-4c52-a42c-6002b6284e15	5a3fb205-4e82-4368-9d7a-7b48311f1e47	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "5b19fece-cb82-45d8-a676-df53cc38a014", "started_at": "2026-02-02T19:08:14.250084077Z", "finished_at": "2026-02-02T19:09:49.286838143Z", "discovery_type": {"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}}}	{"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}	Self Report	2026-02-02 19:08:14.250084+00	2026-02-02 19:10:44.184068+00
dfa904c8-a60f-4efe-930a-d4725f02c8cc	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "f7531810-14a6-48d2-aa0f-8b4e9e97d176", "started_at": "2026-01-26T13:52:00.181047960Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-01-26 13:52:00.181047+00	2026-02-02 19:13:44.173198+00
d4519232-e805-4c28-a896-ce2ae1e5ab1b	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": null, "phase": "Cancelled", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "c8c6530c-aaff-4d7c-a872-ba4457906d77", "started_at": "2026-02-02T19:08:11.158039295Z", "finished_at": "2026-02-02T19:08:11.164336521Z", "discovery_type": {"type": "SelfReport", "host_id": "cc741d90-bcc0-4653-b38b-52b23f9e6a61"}}}	{"type": "SelfReport", "host_id": "cc741d90-bcc0-4653-b38b-52b23f9e6a61"}	Self Report	2026-02-02 19:08:11.158039+00	2026-02-02 19:08:14.191241+00
7ba29e1b-2f75-44ce-8201-4f881054510d	2f910507-55a0-4c52-a42c-6002b6284e15	5a3fb205-4e82-4368-9d7a-7b48311f1e47	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "5b19fece-cb82-45d8-a676-df53cc38a014", "started_at": "2026-02-02T19:08:14.250084077Z", "finished_at": "2026-02-02T19:09:49.286838143Z", "discovery_type": {"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}}}	{"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}	Self Report	2026-02-02 19:08:14.250084+00	2026-02-02 19:09:49.29464+00
f015be0e-693c-4485-a4a1-289c088e136a	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "e5274c5c-4478-40d5-86c6-aabbe025f093", "started_at": "2026-02-02T19:01:57.807520644Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd"}}}	{"type": "SelfReport", "host_id": "37e5888d-4a4e-4ca3-908c-a8939cc75bdd"}	Discovery Run (Stalled)	2026-02-02 19:01:57.80752+00	2026-02-02 19:13:44.173198+00
a98c5fc5-2b21-4dfd-9eee-c75544face31	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "7c20860a-b07c-4c4f-81bc-c7f44bee7a3d", "started_at": "2026-02-02T14:29:34.148055772Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-02-02 14:29:34.148055+00	2026-02-02 19:13:44.173198+00
357bb19c-c443-40d3-b3fd-707313841adf	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "7c314669-ec4f-4719-9e7e-2c579c7d9cd6", "started_at": "2026-01-25T23:12:40.158142587Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-01-25 23:12:40.158142+00	2026-02-02 19:13:44.173198+00
2b2e9362-3f69-498b-a49e-119b84e076a4	2f910507-55a0-4c52-a42c-6002b6284e15	5a3fb205-4e82-4368-9d7a-7b48311f1e47	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "5b19fece-cb82-45d8-a676-df53cc38a014", "started_at": "2026-02-02T19:08:14.250084077Z", "finished_at": "2026-02-02T19:09:49.286838143Z", "discovery_type": {"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}}}	{"type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba"}	Self Report	2026-02-02 19:08:14.250084+00	2026-02-02 19:10:14.183627+00
da9c17cb-ffa0-42e3-b506-363109e8bf08	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "6619a14f-f0d3-467e-a3bc-85b14f0b7652", "started_at": "2026-02-02T19:02:27.806115362Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-02-02 19:02:27.806115+00	2026-02-02 19:13:44.173198+00
3a1156c0-eb5f-45dd-9ba9-1b505f6ed321	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "52a4d1e0-c3b9-4b20-a4e8-0196198a1c15", "started_at": "2026-02-02T14:20:51.227652182Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "SelfReport", "host_id": "53cf4d7a-0ed6-452f-8bc6-4e4a3d611182"}}}	{"type": "SelfReport", "host_id": "53cf4d7a-0ed6-452f-8bc6-4e4a3d611182"}	Discovery Run (Stalled)	2026-02-02 14:20:51.227652+00	2026-02-02 19:13:44.173198+00
fe1c4187-797f-4019-ac8f-4c0861344397	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "bd93b206-4e22-4e0a-9dd0-0f38664a4247", "started_at": "2026-02-02T14:21:21.225991527Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-02-02 14:21:21.225991+00	2026-02-02 19:13:44.173198+00
4abeee42-e9ff-4d68-8017-e0013ca1b262	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "1a182cd9-9710-482e-8645-d95c40db018a", "started_at": "2026-01-26T14:03:24.338877430Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "SelfReport", "host_id": "7891ed81-377c-4eca-b05e-bc8a17129f90"}}}	{"type": "SelfReport", "host_id": "7891ed81-377c-4eca-b05e-bc8a17129f90"}	Discovery Run (Stalled)	2026-01-26 14:03:24.338877+00	2026-02-02 19:13:44.173198+00
2d9e1da8-8fc2-456e-99ba-3e79489327ef	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "580379b9-0101-428f-baef-843afbc5dfee", "started_at": "2026-01-26T14:03:54.326189222Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Discovery Run (Stalled)	2026-01-26 14:03:54.326189+00	2026-02-02 19:13:44.173198+00
5298ae47-ed15-4b0a-93bb-d7b974f9f450	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "adfad9b0-e25d-4bd4-88bc-e0ecc0f3f4a4", "started_at": "2026-01-26T13:51:30.181086877Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "SelfReport", "host_id": "01d97cc8-84d8-4806-877f-52bfd29791f8"}}}	{"type": "SelfReport", "host_id": "01d97cc8-84d8-4806-877f-52bfd29791f8"}	Discovery Run (Stalled)	2026-01-26 13:51:30.181086+00	2026-02-02 19:13:44.173198+00
2e61fb40-20c4-4471-905a-bdc9b42c39fc	2f910507-55a0-4c52-a42c-6002b6284e15	dc0c404c-e549-43a6-be79-05295ee7cb3f	{"type": "Historical", "results": {"error": "Session stalled - no updates received from daemon for more than 5 minutes", "phase": "Failed", "progress": 0, "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "f5a833cc-002f-41e1-b540-c0a623d6775c", "started_at": "2026-01-25T23:12:10.196614920Z", "finished_at": "2026-02-02T19:13:44.173198631Z", "discovery_type": {"type": "SelfReport", "host_id": "7c51d243-60ef-4994-b7db-fa41b23b3644"}}}	{"type": "SelfReport", "host_id": "7c51d243-60ef-4994-b7db-fa41b23b3644"}	Discovery Run (Stalled)	2026-01-25 23:12:10.196614+00	2026-02-02 19:13:44.173198+00
859e8689-ba0e-4dd7-8516-c8b0a2b73326	2f910507-55a0-4c52-a42c-6002b6284e15	5a3fb205-4e82-4368-9d7a-7b48311f1e47	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "session_id": "ad00e2b8-5af6-4685-a8b4-fc7aa70a5a4e", "started_at": "2026-02-02T19:10:44.236020863Z", "finished_at": "2026-02-02T19:16:45.266369933Z", "discovery_type": {"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}	Network Discovery	2026-02-02 19:10:44.23602+00	2026-02-02 19:16:45.272073+00
\.


--
-- Data for Name: entity_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_tags (id, entity_id, entity_type, tag_id, created_at) FROM stdin;
9b369d8d-1c14-4609-9a18-2568a820eef4	ab4995d4-bc76-45db-baf7-673d68e73b41	"Service"	ea25a343-f6ff-4532-8168-08634e3ec712	2026-02-02 19:16:45.292806+00
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
02a4d76d-7fee-455e-adc8-0332b03f863c	2f910507-55a0-4c52-a42c-6002b6284e15		\N	2026-02-02 19:16:45.294636+00	2026-02-02 19:16:45.294636+00	{"type": "Manual"}	Yellow	"SmoothStep"	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden, sys_descr, sys_object_id, sys_location, sys_contact, management_url, chassis_id, snmp_credential_id) FROM stdin;
9292fd99-407e-481b-a6a9-0d6d422a8c3c	2f910507-55a0-4c52-a42c-6002b6284e15	scanopy-daemon-1.scanopy_scanopy-dev	scanopy-daemon-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:14:54.794211432Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-02 19:14:54.794212+00	2026-02-02 19:14:54.794212+00	f	\N	\N	\N	\N	\N	\N	\N
a9590643-88e0-45c1-8420-738ed98070ba	2f910507-55a0-4c52-a42c-6002b6284e15	599142dee50e	599142dee50e	Scanopy daemon	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:08:14.266422464Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47"}]}	null	2026-02-02 19:08:14.266424+00	2026-02-02 19:08:14.266424+00	f	\N	\N	\N	\N	\N	\N	\N
c4878043-f3b3-4b63-89c6-3432504ca781	2f910507-55a0-4c52-a42c-6002b6284e15	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:14:22.172602700Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-02 19:14:22.172605+00	2026-02-02 19:14:22.172605+00	f	\N	\N	\N	\N	\N	\N	\N
41118021-be7e-46ae-929a-f81dbc58de0a	2f910507-55a0-4c52-a42c-6002b6284e15	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:14:38.560073977Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-02 19:14:38.560076+00	2026-02-02 19:14:38.560076+00	f	\N	\N	\N	\N	\N	\N	\N
e27f914c-ba84-46dc-b7a8-15bb2317e4f6	2f910507-55a0-4c52-a42c-6002b6284e15	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:15:10.601466705Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-02 19:15:10.601468+00	2026-02-02 19:15:10.601468+00	f	\N	\N	\N	\N	\N	\N	\N
a1fdc84f-2a77-4040-92c1-3ec72f75f916	2f910507-55a0-4c52-a42c-6002b6284e15	runnervmkj6or	runnervmkj6or	\N	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:15:32.581081494Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	null	2026-02-02 19:15:32.581084+00	2026-02-02 19:15:32.581084+00	f	\N	\N	\N	\N	\N	\N	\N
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
e6992b13-0e5c-4ec4-82da-d6c126aed1c1	2f910507-55a0-4c52-a42c-6002b6284e15	a9590643-88e0-45c1-8420-738ed98070ba	0fe58b78-fe81-4b72-ad06-04aae97ef366	172.25.0.7	da:c7:3d:ee:60:df	eth0	0	2026-02-02 19:08:14.256577+00	2026-02-02 19:08:14.256577+00
628b20f1-e8a2-450c-a75c-e061527ee7be	2f910507-55a0-4c52-a42c-6002b6284e15	c4878043-f3b3-4b63-89c6-3432504ca781	0fe58b78-fe81-4b72-ad06-04aae97ef366	172.25.0.6	96:26:20:53:2d:66	\N	0	2026-02-02 19:14:22.172563+00	2026-02-02 19:14:22.172563+00
ede791d4-25dd-4f8b-aa58-c53a64386d79	2f910507-55a0-4c52-a42c-6002b6284e15	41118021-be7e-46ae-929a-f81dbc58de0a	0fe58b78-fe81-4b72-ad06-04aae97ef366	172.25.0.5	8e:6e:97:83:72:e2	\N	0	2026-02-02 19:14:38.560045+00	2026-02-02 19:14:38.560045+00
a115bc41-8df7-462e-acb4-eead9126f8d5	2f910507-55a0-4c52-a42c-6002b6284e15	9292fd99-407e-481b-a6a9-0d6d422a8c3c	0fe58b78-fe81-4b72-ad06-04aae97ef366	172.25.0.4	36:cf:1e:78:da:59	\N	0	2026-02-02 19:14:54.794182+00	2026-02-02 19:14:54.794182+00
a2e0b704-bc29-4a52-8508-e33973fd5256	2f910507-55a0-4c52-a42c-6002b6284e15	e27f914c-ba84-46dc-b7a8-15bb2317e4f6	0fe58b78-fe81-4b72-ad06-04aae97ef366	172.25.0.3	ee:58:26:98:42:99	\N	0	2026-02-02 19:15:10.601438+00	2026-02-02 19:15:10.601438+00
4dc5cf49-f1f8-414f-8160-d0ad67079a24	2f910507-55a0-4c52-a42c-6002b6284e15	a1fdc84f-2a77-4040-92c1-3ec72f75f916	0fe58b78-fe81-4b72-ad06-04aae97ef366	172.25.0.1	82:ac:81:6a:45:ad	\N	0	2026-02-02 19:15:32.581044+00	2026-02-02 19:15:32.581044+00
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
2f910507-55a0-4c52-a42c-6002b6284e15	My Network	2026-02-02 19:01:47.842437+00	2026-02-02 19:01:47.842437+00	e1913918-75b7-4be2-893a-581bfd6e7937	\N
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding, hubspot_company_id) FROM stdin;
e1913918-75b7-4be2-893a-581bfd6e7937	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2026-02-02 19:01:47.833793+00	2026-02-02 19:01:47.833793+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]	\N
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
b45ed9b6-7b1f-4093-8e13-f30a26ba952b	2f910507-55a0-4c52-a42c-6002b6284e15	a9590643-88e0-45c1-8420-738ed98070ba	60074	Tcp	Custom	2026-02-02 19:08:14.266209+00	2026-02-02 19:08:14.266209+00
6d9f5d18-60ca-409a-ba11-8aa986a4d845	2f910507-55a0-4c52-a42c-6002b6284e15	c4878043-f3b3-4b63-89c6-3432504ca781	5432	Tcp	PostgreSQL	2026-02-02 19:14:38.451027+00	2026-02-02 19:14:38.451027+00
7cc058bb-d8f3-4f17-a91b-1025faa05dc5	2f910507-55a0-4c52-a42c-6002b6284e15	41118021-be7e-46ae-929a-f81dbc58de0a	8123	Tcp	Custom	2026-02-02 19:14:46.63549+00	2026-02-02 19:14:46.63549+00
56a394b7-8bde-4ea2-8558-19e45a262985	2f910507-55a0-4c52-a42c-6002b6284e15	41118021-be7e-46ae-929a-f81dbc58de0a	18555	Tcp	Custom	2026-02-02 19:14:54.755138+00	2026-02-02 19:14:54.755138+00
9c89fb84-e125-45e6-951a-574598da006d	2f910507-55a0-4c52-a42c-6002b6284e15	9292fd99-407e-481b-a6a9-0d6d422a8c3c	60073	Tcp	Custom	2026-02-02 19:14:54.794527+00	2026-02-02 19:14:54.794527+00
82c81c0e-2762-4a1c-91aa-4d5e81776616	2f910507-55a0-4c52-a42c-6002b6284e15	e27f914c-ba84-46dc-b7a8-15bb2317e4f6	60072	Tcp	Custom	2026-02-02 19:15:26.46699+00	2026-02-02 19:15:26.46699+00
19b9d871-15a8-4ed5-af10-ac75f8e3c83a	2f910507-55a0-4c52-a42c-6002b6284e15	a1fdc84f-2a77-4040-92c1-3ec72f75f916	8123	Tcp	Custom	2026-02-02 19:15:40.489043+00	2026-02-02 19:15:40.489043+00
70c7d00a-11a6-49c6-a4c2-e5582e32c701	2f910507-55a0-4c52-a42c-6002b6284e15	a1fdc84f-2a77-4040-92c1-3ec72f75f916	60072	Tcp	Custom	2026-02-02 19:15:46.99339+00	2026-02-02 19:15:46.99339+00
e81f5d5f-4449-4105-a297-14bc5e65db27	2f910507-55a0-4c52-a42c-6002b6284e15	a1fdc84f-2a77-4040-92c1-3ec72f75f916	22	Tcp	Ssh	2026-02-02 19:15:48.401117+00	2026-02-02 19:15:48.401117+00
59ae6e20-5f17-4489-b33e-8d0bcdba11d0	2f910507-55a0-4c52-a42c-6002b6284e15	a1fdc84f-2a77-4040-92c1-3ec72f75f916	5435	Tcp	Custom	2026-02-02 19:15:48.401495+00	2026-02-02 19:15:48.401495+00
2a4fcbcb-f8e1-4996-ac98-69d31345c822	2f910507-55a0-4c52-a42c-6002b6284e15	a1fdc84f-2a77-4040-92c1-3ec72f75f916	60074	Tcp	Custom	2026-02-02 19:15:48.401497+00	2026-02-02 19:15:48.401497+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, "position") FROM stdin;
ff83d0f6-5a66-4ce1-b65d-21a3f24bdc14	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:08:14.266445+00	2026-02-02 19:08:14.266445+00	Scanopy Daemon	a9590643-88e0-45c1-8420-738ed98070ba	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-02-02T19:08:14.266444094Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47"}]}	0
3b495395-bc16-4229-bf82-79bcbc0daba5	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:14:38.451042+00	2026-02-02 19:14:38.451042+00	PostgreSQL	c4878043-f3b3-4b63-89c6-3432504ca781	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-02T19:14:38.451020301Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
ab4995d4-bc76-45db-baf7-673d68e73b41	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:14:46.635508+00	2026-02-02 19:14:46.635508+00	Home Assistant	41118021-be7e-46ae-929a-f81dbc58de0a	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-02T19:14:46.635480898Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
32616a7a-752a-42bb-8161-e463ed0cd342	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:14:54.755153+00	2026-02-02 19:14:54.755153+00	Unclaimed Open Ports	41118021-be7e-46ae-929a-f81dbc58de0a	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-02T19:14:54.755130652Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	1
c1a335f5-c0e2-4d5d-89df-eac0fd19b4a3	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:14:54.794539+00	2026-02-02 19:14:54.794539+00	Scanopy Daemon	9292fd99-407e-481b-a6a9-0d6d422a8c3c	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.4:60073/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-02T19:14:54.794522381Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
e6030f60-2274-408a-bf32-11ff29f3c2a0	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:15:26.467005+00	2026-02-02 19:15:26.467005+00	Unclaimed Open Ports	e27f914c-ba84-46dc-b7a8-15bb2317e4f6	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-02T19:15:26.466982810Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
2c70fb41-7c8f-4a5b-a052-822d9b80b31b	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:15:40.489059+00	2026-02-02 19:15:40.489059+00	Home Assistant	a1fdc84f-2a77-4040-92c1-3ec72f75f916	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-02T19:15:40.489034522Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	0
67b94308-ee02-4b1b-a8d1-78a0492f7e47	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:15:46.993404+00	2026-02-02 19:15:46.993404+00	Scanopy Server	a1fdc84f-2a77-4040-92c1-3ec72f75f916	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-02-02T19:15:46.993382383Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	1
ebd95384-3141-4ee7-8bf4-011c280ec68e	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:15:48.401131+00	2026-02-02 19:15:48.401131+00	SSH	a1fdc84f-2a77-4040-92c1-3ec72f75f916	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-02T19:15:48.401111065Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	2
f65afa3a-9995-40d4-bcd5-63ee107fce84	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:15:48.401502+00	2026-02-02 19:15:48.401502+00	Unclaimed Open Ports	a1fdc84f-2a77-4040-92c1-3ec72f75f916	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-02-02T19:15:48.401492756Z", "type": "Network", "daemon_id": "5a3fb205-4e82-4368-9d7a-7b48311f1e47", "subnet_ids": null, "snmp_credentials": {"ip_overrides": [], "default_credential": null}, "host_naming_fallback": "BestService"}]}	3
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
0fe58b78-fe81-4b72-ad06-04aae97ef366	2f910507-55a0-4c52-a42c-6002b6284e15	2026-02-02 19:08:11.31735+00	2026-02-02 19:08:11.31735+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-02-02T19:08:11.317345904Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f"}]}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
ea25a343-f6ff-4532-8168-08634e3ec712	e1913918-75b7-4be2-893a-581bfd6e7937	Integration Test Tag	\N	2026-02-02 19:16:45.281775+00	2026-02-02 19:16:45.281775+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings, if_entries, removed_if_entries) FROM stdin;
e9e98158-e998-4d57-a047-eba1e8b0351a	2f910507-55a0-4c52-a42c-6002b6284e15	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[]	[{"id": "0fe58b78-fe81-4b72-ad06-04aae97ef366", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-02-02T19:08:11.317345904Z", "type": "SelfReport", "host_id": "a9590643-88e0-45c1-8420-738ed98070ba", "daemon_id": "dc0c404c-e549-43a6-be79-05295ee7cb3f"}]}, "created_at": "2026-02-02T19:08:11.317350Z", "network_id": "2f910507-55a0-4c52-a42c-6002b6284e15", "updated_at": "2026-02-02T19:08:11.317350Z", "description": null, "subnet_type": "Lan"}]	[]	[]	t	2026-02-02 19:01:47.859358+00	f	\N	\N	{93a32e3e-1186-477f-927c-2e4b543f1afb,9dba3397-ebe3-465f-a865-168aacec6893,b3cff80d-9d08-4071-b3ad-ecb6831543e5}	{97ca2c23-2f35-4c3e-8556-61f29f8e5b2e}	{1ffaf5e8-57f7-4e60-ad69-2bb2cb1f94d0}	{868945f1-6706-4959-9d70-e7e3513c69da}	\N	2026-02-02 19:01:47.848028+00	2026-02-02 19:01:47.848028+00	{}	[]	{}	[]	{}	[]	{}	[]	{}
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
f469f7ea-b729-42a4-91c7-9d50aebc40ba	2026-02-02 19:01:47.83673+00	2026-02-02 19:01:47.83673+00	$argon2id$v=19$m=19456,t=2,p=1$+DEV1hdTvMCDqgZmVwVhUw$JnHbkbs8v68vKUTnnivEU2soxl2UexkQv9BnsLUgjH0	\N	\N	\N	user@gmail.com	e1913918-75b7-4be2-893a-581bfd6e7937	Owner	{}	\N	t	\N	\N	\N	\N
262f5b6d-adc3-4480-a6bb-70934a7fd082	2026-02-02 19:16:46.701277+00	2026-02-02 19:16:46.701277+00	\N	\N	\N	\N	user@example.com	e1913918-75b7-4be2-893a-581bfd6e7937	Owner	{}	\N	f	\N	\N	\N	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
F63_FHrUJ7upX6w7pOddWg	\\x93c4105a5de7a43bac5fa9bb27d47a14ffad1781a7757365725f6964d92466343639663765612d623732392d343261342d393163372d39643530616562633430626199cd07ea2813012fce38a7e89a000000	2026-02-09 19:01:47.950528+00
42YOuxx7VdNHG75SHDdvcQ	\\x93c410716f371c52be1b47d3557b1cbb0e66e382ad70656e64696e675f736574757082a86e6574776f726b739183a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92430646331393264372d653165382d346261382d386433642d653037623765346131333037ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92466343639663765612d623732392d343261342d393163372d39643530616562633430626199cd07ea28130805ce056f3add000000	2026-02-09 19:08:05.091175+00
XCKmDjrK0vHQQECw1BAycg	\\x93c410723210d4b04040d0f1d2ca3a0ea6225c82a7757365725f6964d92466343639663765612d623732392d343261342d393163372d396435306165626334306261ad70656e64696e675f736574757082a86e6574776f726b739183a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92438633065333661652d386434312d346637342d623464662d376565376239343237333264ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6e99cd07ea28130809ce16e11c71000000	2026-02-09 19:08:09.383851+00
c4noRelPfrX9LZcHPfBzIA	\\x93c4102073f03d07972dfdb57e4fe945e8897382ad70656e64696e675f736574757082a86e6574776f726b739183a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92437336131653037352d303262312d343661642d396433372d383161383232323661623631ac736e6d705f656e61626c6564c2a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92466343639663765612d623732392d343261342d393163372d39643530616562633430626199cd07ea2813102dce32e957ad000000	2026-02-09 19:16:45.854153+00
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

\unrestrict zGHAYp9lYjlSsZ9AWkff8xdG7pyEFVLijNrkKiOVDC0A1OMD62npx9XaTKC5fGl

