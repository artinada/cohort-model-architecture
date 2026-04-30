SELECT *
FROM (
    SELECT
        cohort_month,
        channel,
        month_number,
        retention,
        LAG(retention) OVER (
            PARTITION BY cohort_month, channel
            ORDER BY month_number
        ) AS prev_retention
    FROM {{ ref('cohort_metrics') }}
) t
WHERE retention > prev_retention
