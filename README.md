# Cohort Model Architecture
## Overview
Measuring user retention (Retention Rate) using Google Sheets and SQL based on cohort analysis

### 1. Design Principles
A single source of truth for events (event-level).\
Clearly separated layers: raw → staging → marts.\
Explicit definitions: signup, activation, activity.\
Support for different retention types: strict / rolling.\
Flexible segmentation: channel, country, device.\
Full reproducibility (SQL + documentation).

### 2. Data model (tables)
#### Raw (ingest)
`raw.events`

user_id \
event_ts (timestamp) \
event_name \
properties (json) \
source_channel (promo / non-promo / …) 

`raw.users`

user_id \
signup_ts \
country \
device 

#### Staging (data cleaning and normalization)
`stg.events_clean`

user_id \
event_ts (UTC, normalized) \
event_name \
channel (normalized)

#### Core marts (product logic)
2.1 Activation

`mart.user_activation`

user_id \
activation_ts (MIN meaningful event) \
time_to_activation (interval) 

2.2 Activity (evidence of activity)

`mart.user_activity_monthly`

user_id \
activity_month (DATE_TRUNC) \
is_active (1) \

(aggregate any events to the “was active this month” level)

2.3 Cohorts

`mart.user_cohorts`

user_id \
cohort_month (by signup) \
channel

2.4 Cohort fact table (core of the model)

`mart.cohort_activity`

cohort_month \
activity_month \
month_number (offset) \
user_id \
channel \

👉 month_number = the difference in months between cohort_month and activity_month

`stg.users_clean`

user_id \
signup_ts \
channel (original source or attribution)

### 3. Metrics

`mart.cohort_metrics`

cohort_month \
month_number \
channel \
cohort_size \
active_users \
retention_strict \
retention_rolling 

#### How Metrics Are Calculated
*Cohort Size*
COUNT DISTINCT user_id in cohort_month

*Strict Retention*
The user is active specifically in this month_number

*Rolling Retention*
The user is active in this month or any subsequent month

### 4. SQL template (core)
Key snippet:
```SQL
WITH cohort_size AS (
    SELECT
        cohort_month,
        channel,
        COUNT(DISTINCT user_id) AS users
    FROM mart.user_cohorts
    GROUP BY 1,2
),

activity AS (
    SELECT
        c.cohort_month,
        c.channel,
        DATE_TRUNC('month', a.activity_month) AS activity_month,
        (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM c.cohort_month)) AS month_number,
        c.user_id
    FROM mart.user_cohorts c
    JOIN mart.user_activity_monthly a
        ON c.user_id = a.user_id
    WHERE a.activity_month >= c.cohort_month
)

SELECT
    cohort_month,
    channel,
    month_number,
    COUNT(DISTINCT user_id) AS active_users,
    COUNT(DISTINCT user_id) * 1.0 / cs.users AS retention
FROM activity
JOIN cohort_size cs USING (cohort_month, channel)
GROUP BY 1,2,3, cs.users
```

### 5. Mandatory “quality checks”
Specific queries/tables:

5.1 Cohort completeness \
max(month_number) for each cohort

5.2 Cohort size distribution \
check for skewness

5.3 Activation delay \
avg/median time_to_activation

5.4 Data sanity \
retention not >100% \
check for user_id duplicates

### 6. Dashboard
#### 1. Cohort heatmap
X: month_number \
Y: cohort_month \
value: retention

#### 2. Retention curves
by cohort or channel

#### 3. Cohort size (bar chart)
to see the effect of volume

#### 4. Segment comparison
promo vs non-promo

#### 5. Activation delay
boxplot

### 7. Interpretation layer

“Insights framework”:
retention curve shape \
segment differences \
cohort trends \
impact of activation
