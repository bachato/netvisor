--
-- PostgreSQL database dump
--

\restrict HLpT4lzdayJBqousixS313BUa04Gx1KghsJeaVzYxkm7wwDvkPmy8FaNdcUg1rK

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
DROP INDEX IF EXISTS public.idx_topologies_network;
DROP INDEX IF EXISTS public.idx_tags_organization;
DROP INDEX IF EXISTS public.idx_tags_org_name;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_shares_topology;
DROP INDEX IF EXISTS public.idx_shares_network;
DROP INDEX IF EXISTS public.idx_shares_enabled;
DROP INDEX IF EXISTS public.idx_services_network;
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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
20251006215000	users	2025-12-31 20:29:53.472789+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2852276
20251006215100	networks	2025-12-31 20:29:53.476615+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3908712
20251006215151	create hosts	2025-12-31 20:29:53.480932+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3109558
20251006215155	create subnets	2025-12-31 20:29:53.48437+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2812988
20251006215201	create groups	2025-12-31 20:29:53.487735+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3079086
20251006215204	create daemons	2025-12-31 20:29:53.491176+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	3423985
20251006215212	create services	2025-12-31 20:29:53.494905+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	3588201
20251029193448	user-auth	2025-12-31 20:29:53.498908+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5944225
20251030044828	daemon api	2025-12-31 20:29:53.50514+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1180806
20251030170438	host-hide	2025-12-31 20:29:53.506725+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	869638
20251102224919	create discovery	2025-12-31 20:29:53.507843+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	8740038
20251106235621	normalize-daemon-cols	2025-12-31 20:29:53.516899+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1383297
20251107034459	api keys	2025-12-31 20:29:53.51886+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	6698574
20251107222650	oidc-auth	2025-12-31 20:29:53.525874+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	23907387
20251110181948	orgs-billing	2025-12-31 20:29:53.55007+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	9118941
20251113223656	group-enhancements	2025-12-31 20:29:53.559655+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	957702
20251117032720	daemon-mode	2025-12-31 20:29:53.56084+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	885196
20251118143058	set-default-plan	2025-12-31 20:29:53.561942+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	930267
20251118225043	save-topology	2025-12-31 20:29:53.563361+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	7315239
20251123232748	network-permissions	2025-12-31 20:29:53.570935+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2451320
20251125001342	billing-updates	2025-12-31 20:29:53.57373+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	833760
20251128035448	org-onboarding-status	2025-12-31 20:29:53.574907+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1512294
20251129180942	nfs-consolidate	2025-12-31 20:29:53.576664+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1012308
20251206052641	discovery-progress	2025-12-31 20:29:53.577897+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1544370
20251206202200	plan-fix	2025-12-31 20:29:53.579672+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	726432
20251207061341	daemon-url	2025-12-31 20:29:53.580661+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	1934348
20251210045929	tags	2025-12-31 20:29:53.582881+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	6986612
20251210175035	terms	2025-12-31 20:29:53.590258+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	718311
20251213025048	hash-keys	2025-12-31 20:29:53.591256+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	8225405
20251214050638	scanopy	2025-12-31 20:29:53.599835+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1423148
20251215215724	topo-scanopy-fix	2025-12-31 20:29:53.601739+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	634613
20251217153736	category rename	2025-12-31 20:29:53.602624+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1295839
20251218053111	invite-persistence	2025-12-31 20:29:53.604305+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	4099823
20251219211216	create shares	2025-12-31 20:29:53.608856+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	5117039
20251220170928	permissions-cleanup	2025-12-31 20:29:53.614485+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1061415
20251220180000	commercial-to-community	2025-12-31 20:29:53.615789+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	640568
20251221010000	cleanup subnet type	2025-12-31 20:29:53.616635+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	723691
20251221020000	remove host target	2025-12-31 20:29:53.617753+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	952181
20251221030000	user network access	2025-12-31 20:29:53.619034+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	5613545
20251221040000	interfaces table	2025-12-31 20:29:53.625001+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	7649302
20251221050000	ports table	2025-12-31 20:29:53.632952+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	6779725
20251221060000	bindings table	2025-12-31 20:29:53.64005+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	8272383
20251221070000	group bindings	2025-12-31 20:29:53.648641+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	5025584
20251222020000	tag cascade delete	2025-12-31 20:29:53.653959+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1148138
20251223232524	network remove default	2025-12-31 20:29:53.655547+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1016208
20251225100000	color enum	2025-12-31 20:29:53.656905+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1062116
20251227010000	topology snapshot migration	2025-12-31 20:29:53.658428+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	3564414
20251230160000	daemon version and maintainer	2025-12-31 20:29:53.6623+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	2385005
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
9be0e938-97dd-4eb2-8495-97fcf16d7394	a6c5d084c49bb5e15daebf0c7a582ac14af735ae5448315cc83d8ab6d74db154	09468cce-2349-47f0-b5a9-5214ac89349e	Integrated Daemon API Key	2025-12-31 20:29:56.301839+00	2025-12-31 20:31:14.960125+00	2025-12-31 20:31:14.959528+00	\N	t	{}
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
65cd93c4-932d-40d5-abcb-7fe998e212a4	09468cce-2349-47f0-b5a9-5214ac89349e	c94b95d9-c039-4ef2-ba2d-4e001ac7c62e	Port	eb1b74db-2f0b-43b9-949e-1c0d85f31777	02958453-a9e2-4c6b-bcb6-aa53d149a31b	2025-12-31 20:29:56.49237+00	2025-12-31 20:29:56.49237+00
425b2c2a-0a2e-4334-8045-66f5826deaed	09468cce-2349-47f0-b5a9-5214ac89349e	c9d1ef90-9af0-4d02-858d-f5d34719c568	Port	60914760-e6c5-4157-b248-7d14f6facd1f	45fc0438-cbc8-4848-98eb-d6ae1589dde2	2025-12-31 20:30:24.078292+00	2025-12-31 20:30:24.078292+00
fd8a7a8a-c9f6-42f7-a9b3-dc6246fc7740	09468cce-2349-47f0-b5a9-5214ac89349e	2c72c664-a185-4fdf-8a5d-e84a0a6e48db	Port	67d67d65-bebb-4c8c-a44a-75fcef5db1aa	15f53393-f9b6-4933-860f-2f96d0ba519f	2025-12-31 20:30:38.356341+00	2025-12-31 20:30:38.356341+00
79772d27-05aa-4b9d-9cbe-d7e655f68590	09468cce-2349-47f0-b5a9-5214ac89349e	b16bb736-d39b-43e4-8dfd-7e1b377c9ddf	Port	52c4afa1-e390-4b7b-b944-abf3f7c3dd18	37c8d67e-90e4-4736-ad83-5c17851e76c6	2025-12-31 20:30:42.157489+00	2025-12-31 20:30:42.157489+00
9e50bda2-e1d1-4373-b88d-b9e496b6e246	09468cce-2349-47f0-b5a9-5214ac89349e	51aed64f-4678-4f54-9e5b-4222612802e1	Port	52c4afa1-e390-4b7b-b944-abf3f7c3dd18	1c0d266d-8bc8-420b-9793-f2c40838175f	2025-12-31 20:30:54.084488+00	2025-12-31 20:30:54.084488+00
f15f4ff6-7d61-435b-aa8a-846afa0a72e9	09468cce-2349-47f0-b5a9-5214ac89349e	6d7fbd5c-ca71-4c93-809b-83d7180f19f6	Port	faa1b4a5-cc50-442d-8e57-db3ad37b9cfb	64dc0fff-b8a0-4dd5-9f52-a99b4a4511de	2025-12-31 20:31:03.090624+00	2025-12-31 20:31:03.090624+00
c62d4f4b-38b5-4317-a58c-ad12fbba9907	09468cce-2349-47f0-b5a9-5214ac89349e	2bc94a4e-a462-459e-8ccf-4e5b4fabfa5f	Port	faa1b4a5-cc50-442d-8e57-db3ad37b9cfb	782aee8f-1c5b-4509-a237-57ab6641d9b9	2025-12-31 20:31:14.166144+00	2025-12-31 20:31:14.166144+00
bf00cf53-9912-43de-88c3-8e77fea77b95	09468cce-2349-47f0-b5a9-5214ac89349e	b2187116-8e8e-4cfa-afc6-82d93ce33734	Port	faa1b4a5-cc50-442d-8e57-db3ad37b9cfb	3b9b2aaf-5dbc-4585-9eef-f87030060050	2025-12-31 20:31:14.907263+00	2025-12-31 20:31:14.907263+00
56f96d29-e75a-4e79-9e52-4dc50034bb96	09468cce-2349-47f0-b5a9-5214ac89349e	0fa9a80e-37ab-4af6-a1cc-eb8c91644228	Port	faa1b4a5-cc50-442d-8e57-db3ad37b9cfb	a26428a4-4de9-4f30-870b-f521cd6ae2ec	2025-12-31 20:31:14.907612+00	2025-12-31 20:31:14.907612+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags, version, user_id) FROM stdin;
835cdd99-8e54-419f-830f-5d01e6afc1e6	09468cce-2349-47f0-b5a9-5214ac89349e	caa099fa-583c-4f6a-84f0-6ac1462fd408	2025-12-31 20:29:56.395355+00	2025-12-31 20:31:12.42799+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["334103f9-3e5b-44dd-b966-15c813a23d74"]}	2025-12-31 20:31:12.428631+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}	0.12.10	d74df551-c7b1-4828-b023-27742a1732f5
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
fa81c055-c4fd-4708-a2c8-9a7c72a2d539	09468cce-2349-47f0-b5a9-5214ac89349e	835cdd99-8e54-419f-830f-5d01e6afc1e6	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408"}	Self Report	2025-12-31 20:29:56.40032+00	2025-12-31 20:29:56.40032+00	{}
3e702f55-2606-4bb3-9a01-8a25033a60cb	09468cce-2349-47f0-b5a9-5214ac89349e	835cdd99-8e54-419f-830f-5d01e6afc1e6	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-31 20:29:56.406796+00	2025-12-31 20:29:56.406796+00	{}
90018f3b-232d-4ef5-8b46-c28dd9107775	09468cce-2349-47f0-b5a9-5214ac89349e	835cdd99-8e54-419f-830f-5d01e6afc1e6	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "session_id": "1d5d1340-1336-44b0-b0d6-feb5f36b4841", "started_at": "2025-12-31T20:29:56.406418373Z", "finished_at": "2025-12-31T20:29:56.524211446Z", "discovery_type": {"type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408"}}}	{"type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408"}	Self Report	2025-12-31 20:29:56.406418+00	2025-12-31 20:29:56.52711+00	{}
8cd35c0a-a486-41aa-93c8-51415535c151	09468cce-2349-47f0-b5a9-5214ac89349e	835cdd99-8e54-419f-830f-5d01e6afc1e6	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "session_id": "7d04da8b-47d8-4e41-9625-562ad61109fa", "started_at": "2025-12-31T20:29:56.537196589Z", "finished_at": "2025-12-31T20:31:14.957661520Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-31 20:29:56.537196+00	2025-12-31 20:31:14.959811+00	{}
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
cca7f27f-5726-4f51-964e-14a6d06a8569	09468cce-2349-47f0-b5a9-5214ac89349e		\N	2025-12-31 20:31:14.973217+00	2025-12-31 20:31:14.973217+00	{"type": "Manual"}	Yellow	"SmoothStep"	{}	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
caa099fa-583c-4f6a-84f0-6ac1462fd408	09468cce-2349-47f0-b5a9-5214ac89349e	scanopy-daemon	cb159094c827	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T20:29:56.492349803Z", "type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6"}]}	null	2025-12-31 20:29:56.391123+00	2025-12-31 20:29:56.500319+00	f	{}
80deca24-e8db-449c-b6d3-c532109c26e6	09468cce-2349-47f0-b5a9-5214ac89349e	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T20:30:09.208204214Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-31 20:30:09.208205+00	2025-12-31 20:30:09.208205+00	f	{}
50359b95-892a-4ef3-a3c5-b34332ae09d3	09468cce-2349-47f0-b5a9-5214ac89349e	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T20:30:24.154036831Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-31 20:30:24.154038+00	2025-12-31 20:30:24.154038+00	f	{}
fafa3706-15a5-4b77-ac1d-1fa53bc738cc	09468cce-2349-47f0-b5a9-5214ac89349e	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T20:30:39.154026412Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-31 20:30:39.154027+00	2025-12-31 20:30:39.154027+00	f	{}
69dceea5-48d9-4f79-83d4-b6540f9df586	09468cce-2349-47f0-b5a9-5214ac89349e	runnervmh13bl	runnervmh13bl	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T20:31:00.141318150Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-31 20:31:00.141319+00	2025-12-31 20:31:00.141319+00	f	{}
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
eb1b74db-2f0b-43b9-949e-1c0d85f31777	09468cce-2349-47f0-b5a9-5214ac89349e	caa099fa-583c-4f6a-84f0-6ac1462fd408	334103f9-3e5b-44dd-b966-15c813a23d74	172.25.0.4	ce:1e:86:37:b0:aa	eth0	0	2025-12-31 20:29:56.406568+00	2025-12-31 20:29:56.406568+00
60914760-e6c5-4157-b248-7d14f6facd1f	09468cce-2349-47f0-b5a9-5214ac89349e	80deca24-e8db-449c-b6d3-c532109c26e6	334103f9-3e5b-44dd-b966-15c813a23d74	172.25.0.6	ce:38:0c:48:cd:94	\N	0	2025-12-31 20:30:09.208173+00	2025-12-31 20:30:09.208173+00
67d67d65-bebb-4c8c-a44a-75fcef5db1aa	09468cce-2349-47f0-b5a9-5214ac89349e	50359b95-892a-4ef3-a3c5-b34332ae09d3	334103f9-3e5b-44dd-b966-15c813a23d74	172.25.0.3	ee:6a:ea:7f:e8:6e	\N	0	2025-12-31 20:30:24.154002+00	2025-12-31 20:30:24.154002+00
52c4afa1-e390-4b7b-b944-abf3f7c3dd18	09468cce-2349-47f0-b5a9-5214ac89349e	fafa3706-15a5-4b77-ac1d-1fa53bc738cc	334103f9-3e5b-44dd-b966-15c813a23d74	172.25.0.5	f2:75:45:c1:f4:8b	\N	0	2025-12-31 20:30:39.153996+00	2025-12-31 20:30:39.153996+00
faa1b4a5-cc50-442d-8e57-db3ad37b9cfb	09468cce-2349-47f0-b5a9-5214ac89349e	69dceea5-48d9-4f79-83d4-b6540f9df586	334103f9-3e5b-44dd-b966-15c813a23d74	172.25.0.1	76:1d:52:be:80:27	\N	0	2025-12-31 20:31:00.141284+00	2025-12-31 20:31:00.141284+00
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
09468cce-2349-47f0-b5a9-5214ac89349e	My Network	2025-12-31 20:29:56.287812+00	2025-12-31 20:29:56.287812+00	08e06483-848c-4172-9e05-b82286a80cbb	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
08e06483-848c-4172-9e05-b82286a80cbb	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-31 20:29:56.28178+00	2025-12-31 20:31:15.719831+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
02958453-a9e2-4c6b-bcb6-aa53d149a31b	09468cce-2349-47f0-b5a9-5214ac89349e	caa099fa-583c-4f6a-84f0-6ac1462fd408	60073	Tcp	Custom	2025-12-31 20:29:56.492095+00	2025-12-31 20:29:56.492095+00
45fc0438-cbc8-4848-98eb-d6ae1589dde2	09468cce-2349-47f0-b5a9-5214ac89349e	80deca24-e8db-449c-b6d3-c532109c26e6	5432	Tcp	PostgreSQL	2025-12-31 20:30:24.078281+00	2025-12-31 20:30:24.078281+00
15f53393-f9b6-4933-860f-2f96d0ba519f	09468cce-2349-47f0-b5a9-5214ac89349e	50359b95-892a-4ef3-a3c5-b34332ae09d3	60072	Tcp	Custom	2025-12-31 20:30:38.35633+00	2025-12-31 20:30:38.35633+00
37c8d67e-90e4-4736-ad83-5c17851e76c6	09468cce-2349-47f0-b5a9-5214ac89349e	fafa3706-15a5-4b77-ac1d-1fa53bc738cc	8123	Tcp	Custom	2025-12-31 20:30:42.157478+00	2025-12-31 20:30:42.157478+00
1c0d266d-8bc8-420b-9793-f2c40838175f	09468cce-2349-47f0-b5a9-5214ac89349e	fafa3706-15a5-4b77-ac1d-1fa53bc738cc	18555	Tcp	Custom	2025-12-31 20:30:54.084475+00	2025-12-31 20:30:54.084475+00
64dc0fff-b8a0-4dd5-9f52-a99b4a4511de	09468cce-2349-47f0-b5a9-5214ac89349e	69dceea5-48d9-4f79-83d4-b6540f9df586	8123	Tcp	Custom	2025-12-31 20:31:03.090614+00	2025-12-31 20:31:03.090614+00
782aee8f-1c5b-4509-a237-57ab6641d9b9	09468cce-2349-47f0-b5a9-5214ac89349e	69dceea5-48d9-4f79-83d4-b6540f9df586	60072	Tcp	Custom	2025-12-31 20:31:14.166133+00	2025-12-31 20:31:14.166133+00
3b9b2aaf-5dbc-4585-9eef-f87030060050	09468cce-2349-47f0-b5a9-5214ac89349e	69dceea5-48d9-4f79-83d4-b6540f9df586	22	Tcp	Ssh	2025-12-31 20:31:14.907252+00	2025-12-31 20:31:14.907252+00
a26428a4-4de9-4f30-870b-f521cd6ae2ec	09468cce-2349-47f0-b5a9-5214ac89349e	69dceea5-48d9-4f79-83d4-b6540f9df586	5435	Tcp	Custom	2025-12-31 20:31:14.907609+00	2025-12-31 20:31:14.907609+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, tags) FROM stdin;
c94b95d9-c039-4ef2-ba2d-4e001ac7c62e	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:29:56.492374+00	2025-12-31 20:29:56.492374+00	Scanopy Daemon	caa099fa-583c-4f6a-84f0-6ac1462fd408	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-31T20:29:56.492373265Z", "type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6"}]}	{}
c9d1ef90-9af0-4d02-858d-f5d34719c568	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:30:24.078296+00	2025-12-31 20:30:24.078296+00	PostgreSQL	80deca24-e8db-449c-b6d3-c532109c26e6	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T20:30:24.078277127Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2c72c664-a185-4fdf-8a5d-e84a0a6e48db	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:30:38.356344+00	2025-12-31 20:30:38.356344+00	Scanopy Server	50359b95-892a-4ef3-a3c5-b34332ae09d3	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T20:30:38.356324372Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b16bb736-d39b-43e4-8dfd-7e1b377c9ddf	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:30:42.157493+00	2025-12-31 20:30:42.157493+00	Home Assistant	fafa3706-15a5-4b77-ac1d-1fa53bc738cc	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T20:30:42.157473391Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
51aed64f-4678-4f54-9e5b-4222612802e1	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:30:54.084492+00	2025-12-31 20:30:54.084492+00	Unclaimed Open Ports	fafa3706-15a5-4b77-ac1d-1fa53bc738cc	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T20:30:54.084470495Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
6d7fbd5c-ca71-4c93-809b-83d7180f19f6	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:31:03.090628+00	2025-12-31 20:31:03.090628+00	Home Assistant	69dceea5-48d9-4f79-83d4-b6540f9df586	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T20:31:03.090608861Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2bc94a4e-a462-459e-8ccf-4e5b4fabfa5f	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:31:14.166147+00	2025-12-31 20:31:14.166147+00	Scanopy Server	69dceea5-48d9-4f79-83d4-b6540f9df586	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T20:31:14.166128154Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b2187116-8e8e-4cfa-afc6-82d93ce33734	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:31:14.907278+00	2025-12-31 20:31:14.907278+00	SSH	69dceea5-48d9-4f79-83d4-b6540f9df586	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T20:31:14.907248133Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0fa9a80e-37ab-4af6-a1cc-eb8c91644228	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:31:14.907613+00	2025-12-31 20:31:14.907613+00	Unclaimed Open Ports	69dceea5-48d9-4f79-83d4-b6540f9df586	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T20:31:14.907608158Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
8449453c-fcff-47fe-8c63-30e6309d7016	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:29:56.289208+00	2025-12-31 20:29:56.289208+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}	{}
b3a79b3f-64c7-4baa-a495-9ac7e1a31ae5	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:29:56.289211+00	2025-12-31 20:29:56.289211+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}	{}
334103f9-3e5b-44dd-b966-15c813a23d74	09468cce-2349-47f0-b5a9-5214ac89349e	2025-12-31 20:29:56.406547+00	2025-12-31 20:29:56.406547+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2025-12-31T20:29:56.406545980Z", "type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
a1bc95c4-29ed-425a-8893-d90f2c059855	08e06483-848c-4172-9e05-b82286a80cbb	New Tag	\N	2025-12-31 20:31:14.983178+00	2025-12-31 20:31:14.983178+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
e90d959f-288f-4928-a431-68fc3a062c2c	09468cce-2349-47f0-b5a9-5214ac89349e	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "caa099fa-583c-4f6a-84f0-6ac1462fd408", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T20:29:56.492349803Z", "type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6"}]}, "hostname": "cb159094c827", "created_at": "2025-12-31T20:29:56.391123Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:29:56.500319Z", "description": null, "virtualization": null}, {"id": "80deca24-e8db-449c-b6d3-c532109c26e6", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T20:30:09.208204214Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2025-12-31T20:30:09.208205Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:30:09.208205Z", "description": null, "virtualization": null}, {"id": "50359b95-892a-4ef3-a3c5-b34332ae09d3", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T20:30:24.154036831Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2025-12-31T20:30:24.154038Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:30:24.154038Z", "description": null, "virtualization": null}, {"id": "fafa3706-15a5-4b77-ac1d-1fa53bc738cc", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T20:30:39.154026412Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2025-12-31T20:30:39.154027Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:30:39.154027Z", "description": null, "virtualization": null}, {"id": "69dceea5-48d9-4f79-83d4-b6540f9df586", "name": "runnervmh13bl", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T20:31:00.141318150Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmh13bl", "created_at": "2025-12-31T20:31:00.141319Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:31:00.141319Z", "description": null, "virtualization": null}]	[{"id": "8449453c-fcff-47fe-8c63-30e6309d7016", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-31T20:29:56.289208Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:29:56.289208Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "b3a79b3f-64c7-4baa-a495-9ac7e1a31ae5", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-31T20:29:56.289211Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:29:56.289211Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "334103f9-3e5b-44dd-b966-15c813a23d74", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T20:29:56.406545980Z", "type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6"}]}, "created_at": "2025-12-31T20:29:56.406547Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:29:56.406547Z", "description": null, "subnet_type": "Lan"}]	[{"id": "c94b95d9-c039-4ef2-ba2d-4e001ac7c62e", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-31T20:29:56.492373265Z", "type": "SelfReport", "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6"}]}, "host_id": "caa099fa-583c-4f6a-84f0-6ac1462fd408", "bindings": [{"id": "65cd93c4-932d-40d5-abcb-7fe998e212a4", "type": "Port", "port_id": "02958453-a9e2-4c6b-bcb6-aa53d149a31b", "created_at": "2025-12-31T20:29:56.492370Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "c94b95d9-c039-4ef2-ba2d-4e001ac7c62e", "updated_at": "2025-12-31T20:29:56.492370Z", "interface_id": "eb1b74db-2f0b-43b9-949e-1c0d85f31777"}], "created_at": "2025-12-31T20:29:56.492374Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:29:56.492374Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "c9d1ef90-9af0-4d02-858d-f5d34719c568", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T20:30:24.078277127Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "80deca24-e8db-449c-b6d3-c532109c26e6", "bindings": [{"id": "425b2c2a-0a2e-4334-8045-66f5826deaed", "type": "Port", "port_id": "45fc0438-cbc8-4848-98eb-d6ae1589dde2", "created_at": "2025-12-31T20:30:24.078292Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "c9d1ef90-9af0-4d02-858d-f5d34719c568", "updated_at": "2025-12-31T20:30:24.078292Z", "interface_id": "60914760-e6c5-4157-b248-7d14f6facd1f"}], "created_at": "2025-12-31T20:30:24.078296Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:30:24.078296Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "2c72c664-a185-4fdf-8a5d-e84a0a6e48db", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T20:30:38.356324372Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "50359b95-892a-4ef3-a3c5-b34332ae09d3", "bindings": [{"id": "fd8a7a8a-c9f6-42f7-a9b3-dc6246fc7740", "type": "Port", "port_id": "15f53393-f9b6-4933-860f-2f96d0ba519f", "created_at": "2025-12-31T20:30:38.356341Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "2c72c664-a185-4fdf-8a5d-e84a0a6e48db", "updated_at": "2025-12-31T20:30:38.356341Z", "interface_id": "67d67d65-bebb-4c8c-a44a-75fcef5db1aa"}], "created_at": "2025-12-31T20:30:38.356344Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:30:38.356344Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "b16bb736-d39b-43e4-8dfd-7e1b377c9ddf", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T20:30:42.157473391Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "fafa3706-15a5-4b77-ac1d-1fa53bc738cc", "bindings": [{"id": "79772d27-05aa-4b9d-9cbe-d7e655f68590", "type": "Port", "port_id": "37c8d67e-90e4-4736-ad83-5c17851e76c6", "created_at": "2025-12-31T20:30:42.157489Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "b16bb736-d39b-43e4-8dfd-7e1b377c9ddf", "updated_at": "2025-12-31T20:30:42.157489Z", "interface_id": "52c4afa1-e390-4b7b-b944-abf3f7c3dd18"}], "created_at": "2025-12-31T20:30:42.157493Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:30:42.157493Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "51aed64f-4678-4f54-9e5b-4222612802e1", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T20:30:54.084470495Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "fafa3706-15a5-4b77-ac1d-1fa53bc738cc", "bindings": [{"id": "9e50bda2-e1d1-4373-b88d-b9e496b6e246", "type": "Port", "port_id": "1c0d266d-8bc8-420b-9793-f2c40838175f", "created_at": "2025-12-31T20:30:54.084488Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "51aed64f-4678-4f54-9e5b-4222612802e1", "updated_at": "2025-12-31T20:30:54.084488Z", "interface_id": "52c4afa1-e390-4b7b-b944-abf3f7c3dd18"}], "created_at": "2025-12-31T20:30:54.084492Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:30:54.084492Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "6d7fbd5c-ca71-4c93-809b-83d7180f19f6", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T20:31:03.090608861Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "69dceea5-48d9-4f79-83d4-b6540f9df586", "bindings": [{"id": "f15f4ff6-7d61-435b-aa8a-846afa0a72e9", "type": "Port", "port_id": "64dc0fff-b8a0-4dd5-9f52-a99b4a4511de", "created_at": "2025-12-31T20:31:03.090624Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "6d7fbd5c-ca71-4c93-809b-83d7180f19f6", "updated_at": "2025-12-31T20:31:03.090624Z", "interface_id": "faa1b4a5-cc50-442d-8e57-db3ad37b9cfb"}], "created_at": "2025-12-31T20:31:03.090628Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:31:03.090628Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "2bc94a4e-a462-459e-8ccf-4e5b4fabfa5f", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T20:31:14.166128154Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "69dceea5-48d9-4f79-83d4-b6540f9df586", "bindings": [{"id": "c62d4f4b-38b5-4317-a58c-ad12fbba9907", "type": "Port", "port_id": "782aee8f-1c5b-4509-a237-57ab6641d9b9", "created_at": "2025-12-31T20:31:14.166144Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "2bc94a4e-a462-459e-8ccf-4e5b4fabfa5f", "updated_at": "2025-12-31T20:31:14.166144Z", "interface_id": "faa1b4a5-cc50-442d-8e57-db3ad37b9cfb"}], "created_at": "2025-12-31T20:31:14.166147Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:31:14.166147Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "b2187116-8e8e-4cfa-afc6-82d93ce33734", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T20:31:14.907248133Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "69dceea5-48d9-4f79-83d4-b6540f9df586", "bindings": [{"id": "bf00cf53-9912-43de-88c3-8e77fea77b95", "type": "Port", "port_id": "3b9b2aaf-5dbc-4585-9eef-f87030060050", "created_at": "2025-12-31T20:31:14.907263Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "b2187116-8e8e-4cfa-afc6-82d93ce33734", "updated_at": "2025-12-31T20:31:14.907263Z", "interface_id": "faa1b4a5-cc50-442d-8e57-db3ad37b9cfb"}], "created_at": "2025-12-31T20:31:14.907278Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:31:14.907278Z", "virtualization": null, "service_definition": "SSH"}, {"id": "0fa9a80e-37ab-4af6-a1cc-eb8c91644228", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T20:31:14.907608158Z", "type": "Network", "daemon_id": "835cdd99-8e54-419f-830f-5d01e6afc1e6", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "69dceea5-48d9-4f79-83d4-b6540f9df586", "bindings": [{"id": "56f96d29-e75a-4e79-9e52-4dc50034bb96", "type": "Port", "port_id": "a26428a4-4de9-4f30-870b-f521cd6ae2ec", "created_at": "2025-12-31T20:31:14.907612Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "service_id": "0fa9a80e-37ab-4af6-a1cc-eb8c91644228", "updated_at": "2025-12-31T20:31:14.907612Z", "interface_id": "faa1b4a5-cc50-442d-8e57-db3ad37b9cfb"}], "created_at": "2025-12-31T20:31:14.907613Z", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:31:14.907613Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "cca7f27f-5726-4f51-964e-14a6d06a8569", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2025-12-31T20:31:14.973217Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "09468cce-2349-47f0-b5a9-5214ac89349e", "updated_at": "2025-12-31T20:31:14.973217Z", "binding_ids": [], "description": null}]	t	2025-12-31 20:29:56.300083+00	f	\N	\N	{f94fa0fb-e10d-4b0c-aa0e-76777202fb63,228852ed-f621-4178-b69e-ce50330ad564,144fe140-fc97-496e-89eb-8828a3df143e}	{6f20f859-1fc5-4434-8528-a9ba9f009620}	{40bfb4c9-7eea-4e0c-96dc-a531b6bbfcbf}	{4b1e1390-3bff-4b2a-a682-94e23719f254}	\N	2025-12-31 20:29:56.292997+00	2025-12-31 20:31:16.543879+00	{}	[]	{}	[]	{}	[]	{}
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
d74df551-c7b1-4828-b023-27742a1732f5	2025-12-31 20:29:56.284848+00	2025-12-31 20:29:56.284848+00	$argon2id$v=19$m=19456,t=2,p=1$IyDQPyiLt4AyFCQKlGKdRg$es5EJyNrDvXVwfmfu+os/mt/U2e3z+569nOyPRX3XF8	\N	\N	\N	user@gmail.com	08e06483-848c-4172-9e05-b82286a80cbb	Owner	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
kt5SJ2a2tdLdfVNXNI_hyg	\\x93c410cae18f3457537dddd2b5b6662752de9281a7757365725f6964d92464373464663535312d633762312d343832382d623032332d32373734326131373332663599cd07ea1e141d38ce18a17781000000	2026-01-30 20:29:56.413235+00
oZDsLT7o2SF8LSEiy_eZ2Q	\\x93c410d999f7cb22212d7c21d9e83e2dec90a182ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92432306461623838612d366633662d343162372d616238302d313130616362313266656366a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92464373464663535312d633762312d343832382d623032332d32373734326131373332663599cd07ea1e141f0fce1aa58660000000	2026-01-30 20:31:15.447055+00
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

\unrestrict HLpT4lzdayJBqousixS313BUa04Gx1KghsJeaVzYxkm7wwDvkPmy8FaNdcUg1rK

