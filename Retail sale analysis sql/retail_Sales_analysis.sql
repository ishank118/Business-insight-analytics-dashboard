create database retail_sales_analysis;
Use retail_sales_analysis;

describe `sql - retail sales analysis_utf`;
Rename table `sql - retail sales analysis_utf` to sales;
describe sales;

alter table sales 
ADD PRIMARY KEY (transactions_id);

SHOW CREATE TABLE sales;

alter table sales 
rename column ï»¿transactions_id to transactions_id;

select * from sales;

-- Data Cleaning 
-- checking null values 
SELECT *
FROM
    sales
WHERE
    transactions_id IS NULL
        OR sale_date IS NULL
        OR sale_time IS NULL
        OR customer_id IS NULL
        OR gender IS NULL
        OR age IS NULL
        OR quantiy IS NULL
        OR price_per_unit IS NULL
        OR cogs IS NULL
        OR total_sale IS NULL;

-- Dropping null values 
Delete from sales 
WHERE
    transactions_id IS NULL
        OR sale_date IS NULL
        OR sale_time IS NULL
        OR customer_id IS NULL
        OR gender IS NULL
        OR age IS NULL
        OR quantiy IS NULL
        OR price_per_unit IS NULL
        OR cogs IS NULL
        OR total_sale IS NULL;

-- Data Exploring 
-- Total no of sales
SELECT count(*) as total_sales from sales;
-- Total quantity sold 
select sum(quantiy) as total_quantity_sold from sales;
-- Total number of users
select distinct count(customer_id) as total_users From sales;
-- Total number of unique category 
select category,count(category) from sales
group by category ; 

-- Questions
-- Write a Query to retrieve all column for sales made on  2022-11-05
select * From sales
Where sale_date = '2022-11-05';
-- Write a query to retrieve all the transactions where the category is 'Clothing' and quantity sold is more than 4 in the month of NOV - 2022

select * from sales
where category = 'Clothing'
and month(sale_date) =11 and year(sale_date) = 2022
and quantiy >= 4;

-- write a sql  query  to calculate  the total sales for each category 

SELECT 
    category, SUM(total_sale) AS net_sale,count(*) as total_orders
FROM
    sales
GROUP BY category;

-- write a sql query to find the average age of customer who purchased items from beauty category 
select avg(age) as average_age
from sales
where category ='Beauty'; 

-- write a query to find all transactions where  the total sales is greater than 1000
select * From sales 
where total_sale > 1000;

-- write a query to find toal number of transaction made by each gender in each category
select gender,category,  count(distinct transactions_id) as total_order
from sales
group by gender, category;


-- write a query to calculate the average for eachmonth  find out best selling  month in each year
select date_year,date_month,avg_sales,top_month From (
	select year(sale_date) as date_year,
	month(sale_date) as date_month,
	avg(total_sale) as avg_sales,
	Rank() over(partition by year(sale_date) order by avg(total_sale) desc) as top_month
	from sales
	group by date_year, date_month
	 
	) as t1 
where top_month = 1;

-- write a query to find top 5 customers based on their highest sales

select customer_id, sum(total_sale) as total_order_value
From sales 
group by customer_id
order by total_order_value desc
limit 5;

-- write query to find unique no of customers who purchase items from each category

select category,count(distinct customer_id) as total_no_of_customers
from sales
group by category;

-- write query to create each shift and number of order(eg morning <=12, afternoon between 12 and 7 evening >17
with hourly_sales
as
(
select *,
	case 
		when hour(sale_time)<=12 then 'morning' 
		when hour(sale_time)  between 12 and 17 then 'afternoon' 
		else 'evening'
	end as shift
from sales
)
select shift, sum(total_sale),count(transactions_id)
from hourly_sales 
group by shift ; -- used CTE to find total sales and total no of order to find the time of sale 



 