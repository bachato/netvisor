--
-- PostgreSQL database dump
--

\restrict iZwqhGfdEiVOCjKAjx1vuHtBymiP50QFXd0F8b0rkHRvMAfMQjqDiCLGZ8OPSC8

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
20251006215000	users	2025-12-30 16:21:04.667839+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3608770
20251006215100	networks	2025-12-30 16:21:04.672761+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5338941
20251006215151	create hosts	2025-12-30 16:21:04.678611+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3986824
20251006215155	create subnets	2025-12-30 16:21:04.68295+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3957058
20251006215201	create groups	2025-12-30 16:21:04.687291+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4116115
20251006215204	create daemons	2025-12-30 16:21:04.691947+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4222032
20251006215212	create services	2025-12-30 16:21:04.696657+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4868466
20251029193448	user-auth	2025-12-30 16:21:04.702048+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	7061708
20251030044828	daemon api	2025-12-30 16:21:04.709474+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1660132
20251030170438	host-hide	2025-12-30 16:21:04.711674+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1180568
20251102224919	create discovery	2025-12-30 16:21:04.713183+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11689525
20251106235621	normalize-daemon-cols	2025-12-30 16:21:04.725199+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1792780
20251107034459	api keys	2025-12-30 16:21:04.727437+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	9047327
20251107222650	oidc-auth	2025-12-30 16:21:04.736852+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	35260468
20251110181948	orgs-billing	2025-12-30 16:21:04.772467+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11265068
20251113223656	group-enhancements	2025-12-30 16:21:04.784115+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1075741
20251117032720	daemon-mode	2025-12-30 16:21:04.785634+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1173745
20251118143058	set-default-plan	2025-12-30 16:21:04.78726+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1474473
20251118225043	save-topology	2025-12-30 16:21:04.789031+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9750627
20251123232748	network-permissions	2025-12-30 16:21:04.799199+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	3091857
20251125001342	billing-updates	2025-12-30 16:21:04.802733+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	946343
20251128035448	org-onboarding-status	2025-12-30 16:21:04.803958+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1535980
20251129180942	nfs-consolidate	2025-12-30 16:21:04.805823+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1272299
20251206052641	discovery-progress	2025-12-30 16:21:04.807399+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1882576
20251206202200	plan-fix	2025-12-30 16:21:04.809616+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	980485
20251207061341	daemon-url	2025-12-30 16:21:04.81096+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2729683
20251210045929	tags	2025-12-30 16:21:04.814009+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9756358
20251210175035	terms	2025-12-30 16:21:04.824241+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	918480
20251213025048	hash-keys	2025-12-30 16:21:04.825481+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	11851088
20251214050638	scanopy	2025-12-30 16:21:04.83763+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1342259
20251215215724	topo-scanopy-fix	2025-12-30 16:21:04.839372+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	787687
20251217153736	category rename	2025-12-30 16:21:04.840497+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1864382
20251218053111	invite-persistence	2025-12-30 16:21:04.842692+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5228055
20251219211216	create shares	2025-12-30 16:21:04.848421+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6758405
20251220170928	permissions-cleanup	2025-12-30 16:21:04.855612+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1470758
20251220180000	commercial-to-community	2025-12-30 16:21:04.857443+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	849251
20251221010000	cleanup subnet type	2025-12-30 16:21:04.858629+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	930353
20251221020000	remove host target	2025-12-30 16:21:04.860108+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	998479
20251221030000	user network access	2025-12-30 16:21:04.861518+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7775941
20251221040000	interfaces table	2025-12-30 16:21:04.869644+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	9709680
20251221050000	ports table	2025-12-30 16:21:04.879747+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	8863995
20251221060000	bindings table	2025-12-30 16:21:04.888964+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	10917128
20251221070000	group bindings	2025-12-30 16:21:04.900247+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6331198
20251222020000	tag cascade delete	2025-12-30 16:21:04.907283+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1297245
20251223232524	network remove default	2025-12-30 16:21:04.908918+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	1045577
20251225100000	color enum	2025-12-30 16:21:04.910292+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1404435
20251227010000	topology snapshot migration	2025-12-30 16:21:04.911988+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4624141
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
e13f6e79-7d6d-4450-8ead-f767990e04d8	a0f69f1fd5b19444a88306fd36b66e88e8bd9354c4f887abffbd3a8db3565b41	8750a51f-9d41-4cd6-b684-f941dec90b48	Integrated Daemon API Key	2025-12-30 16:21:07.671788+00	2025-12-30 16:22:31.449131+00	2025-12-30 16:22:31.448322+00	\N	t	{}
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
b494d7cc-1804-421a-91ea-99180fca5776	8750a51f-9d41-4cd6-b684-f941dec90b48	83368d0b-b045-4e1e-bdb2-c6ed1633f387	Port	9b7eb53d-66fa-4898-a52c-6ad15eca987e	8eeaf283-2181-479b-ad61-5d13576d813b	2025-12-30 16:21:07.815747+00	2025-12-30 16:21:07.815747+00
be4efb8a-1228-4cf9-8062-7c49a5307003	8750a51f-9d41-4cd6-b684-f941dec90b48	eee9ecf0-556d-44e1-8052-7245404e7482	Port	f88bcbbf-b304-42a1-b996-4b72058a4fcc	5fde4b95-1603-49a3-98e5-a483e37909ff	2025-12-30 16:21:40.724945+00	2025-12-30 16:21:40.724945+00
e50b0d66-6ef4-435a-a0b0-90c1314fab1d	8750a51f-9d41-4cd6-b684-f941dec90b48	572a7faf-3857-4ae8-9f39-f0f170f46e1c	Port	b8ba8476-bfa8-4dc1-b460-92c35c535aee	4bbea3aa-d6ed-4a33-ac16-c1e6a5b9f464	2025-12-30 16:21:46.763666+00	2025-12-30 16:21:46.763666+00
df642576-2266-46b5-949b-a2596122c5d8	8750a51f-9d41-4cd6-b684-f941dec90b48	1ffeea63-c6d9-4663-b44b-e7eb1e96dd22	Port	b8ba8476-bfa8-4dc1-b460-92c35c535aee	4cfd6a4d-80ec-49a2-a06b-3fc66b434d13	2025-12-30 16:21:55.569226+00	2025-12-30 16:21:55.569226+00
4e9d266e-8c0c-48b5-bb9f-9eb1aafad50b	8750a51f-9d41-4cd6-b684-f941dec90b48	1b5d4b0b-5ac7-417a-adfc-c803952e6290	Port	d1dd33b7-26a7-49ce-a793-3e7741398d33	8057edcf-c5fd-4a2e-8317-387ea7d8cec8	2025-12-30 16:22:10.554537+00	2025-12-30 16:22:10.554537+00
ddfc517c-9a0b-4b77-8e6a-66eb432f34ec	8750a51f-9d41-4cd6-b684-f941dec90b48	4a8c019a-d34b-438e-9cc2-d75e3516b36a	Port	7ab1ad93-c908-4f49-a9de-2a155e6e0e50	ac3f4e60-8184-4d57-b865-5666fbadf72c	2025-12-30 16:22:22.555265+00	2025-12-30 16:22:22.555265+00
5fe044b1-f94b-48c3-9c7c-e7ddb4c547c7	8750a51f-9d41-4cd6-b684-f941dec90b48	c07930c1-bd4e-473d-bf07-57af0b9dce61	Port	7ab1ad93-c908-4f49-a9de-2a155e6e0e50	ff99fa6e-f359-4a13-bd43-48c0b8016817	2025-12-30 16:22:30.632547+00	2025-12-30 16:22:30.632547+00
f560e8bf-58eb-4be1-805d-3fd668f4a7f5	8750a51f-9d41-4cd6-b684-f941dec90b48	da67ce20-60dd-4d84-9456-70e9094a4982	Port	7ab1ad93-c908-4f49-a9de-2a155e6e0e50	e3a19ae3-50e7-4a72-b26c-3ab2f5b377cb	2025-12-30 16:22:31.385479+00	2025-12-30 16:22:31.385479+00
b0208c3f-cef7-4a54-b47b-e3e2c5b9714a	8750a51f-9d41-4cd6-b684-f941dec90b48	ef4e6672-86c6-49c6-b6c8-c049b16450ca	Port	7ab1ad93-c908-4f49-a9de-2a155e6e0e50	ddbd20f1-a6ff-4689-8787-3955a1a1638f	2025-12-30 16:22:31.385846+00	2025-12-30 16:22:31.385846+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
6344b53b-4838-4d62-be5d-8fd79065cabe	8750a51f-9d41-4cd6-b684-f941dec90b48	842f1a03-1967-4b04-b089-f0c36c7ce0fa	2025-12-30 16:21:07.726128+00	2025-12-30 16:22:25.240295+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["897127ac-9a5d-41b5-be9d-7624a6642508"]}	2025-12-30 16:22:25.240883+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
0fc3adc5-a611-4c28-8db8-fcf9838c1905	8750a51f-9d41-4cd6-b684-f941dec90b48	6344b53b-4838-4d62-be5d-8fd79065cabe	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa"}	Self Report	2025-12-30 16:21:07.735836+00	2025-12-30 16:21:07.735836+00	{}
120198ef-b951-4a8e-a5f6-cfad186e4b48	8750a51f-9d41-4cd6-b684-f941dec90b48	6344b53b-4838-4d62-be5d-8fd79065cabe	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-30 16:21:07.742328+00	2025-12-30 16:21:07.742328+00	{}
fd3e665d-02c1-4d30-a6dd-fcc9d4c6b302	8750a51f-9d41-4cd6-b684-f941dec90b48	6344b53b-4838-4d62-be5d-8fd79065cabe	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "session_id": "bcce6966-b32b-4a1e-a0de-eb04d12f8550", "started_at": "2025-12-30T16:21:07.741685611Z", "finished_at": "2025-12-30T16:21:07.848617236Z", "discovery_type": {"type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa"}}}	{"type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa"}	Self Report	2025-12-30 16:21:07.741685+00	2025-12-30 16:21:07.850966+00	{}
ba503684-0a84-446f-abd0-dc4869c2b368	8750a51f-9d41-4cd6-b684-f941dec90b48	6344b53b-4838-4d62-be5d-8fd79065cabe	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "session_id": "1664bb14-a104-4363-bbfe-87eee8f23973", "started_at": "2025-12-30T16:21:07.862193922Z", "finished_at": "2025-12-30T16:22:31.445039024Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-30 16:21:07.862193+00	2025-12-30 16:22:31.448578+00	{}
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
033833eb-5abc-4445-a0eb-1b4d251c197f	8750a51f-9d41-4cd6-b684-f941dec90b48		\N	2025-12-30 16:22:31.466238+00	2025-12-30 16:22:31.466238+00	{"type": "Manual"}	Yellow	"SmoothStep"	{}	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
842f1a03-1967-4b04-b089-f0c36c7ce0fa	8750a51f-9d41-4cd6-b684-f941dec90b48	scanopy-daemon	eba7d8393e55	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:07.815734104Z", "type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe"}]}	null	2025-12-30 16:21:07.720199+00	2025-12-30 16:21:07.825678+00	f	{}
0cb63aa1-7d8f-4a38-abbc-fcb0b337c8bf	8750a51f-9d41-4cd6-b684-f941dec90b48	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:26.144669706Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-30 16:21:26.14467+00	2025-12-30 16:21:26.14467+00	f	{}
8eef1091-8d0a-48d9-acc3-f9bbf1806696	8750a51f-9d41-4cd6-b684-f941dec90b48	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:40.851679845Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-30 16:21:40.85168+00	2025-12-30 16:21:40.85168+00	f	{}
fcac99a3-5059-45f7-9f94-0ec2fd95876e	8750a51f-9d41-4cd6-b684-f941dec90b48	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:55.587365645Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-30 16:21:55.587366+00	2025-12-30 16:21:55.587366+00	f	{}
bcdf5db3-5750-4fb6-a4e5-329eac1036d6	8750a51f-9d41-4cd6-b684-f941dec90b48	runnervmh13bl	runnervmh13bl	\N	{"type": "Discovery", "metadata": [{"date": "2025-12-30T16:22:16.626606025Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-30 16:22:16.626607+00	2025-12-30 16:22:16.626607+00	f	{}
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
9b7eb53d-66fa-4898-a52c-6ad15eca987e	8750a51f-9d41-4cd6-b684-f941dec90b48	842f1a03-1967-4b04-b089-f0c36c7ce0fa	897127ac-9a5d-41b5-be9d-7624a6642508	172.25.0.4	ba:fe:59:a0:a6:bb	eth0	0	2025-12-30 16:21:07.741888+00	2025-12-30 16:21:07.741888+00
f88bcbbf-b304-42a1-b996-4b72058a4fcc	8750a51f-9d41-4cd6-b684-f941dec90b48	0cb63aa1-7d8f-4a38-abbc-fcb0b337c8bf	897127ac-9a5d-41b5-be9d-7624a6642508	172.25.0.6	c2:45:8f:dd:92:bf	\N	0	2025-12-30 16:21:26.144647+00	2025-12-30 16:21:26.144647+00
b8ba8476-bfa8-4dc1-b460-92c35c535aee	8750a51f-9d41-4cd6-b684-f941dec90b48	8eef1091-8d0a-48d9-acc3-f9bbf1806696	897127ac-9a5d-41b5-be9d-7624a6642508	172.25.0.5	26:3e:1c:47:de:b3	\N	0	2025-12-30 16:21:40.851655+00	2025-12-30 16:21:40.851655+00
d1dd33b7-26a7-49ce-a793-3e7741398d33	8750a51f-9d41-4cd6-b684-f941dec90b48	fcac99a3-5059-45f7-9f94-0ec2fd95876e	897127ac-9a5d-41b5-be9d-7624a6642508	172.25.0.3	2e:8d:be:90:70:f8	\N	0	2025-12-30 16:21:55.587337+00	2025-12-30 16:21:55.587337+00
7ab1ad93-c908-4f49-a9de-2a155e6e0e50	8750a51f-9d41-4cd6-b684-f941dec90b48	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	897127ac-9a5d-41b5-be9d-7624a6642508	172.25.0.1	2e:34:80:a6:63:8e	\N	0	2025-12-30 16:22:16.626566+00	2025-12-30 16:22:16.626566+00
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
8750a51f-9d41-4cd6-b684-f941dec90b48	My Network	2025-12-30 16:21:07.656534+00	2025-12-30 16:21:07.656534+00	6578b457-0056-42c8-a34c-150a5f4af65b	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
6578b457-0056-42c8-a34c-150a5f4af65b	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-30 16:21:07.650383+00	2025-12-30 16:22:32.355334+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
8eeaf283-2181-479b-ad61-5d13576d813b	8750a51f-9d41-4cd6-b684-f941dec90b48	842f1a03-1967-4b04-b089-f0c36c7ce0fa	60073	Tcp	Custom	2025-12-30 16:21:07.815603+00	2025-12-30 16:21:07.815603+00
5fde4b95-1603-49a3-98e5-a483e37909ff	8750a51f-9d41-4cd6-b684-f941dec90b48	0cb63aa1-7d8f-4a38-abbc-fcb0b337c8bf	5432	Tcp	PostgreSQL	2025-12-30 16:21:40.724936+00	2025-12-30 16:21:40.724936+00
4bbea3aa-d6ed-4a33-ac16-c1e6a5b9f464	8750a51f-9d41-4cd6-b684-f941dec90b48	8eef1091-8d0a-48d9-acc3-f9bbf1806696	8123	Tcp	Custom	2025-12-30 16:21:46.763655+00	2025-12-30 16:21:46.763655+00
4cfd6a4d-80ec-49a2-a06b-3fc66b434d13	8750a51f-9d41-4cd6-b684-f941dec90b48	8eef1091-8d0a-48d9-acc3-f9bbf1806696	18555	Tcp	Custom	2025-12-30 16:21:55.569201+00	2025-12-30 16:21:55.569201+00
8057edcf-c5fd-4a2e-8317-387ea7d8cec8	8750a51f-9d41-4cd6-b684-f941dec90b48	fcac99a3-5059-45f7-9f94-0ec2fd95876e	60072	Tcp	Custom	2025-12-30 16:22:10.554527+00	2025-12-30 16:22:10.554527+00
ac3f4e60-8184-4d57-b865-5666fbadf72c	8750a51f-9d41-4cd6-b684-f941dec90b48	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	8123	Tcp	Custom	2025-12-30 16:22:22.555254+00	2025-12-30 16:22:22.555254+00
ff99fa6e-f359-4a13-bd43-48c0b8016817	8750a51f-9d41-4cd6-b684-f941dec90b48	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	60072	Tcp	Custom	2025-12-30 16:22:30.632538+00	2025-12-30 16:22:30.632538+00
e3a19ae3-50e7-4a72-b26c-3ab2f5b377cb	8750a51f-9d41-4cd6-b684-f941dec90b48	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	22	Tcp	Ssh	2025-12-30 16:22:31.38547+00	2025-12-30 16:22:31.38547+00
ddbd20f1-a6ff-4689-8787-3955a1a1638f	8750a51f-9d41-4cd6-b684-f941dec90b48	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	5435	Tcp	Custom	2025-12-30 16:22:31.385841+00	2025-12-30 16:22:31.385841+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, tags) FROM stdin;
83368d0b-b045-4e1e-bdb2-c6ed1633f387	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:21:07.81575+00	2025-12-30 16:21:07.81575+00	Scanopy Daemon	842f1a03-1967-4b04-b089-f0c36c7ce0fa	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-30T16:21:07.815749663Z", "type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe"}]}	{}
eee9ecf0-556d-44e1-8052-7245404e7482	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:21:40.72495+00	2025-12-30 16:21:40.72495+00	PostgreSQL	0cb63aa1-7d8f-4a38-abbc-fcb0b337c8bf	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:21:40.724931780Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
572a7faf-3857-4ae8-9f39-f0f170f46e1c	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:21:46.76367+00	2025-12-30 16:21:46.76367+00	Home Assistant	8eef1091-8d0a-48d9-acc3-f9bbf1806696	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-30T16:21:46.763649896Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1ffeea63-c6d9-4663-b44b-e7eb1e96dd22	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:21:55.569231+00	2025-12-30 16:21:55.569231+00	Unclaimed Open Ports	8eef1091-8d0a-48d9-acc3-f9bbf1806696	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:21:55.569196005Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1b5d4b0b-5ac7-417a-adfc-c803952e6290	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:22:10.554543+00	2025-12-30 16:22:10.554543+00	Unclaimed Open Ports	fcac99a3-5059-45f7-9f94-0ec2fd95876e	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:22:10.554522888Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
4a8c019a-d34b-438e-9cc2-d75e3516b36a	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:22:22.555269+00	2025-12-30 16:22:22.555269+00	Home Assistant	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-30T16:22:22.555248654Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
c07930c1-bd4e-473d-bf07-57af0b9dce61	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:22:30.632551+00	2025-12-30 16:22:30.632551+00	Scanopy Server	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-30T16:22:30.632533468Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
da67ce20-60dd-4d84-9456-70e9094a4982	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:22:31.385484+00	2025-12-30 16:22:31.385484+00	SSH	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:22:31.385465330Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
ef4e6672-86c6-49c6-b6c8-c049b16450ca	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:22:31.385849+00	2025-12-30 16:22:31.385849+00	Unclaimed Open Ports	bcdf5db3-5750-4fb6-a4e5-329eac1036d6	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:22:31.385839247Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
fa215477-7268-4117-8402-414b7eb043ca	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:21:07.657988+00	2025-12-30 16:21:07.657988+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}	{}
9113d828-d501-4f58-95f1-12f6c9b7ccc9	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:21:07.657992+00	2025-12-30 16:21:07.657992+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}	{}
897127ac-9a5d-41b5-be9d-7624a6642508	8750a51f-9d41-4cd6-b684-f941dec90b48	2025-12-30 16:21:07.741859+00	2025-12-30 16:21:07.741859+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:07.741857481Z", "type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
03c9765a-613e-4637-b03e-27f4e2aa4a5c	6578b457-0056-42c8-a34c-150a5f4af65b	New Tag	\N	2025-12-30 16:22:31.478156+00	2025-12-30 16:22:31.478156+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
e4b74484-a5b8-4298-bdf5-2c94bec101e4	8750a51f-9d41-4cd6-b684-f941dec90b48	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:07.815734104Z", "type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe"}]}, "hostname": "eba7d8393e55", "created_at": "2025-12-30T16:21:07.720199Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:07.825678Z", "description": null, "virtualization": null}, {"id": "0cb63aa1-7d8f-4a38-abbc-fcb0b337c8bf", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:26.144669706Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2025-12-30T16:21:26.144670Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:26.144670Z", "description": null, "virtualization": null}, {"id": "8eef1091-8d0a-48d9-acc3-f9bbf1806696", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:40.851679845Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2025-12-30T16:21:40.851680Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:40.851680Z", "description": null, "virtualization": null}, {"id": "fcac99a3-5059-45f7-9f94-0ec2fd95876e", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:55.587365645Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2025-12-30T16:21:55.587366Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:55.587366Z", "description": null, "virtualization": null}, {"id": "bcdf5db3-5750-4fb6-a4e5-329eac1036d6", "name": "runnervmh13bl", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-30T16:22:16.626606025Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmh13bl", "created_at": "2025-12-30T16:22:16.626607Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:22:16.626607Z", "description": null, "virtualization": null}, {"id": "e7880b10-d86d-4ef0-a28f-c0166b129215", "name": "Service Test Host", "tags": [], "hidden": false, "source": {"type": "Manual"}, "hostname": "service-test.local", "created_at": "2025-12-30T16:22:32.194148Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:22:32.194148Z", "description": null, "virtualization": null}]	[{"id": "fa215477-7268-4117-8402-414b7eb043ca", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-30T16:21:07.657988Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:07.657988Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "9113d828-d501-4f58-95f1-12f6c9b7ccc9", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-30T16:21:07.657992Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:07.657992Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "897127ac-9a5d-41b5-be9d-7624a6642508", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-30T16:21:07.741857481Z", "type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe"}]}, "created_at": "2025-12-30T16:21:07.741859Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:07.741859Z", "description": null, "subnet_type": "Lan"}]	[{"id": "83368d0b-b045-4e1e-bdb2-c6ed1633f387", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-30T16:21:07.815749663Z", "type": "SelfReport", "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe"}]}, "host_id": "842f1a03-1967-4b04-b089-f0c36c7ce0fa", "bindings": [{"id": "b494d7cc-1804-421a-91ea-99180fca5776", "type": "Port", "port_id": "8eeaf283-2181-479b-ad61-5d13576d813b", "created_at": "2025-12-30T16:21:07.815747Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "83368d0b-b045-4e1e-bdb2-c6ed1633f387", "updated_at": "2025-12-30T16:21:07.815747Z", "interface_id": "9b7eb53d-66fa-4898-a52c-6ad15eca987e"}], "created_at": "2025-12-30T16:21:07.815750Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:07.815750Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "eee9ecf0-556d-44e1-8052-7245404e7482", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:21:40.724931780Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "0cb63aa1-7d8f-4a38-abbc-fcb0b337c8bf", "bindings": [{"id": "be4efb8a-1228-4cf9-8062-7c49a5307003", "type": "Port", "port_id": "5fde4b95-1603-49a3-98e5-a483e37909ff", "created_at": "2025-12-30T16:21:40.724945Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "eee9ecf0-556d-44e1-8052-7245404e7482", "updated_at": "2025-12-30T16:21:40.724945Z", "interface_id": "f88bcbbf-b304-42a1-b996-4b72058a4fcc"}], "created_at": "2025-12-30T16:21:40.724950Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:40.724950Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "572a7faf-3857-4ae8-9f39-f0f170f46e1c", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-30T16:21:46.763649896Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8eef1091-8d0a-48d9-acc3-f9bbf1806696", "bindings": [{"id": "e50b0d66-6ef4-435a-a0b0-90c1314fab1d", "type": "Port", "port_id": "4bbea3aa-d6ed-4a33-ac16-c1e6a5b9f464", "created_at": "2025-12-30T16:21:46.763666Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "572a7faf-3857-4ae8-9f39-f0f170f46e1c", "updated_at": "2025-12-30T16:21:46.763666Z", "interface_id": "b8ba8476-bfa8-4dc1-b460-92c35c535aee"}], "created_at": "2025-12-30T16:21:46.763670Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:46.763670Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "1ffeea63-c6d9-4663-b44b-e7eb1e96dd22", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:21:55.569196005Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8eef1091-8d0a-48d9-acc3-f9bbf1806696", "bindings": [{"id": "df642576-2266-46b5-949b-a2596122c5d8", "type": "Port", "port_id": "4cfd6a4d-80ec-49a2-a06b-3fc66b434d13", "created_at": "2025-12-30T16:21:55.569226Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "1ffeea63-c6d9-4663-b44b-e7eb1e96dd22", "updated_at": "2025-12-30T16:21:55.569226Z", "interface_id": "b8ba8476-bfa8-4dc1-b460-92c35c535aee"}], "created_at": "2025-12-30T16:21:55.569231Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:21:55.569231Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "1b5d4b0b-5ac7-417a-adfc-c803952e6290", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:22:10.554522888Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "fcac99a3-5059-45f7-9f94-0ec2fd95876e", "bindings": [{"id": "4e9d266e-8c0c-48b5-bb9f-9eb1aafad50b", "type": "Port", "port_id": "8057edcf-c5fd-4a2e-8317-387ea7d8cec8", "created_at": "2025-12-30T16:22:10.554537Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "1b5d4b0b-5ac7-417a-adfc-c803952e6290", "updated_at": "2025-12-30T16:22:10.554537Z", "interface_id": "d1dd33b7-26a7-49ce-a793-3e7741398d33"}], "created_at": "2025-12-30T16:22:10.554543Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:22:10.554543Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "4a8c019a-d34b-438e-9cc2-d75e3516b36a", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-30T16:22:22.555248654Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "bcdf5db3-5750-4fb6-a4e5-329eac1036d6", "bindings": [{"id": "ddfc517c-9a0b-4b77-8e6a-66eb432f34ec", "type": "Port", "port_id": "ac3f4e60-8184-4d57-b865-5666fbadf72c", "created_at": "2025-12-30T16:22:22.555265Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "4a8c019a-d34b-438e-9cc2-d75e3516b36a", "updated_at": "2025-12-30T16:22:22.555265Z", "interface_id": "7ab1ad93-c908-4f49-a9de-2a155e6e0e50"}], "created_at": "2025-12-30T16:22:22.555269Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:22:22.555269Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "c07930c1-bd4e-473d-bf07-57af0b9dce61", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-30T16:22:30.632533468Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "bcdf5db3-5750-4fb6-a4e5-329eac1036d6", "bindings": [{"id": "5fe044b1-f94b-48c3-9c7c-e7ddb4c547c7", "type": "Port", "port_id": "ff99fa6e-f359-4a13-bd43-48c0b8016817", "created_at": "2025-12-30T16:22:30.632547Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "c07930c1-bd4e-473d-bf07-57af0b9dce61", "updated_at": "2025-12-30T16:22:30.632547Z", "interface_id": "7ab1ad93-c908-4f49-a9de-2a155e6e0e50"}], "created_at": "2025-12-30T16:22:30.632551Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:22:30.632551Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "da67ce20-60dd-4d84-9456-70e9094a4982", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:22:31.385465330Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "bcdf5db3-5750-4fb6-a4e5-329eac1036d6", "bindings": [{"id": "f560e8bf-58eb-4be1-805d-3fd668f4a7f5", "type": "Port", "port_id": "e3a19ae3-50e7-4a72-b26c-3ab2f5b377cb", "created_at": "2025-12-30T16:22:31.385479Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "da67ce20-60dd-4d84-9456-70e9094a4982", "updated_at": "2025-12-30T16:22:31.385479Z", "interface_id": "7ab1ad93-c908-4f49-a9de-2a155e6e0e50"}], "created_at": "2025-12-30T16:22:31.385484Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:22:31.385484Z", "virtualization": null, "service_definition": "SSH"}, {"id": "ef4e6672-86c6-49c6-b6c8-c049b16450ca", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-30T16:22:31.385839247Z", "type": "Network", "daemon_id": "6344b53b-4838-4d62-be5d-8fd79065cabe", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "bcdf5db3-5750-4fb6-a4e5-329eac1036d6", "bindings": [{"id": "b0208c3f-cef7-4a54-b47b-e3e2c5b9714a", "type": "Port", "port_id": "ddbd20f1-a6ff-4689-8787-3955a1a1638f", "created_at": "2025-12-30T16:22:31.385846Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "service_id": "ef4e6672-86c6-49c6-b6c8-c049b16450ca", "updated_at": "2025-12-30T16:22:31.385846Z", "interface_id": "7ab1ad93-c908-4f49-a9de-2a155e6e0e50"}], "created_at": "2025-12-30T16:22:31.385849Z", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:22:31.385849Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "033833eb-5abc-4445-a0eb-1b4d251c197f", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2025-12-30T16:22:31.466238Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "8750a51f-9d41-4cd6-b684-f941dec90b48", "updated_at": "2025-12-30T16:22:31.466238Z", "binding_ids": [], "description": null}]	t	2025-12-30 16:21:07.669994+00	f	\N	\N	{011eabba-8e9c-470c-8592-6f8815c9aa29,e7880b10-d86d-4ef0-a28f-c0166b129215,da7a5a50-51fc-4227-9866-a5fbdaa44572}	{b7f0d788-d920-4af3-9556-5f60d099d53b}	{879b1fd9-1dcc-4cfb-b9cf-a36c82aa63f3}	{f2be65ef-d99c-47ae-baed-8970b4ff5917}	\N	2025-12-30 16:21:07.661954+00	2025-12-30 16:22:33.223877+00	{}	[]	{}	[]	{}	[]	{}
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
7ab7aa63-fb62-4c0d-9afa-557504a0a1a7	2025-12-30 16:21:07.653547+00	2025-12-30 16:21:07.653547+00	$argon2id$v=19$m=19456,t=2,p=1$MBkdDmKGvmrJpirvyqHksg$3+4pvEnVjxZF1wP3PnyIj7gAcqtrJrnLQ63TX8yqdrQ	\N	\N	\N	user@gmail.com	6578b457-0056-42c8-a34c-150a5f4af65b	Owner	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
RYEPmcXwdsmqwZF_u276_w	\\x93c410fffa6ebb7f91c1aac976f0c5990f814581a7757365725f6964d92437616237616136332d666236322d346330642d396166612d35353735303461306131613799cd07ea1d101507ce2caaa7e8000000	2026-01-29 16:21:07.749381+00
uyRBiN68ZJ7C7a-VHiyG1Q	\\x93c410d5862c1e95afedc29e64bcde884124bb82ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92431643133656137652d376438632d343862652d396563652d306132383563643434363961a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea7757365725f6964d92437616237616136332d666236322d346330642d396166612d35353735303461306131613799cd07ea1d101620ce04725efe000000	2026-01-29 16:22:32.074604+00
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

\unrestrict iZwqhGfdEiVOCjKAjx1vuHtBymiP50QFXd0F8b0rkHRvMAfMQjqDiCLGZ8OPSC8

