SELECT
    cohort_month,
    channel,
    month_number,
    ROUND(retention * 100, 2) AS retention_pct
FROM {{ ref('cohort_metrics') }}
ORDER BY cohort_month, month_number
