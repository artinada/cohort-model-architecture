--The two previous tables (staging events and user cohorts) have been merged into one. 
--Event dates have been converted to the year-month format. 
--Calculated the difference in months (month_offset) between the event and the registration—the user’s tenure at the company. 
--Added filtering for events with missing dates, excluding test events (where event_type equals test_event)
SELECT
    c.user_id,
    c.cohort_month,
    c.channel,
    DATE_TRUNC('month', e.event_ts)::DATE as activity_month,
    (
      (extract(year FROM e.event_ts) - extract(year FROM c.cohort_month)) * 12 +
      (extract(month FROM e.event_ts) - extract(month FROM c.cohort_month))
    ) as month_number,
FROM {{ ref('user_cohorts') }} c
JOIN {{ ref('stg_events') }} e
    ON u.user_id = e.user_id
WHERE 
    c.activity_month >= c.cohort_month
    and e.event_ts >= u.signup_ts
    and e.event_ts is not null
    and e.event_type is not null
    and e.event_type not in ('test_event', '')
