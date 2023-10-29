-- Q:1 what is the % of total daily calories consumed by patient 14 after 3pm Vs before 3 pm.

select
case
when cal_before_3pm=0 then 0
else (cal_after_3pm/cal_before_3pm)*100
end as percent_of_calories
from(
select(
	select sum(calorie)
from foodlog
where patientid=14
and extract (hour from datetime)>=15)as cal_after_3pm,
(select sum (calorie)
from foodlog
 where patientid=14
 and extract (hour from datetime)<15) as cal_before_3pm) as subquery

--------------------------------------------------------------------------------------------------------------------

--Q:2 Display 5 random patients with hbA1c less than 6

SELECT *
FROM "demographics"
WHERE hba1c < 6
ORDER BY RANDOM()
LIMIT 5;

--------------------------------------------------------------------------------------------------------------------

--Q:3 Generate a random series of data using any column from any table as the base

select patientid,
random() as random_series
from
"demographics"
order by random()

--------------------------------------------------------------------------------------------------------------------

--Q:4 Display the foods consumed by the youngest patient

select foodlog.logged_food
from foodlog 
where patientid=
(select patientid
from demographics
order by dob asc limit 1);

--------------------------------------------------------------------------------------------------------------------

--Q:5 Identify the patients that has letter 'h' in their first name and print the last letter of their first name.

select firstname, right(firstname,1)as last_letter_of_firstname
from demographics
where firstname like '%h%'

--------------------------------------------------------------------------------------------------------------------

--Q:6 Calculate the time spent by each patient outside the recommended blood glucose range.


select patientid, round(sum(time_outside_range_minutes)/60) as total_time_outside_range_minutes
from (select d.patientid,
extract(EPOCH from (
lead(dex.datestamp) over 
(partition by dex.patientid order by dex.datestamp) - dex.datestamp)) as time_outside_range_minutes
from demographics as d
inner join dexcom as dex 
on d.patientid = dex.patientid
where
dex.glucose_value_mgdl < 70 or dex.glucose_value_mgdl > 180
)as subquery
group by
    patientid
order by
    patientid;

--------------------------------------------------------------------------------------------------------------------

															  
--Q:7 Show the time in minutes recorded by the Dexcom for every patient.

select patientid,
sum(extract(hour from datestamp) * 60 + extract(minute from datestamp)) as Total_time_in_minutes
from dexcom
group by patientid;

--------------------------------------------------------------------------------------------------------------------

--Q:8 List all the food eaten by patient Phill Collins.

--Method 1
select patientid,logged_food as List_of_foods_Phill_Collins
from foodlog
where patientid=14


--Method 2
select demographics.firstname,foodlog.logged_food as List_of_foods_Phill_Collins
from foodlog
inner join demographics
on demographics.patientid=foodlog.patientid
where firstname='Phill'
group by demographics.firstname,foodlog.logged_food

--------------------------------------------------------------------------------------------------------------------

--Q:9 Create a stored procedure to delete the min_EDA column in the table EDA.

--create procedure
create or replace procedure delete_min_eda()
language plpgsql
as $$
begin 
Alter table eda drop column if exists min_eda;
end; $$

--call procedure
call delete_min_eda()


--------------------------------------------------------------------------------------------------------------------

--Q:10 When is the most common time of day for people to consume spinach?

select 
extract (hour from datetime) as common_time, count (*) from foodlog
where logged_food like '%spinach%'
group by datetime
order by count(*)
limit 1;

--------------------------------------------------------------------------------------------------------------------

--Q:11 Classify each patient based on their HRV range as high, low or normal.

SELECT ibi.patientid,
  (avg(rmssd_ms) * 600) AS hrv,
  CASE
    WHEN (avg(rmssd_ms) * 600) < 60 THEN 'low'
    WHEN (avg(rmssd_ms) * 600) >= 60 AND (avg(rmssd_ms) * 600) <= 100 THEN 'normal'
    WHEN (avg(rmssd_ms) * 600) > 100 THEN 'high'
  END AS hrv_range
FROM ibi
group by ibi.patientid;


--------------------------------------------------------------------------------------------------------------------

--Q:12 List full name of all patients with 'an' in either their first or last names.

select firstname, lastname as Fullname
from demographics
where firstname like '%an%' or lastname like '%an%'

--------------------------------------------------------------------------------------------------------------------

--Q:13 Display a pie chart of gender vs average HbA1c.

select gender, round (avg(hbA1c))
from demographics
group by gender;

--------------------------------------------------------------------------------------------------------------------

--Q:14 The recommended daily allowance of fiber is approximately 25 grams a day. 
--What % of this does every patient get on average?

select foodlog.patientid, firstname,lastname, round (Avg(foodlog.dietary_fiber)/25*100,2)as percent
from demographics
left join foodlog
on demographics.patientid=foodlog.patientid
group by foodlog.patientid, firstname,lastname
order by foodlog.patientid;

--------------------------------------------------------------------------------------------------------------------

--Q:15 What is the relationship between EDA and Mean HR?

select round(eda.mean_eda)as mean_eda, round(hr.mean_hr)as mean_hr
from eda 
inner join demographics
on demographics.patientid=eda.patientid
inner join hr
on demographics.patientid=hr.patientid

--find correlation coefficient

select corr(eda.mean_eda, hr.mean_hr) as correlation_coefficient
from eda
inner join hr
on eda.patientid=hr.patientid;

--------------------------------------------------------------------------------------------------------------------

--Q16: Show the patient that spent the maximum time out of range.

select patientid, count(*)as max_time_out_of_range
from dexcom
where glucose_value_mgdl <55 or glucose_value_mgdl >200
group by patientid
order by max_time_out_of_range desc
limit 1;
