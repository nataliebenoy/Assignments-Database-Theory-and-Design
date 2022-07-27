/* class 6 script
 * using very large order database
 */

-- list top 10 most recent orders
select *
from order_header
where order_date is not null
order by order_date desc
limit(10);

-- count the number of orders, not including null values
select count(order_date)
from order_header;

-- count the number of customers who have placed orders in 2021
select count(distinct customer_id)
from order_header
where order_date between '01-01-2021' and '12-31-2021'
;

-- convoluted way to answer the previous question, but with year-to-date
select count(distinct customer_id)
from order_header
where extract(year from order_date) = extract(year from current_date) - 1
;

-- count the numbers of cities in Texas where customers live
select count(distinct upper(city))
from customer
where upper(state_province) = 'TEXAS' or state_province = 'TX'
;

-- find the range of dates for orders
select max(order_date) - min(order_date) as range
from order_header
;

-- how many customers have incomplete addresses?
select count(customer_id)
from customer
where city is null
or state_province is null 
or postal_code is null 
or address_line_1 is null 
;

-- average product price
select avg(product_price)::money
from product
;

-- average order quantity
select round(avg(quantity),2) as avg_quantity
from order_line
;

-- number of orders and quantity of items in feb 2019
select count(distinct order_id) as number_of_orders, sum(quantity) as quantity_of_items
from order_line
where order_id in (
	select order_id
	from order_header
	where to_char(order_date, 'Mon-YYYY') = 'Feb-2019'
);

-- find the total number of customers from CA, group by city (order by second column to get most populated cities first)
select city, count(customer_id)
from customer
where upper(state_province) IN ('CA', 'CALIFORNIA')
group by city 
order by 2 desc
;

-- list top 10 days for orders, order by number of orders descending
select count(order_id), order_date
from order_header
where order_date is not null
group by order_date
order by count(order_id) desc 
limit(10)
;

-- list days when fewer than 5 orders were placed
select order_date, count(order_id)
from order_header
where order_date is not null
group by order_date 
having count(order_id) < 5
order by count(order_id) asc
;

-- challenge question: determine customer lifetime value (in terms of number of orders, not $$$)
select customer_id, sum(order_id) as total_orders,
round((max(order_date) - min(order_date))/365,3) as years_as_customer
from order_header
where customer_id is not null 
and order_id is not null
and order_date is not null
group by customer_id 
order by total_orders desc
;

-- find total orders and total revenue in March 2019
-- use left joins for tables you're adding where you don't need all the data to exist in both tables
-- only keep everything in the left table
select count(oh.order_id) as total_orders, sum(ol.quantity * p.product_price)::money as revenue
from order_header oh
inner join order_line ol 
on oh.order_id = ol.order_id 
left join product p 
on ol.product_id = p.product_id 
left join customer c 
on oh.customer_id = c.customer_id 
where order_date between '03-01-2019' and '03-31-2019'
;

-- find top 10 customers by $$$ who have ordered printers
-- remember that you have to group by anything in the "select" statement that is not an aggregation
select c.customer_name, sum(ol.quantity * p.product_price)::money as revenue, count(oh.order_id) as orders
from customer c 
inner join order_header oh 
on oh.customer_id = c.customer_id 
left join order_line ol 
on ol.order_id = oh.order_id 
left join product p
on ol.product_id = p.product_id 
where product_name = 'Printer'
group by customer_name
having sum(ol.quantity * p.product_price) is not null
order by revenue desc 
limit(10)
;

-- challenge question 2: determine customer lifetime value (with $$$, product most frequently ordered)
select c.customer_name, c. state_province, sum(oh.order_id) as total_orders,
max(oh.order_date) - min(oh.order_date) as days_as_customer,
sum(ol.quantity * p.product_price)::money as revenue
from customer c
inner join order_header oh 
on oh.customer_id = c.customer_id 
left join order_line ol 
on ol.order_id = oh.order_id 
left join product p
on ol.product_id = p.product_id 
where c.customer_name is not null 
group by c.customer_name, c.state_province 
order by revenue desc
;

-- union all (includes duplicate records)
SELECT customer_id, customer_name FROM customer
WHERE customer_name LIKE 'J%'
UNION ALL
SELECT customer_id, customer_name FROM customer
WHERE city = 'Salt Lake City'
;

-- intersect picks out only the duplicate/overlap
SELECT customer_id, customer_name FROM customer
WHERE customer_name LIKE 'J%'
INTERSECT
SELECT customer_id, customer_name FROM customer
WHERE city = 'Salt Lake City'
;

-- CASE WHEN example
select state_province,
CASE WHEN state_province IN ('TX','TEXAS')
THEN 'Yes'
ELSE 'NO'
END AS Is_Texan
FROM customer;

-- more CASE WHEN examples
SELECT ol.order_id
, p.product_name
, p.product_price
, CASE WHEN p.product_price > 50 THEN 1
ELSE 0
END is_item_gt_50
FROM order_line ol
INNER JOIN product p
ON ol.product_id = p.product_id;

-- find customers that have placed orders in 2020 (as an additional column)
select c.customer_name,
case when order_date between '01-01-2020' and '12-31-2020' then 'YES' else 'NO' end as order_2020
from customer c 
left join order_header oh 
on oh.customer_id = c.customer_id 
group by oh.order_date, c.customer_name
;

-- more challenge (with season, durable products)
select count(oh.customer_id) as customers, sum(ol.quantity * p.product_price)::money as sales, count(oh.order_id) as orders,
	case when extract(month from order_date) in (3, 4, 5) then 'spring'
	when extract(month from order_date) in (6, 7, 8) then 'summer'
	when extract(month from order_date) in (9, 10, 11) then 'fall'
	when extract(month from order_date) in (12, 1, 2) then 'winter'
	else 'other' end as season,
	sum(case when product_price >= 100 then 1 else 0 end) as durable_products
from order_header oh
inner join customer c
on oh.customer_id = c.customer_id 
left join order_line ol 
on ol.order_id = oh.order_id 
left join product p
on ol.product_id = p.product_id 
where oh.order_date is not null
group by oh.order_date, season
order by sales desc
;
