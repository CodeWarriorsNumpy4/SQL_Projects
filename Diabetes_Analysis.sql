--1.Display any 10 random DM patients.

select "Firstname","Lastname" from "Patients" 
order by random ()
Limit 10;

--2.Please go through the below screenshot and create the exact output. 

select "Firstname" || ' ' || "Lastname" from "Patients" where "Lastname" like 'Ma%';

--3. Write a query to get list of patients whose RPE start is at moderate intensity.

select "Patients"."Firstname","Patients"."Lastname",Round("24Hr_Day_HR"/10) as RPE 
from "Blood_Pressure" 
inner join  "Patients" 
on "Patients"."BP_ID"="Blood_Pressure"."BP_ID"
where Round("24Hr_Day_HR"/10) >= 4 and Round("24Hr_Day_HR"/10) <= 6 ;

--4. Write a query by using common table expressions and case statements to display birthyear ranges.

select (date_part ('Year', current_timestamp)-"Age")  as DOB from "Patients"

with DOB as (select (date_part ('Year', current_timestamp)-"Age") as Date_of_Birth from "Patients")
select Date_of_Birth,
case
    when Date_of_Birth between 1945 and 1955 then '1945-1955'
    when Date_of_Birth between 1956 and 1965 then '1955-1965'
    when Date_of_Birth between 1966 and 1975 then '1965-1975'
	Else 'No Range'
END as Year_Range
From DOB

-- 7.Display a list of Patient IDs and their Group whose diabetes duration is greater than 10 years.

select "Patients"."Patient_ID", "Patients"."Firstname", "Patients"."Lastname", "Group"."Group" 
from "Patients"
inner join "Group"
on "Patients"."Group_ID"= "Group"."Group_ID"
where "Diabetes_Duration"> 10

--9.Use a function to calculate the percentage of patients according to the lab visited per month.

SELECT
EXTRACT(MONTH FROM "Lab_Visit_Date") AS Month, "Lab_names",
COUNT(*) AS Lab_visits,
SUM(COUNT(*)) OVER (PARTITION BY EXTRACT(MONTH FROM "Lab_Visit_Date")) Total_Monthly_Visit,
Round(COUNT(*) * 100.00 / SUM(COUNT(*)) OVER (PARTITION BY EXTRACT(MONTH FROM "Lab_Visit_Date")),2) 
AS Visit_Percentage
FROM public."Lab_Visit"
GROUP BY EXTRACT(MONTH FROM "Lab_Visit_Date"),"Lab_names"
ORDER BY EXTRACT(MONTH FROM "Lab_Visit_Date"),"Lab_names";

--11.write a query to get the list of patients whose lipid test value is null.

SELECT "Patients"."Firstname","Patients"."Lastname","Patients"."Patient_ID"
FROM "Patients"
INNER JOIN "Link_Reference"
ON "Patients"."Link_Reference_ID" = "Link_Reference"."Link_Reference_ID"
INNER JOIN "Lipid_Lab_Test"
ON "Link_Reference"."Lipid_ID" = "Lipid_Lab_Test"."Lipid_ID"
WHERE "Lipid_Lab_Test"."Fasting_LDL" IS NULL or "Fasting_HDL" is null 
ORDER BY  public."Patients"."Firstname"

--12.Create a stored procedure to make user ids for the given patient id.

create or replace procedure GenUserID  
(patient_id int)
language plpgsql
as $$
Declare 
userID varchar (20);
usernumber Integer;
Begin
-- Generate userID based on patient_id
usernumber:= patient_id*100;
userID := 'U' || usernumber::VARCHAR;
RAISE NOTICE 'Generated User ID: %', userID;
End;
$$;

call GenUserID(25425);

--17.Create view on patient table with check constraint condition.

Create or replace view VIEW_check as
select "Firstname"
from public."Patients"
where "Firstname" like 'A%'

select * from VIEW_check

--22.Select the patient's full name with a name starting with 's' followed by any character, 
--followed by 'r', followed by any character, followed by b.

select "Patients"."Firstname","Patients"."Lastname" from "Patients"
where "Patients"."Firstname" like 's_r_b'

--27.Write a query to get a list of patients whose first names is starting with the letter T.

select "Firstname","Lastname" from public."Patients" where"Firstname" like 'T%'

--32.Write a query to calculate the running moving averages of diabetes_duration for Group 2 using the moving 
--windows/sliding dynamic average windows.

select "Patients"."Diabetes_Duration",
cast (AVG ("Patients"."Diabetes_Duration")over(
order by"Patients"."Diabetes_Duration"
rows between 10 preceding and current ROW) as numeric (10,2))
as Moving_Avg
from public."Patients"
where "Group_ID"='GRP_02'

--37.Write a query to get a list of patient IDs whose fasting glucose is 80, 85, and 89.

select "Patients"."Firstname","Patients"."Lastname","Patients"."Patient_ID","Lab_Test"."Fasting_Glucose"
from public."Patients" 
inner join public."Lab_Test"
on "Lab_Test"."Patient_ID"="Patients"."Patient_ID"
where "Lab_Test"."Fasting_Glucose" IN (80,85,89)

--42.Write a query to update id LB002 with the lab name Cultivate Lab.

update "Lab_Visit"
set "Lab_names"= 'Cultivate_Lab'
where "Lab_visit_ID"='LV002'

select * from public."Lab_Visit"

--47.Write a query to display the Patient_ID, last name, and the position of the substring 'an' 
--in the last name column for those patients who have a substring 'an'.

select "Patients"."Patient_ID", "Patients"."Lastname", Position ('an' IN "Patients"."Lastname") 
as substring_position	
from public."Patients"
								
--52.Write the query to create an Index on table Verbal_Cognitive by selecting a column and also 
--write the query drop the same index.

CREATE INDEX Index_name
on public."Verbal_Cognitive"
("VC_ID");

Drop index Index_name

--57.Write a query to display the DM patients and their high fasting triglycerides based upon their age ,
--gender and race. 

select "Patients"."Age","Gender"."Gender","Race"."Race","Patients"."Firstname","Patients"."Lastname",
"Lipid_Lab_Test"."Fasting_Triglyc"	
from public."Patients"
inner join public."Gender"
on "Patients"."Gender_ID"= "Gender"."Gender_ID"
inner join public."Race"
on "Patients"."Race_ID"="Race"."Race_ID"
inner join "Link_Reference"
On "Patients"."Link_Reference_ID" = "Link_Reference"."Link_Reference_ID"
inner join "Lab_Test"
on "Link_Reference"."Lab_ID"="Lab_Test"."Lab_ID"
inner join public."Lipid_Lab_Test"
on "Link_Reference"."Lipid_ID"="Lipid_Lab_Test"."Lipid_ID"
where "Lab_Test"."Hb_A1C">='6.5'
and public."Lipid_Lab_Test"."Fasting_Triglyc"> 200 and public."Lipid_Lab_Test"."Fasting_Triglyc"<499


--62.Write a query to get the number of patients who have normal platelets for each group.

select "Group"."Group",count ("Patients"."Patient_ID")
from "Patients" 
inner join "Group"
on "Patients"."Group_ID"="Group"."Group_ID"
inner join "Lab_Test"
on  "Lab_Test"."Patient_ID"= "Patients"."Patient_ID"
where "Lab_Test"."Platelets">=150 and "Lab_Test"."Platelets"<450
Group by "Group"."Group"	
								

--67.Write a query to get the Sum of Diabetes Duration for Group id 'GRP_02'.
							
select  sum ("Diabetes_Duration")	Total_Diabetes_Duration
from public."Patients"
where "Patients"."Group_ID"='GRP_02'


--72.Display a list of patients who are memory cognitively impaired with the GDS test and whose 
--diabetes duration is between 5 to 30. 

select "Patients"."Firstname", "Patients"."Lastname","Memory_Cognitive"."GDS"
from public."Patients"
inner join public."Link_Reference"
on "Patients"."Link_Reference_ID"= "Link_Reference"."Link_Reference_ID"
inner join public."Memory_Cognitive"
on "Link_Reference"."MC_ID"="Memory_Cognitive"."MC_ID"
where 
"Memory_Cognitive"."GDS" >15
and "Patients"."Diabetes_Duration" >=5 and "Patients"."Diabetes_Duration"<=30	
								
--77.Write a query to get comma-separated values of patient details .(Use a maximum of 6 columns 
--from different tables)

select "Patients"."Firstname" || "Patients"."Lastname" ||',' ||"Race"."Race" || ','||
"Gender"."Gender" ||','|| "Patients"."Age" ||','||"Patients"."Height"||','
||"Patients"."BMI" as CSV_Patients_Detail
from public."Patients"
inner join "Race"
on "Patients"."Race_ID"="Race"."Race_ID"
inner join "Gender"
on "Gender"."Gender_ID"="Patients"."Gender_ID";


