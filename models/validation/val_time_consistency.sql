SELECT *
FROM {{ ref('cohort_activity') }}
WHERE activity_month < cohort_month
