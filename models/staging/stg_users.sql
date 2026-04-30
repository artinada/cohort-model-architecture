--Checking whether the year is entered as four digits and the month and day as two digits
--Pass the results of the CASE checks to the `to_date(…, format)` function
--Just in case, the CASE statement returns `null` if the date format is completely invalid

SELECT
  user_id,
  promo_signup_flag,
    case
      when date_clean(signup_datetime) ~ '^\d{1,2}-\d{1,2}-\d{4}$' then TO_DATE(date_clean(signup_datetime), 'FMDD-FMMM-YYYY')
      when date_clean(signup_datetime) ~ '^\d{1,2}-\d{1,2}-\d{2}$' then
              TO_DATE(
                  CONCAT(
                      SPLIT_PART(date_clean(signup_datetime), '-', 1), '-',
                      SPLIT_PART(date_clean(signup_datetime), '-', 2), '-20',
                      SPLIT_PART(date_clean(signup_datetime), '-', 3)
                  ),
             'DD-MM-YYYY')
        else null
	    end as signup_ts
FROM {{ ref('users_raw') }}
