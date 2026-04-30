--The two previous tables (staging) have been merged into one. 
--Event dates and registration dates have been converted to the year-month format. 
--Calculated the difference in months (month_offset) between the event and the registration—the user’s tenure at the company. 
--Added filtering for users with missing registration dates and events with missing dates, excluding test events (where event_type equals test_event)

select
  u.user_id as uuid,
  DATE_TRUNC('month', u.signup_ts)::DATE as cohort_month,
  DATE_TRUNC('month', e.event_ts)::DATE as activity_month,
  (
  (extract(year FROM e.event_ts) - extract(year FROM u.signup_ts)) * 12 +
  (extract(month FROM e.event_ts) - extract(month FROM u.signup_ts))
  ) as month_offset,
  u.promo_signup_flag
from {{ ref('stg_users') }} u  
join {{ ref('stg_events') }} e on u.user_id = e.user_id
where
  u.signup_ts is not null
  and e.event_ts >= u.signup_ts
  and e.event_ts is not null
  and e.event_type is not null
  and e.event_type not in ('test_event', '')
