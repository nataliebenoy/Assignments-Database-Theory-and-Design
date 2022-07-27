/*
 * Natalie Benoy
 * 03-06-2022
 * u6010825
 * IS 6420 Database Theory & Design
 * Assignment 4
 */


-- 1. List the top 5 states by total volume of dollar sales in the Computer product line.
select state_province, sum(ol.quantity * p.product_price)::money as computer_total_dollar_sales
from customer c
inner join order_header oh 
on c.customer_id = oh.customer_id 
left join order_line ol 
on ol.order_id = oh.order_id 
left join product p
on ol.product_id = p.product_id
where upper(p.product_line) like '%COMPUTER%'
group by state_province
order by computer_total_dollar_sales desc
limit(5)
;

-- 2. Create a seasonality report with "Winter", "Spring", "Summer", "Fall",  as the seasons.
-- List the season, product line, total quantity, and total dollar amount of sales.
-- Sort by product line and then season in chronological order ("Winter", "Spring", "Summer", "Fall").
-- You do not need to include the year.  
select product_line, sum(quantity) as total_quantity, sum(ol.quantity * p.product_price)::money as total_sales,
	case when extract(month from order_date) in (3, 4, 5) then 'spring'
	when extract(month from order_date) in (6, 7, 8) then 'summer'
	when extract(month from order_date) in (9, 10, 11) then 'fall'
	when extract(month from order_date) in (12, 1, 2) then 'winter'
	else 'other' end as season
from order_line ol 
inner join order_header oh 
on ol.order_id = oh.order_id 
left join product p 
on ol.product_id = p.product_id
group by product_line, extract(month from oh.order_date)
order by product_line, extract(month from oh.order_date) asc
;

-- 3. Create a query that uses a CASE statement and gets the following columns:
-- order_id
-- num_items   (number of items in the order)
-- num_desks   (number of desks in the order)
select oh.order_id, sum(quantity) as num_items,
	count(case when upper(p.product_name) like '%DESK%' then 1
	else 0 end) as num_desks
from order_header oh
inner join order_line ol 
on oh.order_id = ol.order_id 
left join product p 
on ol.product_id = p.product_id 
group by oh.order_id
;

-- 4. Create a query that uses a Common Table Expression (CTE) and a Window Function to get the following columns:
-- state_province
-- last_customer_name (last name of customer that placed an order most recently)
-- (Hint:  Try the RANK function. Make sure to handle customers with 3 names. )

-- I really hated this question (you didn't ask for my opinion but I'm giving it anyway)
with some_table as 
(select distinct(customer_name), state_province,
last_value (order_date) over (partition by state_province) as most_recent_order
from customer c 
inner join order_header oh 
on c.customer_id = oh.customer_id 
where order_date is not null)
select state_province,
	(select distinct(substring (customer_name from position(' ' in customer_name)))) as last_customer_name
from some_table
;

-- 5. Create the query from question #4 using a Temporary Table instead of a CTE.
-- Please include a DROP IF EXISTS statement prior to your statement that creates the Temporary Table.
drop table if exists a_table
;

create temp table a_table as 
select distinct(customer_name), state_province,
last_value (order_date) over (partition by state_province) as most_recent_order
from customer c 
inner join order_header oh 
on c.customer_id = oh.customer_id 
where order_date is not null
;

select state_province,
	(select distinct(substring (customer_name from position(' ' in customer_name)))) as last_customer_name
from a_table
;

-- 6. Create the query from question #4 using a View instead of a CTE.
-- Please include a DROP IF EXISTS statement prior to your statement that creates the View.
drop view if exists a_view
;

create view a_view as 
select distinct(customer_name), state_province,
last_value (order_date) over (partition by state_province) as most_recent_order
from customer c 
inner join order_header oh 
on c.customer_id = oh.customer_id 
where order_date is not null
;

select state_province,
	(select distinct(substring (customer_name from position(' ' in customer_name)))) as last_customer_name
from a_view
;

-- 7. Create a role named “product_administrator” with permissions to SELECT and INSERT records into the product table.
-- Create a user named “bob finance” who is a member of that role. 

create role product_administrator
login
password 'abcd'
;

grant select, insert 
on product
to product_administrator
;

create user bob_finance
;

grant product_administrator
to bob_finance
;