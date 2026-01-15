--
-- PostgreSQL database dump
--

\restrict VH1EGxd776JZoAysERAW8bZwI0AsXfimQWuMv0D6qEyanUVPSLhYlRQeTpXclGP

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
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_topology_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_subnet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.group_bindings DROP CONSTRAINT IF EXISTS group_bindings_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.group_bindings DROP CONSTRAINT IF EXISTS group_bindings_binding_id_fkey;
ALTER TABLE IF EXISTS ONLY public.entity_tags DROP CONSTRAINT IF EXISTS entity_tags_tag_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_daemon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
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
DROP INDEX IF EXISTS public.idx_invites_organization;
DROP INDEX IF EXISTS public.idx_invites_expires_at;
DROP INDEX IF EXISTS public.idx_interfaces_subnet;
DROP INDEX IF EXISTS public.idx_interfaces_network;
DROP INDEX IF EXISTS public.idx_interfaces_host_mac;
DROP INDEX IF EXISTS public.idx_interfaces_host;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_groups_network;
DROP INDEX IF EXISTS public.idx_group_bindings_group;
DROP INDEX IF EXISTS public.idx_group_bindings_binding;
DROP INDEX IF EXISTS public.idx_entity_tags_tag_id;
DROP INDEX IF EXISTS public.idx_entity_tags_entity;
DROP INDEX IF EXISTS public.idx_discovery_network;
DROP INDEX IF EXISTS public.idx_discovery_daemon;
DROP INDEX IF EXISTS public.idx_daemons_network;
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
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_pkey;
ALTER TABLE IF EXISTS ONLY public.ports DROP CONSTRAINT IF EXISTS ports_host_id_port_number_protocol_key;
ALTER TABLE IF EXISTS ONLY public.organizations DROP CONSTRAINT IF EXISTS organizations_pkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_pkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_pkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_pkey;
ALTER TABLE IF EXISTS ONLY public.interfaces DROP CONSTRAINT IF EXISTS interfaces_host_id_subnet_id_ip_address_key;
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
DROP TABLE IF EXISTS public.shares;
DROP TABLE IF EXISTS public.services;
DROP TABLE IF EXISTS public.ports;
DROP TABLE IF EXISTS public.organizations;
DROP TABLE IF EXISTS public.networks;
DROP TABLE IF EXISTS public.invites;
DROP TABLE IF EXISTS public.interfaces;
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
    is_enabled boolean DEFAULT true NOT NULL
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
    last_seen timestamp with time zone NOT NULL,
    capabilities jsonb DEFAULT '{}'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    mode text DEFAULT '"Push"'::text,
    url text NOT NULL,
    name text,
    version text,
    user_id uuid NOT NULL
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
    hidden boolean DEFAULT false
);


ALTER TABLE public.hosts OWNER TO postgres;

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
    onboarding jsonb DEFAULT '[]'::jsonb
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
    removed_bindings uuid[] DEFAULT '{}'::uuid[]
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
20251006215000	users	2026-01-15 18:35:48.388499+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3497670
20251006215100	networks	2026-01-15 18:35:48.393478+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4754837
20251006215151	create hosts	2026-01-15 18:35:48.398588+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3906974
20251006215155	create subnets	2026-01-15 18:35:48.402811+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3790316
20251006215201	create groups	2026-01-15 18:35:48.407071+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4015136
20251006215204	create daemons	2026-01-15 18:35:48.411463+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4295950
20251006215212	create services	2026-01-15 18:35:48.416158+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4937437
20251029193448	user-auth	2026-01-15 18:35:48.421473+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6241842
20251030044828	daemon api	2026-01-15 18:35:48.42802+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1633861
20251030170438	host-hide	2026-01-15 18:35:48.430006+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1233553
20251102224919	create discovery	2026-01-15 18:35:48.431526+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11395844
20251106235621	normalize-daemon-cols	2026-01-15 18:35:48.443263+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1785333
20251107034459	api keys	2026-01-15 18:35:48.445398+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8400873
20251107222650	oidc-auth	2026-01-15 18:35:48.454188+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	29466519
20251110181948	orgs-billing	2026-01-15 18:35:48.483968+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11302781
20251113223656	group-enhancements	2026-01-15 18:35:48.495601+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1146720
20251117032720	daemon-mode	2026-01-15 18:35:48.497099+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1186875
20251118143058	set-default-plan	2026-01-15 18:35:48.498593+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1162300
20251118225043	save-topology	2026-01-15 18:35:48.500172+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9323526
20251123232748	network-permissions	2026-01-15 18:35:48.509937+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2738943
20251125001342	billing-updates	2026-01-15 18:35:48.512974+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	967857
20251128035448	org-onboarding-status	2026-01-15 18:35:48.514375+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1764313
20251129180942	nfs-consolidate	2026-01-15 18:35:48.516558+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1191685
20251206052641	discovery-progress	2026-01-15 18:35:48.518243+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1952996
20251206202200	plan-fix	2026-01-15 18:35:48.520455+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	937681
20251207061341	daemon-url	2026-01-15 18:35:48.521662+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2654916
20251210045929	tags	2026-01-15 18:35:48.524749+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8851207
20251210175035	terms	2026-01-15 18:35:48.533982+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	990137
20251213025048	hash-keys	2026-01-15 18:35:48.535288+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	11246565
20251214050638	scanopy	2026-01-15 18:35:48.546832+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1440431
20251215215724	topo-scanopy-fix	2026-01-15 18:35:48.548572+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	758957
20251217153736	category rename	2026-01-15 18:35:48.549672+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1738844
20251218053111	invite-persistence	2026-01-15 18:35:48.551732+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5470062
20251219211216	create shares	2026-01-15 18:35:48.557622+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	7004136
20251220170928	permissions-cleanup	2026-01-15 18:35:48.564954+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1484463
20251220180000	commercial-to-community	2026-01-15 18:35:48.566812+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	975902
20251221010000	cleanup subnet type	2026-01-15 18:35:48.56824+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	833005
20251221020000	remove host target	2026-01-15 18:35:48.569444+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	1175926
20251221030000	user network access	2026-01-15 18:35:48.571039+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7104774
20251221040000	interfaces table	2026-01-15 18:35:48.578552+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9610762
20251221050000	ports table	2026-01-15 18:35:48.58869+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	10494279
20251221060000	bindings table	2026-01-15 18:35:48.599663+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	12103393
20251221070000	group bindings	2026-01-15 18:35:48.612363+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	7498750
20251222020000	tag cascade delete	2026-01-15 18:35:48.620288+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1378220
20251223232524	network remove default	2026-01-15 18:35:48.622066+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1090388
20251225100000	color enum	2026-01-15 18:35:48.623451+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1499277
20251227010000	topology snapshot migration	2026-01-15 18:35:48.62533+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	5000994
20251228010000	user api keys	2026-01-15 18:35:48.630844+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	11818263
20251230160000	daemon version and maintainer	2026-01-15 18:35:48.642982+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	3072246
20260103000000	service position	2026-01-15 18:35:48.64653+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	2127141
20260106000000	interface mac index	2026-01-15 18:35:48.649026+00	t	\\xa26248372a1e31af46a9c6fbdaef178982229e2ceeb90cc6a289d5764f87a38747294b3adf5f21276b5d171e42bdb6ac	2026511
20260106204402	entity tags junction	2026-01-15 18:35:48.651416+00	t	\\xf73c604f9f0b8db065d990a861684b0dbd62c3ef9bead120c68431c933774de56491a53f021e79f09801680152f5a08a	12423886
20260108033856	fix entity tags json format	2026-01-15 18:35:48.664208+00	t	\\x197eaa063d4f96dd0e897ad8fd96cc1ba9a54dda40a93a5c12eac14597e4dea4c806dd0a527736fb5807b7a8870d9916	1382420
20260110000000	email verification	2026-01-15 18:35:48.665892+00	t	\\xb8da8433f58ba4ce846b9fa0c2551795747a8473ad10266b19685504847458ea69d27a0ce430151cfb426f5f5fb6ac3a	3343732
20260114145808	daemon user fk set null	2026-01-15 18:35:48.669581+00	t	\\x57b060be9fc314d7c5851c75661ca8269118feea6cf7ee9c61b147a0e117c4d39642cf0d1acdf7a723a9a76066c1b8ff	1017449
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
9df399c6-9811-43bb-a037-142e2973bb14	a51e4690272961e44dc892a5fbe494ab311529a6bef8394ca29c28115b80706f	492c6359-fe59-4c37-af1e-cc1a2366dbdf	Integrated Daemon API Key	2026-01-15 18:35:49.870778+00	2026-01-15 18:35:49.870778+00	2026-01-15 18:37:45.090552+00	\N	t
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
2c28eaa5-88bc-47b6-a5a7-c258bfb4b504	492c6359-fe59-4c37-af1e-cc1a2366dbdf	fd7ef14e-fb6d-4f22-bb89-e63d89795d34	Port	6936a293-52f5-4b49-a45b-379364314084	9fb637b5-c695-4ed1-ab28-13523f150ec4	2026-01-15 18:35:50.010517+00	2026-01-15 18:35:50.010517+00
9e263265-21bd-4db0-92aa-aa981b04b72a	492c6359-fe59-4c37-af1e-cc1a2366dbdf	1a6faf5a-5b88-4d7a-882a-c343ca55d87f	Port	535e6828-a03d-495f-98ec-8bc5ca0ce18e	5fa0e261-b450-454e-9afa-be79c01e1cae	2026-01-15 18:36:11.576007+00	2026-01-15 18:36:11.576007+00
14bee060-b33a-4bfb-a4d6-4ddbf99487f9	492c6359-fe59-4c37-af1e-cc1a2366dbdf	01ad2946-1766-46bd-8b58-49cc84f9b7fc	Port	b96c723c-7b2d-4da4-8e3a-bdbd6b2aa431	f977322a-32a8-44c7-bf92-5931921ecfe6	2026-01-15 18:36:40.102136+00	2026-01-15 18:36:40.102136+00
05a87507-1e80-4822-b45a-dd46c3ecd237	492c6359-fe59-4c37-af1e-cc1a2366dbdf	1a8d9f29-9ba9-4f89-a938-0465cb40c6cc	Port	febea17c-74f2-4bcb-a638-c37d482b47b6	f35cb9df-8b05-4bf3-a180-3c4fd302427d	2026-01-15 18:36:54.41647+00	2026-01-15 18:36:54.41647+00
f86bbc97-03ac-4f64-a228-f16761dc1a7e	492c6359-fe59-4c37-af1e-cc1a2366dbdf	1a8d9f29-9ba9-4f89-a938-0465cb40c6cc	Port	febea17c-74f2-4bcb-a638-c37d482b47b6	565473cf-f90c-4356-9cf0-2e9ef13706df	2026-01-15 18:36:54.416471+00	2026-01-15 18:36:54.416471+00
3dd2aa06-78ee-42a3-a4d8-4a202692f735	492c6359-fe59-4c37-af1e-cc1a2366dbdf	91c385b9-1f1a-4f46-8daf-a214c2d91274	Port	a34e78d6-7471-4992-a75c-8a7c3aadf84c	22695e12-efb3-4dc8-b9ee-5cabca6404c1	2026-01-15 18:37:01.26025+00	2026-01-15 18:37:01.26025+00
ea24f28f-d754-4e53-9d19-8071a423a1a4	492c6359-fe59-4c37-af1e-cc1a2366dbdf	1a017dcd-05eb-48a9-806f-37c790664c38	Port	a34e78d6-7471-4992-a75c-8a7c3aadf84c	5b6c6af0-1bf2-46db-901f-1b59d49049ab	2026-01-15 18:37:08.421286+00	2026-01-15 18:37:08.421286+00
c585ff85-f23a-4e4c-948a-054d3d70e22f	492c6359-fe59-4c37-af1e-cc1a2366dbdf	c444f8e4-9f09-41bb-bccb-ca2afdad60da	Port	a34e78d6-7471-4992-a75c-8a7c3aadf84c	08dcf854-6a0e-4967-be27-22f4fc942fe7	2026-01-15 18:37:14.847897+00	2026-01-15 18:37:14.847897+00
1465a6a9-5136-4985-ae5b-3ce9e80749e2	492c6359-fe59-4c37-af1e-cc1a2366dbdf	857b7d32-35ec-4640-bc29-63f1c776cf25	Port	a34e78d6-7471-4992-a75c-8a7c3aadf84c	fe5d8e5f-96ea-47f7-a173-80ef68630819	2026-01-15 18:37:14.848263+00	2026-01-15 18:37:14.848263+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, version, user_id) FROM stdin;
62fc77c9-1297-49dc-b93e-891ce8ef0a01	492c6359-fe59-4c37-af1e-cc1a2366dbdf	e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6	2026-01-15 18:35:49.969766+00	2026-01-15 18:37:36.144055+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["ee0d34b4-a3aa-4ffc-b64a-48549e29a0fc"]}	2026-01-15 18:35:49.969766+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	0.13.6	a4a668fe-33f0-43c6-879c-059f5156e2ff
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
ca47e2ca-799c-4e3e-be02-8ae8e02ce287	492c6359-fe59-4c37-af1e-cc1a2366dbdf	62fc77c9-1297-49dc-b93e-891ce8ef0a01	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6"}	Self Report	2026-01-15 18:35:49.980857+00	2026-01-15 18:35:49.980857+00
f961175b-3b83-4867-af48-e64aad39725d	492c6359-fe59-4c37-af1e-cc1a2366dbdf	62fc77c9-1297-49dc-b93e-891ce8ef0a01	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-15 18:35:49.989681+00	2026-01-15 18:35:49.989681+00
d4f79b9c-9e3b-48a0-b06b-6adcf9fbeb6d	492c6359-fe59-4c37-af1e-cc1a2366dbdf	62fc77c9-1297-49dc-b93e-891ce8ef0a01	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "session_id": "27639368-7aa7-48e5-b9dc-33452752d722", "started_at": "2026-01-15T18:35:49.989134525Z", "finished_at": "2026-01-15T18:35:50.044584005Z", "discovery_type": {"type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6"}}}	{"type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6"}	Self Report	2026-01-15 18:35:49.989134+00	2026-01-15 18:35:50.048052+00
39fb0a9e-036e-40e7-b0f4-865b6485d6de	492c6359-fe59-4c37-af1e-cc1a2366dbdf	62fc77c9-1297-49dc-b93e-891ce8ef0a01	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "session_id": "4490c609-a320-4e8e-b3bf-4cf6c5ed1a78", "started_at": "2026-01-15T18:35:50.060924959Z", "finished_at": "2026-01-15T18:37:45.089154035Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-15 18:35:50.060924+00	2026-01-15 18:37:45.092391+00
\.


--
-- Data for Name: entity_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entity_tags (id, entity_id, entity_type, tag_id, created_at) FROM stdin;
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
f403f54b-db16-4f05-8637-8c67c7c8c89b	492c6359-fe59-4c37-af1e-cc1a2366dbdf		\N	2026-01-15 18:37:45.10569+00	2026-01-15 18:37:45.10569+00	{"type": "Manual"}	Yellow	"SmoothStep"	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden) FROM stdin;
e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6	492c6359-fe59-4c37-af1e-cc1a2366dbdf	scanopy-daemon	6dd5eec882d2	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T18:35:50.010494024Z", "type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01"}]}	null	2026-01-15 18:35:49.920106+00	2026-01-15 18:35:49.920106+00	f
1237e234-fa2a-4769-ad73-2f846c12e803	492c6359-fe59-4c37-af1e-cc1a2366dbdf	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T18:36:10.799679316Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-15 18:36:10.79968+00	2026-01-15 18:36:10.79968+00	f
e5b6c491-841b-45cf-ac90-c1a97c3b62f0	492c6359-fe59-4c37-af1e-cc1a2366dbdf	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T18:36:25.688911586Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-15 18:36:25.688912+00	2026-01-15 18:36:25.688912+00	f
caf0a4b9-f8e9-4176-970a-ba4a17513584	492c6359-fe59-4c37-af1e-cc1a2366dbdf	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T18:36:40.104869415Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-15 18:36:40.10487+00	2026-01-15 18:36:40.10487+00	f
98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	492c6359-fe59-4c37-af1e-cc1a2366dbdf	runnervmmtnos	runnervmmtnos	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T18:37:00.480899109Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-15 18:37:00.4809+00	2026-01-15 18:37:00.4809+00	f
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
6936a293-52f5-4b49-a45b-379364314084	492c6359-fe59-4c37-af1e-cc1a2366dbdf	e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6	ee0d34b4-a3aa-4ffc-b64a-48549e29a0fc	172.25.0.4	a2:8f:b5:bb:82:ff	eth0	0	2026-01-15 18:35:49.989449+00	2026-01-15 18:35:49.989449+00
535e6828-a03d-495f-98ec-8bc5ca0ce18e	492c6359-fe59-4c37-af1e-cc1a2366dbdf	1237e234-fa2a-4769-ad73-2f846c12e803	ee0d34b4-a3aa-4ffc-b64a-48549e29a0fc	172.25.0.3	fa:e8:1a:9d:eb:6f	\N	0	2026-01-15 18:36:10.799656+00	2026-01-15 18:36:10.799656+00
b96c723c-7b2d-4da4-8e3a-bdbd6b2aa431	492c6359-fe59-4c37-af1e-cc1a2366dbdf	e5b6c491-841b-45cf-ac90-c1a97c3b62f0	ee0d34b4-a3aa-4ffc-b64a-48549e29a0fc	172.25.0.6	52:aa:92:04:76:92	\N	0	2026-01-15 18:36:25.68888+00	2026-01-15 18:36:25.68888+00
febea17c-74f2-4bcb-a638-c37d482b47b6	492c6359-fe59-4c37-af1e-cc1a2366dbdf	caf0a4b9-f8e9-4176-970a-ba4a17513584	ee0d34b4-a3aa-4ffc-b64a-48549e29a0fc	172.25.0.5	72:f6:29:da:78:e2	\N	0	2026-01-15 18:36:40.104848+00	2026-01-15 18:36:40.104848+00
a34e78d6-7471-4992-a75c-8a7c3aadf84c	492c6359-fe59-4c37-af1e-cc1a2366dbdf	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	ee0d34b4-a3aa-4ffc-b64a-48549e29a0fc	172.25.0.1	56:43:69:39:3f:8d	\N	0	2026-01-15 18:37:00.480869+00	2026-01-15 18:37:00.480869+00
\.


--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invites (id, organization_id, permissions, network_ids, url, created_by, created_at, updated_at, expires_at, send_to) FROM stdin;
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, organization_id) FROM stdin;
492c6359-fe59-4c37-af1e-cc1a2366dbdf	My Network	2026-01-15 18:35:49.851992+00	2026-01-15 18:35:49.851992+00	4c3672a1-e35d-4821-b11b-c3221bf4a8f5
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
4c3672a1-e35d-4821-b11b-c3221bf4a8f5	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2026-01-15 18:35:49.842949+00	2026-01-15 18:35:49.842949+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
9fb637b5-c695-4ed1-ab28-13523f150ec4	492c6359-fe59-4c37-af1e-cc1a2366dbdf	e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6	60073	Tcp	Custom	2026-01-15 18:35:50.010311+00	2026-01-15 18:35:50.010311+00
5fa0e261-b450-454e-9afa-be79c01e1cae	492c6359-fe59-4c37-af1e-cc1a2366dbdf	1237e234-fa2a-4769-ad73-2f846c12e803	60072	Tcp	Custom	2026-01-15 18:36:11.575997+00	2026-01-15 18:36:11.575997+00
f977322a-32a8-44c7-bf92-5931921ecfe6	492c6359-fe59-4c37-af1e-cc1a2366dbdf	e5b6c491-841b-45cf-ac90-c1a97c3b62f0	5432	Tcp	PostgreSQL	2026-01-15 18:36:40.102127+00	2026-01-15 18:36:40.102127+00
f35cb9df-8b05-4bf3-a180-3c4fd302427d	492c6359-fe59-4c37-af1e-cc1a2366dbdf	caf0a4b9-f8e9-4176-970a-ba4a17513584	8123	Tcp	Custom	2026-01-15 18:36:54.416457+00	2026-01-15 18:36:54.416457+00
565473cf-f90c-4356-9cf0-2e9ef13706df	492c6359-fe59-4c37-af1e-cc1a2366dbdf	caf0a4b9-f8e9-4176-970a-ba4a17513584	18555	Tcp	Custom	2026-01-15 18:36:54.416464+00	2026-01-15 18:36:54.416464+00
22695e12-efb3-4dc8-b9ee-5cabca6404c1	492c6359-fe59-4c37-af1e-cc1a2366dbdf	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	60072	Tcp	Custom	2026-01-15 18:37:01.260241+00	2026-01-15 18:37:01.260241+00
5b6c6af0-1bf2-46db-901f-1b59d49049ab	492c6359-fe59-4c37-af1e-cc1a2366dbdf	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	8123	Tcp	Custom	2026-01-15 18:37:08.421274+00	2026-01-15 18:37:08.421274+00
08dcf854-6a0e-4967-be27-22f4fc942fe7	492c6359-fe59-4c37-af1e-cc1a2366dbdf	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	22	Tcp	Ssh	2026-01-15 18:37:14.847888+00	2026-01-15 18:37:14.847888+00
fe5d8e5f-96ea-47f7-a173-80ef68630819	492c6359-fe59-4c37-af1e-cc1a2366dbdf	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	5435	Tcp	Custom	2026-01-15 18:37:14.848259+00	2026-01-15 18:37:14.848259+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, "position") FROM stdin;
fd7ef14e-fb6d-4f22-bb89-e63d89795d34	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:35:50.010522+00	2026-01-15 18:35:50.010522+00	Scanopy Daemon	e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-15T18:35:50.010521315Z", "type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01"}]}	0
1a6faf5a-5b88-4d7a-882a-c343ca55d87f	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:36:11.576011+00	2026-01-15 18:36:11.576011+00	Scanopy Server	1237e234-fa2a-4769-ad73-2f846c12e803	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T18:36:11.575990777Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
01ad2946-1766-46bd-8b58-49cc84f9b7fc	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:36:40.10214+00	2026-01-15 18:36:40.10214+00	PostgreSQL	e5b6c491-841b-45cf-ac90-c1a97c3b62f0	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T18:36:40.102122618Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
1a8d9f29-9ba9-4f89-a938-0465cb40c6cc	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:36:54.416475+00	2026-01-15 18:36:54.416475+00	Unclaimed Open Ports	caf0a4b9-f8e9-4176-970a-ba4a17513584	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T18:36:54.416451879Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
91c385b9-1f1a-4f46-8daf-a214c2d91274	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:37:01.260254+00	2026-01-15 18:37:01.260254+00	Scanopy Server	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T18:37:01.260235697Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
1a017dcd-05eb-48a9-806f-37c790664c38	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:37:08.421291+00	2026-01-15 18:37:08.421291+00	Home Assistant	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T18:37:08.421267697Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
c444f8e4-9f09-41bb-bccb-ca2afdad60da	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:37:14.847901+00	2026-01-15 18:37:14.847901+00	SSH	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T18:37:14.847883409Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	2
857b7d32-35ec-4640-bc29-63f1c776cf25	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:37:14.848265+00	2026-01-15 18:37:14.848265+00	Unclaimed Open Ports	98de04ee-eba5-4d93-a6c0-3c80f68f5cb1	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T18:37:14.848258038Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	3
\.


--
-- Data for Name: shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shares (id, topology_id, network_id, created_by, name, is_enabled, expires_at, password_hash, allowed_domains, options, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
86de622a-4f36-44d3-a3be-39ddc1cebd72	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:35:49.853407+00	2026-01-15 18:35:49.853407+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}
26a8e42b-7778-40e5-aa70-11598aa84a6c	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:35:49.853412+00	2026-01-15 18:35:49.853412+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}
ee0d34b4-a3aa-4ffc-b64a-48549e29a0fc	492c6359-fe59-4c37-af1e-cc1a2366dbdf	2026-01-15 18:35:49.989421+00	2026-01-15 18:35:49.989421+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-01-15T18:35:49.989419888Z", "type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01"}]}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
eb6c3de9-d370-4cdf-8aaa-ce6e35fe4cf6	4c3672a1-e35d-4821-b11b-c3221bf4a8f5	New Tag	\N	2026-01-15 18:37:45.112629+00	2026-01-15 18:37:45.112629+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
cf9d816a-2b66-4692-b361-b3e821794a5e	492c6359-fe59-4c37-af1e-cc1a2366dbdf	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T18:35:50.010494024Z", "type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01"}]}, "hostname": "6dd5eec882d2", "created_at": "2026-01-15T18:35:49.920106Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:35:49.920106Z", "description": null, "virtualization": null}, {"id": "1237e234-fa2a-4769-ad73-2f846c12e803", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T18:36:10.799679316Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2026-01-15T18:36:10.799680Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:36:10.799680Z", "description": null, "virtualization": null}, {"id": "e5b6c491-841b-45cf-ac90-c1a97c3b62f0", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T18:36:25.688911586Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2026-01-15T18:36:25.688912Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:36:25.688912Z", "description": null, "virtualization": null}, {"id": "caf0a4b9-f8e9-4176-970a-ba4a17513584", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T18:36:40.104869415Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2026-01-15T18:36:40.104870Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:36:40.104870Z", "description": null, "virtualization": null}, {"id": "98de04ee-eba5-4d93-a6c0-3c80f68f5cb1", "name": "runnervmmtnos", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T18:37:00.480899109Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmmtnos", "created_at": "2026-01-15T18:37:00.480900Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:37:00.480900Z", "description": null, "virtualization": null}]	[{"id": "86de622a-4f36-44d3-a3be-39ddc1cebd72", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-15T18:35:49.853407Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:35:49.853407Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "26a8e42b-7778-40e5-aa70-11598aa84a6c", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-15T18:35:49.853412Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:35:49.853412Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "ee0d34b4-a3aa-4ffc-b64a-48549e29a0fc", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T18:35:49.989419888Z", "type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01"}]}, "created_at": "2026-01-15T18:35:49.989421Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:35:49.989421Z", "description": null, "subnet_type": "Lan"}]	[{"id": "fd7ef14e-fb6d-4f22-bb89-e63d89795d34", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-15T18:35:50.010521315Z", "type": "SelfReport", "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01"}]}, "host_id": "e7182fb6-4c25-4e64-bd26-a57f3cfe4eb6", "bindings": [{"id": "2c28eaa5-88bc-47b6-a5a7-c258bfb4b504", "type": "Port", "port_id": "9fb637b5-c695-4ed1-ab28-13523f150ec4", "created_at": "2026-01-15T18:35:50.010517Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "fd7ef14e-fb6d-4f22-bb89-e63d89795d34", "updated_at": "2026-01-15T18:35:50.010517Z", "interface_id": "6936a293-52f5-4b49-a45b-379364314084"}], "position": 0, "created_at": "2026-01-15T18:35:50.010522Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:35:50.010522Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "1a6faf5a-5b88-4d7a-882a-c343ca55d87f", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T18:36:11.575990777Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1237e234-fa2a-4769-ad73-2f846c12e803", "bindings": [{"id": "9e263265-21bd-4db0-92aa-aa981b04b72a", "type": "Port", "port_id": "5fa0e261-b450-454e-9afa-be79c01e1cae", "created_at": "2026-01-15T18:36:11.576007Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "1a6faf5a-5b88-4d7a-882a-c343ca55d87f", "updated_at": "2026-01-15T18:36:11.576007Z", "interface_id": "535e6828-a03d-495f-98ec-8bc5ca0ce18e"}], "position": 0, "created_at": "2026-01-15T18:36:11.576011Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:36:11.576011Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "01ad2946-1766-46bd-8b58-49cc84f9b7fc", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T18:36:40.102122618Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e5b6c491-841b-45cf-ac90-c1a97c3b62f0", "bindings": [{"id": "14bee060-b33a-4bfb-a4d6-4ddbf99487f9", "type": "Port", "port_id": "f977322a-32a8-44c7-bf92-5931921ecfe6", "created_at": "2026-01-15T18:36:40.102136Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "01ad2946-1766-46bd-8b58-49cc84f9b7fc", "updated_at": "2026-01-15T18:36:40.102136Z", "interface_id": "b96c723c-7b2d-4da4-8e3a-bdbd6b2aa431"}], "position": 0, "created_at": "2026-01-15T18:36:40.102140Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:36:40.102140Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "1a8d9f29-9ba9-4f89-a938-0465cb40c6cc", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T18:36:54.416451879Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "caf0a4b9-f8e9-4176-970a-ba4a17513584", "bindings": [{"id": "05a87507-1e80-4822-b45a-dd46c3ecd237", "type": "Port", "port_id": "f35cb9df-8b05-4bf3-a180-3c4fd302427d", "created_at": "2026-01-15T18:36:54.416470Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "1a8d9f29-9ba9-4f89-a938-0465cb40c6cc", "updated_at": "2026-01-15T18:36:54.416470Z", "interface_id": "febea17c-74f2-4bcb-a638-c37d482b47b6"}, {"id": "f86bbc97-03ac-4f64-a228-f16761dc1a7e", "type": "Port", "port_id": "565473cf-f90c-4356-9cf0-2e9ef13706df", "created_at": "2026-01-15T18:36:54.416471Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "1a8d9f29-9ba9-4f89-a938-0465cb40c6cc", "updated_at": "2026-01-15T18:36:54.416471Z", "interface_id": "febea17c-74f2-4bcb-a638-c37d482b47b6"}], "position": 0, "created_at": "2026-01-15T18:36:54.416475Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:36:54.416475Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "91c385b9-1f1a-4f46-8daf-a214c2d91274", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T18:37:01.260235697Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "98de04ee-eba5-4d93-a6c0-3c80f68f5cb1", "bindings": [{"id": "3dd2aa06-78ee-42a3-a4d8-4a202692f735", "type": "Port", "port_id": "22695e12-efb3-4dc8-b9ee-5cabca6404c1", "created_at": "2026-01-15T18:37:01.260250Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "91c385b9-1f1a-4f46-8daf-a214c2d91274", "updated_at": "2026-01-15T18:37:01.260250Z", "interface_id": "a34e78d6-7471-4992-a75c-8a7c3aadf84c"}], "position": 0, "created_at": "2026-01-15T18:37:01.260254Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:37:01.260254Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "1a017dcd-05eb-48a9-806f-37c790664c38", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T18:37:08.421267697Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "98de04ee-eba5-4d93-a6c0-3c80f68f5cb1", "bindings": [{"id": "ea24f28f-d754-4e53-9d19-8071a423a1a4", "type": "Port", "port_id": "5b6c6af0-1bf2-46db-901f-1b59d49049ab", "created_at": "2026-01-15T18:37:08.421286Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "1a017dcd-05eb-48a9-806f-37c790664c38", "updated_at": "2026-01-15T18:37:08.421286Z", "interface_id": "a34e78d6-7471-4992-a75c-8a7c3aadf84c"}], "position": 1, "created_at": "2026-01-15T18:37:08.421291Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:37:08.421291Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "c444f8e4-9f09-41bb-bccb-ca2afdad60da", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T18:37:14.847883409Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "98de04ee-eba5-4d93-a6c0-3c80f68f5cb1", "bindings": [{"id": "c585ff85-f23a-4e4c-948a-054d3d70e22f", "type": "Port", "port_id": "08dcf854-6a0e-4967-be27-22f4fc942fe7", "created_at": "2026-01-15T18:37:14.847897Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "c444f8e4-9f09-41bb-bccb-ca2afdad60da", "updated_at": "2026-01-15T18:37:14.847897Z", "interface_id": "a34e78d6-7471-4992-a75c-8a7c3aadf84c"}], "position": 2, "created_at": "2026-01-15T18:37:14.847901Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:37:14.847901Z", "virtualization": null, "service_definition": "SSH"}, {"id": "857b7d32-35ec-4640-bc29-63f1c776cf25", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T18:37:14.848258038Z", "type": "Network", "daemon_id": "62fc77c9-1297-49dc-b93e-891ce8ef0a01", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "98de04ee-eba5-4d93-a6c0-3c80f68f5cb1", "bindings": [{"id": "1465a6a9-5136-4985-ae5b-3ce9e80749e2", "type": "Port", "port_id": "fe5d8e5f-96ea-47f7-a173-80ef68630819", "created_at": "2026-01-15T18:37:14.848263Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "service_id": "857b7d32-35ec-4640-bc29-63f1c776cf25", "updated_at": "2026-01-15T18:37:14.848263Z", "interface_id": "a34e78d6-7471-4992-a75c-8a7c3aadf84c"}], "position": 3, "created_at": "2026-01-15T18:37:14.848265Z", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:37:14.848265Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "f403f54b-db16-4f05-8637-8c67c7c8c89b", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2026-01-15T18:37:45.105690Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "492c6359-fe59-4c37-af1e-cc1a2366dbdf", "updated_at": "2026-01-15T18:37:45.105690Z", "binding_ids": [], "description": null}]	t	2026-01-15 18:35:49.869049+00	f	\N	\N	{5d4da0fe-cf2f-43d6-b5d8-cb4fcf5e43e4,e2b0d38d-7917-442c-bd3e-e24db1c72bc5,f0956a42-4f22-4708-a31f-055d2e305563}	{2994f086-aed5-4e60-abec-3f1748261038}	{63d65796-1b0a-452d-a264-f6535474cf87}	{455c5620-d485-453e-a96c-833984fc7b7c}	\N	2026-01-15 18:35:49.857843+00	2026-01-15 18:35:49.857843+00	{}	[]	{}	[]	{}	[]	{}
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
a4a668fe-33f0-43c6-879c-059f5156e2ff	2026-01-15 18:35:49.846216+00	2026-01-15 18:35:49.846216+00	$argon2id$v=19$m=19456,t=2,p=1$xVg+XHdDToYSD1gOdaxWLg$qAEWKLo7CBSHNXGg2U1tMTaCNvJ6FCyP6ijkLhabuQE	\N	\N	\N	user@gmail.com	4c3672a1-e35d-4821-b11b-c3221bf4a8f5	Owner	{}	\N	t	\N	\N	\N	\N
e7d4b24f-140d-401e-bca2-e546ae4ab6a8	2026-01-15 18:37:46.444377+00	2026-01-15 18:37:46.444377+00	\N	\N	\N	\N	user@example.com	4c3672a1-e35d-4821-b11b-c3221bf4a8f5	Owner	{}	\N	f	\N	\N	\N	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
u_rAd7Ve64YzRYaPrbBGnw	\\x93c4109f46b0ad8f86453386eb5eb577c0fabb81a7757365725f6964d92461346136363866652d333366302d343363362d383739632d30353966353135366532666699cd07ea16122331ce3b656f1a000000	2026-01-22 18:35:49.996503+00
MUb031_qdZ54JVF-KpY3Nw	\\x93c4103737962a7e5125789e75ea5fdff4463182ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92433663830396366392d613165312d346135392d396664392d343436303835613932333730a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92461346136363866652d333366302d343363362d383739632d30353966353135366532666699cd07ea1612252dce29652fc6000000	2026-01-22 18:37:45.694497+00
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
-- Name: idx_hosts_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hosts_network ON public.hosts USING btree (network_id);


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

\unrestrict VH1EGxd776JZoAysERAW8bZwI0AsXfimQWuMv0D6qEyanUVPSLhYlRQeTpXclGP

