--Registration dates have been converted to the year-month format. 
--Added filtering for users with missing registration dates

select
  u.user_id as uuid,
  DATE_TRUNC('month', u.signup_ts)::DATE as cohort_month,
  u.promo_signup_flag as channel
from {{ ref('stg_users') }} u
where
  u.signup_ts is not null
