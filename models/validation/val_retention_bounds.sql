SELECT *
FROM {{ ref('cohort_metrics') }}
WHERE retention < 0 OR retention > 1
