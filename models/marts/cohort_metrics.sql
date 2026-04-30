WITH cohort_size AS (
    SELECT
        cohort_month,
        channel,
        COUNT(DISTINCT user_id) AS users
    FROM {{ ref('user_cohorts') }}
    GROUP BY 1,2
)

SELECT
    a.cohort_month,
    a.channel,
    a.month_number,
    COUNT(DISTINCT a.user_id) AS active_users,
    COUNT(DISTINCT a.user_id) * 1.0 / cs.users AS retention
FROM {{ ref('cohort_activity') }} a
JOIN cohort_size cs
    ON a.cohort_month = cs.cohort_month
    AND a.channel = cs.channel
GROUP BY 1,2,3, cs.users
