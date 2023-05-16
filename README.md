## INTRODUCTION

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/intro.png)

This is a thorough investigation of Sales Data to Address Business Issues. 
The information was obtained via YouTuber chandoo, who utilized it to demonstrate what a dashboard is and how it appears in Tableau within ten minutes.
I used the data to construct these business questions, and then I tried utilizing SQL to provide answers as well as using Tableau to produce a better and interactive Dashboard.

## TOOLS USED
* SQL
* Tableau

## SKILLS APPLIED
* Querrying with SQL (simple and Complex Querries)
* Data Cleaning with SQL
* Creating of calculated fields and Visualization with Tableau

## TABLEAU DASHBOARD LINK

You click on this [link](https://public.tableau.com/app/profile/chigozirim.nwasinachi.oguedoihu/viz/BusinessDashboard_16832365521490/TheDashboard) to see the dashboard on Tableau Public.

## BUSINESS QUESTIONS

1)  What is the Total Amount Made for the 8 months Period?
2)  What is the Total Amount Made per Month?
3)  What are the Top Ten sold Products per Month?
4)  What are the Top Ten sold Products for the 8 Months Period?
5)  show Total Amount Per Country?
6)  Calculate the MoM for each country
7)  Calculate MoM irrespecive of Country
8)  Calculate MoM for Boxes shipped
9)  How Many Sales Persons are working in this Store?
10) How Many Times have theses sales Persons been in attendance?
11) The store has operated for 8 months now, Are there People Absent for a Month what are their Names?
12) Which Month was He or she absent?

## POSSIBLE STAKEHOLDERS

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/stakeholders.jpg)

* Suppliers
* Investors
* Employees 
* Business Owners

## A VIEW OF THE TABLE

```select * from chandoo_sales_data;```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(262).png)

## DATA CLEANING

In SQL Database, column names with spaces are not recognized unlike in Excel. Hence, I had to rename the columns with spaces for using the code below.

 * For Boxes Shipped column
```sp_rename 'chandoo_sales_data.Boxes Shipped', 'Boxes_Shipped'```
 * For Sales Person column
 ```sp_rename 'chandoo_sales_data.Sales Person', 'Sales_Person'```

 QUESTION 1
### **What is the Total Amount made for the 8 months Period?**

**The Query below was used to extract Total Amount made by the store for the 8 months Period.**

```select sum(Amount) as Total_Amount from chandoo_sales_data;```


![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(263).png)

**_Alternatively_**

 
```select format(sum(Amount),'C') as Total_Amount from chandoo_sales_data;```


![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(264).png)

_**NB**: I just spiced it up here by formatting it as currency to input the dollar sign :heart_eyes: but when I want to do serious calculations, I avoid doing this because it affect ordering and calculations at times :hushed:._


QUESTION 2

### **What is the Total Amount Made per Month?**

**The Query was used to extract total per Month.**

```
select month(Date) as Numerical_Month, DateName(month,Date) as Months, 
SUM(Amount) as Amount_Per_month from chandoo_sales_data 
group by Month(Date),DateName(month,Date) 
order by Numerical_Month;
```


![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(265).png)

**_Alternatively_**

```
with Total_Per_Month as (select distinct Month(Date) as Numerical_Month,
 DATENAME(month, Date) as Months,
  format(sum(Amount) over(order by Month(Date)),'C') as Total_Sales
from chandoo_sales_data)

select * from Total_Per_Month;
```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(280).png)

_**NB**: Aside spicing up the table by using the currency format, the main reason for this Alternative method is to show common table expression (CTE)._


QUESTION 3
### **What are the Top Ten sold Products per Month?**

**The Query below was used to extract Top 10 products (Quantity) sold per month.**

```
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
```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(266).png)

QUESTION 4
### **What are the Top Ten sold Products for the 8 Months Period?**

**The Query below was used to extract Top 10 products for the entire 8 months period.**

```
select Top (10) Product, sum(Boxes_Shipped)
 as Total_Boxes_shipped
from chandoo_sales_data
group by Product
order by Total_Boxes_shipped desc;
```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(267).png)

QUESTION 5
### **show Total Amount Per Country?**

**The Query below was used to extract Total Amount per country throughout the 8 months period.**

```
select country, sum(Amount) as Total_Amount  from chandoo_sales_data
group by country
order by country;
```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(268).png)

QUESTION 6
### **Calculate the MoM for each country**

**The Query below was used to calculate the Month over Month growth per country.**

```
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
 ```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(269).png)

NB: Its important to note that the MoM calculation is in percentage.

QUESTION 7
### **Calculate MoM irrespecive of Country**

**The Query below was used to calculate the Month over Month growth irrespective of the country.**


 ```
 with ToTal_Month_Amount as (select distinct Month(Date) as Numerical_Month,
 DATENAME(Month,Date) as Months, 
sum(Amount) over(partition by Month(Date) order by Month(Date)) as 
Total_Amount from chandoo_sales_data)

select Months, Total_Amount, round((Total_Amount - 
lag(Total_Amount) over(order by Numerical_Month))/
(lag(Total_Amount) over(order by Numerical_Month))
*100,2) as MoM from ToTal_Month_Amount ;
```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(278).png)

QUESTION 8
### **Calculate MoM for Boxes shipped**

**The Query below was used to calculate the Month over Month growth per Boxes_Shipped.**

```
with Total_Boxes as (select distinct MONTH(Date) as Numerical_Month, 
 DATENAME(month, Date) as Months, sum(Boxes_Shipped) 
 over(PARTITION BY DATENAME(month, Date)
 order by MONTH(Date)) as Total_Boxes
 from chandoo_sales_data)

 select Numerical_Month, Months, Total_Boxes, round((Total_Boxes - lag(Total_Boxes)
 over(order by Numerical_Month))/ lag(Total_Boxes) 
 over(order by Numerical_Month) * 100,2) as MoM
 from Total_Boxes;
 ```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(271).png)

QUESTION 9
### **How Many Sales Persons are working in this Store?**

**The Query below was used to extract the Number of Sales persons employed in the store.**

```
select count(distinct Sales_Person) 
as No_Sales_Persons from chandoo_sales_data;
```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(272).png)

QUESTION 10 
### **How Many Times have theses sales Persons been in attendance?**

**The Query below was uses to calculate the attendce of sales person irrepective of Month.**

```
select Sales_Person, count(Sales_Person) as Attendance
from chandoo_sales_data
group by Sales_Person;
```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(273).png)

QUESTION 11
### **The store has operated for 8 months now, Are there People Absent for a Month what are their Names?**

**The Query below was used to found out that there is a staff that was not present for a full Month and his Name.**

```
with sales_person_Month as (select  distinct Sales_Person, DateName(Month,Date) as Months
 from chandoo_sales_data)

select  Sales_Person,count(Sales_Person) as Number_of_Months_Attendance
from sales_person_Month 
group by Sales_Person
having count(Sales_Person) < 8;
```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(274).png)



QUESTION 12
### **Which Month was He or she absent?**
**The Query below was used to find out the Month _Dotty Strutley_ was Absent**

```
select distinct DATENAME(month, Date) as Months from chandoo_sales_data
 where DATENAME(month, Date) Not in (
select distinct
 DATENAME(month, Date) as Months from chandoo_sales_data
 where Sales_Person = 'Dotty Strutley');
 ```

![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Screenshot%20(275).png)

## A SCREENSHOT OF THE TABLEAU DASHBOARD

![AlT Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/The%20Dashboard.png)


## RECOMMENDATION AND CONCLUTION


![Alt Text](https://github.com/Mario-Gozie/Chandoo-Sales-Data-Project/blob/main/Images/Thanks.jpg)
