--
-- PostgreSQL database dump
--

\restrict Ae5FcNG0PNTJZDvsZjmqZGNGpKFaNbXyaM6dktz3w16hjbca9fXiOKe08KBcN6v

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
20251006215000	users	2026-01-08 04:56:34.738167+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3932834
20251006215100	networks	2026-01-08 04:56:34.742738+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3846403
20251006215151	create hosts	2026-01-08 04:56:34.746985+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3967671
20251006215155	create subnets	2026-01-08 04:56:34.751311+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3691343
20251006215201	create groups	2026-01-08 04:56:34.755369+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3977087
20251006215204	create daemons	2026-01-08 04:56:34.759689+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4139080
20251006215212	create services	2026-01-08 04:56:34.764227+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4859996
20251029193448	user-auth	2026-01-08 04:56:34.769402+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3612676
20251030044828	daemon api	2026-01-08 04:56:34.773325+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1530728
20251030170438	host-hide	2026-01-08 04:56:34.775132+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1102028
20251102224919	create discovery	2026-01-08 04:56:34.776515+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9564210
20251106235621	normalize-daemon-cols	2026-01-08 04:56:34.786408+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1748125
20251107034459	api keys	2026-01-08 04:56:34.788488+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7400240
20251107222650	oidc-auth	2026-01-08 04:56:34.796214+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20681081
20251110181948	orgs-billing	2026-01-08 04:56:34.817242+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10581691
20251113223656	group-enhancements	2026-01-08 04:56:34.828161+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	3143259
20251117032720	daemon-mode	2026-01-08 04:56:34.831732+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1260994
20251118143058	set-default-plan	2026-01-08 04:56:34.833289+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1175546
20251118225043	save-topology	2026-01-08 04:56:34.834774+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8739039
20251123232748	network-permissions	2026-01-08 04:56:34.84387+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2705102
20251125001342	billing-updates	2026-01-08 04:56:34.84691+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	912855
20251128035448	org-onboarding-status	2026-01-08 04:56:34.848103+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1492868
20251129180942	nfs-consolidate	2026-01-08 04:56:34.849945+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1209598
20251206052641	discovery-progress	2026-01-08 04:56:34.851445+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1585851
20251206202200	plan-fix	2026-01-08 04:56:34.853326+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	950665
20251207061341	daemon-url	2026-01-08 04:56:34.854573+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2093289
20251210045929	tags	2026-01-08 04:56:34.856979+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8678797
20251210175035	terms	2026-01-08 04:56:34.866013+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	907786
20251213025048	hash-keys	2026-01-08 04:56:34.867214+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	6660498
20251214050638	scanopy	2026-01-08 04:56:34.87421+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1392380
20251215215724	topo-scanopy-fix	2026-01-08 04:56:34.875917+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	936008
20251217153736	category rename	2026-01-08 04:56:34.877166+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1696008
20251218053111	invite-persistence	2026-01-08 04:56:34.879166+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5311439
20251219211216	create shares	2026-01-08 04:56:34.884827+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6667602
20251220170928	permissions-cleanup	2026-01-08 04:56:34.891829+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1511011
20251220180000	commercial-to-community	2026-01-08 04:56:34.893654+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	834178
20251221010000	cleanup subnet type	2026-01-08 04:56:34.894892+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	832765
20251221020000	remove host target	2026-01-08 04:56:34.896013+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	1128658
20251221030000	user network access	2026-01-08 04:56:34.897434+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	6129657
20251221040000	interfaces table	2026-01-08 04:56:34.903884+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9552839
20251221050000	ports table	2026-01-08 04:56:34.913758+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	8817336
20251221060000	bindings table	2026-01-08 04:56:34.922911+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	10724357
20251221070000	group bindings	2026-01-08 04:56:34.933981+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6911337
20251222020000	tag cascade delete	2026-01-08 04:56:34.942327+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1375139
20251223232524	network remove default	2026-01-08 04:56:34.943992+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1064579
20251225100000	color enum	2026-01-08 04:56:34.945363+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1434629
20251227010000	topology snapshot migration	2026-01-08 04:56:34.947142+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4347017
20251228010000	user api keys	2026-01-08 04:56:34.951823+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	10952724
20251230160000	daemon version and maintainer	2026-01-08 04:56:34.96312+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	2591499
20260103000000	service position	2026-01-08 04:56:34.966039+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	2037235
20260106000000	interface mac index	2026-01-08 04:56:34.968386+00	t	\\xa26248372a1e31af46a9c6fbdaef178982229e2ceeb90cc6a289d5764f87a38747294b3adf5f21276b5d171e42bdb6ac	1725052
20260106204402	entity tags junction	2026-01-08 04:56:34.970418+00	t	\\xf73c604f9f0b8db065d990a861684b0dbd62c3ef9bead120c68431c933774de56491a53f021e79f09801680152f5a08a	12389837
20260108033856	fix entity tags json format	2026-01-08 04:56:34.983125+00	t	\\x197eaa063d4f96dd0e897ad8fd96cc1ba9a54dda40a93a5c12eac14597e4dea4c806dd0a527736fb5807b7a8870d9916	1548101
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
a00ad5af-90cc-49db-b58d-58dfd0bf509d	6ad701e9799d5b0296a833ba2e890466fbb22d6f4fdfe9a349736dd46882fd6c	e28dc070-c88a-4166-8955-7b3f0327e3cc	Integrated Daemon API Key	2026-01-08 04:56:36.877461+00	2026-01-08 04:58:32.687171+00	2026-01-08 04:58:32.68601+00	\N	t
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
a7c3e469-3fa0-46ee-ae71-61545a124169	e28dc070-c88a-4166-8955-7b3f0327e3cc	c00b3ae7-8344-4fba-9a5e-b4d86692af00	Port	8e6c8f62-678b-46f4-af43-10fe4067275c	17f70d3d-bf7d-40b3-8722-438f1e0ec654	2026-01-08 04:56:37.421905+00	2026-01-08 04:56:37.421905+00
ac4546b9-fbe8-46a3-9e46-e4500c6a42f6	e28dc070-c88a-4166-8955-7b3f0327e3cc	a3044135-4cf8-4a79-9765-51d716037165	Port	5ef2b02e-7266-4e3d-ab83-43581deb950f	889de3c1-dd9f-4b86-8a56-fb8b14a5192a	2026-01-08 04:57:12.477108+00	2026-01-08 04:57:12.477108+00
69d2489b-896a-4152-815a-7ae2d8d056b1	e28dc070-c88a-4166-8955-7b3f0327e3cc	ed9adf38-35b0-4b06-8a8f-5d7d29a67cad	Port	57e026e2-389b-4f1a-b298-8bf7d0af1318	078edaac-f7ea-4bf8-8145-f3bcee1bce9c	2026-01-08 04:57:22.657702+00	2026-01-08 04:57:22.657702+00
a91316fa-bbe5-4927-be51-813c063065a3	e28dc070-c88a-4166-8955-7b3f0327e3cc	4c20f0f3-9609-486b-a9ac-e283fbed529f	Port	57e026e2-389b-4f1a-b298-8bf7d0af1318	dc7937a4-09a6-42ca-be52-6178c52816a5	2026-01-08 04:57:26.954293+00	2026-01-08 04:57:26.954293+00
a928fef9-07d5-4d57-aa0e-35e0750c0685	e28dc070-c88a-4166-8955-7b3f0327e3cc	d3a6a1d4-9422-439a-aa69-55d86e036408	Port	0354c93d-6d31-4157-b608-89a236a72a05	4ccb5391-fbba-455e-ad8d-2e94e6fe5b5f	2026-01-08 04:57:41.283775+00	2026-01-08 04:57:41.283775+00
37beda1e-c40e-426b-99e5-0dee91e0fd0a	e28dc070-c88a-4166-8955-7b3f0327e3cc	b8e62a8d-618b-4d6b-8e85-e7a2400b7323	Port	1933ea47-e3eb-4014-80a0-873644393c76	0442271e-7b22-4842-adb5-0f1d82c3cd78	2026-01-08 04:57:51.621918+00	2026-01-08 04:57:51.621918+00
50f60a1e-6329-4da6-80e2-3c2368aa2a44	e28dc070-c88a-4166-8955-7b3f0327e3cc	4e5c7ab2-ceea-47ad-98bc-89c9c862ad0c	Port	1933ea47-e3eb-4014-80a0-873644393c76	5e535a4b-eb09-42ff-a2e5-b51af70eccdd	2026-01-08 04:57:57.359052+00	2026-01-08 04:57:57.359052+00
187d2903-3960-45ae-8af5-567ae8185993	e28dc070-c88a-4166-8955-7b3f0327e3cc	38c774eb-c4fa-46fb-a562-a3ab16d7a0c0	Port	1933ea47-e3eb-4014-80a0-873644393c76	10e51766-e926-4883-b156-e5a20d5dbcd0	2026-01-08 04:58:01.667327+00	2026-01-08 04:58:01.667327+00
b48eddc9-6d47-4bf1-9a4f-cc0e9cb68eb8	e28dc070-c88a-4166-8955-7b3f0327e3cc	cbc6da48-ad10-416a-b047-13ae3dce3f52	Port	1933ea47-e3eb-4014-80a0-873644393c76	4e783e83-44d0-47ff-817a-6d66069e6541	2026-01-08 04:58:01.667649+00	2026-01-08 04:58:01.667649+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, version, user_id) FROM stdin;
1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8	e28dc070-c88a-4166-8955-7b3f0327e3cc	1aa79182-8874-472b-98c8-f0d1f5a48fac	2026-01-08 04:56:36.986127+00	2026-01-08 04:58:20.585089+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["431b89b9-32f4-4f9f-bb55-2bc948886f8e"]}	2026-01-08 04:58:20.586036+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	0.13.3	2ffe7cbb-fe20-4f92-b909-0f1d2c04362f
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
88f92d14-f1ab-4954-9cd2-0cfaf6d46e16	e28dc070-c88a-4166-8955-7b3f0327e3cc	1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac"}	Self Report	2026-01-08 04:56:36.999432+00	2026-01-08 04:56:36.999432+00
abe7a5da-372e-4d86-896f-b5025e9a71d7	e28dc070-c88a-4166-8955-7b3f0327e3cc	1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-08 04:56:37.009434+00	2026-01-08 04:56:37.009434+00
1fbc344e-89d2-475d-85fd-205ae6eae56a	e28dc070-c88a-4166-8955-7b3f0327e3cc	1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "session_id": "a491a223-3fe5-4832-b599-ee2734f82896", "started_at": "2026-01-08T04:56:37.008822304Z", "finished_at": "2026-01-08T04:56:37.632046881Z", "discovery_type": {"type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac"}}}	{"type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac"}	Self Report	2026-01-08 04:56:37.008822+00	2026-01-08 04:56:37.63746+00
4a44355d-cb49-4370-9ce9-b05b97afa06a	e28dc070-c88a-4166-8955-7b3f0327e3cc	1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "session_id": "9263f0ec-2239-43ee-bfc1-9b9d515dfb05", "started_at": "2026-01-08T04:56:37.653575032Z", "finished_at": "2026-01-08T04:58:32.684691281Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-08 04:56:37.653575+00	2026-01-08 04:58:32.687901+00
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
d8421248-89f6-40db-b7b5-bd67400db0e9	e28dc070-c88a-4166-8955-7b3f0327e3cc		\N	2026-01-08 04:58:32.700405+00	2026-01-08 04:58:32.700405+00	{"type": "Manual"}	Yellow	"SmoothStep"	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden) FROM stdin;
1aa79182-8874-472b-98c8-f0d1f5a48fac	e28dc070-c88a-4166-8955-7b3f0327e3cc	scanopy-daemon	c6cd86371019	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:56:37.421888736Z", "type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8"}]}	null	2026-01-08 04:56:36.979925+00	2026-01-08 04:56:37.434824+00	f
2a810c2d-f68d-4e95-b507-d3266b353646	e28dc070-c88a-4166-8955-7b3f0327e3cc	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:56:57.940832481Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-08 04:56:57.940833+00	2026-01-08 04:56:57.940833+00	f
a7eff38b-ef19-4028-9483-0f2ee50d3210	e28dc070-c88a-4166-8955-7b3f0327e3cc	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:57:12.577539875Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-08 04:57:12.57754+00	2026-01-08 04:57:12.57754+00	f
cfc3f0e3-a959-4acd-8457-2eb9a50fc368	e28dc070-c88a-4166-8955-7b3f0327e3cc	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:57:26.957658130Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-08 04:57:26.957659+00	2026-01-08 04:57:26.957659+00	f
d7c8568a-ecca-4da6-a687-16d929114fc4	e28dc070-c88a-4166-8955-7b3f0327e3cc	runnervmh13bl	runnervmh13bl	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:57:47.337108844Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-08 04:57:47.33711+00	2026-01-08 04:57:47.33711+00	f
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
8e6c8f62-678b-46f4-af43-10fe4067275c	e28dc070-c88a-4166-8955-7b3f0327e3cc	1aa79182-8874-472b-98c8-f0d1f5a48fac	431b89b9-32f4-4f9f-bb55-2bc948886f8e	172.25.0.4	a2:35:30:b8:e0:e2	eth0	0	2026-01-08 04:56:37.009097+00	2026-01-08 04:56:37.009097+00
5ef2b02e-7266-4e3d-ab83-43581deb950f	e28dc070-c88a-4166-8955-7b3f0327e3cc	2a810c2d-f68d-4e95-b507-d3266b353646	431b89b9-32f4-4f9f-bb55-2bc948886f8e	172.25.0.6	d6:ae:93:09:dc:00	\N	0	2026-01-08 04:56:57.940804+00	2026-01-08 04:56:57.940804+00
57e026e2-389b-4f1a-b298-8bf7d0af1318	e28dc070-c88a-4166-8955-7b3f0327e3cc	a7eff38b-ef19-4028-9483-0f2ee50d3210	431b89b9-32f4-4f9f-bb55-2bc948886f8e	172.25.0.5	92:9a:8d:89:59:b3	\N	0	2026-01-08 04:57:12.577511+00	2026-01-08 04:57:12.577511+00
0354c93d-6d31-4157-b608-89a236a72a05	e28dc070-c88a-4166-8955-7b3f0327e3cc	cfc3f0e3-a959-4acd-8457-2eb9a50fc368	431b89b9-32f4-4f9f-bb55-2bc948886f8e	172.25.0.3	76:71:76:74:77:a3	\N	0	2026-01-08 04:57:26.957636+00	2026-01-08 04:57:26.957636+00
1933ea47-e3eb-4014-80a0-873644393c76	e28dc070-c88a-4166-8955-7b3f0327e3cc	d7c8568a-ecca-4da6-a687-16d929114fc4	431b89b9-32f4-4f9f-bb55-2bc948886f8e	172.25.0.1	02:2a:17:3b:84:f8	\N	0	2026-01-08 04:57:47.337081+00	2026-01-08 04:57:47.337081+00
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
e28dc070-c88a-4166-8955-7b3f0327e3cc	My Network	2026-01-08 04:56:36.859557+00	2026-01-08 04:56:36.859557+00	a2f00160-ef69-4465-a49e-1b9f7fcf7ad9
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
a2f00160-ef69-4465-a49e-1b9f7fcf7ad9	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2026-01-08 04:56:36.852958+00	2026-01-08 04:58:33.525925+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
17f70d3d-bf7d-40b3-8722-438f1e0ec654	e28dc070-c88a-4166-8955-7b3f0327e3cc	1aa79182-8874-472b-98c8-f0d1f5a48fac	60073	Tcp	Custom	2026-01-08 04:56:37.42165+00	2026-01-08 04:56:37.42165+00
889de3c1-dd9f-4b86-8a56-fb8b14a5192a	e28dc070-c88a-4166-8955-7b3f0327e3cc	2a810c2d-f68d-4e95-b507-d3266b353646	5432	Tcp	PostgreSQL	2026-01-08 04:57:12.477098+00	2026-01-08 04:57:12.477098+00
078edaac-f7ea-4bf8-8145-f3bcee1bce9c	e28dc070-c88a-4166-8955-7b3f0327e3cc	a7eff38b-ef19-4028-9483-0f2ee50d3210	8123	Tcp	Custom	2026-01-08 04:57:22.657691+00	2026-01-08 04:57:22.657691+00
dc7937a4-09a6-42ca-be52-6178c52816a5	e28dc070-c88a-4166-8955-7b3f0327e3cc	a7eff38b-ef19-4028-9483-0f2ee50d3210	18555	Tcp	Custom	2026-01-08 04:57:26.954283+00	2026-01-08 04:57:26.954283+00
4ccb5391-fbba-455e-ad8d-2e94e6fe5b5f	e28dc070-c88a-4166-8955-7b3f0327e3cc	cfc3f0e3-a959-4acd-8457-2eb9a50fc368	60072	Tcp	Custom	2026-01-08 04:57:41.283765+00	2026-01-08 04:57:41.283765+00
0442271e-7b22-4842-adb5-0f1d82c3cd78	e28dc070-c88a-4166-8955-7b3f0327e3cc	d7c8568a-ecca-4da6-a687-16d929114fc4	60072	Tcp	Custom	2026-01-08 04:57:51.621907+00	2026-01-08 04:57:51.621907+00
5e535a4b-eb09-42ff-a2e5-b51af70eccdd	e28dc070-c88a-4166-8955-7b3f0327e3cc	d7c8568a-ecca-4da6-a687-16d929114fc4	8123	Tcp	Custom	2026-01-08 04:57:57.359042+00	2026-01-08 04:57:57.359042+00
10e51766-e926-4883-b156-e5a20d5dbcd0	e28dc070-c88a-4166-8955-7b3f0327e3cc	d7c8568a-ecca-4da6-a687-16d929114fc4	22	Tcp	Ssh	2026-01-08 04:58:01.667317+00	2026-01-08 04:58:01.667317+00
4e783e83-44d0-47ff-817a-6d66069e6541	e28dc070-c88a-4166-8955-7b3f0327e3cc	d7c8568a-ecca-4da6-a687-16d929114fc4	5435	Tcp	Custom	2026-01-08 04:58:01.667646+00	2026-01-08 04:58:01.667646+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, "position") FROM stdin;
c00b3ae7-8344-4fba-9a5e-b4d86692af00	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:56:37.421909+00	2026-01-08 04:56:37.421909+00	Scanopy Daemon	1aa79182-8874-472b-98c8-f0d1f5a48fac	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-08T04:56:37.421908032Z", "type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8"}]}	0
a3044135-4cf8-4a79-9765-51d716037165	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:57:12.477112+00	2026-01-08 04:57:12.477112+00	PostgreSQL	2a810c2d-f68d-4e95-b507-d3266b353646	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:57:12.477093236Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
ed9adf38-35b0-4b06-8a8f-5d7d29a67cad	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:57:22.657705+00	2026-01-08 04:57:22.657705+00	Home Assistant	a7eff38b-ef19-4028-9483-0f2ee50d3210	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:57:22.657685177Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
4c20f0f3-9609-486b-a9ac-e283fbed529f	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:57:26.954298+00	2026-01-08 04:57:26.954298+00	Unclaimed Open Ports	a7eff38b-ef19-4028-9483-0f2ee50d3210	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:57:26.954277047Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
d3a6a1d4-9422-439a-aa69-55d86e036408	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:57:41.283779+00	2026-01-08 04:57:41.283779+00	Unclaimed Open Ports	cfc3f0e3-a959-4acd-8457-2eb9a50fc368	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:57:41.283759105Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
b8e62a8d-618b-4d6b-8e85-e7a2400b7323	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:57:51.621922+00	2026-01-08 04:57:51.621922+00	Scanopy Server	d7c8568a-ecca-4da6-a687-16d929114fc4	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:57:51.621900861Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
4e5c7ab2-ceea-47ad-98bc-89c9c862ad0c	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:57:57.359055+00	2026-01-08 04:57:57.359055+00	Home Assistant	d7c8568a-ecca-4da6-a687-16d929114fc4	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:57:57.359037290Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
38c774eb-c4fa-46fb-a562-a3ab16d7a0c0	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:58:01.667331+00	2026-01-08 04:58:01.667331+00	SSH	d7c8568a-ecca-4da6-a687-16d929114fc4	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:58:01.667312748Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	2
cbc6da48-ad10-416a-b047-13ae3dce3f52	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:58:01.667651+00	2026-01-08 04:58:01.667651+00	Unclaimed Open Ports	d7c8568a-ecca-4da6-a687-16d929114fc4	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:58:01.667644427Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	3
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
7c620129-10d0-4c81-8977-777f541b065e	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:56:36.860969+00	2026-01-08 04:56:36.860969+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}
8b0297d0-dc2f-46e0-b38d-069af85fd3d6	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:56:36.860973+00	2026-01-08 04:56:36.860973+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}
431b89b9-32f4-4f9f-bb55-2bc948886f8e	e28dc070-c88a-4166-8955-7b3f0327e3cc	2026-01-08 04:56:37.009071+00	2026-01-08 04:56:37.009071+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:56:37.009070077Z", "type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8"}]}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
83218ce6-a9bf-42af-9925-5320175696b9	a2f00160-ef69-4465-a49e-1b9f7fcf7ad9	New Tag	\N	2026-01-08 04:58:32.707228+00	2026-01-08 04:58:32.707228+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
d03be7b5-2596-4871-b439-c70b6f51352d	e28dc070-c88a-4166-8955-7b3f0327e3cc	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "1aa79182-8874-472b-98c8-f0d1f5a48fac", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:56:37.421888736Z", "type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8"}]}, "hostname": "c6cd86371019", "created_at": "2026-01-08T04:56:36.979925Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:56:37.434824Z", "description": null, "virtualization": null}, {"id": "2a810c2d-f68d-4e95-b507-d3266b353646", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:56:57.940832481Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2026-01-08T04:56:57.940833Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:56:57.940833Z", "description": null, "virtualization": null}, {"id": "a7eff38b-ef19-4028-9483-0f2ee50d3210", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:57:12.577539875Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2026-01-08T04:57:12.577540Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:12.577540Z", "description": null, "virtualization": null}, {"id": "cfc3f0e3-a959-4acd-8457-2eb9a50fc368", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:57:26.957658130Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2026-01-08T04:57:26.957659Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:26.957659Z", "description": null, "virtualization": null}, {"id": "d7c8568a-ecca-4da6-a687-16d929114fc4", "name": "runnervmh13bl", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:57:47.337108844Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmh13bl", "created_at": "2026-01-08T04:57:47.337110Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:47.337110Z", "description": null, "virtualization": null}]	[{"id": "7c620129-10d0-4c81-8977-777f541b065e", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-08T04:56:36.860969Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:56:36.860969Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "8b0297d0-dc2f-46e0-b38d-069af85fd3d6", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-08T04:56:36.860973Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:56:36.860973Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "431b89b9-32f4-4f9f-bb55-2bc948886f8e", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:56:37.009070077Z", "type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8"}]}, "created_at": "2026-01-08T04:56:37.009071Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:56:37.009071Z", "description": null, "subnet_type": "Lan"}]	[{"id": "c00b3ae7-8344-4fba-9a5e-b4d86692af00", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-08T04:56:37.421908032Z", "type": "SelfReport", "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8"}]}, "host_id": "1aa79182-8874-472b-98c8-f0d1f5a48fac", "bindings": [{"id": "a7c3e469-3fa0-46ee-ae71-61545a124169", "type": "Port", "port_id": "17f70d3d-bf7d-40b3-8722-438f1e0ec654", "created_at": "2026-01-08T04:56:37.421905Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "c00b3ae7-8344-4fba-9a5e-b4d86692af00", "updated_at": "2026-01-08T04:56:37.421905Z", "interface_id": "8e6c8f62-678b-46f4-af43-10fe4067275c"}], "position": 0, "created_at": "2026-01-08T04:56:37.421909Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:56:37.421909Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "a3044135-4cf8-4a79-9765-51d716037165", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:57:12.477093236Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2a810c2d-f68d-4e95-b507-d3266b353646", "bindings": [{"id": "ac4546b9-fbe8-46a3-9e46-e4500c6a42f6", "type": "Port", "port_id": "889de3c1-dd9f-4b86-8a56-fb8b14a5192a", "created_at": "2026-01-08T04:57:12.477108Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "a3044135-4cf8-4a79-9765-51d716037165", "updated_at": "2026-01-08T04:57:12.477108Z", "interface_id": "5ef2b02e-7266-4e3d-ab83-43581deb950f"}], "position": 0, "created_at": "2026-01-08T04:57:12.477112Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:12.477112Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "ed9adf38-35b0-4b06-8a8f-5d7d29a67cad", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:57:22.657685177Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "a7eff38b-ef19-4028-9483-0f2ee50d3210", "bindings": [{"id": "69d2489b-896a-4152-815a-7ae2d8d056b1", "type": "Port", "port_id": "078edaac-f7ea-4bf8-8145-f3bcee1bce9c", "created_at": "2026-01-08T04:57:22.657702Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "ed9adf38-35b0-4b06-8a8f-5d7d29a67cad", "updated_at": "2026-01-08T04:57:22.657702Z", "interface_id": "57e026e2-389b-4f1a-b298-8bf7d0af1318"}], "position": 0, "created_at": "2026-01-08T04:57:22.657705Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:22.657705Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "4c20f0f3-9609-486b-a9ac-e283fbed529f", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:57:26.954277047Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "a7eff38b-ef19-4028-9483-0f2ee50d3210", "bindings": [{"id": "a91316fa-bbe5-4927-be51-813c063065a3", "type": "Port", "port_id": "dc7937a4-09a6-42ca-be52-6178c52816a5", "created_at": "2026-01-08T04:57:26.954293Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "4c20f0f3-9609-486b-a9ac-e283fbed529f", "updated_at": "2026-01-08T04:57:26.954293Z", "interface_id": "57e026e2-389b-4f1a-b298-8bf7d0af1318"}], "position": 1, "created_at": "2026-01-08T04:57:26.954298Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:26.954298Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "d3a6a1d4-9422-439a-aa69-55d86e036408", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:57:41.283759105Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "cfc3f0e3-a959-4acd-8457-2eb9a50fc368", "bindings": [{"id": "a928fef9-07d5-4d57-aa0e-35e0750c0685", "type": "Port", "port_id": "4ccb5391-fbba-455e-ad8d-2e94e6fe5b5f", "created_at": "2026-01-08T04:57:41.283775Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "d3a6a1d4-9422-439a-aa69-55d86e036408", "updated_at": "2026-01-08T04:57:41.283775Z", "interface_id": "0354c93d-6d31-4157-b608-89a236a72a05"}], "position": 0, "created_at": "2026-01-08T04:57:41.283779Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:41.283779Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "b8e62a8d-618b-4d6b-8e85-e7a2400b7323", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:57:51.621900861Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "d7c8568a-ecca-4da6-a687-16d929114fc4", "bindings": [{"id": "37beda1e-c40e-426b-99e5-0dee91e0fd0a", "type": "Port", "port_id": "0442271e-7b22-4842-adb5-0f1d82c3cd78", "created_at": "2026-01-08T04:57:51.621918Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "b8e62a8d-618b-4d6b-8e85-e7a2400b7323", "updated_at": "2026-01-08T04:57:51.621918Z", "interface_id": "1933ea47-e3eb-4014-80a0-873644393c76"}], "position": 0, "created_at": "2026-01-08T04:57:51.621922Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:51.621922Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "4e5c7ab2-ceea-47ad-98bc-89c9c862ad0c", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:57:57.359037290Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "d7c8568a-ecca-4da6-a687-16d929114fc4", "bindings": [{"id": "50f60a1e-6329-4da6-80e2-3c2368aa2a44", "type": "Port", "port_id": "5e535a4b-eb09-42ff-a2e5-b51af70eccdd", "created_at": "2026-01-08T04:57:57.359052Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "4e5c7ab2-ceea-47ad-98bc-89c9c862ad0c", "updated_at": "2026-01-08T04:57:57.359052Z", "interface_id": "1933ea47-e3eb-4014-80a0-873644393c76"}], "position": 1, "created_at": "2026-01-08T04:57:57.359055Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:57:57.359055Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "38c774eb-c4fa-46fb-a562-a3ab16d7a0c0", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:58:01.667312748Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "d7c8568a-ecca-4da6-a687-16d929114fc4", "bindings": [{"id": "187d2903-3960-45ae-8af5-567ae8185993", "type": "Port", "port_id": "10e51766-e926-4883-b156-e5a20d5dbcd0", "created_at": "2026-01-08T04:58:01.667327Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "38c774eb-c4fa-46fb-a562-a3ab16d7a0c0", "updated_at": "2026-01-08T04:58:01.667327Z", "interface_id": "1933ea47-e3eb-4014-80a0-873644393c76"}], "position": 2, "created_at": "2026-01-08T04:58:01.667331Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:58:01.667331Z", "virtualization": null, "service_definition": "SSH"}, {"id": "cbc6da48-ad10-416a-b047-13ae3dce3f52", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:58:01.667644427Z", "type": "Network", "daemon_id": "1f2f8432-b6ce-4a99-b0b2-54eb82dbe4d8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "d7c8568a-ecca-4da6-a687-16d929114fc4", "bindings": [{"id": "b48eddc9-6d47-4bf1-9a4f-cc0e9cb68eb8", "type": "Port", "port_id": "4e783e83-44d0-47ff-817a-6d66069e6541", "created_at": "2026-01-08T04:58:01.667649Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "service_id": "cbc6da48-ad10-416a-b047-13ae3dce3f52", "updated_at": "2026-01-08T04:58:01.667649Z", "interface_id": "1933ea47-e3eb-4014-80a0-873644393c76"}], "position": 3, "created_at": "2026-01-08T04:58:01.667651Z", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:58:01.667651Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "d8421248-89f6-40db-b7b5-bd67400db0e9", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2026-01-08T04:58:32.700405Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "e28dc070-c88a-4166-8955-7b3f0327e3cc", "updated_at": "2026-01-08T04:58:32.700405Z", "binding_ids": [], "description": null}]	t	2026-01-08 04:56:36.875829+00	f	\N	\N	{c2949e47-89d4-4aff-8287-0135ea3cf6e7,7fef6b78-5edd-4c38-8a01-54eaa9c2ddb0,98772602-0999-4026-b793-470fc037956d}	{d9ea9fd0-7a9e-47a8-902c-cda94ee61906}	{c7305b25-3631-4532-8ea7-7017dda965d3}	{ae347e92-b870-4083-b20f-33c4c6536751}	\N	2026-01-08 04:56:36.864723+00	2026-01-08 04:58:34.876373+00	{}	[]	{}	[]	{}	[]	{}
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

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, tags, terms_accepted_at) FROM stdin;
2ffe7cbb-fe20-4f92-b909-0f1d2c04362f	2026-01-08 04:56:36.856318+00	2026-01-08 04:56:36.856318+00	$argon2id$v=19$m=19456,t=2,p=1$UDZKxTYr3zwCyMyqLZwlsA$HEl8QZL1v7CS5jPwxwiAXEbRrA+Qi0xLovTFX8sZc+k	\N	\N	\N	user@gmail.com	a2f00160-ef69-4465-a49e-1b9f7fcf7ad9	Owner	{}	\N
d1255439-c17f-4b6c-ae41-aa5c46655915	2026-01-08 04:58:34.036574+00	2026-01-08 04:58:34.036574+00	\N	\N	\N	\N	user@example.com	a2f00160-ef69-4465-a49e-1b9f7fcf7ad9	Owner	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
ZInmdYOsAWsJJGeLtuT2vA	\\x93c410bcf6e4b68b6724096b01ac8375e6896481a7757365725f6964d92432666665376362622d666532302d346639322d623930392d30663164326330343336326699cd07ea0f043825ce033f8d86000000	2026-01-15 04:56:37.054496+00
-yUjZbEynbkP9_WLU79j0A	\\x93c410d063bf538bf5f70fb99d32b1652325fb82ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92438663333386565652d633661342d346632312d393863382d663135623831303864393731a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92432666665376362622d666532302d346639322d623930392d30663164326330343336326699cd07ea0f043a21ce11567283000000	2026-01-15 04:58:33.290878+00
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
-- Name: idx_users_oidc_provider_subject; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_oidc_provider_subject ON public.users USING btree (oidc_provider, oidc_subject) WHERE ((oidc_provider IS NOT NULL) AND (oidc_subject IS NOT NULL));


--
-- Name: idx_users_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_organization ON public.users USING btree (organization_id);


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

\unrestrict Ae5FcNG0PNTJZDvsZjmqZGNGpKFaNbXyaM6dktz3w16hjbca9fXiOKe08KBcN6v

