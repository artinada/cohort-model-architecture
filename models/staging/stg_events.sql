select
		user_id,
		event_type,
        case
          when date_clean(event_datetime) ~ '^\d{1,2}-\d{1,2}-\d{4}$' then TO_DATE(date_clean(event_datetime), 'DD-MM-YYYY')
			    when date_clean(event_datetime) ~ '^\d{1,2}-\d{1,2}-\d{2}$' then
                TO_DATE(
                    CONCAT(
                        SPLIT_PART(date_clean(event_datetime), '-', 1), '-',
                        SPLIT_PART(date_clean(event_datetime), '-', 2), '-20',
                        SPLIT_PART(date_clean(event_datetime), '-', 3)
                    ),
                    'DD-MM-YYYY'
                )
          else null
        end as event_ts
from project.cohort_events_raw
