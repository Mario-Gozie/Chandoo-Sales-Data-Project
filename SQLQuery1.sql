--Exploring the table
select * from chandoo_sales_data;
go
-- A little data cleaning
sp_rename 'chandoo_sales_data.Boxes Shipped', 'Boxes_Shipped'
sp_rename 'chandoo_sales_data.Sales Person', 'Sales_Person'

go
--Total Amount

select sum(Amount) as Total_Amount from chandoo_sales_data;

-- let me spice it up a bit by adding the dollar sign.
--NB: I am doing this because it is a single calculation. using the dollar sign turns value 
-- into strings thus affecting calculations and ordering. 
select format(sum(Amount),'C') as Total_Amount from chandoo_sales_data;

-- Total Amount per month
select month(Date) as Numerical_Month, DateName(month,Date) as Months, 
SUM(Amount) as Amount_Per_month from chandoo_sales_data
group by Month(Date),DateName(month,Date)
order by Numerical_Month;

-- Alternatively

-- Total per Month
-- NB this can be done without the dollar sign which gives a good result
-- ordering by the calculated column or when making calculations on the column.
with Total_Per_Month as (select distinct Month(Date) as Numerical_Month,
 DATENAME(month, Date) as Months,
  format(sum(Amount) over(order by Month(Date)),'C') as Total_Sales
from chandoo_sales_data)

select * from Total_Per_Month;



go
-- Top Ten Per Month

with ordered_date as (select distinct month(Date) as Numerical_Month,
datename(month,Date) as Months,Product , 
sum(Boxes_Shipped) over(partition by datename(month, Date), 
Product) 
as Total_Boxes from chandoo_sales_data),

Row_Table as (select *, ROW_NUMBER()
 over(Partition by Numerical_Month order by Total_boxes desc)
as row_num from ordered_date)

select Months, Product, Total_Boxes from Row_Table
where row_num <= 10;

go
-- Top 10 for the  Total 8 Months


select Top (10) Product, sum(Boxes_Shipped)
 as Total_Boxes_shipped
from chandoo_sales_data
group by Product
order by Total_Boxes_shipped desc;



-- Country related calculations.
-- Total Amount per country
select country, sum(Amount) as Total_Amount  from chandoo_sales_data
group by country
order by country;

-- MoM per country.
go
with Months_country_sum as (select  Month(Date) Numerical_month, 
 DATENAME(month, Date) as Months,country,
 sum(Amount) as Total_Amount,DENSE_RANK()
over(partition by country order by Month(Date) ) as Dense_ranks
 from chandoo_sales_data
group by Month(Date), DATENAME(month, Date), country),

final_sub_table as (select  Numerical_Month,Months, country, 
Total_Amount, Dense_ranks, ((Total_Amount - lag(Total_Amount)
over(Partition by country order by country))/lag(Total_Amount)
over(Partition by country order by country) * 100) as MoM
 from Months_country_sum)

 select Months, country, Total_Amount,MoM from final_sub_table;


 go 

 -- MoM irrespective of country

 with ToTal_Month_Amount as (select distinct Month(Date) as Numerical_Month,
 DATENAME(Month,Date) as Months, 
sum(Amount) over(partition by Month(Date) order by Month(Date)) as 
Total_Amount from chandoo_sales_data)

select Months, Total_Amount, round((Total_Amount - 
lag(Total_Amount) over(order by Numerical_Month))/
(lag(Total_Amount) over(order by Numerical_Month))
*100,2) as MoM from ToTal_Month_Amount ;
 go



 -- MoM for Boxes shipped

 with Total_Boxes as (select distinct MONTH(Date) as Numerical_Month, 
 DATENAME(month, Date) as Months, sum(Boxes_Shipped) 
 over(PARTITION BY DATENAME(month, Date)
 order by MONTH(Date)) as Total_Boxes
 from chandoo_sales_data)

 select Numerical_Month, Months, Total_Boxes, round((Total_Boxes - lag(Total_Boxes)
 over(order by Numerical_Month))/ lag(Total_Boxes) 
 over(order by Numerical_Month) * 100,2) as MoM
 from Total_Boxes;
 
 go
-- Sales persons calculations
select count(distinct Sales_Person) 
as No_Sales_Persons from chandoo_sales_data;

-- No of times in attendance
select Sales_Person, count(Sales_Person) as Attendance
from chandoo_sales_data
group by Sales_Person;

go
-- Attendance per Month
-- the Store operated for 8 months. lets see employees absent for a month.
with sales_person_Month as (select  distinct Sales_Person, DateName(Month,Date) as Months
 from chandoo_sales_data)

select  Sales_Person,count(Sales_Person) as Number_of_Months_Attendance
from sales_person_Month 
group by Sales_Person
having count(Sales_Person) < 8;


go
-- fish out the particular month
go

 select distinct DATENAME(month, Date) as Months from chandoo_sales_data
 where DATENAME(month, Date) Not in (
select distinct
 DATENAME(month, Date) as Months from chandoo_sales_data
 where Sales_Person = 'Dotty Strutley');

 go
