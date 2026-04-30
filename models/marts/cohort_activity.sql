SELECT
    c.user_id,
    c.cohort_month,
    c.channel,
    a.activity_month,
    (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12 +
    (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM c.cohort_month)) AS month_number
FROM {{ ref('user_cohorts') }} c
JOIN {{ ref('int_user_activity_monthly') }} a
    ON c.user_id = a.user_id
WHERE a.activity_month >= c.cohort_month
