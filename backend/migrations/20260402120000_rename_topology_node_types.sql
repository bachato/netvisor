-- Rename topology node type discriminators and add new type fields in stored JSONB
-- Safety net: serde aliases on ContainerNode/LeafNode accept old names,
-- so this migration is for data cleanliness, not correctness.

UPDATE topologies SET nodes = (
    SELECT jsonb_agg(
        CASE
            WHEN node->>'node_type' = 'SubnetNode' THEN
                node || jsonb_build_object(
                    'node_type', 'ContainerNode',
                    'container_type', 'Subnet'
                )
            WHEN node->>'node_type' = 'InterfaceNode' THEN
                node || jsonb_build_object(
                    'node_type', 'LeafNode',
                    'container_id', node->>'subnet_id',
                    'leaf_type', 'Interface'
                )
            ELSE node
        END
    )
    FROM jsonb_array_elements(nodes) AS node
)
WHERE nodes IS NOT NULL AND jsonb_array_length(nodes) > 0;
