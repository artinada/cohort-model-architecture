SELECT
    'retention_bounds' AS check_name,
    COUNT(*) AS issues
FROM {{ ref('val_retention_bounds') }}

UNION ALL

SELECT
    'monotonicity',
    COUNT(*)
FROM {{ ref('val_monotonicity') }}
