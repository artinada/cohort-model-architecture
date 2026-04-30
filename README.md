# Cohort Model Architecture
## Overview
This project presents an end-to-end cohort analysis model designed to evaluate user retention and behavior over time. \
The analysis focuses on:
- user retention by cohort (monthly)
- comparison between acquisition channels (promo vs non-promo)
- identification of behavioral patterns and data limitations

### Design Principles
A single source of truth for events (event-level).\
Clearly separated layers: raw → staging → marts.\
Explicit definitions: signup, activation, activity.\
Support for different retention types: strict / rolling.\
Flexible segmentation: channel, country, device.\
Full reproducibility (SQL + documentation).

### Objectives
Build a reproducible cohort analysis model using SQL \
Compare retention across user segments \
Identify patterns in user engagement and long-term retention \
Highlight potential data biases and limitations

### Methodology
Steps: \
Data cleaning and normalization \
Cohort assignment (by signup month) \
Aggregation of user activity by month \
Calculation of retention metrics \
Segmentation by acquisition channel

Retention is calculated as: ` active_users / cohort_size `

### Data model
The analysis is based on event-level data:
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

`stg.users_clean`

user_id \
signup_ts \
channel (original source or attribution)

#### Core marts (product logic)
Key transformations: \
cohort definition based on signup month \
activity aggregated to monthly level \
calculation of month offsets (cohort index)

2.1 Activation

`mart.user_activation` \
user_id \
activation_ts (MIN meaningful event) \
time_to_activation (interval) 

2.2 Activity (evidence of activity)

`mart.user_activity_monthly` \
user_id \
activity_month (DATE_TRUNC) \
is_active (1) \

(aggregate any events to the “was active this month” level)

2.3 Cohorts

`mart.user_cohorts` \
user_id \
cohort_month (by signup) \
channel

2.4 Cohort fact table (core of the model)

`mart.cohort_activity` \
cohort_month \
activity_month \
month_number (offset) \
user_id \
channel

👉 month_number = the difference in months between cohort_month and activity_month

#### Metrics

`mart.cohort_metrics` \
cohort_month \
month_number \
channel \
cohort_size \
active_users \
retention_strict \
retention_rolling 

**How Metrics Are Calculated** \
*Cohort Size*
COUNT DISTINCT user_id in cohort_month

*Strict Retention*
The user is active specifically in this month_number

*Rolling Retention*
The user is active in this month or any subsequent month

### SQL template
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

### Data Validation
This project includes a dedicated validation layer to ensure data quality and correctness of analytical outputs. \
Validation checks include: \
cohort size consistency \
retention bounds (0–1) \
monotonicity of retention curves \
time consistency between events and cohort assignment \
completeness of cohort data

### Dashboard
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

### Project Structure

```
cohort-analysis-project/
│
├── README.md
│
├── data/
│   ├── events_raw.csv
│   └── users_raw.csv
│
├── models/
│   └── staging/
│   ├── stg_users.sql
│   └── stg_events.sql
│
│   └── marts/
│   ├── cohort_activity.sql
│   ├── cohort_metrics.sql
│   └── user_cohorts.sql
│
│   └── validation/
│   ├── val_cohort_size.sql
│   ├── val_retention_bounds.sql
│   ├── val_monotonicity.sql
│   ├── val_time_consistency.sql
│   └── schema.yml
│
│   └── analytics/
│   └── cohort_dashboard.sql
│
├── dashboard/
│   └── screenshots.png
│
├── docs/
│   └── methodology.md
│
└── results/
    └── insights.md
```

### Tools
SQL (PostgreSQL) \
DBeaver as SQL client \
Google Sheets
Looker Studio
