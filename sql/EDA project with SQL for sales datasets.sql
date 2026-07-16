-- =============================================================
-- Create Database
-- =============================================================

-- Drop the database if it already exists
DROP DATABASE IF EXISTS DataWarehouseAnalytics;

-- Create the database
CREATE DATABASE DataWarehouseAnalytics;

-- Use the database
USE DataWarehouseAnalytics;

-- =============================================================
-- Create Tables
-- =============================================================

CREATE TABLE dim_customers (
    customer_key INT,
    customer_id INT,
    customer_number VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    marital_status VARCHAR(50),
    gender VARCHAR(50),
    birthdate DATE,
    create_date DATE
);

CREATE TABLE dim_products (
    product_key INT,
    product_id INT,
    product_number VARCHAR(50),
    product_name VARCHAR(50),
    category_id VARCHAR(50),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    maintenance VARCHAR(50),
    cost INT,
    product_line VARCHAR(50),
    start_date DATE
);

CREATE TABLE fact_sales (
    order_number VARCHAR(50),
    product_key INT,
    customer_key INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount INT,
    quantity TINYINT,
    price INT
);

-- 1.Database exploration-- 
select * from dim_customers;
select * from dim_products;
select * from fact_sales;

select * from information_schema.tables;
select * from information_schema.columns where table_name='dim_customers';
show tables;

-- 2.Dimensions exploration-- 
select distinct country from dim_customers;

select distinct category,subcategory,product_name from dim_products order by 1,2,3;


-- 3.Date exploration-- 
select min(order_date) first_order_date,max(order_date) last_order_date,timestampdiff(month ,min(order_date),max(order_date)) as order_range_year from fact_sales;

select min(birthdate) as oldest,max(birthdate) as youngest,year(now())-year(min(birthdate))
as oldest_age,year(now())-year(max(birthdate)) as youngest_age from dim_customers;

-- 4.Measure exploration-- 

select sum(sales_amount) total_sales from fact_sales; 

select sum(quantity) total_items from fact_sales;

select avg(price) avg_price from fact_sales; 

select count(order_number) total_orders from fact_sales;

select count(distinct order_number) total_orders from fact_sales;

select count(distinct product_name) total_products from dim_products; 

select count(distinct customer_id) total_customers from dim_customers;

select count(distinct customer_key) total_customers from fact_sales;


-- Generate report to show key metrics of business-- 

select 'Total Sales' as measure_name,sum(sales_amount) as measure_value from fact_sales
union all
select 'Total quantity' as measure_name,sum(quantity) as measure_value  from fact_sales
union all
select 'Average price' as measure_name,avg(price) as measure_value  from fact_sales
union all
select 'Total orders' as measure_name,count(distinct order_number) as measure_value from fact_sales
union all
select 'Total products' as measure_name,count(distinct product_name) as measure_value from dim_products
union all
select 'Total customers' as measure_name,count( customer_key) as measure_value from dim_customers
union all
select 'Total customers that ordered' as measure_name,count(distinct customer_key) as measure_value from fact_sales;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_key) AS unique_customer_keys
FROM dim_customers;

SELECT *
FROM dim_customers
WHERE customer_key IS NULL;

SELECT DISTINCT f.customer_key
FROM fact_sales f
LEFT JOIN dim_customers d
ON f.customer_key = d.customer_key
WHERE d.customer_key IS NULL;

SELECT DISTINCT d.customer_key
FROM dim_customers d
LEFT JOIN fact_sales f
ON d.customer_key = f.customer_key
WHERE f.customer_key IS NULL;

SELECT
    COUNT(DISTINCT customer_key)
FROM dim_customers;

SELECT
    COUNT(DISTINCT customer_key)
FROM fact_sales;



-- 5.Magnitude analysis-- 
select country,count(customer_key) as total_customers from dim_customers group by country order by 2 desc;

select gender,count(customer_key) as total_customers from dim_customers group by gender order by 2 desc;

select category,count(product_key) as total_products from dim_products group by category order by 2 desc;

select category,avg(cost) as average_cost from dim_products group by category;

select p.category,sum(f.sales_amount) total_revenue
from fact_sales f 
left join dim_products p 
on p.product_key=f.product_key
group by p.category;

select c.customer_key,c.first_name,c.last_name,sum(f.sales_amount) total_revenue 
from fact_sales f
left join dim_customers c
on f.customer_key=c.customer_key
group by c.customer_key,c.first_name,c.last_name order by total_revenue desc;

select c.country,sum(f.quantity) as total_sold_items
from fact_sales f
left join dim_customers c
on c.customer_key=f.customer_key
group by c.country
order by total_sold_items desc;

-- 6.Ranking analysis-- 

select p.subcategory,sum(f.sales_amount) total_revenue
from fact_sales f 
left join dim_products p 
on p.product_key=f.product_key
group by p.subcategory order by 2 desc  limit 10;

select * from 
(select p.product_name,sum(f.sales_amount) total_revenue,
row_number() over(order by sum(f.sales_amount) desc) as rank_products
from fact_sales f 
left join dim_products p 
on p.product_key=f.product_key
group by p.product_name )t

where rank_products<=5;


select c.customer_key,c.first_name,c.last_name,sum(f.sales_amount) total_revenue 
from fact_sales f
left join dim_customers c
on f.customer_key=c.customer_key
group by c.customer_key,c.first_name,c.last_name order by total_revenue desc limit 10;


select c.customer_key,c.first_name,c.last_name,count(distinct order_number) total_revenue 
from fact_sales f
left join dim_customers c
on f.customer_key=c.customer_key
group by c.customer_key,c.first_name,c.last_name order by total_revenue limit 3;















