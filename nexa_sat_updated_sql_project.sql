--quickly view the data
select * from nexa_sat;

-- identify duplicates in the dataset
with rankeddata as (
	select *,
		row_number() over(partition by customer_id, gender, partner, dependents, senior_citizen, 
		call_duration, data_usage, plan_type, plan_level, monthly_bill_amount, 
		tenure_months, multiple_lines, tech_support,churn) as row_num
	from nexa_sat
	order by customer_id 
)
select * 
from rankeddata
where row_num >1
order by customer_id;
-- there are no duplicates in the data

-- check for null values
select
	sum(case when customer_id is null then 1 else 0 end) as customer_id_nulls,
	sum(case when gender is null then 1 else 0 end) as gender_nulls,
	sum(case when partner is null then 1 else 0 end) as partner_nulls,
	sum(case when dependents is null then 1 else 0 end) as dependents_nulls,
	sum(case when senior_citizen is null then 1 else 0 end) as senior_citizen_nulls,
	sum(case when call_duration is null then 1 else 0 end) as call_duration_nulls,
	sum(case when data_usage is null then 1 else 0 end) as data_usage_nulls,
	sum(case when plan_type is null then 1 else 0 end) as plan_type_nulls,
	sum(case when plan_level is null then 1 else 0 end) as plan_level_nulls,
	sum(case when monthly_bill_amount is null then 1 else 0 end) as monthly_bill_amount_nulls,
	sum(case when tenure_months is null then 1 else 0 end) as tenure_months_nulls,
	sum(case when multiple_lines is null then 1 else 0 end) as multiple_lines_nulls,
	sum(case when tech_support is null then 1 else 0 end) as tech_support_nulls,
	sum(case when churn is null then 1 else 0 end) as churn_nulls
from nexa_sat;
--there are no null values

-- what if there were any null values and i wanted to see what records were affected
select *
from nexa_sat
where customer_id is null 
	or gender is null 
	or partner is null 
	or dependents is null 
	or senior_citizen is null 
	or call_duration is null 
	or data_usage is null 
	or plan_type is null 
	or plan_level is null 
	or monthly_bill_amount is null 
	or tenure_months is null 
	or multiple_lines is null 
	or tech_support is null 
	or churn is null ;
--there are no null values

--check for consistency in categorical data
select distinct gender from nexa_sat;
select distinct partner from nexa_sat;
select distinct dependents from nexa_sat;
select distinct plan_type from nexa_sat;
select distinct plan_level from nexa_sat;
select distinct multiple_lines from nexa_sat;
select distinct tech_support from nexa_sat;
--there is consistency in categorical data

--check for ouliers in the numerical dataset
--what are those columns again?
select * from nexa_sat
limit 2;
-- call_duration, data_usage, monthly_bill_amount,tenure_months
--call duration
--q1 and q3
with quartiles as (
	select
		percentile_cont(0.25) within group (order by call_duration) as q1,
		percentile_cont(0.75) within group (order by call_duration) as q3
	from nexa_sat
),
--IQR, lower bound and upper bound
bounds as (
	select
		q1,
		q3,
		(q3-q1) as iqr,
		(q1-1.5 *(q3-q1)) as lower_bound,
		(q3+1.5 *(q3-q1)) as upper_bound
	from quartiles
)
-- select outliers
select
	customer_id,
	call_duration
from nexa_sat, bounds
where call_duration < bounds.lower_bound or call_duration > bounds.upper_bound
order by call_duration;
--there are no ouliers 
	
--data_usage
--q1 and q3
with quartiles as (
	select
		percentile_cont(0.25) within group (order by data_usage) as q1,
		percentile_cont(0.75) within group (order by data_usage) as q3
	from nexa_sat
),
--IQR, lower bound and upper bound
bounds as (
	select
		q1,
		q3,
		(q3-q1) as iqr,
		(q1-1.5 *(q3-q1)) as lower_bound,
		(q3+1.5 *(q3-q1)) as upper_bound
	from quartiles
)
-- select outliers
select
	customer_id,
	call_duration
from nexa_sat, bounds
where data_usage < bounds.lower_bound or data_usage > bounds.upper_bound
order by data_usage;
--there are 814 outliers
	
-- monthly_bill_amount
--q1 and q3
with quartiles as (
	select
		percentile_cont(0.25) within group (order by monthly_bill_amount) as q1,
		percentile_cont(0.75) within group (order by monthly_bill_amount) as q3
	from nexa_sat
),
--IQR, lower bound and upper bound
bounds as (
	select
		q1,
		q3,
		(q3-q1) as iqr,
		(q1-1.5 *(q3-q1)) as lower_bound,
		(q3+1.5 *(q3-q1)) as upper_bound
	from quartiles
)
-- select outliers
select
	customer_id,
	call_duration
from nexa_sat, bounds
where monthly_bill_amount < bounds.lower_bound or monthly_bill_amount > bounds.upper_bound
order by monthly_bill_amount;
-- there are 601 ouliers


--tenure_months
--q1 and q3
with quartiles as (
	select
		percentile_cont(0.25) within group (order by tenure_months) as q1,
		percentile_cont(0.75) within group (order by tenure_months) as q3
	from nexa_sat
),
--IQR, lower bound and upper bound
bounds as (
	select
		q1,
		q3,
		(q3-q1) as iqr,
		(q1-1.5 *(q3-q1)) as lower_bound,
		(q3+1.5 *(q3-q1)) as upper_bound
	from quartiles
)
-- select outliers
select
	customer_id,
	call_duration
from nexa_sat, bounds
where tenure_months < bounds.lower_bound or tenure_months > bounds.upper_bound
order by tenure_months;
-- there are no outliers

--customers who are considered outliers in both monthly_bill_amount and data_usage
-- Step 1: Calculate Q1, Q3, and IQR for both monthly_bill_amount and data_usage
WITH quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY monthly_bill_amount) AS Q1_monthly_bill,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY monthly_bill_amount) AS Q3_monthly_bill,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY data_usage) AS Q1_data_usage,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY data_usage) AS Q3_data_usage
    FROM Nexa_Sat.nexa_sat
),
iqr AS (
    SELECT
        Q1_monthly_bill,
        Q3_monthly_bill,
        Q3_monthly_bill - Q1_monthly_bill AS IQR_monthly_bill,
        Q1_data_usage,
        Q3_data_usage,
        Q3_data_usage - Q1_data_usage AS IQR_data_usage
    FROM quartiles
),
-- Step 2: Identify outliers for monthly_bill_amount and data_usage using the IQR method
outliers AS (
    SELECT
        customer_id,
        monthly_bill_amount,
        data_usage,
        CASE 
            WHEN monthly_bill_amount < q.Q1_monthly_bill - 1.5 * q.IQR_monthly_bill OR 
                 monthly_bill_amount > q.Q3_monthly_bill + 1.5 * q.IQR_monthly_bill 
            THEN 1 ELSE 0 END AS is_high_value_bill,
        CASE 
            WHEN data_usage < q.Q1_data_usage - 1.5 * q.IQR_data_usage OR 
                 data_usage > q.Q3_data_usage + 1.5 * q.IQR_data_usage 
            THEN 1 ELSE 0 END AS is_high_value_data
    FROM nexa_sat, iqr q
),
-- Step 3: Find common customers who are outliers in both columns
common_outliers AS (
    SELECT
        customer_id,
        monthly_bill_amount,
        data_usage
    FROM outliers
    WHERE is_high_value_bill = 1 AND is_high_value_data = 1
)
-- Select the common outliers
SELECT *
FROM common_outliers;
-- there are 45 customers who are considered as outliers based on their monthly_bill_amount and data_usage
-- which is 0.6 percent of the entire dataset. Additionally the monthly bills for these customers are quiet high,
-- but also seem to be legitimate records and not misatakes. Therefore taking them out of the dataset would not
-- show the real distribution of high value customers in the dataset

--create a view for customers with churn =0 
create view active_customers as 
select * 
from nexa_sat
where churn = 0;

--view columns in table again
select * from active_customers
limit 2;

-- calculating the clv
-- here we note that we could have first computed the revenue on each customer by monthly_bill_amount * tunure_months
-- next we would have looked for the correlation between the revenue and the other numerical data
-- this was done on the side and the following results were obtained:
-- Revenue                1.000000
-- Tenure_Months          0.790962
-- Monthly_Bill_Amount    0.507056
-- Data_Usage            -0.111429
-- Call_Duration         -0.269482
-- Churn                 -0.710158
-- this suggest that for this particular dataset, only the tenure_months and monthly_bill_amounts should be 
	-- considered when calculating the lifetime value of a customer

create table active_customers as
	select *
	from nexa_sat
	where churn = 0;

--add clv column in active_customers table
alter table active_customers
add column clv numeric;
-- update active_customers table and set values for cls
update active_customers
set clv = monthly_bill_amount * tenure_months;
--view active_customers with updated records
select * from active_Customers
limit 2;

--customer segmentation
--add clv segments to active_customer table
alter table active_customers
add column clv_segment TEXT;

--assign customers to the diffrent segments

with rankedcustomers as(
	select*,
		ntile(3) over (order by clv desc) as clv_quartile
	from active_customers
)
update active_customers
set clv_segment = case
						when clv_quartile =1 then 'high value'
						when clv_quartile =2 then 'moderate value'
						else 'low value'
				  end
from rankedcustomers
where active_customers.customer_id = rankedcustomers.customer_id;

--check clv column in active_customers
select * from active_customers
order by clv desc
limit 2;

--what is the count for each of these segments
select clv_segment, count(*) as frequency
from active_customers
group by clv_segment
order by 2 desc;
--the result from the clv segment based on the quartiles does not make sense

-- clv based on the average monthly bill or payment per user
ALTER TABLE active_customers
ADD COLUMN clv_segment_mean TEXT;

SELECT AVG(clv) AS mean_clv, STDDEV(clv) AS stddev_clv
FROM active_customers;

UPDATE active_customers
SET clv_segment_mean = CASE
    WHEN clv > (SELECT AVG(clv) FROM active_customers) THEN 'High Value'
    WHEN clv > (SELECT AVG(clv) FROM active_customers) - (SELECT STDDEV(clv) FROM active_customers) AND clv < (SELECT AVG(clv) FROM active_customers) THEN 'Moderate Value'
    ELSE 'Low Value'
END;

select clv_segment_mean, count(*) as frequency
from active_customers
group by clv_segment_mean
order by 2 desc;
-- what if we really wanted to see customers who have not churned but are at risk of churning

--let's add a third column for another clv segmentation
ALTER TABLE active_customers
ADD COLUMN clv_segment_avg_sd TEXT;
--calculate mean and standard deviation
SELECT AVG(clv) AS mean_clv, STDDEV(clv) AS stddev_clv
FROM active_customers;

-- Step 1: Calculate mean and standard deviation
WITH clv_stats AS (
    SELECT 
        AVG(clv) AS mean_clv, 
        STDDEV(clv) AS stddev_clv
    FROM active_customers
)
-- Step 2: Update the clv_segment_avg_sd based on the new criteria
UPDATE active_customers
SET clv_segment_avg_sd = CASE
    WHEN clv > (SELECT mean_clv + stddev_clv FROM clv_stats) THEN 'high value'
    WHEN clv >= (SELECT mean_clv FROM clv_stats) AND clv <= (SELECT mean_clv + stddev_clv FROM clv_stats) THEN 'moderate value'
    WHEN clv >= (SELECT mean_clv - stddev_clv FROM clv_stats) AND clv < (SELECT mean_clv FROM clv_stats) THEN 'low value'
    ELSE 'churn risk'
END;

--what is the count for each of these segments
select clv_segment_avg_sd, count(*) as frequency
from active_customers
group by clv_segment_avg_sd
order by 2 desc;
-- this is the segmentation that will be used
--looking at this, i think that upselling can can be for low value and moderate customers
--high value customers should be offered cross selling offers
--low risk should also be offered cross selling offers

--UPSELLING STRATEGIES
--1 upgrade to premium
SELECT customer_id
FROM active_customers
WHERE plan_level = 'Basic' 
  AND clv_segment_avg_sd IN ('high value', 'moderate value', 'low value') 
  AND monthly_bill_amount > (SELECT AVG(monthly_bill_amount) FROM active_customers)
  AND data_usage > (SELECT AVG(data_usage) FROM active_customers);

--CROSS-SELLING STRATEGIES
--1 Tech Support Services for Senior Citizens:
SELECT customer_id
FROM active_customers
WHERE senior_citizen = 1 
  AND tech_support = 'No' 
  AND dependents = 'No' 
  AND partner = 'No'
  AND call_duration > (SELECT AVG(call_duration) FROM active_customers);

--2 multiple lines
SELECT customer_id
FROM active_customers
WHERE clv_segment_avg_sd IN ('low value', 'moderate value') 
  AND dependents = 'Yes' 
  AND data_usage > (SELECT AVG(data_usage) FROM active_customers);

--3 tech support services
SELECT customer_id
FROM active_customers
WHERE clv_segment_avg_sd IN ('churn risk', 'moderate Value') 
  AND tech_support = 'No' 
  AND call_duration > (SELECT AVG(call_duration) FROM active_customers);

--4 bundled services
SELECT customer_id
FROM active_customers
WHERE clv_segment_avg_sd IN ('moderate value', 'high value')
  AND tenure_months > (SELECT AVG(tenure_months) FROM active_customers);

-- Upselling Strategies

-- 1. Upgrade to Premium Plan
-- "Upgrade to our Premium plan for more data and unlimited call benefits!"

-- Cross-Selling Strategies

-- 1. Tech Support Services for Senior Citizens
-- "Enjoy 24/7 tech support for just an additional $5 per month, ensuring you have assistance whenever needed."

-- 2. Multiple Lines
-- "Add a line for your family member and get a 20% discount on your monthly bill."

-- 3. Tech Support Services for Low Risk and Moderate Value Customers
-- "Enjoy 24/7 tech support for just an additional $5 per month."

-- 4. Bundled Services
-- "Bundle your plan with home internet and save 15% on your total bill."

--STORED PROCEDURES
-- Function to identify customers for upgrading to premium plan
CREATE OR REPLACE FUNCTION upgrade_to_premium_plan()
RETURNS TABLE (customer_id TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT ac.customer_id
    FROM active_customers ac
    WHERE ac.plan_level = 'Basic' 
      AND ac.clv_segment_avg_sd IN ('high value', 'moderate value', 'low value') 
      AND ac.monthly_bill_amount > (SELECT AVG(ac2.monthly_bill_amount) FROM active_customers ac2)
      AND ac.data_usage > (SELECT AVG(ac2.data_usage) FROM active_customers ac2);
END;
$$ LANGUAGE plpgsql;

-- Test the upgrade_to_premium_plan function
SELECT * FROM upgrade_to_premium_plan();


-- Function to identify senior citizens for tech support services
CREATE OR REPLACE FUNCTION tech_support_senior_citizens()
RETURNS TABLE (customer_id TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT ac.customer_id
    FROM active_customers ac
    WHERE ac.senior_citizen = 1 
      AND ac.tech_support = 'No' 
      AND ac.dependents = 'No' 
      AND ac.partner = 'No'
      AND ac.call_duration > (SELECT AVG(ac2.call_duration) FROM active_customers ac2);
END;
$$ LANGUAGE plpgsql;

-- Test the tech_support_senior_citizens function
SELECT * FROM tech_support_senior_citizens();

-- Function to identify customers for multiple lines
CREATE OR REPLACE FUNCTION multiple_lines()
RETURNS TABLE (customer_id TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT ac.customer_id
    FROM active_customers ac
    WHERE ac.clv_segment_avg_sd IN ('low value', 'moderate value') 
      AND ac.dependents = 'Yes' 
      AND ac.data_usage > (SELECT AVG(ac2.data_usage) FROM active_customers ac2);
END;
$$ LANGUAGE plpgsql;

-- Test the multiple_lines function
SELECT * FROM multiple_lines();

-- Function to identify low risk and moderate value customers for tech support services
CREATE OR REPLACE FUNCTION tech_support_low_moderate()
RETURNS TABLE (customer_id TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT ac.customer_id
    FROM active_customers ac
    WHERE ac.clv_segment_avg_sd IN ('low value', 'moderate value') 
      AND ac.tech_support = 'No' 
      AND ac.call_duration > (SELECT AVG(ac2.call_duration) FROM active_customers ac2);
END;
$$ LANGUAGE plpgsql;

-- Test the tech_support_low_moderate function
SELECT * FROM tech_support_low_moderate();

-- Function to identify customers for bundled services
CREATE OR REPLACE FUNCTION bundled_services()
RETURNS TABLE (customer_id TEXT)
AS $$
BEGIN
    RETURN QUERY
    SELECT ac.customer_id
    FROM active_customers ac
    WHERE ac.clv_segment_avg_sd IN ('moderate value', 'high value')
      AND ac.tenure_months > (SELECT AVG(ac2.tenure_months) FROM active_customers ac2);
END;
$$ LANGUAGE plpgsql;

-- Test the bundled_services function
SELECT * FROM bundled_services();


