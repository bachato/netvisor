-- Convert legacy grouping fields to per-perspective container_rules HashMap,
-- expanded element_rules Vec, and per-perspective hide_service_categories HashMap.

-- Step 1: Build new structure from legacy fields
UPDATE topologies
SET options = jsonb_set(
    options,
    '{request}',
    (
        (options->'request')
        -- Remove legacy fields
        - 'group_docker_bridges_by_host'
        - 'left_zone_service_categories'
        - 'show_gateway_in_left_zone'
        - 'perspective_overrides'

        -- container_rules: HashMap<Perspective, Vec<GraphRule<ContainerRule>>>
        || jsonb_build_object('container_rules',
            jsonb_build_object(
                'L3Logical', (
                    -- Always include BySubnet for L3
                    jsonb_build_array(
                        jsonb_build_object('id', gen_random_uuid(), 'rule', 'BySubnet')
                    )
                    -- Conditionally include MergeDockerBridges (legacy default was true)
                    || CASE
                        WHEN COALESCE((options->'request'->>'group_docker_bridges_by_host')::boolean, true)
                        THEN jsonb_build_array(
                            jsonb_build_object('id', gen_random_uuid(), 'rule', 'MergeDockerBridges')
                        )
                        ELSE '[]'::jsonb
                    END
                ),
                'L2Physical', jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByHost')
                ),
                'Workloads', jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByHost')
                ),
                'Application', jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule',
                        jsonb_build_object('ByApplication', jsonb_build_object('tag_ids', '[]'::jsonb))
                    )
                )
            )
        )

        -- element_rules: Vec<GraphRule<ElementRule>> — full default set in correct order
        || jsonb_build_object('element_rules',
            (
                -- ByTrunkPort
                jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByTrunkPort')
                )
                -- ByVLAN
                || jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByVLAN')
                )
                -- ByPortOpStatus
                || jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByPortOpStatus')
                )
                -- ByServiceCategory: empty infra rule (server populates categories at runtime)
                || jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'rule', jsonb_build_object(
                            'ByServiceCategory', jsonb_build_object(
                                'categories', '[]'::jsonb,
                                'title', 'Infrastructure',
                                'is_infra_rule', true
                            )
                        )
                    )
                )
                -- ByTag (empty default)
                || jsonb_build_array(
                    jsonb_build_object(
                        'id', gen_random_uuid(),
                        'rule', jsonb_build_object(
                            'ByTag', jsonb_build_object('tag_ids', '[]'::jsonb, 'title', 'null'::jsonb)
                        )
                    )
                )
                -- ByHypervisor
                || jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByHypervisor')
                )
                -- ByContainerRuntime
                || jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByContainerRuntime')
                )
                -- ByStack
                || jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByStack')
                )
            )
        )

        -- hide_service_categories: HashMap<Perspective, Vec<ServiceCategory>>
        || jsonb_build_object('hide_service_categories',
            jsonb_build_object(
                'L3Logical', COALESCE(options->'request'->'hide_service_categories', '["OpenPorts"]'::jsonb),
                'L2Physical', '["OpenPorts"]'::jsonb,
                'Workloads', '["OpenPorts"]'::jsonb,
                'Application', '["OpenPorts"]'::jsonb
            )
        )
    )
)
WHERE options IS NOT NULL;

-- Step 2: Remove left_zone_title from local options and layout_mode from request
UPDATE topologies
SET options = options #- '{local,left_zone_title}' #- '{request,layout_mode}'
WHERE options IS NOT NULL;
