--
-- PostgreSQL database dump
--

\restrict KsWC7V31VtwgXg91qTszYVSnJM7tJjtTbZfzuEUz4HtrAhedMkocg2y9bbghOxt

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
20251006215000	users	2026-01-08 04:31:53.091793+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3603323
20251006215100	networks	2026-01-08 04:31:53.09632+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4403901
20251006215151	create hosts	2026-01-08 04:31:53.101044+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3850315
20251006215155	create subnets	2026-01-08 04:31:53.105216+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3709692
20251006215201	create groups	2026-01-08 04:31:53.109249+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3873398
20251006215204	create daemons	2026-01-08 04:31:53.113442+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4125099
20251006215212	create services	2026-01-08 04:31:53.117945+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4712237
20251029193448	user-auth	2026-01-08 04:31:53.122954+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5531220
20251030044828	daemon api	2026-01-08 04:31:53.128785+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1471323
20251030170438	host-hide	2026-01-08 04:31:53.130545+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1090901
20251102224919	create discovery	2026-01-08 04:31:53.13191+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10395282
20251106235621	normalize-daemon-cols	2026-01-08 04:31:53.142599+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1708207
20251107034459	api keys	2026-01-08 04:31:53.1446+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8298880
20251107222650	oidc-auth	2026-01-08 04:31:53.153194+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	24543257
20251110181948	orgs-billing	2026-01-08 04:31:53.17804+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10767649
20251113223656	group-enhancements	2026-01-08 04:31:53.189197+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1035878
20251117032720	daemon-mode	2026-01-08 04:31:53.190516+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1081975
20251118143058	set-default-plan	2026-01-08 04:31:53.191871+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1083106
20251118225043	save-topology	2026-01-08 04:31:53.193216+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8804325
20251123232748	network-permissions	2026-01-08 04:31:53.202343+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2672771
20251125001342	billing-updates	2026-01-08 04:31:53.205412+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	904803
20251128035448	org-onboarding-status	2026-01-08 04:31:53.206614+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1374542
20251129180942	nfs-consolidate	2026-01-08 04:31:53.208248+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1153389
20251206052641	discovery-progress	2026-01-08 04:31:53.209689+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1700322
20251206202200	plan-fix	2026-01-08 04:31:53.211669+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	856382
20251207061341	daemon-url	2026-01-08 04:31:53.212813+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2215315
20251210045929	tags	2026-01-08 04:31:53.21531+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8781092
20251210175035	terms	2026-01-08 04:31:53.224436+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	859218
20251213025048	hash-keys	2026-01-08 04:31:53.225575+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	8762377
20251214050638	scanopy	2026-01-08 04:31:53.234619+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1470401
20251215215724	topo-scanopy-fix	2026-01-08 04:31:53.236367+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	785078
20251217153736	category rename	2026-01-08 04:31:53.237436+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1629780
20251218053111	invite-persistence	2026-01-08 04:31:53.239459+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5220589
20251219211216	create shares	2026-01-08 04:31:53.244995+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6652789
20251220170928	permissions-cleanup	2026-01-08 04:31:53.251973+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1390201
20251220180000	commercial-to-community	2026-01-08 04:31:53.253628+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	735457
20251221010000	cleanup subnet type	2026-01-08 04:31:53.254638+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	771784
20251221020000	remove host target	2026-01-08 04:31:53.255685+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	942885
20251221030000	user network access	2026-01-08 04:31:53.256922+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	6755271
20251221040000	interfaces table	2026-01-08 04:31:53.263966+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9571652
20251221050000	ports table	2026-01-08 04:31:53.273867+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	8756777
20251221060000	bindings table	2026-01-08 04:31:53.28293+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	10980848
20251221070000	group bindings	2026-01-08 04:31:53.294233+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6148044
20251222020000	tag cascade delete	2026-01-08 04:31:53.300891+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1139963
20251223232524	network remove default	2026-01-08 04:31:53.302301+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	966519
20251225100000	color enum	2026-01-08 04:31:53.303536+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1403236
20251227010000	topology snapshot migration	2026-01-08 04:31:53.305204+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4114669
20251228010000	user api keys	2026-01-08 04:31:53.309608+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	11024250
20251230160000	daemon version and maintainer	2026-01-08 04:31:53.32097+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	2521929
20260103000000	service position	2026-01-08 04:31:53.323785+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	1779129
20260106000000	interface mac index	2026-01-08 04:31:53.325867+00	t	\\xa26248372a1e31af46a9c6fbdaef178982229e2ceeb90cc6a289d5764f87a38747294b3adf5f21276b5d171e42bdb6ac	1604432
20260106204402	entity tags junction	2026-01-08 04:31:53.327763+00	t	\\xf73c604f9f0b8db065d990a861684b0dbd62c3ef9bead120c68431c933774de56491a53f021e79f09801680152f5a08a	11985879
20260108033856	fix entity tags json format	2026-01-08 04:31:53.340036+00	t	\\x197eaa063d4f96dd0e897ad8fd96cc1ba9a54dda40a93a5c12eac14597e4dea4c806dd0a527736fb5807b7a8870d9916	1372598
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
b10bf651-a536-440c-9d46-e8564ef9d756	6b1774a4ae4ca2d76ed31867cf286af3859fb64d2b4ec11972ecc26d6d36c384	dded8be8-442f-4cf6-bcca-23ffe1712ac9	Integrated Daemon API Key	2026-01-08 04:31:55.334027+00	2026-01-08 04:33:49.570172+00	2026-01-08 04:33:49.569011+00	\N	t
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
645b2cd7-10d4-4293-b53d-7b550774605d	dded8be8-442f-4cf6-bcca-23ffe1712ac9	0b5e6b51-15a3-429f-9b00-03ad2ed29d59	Port	ea5c2b42-8d84-41ea-b856-4e7a927402a9	87c9d38b-6ff3-40e7-b20b-b6b5e1e0f543	2026-01-08 04:31:55.471994+00	2026-01-08 04:31:55.471994+00
21804d2a-1e24-42d8-bf53-4789b95fe242	dded8be8-442f-4cf6-bcca-23ffe1712ac9	0fb73b33-5267-42bc-940e-884918945fbe	Port	a2f499c4-734f-4dc0-aa4e-d8f06ab590b0	7a2fdc68-fc61-4f57-baf0-60a7aba061ba	2026-01-08 04:32:17.99292+00	2026-01-08 04:32:17.99292+00
5f6836e1-1281-4f05-8e26-5710fe36ec2d	dded8be8-442f-4cf6-bcca-23ffe1712ac9	cda455e4-517f-461e-9d0c-101ac6e98124	Port	a2f499c4-734f-4dc0-aa4e-d8f06ab590b0	be1c01f3-56bc-431a-a120-22780b6d3121	2026-01-08 04:32:29.863231+00	2026-01-08 04:32:29.863231+00
3928737d-2611-49ce-be20-12bb4a7df7dc	dded8be8-442f-4cf6-bcca-23ffe1712ac9	6f07e23b-f639-4227-be18-7a9d560adfb1	Port	79c3b263-4c52-40e1-908b-fb76f7c9d000	9916d3b5-bc99-4d31-be33-93b6dd571939	2026-01-08 04:32:44.729175+00	2026-01-08 04:32:44.729175+00
cb671cee-2a25-4613-9f05-01379d44f645	dded8be8-442f-4cf6-bcca-23ffe1712ac9	ac4662a6-8f8c-49de-b199-43fe22044971	Port	da09b653-40a0-45d1-9c7c-d1eaccc32601	18f16d82-fc1d-488c-9e53-2dcadc913f10	2026-01-08 04:32:58.643486+00	2026-01-08 04:32:58.643486+00
01f9020b-d439-4699-9d49-2fc9236e1319	dded8be8-442f-4cf6-bcca-23ffe1712ac9	e521670a-3bb4-4473-8314-3fd8e64e5e4a	Port	2dea0ec0-1f30-4a95-8c9f-0f376c480051	a1bd7a8f-7113-4c99-afb0-4304590a5611	2026-01-08 04:33:06.826968+00	2026-01-08 04:33:06.826968+00
0f88392f-2699-480c-8a8f-fd6825de00bb	dded8be8-442f-4cf6-bcca-23ffe1712ac9	ab351d8d-d68a-4cdd-bc87-14eeadd9edef	Port	2dea0ec0-1f30-4a95-8c9f-0f376c480051	04112b5d-98e6-41a0-8abc-8a8168beaa6d	2026-01-08 04:33:16.467664+00	2026-01-08 04:33:16.467664+00
0ddb309a-c5b6-486d-9441-d03fdf1b271a	dded8be8-442f-4cf6-bcca-23ffe1712ac9	ffcc2fa9-f6ed-48f5-b0e9-8b3fc0ef3383	Port	2dea0ec0-1f30-4a95-8c9f-0f376c480051	c5a292da-4011-4a69-b5ef-57bbb64e8b0f	2026-01-08 04:33:18.517914+00	2026-01-08 04:33:18.517914+00
ddd343ff-6440-40f0-bba1-913376d71272	dded8be8-442f-4cf6-bcca-23ffe1712ac9	8ec17d00-c4a6-4216-85ab-0e25df64ff87	Port	2dea0ec0-1f30-4a95-8c9f-0f376c480051	ffde962e-6c9b-47b3-98b0-4a8bfc545c4e	2026-01-08 04:33:18.518341+00	2026-01-08 04:33:18.518341+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, version, user_id) FROM stdin;
1095e8c6-eb06-4c22-9026-c6f7d661e970	dded8be8-442f-4cf6-bcca-23ffe1712ac9	11224026-20a2-450c-801e-b216fef39843	2026-01-08 04:31:55.432663+00	2026-01-08 04:33:39.485297+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["64507048-2a38-4df3-ad5e-518784f291bc"]}	2026-01-08 04:33:39.487227+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	0.13.3	965fd837-18c7-4a58-8952-2aca03716718
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
037b45d2-e1c8-4126-9c5e-45565c0ccd96	dded8be8-442f-4cf6-bcca-23ffe1712ac9	1095e8c6-eb06-4c22-9026-c6f7d661e970	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843"}	Self Report	2026-01-08 04:31:55.439991+00	2026-01-08 04:31:55.439991+00
62c240d4-42f9-4b56-b267-30528a8669fd	dded8be8-442f-4cf6-bcca-23ffe1712ac9	1095e8c6-eb06-4c22-9026-c6f7d661e970	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-08 04:31:55.452195+00	2026-01-08 04:31:55.452195+00
bfa48f0a-a865-449d-9aa0-a7bfe0064875	dded8be8-442f-4cf6-bcca-23ffe1712ac9	1095e8c6-eb06-4c22-9026-c6f7d661e970	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "session_id": "84a24137-6223-4259-a856-0c37e6d70523", "started_at": "2026-01-08T04:31:55.451728347Z", "finished_at": "2026-01-08T04:31:55.511485441Z", "discovery_type": {"type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843"}}}	{"type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843"}	Self Report	2026-01-08 04:31:55.451728+00	2026-01-08 04:31:55.517029+00
0591ed41-4787-41a4-b69c-83cf118274df	dded8be8-442f-4cf6-bcca-23ffe1712ac9	1095e8c6-eb06-4c22-9026-c6f7d661e970	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "session_id": "eaa5e558-eea5-4fdd-80e3-cfb7598e79f2", "started_at": "2026-01-08T04:31:55.530756843Z", "finished_at": "2026-01-08T04:33:49.567781681Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-08 04:31:55.530756+00	2026-01-08 04:33:49.57122+00
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
e7c8b402-0d61-4316-96b2-1d5c5c24b8c1	dded8be8-442f-4cf6-bcca-23ffe1712ac9		\N	2026-01-08 04:33:49.584211+00	2026-01-08 04:33:49.584211+00	{"type": "Manual"}	Yellow	"SmoothStep"	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden) FROM stdin;
11224026-20a2-450c-801e-b216fef39843	dded8be8-442f-4cf6-bcca-23ffe1712ac9	scanopy-daemon	2681bcda9cab	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:31:55.471979893Z", "type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970"}]}	null	2026-01-08 04:31:55.426717+00	2026-01-08 04:31:55.484706+00	f
7f69e89f-0383-480d-a56b-12bd62264f09	dded8be8-442f-4cf6-bcca-23ffe1712ac9	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:32:15.832626432Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-08 04:32:15.832627+00	2026-01-08 04:32:15.832627+00	f
b66dea9a-6fe3-42a6-a5d5-3e0b606287d1	dded8be8-442f-4cf6-bcca-23ffe1712ac9	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:32:29.967212273Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-08 04:32:29.967213+00	2026-01-08 04:32:29.967213+00	f
e68d0580-af8a-45a5-bed4-d4f29dd03fa8	dded8be8-442f-4cf6-bcca-23ffe1712ac9	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:32:44.731941645Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-08 04:32:44.731942+00	2026-01-08 04:32:44.731942+00	f
931654db-9c91-4bd2-9423-bbe09bcf782d	dded8be8-442f-4cf6-bcca-23ffe1712ac9	runnervmh13bl	runnervmh13bl	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:33:04.703519788Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-08 04:33:04.70352+00	2026-01-08 04:33:04.70352+00	f
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
ea5c2b42-8d84-41ea-b856-4e7a927402a9	dded8be8-442f-4cf6-bcca-23ffe1712ac9	11224026-20a2-450c-801e-b216fef39843	64507048-2a38-4df3-ad5e-518784f291bc	172.25.0.4	86:2f:97:7c:bc:d1	eth0	0	2026-01-08 04:31:55.452056+00	2026-01-08 04:31:55.452056+00
a2f499c4-734f-4dc0-aa4e-d8f06ab590b0	dded8be8-442f-4cf6-bcca-23ffe1712ac9	7f69e89f-0383-480d-a56b-12bd62264f09	64507048-2a38-4df3-ad5e-518784f291bc	172.25.0.5	c2:3b:74:08:83:ed	\N	0	2026-01-08 04:32:15.832602+00	2026-01-08 04:32:15.832602+00
79c3b263-4c52-40e1-908b-fb76f7c9d000	dded8be8-442f-4cf6-bcca-23ffe1712ac9	b66dea9a-6fe3-42a6-a5d5-3e0b606287d1	64507048-2a38-4df3-ad5e-518784f291bc	172.25.0.6	ee:15:e7:ec:6e:9d	\N	0	2026-01-08 04:32:29.967189+00	2026-01-08 04:32:29.967189+00
da09b653-40a0-45d1-9c7c-d1eaccc32601	dded8be8-442f-4cf6-bcca-23ffe1712ac9	e68d0580-af8a-45a5-bed4-d4f29dd03fa8	64507048-2a38-4df3-ad5e-518784f291bc	172.25.0.3	b2:5a:cb:4e:b2:ab	\N	0	2026-01-08 04:32:44.731923+00	2026-01-08 04:32:44.731923+00
2dea0ec0-1f30-4a95-8c9f-0f376c480051	dded8be8-442f-4cf6-bcca-23ffe1712ac9	931654db-9c91-4bd2-9423-bbe09bcf782d	64507048-2a38-4df3-ad5e-518784f291bc	172.25.0.1	fa:c0:cd:36:ee:3c	\N	0	2026-01-08 04:33:04.703496+00	2026-01-08 04:33:04.703496+00
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
dded8be8-442f-4cf6-bcca-23ffe1712ac9	My Network	2026-01-08 04:31:55.31589+00	2026-01-08 04:31:55.31589+00	59db95b8-1aac-467a-81d9-e70a85a96d54
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
59db95b8-1aac-467a-81d9-e70a85a96d54	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2026-01-08 04:31:55.309675+00	2026-01-08 04:33:50.398043+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
87c9d38b-6ff3-40e7-b20b-b6b5e1e0f543	dded8be8-442f-4cf6-bcca-23ffe1712ac9	11224026-20a2-450c-801e-b216fef39843	60073	Tcp	Custom	2026-01-08 04:31:55.471799+00	2026-01-08 04:31:55.471799+00
7a2fdc68-fc61-4f57-baf0-60a7aba061ba	dded8be8-442f-4cf6-bcca-23ffe1712ac9	7f69e89f-0383-480d-a56b-12bd62264f09	8123	Tcp	Custom	2026-01-08 04:32:17.992908+00	2026-01-08 04:32:17.992908+00
be1c01f3-56bc-431a-a120-22780b6d3121	dded8be8-442f-4cf6-bcca-23ffe1712ac9	7f69e89f-0383-480d-a56b-12bd62264f09	18555	Tcp	Custom	2026-01-08 04:32:29.863221+00	2026-01-08 04:32:29.863221+00
9916d3b5-bc99-4d31-be33-93b6dd571939	dded8be8-442f-4cf6-bcca-23ffe1712ac9	b66dea9a-6fe3-42a6-a5d5-3e0b606287d1	5432	Tcp	PostgreSQL	2026-01-08 04:32:44.729164+00	2026-01-08 04:32:44.729164+00
18f16d82-fc1d-488c-9e53-2dcadc913f10	dded8be8-442f-4cf6-bcca-23ffe1712ac9	e68d0580-af8a-45a5-bed4-d4f29dd03fa8	60072	Tcp	Custom	2026-01-08 04:32:58.643476+00	2026-01-08 04:32:58.643476+00
a1bd7a8f-7113-4c99-afb0-4304590a5611	dded8be8-442f-4cf6-bcca-23ffe1712ac9	931654db-9c91-4bd2-9423-bbe09bcf782d	8123	Tcp	Custom	2026-01-08 04:33:06.826959+00	2026-01-08 04:33:06.826959+00
04112b5d-98e6-41a0-8abc-8a8168beaa6d	dded8be8-442f-4cf6-bcca-23ffe1712ac9	931654db-9c91-4bd2-9423-bbe09bcf782d	60072	Tcp	Custom	2026-01-08 04:33:16.467654+00	2026-01-08 04:33:16.467654+00
c5a292da-4011-4a69-b5ef-57bbb64e8b0f	dded8be8-442f-4cf6-bcca-23ffe1712ac9	931654db-9c91-4bd2-9423-bbe09bcf782d	22	Tcp	Ssh	2026-01-08 04:33:18.517905+00	2026-01-08 04:33:18.517905+00
ffde962e-6c9b-47b3-98b0-4a8bfc545c4e	dded8be8-442f-4cf6-bcca-23ffe1712ac9	931654db-9c91-4bd2-9423-bbe09bcf782d	5435	Tcp	Custom	2026-01-08 04:33:18.518337+00	2026-01-08 04:33:18.518337+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, "position") FROM stdin;
0b5e6b51-15a3-429f-9b00-03ad2ed29d59	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:31:55.471997+00	2026-01-08 04:31:55.471997+00	Scanopy Daemon	11224026-20a2-450c-801e-b216fef39843	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-08T04:31:55.471997126Z", "type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970"}]}	0
0fb73b33-5267-42bc-940e-884918945fbe	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:32:17.992924+00	2026-01-08 04:32:17.992924+00	Home Assistant	7f69e89f-0383-480d-a56b-12bd62264f09	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:32:17.992901427Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
cda455e4-517f-461e-9d0c-101ac6e98124	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:32:29.863235+00	2026-01-08 04:32:29.863235+00	Unclaimed Open Ports	7f69e89f-0383-480d-a56b-12bd62264f09	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:32:29.863215024Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
6f07e23b-f639-4227-be18-7a9d560adfb1	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:32:44.729181+00	2026-01-08 04:32:44.729181+00	PostgreSQL	b66dea9a-6fe3-42a6-a5d5-3e0b606287d1	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:32:44.729157582Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
ac4662a6-8f8c-49de-b199-43fe22044971	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:32:58.643491+00	2026-01-08 04:32:58.643491+00	Unclaimed Open Ports	e68d0580-af8a-45a5-bed4-d4f29dd03fa8	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:32:58.643469991Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
e521670a-3bb4-4473-8314-3fd8e64e5e4a	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:33:06.826972+00	2026-01-08 04:33:06.826972+00	Home Assistant	931654db-9c91-4bd2-9423-bbe09bcf782d	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:33:06.826952383Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
ab351d8d-d68a-4cdd-bc87-14eeadd9edef	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:33:16.467668+00	2026-01-08 04:33:16.467668+00	Scanopy Server	931654db-9c91-4bd2-9423-bbe09bcf782d	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:33:16.467647492Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
ffcc2fa9-f6ed-48f5-b0e9-8b3fc0ef3383	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:33:18.517918+00	2026-01-08 04:33:18.517918+00	SSH	931654db-9c91-4bd2-9423-bbe09bcf782d	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:33:18.517899699Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	2
8ec17d00-c4a6-4216-85ab-0e25df64ff87	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:33:18.518343+00	2026-01-08 04:33:18.518343+00	Unclaimed Open Ports	931654db-9c91-4bd2-9423-bbe09bcf782d	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:33:18.518336387Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	3
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
757390de-c039-4787-b18f-3493d9be6d99	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:31:55.317376+00	2026-01-08 04:31:55.317376+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}
1cf2deed-6861-4966-a31d-eb0b84d39d25	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:31:55.31738+00	2026-01-08 04:31:55.31738+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}
64507048-2a38-4df3-ad5e-518784f291bc	dded8be8-442f-4cf6-bcca-23ffe1712ac9	2026-01-08 04:31:55.452026+00	2026-01-08 04:31:55.452026+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-01-08T04:31:55.452025302Z", "type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970"}]}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
1bd0d2d5-2111-42c0-aac7-e6326d1c7317	59db95b8-1aac-467a-81d9-e70a85a96d54	New Tag	\N	2026-01-08 04:33:49.592659+00	2026-01-08 04:33:49.592659+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
9712ac71-60a4-469a-81bd-ca92c2ef9513	dded8be8-442f-4cf6-bcca-23ffe1712ac9	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "11224026-20a2-450c-801e-b216fef39843", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:31:55.471979893Z", "type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970"}]}, "hostname": "2681bcda9cab", "created_at": "2026-01-08T04:31:55.426717Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:31:55.484706Z", "description": null, "virtualization": null}, {"id": "7f69e89f-0383-480d-a56b-12bd62264f09", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:32:15.832626432Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2026-01-08T04:32:15.832627Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:32:15.832627Z", "description": null, "virtualization": null}, {"id": "b66dea9a-6fe3-42a6-a5d5-3e0b606287d1", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:32:29.967212273Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2026-01-08T04:32:29.967213Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:32:29.967213Z", "description": null, "virtualization": null}, {"id": "e68d0580-af8a-45a5-bed4-d4f29dd03fa8", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:32:44.731941645Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2026-01-08T04:32:44.731942Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:32:44.731942Z", "description": null, "virtualization": null}, {"id": "931654db-9c91-4bd2-9423-bbe09bcf782d", "name": "runnervmh13bl", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:33:04.703519788Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmh13bl", "created_at": "2026-01-08T04:33:04.703520Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:33:04.703520Z", "description": null, "virtualization": null}]	[{"id": "757390de-c039-4787-b18f-3493d9be6d99", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-08T04:31:55.317376Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:31:55.317376Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "1cf2deed-6861-4966-a31d-eb0b84d39d25", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-08T04:31:55.317380Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:31:55.317380Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "64507048-2a38-4df3-ad5e-518784f291bc", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-01-08T04:31:55.452025302Z", "type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970"}]}, "created_at": "2026-01-08T04:31:55.452026Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:31:55.452026Z", "description": null, "subnet_type": "Lan"}]	[{"id": "0b5e6b51-15a3-429f-9b00-03ad2ed29d59", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-08T04:31:55.471997126Z", "type": "SelfReport", "host_id": "11224026-20a2-450c-801e-b216fef39843", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970"}]}, "host_id": "11224026-20a2-450c-801e-b216fef39843", "bindings": [{"id": "645b2cd7-10d4-4293-b53d-7b550774605d", "type": "Port", "port_id": "87c9d38b-6ff3-40e7-b20b-b6b5e1e0f543", "created_at": "2026-01-08T04:31:55.471994Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "0b5e6b51-15a3-429f-9b00-03ad2ed29d59", "updated_at": "2026-01-08T04:31:55.471994Z", "interface_id": "ea5c2b42-8d84-41ea-b856-4e7a927402a9"}], "position": 0, "created_at": "2026-01-08T04:31:55.471997Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:31:55.471997Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "0fb73b33-5267-42bc-940e-884918945fbe", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:32:17.992901427Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "7f69e89f-0383-480d-a56b-12bd62264f09", "bindings": [{"id": "21804d2a-1e24-42d8-bf53-4789b95fe242", "type": "Port", "port_id": "7a2fdc68-fc61-4f57-baf0-60a7aba061ba", "created_at": "2026-01-08T04:32:17.992920Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "0fb73b33-5267-42bc-940e-884918945fbe", "updated_at": "2026-01-08T04:32:17.992920Z", "interface_id": "a2f499c4-734f-4dc0-aa4e-d8f06ab590b0"}], "position": 0, "created_at": "2026-01-08T04:32:17.992924Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:32:17.992924Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "cda455e4-517f-461e-9d0c-101ac6e98124", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:32:29.863215024Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "7f69e89f-0383-480d-a56b-12bd62264f09", "bindings": [{"id": "5f6836e1-1281-4f05-8e26-5710fe36ec2d", "type": "Port", "port_id": "be1c01f3-56bc-431a-a120-22780b6d3121", "created_at": "2026-01-08T04:32:29.863231Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "cda455e4-517f-461e-9d0c-101ac6e98124", "updated_at": "2026-01-08T04:32:29.863231Z", "interface_id": "a2f499c4-734f-4dc0-aa4e-d8f06ab590b0"}], "position": 1, "created_at": "2026-01-08T04:32:29.863235Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:32:29.863235Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "6f07e23b-f639-4227-be18-7a9d560adfb1", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:32:44.729157582Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "b66dea9a-6fe3-42a6-a5d5-3e0b606287d1", "bindings": [{"id": "3928737d-2611-49ce-be20-12bb4a7df7dc", "type": "Port", "port_id": "9916d3b5-bc99-4d31-be33-93b6dd571939", "created_at": "2026-01-08T04:32:44.729175Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "6f07e23b-f639-4227-be18-7a9d560adfb1", "updated_at": "2026-01-08T04:32:44.729175Z", "interface_id": "79c3b263-4c52-40e1-908b-fb76f7c9d000"}], "position": 0, "created_at": "2026-01-08T04:32:44.729181Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:32:44.729181Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "ac4662a6-8f8c-49de-b199-43fe22044971", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:32:58.643469991Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e68d0580-af8a-45a5-bed4-d4f29dd03fa8", "bindings": [{"id": "cb671cee-2a25-4613-9f05-01379d44f645", "type": "Port", "port_id": "18f16d82-fc1d-488c-9e53-2dcadc913f10", "created_at": "2026-01-08T04:32:58.643486Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "ac4662a6-8f8c-49de-b199-43fe22044971", "updated_at": "2026-01-08T04:32:58.643486Z", "interface_id": "da09b653-40a0-45d1-9c7c-d1eaccc32601"}], "position": 0, "created_at": "2026-01-08T04:32:58.643491Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:32:58.643491Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "e521670a-3bb4-4473-8314-3fd8e64e5e4a", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:33:06.826952383Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "931654db-9c91-4bd2-9423-bbe09bcf782d", "bindings": [{"id": "01f9020b-d439-4699-9d49-2fc9236e1319", "type": "Port", "port_id": "a1bd7a8f-7113-4c99-afb0-4304590a5611", "created_at": "2026-01-08T04:33:06.826968Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "e521670a-3bb4-4473-8314-3fd8e64e5e4a", "updated_at": "2026-01-08T04:33:06.826968Z", "interface_id": "2dea0ec0-1f30-4a95-8c9f-0f376c480051"}], "position": 0, "created_at": "2026-01-08T04:33:06.826972Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:33:06.826972Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "ab351d8d-d68a-4cdd-bc87-14eeadd9edef", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-08T04:33:16.467647492Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "931654db-9c91-4bd2-9423-bbe09bcf782d", "bindings": [{"id": "0f88392f-2699-480c-8a8f-fd6825de00bb", "type": "Port", "port_id": "04112b5d-98e6-41a0-8abc-8a8168beaa6d", "created_at": "2026-01-08T04:33:16.467664Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "ab351d8d-d68a-4cdd-bc87-14eeadd9edef", "updated_at": "2026-01-08T04:33:16.467664Z", "interface_id": "2dea0ec0-1f30-4a95-8c9f-0f376c480051"}], "position": 1, "created_at": "2026-01-08T04:33:16.467668Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:33:16.467668Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "ffcc2fa9-f6ed-48f5-b0e9-8b3fc0ef3383", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:33:18.517899699Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "931654db-9c91-4bd2-9423-bbe09bcf782d", "bindings": [{"id": "0ddb309a-c5b6-486d-9441-d03fdf1b271a", "type": "Port", "port_id": "c5a292da-4011-4a69-b5ef-57bbb64e8b0f", "created_at": "2026-01-08T04:33:18.517914Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "ffcc2fa9-f6ed-48f5-b0e9-8b3fc0ef3383", "updated_at": "2026-01-08T04:33:18.517914Z", "interface_id": "2dea0ec0-1f30-4a95-8c9f-0f376c480051"}], "position": 2, "created_at": "2026-01-08T04:33:18.517918Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:33:18.517918Z", "virtualization": null, "service_definition": "SSH"}, {"id": "8ec17d00-c4a6-4216-85ab-0e25df64ff87", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-08T04:33:18.518336387Z", "type": "Network", "daemon_id": "1095e8c6-eb06-4c22-9026-c6f7d661e970", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "931654db-9c91-4bd2-9423-bbe09bcf782d", "bindings": [{"id": "ddd343ff-6440-40f0-bba1-913376d71272", "type": "Port", "port_id": "ffde962e-6c9b-47b3-98b0-4a8bfc545c4e", "created_at": "2026-01-08T04:33:18.518341Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "service_id": "8ec17d00-c4a6-4216-85ab-0e25df64ff87", "updated_at": "2026-01-08T04:33:18.518341Z", "interface_id": "2dea0ec0-1f30-4a95-8c9f-0f376c480051"}], "position": 3, "created_at": "2026-01-08T04:33:18.518343Z", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:33:18.518343Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "e7c8b402-0d61-4316-96b2-1d5c5c24b8c1", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2026-01-08T04:33:49.584211Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "dded8be8-442f-4cf6-bcca-23ffe1712ac9", "updated_at": "2026-01-08T04:33:49.584211Z", "binding_ids": [], "description": null}]	t	2026-01-08 04:31:55.332373+00	f	\N	\N	{12a2b0f8-fdf4-4df6-a4e4-bffa4d79eb9f,9675ac00-54af-47f0-8989-d26f2c68f1f0,6073b0e7-fa49-48d6-ade6-46ee434460e8}	{b345210d-c755-47d6-b147-af07a50b5626}	{938fa4c8-c05b-4b3c-b09d-2b21dd42e4e2}	{a463b38c-cc42-4721-bf30-66bb4b07a570}	\N	2026-01-08 04:31:55.32103+00	2026-01-08 04:33:51.828526+00	{}	[]	{}	[]	{}	[]	{}
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
965fd837-18c7-4a58-8952-2aca03716718	2026-01-08 04:31:55.312705+00	2026-01-08 04:31:55.312705+00	$argon2id$v=19$m=19456,t=2,p=1$qLnnSE4tmxSgIGqSxBoNDA$OFSW6YbJJ/yMgaCctr0mWlseZ2gaYz1vweggIHeOAPY	\N	\N	\N	user@gmail.com	59db95b8-1aac-467a-81d9-e70a85a96d54	Owner	{}	\N
ef842f16-b8e7-431b-9c78-dc8afb6214ba	2026-01-08 04:33:50.915952+00	2026-01-08 04:33:50.915952+00	\N	\N	\N	\N	user@example.com	59db95b8-1aac-467a-81d9-e70a85a96d54	Owner	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
OZIZDuBiioFZQADBwI5mLw	\\x93c4102f668ec0c1004059818a62e00e19923981a7757365725f6964d92439363566643833372d313863372d346135382d383935322d32616361303337313637313899cd07ea0f041f37ce1b654eb8000000	2026-01-15 04:31:55.459624+00
Ebj_T72Poz9BGfyU3f3_uA	\\x93c410b8fffddd94fc19413fa38fbd4fffb81182a7757365725f6964d92439363566643833372d313863372d346135382d383935322d326163613033373136373138ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92436306433323539632d633036662d346238392d386135662d386531303039353436396666a86f72675f6e616d65af4d79204f7267616e697a6174696f6e99cd07ea0f042132ce0a226775000000	2026-01-15 04:33:50.170026+00
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

\unrestrict KsWC7V31VtwgXg91qTszYVSnJM7tJjtTbZfzuEUz4HtrAhedMkocg2y9bbghOxt

