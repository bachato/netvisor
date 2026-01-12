--
-- PostgreSQL database dump
--

\restrict PHfcXDurhfzZXLB1djPT1QebcejEixfIVRW9KbMm6TLVwqQKQDTPyD1Wg3mwWws

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
20251006215000	users	2026-01-11 19:16:01.428304+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3764533
20251006215100	networks	2026-01-11 19:16:01.436929+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5267807
20251006215151	create hosts	2026-01-11 19:16:01.44255+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4420998
20251006215155	create subnets	2026-01-11 19:16:01.447298+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4108715
20251006215201	create groups	2026-01-11 19:16:01.451765+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4397243
20251006215204	create daemons	2026-01-11 19:16:01.456506+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4744331
20251006215212	create services	2026-01-11 19:16:01.461655+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5322108
20251029193448	user-auth	2026-01-11 19:16:01.467277+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6191792
20251030044828	daemon api	2026-01-11 19:16:01.473831+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1690664
20251030170438	host-hide	2026-01-11 19:16:01.475823+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1235224
20251102224919	create discovery	2026-01-11 19:16:01.477331+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	12262016
20251106235621	normalize-daemon-cols	2026-01-11 19:16:01.489935+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1939689
20251107034459	api keys	2026-01-11 19:16:01.492174+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8511700
20251107222650	oidc-auth	2026-01-11 19:16:01.501016+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	28343027
20251110181948	orgs-billing	2026-01-11 19:16:01.529709+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11792811
20251113223656	group-enhancements	2026-01-11 19:16:01.545207+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1192645
20251117032720	daemon-mode	2026-01-11 19:16:01.546751+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1195671
20251118143058	set-default-plan	2026-01-11 19:16:01.548253+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1266223
20251118225043	save-topology	2026-01-11 19:16:01.550056+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9512526
20251123232748	network-permissions	2026-01-11 19:16:01.559726+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2833466
20251125001342	billing-updates	2026-01-11 19:16:01.56287+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	948850
20251128035448	org-onboarding-status	2026-01-11 19:16:01.564124+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1453561
20251129180942	nfs-consolidate	2026-01-11 19:16:01.566027+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1420410
20251206052641	discovery-progress	2026-01-11 19:16:01.567589+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1749955
20251206202200	plan-fix	2026-01-11 19:16:01.569623+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	963858
20251207061341	daemon-url	2026-01-11 19:16:01.570869+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2417009
20251210045929	tags	2026-01-11 19:16:01.57359+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9213058
20251210175035	terms	2026-01-11 19:16:01.583199+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	994506
20251213025048	hash-keys	2026-01-11 19:16:01.584486+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	10931885
20251214050638	scanopy	2026-01-11 19:16:01.596076+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1617667
20251215215724	topo-scanopy-fix	2026-01-11 19:16:01.59807+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	778403
20251217153736	category rename	2026-01-11 19:16:01.599151+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1779319
20251218053111	invite-persistence	2026-01-11 19:16:01.601241+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5725461
20251219211216	create shares	2026-01-11 19:16:01.607295+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6916263
20251220170928	permissions-cleanup	2026-01-11 19:16:01.614552+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1559858
20251220180000	commercial-to-community	2026-01-11 19:16:01.616411+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	855336
20251221010000	cleanup subnet type	2026-01-11 19:16:01.617559+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	1013331
20251221020000	remove host target	2026-01-11 19:16:01.618893+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	1036476
20251221030000	user network access	2026-01-11 19:16:01.620236+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7075007
20251221040000	interfaces table	2026-01-11 19:16:01.627658+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	10071309
20251221050000	ports table	2026-01-11 19:16:01.638155+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	9158626
20251221060000	bindings table	2026-01-11 19:16:01.647673+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	10979413
20251221070000	group bindings	2026-01-11 19:16:01.659233+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6491923
20251222020000	tag cascade delete	2026-01-11 19:16:01.6661+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1417212
20251223232524	network remove default	2026-01-11 19:16:01.667995+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1134288
20251225100000	color enum	2026-01-11 19:16:01.669493+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1650559
20251227010000	topology snapshot migration	2026-01-11 19:16:01.671478+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4481681
20251228010000	user api keys	2026-01-11 19:16:01.676289+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	11340705
20251230160000	daemon version and maintainer	2026-01-11 19:16:01.688042+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	3123287
20260103000000	service position	2026-01-11 19:16:01.691499+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	1959175
20260106000000	interface mac index	2026-01-11 19:16:01.693767+00	t	\\xa26248372a1e31af46a9c6fbdaef178982229e2ceeb90cc6a289d5764f87a38747294b3adf5f21276b5d171e42bdb6ac	1798636
20260106204402	entity tags junction	2026-01-11 19:16:01.69593+00	t	\\xf73c604f9f0b8db065d990a861684b0dbd62c3ef9bead120c68431c933774de56491a53f021e79f09801680152f5a08a	12866935
20260108033856	fix entity tags json format	2026-01-11 19:16:01.709194+00	t	\\x197eaa063d4f96dd0e897ad8fd96cc1ba9a54dda40a93a5c12eac14597e4dea4c806dd0a527736fb5807b7a8870d9916	1567316
20260110000000	email verification	2026-01-11 19:16:01.711288+00	t	\\xb8da8433f58ba4ce846b9fa0c2551795747a8473ad10266b19685504847458ea69d27a0ce430151cfb426f5f5fb6ac3a	3319813
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
c57015c2-2190-4aa2-a12f-6ff87d1bd67b	20b4ea84d172e79f514f9ce892efa1cf6968462aa925a16e37f51ffa7d2721bf	157a60f7-b693-4f10-afdd-810c4ea2bdfe	Integrated Daemon API Key	2026-01-11 19:16:03.148779+00	2026-01-11 19:16:03.148779+00	2026-01-11 19:18:03.496159+00	\N	t
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
b28c009d-5904-4780-84d7-5c19666b37fe	157a60f7-b693-4f10-afdd-810c4ea2bdfe	f2839290-8f09-4d7d-81d1-5c0276961c8e	Port	b05505e3-d332-426f-be9f-a89411bed7c0	12d9b4b2-db83-43f1-b655-94c8df48c646	2026-01-11 19:16:03.296743+00	2026-01-11 19:16:03.296743+00
867dd219-00a1-47b3-a5ff-1c9faddf88c3	157a60f7-b693-4f10-afdd-810c4ea2bdfe	d7367ccd-a7ae-4fa9-86a0-846017b4bb89	Port	03d718fb-17bd-44ac-b792-d1181f07ab13	c7661823-58c0-4c35-995a-9392c1065fc2	2026-01-11 19:16:31.46425+00	2026-01-11 19:16:31.46425+00
09568833-5ca0-4eab-badf-c869eb009b7e	157a60f7-b693-4f10-afdd-810c4ea2bdfe	5fa3168b-2ccb-45f1-a8bb-26e6c0487fed	Port	03d718fb-17bd-44ac-b792-d1181f07ab13	d161ec9c-bfbd-4f09-88e2-5c9f3be78abb	2026-01-11 19:16:40.710357+00	2026-01-11 19:16:40.710357+00
4d073e82-8f5f-4c12-9b8b-940617352e03	157a60f7-b693-4f10-afdd-810c4ea2bdfe	9ab7ec4a-a813-4165-8ff2-1a004a03707a	Port	04be2de1-6f7c-4d0b-a93a-dff3dc2d5439	bc029501-34c0-4466-91c2-5a5621645a75	2026-01-11 19:16:53.107951+00	2026-01-11 19:16:53.107951+00
2db53de4-7cd3-42f2-8783-9e7caf80f46c	157a60f7-b693-4f10-afdd-810c4ea2bdfe	379df372-1276-4c61-a52f-e8272d72164a	Port	5b436a08-ffb3-473a-9ee5-5dafaa91ae86	b3573088-3253-420b-ab06-6db3b3ebea0f	2026-01-11 19:17:11.556389+00	2026-01-11 19:17:11.556389+00
6b94a0b4-1362-4f17-9cff-8ad92a780b69	157a60f7-b693-4f10-afdd-810c4ea2bdfe	5e41ed53-1fa6-4c3c-86ad-7c2bb65ee439	Port	2983a669-96e6-4ec5-b5b6-4078b0e837c2	0b99f2a9-7631-4cef-837f-389e6df4e725	2026-01-11 19:17:23.801986+00	2026-01-11 19:17:23.801986+00
0f5787cd-f0d1-48de-b4fa-e20ecaf9bd1b	157a60f7-b693-4f10-afdd-810c4ea2bdfe	75ae286b-c2a1-49e0-aac7-4c2250fe9747	Port	2983a669-96e6-4ec5-b5b6-4078b0e837c2	c8e61660-9f9c-4d6a-9a1f-f9dd99273078	2026-01-11 19:17:29.95327+00	2026-01-11 19:17:29.95327+00
9637a128-8085-4f52-83e0-58147dde0d34	157a60f7-b693-4f10-afdd-810c4ea2bdfe	c6811906-7a1e-4a89-94be-3619a08ad27a	Port	2983a669-96e6-4ec5-b5b6-4078b0e837c2	a5eba8cc-896d-446e-ab7a-b572807a0890	2026-01-11 19:17:33.01431+00	2026-01-11 19:17:33.01431+00
572de96d-9cf9-4480-9d82-947e9814839c	157a60f7-b693-4f10-afdd-810c4ea2bdfe	8ef95629-e668-4854-8656-45ab262a95b8	Port	2983a669-96e6-4ec5-b5b6-4078b0e837c2	28925b24-52df-4f2e-a593-cd314bd332d6	2026-01-11 19:17:33.014372+00	2026-01-11 19:17:33.014372+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, version, user_id) FROM stdin;
6fad9801-e370-403a-a65f-bb8ba0118d72	157a60f7-b693-4f10-afdd-810c4ea2bdfe	d101410f-d3fe-484e-bdcd-5a1ec9155f54	2026-01-11 19:16:03.255838+00	2026-01-11 19:17:46.444889+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["9a783afa-50e6-4737-83e2-8e884e70d829"]}	2026-01-11 19:16:03.255838+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	0.13.5	70cd167c-62a2-430d-bd2a-65f5a57d3420
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
e75703c5-144a-4e7c-8f9d-be9f552c8f9d	157a60f7-b693-4f10-afdd-810c4ea2bdfe	6fad9801-e370-403a-a65f-bb8ba0118d72	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54"}	Self Report	2026-01-11 19:16:03.264912+00	2026-01-11 19:16:03.264912+00
28ca7303-7b0e-4e0b-bb0a-60b603e9828e	157a60f7-b693-4f10-afdd-810c4ea2bdfe	6fad9801-e370-403a-a65f-bb8ba0118d72	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-11 19:16:03.273342+00	2026-01-11 19:16:03.273342+00
180fc11a-f7a9-4e5a-8702-d5b9f00b3ced	157a60f7-b693-4f10-afdd-810c4ea2bdfe	6fad9801-e370-403a-a65f-bb8ba0118d72	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "session_id": "93444ea3-fcd4-4e63-8d15-e0ae6e4eb8b1", "started_at": "2026-01-11T19:16:03.272816401Z", "finished_at": "2026-01-11T19:16:03.428477969Z", "discovery_type": {"type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54"}}}	{"type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54"}	Self Report	2026-01-11 19:16:03.272816+00	2026-01-11 19:16:03.436864+00
fc0d7996-54aa-4d2e-8f2e-8e1c3c40e8be	157a60f7-b693-4f10-afdd-810c4ea2bdfe	6fad9801-e370-403a-a65f-bb8ba0118d72	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "session_id": "754c34ce-f68c-440f-8edb-18f21a62a21d", "started_at": "2026-01-11T19:16:03.455086079Z", "finished_at": "2026-01-11T19:18:03.494709150Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-11 19:16:03.455086+00	2026-01-11 19:18:03.498322+00
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
e4270a43-d1ef-4da3-b0bd-742847dc5ff1	157a60f7-b693-4f10-afdd-810c4ea2bdfe		\N	2026-01-11 19:18:03.512489+00	2026-01-11 19:18:03.512489+00	{"type": "Manual"}	Yellow	"SmoothStep"	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden) FROM stdin;
d101410f-d3fe-484e-bdcd-5a1ec9155f54	157a60f7-b693-4f10-afdd-810c4ea2bdfe	scanopy-daemon	4074548c100b	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:03.296685448Z", "type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72"}]}	null	2026-01-11 19:16:03.249529+00	2026-01-11 19:16:03.249529+00	f
1ed29502-b1ac-448d-9114-71011a7376fc	157a60f7-b693-4f10-afdd-810c4ea2bdfe	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:25.221511844Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-11 19:16:25.221513+00	2026-01-11 19:16:25.221513+00	f
94fdb5e3-6cdd-4522-8b1e-026a0734f7a4	157a60f7-b693-4f10-afdd-810c4ea2bdfe	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:40.814487317Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-11 19:16:40.814488+00	2026-01-11 19:16:40.814488+00	f
e1364cec-096b-42b5-bd8c-cb09a28aaf5c	157a60f7-b693-4f10-afdd-810c4ea2bdfe	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:56.181946725Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-11 19:16:56.181948+00	2026-01-11 19:16:56.181948+00	f
aca5e8d6-d035-464d-b962-fcfa0ac82921	157a60f7-b693-4f10-afdd-810c4ea2bdfe	runnervmi13qx	runnervmi13qx	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-11T19:17:17.613414490Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-11 19:17:17.613415+00	2026-01-11 19:17:17.613415+00	f
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
b05505e3-d332-426f-be9f-a89411bed7c0	157a60f7-b693-4f10-afdd-810c4ea2bdfe	d101410f-d3fe-484e-bdcd-5a1ec9155f54	9a783afa-50e6-4737-83e2-8e884e70d829	172.25.0.4	22:e6:20:66:aa:8a	eth0	0	2026-01-11 19:16:03.273148+00	2026-01-11 19:16:03.273148+00
03d718fb-17bd-44ac-b792-d1181f07ab13	157a60f7-b693-4f10-afdd-810c4ea2bdfe	1ed29502-b1ac-448d-9114-71011a7376fc	9a783afa-50e6-4737-83e2-8e884e70d829	172.25.0.5	4a:32:8d:21:56:e8	\N	0	2026-01-11 19:16:25.221484+00	2026-01-11 19:16:25.221484+00
04be2de1-6f7c-4d0b-a93a-dff3dc2d5439	157a60f7-b693-4f10-afdd-810c4ea2bdfe	94fdb5e3-6cdd-4522-8b1e-026a0734f7a4	9a783afa-50e6-4737-83e2-8e884e70d829	172.25.0.3	2a:d7:81:a1:f6:5e	\N	0	2026-01-11 19:16:40.814464+00	2026-01-11 19:16:40.814464+00
5b436a08-ffb3-473a-9ee5-5dafaa91ae86	157a60f7-b693-4f10-afdd-810c4ea2bdfe	e1364cec-096b-42b5-bd8c-cb09a28aaf5c	9a783afa-50e6-4737-83e2-8e884e70d829	172.25.0.6	5e:8e:15:7c:94:28	\N	0	2026-01-11 19:16:56.181922+00	2026-01-11 19:16:56.181922+00
2983a669-96e6-4ec5-b5b6-4078b0e837c2	157a60f7-b693-4f10-afdd-810c4ea2bdfe	aca5e8d6-d035-464d-b962-fcfa0ac82921	9a783afa-50e6-4737-83e2-8e884e70d829	172.25.0.1	62:b2:ad:e8:d1:6f	\N	0	2026-01-11 19:17:17.613381+00	2026-01-11 19:17:17.613381+00
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
157a60f7-b693-4f10-afdd-810c4ea2bdfe	My Network	2026-01-11 19:16:03.129256+00	2026-01-11 19:16:03.129256+00	7aa05e41-e845-481b-88a0-bbf9ad27d48d
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
7aa05e41-e845-481b-88a0-bbf9ad27d48d	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2026-01-11 19:16:03.120094+00	2026-01-11 19:16:03.120094+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
12d9b4b2-db83-43f1-b655-94c8df48c646	157a60f7-b693-4f10-afdd-810c4ea2bdfe	d101410f-d3fe-484e-bdcd-5a1ec9155f54	60073	Tcp	Custom	2026-01-11 19:16:03.296363+00	2026-01-11 19:16:03.296363+00
c7661823-58c0-4c35-995a-9392c1065fc2	157a60f7-b693-4f10-afdd-810c4ea2bdfe	1ed29502-b1ac-448d-9114-71011a7376fc	8123	Tcp	Custom	2026-01-11 19:16:31.464239+00	2026-01-11 19:16:31.464239+00
d161ec9c-bfbd-4f09-88e2-5c9f3be78abb	157a60f7-b693-4f10-afdd-810c4ea2bdfe	1ed29502-b1ac-448d-9114-71011a7376fc	18555	Tcp	Custom	2026-01-11 19:16:40.710347+00	2026-01-11 19:16:40.710347+00
bc029501-34c0-4466-91c2-5a5621645a75	157a60f7-b693-4f10-afdd-810c4ea2bdfe	94fdb5e3-6cdd-4522-8b1e-026a0734f7a4	60072	Tcp	Custom	2026-01-11 19:16:53.107941+00	2026-01-11 19:16:53.107941+00
b3573088-3253-420b-ab06-6db3b3ebea0f	157a60f7-b693-4f10-afdd-810c4ea2bdfe	e1364cec-096b-42b5-bd8c-cb09a28aaf5c	5432	Tcp	PostgreSQL	2026-01-11 19:17:11.556379+00	2026-01-11 19:17:11.556379+00
0b99f2a9-7631-4cef-837f-389e6df4e725	157a60f7-b693-4f10-afdd-810c4ea2bdfe	aca5e8d6-d035-464d-b962-fcfa0ac82921	8123	Tcp	Custom	2026-01-11 19:17:23.801975+00	2026-01-11 19:17:23.801975+00
c8e61660-9f9c-4d6a-9a1f-f9dd99273078	157a60f7-b693-4f10-afdd-810c4ea2bdfe	aca5e8d6-d035-464d-b962-fcfa0ac82921	60072	Tcp	Custom	2026-01-11 19:17:29.953259+00	2026-01-11 19:17:29.953259+00
a5eba8cc-896d-446e-ab7a-b572807a0890	157a60f7-b693-4f10-afdd-810c4ea2bdfe	aca5e8d6-d035-464d-b962-fcfa0ac82921	22	Tcp	Ssh	2026-01-11 19:17:33.014301+00	2026-01-11 19:17:33.014301+00
28925b24-52df-4f2e-a593-cd314bd332d6	157a60f7-b693-4f10-afdd-810c4ea2bdfe	aca5e8d6-d035-464d-b962-fcfa0ac82921	5435	Tcp	Custom	2026-01-11 19:17:33.01437+00	2026-01-11 19:17:33.01437+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, "position") FROM stdin;
f2839290-8f09-4d7d-81d1-5c0276961c8e	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:16:03.29675+00	2026-01-11 19:16:03.29675+00	Scanopy Daemon	d101410f-d3fe-484e-bdcd-5a1ec9155f54	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-11T19:16:03.296748546Z", "type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72"}]}	0
d7367ccd-a7ae-4fa9-86a0-846017b4bb89	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:16:31.464252+00	2026-01-11 19:16:31.464252+00	Home Assistant	1ed29502-b1ac-448d-9114-71011a7376fc	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-11T19:16:31.464233881Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
5fa3168b-2ccb-45f1-a8bb-26e6c0487fed	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:16:40.710361+00	2026-01-11 19:16:40.710361+00	Unclaimed Open Ports	1ed29502-b1ac-448d-9114-71011a7376fc	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-11T19:16:40.710341889Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
9ab7ec4a-a813-4165-8ff2-1a004a03707a	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:16:53.107954+00	2026-01-11 19:16:53.107954+00	Scanopy Server	94fdb5e3-6cdd-4522-8b1e-026a0734f7a4	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-11T19:16:53.107935227Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
379df372-1276-4c61-a52f-e8272d72164a	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:17:11.556393+00	2026-01-11 19:17:11.556393+00	PostgreSQL	e1364cec-096b-42b5-bd8c-cb09a28aaf5c	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-11T19:17:11.556373362Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
5e41ed53-1fa6-4c3c-86ad-7c2bb65ee439	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:17:23.801988+00	2026-01-11 19:17:23.801988+00	Home Assistant	aca5e8d6-d035-464d-b962-fcfa0ac82921	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-11T19:17:23.801970673Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
75ae286b-c2a1-49e0-aac7-4c2250fe9747	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:17:29.953273+00	2026-01-11 19:17:29.953273+00	Scanopy Server	aca5e8d6-d035-464d-b962-fcfa0ac82921	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-11T19:17:29.953252886Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
c6811906-7a1e-4a89-94be-3619a08ad27a	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:17:33.014313+00	2026-01-11 19:17:33.014313+00	SSH	aca5e8d6-d035-464d-b962-fcfa0ac82921	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-11T19:17:33.014296122Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	2
8ef95629-e668-4854-8656-45ab262a95b8	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:17:33.014375+00	2026-01-11 19:17:33.014375+00	Unclaimed Open Ports	aca5e8d6-d035-464d-b962-fcfa0ac82921	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-11T19:17:33.014368857Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	3
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
9f9528e5-5de2-44a1-92fa-01359feb1afb	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:16:03.130789+00	2026-01-11 19:16:03.130789+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}
7a75ac4c-0fc7-43a7-8cd9-e0d2191a2f68	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:16:03.130809+00	2026-01-11 19:16:03.130809+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}
9a783afa-50e6-4737-83e2-8e884e70d829	157a60f7-b693-4f10-afdd-810c4ea2bdfe	2026-01-11 19:16:03.273119+00	2026-01-11 19:16:03.273119+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:03.273117663Z", "type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72"}]}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
644a1862-88dd-4271-9247-59e19ba8c23b	7aa05e41-e845-481b-88a0-bbf9ad27d48d	New Tag	\N	2026-01-11 19:18:03.523049+00	2026-01-11 19:18:03.523049+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
f6fdad5f-4205-483e-bace-0cd4b27d7643	157a60f7-b693-4f10-afdd-810c4ea2bdfe	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:03.296685448Z", "type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72"}]}, "hostname": "4074548c100b", "created_at": "2026-01-11T19:16:03.249529Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:03.249529Z", "description": null, "virtualization": null}, {"id": "1ed29502-b1ac-448d-9114-71011a7376fc", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:25.221511844Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2026-01-11T19:16:25.221513Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:25.221513Z", "description": null, "virtualization": null}, {"id": "94fdb5e3-6cdd-4522-8b1e-026a0734f7a4", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:40.814487317Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2026-01-11T19:16:40.814488Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:40.814488Z", "description": null, "virtualization": null}, {"id": "e1364cec-096b-42b5-bd8c-cb09a28aaf5c", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:56.181946725Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2026-01-11T19:16:56.181948Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:56.181948Z", "description": null, "virtualization": null}, {"id": "aca5e8d6-d035-464d-b962-fcfa0ac82921", "name": "runnervmi13qx", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-11T19:17:17.613414490Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmi13qx", "created_at": "2026-01-11T19:17:17.613415Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:17:17.613415Z", "description": null, "virtualization": null}]	[{"id": "9f9528e5-5de2-44a1-92fa-01359feb1afb", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-11T19:16:03.130789Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:03.130789Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "7a75ac4c-0fc7-43a7-8cd9-e0d2191a2f68", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-11T19:16:03.130809Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:03.130809Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "9a783afa-50e6-4737-83e2-8e884e70d829", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-01-11T19:16:03.273117663Z", "type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72"}]}, "created_at": "2026-01-11T19:16:03.273119Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:03.273119Z", "description": null, "subnet_type": "Lan"}]	[{"id": "f2839290-8f09-4d7d-81d1-5c0276961c8e", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-11T19:16:03.296748546Z", "type": "SelfReport", "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72"}]}, "host_id": "d101410f-d3fe-484e-bdcd-5a1ec9155f54", "bindings": [{"id": "b28c009d-5904-4780-84d7-5c19666b37fe", "type": "Port", "port_id": "12d9b4b2-db83-43f1-b655-94c8df48c646", "created_at": "2026-01-11T19:16:03.296743Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "f2839290-8f09-4d7d-81d1-5c0276961c8e", "updated_at": "2026-01-11T19:16:03.296743Z", "interface_id": "b05505e3-d332-426f-be9f-a89411bed7c0"}], "position": 0, "created_at": "2026-01-11T19:16:03.296750Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:03.296750Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "d7367ccd-a7ae-4fa9-86a0-846017b4bb89", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-11T19:16:31.464233881Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1ed29502-b1ac-448d-9114-71011a7376fc", "bindings": [{"id": "867dd219-00a1-47b3-a5ff-1c9faddf88c3", "type": "Port", "port_id": "c7661823-58c0-4c35-995a-9392c1065fc2", "created_at": "2026-01-11T19:16:31.464250Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "d7367ccd-a7ae-4fa9-86a0-846017b4bb89", "updated_at": "2026-01-11T19:16:31.464250Z", "interface_id": "03d718fb-17bd-44ac-b792-d1181f07ab13"}], "position": 0, "created_at": "2026-01-11T19:16:31.464252Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:31.464252Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "5fa3168b-2ccb-45f1-a8bb-26e6c0487fed", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-11T19:16:40.710341889Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1ed29502-b1ac-448d-9114-71011a7376fc", "bindings": [{"id": "09568833-5ca0-4eab-badf-c869eb009b7e", "type": "Port", "port_id": "d161ec9c-bfbd-4f09-88e2-5c9f3be78abb", "created_at": "2026-01-11T19:16:40.710357Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "5fa3168b-2ccb-45f1-a8bb-26e6c0487fed", "updated_at": "2026-01-11T19:16:40.710357Z", "interface_id": "03d718fb-17bd-44ac-b792-d1181f07ab13"}], "position": 1, "created_at": "2026-01-11T19:16:40.710361Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:40.710361Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "9ab7ec4a-a813-4165-8ff2-1a004a03707a", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-11T19:16:53.107935227Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "94fdb5e3-6cdd-4522-8b1e-026a0734f7a4", "bindings": [{"id": "4d073e82-8f5f-4c12-9b8b-940617352e03", "type": "Port", "port_id": "bc029501-34c0-4466-91c2-5a5621645a75", "created_at": "2026-01-11T19:16:53.107951Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "9ab7ec4a-a813-4165-8ff2-1a004a03707a", "updated_at": "2026-01-11T19:16:53.107951Z", "interface_id": "04be2de1-6f7c-4d0b-a93a-dff3dc2d5439"}], "position": 0, "created_at": "2026-01-11T19:16:53.107954Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:16:53.107954Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "379df372-1276-4c61-a52f-e8272d72164a", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-11T19:17:11.556373362Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e1364cec-096b-42b5-bd8c-cb09a28aaf5c", "bindings": [{"id": "2db53de4-7cd3-42f2-8783-9e7caf80f46c", "type": "Port", "port_id": "b3573088-3253-420b-ab06-6db3b3ebea0f", "created_at": "2026-01-11T19:17:11.556389Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "379df372-1276-4c61-a52f-e8272d72164a", "updated_at": "2026-01-11T19:17:11.556389Z", "interface_id": "5b436a08-ffb3-473a-9ee5-5dafaa91ae86"}], "position": 0, "created_at": "2026-01-11T19:17:11.556393Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:17:11.556393Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "5e41ed53-1fa6-4c3c-86ad-7c2bb65ee439", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-11T19:17:23.801970673Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "aca5e8d6-d035-464d-b962-fcfa0ac82921", "bindings": [{"id": "6b94a0b4-1362-4f17-9cff-8ad92a780b69", "type": "Port", "port_id": "0b99f2a9-7631-4cef-837f-389e6df4e725", "created_at": "2026-01-11T19:17:23.801986Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "5e41ed53-1fa6-4c3c-86ad-7c2bb65ee439", "updated_at": "2026-01-11T19:17:23.801986Z", "interface_id": "2983a669-96e6-4ec5-b5b6-4078b0e837c2"}], "position": 0, "created_at": "2026-01-11T19:17:23.801988Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:17:23.801988Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "75ae286b-c2a1-49e0-aac7-4c2250fe9747", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-11T19:17:29.953252886Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "aca5e8d6-d035-464d-b962-fcfa0ac82921", "bindings": [{"id": "0f5787cd-f0d1-48de-b4fa-e20ecaf9bd1b", "type": "Port", "port_id": "c8e61660-9f9c-4d6a-9a1f-f9dd99273078", "created_at": "2026-01-11T19:17:29.953270Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "75ae286b-c2a1-49e0-aac7-4c2250fe9747", "updated_at": "2026-01-11T19:17:29.953270Z", "interface_id": "2983a669-96e6-4ec5-b5b6-4078b0e837c2"}], "position": 1, "created_at": "2026-01-11T19:17:29.953273Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:17:29.953273Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "c6811906-7a1e-4a89-94be-3619a08ad27a", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-11T19:17:33.014296122Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "aca5e8d6-d035-464d-b962-fcfa0ac82921", "bindings": [{"id": "9637a128-8085-4f52-83e0-58147dde0d34", "type": "Port", "port_id": "a5eba8cc-896d-446e-ab7a-b572807a0890", "created_at": "2026-01-11T19:17:33.014310Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "c6811906-7a1e-4a89-94be-3619a08ad27a", "updated_at": "2026-01-11T19:17:33.014310Z", "interface_id": "2983a669-96e6-4ec5-b5b6-4078b0e837c2"}], "position": 2, "created_at": "2026-01-11T19:17:33.014313Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:17:33.014313Z", "virtualization": null, "service_definition": "SSH"}, {"id": "8ef95629-e668-4854-8656-45ab262a95b8", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-11T19:17:33.014368857Z", "type": "Network", "daemon_id": "6fad9801-e370-403a-a65f-bb8ba0118d72", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "aca5e8d6-d035-464d-b962-fcfa0ac82921", "bindings": [{"id": "572de96d-9cf9-4480-9d82-947e9814839c", "type": "Port", "port_id": "28925b24-52df-4f2e-a593-cd314bd332d6", "created_at": "2026-01-11T19:17:33.014372Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "service_id": "8ef95629-e668-4854-8656-45ab262a95b8", "updated_at": "2026-01-11T19:17:33.014372Z", "interface_id": "2983a669-96e6-4ec5-b5b6-4078b0e837c2"}], "position": 3, "created_at": "2026-01-11T19:17:33.014375Z", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:17:33.014375Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "e4270a43-d1ef-4da3-b0bd-742847dc5ff1", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2026-01-11T19:18:03.512489Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "157a60f7-b693-4f10-afdd-810c4ea2bdfe", "updated_at": "2026-01-11T19:18:03.512489Z", "binding_ids": [], "description": null}]	t	2026-01-11 19:16:03.14665+00	f	\N	\N	{9c97c132-1199-42ce-94bb-e255cec1a299,34d81bc2-2fe2-48a2-8675-9b2ed97c3fb1,e27e0147-d887-4c1b-a367-463a75ec0807}	{724acb28-73d8-43c5-958b-a94d07798f04}	{44e4da40-1217-4dfe-9765-c3847ed79601}	{680ff5cb-9fb0-41ac-985f-74a683158a58}	\N	2026-01-11 19:16:03.134876+00	2026-01-11 19:16:03.134876+00	{}	[]	{}	[]	{}	[]	{}
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
70cd167c-62a2-430d-bd2a-65f5a57d3420	2026-01-11 19:16:03.123425+00	2026-01-11 19:16:03.123425+00	$argon2id$v=19$m=19456,t=2,p=1$kKa/sTmnIJGyo9BItBRkEA$940fgl8CI/a2uU1uAQAsXJudFX+5grcrCDv+IuNGn10	\N	\N	\N	user@gmail.com	7aa05e41-e845-481b-88a0-bbf9ad27d48d	Owner	{}	\N	t	\N	\N	\N	\N
3676101b-6ace-463b-ac47-31cb12b69363	2026-01-11 19:18:04.937991+00	2026-01-11 19:18:04.937991+00	\N	\N	\N	\N	user@example.com	7aa05e41-e845-481b-88a0-bbf9ad27d48d	Owner	{}	\N	f	\N	\N	\N	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
e6YTR0-eIzp54BFvzOiycA	\\x93c41070b2e8cc6f11e0793a239e4f4713a67b81a7757365725f6964d92437306364313637632d363261322d343330642d626432612d36356635613537643334323099cd07ea12131003ce10cc2252000000	2026-01-18 19:16:03.281813+00
OVL2eLAAytYEkQqTMtMEZw	\\x93c4106704d332930a9104d6ca00b078f6523982ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92463353563613734382d633366662d343061352d386539332d336639343866316466663561a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92437306364313637632d363261322d343330642d626432612d36356635613537643334323099cd07ea12131204ce063dfdf7000000	2026-01-18 19:18:04.104726+00
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

\unrestrict PHfcXDurhfzZXLB1djPT1QebcejEixfIVRW9KbMm6TLVwqQKQDTPyD1Wg3mwWws

