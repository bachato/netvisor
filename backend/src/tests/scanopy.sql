--
-- PostgreSQL database dump
--

\restrict Y5wX0k6TJSLNqTOqzhyJ0HJNHrJLF6fEvZ7mOgtFRRGi5ZXzTJOin00sTv7AB3Q

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
20251006215000	users	2026-01-15 20:10:23.961418+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3506504
20251006215100	networks	2026-01-15 20:10:23.965663+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4213529
20251006215151	create hosts	2026-01-15 20:10:23.970209+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3950598
20251006215155	create subnets	2026-01-15 20:10:23.974569+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3758301
20251006215201	create groups	2026-01-15 20:10:23.978675+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3995483
20251006215204	create daemons	2026-01-15 20:10:23.983163+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4227516
20251006215212	create services	2026-01-15 20:10:23.987775+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4733327
20251029193448	user-auth	2026-01-15 20:10:23.992841+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5373149
20251030044828	daemon api	2026-01-15 20:10:23.998523+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1546481
20251030170438	host-hide	2026-01-15 20:10:24.000428+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1236464
20251102224919	create discovery	2026-01-15 20:10:24.002092+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10488879
20251106235621	normalize-daemon-cols	2026-01-15 20:10:24.012886+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1799732
20251107034459	api keys	2026-01-15 20:10:24.015036+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	9084011
20251107222650	oidc-auth	2026-01-15 20:10:24.024417+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	42759513
20251110181948	orgs-billing	2026-01-15 20:10:24.067554+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10403751
20251113223656	group-enhancements	2026-01-15 20:10:24.078336+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	996036
20251117032720	daemon-mode	2026-01-15 20:10:24.079609+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1216416
20251118143058	set-default-plan	2026-01-15 20:10:24.081198+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1375603
20251118225043	save-topology	2026-01-15 20:10:24.083181+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9150255
20251123232748	network-permissions	2026-01-15 20:10:24.092883+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2990131
20251125001342	billing-updates	2026-01-15 20:10:24.096226+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	878576
20251128035448	org-onboarding-status	2026-01-15 20:10:24.097404+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1515423
20251129180942	nfs-consolidate	2026-01-15 20:10:24.099302+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1438360
20251206052641	discovery-progress	2026-01-15 20:10:24.101175+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1604209
20251206202200	plan-fix	2026-01-15 20:10:24.10325+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	945972
20251207061341	daemon-url	2026-01-15 20:10:24.104916+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2488276
20251210045929	tags	2026-01-15 20:10:24.107792+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9056808
20251210175035	terms	2026-01-15 20:10:24.117224+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	1008036
20251213025048	hash-keys	2026-01-15 20:10:24.118632+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9809774
20251214050638	scanopy	2026-01-15 20:10:24.128873+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1644070
20251215215724	topo-scanopy-fix	2026-01-15 20:10:24.131005+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	874600
20251217153736	category rename	2026-01-15 20:10:24.132214+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1796246
20251218053111	invite-persistence	2026-01-15 20:10:24.13441+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5761132
20251219211216	create shares	2026-01-15 20:10:24.140505+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	7384686
20251220170928	permissions-cleanup	2026-01-15 20:10:24.148264+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	4296223
20251220180000	commercial-to-community	2026-01-15 20:10:24.153226+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	979114
20251221010000	cleanup subnet type	2026-01-15 20:10:24.154526+00	t	\\xb521121f3fd3a10c0de816977ac2a2ffb6118f34f8474ffb9058722abc0dc4cf5cbec83bc6ee49e79a68e6b715087f40	883365
20251221020000	remove host target	2026-01-15 20:10:24.155719+00	t	\\x77b5f8872705676ca81a5704bd1eaee90b9a52b404bdaa27a23da2ffd4858d3e131680926a5a00ad2a0d7a24ba229046	984654
20251221030000	user network access	2026-01-15 20:10:24.156973+00	t	\\x5c23f5bb6b0b8ca699a17eee6730c4197a006ca21fecc79136a5e5697b9211a81b4cd08ceda70dace6a26408d021ff3a	7151572
20251221040000	interfaces table	2026-01-15 20:10:24.164456+00	t	\\xf7977b6f1e7e5108c614397d03a38c9bd9243fdc422575ec29610366a0c88f443de2132185878d8e291f06a50a8c3244	10459304
20251221050000	ports table	2026-01-15 20:10:24.175298+00	t	\\xdf72f9306b405be7be62c39003ef38408115e740b120f24e8c78b8e136574fff7965c52023b3bc476899613fa5f4fe35	9628757
20251221060000	bindings table	2026-01-15 20:10:24.185289+00	t	\\x933648a724bd179c7f47305e4080db85342d48712cde39374f0f88cde9d7eba8fe5fafba360937331e2a8178dec420c4	11709432
20251221070000	group bindings	2026-01-15 20:10:24.197375+00	t	\\x697475802f6c42e38deee6596f4ba786b09f7b7cd91742fbc5696dd0f9b3ddfce90dd905153f2b1a9e82f959f5a88302	6945719
20251222020000	tag cascade delete	2026-01-15 20:10:24.20466+00	t	\\xabfb48c0da8522f5c8ea6d482eb5a5f4562ed41f6160a5915f0fd477c7dd0517aa84760ef99ab3a5db3e0f21b0c69b5f	1295484
20251223232524	network remove default	2026-01-15 20:10:24.206248+00	t	\\x7099fe4e52405e46269d7ce364050da930b481e72484ad3c4772fd2911d2d505476d659fa9f400c63bc287512d033e18	974405
20251225100000	color enum	2026-01-15 20:10:24.207584+00	t	\\x62cecd9d79a49835a3bea68a7959ab62aa0c1aaa7e2940dec6a7f8a714362df3649f0c1f9313672d9268295ed5a1cfa9	1270827
20251227010000	topology snapshot migration	2026-01-15 20:10:24.209154+00	t	\\xc042591d254869c0e79c8b52a9ede680fd26f094e2c385f5f017e115f5e3f31ad155f4885d095344f2642ebb70755d54	4367325
20251228010000	user api keys	2026-01-15 20:10:24.213868+00	t	\\xa41adb558a5b9d94a4e17af3f16839b83f7da072dbeac9251b12d8a84c7bec6df008009acf246468712a975bb36bb5f5	11942069
20251230160000	daemon version and maintainer	2026-01-15 20:10:24.22624+00	t	\\xafed3d9f00adb8c1b0896fb663af801926c218472a0a197f90ecdaa13305a78846a9e15af0043ec010328ba533fca68f	2705129
20260103000000	service position	2026-01-15 20:10:24.229304+00	t	\\x19d00e8c8b300d1c74d721931f4d771ec7bc4e06db0d6a78126e00785586fdc4bcff5b832eeae2fce0cb8d01e12a7fb5	1991509
20260106000000	interface mac index	2026-01-15 20:10:24.231726+00	t	\\xa26248372a1e31af46a9c6fbdaef178982229e2ceeb90cc6a289d5764f87a38747294b3adf5f21276b5d171e42bdb6ac	1891373
20260106204402	entity tags junction	2026-01-15 20:10:24.233903+00	t	\\xf73c604f9f0b8db065d990a861684b0dbd62c3ef9bead120c68431c933774de56491a53f021e79f09801680152f5a08a	12196610
20260108033856	fix entity tags json format	2026-01-15 20:10:24.246456+00	t	\\x197eaa063d4f96dd0e897ad8fd96cc1ba9a54dda40a93a5c12eac14597e4dea4c806dd0a527736fb5807b7a8870d9916	1413854
20260110000000	email verification	2026-01-15 20:10:24.248732+00	t	\\xb8da8433f58ba4ce846b9fa0c2551795747a8473ad10266b19685504847458ea69d27a0ce430151cfb426f5f5fb6ac3a	3341164
20260114145808	daemon user fk set null	2026-01-15 20:10:24.252584+00	t	\\x57b060be9fc314d7c5851c75661ca8269118feea6cf7ee9c61b147a0e117c4d39642cf0d1acdf7a723a9a76066c1b8ff	1149350
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
9867d8ba-cdc4-4101-8dbb-67cc07e5cb84	6eaf3ccb3e7617eb579b97a34f9c4794f7d126e93f842690e62b53addd8eb5cd	2da7d557-935b-4167-9f3a-6e952b2f7db2	Integrated Daemon API Key	2026-01-15 20:10:25.783437+00	2026-01-15 20:10:25.783437+00	2026-01-15 20:12:25.115928+00	\N	t
\.


--
-- Data for Name: bindings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at) FROM stdin;
ac0ee261-6441-4771-b7bf-f9e8e838c53c	2da7d557-935b-4167-9f3a-6e952b2f7db2	bdfaf5bc-5d42-4495-a397-20200a36931c	Port	7bd1c2fd-d5e3-4b90-92ee-e93398929fe7	4a1a276a-b065-4b41-94eb-aa730e802a12	2026-01-15 20:10:26.01044+00	2026-01-15 20:10:26.01044+00
55b8e12a-319c-4ced-b6d3-e9b0afc5c1b2	2da7d557-935b-4167-9f3a-6e952b2f7db2	b29ea3ae-5cec-4a0f-9822-d5efd3b74db4	Port	09d1128c-4bbf-40cc-9975-d95955973f72	9e3901b3-597b-4804-8dc6-e9d35fd786d4	2026-01-15 20:10:56.277116+00	2026-01-15 20:10:56.277116+00
c4f76d74-28d5-4284-ac19-a5c852fbacf2	2da7d557-935b-4167-9f3a-6e952b2f7db2	be137d24-1372-43c8-b056-537675e689d3	Port	09d1128c-4bbf-40cc-9975-d95955973f72	c86f77d4-af75-4c0e-b29e-1fb1bf71b84e	2026-01-15 20:11:03.342604+00	2026-01-15 20:11:03.342604+00
a112821b-290c-44f7-8974-5044513b0e44	2da7d557-935b-4167-9f3a-6e952b2f7db2	692fe682-1090-42ff-96fe-1b3869c4f182	Port	81f69448-2251-4657-88a9-1e75e93e6754	81f7e647-b9f5-42f6-89f8-e793c4dbcff7	2026-01-15 20:11:04.293779+00	2026-01-15 20:11:04.293779+00
20133649-351f-486f-9278-3fcbb5715797	2da7d557-935b-4167-9f3a-6e952b2f7db2	0e628eed-b7cc-4c8b-b589-a18cafcecf69	Port	e1dcb897-cf64-4d05-b662-2f7666c22023	9f85cbb2-1545-410c-b5c2-7778ef5ca0fd	2026-01-15 20:11:35.023398+00	2026-01-15 20:11:35.023398+00
a3af29b9-2979-4b76-bbad-9fcf0a25f467	2da7d557-935b-4167-9f3a-6e952b2f7db2	3029eade-cad0-4781-81f0-a198adde6771	Port	dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7	9a1e3ee1-9de2-492a-a08c-85ed0ff975d8	2026-01-15 20:11:39.92965+00	2026-01-15 20:11:39.92965+00
7629048a-185f-4d3b-baa6-d8b5c19f95f8	2da7d557-935b-4167-9f3a-6e952b2f7db2	08d7a659-94c5-42ad-9adb-9677d8ee412b	Port	dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7	e453cf55-0bdb-4bfc-a07c-6671caa0aedd	2026-01-15 20:11:47.850133+00	2026-01-15 20:11:47.850133+00
2d661f66-eaa4-4349-872a-ca73bffbf44b	2da7d557-935b-4167-9f3a-6e952b2f7db2	3ac5ba42-0a9b-4407-8ad8-cf90780d0c91	Port	dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7	0b763a04-651f-4d82-919d-3d1c7e026e22	2026-01-15 20:11:54.995099+00	2026-01-15 20:11:54.995099+00
8333c0b6-7eca-4e47-993c-7edb4efef648	2da7d557-935b-4167-9f3a-6e952b2f7db2	abf308b0-20e1-493c-bca6-632d9883b962	Port	dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7	db694ed5-eb2c-424b-83e8-3f1a0f99ff54	2026-01-15 20:11:54.995498+00	2026-01-15 20:11:54.995498+00
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, version, user_id) FROM stdin;
dca600d3-b6bf-4706-8796-06b3923222ec	2da7d557-935b-4167-9f3a-6e952b2f7db2	6735df3c-6346-43b7-a9ee-c154d30997ff	2026-01-15 20:10:25.889757+00	2026-01-15 20:12:09.602381+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["1a4708e4-d863-4490-aa3c-b28c9789ae7a"]}	2026-01-15 20:10:25.889757+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	0.13.6	6fd7ee2f-db24-4859-87df-39766e676047
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
54a0a402-bc97-46ed-a7f2-24aec7e740f4	2da7d557-935b-4167-9f3a-6e952b2f7db2	dca600d3-b6bf-4706-8796-06b3923222ec	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff"}	Self Report	2026-01-15 20:10:25.898875+00	2026-01-15 20:10:25.898875+00
12f7d06c-cff0-47c8-a6ea-4b16c6dfa1fd	2da7d557-935b-4167-9f3a-6e952b2f7db2	dca600d3-b6bf-4706-8796-06b3923222ec	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-15 20:10:25.908748+00	2026-01-15 20:10:25.908748+00
7e85481c-b35c-4abf-9e70-c082cd41b6bc	2da7d557-935b-4167-9f3a-6e952b2f7db2	dca600d3-b6bf-4706-8796-06b3923222ec	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "session_id": "dcfae405-e8e4-42d2-8dca-1414551cff2b", "started_at": "2026-01-15T20:10:25.908256521Z", "finished_at": "2026-01-15T20:10:26.059935943Z", "discovery_type": {"type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff"}}}	{"type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff"}	Self Report	2026-01-15 20:10:25.908256+00	2026-01-15 20:10:26.065373+00
5d044a99-4d3e-485a-80bf-3aaac748163e	2da7d557-935b-4167-9f3a-6e952b2f7db2	dca600d3-b6bf-4706-8796-06b3923222ec	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "session_id": "60e2fd87-0c4c-4e9d-b889-16de1ea82eae", "started_at": "2026-01-15T20:10:26.080450060Z", "finished_at": "2026-01-15T20:12:25.114469803Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2026-01-15 20:10:26.08045+00	2026-01-15 20:12:25.117948+00
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
3fa88db2-b3a8-4548-8c4e-d16d7f56d050	2da7d557-935b-4167-9f3a-6e952b2f7db2		\N	2026-01-15 20:12:25.130822+00	2026-01-15 20:12:25.130822+00	{"type": "Manual"}	Yellow	"SmoothStep"	RequestPath
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, source, virtualization, created_at, updated_at, hidden) FROM stdin;
6735df3c-6346-43b7-a9ee-c154d30997ff	2da7d557-935b-4167-9f3a-6e952b2f7db2	scanopy-daemon	6e8580f308b3	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T20:10:26.010422441Z", "type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec"}]}	null	2026-01-15 20:10:25.882678+00	2026-01-15 20:10:25.882678+00	f
e78dfdd5-f880-42f4-8059-67569e3b0283	2da7d557-935b-4167-9f3a-6e952b2f7db2	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T20:10:47.570510093Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-15 20:10:47.570511+00	2026-01-15 20:10:47.570511+00	f
ad9dc704-35a1-4305-aa0f-d898686b75ea	2da7d557-935b-4167-9f3a-6e952b2f7db2	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T20:11:03.447907194Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-15 20:11:03.447908+00	2026-01-15 20:11:03.447908+00	f
9fa1ab50-8f67-487d-98a2-44d4c5a21936	2da7d557-935b-4167-9f3a-6e952b2f7db2	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T20:11:19.340857300Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-15 20:11:19.340858+00	2026-01-15 20:11:19.340858+00	f
935d33fa-7922-4d16-a37b-8b65d2872f7f	2da7d557-935b-4167-9f3a-6e952b2f7db2	runnervmi13qx	runnervmi13qx	\N	{"type": "Discovery", "metadata": [{"date": "2026-01-15T20:11:39.085038731Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2026-01-15 20:11:39.08504+00	2026-01-15 20:11:39.08504+00	f
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, "position", created_at, updated_at) FROM stdin;
7bd1c2fd-d5e3-4b90-92ee-e93398929fe7	2da7d557-935b-4167-9f3a-6e952b2f7db2	6735df3c-6346-43b7-a9ee-c154d30997ff	1a4708e4-d863-4490-aa3c-b28c9789ae7a	172.25.0.4	46:fc:f3:e1:a0:71	eth0	0	2026-01-15 20:10:25.908566+00	2026-01-15 20:10:25.908566+00
09d1128c-4bbf-40cc-9975-d95955973f72	2da7d557-935b-4167-9f3a-6e952b2f7db2	e78dfdd5-f880-42f4-8059-67569e3b0283	1a4708e4-d863-4490-aa3c-b28c9789ae7a	172.25.0.5	8a:9f:78:74:8c:fb	\N	0	2026-01-15 20:10:47.570482+00	2026-01-15 20:10:47.570482+00
81f69448-2251-4657-88a9-1e75e93e6754	2da7d557-935b-4167-9f3a-6e952b2f7db2	ad9dc704-35a1-4305-aa0f-d898686b75ea	1a4708e4-d863-4490-aa3c-b28c9789ae7a	172.25.0.3	3a:f2:e1:4c:4a:21	\N	0	2026-01-15 20:11:03.44787+00	2026-01-15 20:11:03.44787+00
e1dcb897-cf64-4d05-b662-2f7666c22023	2da7d557-935b-4167-9f3a-6e952b2f7db2	9fa1ab50-8f67-487d-98a2-44d4c5a21936	1a4708e4-d863-4490-aa3c-b28c9789ae7a	172.25.0.6	6e:02:f4:ca:82:ba	\N	0	2026-01-15 20:11:19.340828+00	2026-01-15 20:11:19.340828+00
dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7	2da7d557-935b-4167-9f3a-6e952b2f7db2	935d33fa-7922-4d16-a37b-8b65d2872f7f	1a4708e4-d863-4490-aa3c-b28c9789ae7a	172.25.0.1	a6:47:b8:35:ef:86	\N	0	2026-01-15 20:11:39.084983+00	2026-01-15 20:11:39.084983+00
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
2da7d557-935b-4167-9f3a-6e952b2f7db2	My Network	2026-01-15 20:10:25.764739+00	2026-01-15 20:10:25.764739+00	14153bac-e24b-4337-9dc8-c1d71f9da398
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
14153bac-e24b-4337-9dc8-c1d71f9da398	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2026-01-15 20:10:25.755643+00	2026-01-15 20:10:25.755643+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at) FROM stdin;
4a1a276a-b065-4b41-94eb-aa730e802a12	2da7d557-935b-4167-9f3a-6e952b2f7db2	6735df3c-6346-43b7-a9ee-c154d30997ff	60073	Tcp	Custom	2026-01-15 20:10:26.01022+00	2026-01-15 20:10:26.01022+00
9e3901b3-597b-4804-8dc6-e9d35fd786d4	2da7d557-935b-4167-9f3a-6e952b2f7db2	e78dfdd5-f880-42f4-8059-67569e3b0283	8123	Tcp	Custom	2026-01-15 20:10:56.277106+00	2026-01-15 20:10:56.277106+00
c86f77d4-af75-4c0e-b29e-1fb1bf71b84e	2da7d557-935b-4167-9f3a-6e952b2f7db2	e78dfdd5-f880-42f4-8059-67569e3b0283	18555	Tcp	Custom	2026-01-15 20:11:03.342594+00	2026-01-15 20:11:03.342594+00
81f7e647-b9f5-42f6-89f8-e793c4dbcff7	2da7d557-935b-4167-9f3a-6e952b2f7db2	ad9dc704-35a1-4305-aa0f-d898686b75ea	60072	Tcp	Custom	2026-01-15 20:11:04.293768+00	2026-01-15 20:11:04.293768+00
9f85cbb2-1545-410c-b5c2-7778ef5ca0fd	2da7d557-935b-4167-9f3a-6e952b2f7db2	9fa1ab50-8f67-487d-98a2-44d4c5a21936	5432	Tcp	PostgreSQL	2026-01-15 20:11:35.023388+00	2026-01-15 20:11:35.023388+00
9a1e3ee1-9de2-492a-a08c-85ed0ff975d8	2da7d557-935b-4167-9f3a-6e952b2f7db2	935d33fa-7922-4d16-a37b-8b65d2872f7f	60072	Tcp	Custom	2026-01-15 20:11:39.929639+00	2026-01-15 20:11:39.929639+00
e453cf55-0bdb-4bfc-a07c-6671caa0aedd	2da7d557-935b-4167-9f3a-6e952b2f7db2	935d33fa-7922-4d16-a37b-8b65d2872f7f	8123	Tcp	Custom	2026-01-15 20:11:47.850122+00	2026-01-15 20:11:47.850122+00
0b763a04-651f-4d82-919d-3d1c7e026e22	2da7d557-935b-4167-9f3a-6e952b2f7db2	935d33fa-7922-4d16-a37b-8b65d2872f7f	22	Tcp	Ssh	2026-01-15 20:11:54.995085+00	2026-01-15 20:11:54.995085+00
db694ed5-eb2c-424b-83e8-3f1a0f99ff54	2da7d557-935b-4167-9f3a-6e952b2f7db2	935d33fa-7922-4d16-a37b-8b65d2872f7f	5435	Tcp	Custom	2026-01-15 20:11:54.995495+00	2026-01-15 20:11:54.995495+00
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, service_definition, virtualization, source, "position") FROM stdin;
bdfaf5bc-5d42-4495-a397-20200a36931c	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:10:26.010445+00	2026-01-15 20:10:26.010445+00	Scanopy Daemon	6735df3c-6346-43b7-a9ee-c154d30997ff	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-15T20:10:26.010444341Z", "type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec"}]}	0
b29ea3ae-5cec-4a0f-9822-d5efd3b74db4	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:10:56.277119+00	2026-01-15 20:10:56.277119+00	Home Assistant	e78dfdd5-f880-42f4-8059-67569e3b0283	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T20:10:56.277100424Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
be137d24-1372-43c8-b056-537675e689d3	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:11:03.342609+00	2026-01-15 20:11:03.342609+00	Unclaimed Open Ports	e78dfdd5-f880-42f4-8059-67569e3b0283	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T20:11:03.342586699Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
692fe682-1090-42ff-96fe-1b3869c4f182	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:11:04.293782+00	2026-01-15 20:11:04.293782+00	Scanopy Server	ad9dc704-35a1-4305-aa0f-d898686b75ea	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T20:11:04.293762116Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
0e628eed-b7cc-4c8b-b589-a18cafcecf69	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:11:35.023402+00	2026-01-15 20:11:35.023402+00	PostgreSQL	9fa1ab50-8f67-487d-98a2-44d4c5a21936	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T20:11:35.023383277Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
3029eade-cad0-4781-81f0-a198adde6771	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:11:39.929654+00	2026-01-15 20:11:39.929654+00	Scanopy Server	935d33fa-7922-4d16-a37b-8b65d2872f7f	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T20:11:39.929632804Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	0
08d7a659-94c5-42ad-9adb-9677d8ee412b	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:11:47.850137+00	2026-01-15 20:11:47.850137+00	Home Assistant	935d33fa-7922-4d16-a37b-8b65d2872f7f	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T20:11:47.850115682Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	1
3ac5ba42-0a9b-4407-8ad8-cf90780d0c91	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:11:54.995105+00	2026-01-15 20:11:54.995105+00	SSH	935d33fa-7922-4d16-a37b-8b65d2872f7f	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T20:11:54.995076922Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	2
abf308b0-20e1-493c-bca6-632d9883b962	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:11:54.995501+00	2026-01-15 20:11:54.995501+00	Unclaimed Open Ports	935d33fa-7922-4d16-a37b-8b65d2872f7f	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T20:11:54.995493498Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	3
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
ae8ad5c7-5e4c-4084-99a2-493e02b02e4a	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:10:25.766318+00	2026-01-15 20:10:25.766318+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	Internet	{"type": "System"}
2164d328-dd7f-43ad-8cf7-9be259e96362	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:10:25.766321+00	2026-01-15 20:10:25.766321+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	Remote	{"type": "System"}
1a4708e4-d863-4490-aa3c-b28c9789ae7a	2da7d557-935b-4167-9f3a-6e952b2f7db2	2026-01-15 20:10:25.908537+00	2026-01-15 20:10:25.908537+00	"172.25.0.0/28"	172.25.0.0/28	\N	Lan	{"type": "Discovery", "metadata": [{"date": "2026-01-15T20:10:25.908535692Z", "type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec"}]}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
c05c9a11-236b-473d-bdc7-b85996dc8325	14153bac-e24b-4337-9dc8-c1d71f9da398	New Tag	\N	2026-01-15 20:12:25.141038+00	2026-01-15 20:12:25.141038+00	Yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags, interfaces, removed_interfaces, ports, removed_ports, bindings, removed_bindings) FROM stdin;
bbf47e6e-a8da-4585-b966-8d9012d3bef8	2da7d557-935b-4167-9f3a-6e952b2f7db2	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "6735df3c-6346-43b7-a9ee-c154d30997ff", "name": "scanopy-daemon", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T20:10:26.010422441Z", "type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec"}]}, "hostname": "6e8580f308b3", "created_at": "2026-01-15T20:10:25.882678Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:10:25.882678Z", "description": null, "virtualization": null}, {"id": "e78dfdd5-f880-42f4-8059-67569e3b0283", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T20:10:47.570510093Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "created_at": "2026-01-15T20:10:47.570511Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:10:47.570511Z", "description": null, "virtualization": null}, {"id": "ad9dc704-35a1-4305-aa0f-d898686b75ea", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T20:11:03.447907194Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "created_at": "2026-01-15T20:11:03.447908Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:03.447908Z", "description": null, "virtualization": null}, {"id": "9fa1ab50-8f67-487d-98a2-44d4c5a21936", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T20:11:19.340857300Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "created_at": "2026-01-15T20:11:19.340858Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:19.340858Z", "description": null, "virtualization": null}, {"id": "935d33fa-7922-4d16-a37b-8b65d2872f7f", "name": "runnervmi13qx", "tags": [], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T20:11:39.085038731Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "hostname": "runnervmi13qx", "created_at": "2026-01-15T20:11:39.085040Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:39.085040Z", "description": null, "virtualization": null}, {"id": "04c39721-38c1-40b7-92e6-515d3f9c9305", "name": "Service Test Host", "tags": [], "hidden": false, "source": {"type": "Manual"}, "hostname": "service-test.local", "created_at": "2026-01-15T20:12:25.867486Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:12:25.867486Z", "description": null, "virtualization": null}]	[{"id": "ae8ad5c7-5e4c-4084-99a2-493e02b02e4a", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-15T20:10:25.766318Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:10:25.766318Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "2164d328-dd7f-43ad-8cf7-9be259e96362", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2026-01-15T20:10:25.766321Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:10:25.766321Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "1a4708e4-d863-4490-aa3c-b28c9789ae7a", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2026-01-15T20:10:25.908535692Z", "type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec"}]}, "created_at": "2026-01-15T20:10:25.908537Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:10:25.908537Z", "description": null, "subnet_type": "Lan"}]	[{"id": "bdfaf5bc-5d42-4495-a397-20200a36931c", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2026-01-15T20:10:26.010444341Z", "type": "SelfReport", "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec"}]}, "host_id": "6735df3c-6346-43b7-a9ee-c154d30997ff", "bindings": [{"id": "ac0ee261-6441-4771-b7bf-f9e8e838c53c", "type": "Port", "port_id": "4a1a276a-b065-4b41-94eb-aa730e802a12", "created_at": "2026-01-15T20:10:26.010440Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "bdfaf5bc-5d42-4495-a397-20200a36931c", "updated_at": "2026-01-15T20:10:26.010440Z", "interface_id": "7bd1c2fd-d5e3-4b90-92ee-e93398929fe7"}], "position": 0, "created_at": "2026-01-15T20:10:26.010445Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:10:26.010445Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "b29ea3ae-5cec-4a0f-9822-d5efd3b74db4", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T20:10:56.277100424Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e78dfdd5-f880-42f4-8059-67569e3b0283", "bindings": [{"id": "55b8e12a-319c-4ced-b6d3-e9b0afc5c1b2", "type": "Port", "port_id": "9e3901b3-597b-4804-8dc6-e9d35fd786d4", "created_at": "2026-01-15T20:10:56.277116Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "b29ea3ae-5cec-4a0f-9822-d5efd3b74db4", "updated_at": "2026-01-15T20:10:56.277116Z", "interface_id": "09d1128c-4bbf-40cc-9975-d95955973f72"}], "position": 0, "created_at": "2026-01-15T20:10:56.277119Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:10:56.277119Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "be137d24-1372-43c8-b056-537675e689d3", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T20:11:03.342586699Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e78dfdd5-f880-42f4-8059-67569e3b0283", "bindings": [{"id": "c4f76d74-28d5-4284-ac19-a5c852fbacf2", "type": "Port", "port_id": "c86f77d4-af75-4c0e-b29e-1fb1bf71b84e", "created_at": "2026-01-15T20:11:03.342604Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "be137d24-1372-43c8-b056-537675e689d3", "updated_at": "2026-01-15T20:11:03.342604Z", "interface_id": "09d1128c-4bbf-40cc-9975-d95955973f72"}], "position": 1, "created_at": "2026-01-15T20:11:03.342609Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:03.342609Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "692fe682-1090-42ff-96fe-1b3869c4f182", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T20:11:04.293762116Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ad9dc704-35a1-4305-aa0f-d898686b75ea", "bindings": [{"id": "a112821b-290c-44f7-8974-5044513b0e44", "type": "Port", "port_id": "81f7e647-b9f5-42f6-89f8-e793c4dbcff7", "created_at": "2026-01-15T20:11:04.293779Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "692fe682-1090-42ff-96fe-1b3869c4f182", "updated_at": "2026-01-15T20:11:04.293779Z", "interface_id": "81f69448-2251-4657-88a9-1e75e93e6754"}], "position": 0, "created_at": "2026-01-15T20:11:04.293782Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:04.293782Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "0e628eed-b7cc-4c8b-b589-a18cafcecf69", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T20:11:35.023383277Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "9fa1ab50-8f67-487d-98a2-44d4c5a21936", "bindings": [{"id": "20133649-351f-486f-9278-3fcbb5715797", "type": "Port", "port_id": "9f85cbb2-1545-410c-b5c2-7778ef5ca0fd", "created_at": "2026-01-15T20:11:35.023398Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "0e628eed-b7cc-4c8b-b589-a18cafcecf69", "updated_at": "2026-01-15T20:11:35.023398Z", "interface_id": "e1dcb897-cf64-4d05-b662-2f7666c22023"}], "position": 0, "created_at": "2026-01-15T20:11:35.023402Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:35.023402Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "3029eade-cad0-4781-81f0-a198adde6771", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T20:11:39.929632804Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "935d33fa-7922-4d16-a37b-8b65d2872f7f", "bindings": [{"id": "a3af29b9-2979-4b76-bbad-9fcf0a25f467", "type": "Port", "port_id": "9a1e3ee1-9de2-492a-a08c-85ed0ff975d8", "created_at": "2026-01-15T20:11:39.929650Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "3029eade-cad0-4781-81f0-a198adde6771", "updated_at": "2026-01-15T20:11:39.929650Z", "interface_id": "dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7"}], "position": 0, "created_at": "2026-01-15T20:11:39.929654Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:39.929654Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "08d7a659-94c5-42ad-9adb-9677d8ee412b", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2026-01-15T20:11:47.850115682Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "935d33fa-7922-4d16-a37b-8b65d2872f7f", "bindings": [{"id": "7629048a-185f-4d3b-baa6-d8b5c19f95f8", "type": "Port", "port_id": "e453cf55-0bdb-4bfc-a07c-6671caa0aedd", "created_at": "2026-01-15T20:11:47.850133Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "08d7a659-94c5-42ad-9adb-9677d8ee412b", "updated_at": "2026-01-15T20:11:47.850133Z", "interface_id": "dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7"}], "position": 1, "created_at": "2026-01-15T20:11:47.850137Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:47.850137Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "3ac5ba42-0a9b-4407-8ad8-cf90780d0c91", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T20:11:54.995076922Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "935d33fa-7922-4d16-a37b-8b65d2872f7f", "bindings": [{"id": "2d661f66-eaa4-4349-872a-ca73bffbf44b", "type": "Port", "port_id": "0b763a04-651f-4d82-919d-3d1c7e026e22", "created_at": "2026-01-15T20:11:54.995099Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "3ac5ba42-0a9b-4407-8ad8-cf90780d0c91", "updated_at": "2026-01-15T20:11:54.995099Z", "interface_id": "dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7"}], "position": 2, "created_at": "2026-01-15T20:11:54.995105Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:54.995105Z", "virtualization": null, "service_definition": "SSH"}, {"id": "abf308b0-20e1-493c-bca6-632d9883b962", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2026-01-15T20:11:54.995493498Z", "type": "Network", "daemon_id": "dca600d3-b6bf-4706-8796-06b3923222ec", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "935d33fa-7922-4d16-a37b-8b65d2872f7f", "bindings": [{"id": "8333c0b6-7eca-4e47-993c-7edb4efef648", "type": "Port", "port_id": "db694ed5-eb2c-424b-83e8-3f1a0f99ff54", "created_at": "2026-01-15T20:11:54.995498Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "service_id": "abf308b0-20e1-493c-bca6-632d9883b962", "updated_at": "2026-01-15T20:11:54.995498Z", "interface_id": "dd3cd83f-4bd0-4f9e-827a-c4c6bb25c8c7"}], "position": 3, "created_at": "2026-01-15T20:11:54.995501Z", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:11:54.995501Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "3fa88db2-b3a8-4548-8c4e-d16d7f56d050", "name": "", "tags": [], "color": "Yellow", "source": {"type": "Manual"}, "created_at": "2026-01-15T20:12:25.130822Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "2da7d557-935b-4167-9f3a-6e952b2f7db2", "updated_at": "2026-01-15T20:12:25.130822Z", "binding_ids": [], "description": null}]	t	2026-01-15 20:10:25.781633+00	f	\N	\N	{72bc9c81-88cb-4d04-9ac0-c4c3de35e343,04c39721-38c1-40b7-92e6-515d3f9c9305,b73f5632-c188-4821-a48b-12948c0ac9b8}	{fdd099f6-c96b-4dea-a01f-33c38044f8d0}	{bb1ea477-2fe2-4fcc-85ff-c7f0afa2bf05}	{0f9b4b1b-e396-428f-801d-288e0ed6231a}	\N	2026-01-15 20:10:25.77031+00	2026-01-15 20:10:25.77031+00	{}	[]	{}	[]	{}	[]	{}
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
6fd7ee2f-db24-4859-87df-39766e676047	2026-01-15 20:10:25.7589+00	2026-01-15 20:10:25.7589+00	$argon2id$v=19$m=19456,t=2,p=1$UwrB5+rAyJUBMacGY/DGrg$5m2+9TXHSWK/t9/0wIH+zP0F8c6qTQc2qsjcjl1gKOk	\N	\N	\N	user@gmail.com	14153bac-e24b-4337-9dc8-c1d71f9da398	Owner	{}	\N	t	\N	\N	\N	\N
71fb8428-de44-4464-a132-cd99c746af7c	2026-01-15 20:12:26.639493+00	2026-01-15 20:12:26.639493+00	\N	\N	\N	\N	user@example.com	14153bac-e24b-4337-9dc8-c1d71f9da398	Owner	{}	\N	f	\N	\N	\N	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
N-0ADKN7mVUyaFafY4fvNA	\\x93c41034ef87639f56683255997ba30c00ed3781a7757365725f6964d92436666437656532662d646232342d343835392d383764662d33393736366536373630343799cd07ea16140a19ce3b28de9f000000	2026-01-22 20:10:25.992534+00
gmZ8nKAIGWadW1XQbJO5zg	\\x93c410ceb9936cd0555b9d661908a09c7c668282a7757365725f6964d92436666437656532662d646232342d343835392d383764662d333937363665363736303437ad70656e64696e675f736574757082a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92433386662366230352d616233622d346637342d393132622d663136363938616637633636a86f72675f6e616d65af4d79204f7267616e697a6174696f6e99cd07ea16140c19ce2c01b3d6000000	2026-01-22 20:12:25.738309+00
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

\unrestrict Y5wX0k6TJSLNqTOqzhyJ0HJNHrJLF6fEvZ7mOgtFRRGi5ZXzTJOin00sTv7AB3Q

