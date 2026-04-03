-- Rename topology node type discriminators and add new type fields in stored JSONB

UPDATE topologies SET nodes = (
    SELECT jsonb_agg(
        CASE
            WHEN node->>'node_type' = 'SubnetNode' THEN
                node || jsonb_build_object(
                    'node_type', 'Container',
                    'container_type', 'Subnet'
                )
            WHEN node->>'node_type' = 'InterfaceNode' THEN
                node || jsonb_build_object(
                    'node_type', 'Element',
                    'container_id', node->>'subnet_id',
                    'element_type', 'Interface'
                )
            ELSE node
        END
    )
    FROM jsonb_array_elements(nodes) AS node
)
WHERE nodes IS NOT NULL AND jsonb_array_length(nodes) > 0;
