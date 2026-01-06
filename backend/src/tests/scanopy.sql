--
-- PostgreSQL database dump
--

\restrict aIDejkmQVwtAdl3leiAe4uDaFP1bRQbMQFRrvkmWvXmxrqrpJXirKPWxqQySOes

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
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_daemon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_service_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_port_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bindings DROP CONSTRAINT IF EXISTS bindings_interface_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_network_id_fkey;
DROP TRIGGER IF EXISTS trigger_remove_deleted_tag_from_entities ON public.tags;
DROP INDEX IF EXISTS public.idx_users_organization;
DROP INDEX IF EXISTS public.idx_users_oidc_provider_subject;
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
DROP INDEX IF EXISTS public.idx_interfaces_host;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_groups_network;
DROP INDEX IF EXISTS public.idx_group_bindings_group;
DROP INDEX IF EXISTS public.idx_group_bindings_binding;
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
DROP TABLE IF EXISTS public.discovery;
DROP TABLE IF EXISTS public.daemons;
DROP TABLE IF EXISTS public.bindings;
DROP TABLE IF EXISTS public.api_keys;
DROP TABLE IF EXISTS public._sqlx_migrations;
DROP FUNCTION IF EXISTS public.remove_deleted_tag_from_entities();
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
-- Name: remove_deleted_tag_from_entities(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.remove_deleted_tag_from_entities() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Remove the deleted tag ID from all entity tags arrays
    UPDATE users SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE discovery SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE hosts SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE networks SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE subnets SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE groups SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE daemons SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE services SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE api_keys SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);
    UPDATE topologies SET tags = array_remove(tags, OLD.id), updated_at = NOW() WHERE OLD.id = ANY(tags);

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.remove_deleted_tag_from_entities() OWNER TO postgres;

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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL,
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
    updated_at timestamp with time zone NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
);


ALTER TABLE public.discovery OWNER TO postgres;

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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL,
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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    organization_id uuid NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL,
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
    source jsonb NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    is_enabled boolean DEFAULT true NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    terms_accepted_at timestamp with time zone
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
20251006215000	users	2026-01-06 06:13:06.743132+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3989800
20251006215100	networks	2026-01-06 06:13:06.748164+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5171151
20251006215151	create hosts	2026-01-06 06:13:06.753731+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4055003
20251006215155	create subnets	2026-01-06 06:13:06.758196+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4098793
20251006215201	create groups	2026-01-06 06:13:06.762644+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4400232
20251006215204	create daemons	2026-01-06 06:13:06.767424+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4398025
20251006215212	create services	2026-01-06 06:13:06.77233+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4974232
20251029193448	user-auth	2026-01-06 06:13:06.777645+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6221887
20251030044828	daemon api	2026-01-06 06:13:06.784163+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1561876
20251030170438	host-hide	2026-01-06 06:13:06.786006+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1111399
20251102224919	create discovery	2026-01-06 06:13:06.78742+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11399310
20251106235621	normalize-daemon-cols	2026-01-06 06:13:06.79915+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1805945
20251107034459	api keys	2026-01-06 06:13:06.801245+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8813670
20251107222650	oidc-auth	2026-01-06 06:13:06.810425+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	27875188
20251110181948	orgs-billing	2026-01-06 06:13:06.83862+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11338977
20251113223656	group-enhancements	2026-01-06 06:13:06.850298+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1069951
20251117032720	daemon-mode	2026-01-06 06:13:06.851717+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1169349
20251118143058	set-default-plan	2026-01-06 06:13:06.853171+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1175019
20251118225043	save-topology	2026-01-06 06:13:06.85464+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9178937
20251123232748	network-permissions	2026-01-06 06:13:06.864147+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2803060
20251125001342	billing-updates	2026-01-06 06:13:06.867244+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	943604
20251128035448	org-onboarding-status	2026-01-06 06:13:06.86868+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1643800
20251129180942	nfs-consolidate	2026-01-06 06:13:06.870418+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1255901
20251206052641	discovery-progress	2026-01-06 06:13:06.871979+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1705807
20251206202200	plan-fix	2026-01-06 06:13:06.87399+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	964514
20251207061341	daemon-url	2026-01-06 06:13:06.875237+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2449766
20251210045929	tags	2026-01-06 06:13:06.878009+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8983426
20251210175035	terms	2026-01-06 06:13:06.887318+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	900263
20251213025048	hash-keys	2026-01-06 06:13:06.888566+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	10723490
20251214050638	scanopy	2026-01-06 06:13:06.899606+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1650784
20251215215724	topo-scanopy-fix	2026-01-06 06:13:06.901571+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	813426
20251217153736	category rename	2026-01-06 06:13:06.902723+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1910139
20251218053111	invite-persistence	2026-01-06 06:13:06.904934+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5419589
20251219211216	create shares	2026-01-06 06:13:06.910676+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6889635
20251220170928	permissions-cleanup	2026-01-06 06:13:06.917949+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1525668
20251220180000	commercial-to-community	2026-01-06 06:13:06.919773+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	830201
20251221010000	cleanup subnet type	2026-01-06 06:13:06.920897+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	1035246
20251221020000	remove host target	2026-01-06 06:13:06.922236+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	1085130
20251221030000	user network access	2026-01-06 06:13:06.923629+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7091151
20251221040000	interfaces table	2026-01-06 06:13:06.93102+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9990642
20251221050000	ports table	2026-01-06 06:13:06.941384+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	9114145
20251221060000	bindings table	2026-01-06 06:13:06.950847+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	11261572
20251221070000	group bindings	2026-01-06 06:13:06.962437+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6818889
20251222020000	tag cascade delete	2026-01-06 06:13:06.969649+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1318249
20251223232524	network remove default	2026-01-06 06:13:06.971269+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1266451
20251225100000	color enum	2026-01-06 06:13:06.972827+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1356811
20251227010000	topology snapshot migration	2026-01-06 06:13:06.974466+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4356901
20251228010000	user api keys	2026-01-06 06:13:06.979131+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	11946650
20251230160000	daemon version and maintainer	2026-01-06 06:13:06.991409+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	2857502
20260103000000	service position	2026-01-06 06:13:06.994585+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	2035196
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
6775dea9-0d7a-482d-b18b-d0e0fee4cf50	f2c4ea030221e224bdddc874cb84528bc17b5ce38d6ae8d3585ae3ac2d472354	0ce2a92f-72d6-4773-8549-b494008ee36b	Integrated Daemon API Key	2026-01-06 06:13:08.889746+00	2026-01-06 06:15:05.57444+00	2026-01-06 06:15:05.573591+00	\N	t	{}
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
d2959148-a48d-460f-9887-4757ee89b740	0ce2a92f-72d6-4773-8549-b494008ee36b	38a367bf-42a1-4c9a-bd68-a0e67e706fb1	Port	fef8a4d0-5d29-4f23-9ea9-154f1bf6aaac	75923b61-0acd-4fed-9323-4ff56f2539a9	2026-01-06 06:13:09.0203+00	2026-01-06 06:13:09.0203+00
0968de2c-620e-418e-ae29-aadc880a027d	0ce2a92f-72d6-4773-8549-b494008ee36b	76391bef-af56-4b32-98a5-e93d2fc44eea	Port	fc0b6e1e-05a7-4bf2-a446-a3a92b3c446b	517b9d35-339a-4993-8f27-0db0de1dd29a	2026-01-06 06:13:45.361579+00	2026-01-06 06:13:45.361579+00
d6b1ee4e-aee1-463e-92d5-b446f32d620f	0ce2a92f-72d6-4773-8549-b494008ee36b	1239c301-c58d-4c62-af26-88d149a24cc8	Port	cb012995-7977-41a5-be8f-a2e519896e0a	3c4e7f1b-eac0-44b9-84d3-ef880e4c4f38	2026-01-06 06:13:51.272283+00	2026-01-06 06:13:51.272283+00
6452ccf8-8b1e-4ed6-9495-bf841c20b8fb	0ce2a92f-72d6-4773-8549-b494008ee36b	cd2f32c6-c871-456b-b63e-6c95b2657306	Port	cb012995-7977-41a5-be8f-a2e519896e0a	10b54bb7-d8b2-4e69-86be-4ef8e08bdf84	2026-01-06 06:13:59.94906+00	2026-01-06 06:13:59.94906+00
f5e7be9d-16bd-4c34-9d3f-b2b317cf3717	0ce2a92f-72d6-4773-8549-b494008ee36b	067960e6-d39f-41da-8bf3-30425d454634	Port	811fee3f-75cc-40ce-aac5-8e3736db8adc	2ab69d4c-ce71-4d82-92e7-1a2858559a05	2026-01-06 06:14:14.279063+00	2026-01-06 06:14:14.279063+00
3fc7c346-ba2d-48b0-854b-ceca817ce84f	0ce2a92f-72d6-4773-8549-b494008ee36b	900b0cc1-b445-4b51-b2ba-1b0bffddded8	Port	32d38014-aeb6-473e-86b2-985bb781ec9e	8042a832-15c0-43cd-be8d-b887effc29c2	2026-01-06 06:14:26.071692+00	2026-01-06 06:14:26.071692+00
0f63ba5b-5a46-442a-a0e7-c0a927c8420d	0ce2a92f-72d6-4773-8549-b494008ee36b	2658d6d7-e71e-4186-9a5d-9318fbc86818	Port	32d38014-aeb6-473e-86b2-985bb781ec9e	cd02163c-ba59-456c-b4a9-468e7f56d34f	2026-01-06 06:14:32.523236+00	2026-01-06 06:14:32.523236+00
056001b5-7485-4420-bb20-2fa3ae25395e	0ce2a92f-72d6-4773-8549-b494008ee36b	0870d81c-c535-4696-89a6-1c806361758b	Port	32d38014-aeb6-473e-86b2-985bb781ec9e	d067bfbb-68c4-4907-bbd4-689faa718a88	2026-01-06 06:14:34.681142+00	2026-01-06 06:14:34.681142+00
fab0299f-a401-4410-a964-b72f985a9e14	0ce2a92f-72d6-4773-8549-b494008ee36b	413f0bb4-93cf-4d28-9a8f-f9522d033937	Port	32d38014-aeb6-473e-86b2-985bb781ec9e	5f865b30-52f8-4d77-8a1f-d195250d31fc	2026-01-06 06:14:34.681193+00	2026-01-06 06:14:34.681193+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags, version, user_id) FROM stdin;
c102e0e1-568c-44b4-826d-e5488d54e3ac	0ce2a92f-72d6-4773-8549-b494008ee36b	2b015a70-1c08-4f80-a971-21ea7ee54704	2026-01-06 06:13:08.981544+00	2026-01-06 06:14:52.759904+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["128a8b76-15c6-4f67-b908-fb34c6d9af68"]}	2026-01-06 06:14:52.760662+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}	0.13.1	d6b50eb7-2a43-4738-a42d-6028478e9f0a
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
f5c03b22-9be8-4188-8caf-9d6fc69f9ecf	0ce2a92f-72d6-4773-8549-b494008ee36b	c102e0e1-568c-44b4-826d-e5488d54e3ac	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704"}	Self Report	2026-01-06 06:13:08.989131+00	2026-01-06 06:13:08.989131+00	{}
0e60ea78-ca4f-4f14-893c-668ed904e934	0ce2a92f-72d6-4773-8549-b494008ee36b	c102e0e1-568c-44b4-826d-e5488d54e3ac	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-06 06:13:08.998413+00	2026-01-06 06:13:08.998413+00	{}
48e2dd33-24a7-443d-a6b9-ae682f4c2c0b	0ce2a92f-72d6-4773-8549-b494008ee36b	c102e0e1-568c-44b4-826d-e5488d54e3ac	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "session_id": "c6b45ce2-c159-4c13-ad48-41101e496cfa", "started_at": "2026-01-06T06:13:08.997904773Z", "finished_at": "2026-01-06T06:13:09.307937360Z", "discovery_type": {"type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704"}}}	{"type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704"}	Self Report	2026-01-06 06:13:08.997904+00	2026-01-06 06:13:09.311407+00	{}
a8c5f5a4-e8da-448e-bcc2-cb9ef5ff0949	0ce2a92f-72d6-4773-8549-b494008ee36b	c102e0e1-568c-44b4-826d-e5488d54e3ac	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "session_id": "849d9bb4-347a-43cf-bd5c-1964dd265416", "started_at": "2026-01-06T06:13:09.496457630Z", "finished_at": "2026-01-06T06:15:05.572709714Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-06 06:13:09.496457+00	2026-01-06 06:15:05.57497+00	{}
\.


--
-- Data for Name: group_bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_bindings (id, group_id, binding_id, "position", created_at) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, created_at, updated_at, source, color, edge_style, tags, group_type) FROM stdin;
f7a97fd7-99b7-40f7-82a9-304d36fd22b2	0ce2a92f-72d6-4773-8549-b494008ee36b		\N	2026-01-06 06:15:05.586391+00	2026-01-06 06:15:05.586391+00	{"type": "Manual"}	Yellow	"SmoothStep"	{}	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
2b015a70-1c08-4f80-a971-21ea7ee54704	0ce2a92f-72d6-4773-8549-b494008ee36b	scanopy-daemon	e571af51b6d7	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:09.020278859Z", "type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac"}]}	null	2026-01-06 06:13:08.940218+00	2026-01-06 06:13:09.031416+00	f	{}
7f8f209d-a3f6-4216-8d0f-34189bde4c06	0ce2a92f-72d6-4773-8549-b494008ee36b	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:30.759435904Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-06 06:13:30.759436+00	2026-01-06 06:13:30.759436+00	f	{}
1a2697eb-c6f9-4d2d-aa2f-917ea7001c09	0ce2a92f-72d6-4773-8549-b494008ee36b	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:45.463388677Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-06 06:13:45.463389+00	2026-01-06 06:13:45.463389+00	f	{}
c3dba9c6-53f0-45b7-ba60-d05c669dc6d2	0ce2a92f-72d6-4773-8549-b494008ee36b	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:59.951524473Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-06 06:13:59.951525+00	2026-01-06 06:13:59.951525+00	f	{}
df891cd7-3275-4b35-af50-55e4fd8d5b16	0ce2a92f-72d6-4773-8549-b494008ee36b	runnervmh13bl	runnervmh13bl	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-06T06:14:20.333669858Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-06 06:14:20.33367+00	2026-01-06 06:14:20.33367+00	f	{}
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
fef8a4d0-5d29-4f23-9ea9-154f1bf6aaac	0ce2a92f-72d6-4773-8549-b494008ee36b	2b015a70-1c08-4f80-a971-21ea7ee54704	128a8b76-15c6-4f67-b908-fb34c6d9af68	172.25.0.4	1a:53:06:e5:e3:35	eth0	0	2026-01-06 06:13:08.998109+00	2026-01-06 06:13:08.998109+00
fc0b6e1e-05a7-4bf2-a446-a3a92b3c446b	0ce2a92f-72d6-4773-8549-b494008ee36b	7f8f209d-a3f6-4216-8d0f-34189bde4c06	128a8b76-15c6-4f67-b908-fb34c6d9af68	172.25.0.6	62:05:32:ee:7e:e9	\N	0	2026-01-06 06:13:30.759411+00	2026-01-06 06:13:30.759411+00
cb012995-7977-41a5-be8f-a2e519896e0a	0ce2a92f-72d6-4773-8549-b494008ee36b	1a2697eb-c6f9-4d2d-aa2f-917ea7001c09	128a8b76-15c6-4f67-b908-fb34c6d9af68	172.25.0.5	fe:7c:10:e2:90:bf	\N	0	2026-01-06 06:13:45.46336+00	2026-01-06 06:13:45.46336+00
811fee3f-75cc-40ce-aac5-8e3736db8adc	0ce2a92f-72d6-4773-8549-b494008ee36b	c3dba9c6-53f0-45b7-ba60-d05c669dc6d2	128a8b76-15c6-4f67-b908-fb34c6d9af68	172.25.0.3	b6:b6:3c:36:14:1a	\N	0	2026-01-06 06:13:59.951506+00	2026-01-06 06:13:59.951506+00
32d38014-aeb6-473e-86b2-985bb781ec9e	0ce2a92f-72d6-4773-8549-b494008ee36b	df891cd7-3275-4b35-af50-55e4fd8d5b16	128a8b76-15c6-4f67-b908-fb34c6d9af68	172.25.0.1	fe:db:e8:2a:63:ba	\N	0	2026-01-06 06:14:20.333645+00	2026-01-06 06:14:20.333645+00
\.


--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invites (id, organization_id, permissions, network_ids, url, created_by, created_at, updated_at, expires_at, send_to) FROM stdin;
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, organization_id, tags) FROM stdin;
0ce2a92f-72d6-4773-8549-b494008ee36b	My Network	2026-01-06 06:13:08.874042+00	2026-01-06 06:13:08.874042+00	7da11bc7-2389-4856-8c4b-7a5d067bfb8f	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
7da11bc7-2389-4856-8c4b-7a5d067bfb8f	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2026-01-06 06:13:08.867731+00	2026-01-06 06:15:06.344736+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
75923b61-0acd-4fed-9323-4ff56f2539a9	0ce2a92f-72d6-4773-8549-b494008ee36b	2b015a70-1c08-4f80-a971-21ea7ee54704	60073	Tcp	Custom	2026-01-06 06:13:09.020121+00	2026-01-06 06:13:09.020121+00
517b9d35-339a-4993-8f27-0db0de1dd29a	0ce2a92f-72d6-4773-8549-b494008ee36b	7f8f209d-a3f6-4216-8d0f-34189bde4c06	5432	Tcp	PostgreSQL	2026-01-06 06:13:45.361569+00	2026-01-06 06:13:45.361569+00
3c4e7f1b-eac0-44b9-84d3-ef880e4c4f38	0ce2a92f-72d6-4773-8549-b494008ee36b	1a2697eb-c6f9-4d2d-aa2f-917ea7001c09	8123	Tcp	Custom	2026-01-06 06:13:51.272272+00	2026-01-06 06:13:51.272272+00
10b54bb7-d8b2-4e69-86be-4ef8e08bdf84	0ce2a92f-72d6-4773-8549-b494008ee36b	1a2697eb-c6f9-4d2d-aa2f-917ea7001c09	18555	Tcp	Custom	2026-01-06 06:13:59.94905+00	2026-01-06 06:13:59.94905+00
2ab69d4c-ce71-4d82-92e7-1a2858559a05	0ce2a92f-72d6-4773-8549-b494008ee36b	c3dba9c6-53f0-45b7-ba60-d05c669dc6d2	60072	Tcp	Custom	2026-01-06 06:14:14.279052+00	2026-01-06 06:14:14.279052+00
8042a832-15c0-43cd-be8d-b887effc29c2	0ce2a92f-72d6-4773-8549-b494008ee36b	df891cd7-3275-4b35-af50-55e4fd8d5b16	8123	Tcp	Custom	2026-01-06 06:14:26.071683+00	2026-01-06 06:14:26.071683+00
cd02163c-ba59-456c-b4a9-468e7f56d34f	0ce2a92f-72d6-4773-8549-b494008ee36b	df891cd7-3275-4b35-af50-55e4fd8d5b16	60072	Tcp	Custom	2026-01-06 06:14:32.523227+00	2026-01-06 06:14:32.523227+00
d067bfbb-68c4-4907-bbd4-689faa718a88	0ce2a92f-72d6-4773-8549-b494008ee36b	df891cd7-3275-4b35-af50-55e4fd8d5b16	22	Tcp	Ssh	2026-01-06 06:14:34.681133+00	2026-01-06 06:14:34.681133+00
5f865b30-52f8-4d77-8a1f-d195250d31fc	0ce2a92f-72d6-4773-8549-b494008ee36b	df891cd7-3275-4b35-af50-55e4fd8d5b16	5435	Tcp	Custom	2026-01-06 06:14:34.68119+00	2026-01-06 06:14:34.68119+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, tags, "position") FROM stdin;
38a367bf-42a1-4c9a-bd68-a0e67e706fb1	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:13:09.020304+00	2026-01-06 06:13:09.020304+00	Scanopy Daemon	2b015a70-1c08-4f80-a971-21ea7ee54704	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-06T06:13:09.020303545Z", "type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac"}]}	{}	0
76391bef-af56-4b32-98a5-e93d2fc44eea	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:13:45.361583+00	2026-01-06 06:13:45.361583+00	PostgreSQL	7f8f209d-a3f6-4216-8d0f-34189bde4c06	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:13:45.361563479Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}	0
1239c301-c58d-4c62-af26-88d149a24cc8	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:13:51.272286+00	2026-01-06 06:13:51.272286+00	Home Assistant	1a2697eb-c6f9-4d2d-aa2f-917ea7001c09	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-06T06:13:51.272266099Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}	0
cd2f32c6-c871-456b-b63e-6c95b2657306	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:13:59.949063+00	2026-01-06 06:13:59.949063+00	Unclaimed Open Ports	1a2697eb-c6f9-4d2d-aa2f-917ea7001c09	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:13:59.949044797Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}	1
067960e6-d39f-41da-8bf3-30425d454634	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:14:14.279067+00	2026-01-06 06:14:14.279067+00	Unclaimed Open Ports	c3dba9c6-53f0-45b7-ba60-d05c669dc6d2	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:14:14.279045358Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}	0
900b0cc1-b445-4b51-b2ba-1b0bffddded8	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:14:26.071695+00	2026-01-06 06:14:26.071695+00	Home Assistant	df891cd7-3275-4b35-af50-55e4fd8d5b16	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-06T06:14:26.071676819Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}	0
2658d6d7-e71e-4186-9a5d-9318fbc86818	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:14:32.523239+00	2026-01-06 06:14:32.523239+00	Scanopy Server	df891cd7-3275-4b35-af50-55e4fd8d5b16	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-06T06:14:32.523221059Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}	1
0870d81c-c535-4696-89a6-1c806361758b	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:14:34.681145+00	2026-01-06 06:14:34.681145+00	SSH	df891cd7-3275-4b35-af50-55e4fd8d5b16	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:14:34.681127624Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}	2
413f0bb4-93cf-4d28-9a8f-f9522d033937	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:14:34.681196+00	2026-01-06 06:14:34.681196+00	Unclaimed Open Ports	df891cd7-3275-4b35-af50-55e4fd8d5b16	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:14:34.681189750Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}	3
\.


--
-- Data for Name: shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shares (id, topology_id, network_id, created_by, name, is_enabled, expires_at, password_hash, allowed_domains, options, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
cf562788-f00e-41af-b277-5db9da6110ec	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:13:08.87551+00	2026-01-06 06:13:08.87551+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}	{}
90edb4a5-e151-4518-b6a8-6f77d6435bf0	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:13:08.875514+00	2026-01-06 06:13:08.875514+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}	{}
128a8b76-15c6-4f67-b908-fb34c6d9af68	0ce2a92f-72d6-4773-8549-b494008ee36b	2026-01-06 06:13:08.998077+00	2026-01-06 06:13:08.998077+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:08.998070975Z", "type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
3053452d-ac2c-4f47-a491-f5a33de46ca6	7da11bc7-2389-4856-8c4b-7a5d067bfb8f	New Tag	\N	2026-01-06 06:15:05.59268+00	2026-01-06 06:15:05.59268+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
b4e213ab-4431-40e2-bca3-53574aa3ad65	0ce2a92f-72d6-4773-8549-b494008ee36b	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "2b015a70-1c08-4f80-a971-21ea7ee54704", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:09.020278859Z", "type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac"}]}, "hostname": "e571af51b6d7", "created_at": "2026-01-06T06:13:08.940218Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:09.031416Z", "description": null, "virtualization": null}, {"id": "7f8f209d-a3f6-4216-8d0f-34189bde4c06", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:30.759435904Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2026-01-06T06:13:30.759436Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:30.759436Z", "description": null, "virtualization": null}, {"id": "1a2697eb-c6f9-4d2d-aa2f-917ea7001c09", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:45.463388677Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2026-01-06T06:13:45.463389Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:45.463389Z", "description": null, "virtualization": null}, {"id": "c3dba9c6-53f0-45b7-ba60-d05c669dc6d2", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:59.951524473Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2026-01-06T06:13:59.951525Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:59.951525Z", "description": null, "virtualization": null}, {"id": "df891cd7-3275-4b35-af50-55e4fd8d5b16", "name": "runnervmh13bl", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-06T06:14:20.333669858Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmh13bl", "created_at": "2026-01-06T06:14:20.333670Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:14:20.333670Z", "description": null, "virtualization": null}, {"id": "f91718b4-6b44-4b8b-9ffe-74078eb89dd8", "name": "Service Test Host", "tags": [], "hidden": false, "source": {"type": "Manual"}, "hostname": "service-test.local", "created_at": "2026-01-06T06:15:06.243192Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:15:06.243192Z", "description": null, "virtualization": null}]	[{"id": "cf562788-f00e-41af-b277-5db9da6110ec", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-06T06:13:08.875510Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:08.875510Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "90edb4a5-e151-4518-b6a8-6f77d6435bf0", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-06T06:13:08.875514Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:08.875514Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "128a8b76-15c6-4f67-b908-fb34c6d9af68", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-01-06T06:13:08.998070975Z", "type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac"}]}, "created_at": "2026-01-06T06:13:08.998077Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:08.998077Z", "description": null, "subnet_type": "Lan"}]	[{"id": "38a367bf-42a1-4c9a-bd68-a0e67e706fb1", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-06T06:13:09.020303545Z", "type": "SelfReport", "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac"}]}, "host_id": "2b015a70-1c08-4f80-a971-21ea7ee54704", "bindings": [{"id": "d2959148-a48d-460f-9887-4757ee89b740", "type": "Port", "port_id": "75923b61-0acd-4fed-9323-4ff56f2539a9", "created_at": "2026-01-06T06:13:09.020300Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "38a367bf-42a1-4c9a-bd68-a0e67e706fb1", "updated_at": "2026-01-06T06:13:09.020300Z", "interface_id": "fef8a4d0-5d29-4f23-9ea9-154f1bf6aaac"}], "position": 0, "created_at": "2026-01-06T06:13:09.020304Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:09.020304Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "76391bef-af56-4b32-98a5-e93d2fc44eea", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:13:45.361563479Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "7f8f209d-a3f6-4216-8d0f-34189bde4c06", "bindings": [{"id": "0968de2c-620e-418e-ae29-aadc880a027d", "type": "Port", "port_id": "517b9d35-339a-4993-8f27-0db0de1dd29a", "created_at": "2026-01-06T06:13:45.361579Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "76391bef-af56-4b32-98a5-e93d2fc44eea", "updated_at": "2026-01-06T06:13:45.361579Z", "interface_id": "fc0b6e1e-05a7-4bf2-a446-a3a92b3c446b"}], "position": 0, "created_at": "2026-01-06T06:13:45.361583Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:45.361583Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "1239c301-c58d-4c62-af26-88d149a24cc8", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-06T06:13:51.272266099Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1a2697eb-c6f9-4d2d-aa2f-917ea7001c09", "bindings": [{"id": "d6b1ee4e-aee1-463e-92d5-b446f32d620f", "type": "Port", "port_id": "3c4e7f1b-eac0-44b9-84d3-ef880e4c4f38", "created_at": "2026-01-06T06:13:51.272283Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "1239c301-c58d-4c62-af26-88d149a24cc8", "updated_at": "2026-01-06T06:13:51.272283Z", "interface_id": "cb012995-7977-41a5-be8f-a2e519896e0a"}], "position": 0, "created_at": "2026-01-06T06:13:51.272286Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:51.272286Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "cd2f32c6-c871-456b-b63e-6c95b2657306", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:13:59.949044797Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1a2697eb-c6f9-4d2d-aa2f-917ea7001c09", "bindings": [{"id": "6452ccf8-8b1e-4ed6-9495-bf841c20b8fb", "type": "Port", "port_id": "10b54bb7-d8b2-4e69-86be-4ef8e08bdf84", "created_at": "2026-01-06T06:13:59.949060Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "cd2f32c6-c871-456b-b63e-6c95b2657306", "updated_at": "2026-01-06T06:13:59.949060Z", "interface_id": "cb012995-7977-41a5-be8f-a2e519896e0a"}], "position": 1, "created_at": "2026-01-06T06:13:59.949063Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:13:59.949063Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "067960e6-d39f-41da-8bf3-30425d454634", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:14:14.279045358Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "c3dba9c6-53f0-45b7-ba60-d05c669dc6d2", "bindings": [{"id": "f5e7be9d-16bd-4c34-9d3f-b2b317cf3717", "type": "Port", "port_id": "2ab69d4c-ce71-4d82-92e7-1a2858559a05", "created_at": "2026-01-06T06:14:14.279063Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "067960e6-d39f-41da-8bf3-30425d454634", "updated_at": "2026-01-06T06:14:14.279063Z", "interface_id": "811fee3f-75cc-40ce-aac5-8e3736db8adc"}], "position": 0, "created_at": "2026-01-06T06:14:14.279067Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:14:14.279067Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "900b0cc1-b445-4b51-b2ba-1b0bffddded8", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-06T06:14:26.071676819Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "df891cd7-3275-4b35-af50-55e4fd8d5b16", "bindings": [{"id": "3fc7c346-ba2d-48b0-854b-ceca817ce84f", "type": "Port", "port_id": "8042a832-15c0-43cd-be8d-b887effc29c2", "created_at": "2026-01-06T06:14:26.071692Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "900b0cc1-b445-4b51-b2ba-1b0bffddded8", "updated_at": "2026-01-06T06:14:26.071692Z", "interface_id": "32d38014-aeb6-473e-86b2-985bb781ec9e"}], "position": 0, "created_at": "2026-01-06T06:14:26.071695Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:14:26.071695Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "2658d6d7-e71e-4186-9a5d-9318fbc86818", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-06T06:14:32.523221059Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "df891cd7-3275-4b35-af50-55e4fd8d5b16", "bindings": [{"id": "0f63ba5b-5a46-442a-a0e7-c0a927c8420d", "type": "Port", "port_id": "cd02163c-ba59-456c-b4a9-468e7f56d34f", "created_at": "2026-01-06T06:14:32.523236Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "2658d6d7-e71e-4186-9a5d-9318fbc86818", "updated_at": "2026-01-06T06:14:32.523236Z", "interface_id": "32d38014-aeb6-473e-86b2-985bb781ec9e"}], "position": 1, "created_at": "2026-01-06T06:14:32.523239Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:14:32.523239Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "0870d81c-c535-4696-89a6-1c806361758b", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:14:34.681127624Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "df891cd7-3275-4b35-af50-55e4fd8d5b16", "bindings": [{"id": "056001b5-7485-4420-bb20-2fa3ae25395e", "type": "Port", "port_id": "d067bfbb-68c4-4907-bbd4-689faa718a88", "created_at": "2026-01-06T06:14:34.681142Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "0870d81c-c535-4696-89a6-1c806361758b", "updated_at": "2026-01-06T06:14:34.681142Z", "interface_id": "32d38014-aeb6-473e-86b2-985bb781ec9e"}], "position": 2, "created_at": "2026-01-06T06:14:34.681145Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:14:34.681145Z", "virtualization": null, "service_definition": "SSH"}, {"id": "413f0bb4-93cf-4d28-9a8f-f9522d033937", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-06T06:14:34.681189750Z", "type": "Network", "daemon_id": "c102e0e1-568c-44b4-826d-e5488d54e3ac", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "df891cd7-3275-4b35-af50-55e4fd8d5b16", "bindings": [{"id": "fab0299f-a401-4410-a964-b72f985a9e14", "type": "Port", "port_id": "5f865b30-52f8-4d77-8a1f-d195250d31fc", "created_at": "2026-01-06T06:14:34.681193Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "service_id": "413f0bb4-93cf-4d28-9a8f-f9522d033937", "updated_at": "2026-01-06T06:14:34.681193Z", "interface_id": "32d38014-aeb6-473e-86b2-985bb781ec9e"}], "position": 3, "created_at": "2026-01-06T06:14:34.681196Z", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:14:34.681196Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "f7a97fd7-99b7-40f7-82a9-304d36fd22b2", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2026-01-06T06:15:05.586391Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "0ce2a92f-72d6-4773-8549-b494008ee36b", "updated_at": "2026-01-06T06:15:05.586391Z", "binding_ids": [], "description": null}]	t	2026-01-06 06:13:08.887935+00	f	\N	\N	{c6ecb023-2ae3-4408-9a72-4360b2675229,f91718b4-6b44-4b8b-9ffe-74078eb89dd8,5de3fdae-43f8-494c-9645-256bd49bbb9b}	{08f8043c-dc90-4894-b03c-80b7920eca05}	{f8da03ec-3e4a-4405-89dd-a98e7d082702}	{777ac08a-1365-44c5-8f85-3e8e47d041a0}	\N	2026-01-06 06:13:08.879622+00	2026-01-06 06:15:07.686765+00	{}	[]	{}	[]	{}	[]	{}
\.


--
-- Data for Name: user_api_key_network_access; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_api_key_network_access (id, api_key_id, network_id, created_at) FROM stdin;
\.


--
-- Data for Name: user_api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_api_keys (id, key, user_id, organization_id, permissions, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
\.


--
-- Data for Name: user_network_access; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_network_access (id, user_id, network_id, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, tags, terms_accepted_at) FROM stdin;
d6b50eb7-2a43-4738-a42d-6028478e9f0a	2026-01-06 06:13:08.870756+00	2026-01-06 06:13:08.870756+00	$argon2id$v=19$m=19456,t=2,p=1$plI2wQSzuoQRpFFMliSLxA$qPQtShCz/gE75CHcn+jD4nzSDyL1OHxy4dwTybAT2Lc	\N	\N	\N	user@gmail.com	7da11bc7-2389-4856-8c4b-7a5d067bfb8f	Owner	{}	\N
7d2f8d17-d86d-4534-8389-3d5f60fa9b3c	2026-01-06 06:15:06.827686+00	2026-01-06 06:15:06.827686+00	\N	\N	\N	\N	user@example.com	7da11bc7-2389-4856-8c4b-7a5d067bfb8f	Owner	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
BvdQETJaWMkGkBlkCGoGmw	\\x93c4109b066a0864199006c9585a321150f70681a7757365725f6964d92464366235306562372d326134332d343733382d613432642d36303238343738653966306199cd07ea0d060d09ce0076197c000000	2026-01-13 06:13:09.007739+00
Z1nXl-e9P-smUIbqvciiZw	\\x93c41067a2c8bdea865026eb3fbde797d7596782ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92466326362653435372d663739652d343161352d393633352d346537636665343737316631a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92464366235306562372d326134332d343733382d613432642d36303238343738653966306199cd07ea0d060f06ce0a460405000000	2026-01-13 06:15:06.17236+00
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
-- Name: idx_users_oidc_provider_subject; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_oidc_provider_subject ON public.users USING btree (oidc_provider, oidc_subject) WHERE ((oidc_provider IS NOT NULL) AND (oidc_subject IS NOT NULL));


--
-- Name: idx_users_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_organization ON public.users USING btree (organization_id);


--
-- Name: tags trigger_remove_deleted_tag_from_entities; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_remove_deleted_tag_from_entities BEFORE DELETE ON public.tags FOR EACH ROW EXECUTE FUNCTION public.remove_deleted_tag_from_entities();


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

\unrestrict aIDejkmQVwtAdl3leiAe4uDaFP1bRQbMQFRrvkmWvXmxrqrpJXirKPWxqQySOes

