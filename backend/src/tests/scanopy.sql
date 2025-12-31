--
-- PostgreSQL database dump
--

\restrict NrpJiRPfJtguFyVkiPCt4TFJPI869nfabA1B6tMPYjBVke7gK2Zm5YQHnDP1wzw

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
20251006215000	users	2025-12-31 17:00:52.77963+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3869441
20251006215100	networks	2025-12-31 17:00:52.784853+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4938504
20251006215151	create hosts	2025-12-31 17:00:52.790124+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4084937
20251006215155	create subnets	2025-12-31 17:00:52.794574+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4335968
20251006215201	create groups	2025-12-31 17:00:52.799351+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4514391
20251006215204	create daemons	2025-12-31 17:00:52.804222+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4540791
20251006215212	create services	2025-12-31 17:00:52.80911+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4841604
20251029193448	user-auth	2025-12-31 17:00:52.814285+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6120562
20251030044828	daemon api	2025-12-31 17:00:52.820846+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1507849
20251030170438	host-hide	2025-12-31 17:00:52.82263+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1154827
20251102224919	create discovery	2025-12-31 17:00:52.824094+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10821903
20251106235621	normalize-daemon-cols	2025-12-31 17:00:52.835214+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1743888
20251107034459	api keys	2025-12-31 17:00:52.837369+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8669603
20251107222650	oidc-auth	2025-12-31 17:00:52.846369+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	28167259
20251110181948	orgs-billing	2025-12-31 17:00:52.874902+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10891813
20251113223656	group-enhancements	2025-12-31 17:00:52.886317+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1163202
20251117032720	daemon-mode	2025-12-31 17:00:52.88785+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1116175
20251118143058	set-default-plan	2025-12-31 17:00:52.889255+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1161500
20251118225043	save-topology	2025-12-31 17:00:52.890687+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9022983
20251123232748	network-permissions	2025-12-31 17:00:52.90013+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2753373
20251125001342	billing-updates	2025-12-31 17:00:52.903212+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	982875
20251128035448	org-onboarding-status	2025-12-31 17:00:52.904515+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1449016
20251129180942	nfs-consolidate	2025-12-31 17:00:52.906267+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1387752
20251206052641	discovery-progress	2025-12-31 17:00:52.908025+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1835548
20251206202200	plan-fix	2025-12-31 17:00:52.91014+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	906523
20251207061341	daemon-url	2025-12-31 17:00:52.911349+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2354257
20251210045929	tags	2025-12-31 17:00:52.914161+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8756984
20251210175035	terms	2025-12-31 17:00:52.923328+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	894571
20251213025048	hash-keys	2025-12-31 17:00:52.924514+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	10030627
20251214050638	scanopy	2025-12-31 17:00:52.934992+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1416916
20251215215724	topo-scanopy-fix	2025-12-31 17:00:52.936864+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	813169
20251217153736	category rename	2025-12-31 17:00:52.938055+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1708211
20251218053111	invite-persistence	2025-12-31 17:00:52.940082+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5158645
20251219211216	create shares	2025-12-31 17:00:52.945544+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6712256
20251220170928	permissions-cleanup	2025-12-31 17:00:52.952609+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1478892
20251220180000	commercial-to-community	2025-12-31 17:00:52.954452+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	1111737
20251221010000	cleanup subnet type	2025-12-31 17:00:52.9559+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	942581
20251221020000	remove host target	2025-12-31 17:00:52.957241+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	948842
20251221030000	user network access	2025-12-31 17:00:52.958465+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	6896361
20251221040000	interfaces table	2025-12-31 17:00:52.965701+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9638281
20251221050000	ports table	2025-12-31 17:00:52.97574+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	8757686
20251221060000	bindings table	2025-12-31 17:00:52.984789+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	10561106
20251221070000	group bindings	2025-12-31 17:00:52.995675+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6309484
20251222020000	tag cascade delete	2025-12-31 17:00:53.002543+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1460588
20251223232524	network remove default	2025-12-31 17:00:53.004307+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1881845
20251225100000	color enum	2025-12-31 17:00:53.006565+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1536361
20251227010000	topology snapshot migration	2025-12-31 17:00:53.008433+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4369904
20251230160000	daemon version and maintainer	2025-12-31 17:00:53.013169+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	2545913
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
61606d73-60c0-4e84-9cd4-5d0a21a95dda	e67896e6a4ca24a71472831d4bf8a0228000a7de659e89556a5b8608274ea9e2	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	Integrated Daemon API Key	2025-12-31 17:00:55.565489+00	2025-12-31 17:02:13.537037+00	2025-12-31 17:02:13.536049+00	\N	t	{}
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
57cb7176-8be2-443a-ac68-fb1ec41df25e	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	092c70e8-6be8-4e7f-8f73-d1045b3d835d	Port	004a39de-3222-4b8b-afef-ccbc2bf2faf2	b0a08fde-7281-4f76-b9b3-d182cd376f3f	2025-12-31 17:00:55.771533+00	2025-12-31 17:00:55.771533+00
26aa951d-6458-4b6d-9af2-e81aeb9320a2	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	b4457004-756e-48d0-ae68-caf435176e8f	Port	736d1c4f-f18e-46e9-84f5-247025b24b36	483aa59d-fcf6-4538-9596-4f215d961757	2025-12-31 17:01:22.825984+00	2025-12-31 17:01:22.825984+00
2d05a1c0-5ffa-42e8-99a5-43b35d3c92ab	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	d4a0187f-6168-4ff8-b59f-87753ade8be5	Port	a5c67d50-ec31-4432-b137-07424c7831e2	da8867e7-97a4-4ea1-a8cd-235364f9901c	2025-12-31 17:01:41.727623+00	2025-12-31 17:01:41.727623+00
15bd926b-f441-409b-bc5a-a10d2943640e	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	d4a0187f-6168-4ff8-b59f-87753ade8be5	Port	a5c67d50-ec31-4432-b137-07424c7831e2	dfb0c783-9045-430f-9dbb-42653317c5a9	2025-12-31 17:01:41.727624+00	2025-12-31 17:01:41.727624+00
d6b9cdbd-6504-4e7d-b2e3-33a140498875	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	223c9fb6-974a-457d-82f7-1ba24c450df0	Port	9711e53e-0757-45a3-997c-d2a03618b2c1	14070f7b-a9da-4416-b208-7264bcdd688e	2025-12-31 17:01:55.614149+00	2025-12-31 17:01:55.614149+00
970a99e6-5bd2-44eb-aeba-de70761d18c2	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	27f569e2-ed11-4b37-b79a-f608ec56f1c3	Port	5f68cae9-f36f-4f27-a04f-97213033e416	8244d251-d624-46f3-9257-4358de7035ea	2025-12-31 17:02:06.587924+00	2025-12-31 17:02:06.587924+00
f787c16e-a7b8-4d84-8c33-baa6bad8240b	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	aef4993e-b1f0-4ba8-9ed6-64bd61afeca9	Port	5f68cae9-f36f-4f27-a04f-97213033e416	59b75194-6861-4c73-a06b-a21042b4c9a4	2025-12-31 17:02:08.651265+00	2025-12-31 17:02:08.651265+00
ea10f9d7-5d81-4401-82b1-c20f8f45ae48	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	b3063d5d-b5bf-458f-96cd-a731a8113527	Port	5f68cae9-f36f-4f27-a04f-97213033e416	36c998e9-9f19-436f-b969-6aae5c49d6fa	2025-12-31 17:02:13.479018+00	2025-12-31 17:02:13.479018+00
226072a3-c35e-4180-af14-367436a39f93	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	550c565d-8bac-4a93-ad52-7d7248af7abd	Port	5f68cae9-f36f-4f27-a04f-97213033e416	8c986fc5-94a3-4568-9923-ed124b9aa1a2	2025-12-31 17:02:13.479207+00	2025-12-31 17:02:13.479207+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags, version, user_id) FROM stdin;
53c8bd80-939c-45f9-a9ea-56f17fe17883	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	b4a6a2c8-5a65-4c80-8bbb-13d2a9402942	2025-12-31 17:00:55.694162+00	2025-12-31 17:02:09.898327+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["dd4bf584-9b96-456a-8613-71046f56c6db"]}	2025-12-31 17:02:09.898846+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}	0.12.9	80033033-480f-435b-b8e1-14a710c50306
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
7f65b55f-d866-4cdb-a962-1f5551e088ae	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	53c8bd80-939c-45f9-a9ea-56f17fe17883	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942"}	Self Report	2025-12-31 17:00:55.702911+00	2025-12-31 17:00:55.702911+00	{}
93947c6b-54aa-4a4d-a089-e38411e2953e	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	53c8bd80-939c-45f9-a9ea-56f17fe17883	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-31 17:00:55.71105+00	2025-12-31 17:00:55.71105+00	{}
ad27b050-ba66-468b-93d9-6e6b05af9b79	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	53c8bd80-939c-45f9-a9ea-56f17fe17883	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "session_id": "190b2b82-cde0-4db4-8cce-ee976b62d1f0", "started_at": "2025-12-31T17:00:55.710476697Z", "finished_at": "2025-12-31T17:00:55.799408054Z", "discovery_type": {"type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942"}}}	{"type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942"}	Self Report	2025-12-31 17:00:55.710476+00	2025-12-31 17:00:55.80216+00	{}
8fd94035-21a8-41fc-869f-94519cdde085	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	53c8bd80-939c-45f9-a9ea-56f17fe17883	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "session_id": "83b1a04b-b184-413d-8738-57f9b24639b0", "started_at": "2025-12-31T17:00:55.810535938Z", "finished_at": "2025-12-31T17:02:13.533989117Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-31 17:00:55.810535+00	2025-12-31 17:02:13.536301+00	{}
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
21417563-0172-442f-9e8b-65c3ae82a8c4	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1		\N	2025-12-31 17:02:13.55089+00	2025-12-31 17:02:13.55089+00	{"type": "Manual"}	Yellow	"SmoothStep"	{}	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
b4a6a2c8-5a65-4c80-8bbb-13d2a9402942	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	scanopy-daemon	cea71c093706	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T17:00:55.771519225Z", "type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883"}]}	null	2025-12-31 17:00:55.688085+00	2025-12-31 17:00:55.780042+00	f	{}
ddfc7a0e-6060-4808-8c2d-d323dc48aeb7	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T17:01:13.748811640Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-31 17:01:13.748812+00	2025-12-31 17:01:13.748812+00	f	{}
4fea96d7-3030-49b5-8e48-54f8bb11ac4d	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T17:01:27.782513126Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-31 17:01:27.782514+00	2025-12-31 17:01:27.782514+00	f	{}
6b21308b-3f3b-4e44-b076-5f9d6444ebb6	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T17:01:41.733683111Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-31 17:01:41.733684+00	2025-12-31 17:01:41.733684+00	f	{}
670fb639-b882-4576-9e6d-47c253314b6c	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	runnervmh13bl	runnervmh13bl	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-31T17:01:59.673777254Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-31 17:01:59.673778+00	2025-12-31 17:01:59.673778+00	f	{}
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
004a39de-3222-4b8b-afef-ccbc2bf2faf2	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	b4a6a2c8-5a65-4c80-8bbb-13d2a9402942	dd4bf584-9b96-456a-8613-71046f56c6db	172.25.0.4	1a:a3:35:cc:82:4e	eth0	0	2025-12-31 17:00:55.710635+00	2025-12-31 17:00:55.710635+00
736d1c4f-f18e-46e9-84f5-247025b24b36	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	ddfc7a0e-6060-4808-8c2d-d323dc48aeb7	dd4bf584-9b96-456a-8613-71046f56c6db	172.25.0.3	8e:57:c7:29:6a:81	\N	0	2025-12-31 17:01:13.748794+00	2025-12-31 17:01:13.748794+00
a5c67d50-ec31-4432-b137-07424c7831e2	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	4fea96d7-3030-49b5-8e48-54f8bb11ac4d	dd4bf584-9b96-456a-8613-71046f56c6db	172.25.0.5	76:7e:fc:20:f4:c6	\N	0	2025-12-31 17:01:27.782493+00	2025-12-31 17:01:27.782493+00
9711e53e-0757-45a3-997c-d2a03618b2c1	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	6b21308b-3f3b-4e44-b076-5f9d6444ebb6	dd4bf584-9b96-456a-8613-71046f56c6db	172.25.0.6	f2:bb:ba:1b:58:62	\N	0	2025-12-31 17:01:41.73366+00	2025-12-31 17:01:41.73366+00
5f68cae9-f36f-4f27-a04f-97213033e416	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	670fb639-b882-4576-9e6d-47c253314b6c	dd4bf584-9b96-456a-8613-71046f56c6db	172.25.0.1	a2:b9:0d:67:c2:41	\N	0	2025-12-31 17:01:59.673759+00	2025-12-31 17:01:59.673759+00
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
a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	My Network	2025-12-31 17:00:55.549971+00	2025-12-31 17:00:55.549971+00	d012a792-3ff7-4db4-8422-4558bb77542a	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
d012a792-3ff7-4db4-8422-4558bb77542a	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-31 17:00:55.544077+00	2025-12-31 17:02:14.417246+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
b0a08fde-7281-4f76-b9b3-d182cd376f3f	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	b4a6a2c8-5a65-4c80-8bbb-13d2a9402942	60073	Tcp	Custom	2025-12-31 17:00:55.771383+00	2025-12-31 17:00:55.771383+00
483aa59d-fcf6-4538-9596-4f215d961757	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	ddfc7a0e-6060-4808-8c2d-d323dc48aeb7	60072	Tcp	Custom	2025-12-31 17:01:22.825975+00	2025-12-31 17:01:22.825975+00
da8867e7-97a4-4ea1-a8cd-235364f9901c	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	4fea96d7-3030-49b5-8e48-54f8bb11ac4d	8123	Tcp	Custom	2025-12-31 17:01:41.727612+00	2025-12-31 17:01:41.727612+00
dfb0c783-9045-430f-9dbb-42653317c5a9	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	4fea96d7-3030-49b5-8e48-54f8bb11ac4d	18555	Tcp	Custom	2025-12-31 17:01:41.727618+00	2025-12-31 17:01:41.727618+00
14070f7b-a9da-4416-b208-7264bcdd688e	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	6b21308b-3f3b-4e44-b076-5f9d6444ebb6	5432	Tcp	PostgreSQL	2025-12-31 17:01:55.61414+00	2025-12-31 17:01:55.61414+00
8244d251-d624-46f3-9257-4358de7035ea	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	670fb639-b882-4576-9e6d-47c253314b6c	8123	Tcp	Custom	2025-12-31 17:02:06.587912+00	2025-12-31 17:02:06.587912+00
59b75194-6861-4c73-a06b-a21042b4c9a4	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	670fb639-b882-4576-9e6d-47c253314b6c	60072	Tcp	Custom	2025-12-31 17:02:08.651255+00	2025-12-31 17:02:08.651255+00
36c998e9-9f19-436f-b969-6aae5c49d6fa	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	670fb639-b882-4576-9e6d-47c253314b6c	22	Tcp	Ssh	2025-12-31 17:02:13.479007+00	2025-12-31 17:02:13.479007+00
8c986fc5-94a3-4568-9923-ed124b9aa1a2	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	670fb639-b882-4576-9e6d-47c253314b6c	5435	Tcp	Custom	2025-12-31 17:02:13.479203+00	2025-12-31 17:02:13.479203+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, tags) FROM stdin;
092c70e8-6be8-4e7f-8f73-d1045b3d835d	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:00:55.771536+00	2025-12-31 17:00:55.771536+00	Scanopy Daemon	b4a6a2c8-5a65-4c80-8bbb-13d2a9402942	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-31T17:00:55.771535465Z", "type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883"}]}	{}
b4457004-756e-48d0-ae68-caf435176e8f	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:01:22.825987+00	2025-12-31 17:01:22.825987+00	Scanopy Server	ddfc7a0e-6060-4808-8c2d-d323dc48aeb7	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T17:01:22.825970642Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
d4a0187f-6168-4ff8-b59f-87753ade8be5	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:01:41.727627+00	2025-12-31 17:01:41.727627+00	Unclaimed Open Ports	4fea96d7-3030-49b5-8e48-54f8bb11ac4d	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T17:01:41.727608040Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
223c9fb6-974a-457d-82f7-1ba24c450df0	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:01:55.614153+00	2025-12-31 17:01:55.614153+00	PostgreSQL	6b21308b-3f3b-4e44-b076-5f9d6444ebb6	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T17:01:55.614136030Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
27f569e2-ed11-4b37-b79a-f608ec56f1c3	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:02:06.587928+00	2025-12-31 17:02:06.587928+00	Home Assistant	670fb639-b882-4576-9e6d-47c253314b6c	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T17:02:06.587906475Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
aef4993e-b1f0-4ba8-9ed6-64bd61afeca9	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:02:08.651268+00	2025-12-31 17:02:08.651268+00	Scanopy Server	670fb639-b882-4576-9e6d-47c253314b6c	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T17:02:08.651250428Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b3063d5d-b5bf-458f-96cd-a731a8113527	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:02:13.479022+00	2025-12-31 17:02:13.479022+00	SSH	670fb639-b882-4576-9e6d-47c253314b6c	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T17:02:13.479001425Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
550c565d-8bac-4a93-ad52-7d7248af7abd	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:02:13.47921+00	2025-12-31 17:02:13.47921+00	Unclaimed Open Ports	670fb639-b882-4576-9e6d-47c253314b6c	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T17:02:13.479201419Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
ffea6efc-9775-4d97-be89-7831800fdd22	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:00:55.551394+00	2025-12-31 17:00:55.551394+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}	{}
420a8255-f38f-44ff-9c6d-f54d856b8991	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:00:55.551398+00	2025-12-31 17:00:55.551398+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}	{}
dd4bf584-9b96-456a-8613-71046f56c6db	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	2025-12-31 17:00:55.710612+00	2025-12-31 17:00:55.710612+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2025-12-31T17:00:55.710611548Z", "type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
f2d259da-b418-49f0-9e23-dc140a50b6a3	d012a792-3ff7-4db4-8422-4558bb77542a	New Tag	\N	2025-12-31 17:02:13.561984+00	2025-12-31 17:02:13.561984+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
46ead807-2eba-412a-9ebe-eede6c2f887f	a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T17:00:55.771519225Z", "type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883"}]}, "hostname": "cea71c093706", "created_at": "2025-12-31T17:00:55.688085Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:00:55.780042Z", "description": null, "virtualization": null}, {"id": "ddfc7a0e-6060-4808-8c2d-d323dc48aeb7", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T17:01:13.748811640Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2025-12-31T17:01:13.748812Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:01:13.748812Z", "description": null, "virtualization": null}, {"id": "4fea96d7-3030-49b5-8e48-54f8bb11ac4d", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T17:01:27.782513126Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2025-12-31T17:01:27.782514Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:01:27.782514Z", "description": null, "virtualization": null}, {"id": "6b21308b-3f3b-4e44-b076-5f9d6444ebb6", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T17:01:41.733683111Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2025-12-31T17:01:41.733684Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:01:41.733684Z", "description": null, "virtualization": null}, {"id": "670fb639-b882-4576-9e6d-47c253314b6c", "name": "runnervmh13bl", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T17:01:59.673777254Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmh13bl", "created_at": "2025-12-31T17:01:59.673778Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:01:59.673778Z", "description": null, "virtualization": null}, {"id": "dc2371ca-c3e7-42f0-97e2-efc4d4e48779", "name": "Service Test Host", "tags": [], "hidden": false, "source": {"type": "Manual"}, "hostname": "service-test.local", "created_at": "2025-12-31T17:02:14.269505Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:02:14.269505Z", "description": null, "virtualization": null}]	[{"id": "ffea6efc-9775-4d97-be89-7831800fdd22", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-31T17:00:55.551394Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:00:55.551394Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "420a8255-f38f-44ff-9c6d-f54d856b8991", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-31T17:00:55.551398Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:00:55.551398Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "dd4bf584-9b96-456a-8613-71046f56c6db", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-31T17:00:55.710611548Z", "type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883"}]}, "created_at": "2025-12-31T17:00:55.710612Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:00:55.710612Z", "description": null, "subnet_type": "Lan"}]	[{"id": "092c70e8-6be8-4e7f-8f73-d1045b3d835d", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-31T17:00:55.771535465Z", "type": "SelfReport", "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883"}]}, "host_id": "b4a6a2c8-5a65-4c80-8bbb-13d2a9402942", "bindings": [{"id": "57cb7176-8be2-443a-ac68-fb1ec41df25e", "type": "Port", "port_id": "b0a08fde-7281-4f76-b9b3-d182cd376f3f", "created_at": "2025-12-31T17:00:55.771533Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "092c70e8-6be8-4e7f-8f73-d1045b3d835d", "updated_at": "2025-12-31T17:00:55.771533Z", "interface_id": "004a39de-3222-4b8b-afef-ccbc2bf2faf2"}], "created_at": "2025-12-31T17:00:55.771536Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:00:55.771536Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "b4457004-756e-48d0-ae68-caf435176e8f", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T17:01:22.825970642Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ddfc7a0e-6060-4808-8c2d-d323dc48aeb7", "bindings": [{"id": "26aa951d-6458-4b6d-9af2-e81aeb9320a2", "type": "Port", "port_id": "483aa59d-fcf6-4538-9596-4f215d961757", "created_at": "2025-12-31T17:01:22.825984Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "b4457004-756e-48d0-ae68-caf435176e8f", "updated_at": "2025-12-31T17:01:22.825984Z", "interface_id": "736d1c4f-f18e-46e9-84f5-247025b24b36"}], "created_at": "2025-12-31T17:01:22.825987Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:01:22.825987Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "d4a0187f-6168-4ff8-b59f-87753ade8be5", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T17:01:41.727608040Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "4fea96d7-3030-49b5-8e48-54f8bb11ac4d", "bindings": [{"id": "2d05a1c0-5ffa-42e8-99a5-43b35d3c92ab", "type": "Port", "port_id": "da8867e7-97a4-4ea1-a8cd-235364f9901c", "created_at": "2025-12-31T17:01:41.727623Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "d4a0187f-6168-4ff8-b59f-87753ade8be5", "updated_at": "2025-12-31T17:01:41.727623Z", "interface_id": "a5c67d50-ec31-4432-b137-07424c7831e2"}, {"id": "15bd926b-f441-409b-bc5a-a10d2943640e", "type": "Port", "port_id": "dfb0c783-9045-430f-9dbb-42653317c5a9", "created_at": "2025-12-31T17:01:41.727624Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "d4a0187f-6168-4ff8-b59f-87753ade8be5", "updated_at": "2025-12-31T17:01:41.727624Z", "interface_id": "a5c67d50-ec31-4432-b137-07424c7831e2"}], "created_at": "2025-12-31T17:01:41.727627Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:01:41.727627Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "223c9fb6-974a-457d-82f7-1ba24c450df0", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T17:01:55.614136030Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "6b21308b-3f3b-4e44-b076-5f9d6444ebb6", "bindings": [{"id": "d6b9cdbd-6504-4e7d-b2e3-33a140498875", "type": "Port", "port_id": "14070f7b-a9da-4416-b208-7264bcdd688e", "created_at": "2025-12-31T17:01:55.614149Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "223c9fb6-974a-457d-82f7-1ba24c450df0", "updated_at": "2025-12-31T17:01:55.614149Z", "interface_id": "9711e53e-0757-45a3-997c-d2a03618b2c1"}], "created_at": "2025-12-31T17:01:55.614153Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:01:55.614153Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "27f569e2-ed11-4b37-b79a-f608ec56f1c3", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T17:02:06.587906475Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "670fb639-b882-4576-9e6d-47c253314b6c", "bindings": [{"id": "970a99e6-5bd2-44eb-aeba-de70761d18c2", "type": "Port", "port_id": "8244d251-d624-46f3-9257-4358de7035ea", "created_at": "2025-12-31T17:02:06.587924Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "27f569e2-ed11-4b37-b79a-f608ec56f1c3", "updated_at": "2025-12-31T17:02:06.587924Z", "interface_id": "5f68cae9-f36f-4f27-a04f-97213033e416"}], "created_at": "2025-12-31T17:02:06.587928Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:02:06.587928Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "aef4993e-b1f0-4ba8-9ed6-64bd61afeca9", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-31T17:02:08.651250428Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "670fb639-b882-4576-9e6d-47c253314b6c", "bindings": [{"id": "f787c16e-a7b8-4d84-8c33-baa6bad8240b", "type": "Port", "port_id": "59b75194-6861-4c73-a06b-a21042b4c9a4", "created_at": "2025-12-31T17:02:08.651265Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "aef4993e-b1f0-4ba8-9ed6-64bd61afeca9", "updated_at": "2025-12-31T17:02:08.651265Z", "interface_id": "5f68cae9-f36f-4f27-a04f-97213033e416"}], "created_at": "2025-12-31T17:02:08.651268Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:02:08.651268Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "b3063d5d-b5bf-458f-96cd-a731a8113527", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T17:02:13.479001425Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "670fb639-b882-4576-9e6d-47c253314b6c", "bindings": [{"id": "ea10f9d7-5d81-4401-82b1-c20f8f45ae48", "type": "Port", "port_id": "36c998e9-9f19-436f-b969-6aae5c49d6fa", "created_at": "2025-12-31T17:02:13.479018Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "b3063d5d-b5bf-458f-96cd-a731a8113527", "updated_at": "2025-12-31T17:02:13.479018Z", "interface_id": "5f68cae9-f36f-4f27-a04f-97213033e416"}], "created_at": "2025-12-31T17:02:13.479022Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:02:13.479022Z", "virtualization": null, "service_definition": "SSH"}, {"id": "550c565d-8bac-4a93-ad52-7d7248af7abd", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-31T17:02:13.479201419Z", "type": "Network", "daemon_id": "53c8bd80-939c-45f9-a9ea-56f17fe17883", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "670fb639-b882-4576-9e6d-47c253314b6c", "bindings": [{"id": "226072a3-c35e-4180-af14-367436a39f93", "type": "Port", "port_id": "8c986fc5-94a3-4568-9923-ed124b9aa1a2", "created_at": "2025-12-31T17:02:13.479207Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "service_id": "550c565d-8bac-4a93-ad52-7d7248af7abd", "updated_at": "2025-12-31T17:02:13.479207Z", "interface_id": "5f68cae9-f36f-4f27-a04f-97213033e416"}], "created_at": "2025-12-31T17:02:13.479210Z", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:02:13.479210Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "21417563-0172-442f-9e8b-65c3ae82a8c4", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2025-12-31T17:02:13.550890Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "a0b4ebcf-1781-4ecd-8437-0c0f391ad1c1", "updated_at": "2025-12-31T17:02:13.550890Z", "binding_ids": [], "description": null}]	t	2025-12-31 17:00:55.563518+00	f	\N	\N	{acb70e7d-3ea5-4772-83e4-5d30e6de3e2d,dc2371ca-c3e7-42f0-97e2-efc4d4e48779,7fdc68d5-5950-448a-87e1-37757d2561db}	{38f0838e-2fd0-4365-915f-d6c528d8c482}	{5f05be15-b09b-4bd0-8f9c-93ee7bed98f3}	{1a423c89-c812-4793-bb83-1966e3d1a4d3}	\N	2025-12-31 17:00:55.555344+00	2025-12-31 17:02:15.304665+00	{}	[]	{}	[]	{}	[]	{}
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
80033033-480f-435b-b8e1-14a710c50306	2025-12-31 17:00:55.5469+00	2025-12-31 17:00:55.5469+00	$argon2id$v=19$m=19456,t=2,p=1$lMY7qCChre8C+81kWW4Siw$M3lrL00+ExotTF8Kgd9CKL+rlDRg0PbGm8o8hlv1gfw	\N	\N	\N	user@gmail.com	d012a792-3ff7-4db4-8422-4558bb77542a	Owner	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
sI1ZblNygdaZFRQDUQTnmg	\\x93c4109ae7045103141599d68172536e598db081a7757365725f6964d92438303033333033332d343830662d343335622d623865312d31346137313063353033303699cd07ea1e110037ce2ae3f2c0000000	2026-01-30 17:00:55.719581+00
fdFngTdy7Vpct_wYhg6wvA	\\x93c410bcb00e8618fcb75c5aed72378167d17d82a7757365725f6964d92438303033333033332d343830662d343335622d623865312d313461373130633530333036ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92465363964343064332d626435322d343264652d613435622d326438303231396661393761a86f72675f6e616d65af4d79204f7267616e697a6174696f6e99cd07ea1e11020ece09ae8d7a000000	2026-01-30 17:02:14.162434+00
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

\unrestrict NrpJiRPfJtguFyVkiPCt4TFJPI869nfabA1B6tMPYjBVke7gK2Zm5YQHnDP1wzw

