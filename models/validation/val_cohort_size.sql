SELECT
    cohort_month,
    channel,
    COUNT(DISTINCT user_id) AS cohort_size
FROM {{ ref('user_cohorts') }}
GROUP BY 1,2
