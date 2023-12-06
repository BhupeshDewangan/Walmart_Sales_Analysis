CREATE TABLE "SalesData" (
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date_val DATE NOT NULL,
    time_val TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT ,
    gross_income DECIMAL(12, 4),
    rating FLOAT
);


select * from public."SalesData";

------ Feature Engineering -------------

-- time of day

select  time_val,
	(
		Case 
			when time_val between '00:00:00' and '12:00:00' then 'Morning'
			when time_val between '12:01:00' and '16:00:00' then 'Afternoon'
			else 'Evening'
		end
	) as time_of_day

from public."SalesData";


alter table "SalesData" add column time_of_day varchar(30)

update "SalesData"
set time_of_day = 
(
	Case 
		when time_val between '00:00:00' and '12:00:00' then 'Morning'
		when time_val between '12:01:00' and '16:00:00' then 'Afternoon'
		else 'Evening'
	end
);


-- Day Name ----------

-- select date_val, extract(dow from date_val) as h from public."SalesData";
-- 0, 1, 2......6, Sun, Mon.....


select date_val, to_char(date_val, 'Day') as h from public."SalesData";


alter table "SalesData" add column day_name varchar(30)

update "SalesData"
set day_name= 
(
	to_char(date_val, 'Day')
);


-- Month Name -------------

select date_val, to_char(date_val, 'Month') as h from public."SalesData";


alter table "SalesData" add column month_name varchar(30)

update "SalesData"
set month_name= 
(
	to_char(date_val, 'Month')
);


-- EDA -------------------------------------------------

-- Generic  Questions -----------

-- 1. How many unique cities does the data have
-- 2. In which city is each branch?

select distinct(city) as unique_city, branch from public."SalesData";


-- Prooduct Questions -----------

-- 1. How many unique product lines does the data have?

select distinct(product_line) as unique_products from public."SalesData"
-- 6
select count(distinct(product_line)) as unique_products from public."SalesData"


-- 2. What is the most common payment method?

select distinct(payment) as unique_payments from public."SalesData"

select payment, count(payment) as cnt from public."SalesData"
group by payment 
order by cnt desc limit 1

-- "Ewallet"	345

-- 3. What is the most selling product line?

select product_line, count(product_line) as cnt from public."SalesData"
group by product_line 
order by cnt desc limit 1

-- "Fashion accessories"	178

-- 4. What is the total revenue by month?

select sum(total) as total_sum, month_name FROM public."SalesData"
group by month_name
order by total_sum desc limit 1
-- January

-- 5. What month had the largest COGS?

select sum(cogs) as total_sum, month_name FROM public."SalesData"
group by month_name
order by total_sum desc limit 1
-- January

-- 6. What product line had the largest revenue?

select sum(total) as total_sum, product_line FROM public."SalesData"
group by product_line
order by total_sum desc limit 1

-- 56144.8440	"Food and beverages"

-- 7. What is the city with the largest revenue?

select sum(total) as total_sum, city FROM public."SalesData"
group by city
order by total_sum desc limit 1

-- Naypyitaw

-- 8. What product line had the largest VAT?

select round(sum(tax_pct)) as total_sum, product_line FROM public."SalesData"
group by product_line
order by total_sum desc limit 1

-- 2674	"Food and beverages"

-- 9. Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

alter table "SalesData" add column avg_prod_qua varchar(15)

select product_line, total, 
(	case
 		when total > (select avg(total) from public."SalesData") then 'Good'
 		else 'Bad'
	end 
) as sales_qua

from public."SalesData";

update "SalesData"
set avg_prod_qua = (	
	case
 		when total > (select avg(total) from public."SalesData") then 'Good'
 		else 'Bad'
	end 
);


-- 10. Which branch sold more products than average product sold?

select quantity, count(quantity) as q from public."SalesData"
group by quantity
order by q desc

-- 10	119

-- 11. What is the most common product line by gender?

select product_line, count(gender), gender
from public."SalesData"
group by product_line, gender
order by gender desc


-- 12. What is the average rating of each product line?

select round(avg(rating)) as h, product_line  FROM public."SalesData"
group by product_line
order by h desc


----- Sales Questions ------------------------


-- 1. Number of quantity made in each weekday of the week

select count(quantity) as cnt, day_name from public."SalesData"
group by day_name
order by cnt

-- 2. Number of sales made in each time of the day per weekday

select round(sum(total), 2) as cnt, time_of_day
from public."SalesData"
group by time_of_day
order by cnt desc 

-- 138370.92	"Evening"

-- 3. Which of the customer types brings the most revenue?

select round(sum(total), 2) as cnt, customer_type
from public."SalesData"
group by customer_type
order by cnt desc 

-- 164223.44	"Member"


-- 4. Which city has the largest tax percent/ VAT (**Value Added Tax**)?

select round(sum(tax_pct)) as cnt, city
from public."SalesData"
group by city
order by cnt desc 

-- 5265	"Naypyitaw"

-- 4. Which customer type pays the most in VAT?

select round(sum(tax_pct)) as cnt, customer_type
from public."SalesData"
group by customer_type
order by cnt desc 

-- 7820	"Member"


-- ------ Customer -----------

-- 1 / 2. How many unique customer types  and payment does the data have?

select distinct(customer_type) as CT
from public."SalesData"

select distinct(payment) as pay
from public."SalesData"

-- 2. What is the most common customer type?

select count(customer_type) as cnt, customer_type
from public."SalesData"
group by customer_type
order by customer_type desc

-- 4. Which customer type buys the most?

select sum(quantity) as cnt, customer_type
from public."SalesData"
group by customer_type
order by cnt desc


-- 5. What is the gender of most of the customers?

SELECT
	gender,
	COUNT(*) as gender_cnt
FROM public."SalesData"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 6. What is the gender distribution per branch?

select gender, branch, count(*) as cnt
from public."SalesData"
group by gender, branch
order by branch

-- 7. Which time of the day do customers give most ratings?

select count(rating) as cnt, time_of_day
from public."SalesData"
group by time_of_day
order by cnt desc

-- 432	"Evening"

-- 8. Which time of the day do customers give most ratings per branch?

select count(rating) as cnt, time_of_day, branch
from public."SalesData"
group by time_of_day, branch
order by branch, time_of_day


-- 9. Which day of the week has the best avg ratings?

select round(avg(rating)) as aver, day_name
from public."SalesData"
group by day_name
order by aver

-- 10. Which day of the week has the best average ratings per branch?

select avg(rating) as cnt, day_name, branch
from public."SalesData"
group by day_name, branch
order by branch, day_name


