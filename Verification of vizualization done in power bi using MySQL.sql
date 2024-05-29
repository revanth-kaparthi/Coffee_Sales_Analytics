create database coffee_shop_sales_db;


select * from coffee_shop_sales limit 150000;

-- LETS CHANGE TEXT FORMAT IN THE COLUMN TO DATE FORMAT
SET SQL_SAFE_UPDATES = 0;


update coffee_shop_sales
set transaction_date = str_to_date(transaction_date,'%d-%m-%Y');

SET SQL_SAFE_UPDATES = 1;

describe coffee_shop_sales;

ALTER TABLE coffee_shop_sales
MODIFY column transaction_date DATE;

-- LETS CHANGE TEXT FORMAT IN THE COLUMN TO TIME FORMAT
SET SQL_SAFE_UPDATES = 0;
update coffee_shop_sales
set transaction_time = str_to_date(transaction_time,'%H.%i.%s');

SET SQL_SAFE_UPDATES = 1;
ALTER TABLE coffee_shop_sales
modify column transaction_time TIME;
describe coffee_shop_sales;

-- CHANGING THE COLUMN NAME

ALTER TABLE coffee_shop_sales
change COLUMN ï»¿transaction_id transaction_id int;
SELECT * FROM coffee_shop_sales;

-- PROJECT Q1- TOTAL SALES FOR ALL MONTHS

SELECT month(transaction_date) AS Month_Sales, concat(ROUND(SUM(unit_price * transaction_qty))/1000,"k") AS Total_Sales
FROM coffee_shop_sales
-- WHERE MONTH(transaction_date) = 5 -- FOR MAY MONTH
GROUP BY month(transaction_date); 

-- PROJECT Q2- PREVIOUS MONTH SALES(FOR MAY MONTH -APRIL , FOR APRIL MONTH-MARCH...)
SELECT 
	month(transaction_date) AS MONTH, -- GIVE MONTH 
	ROUND(SUM(unit_price * transaction_qty),1) AS Total_Sales, -- TOTAL SALES COLUMN
	(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1,0)
    OVER(ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty),1,0)
    OVER(ORDER BY MONTH(transaction_date)) * 100 AS MOM_INCREASE_PERCENTAGE
from coffee_shop_sales
WHERE MONTH(transaction_date) in (4, 5)
group by month(transaction_date)
ORDER BY MONTH(transaction_date);

-- cal total orders in each month
select * from coffee_shop_sales;

select count(transaction_id) as Total_orders from coffee_shop_sales
GROUP BY month(transaction_date);
-- for MOM increse in %

SELECT 
	month(transaction_date) AS MONTH, -- GIVE MONTH 
	ROUND(COUNT(unit_price * transaction_qty),1) AS Total_orders, -- TOTAL SALES COLUMN
	(COUNT(unit_price * transaction_qty) - LAG(COUNT(unit_price * transaction_qty),1,0)
    OVER(ORDER BY MONTH(transaction_date))) / LAG(COUNT(unit_price * transaction_qty),1,0)
    OVER(ORDER BY MONTH(transaction_date)) * 100 AS MOM_INCREASE_PERCENTAGE
from coffee_shop_sales
-- WHERE MONTH(transaction_date) in (4, 5)
group by month(transaction_date)
ORDER BY MONTH(transaction_date);

SELECT * FROM coffee_shop_sales;
SELECT SUM(transaction_qty) FROM coffee_shop_sales
WHERE month(transaction_date)=6;

-- for total quantity MOM 
-- same lines of code as before




-- for any day what are total_sales,total_orders,total_qty_sold
select sum(unit_price * transaction_qty) as total_sales,
	sum(transaction_qty) as total_order_sold,
    count(transaction_qty) as total_orders_count
from coffee_shop_sales
where transaction_date = '2023-5-18';


-- lets check sales on weekends and weekdays

select
	case when dayofweek(transaction_date) in (1,7) then 'weekdays'
    else 'weekends'
    end as Date_type,
    concat(round(sum(transaction_qty * unit_price)/1000 , 1), 'k') as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5
group by case when dayofweek(transaction_date) in (1,7) then 'weekdays'
    else 'weekends'
    end;
    
select * from coffee_shop_sales;

select
	store_location,
    concat(round(sum(unit_price * transaction_qty)/1000 ,2), 'k') as Total_sales
from coffee_shop_sales
where month(transaction_date) =5
group by store_location
order by store_location desc;

-- avg sales for a month
select avg(transaction_qty * unit_price) as Avg_sales from coffee_shop_sales;


-- but above query is wrong the correct is 
SELECT
	AVG(total_sales) AS Avg_sales
FROM (SELECT 
		SUM(transaction_qty * unit_price) AS total_sales
        FROM coffee_shop_sales
        WHERE month(transaction_date) = 5
        GROUP BY transaction_date) AS INTERNAL_QUERY;
	
    
    
    
    
-- sales for each day in a month

SELECT DAY(transaction_date) AS day_in_month , sum(transaction_qty * unit_price)
from coffee_shop_sales
where month(transaction_date) = 5
group by DAY(transaction_date)
order by DAY(transaction_date) ;

-- comparing dauly sales to avg of month sales
-- info: 1.here in 'select' we have 3 things, 2.since we cannot 2 aggregate at a time ...we kept it in 'from' and gave alias and using in 'select'
SELECT	day_of_month,total_sales,
case
	when total_sales > avg_sales then 'Above Average'
	when total_sales < avg_sales then 'Below Average'
	else 'Average'
    end as Total_sales_status
from (SELECT 
		DAY(transaction_date) AS day_of_month, 
		sum(transaction_qty * unit_price) as total_sales,
        avg(sum(transaction_qty * unit_price)) over() as avg_sales
        from coffee_shop_sales
        where month(transaction_date) = 5
        group by day(transaction_date)
        order by day(transaction_date) ) as inner_query;

-- sales across products category

select 
	product_category,
	sum(transaction_qty * unit_price) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_category
order by product_category desc;

-- top 10 products type sales
select	* from coffee_shop_sales;
select 
	product_type,
	round(sum(transaction_qty * unit_price),1) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_type
order by sum(transaction_qty * unit_price) desc
limit 10;


-- hour wise transaction sales in a day

select 
	hour(transaction_time) as In_hour,
    sum(transaction_qty * unit_price) as Total_sales
from coffee_shop_sales
-- where month(transaction_date) = 5 -- this is for any particular month
group by hour(transaction_time)
order by Total_sales;
