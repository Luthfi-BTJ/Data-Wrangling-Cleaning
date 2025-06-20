--create database covid_indonesia

CREATE TABLE public.covid19 (
	"Date" varchar(50) NULL,
	"Location ISO Code" varchar(50) NULL,
	"Location" varchar(50) NULL,
	"New Cases" int4 NULL,
	"New Deaths" int4 NULL,
	"New Recovered" int4 NULL,
	"New Active Cases" int4 NULL,
	"Total Cases" int4 NULL,
	"Total Deaths" int4 NULL,
	"Total Recovered" int4 NULL,
	"Total Active Cases" int4 NULL,
	"Location Level" varchar(50) NULL,
	"City or Regency" varchar(50) NULL,
	province varchar(50) NULL,
	country varchar(50) NULL,
	continent varchar(50) NULL,
	island varchar(50) NULL,
	"Time Zone" varchar(50) NULL,
	"Special Status" varchar(50) NULL,
	"Total Regencies" int4 NULL,
	"Total Cities" int4 NULL,
	"Total Districts" int4 NULL,
	"Total Urban Villages" int4 NULL,
	"Total Rural Villages" int4 NULL,
	"Area (km2)" int4 NULL,
	population int4 NULL,
	"Population Density" float4 NULL,
	longitude float4 NULL,
	latitude float4 NULL,
	"New Cases per Million" float4 NULL,
	"Total Cases per Million" float4 NULL,
	"New Deaths per Million" float4 NULL,
	"Total Deaths per Million" float4 NULL,
	"Total Deaths per 100rb" float4 NULL,
	"Case Fatality Rate" varchar(50) NULL,
	"Case Recovered Rate" varchar(50) NULL,
	"Growth Factor of New Cases" float4 NULL,
	"Growth Factor of New Deaths" float4 NULL
);

-- Drop column "City or Regency" and "Special Status"
alter table covid19 
drop column "City or Regency", 
drop column "Special Status";


-- Change data type of column "Date" into date
alter table covid19 
alter column "Date" type Date
using to_date("Date", 'MM-DD-YYYY');


-- Remove "%" and change data type into float4
alter table covid19 
alter column "Case Fatality Rate" type float4
using replace("Case Fatality Rate", '%', '')::float4;

alter table covid19 
alter column "Case Recovered Rate" type float4
using replace("Case Recovered Rate", '%', '')::float4;

-- Handle Outlier Values for 'Case Recovered Rate' and 'Case Fatality Rate' 
select 
	"Case Fatality Rate",
	"Case Recovered Rate"
from covid19
where "Case Fatality Rate" > 100 or "Case Recovered Rate" > 100

update covid19
set
	"Case Fatality Rate" = 100
where "Case Fatality Rate" > 100

update covid19
set
	"Case Recovered Rate" = 100
where "Case Recovered Rate" > 100


-- Change all NaN values in 'Time Zone' into UTC+07:00
update covid19
set "Time Zone" = 'UTC+07:00'
where "Location" = 'Indonesia'

select "Location", "Time Zone" from covid19


-- Change all NaN values in 'Province' and 'Island' into Indonesia
update covid19
set province = 'Indonesia', island = 'Indonesia'
where "Location" = 'Indonesia'

select "Location", province, island from covid19


-- Change all NaN in 'Total Cities', 'Growth Factor of New Cases', and 'Growth Factor of New Deaths' with mean of each their own column

select 
	"Total Cities", 
	"Growth Factor of New Cases", 
	"Growth Factor of New Deaths"
from covid19
where "Growth Factor of New Cases" is null

update covid19
set "Total Cities" = tc_avg.tc
from (
	select 
		avg("Total Cities") as tc
	from covid19
	) as tc_avg
where "Total Cities" is null;

update covid19
set "Growth Factor of New Cases" = new_case.avg_new_case 
from (
	select 
		avg("Growth Factor of New Cases") as avg_new_case
	from covid19
	) as new_case
where "Growth Factor of New Cases" is null;

update covid19
set "Growth Factor of New Deaths" = new_death.avg_new_death
from (
	select 
		avg("Growth Factor of New Deaths") as avg_new_death
	from covid19
	) as new_death
where "Growth Factor of New Deaths" is null;


-- Change all NaN in 'Total Urban Villages' and 'Total Rural Villages' with 0

select 
	"Total Urban Villages",
	"Total Rural Villages"
from covid19

update covid19
set "Total Urban Villages" = 0
where "Total Urban Villages" is null

update covid19
set "Total Rural Villages" = 0
where "Total Rural Villages" is null


select * from covid19