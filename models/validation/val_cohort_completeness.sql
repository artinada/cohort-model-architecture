SELECT
    cohort_month,
    MAX(month_number) AS max_month
FROM {{ ref('cohort_activity') }}
GROUP BY 1
