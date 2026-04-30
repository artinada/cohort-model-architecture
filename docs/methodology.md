## Cohort Analysis Methodology
### 1. Objective
The purpose of this analysis is to evaluate user retention and engagement over time using a cohort-based approach. \
The analysis aims to:
- measure user retention across time \
- compare behavior across acquisition channels \
- identify patterns in user engagement \
- detect potential data quality and methodological limitations

### 2. Data Sources
The analysis is based on two main datasets: \
**users** \
  user_id \
  signup_ts \
  channel (promo / non-promo) \
**events** \
user_id \
event_ts \
event_name

### 3. Data Modeling Approach
A layered data model is used to ensure clarity, reproducibility, and scalability: \
`raw → staging → mart → analytics`
- staging (stg): data cleaning and normalization 
- mart: business logic and metric calculations 
- analytics: final datasets for reporting

### 4. Cohort Definition
Cohorts are defined based on the user signup month: \
`cohort_month = DATE_TRUNC('month', signup_ts)` \
Each user belongs to exactly one cohort.

### 5. Activity Definition
A user is considered active in a given period if they perform at least one event within that month. \
Activity is aggregated to a monthly level: \
`activity_month = DATE_TRUNC('month', event_ts)`

### 6. Time Index (Month Offset)
Retention is calculated based on the difference between activity month and cohort month: \
`month_number = months_between(activity_month, cohort_month)` \
Where: \
`month_number = 0` → signup month \
`month_number = 1` → first month after signup \
etc.

### 7. Retention Calculation
Retention is defined as: \
`retention = active_users / cohort_size` \
Where: \
`cohort_size` = number of users in the cohort \
`active_users` = number of users active in a given month

### 8. Retention Type
The current implementation approximates monthly retention based on activity presence. \
Important considerations:
- retention may behave similarly to rolling retention if users return after inactivity 
- non-monotonic retention curves may occur due to delayed engagement

### 9. Segmentation
Users are segmented based on acquisition channel:
- promo 
- non-promo 

This segmentation is used to compare retention patterns and user quality.

### 10. Data Validation
A dedicated validation layer is used to ensure data quality and correctness of calculations. \
Key validation checks include:
- cohort size consistency 
- retention bounds (0–1) 
- monotonicity of retention curves 
- time consistency (activity ≥ signup) 
- cohort completeness (maturity of cohorts)

### 11. Limitations
- Activity is defined as any event (may overestimate engagement) 
- Retention may not be strictly monotonic due to calculation approach 
- Recent cohorts are incomplete (right-censoring effect) 
- No distinction between meaningful and low-value actions

### 12. Interpretation Guidelines
When analyzing cohort data, the following aspects are considered:
- retention curve shape (sharp drop vs gradual decline) 
- differences between segments 
- trends across cohorts over time 
- anomalies (e.g., retention increase)

### 13. Future Improvements
- introduce strict vs rolling retention comparison 
- refine definition of meaningful activity 
- add LTV and monetization metrics 
- incorporate additional segmentation (country, device, campaign)
