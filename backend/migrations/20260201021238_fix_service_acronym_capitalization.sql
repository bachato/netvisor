-- Fix acronym capitalization in service definitions
-- Affects: services table and topology snapshots

-- 1. Update services table - service_definition field (stored with quotes as JSON string)
UPDATE services
SET service_definition = '"DNS Server"'
WHERE service_definition = '"Dns Server"';

UPDATE services
SET service_definition = '"DHCP Server"'
WHERE service_definition = '"Dhcp Server"';

UPDATE services
SET service_definition = '"HP Printer"'
WHERE service_definition = '"Hp Printer"';

-- 2. Update topology snapshots - services JSONB array (no extra quotes in JSONB values)
UPDATE topologies
SET services = (
    SELECT jsonb_agg(
        CASE
            WHEN svc->>'service_definition' = 'Dns Server'
            THEN jsonb_set(svc, '{service_definition}', '"DNS Server"')
            WHEN svc->>'service_definition' = 'Dhcp Server'
            THEN jsonb_set(svc, '{service_definition}', '"DHCP Server"')
            WHEN svc->>'service_definition' = 'Hp Printer'
            THEN jsonb_set(svc, '{service_definition}', '"HP Printer"')
            ELSE svc
        END
    )
    FROM jsonb_array_elements(services) AS svc
)
WHERE services::text LIKE '%Dns Server%'
   OR services::text LIKE '%Dhcp Server%'
   OR services::text LIKE '%Hp Printer%';
