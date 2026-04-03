-- Convert legacy grouping boolean fields in topology options to container_rules + leaf_rules arrays
-- Rules are wrapped in GraphRule with a stable UUID identity

-- Step 1: Build container_rules and leaf_rules from legacy fields and update options.request
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
        -- Add container_rules array (GraphRule<ContainerRule>)
        || jsonb_build_object('container_rules',
            (
                -- Always include BySubnet
                jsonb_build_array(
                    jsonb_build_object('id', gen_random_uuid(), 'rule', 'BySubnet')
                )
                -- Conditionally include ByVirtualizingService (default was true)
                || CASE
                    WHEN COALESCE((options->'request'->>'group_docker_bridges_by_host')::boolean, true)
                    THEN jsonb_build_array(
                        jsonb_build_object('id', gen_random_uuid(), 'rule', 'ByVirtualizingService')
                    )
                    ELSE '[]'::jsonb
                END
            )
        )
        -- Add leaf_rules array (GraphRule<LeafRule>)
        || jsonb_build_object('leaf_rules',
            (
                -- Conditionally include ByServiceCategory
                CASE
                    WHEN jsonb_array_length(COALESCE(options->'request'->'left_zone_service_categories', '["DNS","ReverseProxy"]'::jsonb)) > 0
                    THEN jsonb_build_array(
                        jsonb_build_object(
                            'id', gen_random_uuid(),
                            'rule', jsonb_build_object(
                                'ByServiceCategory', jsonb_build_object(
                                    'categories', COALESCE(options->'request'->'left_zone_service_categories', '["DNS","ReverseProxy"]'::jsonb),
                                    'title', COALESCE(options->'local'->>'left_zone_title', 'Infrastructure')
                                )
                            )
                        )
                    )
                    ELSE '[]'::jsonb
                END
            )
        )
    )
)
WHERE options IS NOT NULL;

-- Step 2: Remove left_zone_title from local options and layout_mode from request
UPDATE topologies
SET options = options #- '{local,left_zone_title}' #- '{request,layout_mode}'
WHERE options IS NOT NULL;
