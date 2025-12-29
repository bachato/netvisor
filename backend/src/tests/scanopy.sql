--
-- PostgreSQL database dump
--

\restrict ZoyypC2yYralGLljuScqff2Impfx72R1uzL8658Z6hIEuc3NhaNcnRipGu577YL

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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
20251006215000	users	2025-12-29 15:53:17.280945+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3693006
20251006215100	networks	2025-12-29 15:53:17.285746+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4843432
20251006215151	create hosts	2025-12-29 15:53:17.290943+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3986183
20251006215155	create subnets	2025-12-29 15:53:17.29529+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4164425
20251006215201	create groups	2025-12-29 15:53:17.2998+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	5174529
20251006215204	create daemons	2025-12-29 15:53:17.305313+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4135922
20251006215212	create services	2025-12-29 15:53:17.309785+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4789651
20251029193448	user-auth	2025-12-29 15:53:17.314875+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6016929
20251030044828	daemon api	2025-12-29 15:53:17.321209+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1534170
20251030170438	host-hide	2025-12-29 15:53:17.323017+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1086926
20251102224919	create discovery	2025-12-29 15:53:17.324393+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10650981
20251106235621	normalize-daemon-cols	2025-12-29 15:53:17.335385+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1706683
20251107034459	api keys	2025-12-29 15:53:17.337406+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8514993
20251107222650	oidc-auth	2025-12-29 15:53:17.34624+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26818358
20251110181948	orgs-billing	2025-12-29 15:53:17.373407+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	12303712
20251113223656	group-enhancements	2025-12-29 15:53:17.386052+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1120519
20251117032720	daemon-mode	2025-12-29 15:53:17.387498+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1266372
20251118143058	set-default-plan	2025-12-29 15:53:17.389059+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1289184
20251118225043	save-topology	2025-12-29 15:53:17.390651+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	10025966
20251123232748	network-permissions	2025-12-29 15:53:17.401035+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	3027124
20251125001342	billing-updates	2025-12-29 15:53:17.404434+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	960131
20251128035448	org-onboarding-status	2025-12-29 15:53:17.405691+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1563595
20251129180942	nfs-consolidate	2025-12-29 15:53:17.407579+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1452748
20251206052641	discovery-progress	2025-12-29 15:53:17.409356+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1815395
20251206202200	plan-fix	2025-12-29 15:53:17.41147+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	2428568
20251207061341	daemon-url	2025-12-29 15:53:17.414264+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2646455
20251210045929	tags	2025-12-29 15:53:17.417246+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9853614
20251210175035	terms	2025-12-29 15:53:17.42749+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	971661
20251213025048	hash-keys	2025-12-29 15:53:17.428763+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9763657
20251214050638	scanopy	2025-12-29 15:53:17.438852+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1422282
20251215215724	topo-scanopy-fix	2025-12-29 15:53:17.440581+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	808978
20251217153736	category rename	2025-12-29 15:53:17.44168+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1737680
20251218053111	invite-persistence	2025-12-29 15:53:17.443709+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5296086
20251219211216	create shares	2025-12-29 15:53:17.449364+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6833392
20251220170928	permissions-cleanup	2025-12-29 15:53:17.456524+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1470272
20251220180000	commercial-to-community	2025-12-29 15:53:17.458307+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	868690
20251221010000	cleanup subnet type	2025-12-29 15:53:17.459469+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	917751
20251221020000	remove host target	2025-12-29 15:53:17.460678+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	1027095
20251221030000	user network access	2025-12-29 15:53:17.461996+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7047572
20251221040000	interfaces table	2025-12-29 15:53:17.469397+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9792469
20251221050000	ports table	2025-12-29 15:53:17.47952+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	8813505
20251221060000	bindings table	2025-12-29 15:53:17.488666+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	10924190
20251221070000	group bindings	2025-12-29 15:53:17.499965+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6441351
20251222020000	tag cascade delete	2025-12-29 15:53:17.506732+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1357321
20251223232524	network remove default	2025-12-29 15:53:17.508436+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1327515
20251225100000	color enum	2025-12-29 15:53:17.510069+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1350038
20251227010000	topology snapshot migration	2025-12-29 15:53:17.511718+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4437976
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
d705e39f-80ce-46c8-9d42-19b6168ed4fe	954c0898e18e6f6bcefa2814898111bbaf71070b796a87e04cf52697fa2d4ea1	f0379d72-158f-446f-a867-d3dc7ebaeb0c	Integrated Daemon API Key	2025-12-29 15:53:19.912299+00	2025-12-29 15:54:43.823301+00	2025-12-29 15:54:43.822422+00	\N	t	{}
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
bc668e9a-a800-4a9f-b10b-173d518dc030	f0379d72-158f-446f-a867-d3dc7ebaeb0c	4d7ffac7-6136-457d-ab60-4975ffc0454a	Port	4e898df8-1804-4b8d-938b-e3e5dd1c0392	c3922e2d-e3f6-49d2-8f66-738e6888f12d	2025-12-29 15:53:20.078675+00	2025-12-29 15:53:20.078675+00
e3422be7-f8bb-4125-9577-716fb92f4bd6	f0379d72-158f-446f-a867-d3dc7ebaeb0c	8198ac06-cf14-4b79-9de5-dd8622182247	Port	01361e58-c51e-482e-9ffe-9fb1e02ea065	70cd027b-1d2e-4a0b-b329-c0b01a972ac8	2025-12-29 15:53:53.289478+00	2025-12-29 15:53:53.289478+00
667e26a2-d3e2-480d-afc6-a0b89cb7ca8f	f0379d72-158f-446f-a867-d3dc7ebaeb0c	8a3b8c61-367c-44e6-97ac-c3700531105a	Port	f9553fd3-bb2b-471c-a8c3-1d16e203e4f9	0c582805-a4eb-4bcb-a84c-a5522e68bdc9	2025-12-29 15:54:05.986808+00	2025-12-29 15:54:05.986808+00
52a2cb29-63e3-4d88-ab64-41d8b36d270f	f0379d72-158f-446f-a867-d3dc7ebaeb0c	0e9c8db1-e5ea-44e0-b12a-faacd6eac2e2	Port	f9553fd3-bb2b-471c-a8c3-1d16e203e4f9	9444352b-3397-4b67-b8f8-780f7f898bac	2025-12-29 15:54:08.243217+00	2025-12-29 15:54:08.243217+00
9ac1ec80-edb2-4f61-89a0-3af08eb85598	f0379d72-158f-446f-a867-d3dc7ebaeb0c	9417388a-5184-4be3-b82b-504ecda9a3f0	Port	5be72735-0576-44f4-bd71-cc2fb27833db	dcb302f4-6e9d-485e-b9ec-13e4428f5065	2025-12-29 15:54:23.211545+00	2025-12-29 15:54:23.211545+00
736de829-a482-4346-a9ea-531e596e2aec	f0379d72-158f-446f-a867-d3dc7ebaeb0c	a68513a7-1a04-4bea-aa3a-427c99cd5450	Port	6663c5dd-5bee-4c10-9ffd-fb49e988784d	4b00ae02-1a3b-433a-ad19-05dbf3db499f	2025-12-29 15:54:41.607887+00	2025-12-29 15:54:41.607887+00
ed5a552d-20be-4562-a03f-2e6af9eafed4	f0379d72-158f-446f-a867-d3dc7ebaeb0c	3eeafd5b-9288-4888-b30a-8088d5408e5d	Port	6663c5dd-5bee-4c10-9ffd-fb49e988784d	c0315027-a7ef-4d2a-9b01-acd928d14877	2025-12-29 15:54:42.32246+00	2025-12-29 15:54:42.32246+00
7f2d4303-2eab-4060-9d89-88fa2d7e6002	f0379d72-158f-446f-a867-d3dc7ebaeb0c	a4a011aa-41d1-4857-99b4-ddf382d91056	Port	6663c5dd-5bee-4c10-9ffd-fb49e988784d	6b1b24f8-8a79-4448-974e-9599b72cfd61	2025-12-29 15:54:43.769768+00	2025-12-29 15:54:43.769768+00
b1bdd7ff-5660-4315-a05e-36fc30b054bf	f0379d72-158f-446f-a867-d3dc7ebaeb0c	eb7e0d95-f98c-4d14-89f5-b393ff4f0a36	Port	6663c5dd-5bee-4c10-9ffd-fb49e988784d	519b04e8-6f69-47e6-8d78-1354d5012855	2025-12-29 15:54:43.77017+00	2025-12-29 15:54:43.77017+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
e8b82bc9-00ee-4e29-8b80-c747a3f583e0	f0379d72-158f-446f-a867-d3dc7ebaeb0c	9414173b-c31f-495e-aec7-6e01f8a099fd	2025-12-29 15:53:20.044901+00	2025-12-29 15:54:38.437387+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["e5bb8910-b137-4fff-9f7a-1b0e2ad7854a"]}	2025-12-29 15:54:38.437939+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
d8c8cdd1-2020-4ca7-8b75-002b51bc9eb2	f0379d72-158f-446f-a867-d3dc7ebaeb0c	e8b82bc9-00ee-4e29-8b80-c747a3f583e0	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd"}	Self Report	2025-12-29 15:53:20.052752+00	2025-12-29 15:53:20.052752+00	{}
c1bea95d-787f-414a-905c-5003bba9ac58	f0379d72-158f-446f-a867-d3dc7ebaeb0c	e8b82bc9-00ee-4e29-8b80-c747a3f583e0	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-29 15:53:20.060474+00	2025-12-29 15:53:20.060474+00	{}
2134cda7-9c76-41a2-83ab-01b017ee7049	f0379d72-158f-446f-a867-d3dc7ebaeb0c	e8b82bc9-00ee-4e29-8b80-c747a3f583e0	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "session_id": "fd781cf3-2d19-4387-aa03-9db388fc29ee", "started_at": "2025-12-29T15:53:20.060033097Z", "finished_at": "2025-12-29T15:53:20.201901089Z", "discovery_type": {"type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd"}}}	{"type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd"}	Self Report	2025-12-29 15:53:20.060033+00	2025-12-29 15:53:20.204563+00	{}
d9f14172-f2bc-48aa-a428-8c6ac61bf9ca	f0379d72-158f-446f-a867-d3dc7ebaeb0c	e8b82bc9-00ee-4e29-8b80-c747a3f583e0	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "session_id": "f9423514-0461-4c31-9797-5fac89929864", "started_at": "2025-12-29T15:53:20.216565937Z", "finished_at": "2025-12-29T15:54:43.820459478Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-29 15:53:20.216565+00	2025-12-29 15:54:43.82267+00	{}
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
8d545d36-23eb-4632-af72-a4ae7bbb38ca	f0379d72-158f-446f-a867-d3dc7ebaeb0c		\N	2025-12-29 15:54:43.836842+00	2025-12-29 15:54:43.836842+00	{"type": "Manual"}	Yellow	"SmoothStep"	{}	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
9414173b-c31f-495e-aec7-6e01f8a099fd	f0379d72-158f-446f-a867-d3dc7ebaeb0c	scanopy-daemon	0df556391e34	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-29T15:53:20.078654794Z", "type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0"}]}	null	2025-12-29 15:53:20.039903+00	2025-12-29 15:53:20.176982+00	f	{}
57e70b79-2885-4d3e-aa61-cf97296a75d9	f0379d72-158f-446f-a867-d3dc7ebaeb0c	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-29T15:53:38.705935166Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-29 15:53:38.705936+00	2025-12-29 15:53:38.705936+00	f	{}
c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46	f0379d72-158f-446f-a867-d3dc7ebaeb0c	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-29T15:53:53.397079086Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-29 15:53:53.39708+00	2025-12-29 15:53:53.39708+00	f	{}
f7193a59-3dd0-4d1b-aa8a-86d4fa8ea8fc	f0379d72-158f-446f-a867-d3dc7ebaeb0c	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-29T15:54:08.257404645Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-29 15:54:08.257405+00	2025-12-29 15:54:08.257405+00	f	{}
07ec5f46-83f1-421f-8efc-33636464a073	f0379d72-158f-446f-a867-d3dc7ebaeb0c	runnervmh13bl	runnervmh13bl	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-29T15:54:29.282989221Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-29 15:54:29.28299+00	2025-12-29 15:54:29.28299+00	f	{}
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
4e898df8-1804-4b8d-938b-e3e5dd1c0392	f0379d72-158f-446f-a867-d3dc7ebaeb0c	9414173b-c31f-495e-aec7-6e01f8a099fd	e5bb8910-b137-4fff-9f7a-1b0e2ad7854a	172.25.0.4	6a:ca:d6:50:05:d4	eth0	0	2025-12-29 15:53:20.060264+00	2025-12-29 15:53:20.060264+00
01361e58-c51e-482e-9ffe-9fb1e02ea065	f0379d72-158f-446f-a867-d3dc7ebaeb0c	57e70b79-2885-4d3e-aa61-cf97296a75d9	e5bb8910-b137-4fff-9f7a-1b0e2ad7854a	172.25.0.6	1a:4a:7e:40:a6:0a	\N	0	2025-12-29 15:53:38.705909+00	2025-12-29 15:53:38.705909+00
f9553fd3-bb2b-471c-a8c3-1d16e203e4f9	f0379d72-158f-446f-a867-d3dc7ebaeb0c	c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46	e5bb8910-b137-4fff-9f7a-1b0e2ad7854a	172.25.0.5	5e:ce:b7:cb:16:f2	\N	0	2025-12-29 15:53:53.397056+00	2025-12-29 15:53:53.397056+00
5be72735-0576-44f4-bd71-cc2fb27833db	f0379d72-158f-446f-a867-d3dc7ebaeb0c	f7193a59-3dd0-4d1b-aa8a-86d4fa8ea8fc	e5bb8910-b137-4fff-9f7a-1b0e2ad7854a	172.25.0.3	ba:fd:29:e8:4c:fa	\N	0	2025-12-29 15:54:08.257377+00	2025-12-29 15:54:08.257377+00
6663c5dd-5bee-4c10-9ffd-fb49e988784d	f0379d72-158f-446f-a867-d3dc7ebaeb0c	07ec5f46-83f1-421f-8efc-33636464a073	e5bb8910-b137-4fff-9f7a-1b0e2ad7854a	172.25.0.1	9a:b4:5d:94:08:49	\N	0	2025-12-29 15:54:29.282958+00	2025-12-29 15:54:29.282958+00
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
f0379d72-158f-446f-a867-d3dc7ebaeb0c	My Network	2025-12-29 15:53:19.896615+00	2025-12-29 15:53:19.896615+00	0708024f-c6e1-430b-9941-6644403b3ed2	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
0708024f-c6e1-430b-9941-6644403b3ed2	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-29 15:53:19.890418+00	2025-12-29 15:54:44.732957+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
c3922e2d-e3f6-49d2-8f66-738e6888f12d	f0379d72-158f-446f-a867-d3dc7ebaeb0c	9414173b-c31f-495e-aec7-6e01f8a099fd	60073	Tcp	Custom	2025-12-29 15:53:20.078496+00	2025-12-29 15:53:20.078496+00
70cd027b-1d2e-4a0b-b329-c0b01a972ac8	f0379d72-158f-446f-a867-d3dc7ebaeb0c	57e70b79-2885-4d3e-aa61-cf97296a75d9	5432	Tcp	PostgreSQL	2025-12-29 15:53:53.28947+00	2025-12-29 15:53:53.28947+00
0c582805-a4eb-4bcb-a84c-a5522e68bdc9	f0379d72-158f-446f-a867-d3dc7ebaeb0c	c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46	8123	Tcp	Custom	2025-12-29 15:54:05.986797+00	2025-12-29 15:54:05.986797+00
9444352b-3397-4b67-b8f8-780f7f898bac	f0379d72-158f-446f-a867-d3dc7ebaeb0c	c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46	18555	Tcp	Custom	2025-12-29 15:54:08.243205+00	2025-12-29 15:54:08.243205+00
dcb302f4-6e9d-485e-b9ec-13e4428f5065	f0379d72-158f-446f-a867-d3dc7ebaeb0c	f7193a59-3dd0-4d1b-aa8a-86d4fa8ea8fc	60072	Tcp	Custom	2025-12-29 15:54:23.211534+00	2025-12-29 15:54:23.211534+00
4b00ae02-1a3b-433a-ad19-05dbf3db499f	f0379d72-158f-446f-a867-d3dc7ebaeb0c	07ec5f46-83f1-421f-8efc-33636464a073	8123	Tcp	Custom	2025-12-29 15:54:41.607875+00	2025-12-29 15:54:41.607875+00
c0315027-a7ef-4d2a-9b01-acd928d14877	f0379d72-158f-446f-a867-d3dc7ebaeb0c	07ec5f46-83f1-421f-8efc-33636464a073	60072	Tcp	Custom	2025-12-29 15:54:42.322449+00	2025-12-29 15:54:42.322449+00
6b1b24f8-8a79-4448-974e-9599b72cfd61	f0379d72-158f-446f-a867-d3dc7ebaeb0c	07ec5f46-83f1-421f-8efc-33636464a073	22	Tcp	Ssh	2025-12-29 15:54:43.769758+00	2025-12-29 15:54:43.769758+00
519b04e8-6f69-47e6-8d78-1354d5012855	f0379d72-158f-446f-a867-d3dc7ebaeb0c	07ec5f46-83f1-421f-8efc-33636464a073	5435	Tcp	Custom	2025-12-29 15:54:43.770165+00	2025-12-29 15:54:43.770165+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, tags) FROM stdin;
4d7ffac7-6136-457d-ab60-4975ffc0454a	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:53:20.078679+00	2025-12-29 15:53:20.078679+00	Scanopy Daemon	9414173b-c31f-495e-aec7-6e01f8a099fd	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-29T15:53:20.078678258Z", "type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0"}]}	{}
8198ac06-cf14-4b79-9de5-dd8622182247	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:53:53.289481+00	2025-12-29 15:53:53.289481+00	PostgreSQL	57e70b79-2885-4d3e-aa61-cf97296a75d9	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:53:53.289465959Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
8a3b8c61-367c-44e6-97ac-c3700531105a	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:54:05.986812+00	2025-12-29 15:54:05.986812+00	Home Assistant	c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-29T15:54:05.986790560Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0e9c8db1-e5ea-44e0-b12a-faacd6eac2e2	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:54:08.243222+00	2025-12-29 15:54:08.243222+00	Unclaimed Open Ports	c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:54:08.243199028Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
9417388a-5184-4be3-b82b-504ecda9a3f0	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:54:23.21155+00	2025-12-29 15:54:23.21155+00	Unclaimed Open Ports	f7193a59-3dd0-4d1b-aa8a-86d4fa8ea8fc	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:54:23.211529365Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
a68513a7-1a04-4bea-aa3a-427c99cd5450	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:54:41.60789+00	2025-12-29 15:54:41.60789+00	Home Assistant	07ec5f46-83f1-421f-8efc-33636464a073	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-29T15:54:41.607870294Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
3eeafd5b-9288-4888-b30a-8088d5408e5d	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:54:42.322464+00	2025-12-29 15:54:42.322464+00	Scanopy Server	07ec5f46-83f1-421f-8efc-33636464a073	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-29T15:54:42.322443269Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
a4a011aa-41d1-4857-99b4-ddf382d91056	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:54:43.769773+00	2025-12-29 15:54:43.769773+00	SSH	07ec5f46-83f1-421f-8efc-33636464a073	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:54:43.769752947Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
eb7e0d95-f98c-4d14-89f5-b393ff4f0a36	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:54:43.770173+00	2025-12-29 15:54:43.770173+00	Unclaimed Open Ports	07ec5f46-83f1-421f-8efc-33636464a073	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:54:43.770163181Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
4aff1f09-421a-46ca-b373-959ee08e5c6d	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:53:19.898155+00	2025-12-29 15:53:19.898155+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}	{}
608807db-e3c2-4e30-bfb8-fba750efe24d	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:53:19.898159+00	2025-12-29 15:53:19.898159+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}	{}
e5bb8910-b137-4fff-9f7a-1b0e2ad7854a	f0379d72-158f-446f-a867-d3dc7ebaeb0c	2025-12-29 15:53:20.060236+00	2025-12-29 15:53:20.060236+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2025-12-29T15:53:20.060233922Z", "type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
363bb8d6-d40a-40e6-98a5-0f4fc8b15a90	0708024f-c6e1-430b-9941-6644403b3ed2	New Tag	\N	2025-12-29 15:54:43.848693+00	2025-12-29 15:54:43.848693+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
7a5aaac4-d696-4dc4-a3d1-3456c51c823b	f0379d72-158f-446f-a867-d3dc7ebaeb0c	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "9414173b-c31f-495e-aec7-6e01f8a099fd", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-29T15:53:20.078654794Z", "type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0"}]}, "hostname": "0df556391e34", "created_at": "2025-12-29T15:53:20.039903Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:53:20.176982Z", "description": null, "virtualization": null}, {"id": "57e70b79-2885-4d3e-aa61-cf97296a75d9", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-29T15:53:38.705935166Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2025-12-29T15:53:38.705936Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:53:38.705936Z", "description": null, "virtualization": null}, {"id": "c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-29T15:53:53.397079086Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2025-12-29T15:53:53.397080Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:53:53.397080Z", "description": null, "virtualization": null}, {"id": "f7193a59-3dd0-4d1b-aa8a-86d4fa8ea8fc", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-29T15:54:08.257404645Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2025-12-29T15:54:08.257405Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:08.257405Z", "description": null, "virtualization": null}, {"id": "07ec5f46-83f1-421f-8efc-33636464a073", "name": "runnervmh13bl", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-29T15:54:29.282989221Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmh13bl", "created_at": "2025-12-29T15:54:29.282990Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:29.282990Z", "description": null, "virtualization": null}, {"id": "8bce047a-9cb0-40f8-9c2a-ba2d505fbf00", "name": "Service Test Host", "tags": [], "hidden": false, "source": {"type": "Manual"}, "hostname": "service-test.local", "created_at": "2025-12-29T15:54:44.580076Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:44.580076Z", "description": null, "virtualization": null}]	[{"id": "4aff1f09-421a-46ca-b373-959ee08e5c6d", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-29T15:53:19.898155Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:53:19.898155Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "608807db-e3c2-4e30-bfb8-fba750efe24d", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-29T15:53:19.898159Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:53:19.898159Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "e5bb8910-b137-4fff-9f7a-1b0e2ad7854a", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-29T15:53:20.060233922Z", "type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0"}]}, "created_at": "2025-12-29T15:53:20.060236Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:53:20.060236Z", "description": null, "subnet_type": "Lan"}]	[{"id": "4d7ffac7-6136-457d-ab60-4975ffc0454a", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-29T15:53:20.078678258Z", "type": "SelfReport", "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0"}]}, "host_id": "9414173b-c31f-495e-aec7-6e01f8a099fd", "bindings": [{"id": "bc668e9a-a800-4a9f-b10b-173d518dc030", "type": "Port", "port_id": "c3922e2d-e3f6-49d2-8f66-738e6888f12d", "created_at": "2025-12-29T15:53:20.078675Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "4d7ffac7-6136-457d-ab60-4975ffc0454a", "updated_at": "2025-12-29T15:53:20.078675Z", "interface_id": "4e898df8-1804-4b8d-938b-e3e5dd1c0392"}], "created_at": "2025-12-29T15:53:20.078679Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:53:20.078679Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "8198ac06-cf14-4b79-9de5-dd8622182247", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:53:53.289465959Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "57e70b79-2885-4d3e-aa61-cf97296a75d9", "bindings": [{"id": "e3422be7-f8bb-4125-9577-716fb92f4bd6", "type": "Port", "port_id": "70cd027b-1d2e-4a0b-b329-c0b01a972ac8", "created_at": "2025-12-29T15:53:53.289478Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "8198ac06-cf14-4b79-9de5-dd8622182247", "updated_at": "2025-12-29T15:53:53.289478Z", "interface_id": "01361e58-c51e-482e-9ffe-9fb1e02ea065"}], "created_at": "2025-12-29T15:53:53.289481Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:53:53.289481Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "8a3b8c61-367c-44e6-97ac-c3700531105a", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-29T15:54:05.986790560Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46", "bindings": [{"id": "667e26a2-d3e2-480d-afc6-a0b89cb7ca8f", "type": "Port", "port_id": "0c582805-a4eb-4bcb-a84c-a5522e68bdc9", "created_at": "2025-12-29T15:54:05.986808Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "8a3b8c61-367c-44e6-97ac-c3700531105a", "updated_at": "2025-12-29T15:54:05.986808Z", "interface_id": "f9553fd3-bb2b-471c-a8c3-1d16e203e4f9"}], "created_at": "2025-12-29T15:54:05.986812Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:05.986812Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "0e9c8db1-e5ea-44e0-b12a-faacd6eac2e2", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:54:08.243199028Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "c97d6a5e-aaeb-4a4d-bc12-8d2e6bf12e46", "bindings": [{"id": "52a2cb29-63e3-4d88-ab64-41d8b36d270f", "type": "Port", "port_id": "9444352b-3397-4b67-b8f8-780f7f898bac", "created_at": "2025-12-29T15:54:08.243217Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "0e9c8db1-e5ea-44e0-b12a-faacd6eac2e2", "updated_at": "2025-12-29T15:54:08.243217Z", "interface_id": "f9553fd3-bb2b-471c-a8c3-1d16e203e4f9"}], "created_at": "2025-12-29T15:54:08.243222Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:08.243222Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "9417388a-5184-4be3-b82b-504ecda9a3f0", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:54:23.211529365Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "f7193a59-3dd0-4d1b-aa8a-86d4fa8ea8fc", "bindings": [{"id": "9ac1ec80-edb2-4f61-89a0-3af08eb85598", "type": "Port", "port_id": "dcb302f4-6e9d-485e-b9ec-13e4428f5065", "created_at": "2025-12-29T15:54:23.211545Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "9417388a-5184-4be3-b82b-504ecda9a3f0", "updated_at": "2025-12-29T15:54:23.211545Z", "interface_id": "5be72735-0576-44f4-bd71-cc2fb27833db"}], "created_at": "2025-12-29T15:54:23.211550Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:23.211550Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "a68513a7-1a04-4bea-aa3a-427c99cd5450", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-29T15:54:41.607870294Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "07ec5f46-83f1-421f-8efc-33636464a073", "bindings": [{"id": "736de829-a482-4346-a9ea-531e596e2aec", "type": "Port", "port_id": "4b00ae02-1a3b-433a-ad19-05dbf3db499f", "created_at": "2025-12-29T15:54:41.607887Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "a68513a7-1a04-4bea-aa3a-427c99cd5450", "updated_at": "2025-12-29T15:54:41.607887Z", "interface_id": "6663c5dd-5bee-4c10-9ffd-fb49e988784d"}], "created_at": "2025-12-29T15:54:41.607890Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:41.607890Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "3eeafd5b-9288-4888-b30a-8088d5408e5d", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-29T15:54:42.322443269Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "07ec5f46-83f1-421f-8efc-33636464a073", "bindings": [{"id": "ed5a552d-20be-4562-a03f-2e6af9eafed4", "type": "Port", "port_id": "c0315027-a7ef-4d2a-9b01-acd928d14877", "created_at": "2025-12-29T15:54:42.322460Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "3eeafd5b-9288-4888-b30a-8088d5408e5d", "updated_at": "2025-12-29T15:54:42.322460Z", "interface_id": "6663c5dd-5bee-4c10-9ffd-fb49e988784d"}], "created_at": "2025-12-29T15:54:42.322464Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:42.322464Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "a4a011aa-41d1-4857-99b4-ddf382d91056", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:54:43.769752947Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "07ec5f46-83f1-421f-8efc-33636464a073", "bindings": [{"id": "7f2d4303-2eab-4060-9d89-88fa2d7e6002", "type": "Port", "port_id": "6b1b24f8-8a79-4448-974e-9599b72cfd61", "created_at": "2025-12-29T15:54:43.769768Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "a4a011aa-41d1-4857-99b4-ddf382d91056", "updated_at": "2025-12-29T15:54:43.769768Z", "interface_id": "6663c5dd-5bee-4c10-9ffd-fb49e988784d"}], "created_at": "2025-12-29T15:54:43.769773Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:43.769773Z", "virtualization": null, "service_definition": "SSH"}, {"id": "eb7e0d95-f98c-4d14-89f5-b393ff4f0a36", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-29T15:54:43.770163181Z", "type": "Network", "daemon_id": "e8b82bc9-00ee-4e29-8b80-c747a3f583e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "07ec5f46-83f1-421f-8efc-33636464a073", "bindings": [{"id": "b1bdd7ff-5660-4315-a05e-36fc30b054bf", "type": "Port", "port_id": "519b04e8-6f69-47e6-8d78-1354d5012855", "created_at": "2025-12-29T15:54:43.770170Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "service_id": "eb7e0d95-f98c-4d14-89f5-b393ff4f0a36", "updated_at": "2025-12-29T15:54:43.770170Z", "interface_id": "6663c5dd-5bee-4c10-9ffd-fb49e988784d"}], "created_at": "2025-12-29T15:54:43.770173Z", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:43.770173Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "8d545d36-23eb-4632-af72-a4ae7bbb38ca", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2025-12-29T15:54:43.836842Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "f0379d72-158f-446f-a867-d3dc7ebaeb0c", "updated_at": "2025-12-29T15:54:43.836842Z", "binding_ids": [], "description": null}]	t	2025-12-29 15:53:19.910473+00	f	\N	\N	{50b88576-bcbb-4c0b-a7e2-653e72de0a16,8bce047a-9cb0-40f8-9c2a-ba2d505fbf00,ac022494-f016-42ce-94a6-3afad1af772c}	{7c552f92-2b50-408e-a96e-3a2398292c3a}	{12b0081a-2231-40a3-b013-10728eb8b25a}	{d1ed417e-1c8a-4f28-9e5b-e14105001287}	\N	2025-12-29 15:53:19.902247+00	2025-12-29 15:54:45.609043+00	{}	[]	{}	[]	{}	[]	{}
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
0c19eb6a-17aa-4752-a2f8-ff7135597f54	2025-12-29 15:53:19.89358+00	2025-12-29 15:53:19.89358+00	$argon2id$v=19$m=19456,t=2,p=1$HKF+MaGCtkOnpcJHeF+2Yg$Ab4t2guHi039q7mBOcqwwF5k+BXdu0sC20flXYhMUR4	\N	\N	\N	user@gmail.com	0708024f-c6e1-430b-9941-6644403b3ed2	Owner	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
zbPoBTYXdcAKYyUvPJTM0Q	\\x93c410d1cc943c2f25630ac075173605e8b3cd81a7757365725f6964d92430633139656236612d313761612d343735322d613266382d66663731333535393766353499cd07ea1c0f3514ce0409391b000000	2026-01-28 15:53:20.067713+00
5XMEf9EOO-gVwFseEdIwow	\\x93c410a330d2111e5bc015e83b0ed17f0473e582a7757365725f6964d92430633139656236612d313761612d343735322d613266382d666637313335353937663534ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92463336239373764642d396361332d343534392d613866372d313039303463666439643765a86f72675f6e616d65af4d79204f7267616e697a6174696f6e99cd07ea1c0f362cce1af94a8a000000	2026-01-28 15:54:44.452545+00
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

\unrestrict ZoyypC2yYralGLljuScqff2Impfx72R1uzL8658Z6hIEuc3NhaNcnRipGu577YL

