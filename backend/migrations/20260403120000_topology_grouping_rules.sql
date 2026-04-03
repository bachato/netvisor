-- Convert legacy grouping boolean fields in topology options to grouping_rules array
-- Also remove left_zone_title from local options (title now lives on GroupingRule variants)

-- Step 1: Build grouping_rules from legacy fields and update options.request
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
        -- Add grouping_rules array
        || jsonb_build_object('grouping_rules',
            (
                -- Always include BySubnet
                '[{"BySubnet": {"title": null}}]'::jsonb
                -- Conditionally include ByVirtualizingService (default was true)
                || CASE
                    WHEN COALESCE((options->'request'->>'group_docker_bridges_by_host')::boolean, true)
                    THEN '[{"ByVirtualizingService": {"title": null}}]'::jsonb
                    ELSE '[]'::jsonb
                END
                -- Conditionally include ByServiceCategory
                || CASE
                    WHEN jsonb_array_length(COALESCE(options->'request'->'left_zone_service_categories', '["DNS","ReverseProxy"]'::jsonb)) > 0
                    THEN jsonb_build_array(
                        jsonb_build_object(
                            'ByServiceCategory', jsonb_build_object(
                                'categories', COALESCE(options->'request'->'left_zone_service_categories', '["DNS","ReverseProxy"]'::jsonb),
                                'title', COALESCE(options->'local'->>'left_zone_title', 'Infrastructure')
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

-- Step 2: Remove left_zone_title from local options
UPDATE topologies
SET options = options #- '{local,left_zone_title}'
WHERE options IS NOT NULL;
