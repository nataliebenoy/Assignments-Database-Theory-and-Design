/*
 * Natalie Benoy
 * 2-20-2020
 * u6010825
 * IS 6420 Database Theory & Design
 * Lab 3
 */

-- Guided exercise

-- 1. List IDs of products that have been ordered. One ID appears exactly one time.
-- Order product IDs in ascending order.

select distinct(product_id)
from order_line
order by product_id asc 
;

-- 2. List IDs of customers that have placed orders after October 27, 2019.
-- One ID appears exactly one time. Order customer IDs in ascending order.

select distinct customer_id
from order_header
where order_date > '2019-10-27'
order by customer_id asc 
;

-- 3. List all customer names for customers who are from Salt Lake City and whose
-- first name starts with the letter ‘J’.

select customer_name
from customer
where city = 'Salt Lake City'
and upper(customer_name) like 'J%'
;

-- 4. List the product name, product price and product price after 10% discount.

select product_name, cast(product_price as money), (cast(product_price as decimal) * 0.9)::money as ten_percent_discount
from product
;

-- 5. List the number of products with a price higher than $100.  

select count(*)
from product
where product_price > 100
;

-- 6. List name and price for all products that have been purchased on order 1001.
-- Use a subquery and IN to implement this query.

select product_name, product_price
from product
where product_id in (
	select product_id
	from order_line 
	where order_id = 1001)
;

-- 7. List the order id and the order date for each order from an Arizona customer.
-- Sort the result by the date descending.

select order_id, order_date
from order_header 
where customer_id in (
	select customer_id
	from customer
	where state_province in ('Arizona', 'AZ'))
order by order_date desc
	;


-- Challenge 1

-- 1. Select all rows from the customer table, but add a column called is_vip_customer
-- where 1 indicates customers who have placed at least 10 orders and 0 indicates customers
-- who have placed 9 or less orders (Note: VIP = Very Important Person).
-- The result should have those who are VIP customers first, then those are not VIP.
-- Within these two groups, sort by state/province ascending, then city ascending

-- this doesn't work but I tried it anyway
select *, order_id in (case when count(order_id) >= 10 then 1 else 0 end) as is_vip_customer
from customer
join order_header
on customer.customer_id = order_header.customer_id
group by customer.customer_id, order_header.order_id
having order_header.order_id in (case when count(order_id) >= 10 then 1 else 0 end)
order by state_province asc, city asc
;

-- this also doesn't work, very sad :(
select *
from customer
where customer_id in (
	select customer_id, order_id
	case when count(order_id) >= 10 then 1
		else 0
		end
	as is_vip_customer
	from order_header
)
group by is_vip_customer desc 
order by state_province asc, city asc
;


-- 2. List the order id, date and total dollar amount for the top 10 orders by dollar amount.
-- Sort the result by the date ascending and then the total amount descending.
-- (hint: you will need to join tables to get product price and quantity)

select order_header.order_id, order_header.order_date, (product.product_price * order_line.quantity):: money as total_dollar_amount
from order_header
join order_line
on order_header.order_id = order_line.order_id 
join product
on product.product_id = order_line.product_id 
order by order_date asc, total_dollar_amount desc 
limit(10)
;


-- Challenge 2

-- 1. Remove the customer “Pavia Vanyutin” from the database.

delete from order_line 
where order_id in (
	select order_id 
	from order_header 
	where customer_id in (
		select customer_id
		from customer
		where customer_name = 'Pavia Vanyutin'
))
;

delete from order_header 
where customer_id in(
	select customer_id
	from customer
	where customer_name = 'Pavia Vanyutin'
)
;

delete from customer 
where upper(customer_name) = 'PAVIA VANYUTIN'
;

-- check to see if that worked
select *
from customer
where customer_name = 'Pavia Vanyutin'
;

-- 2. Remove the customer “Rania Kyne” from the database using only three (3) separate delete statements,
-- none of which can include the hard-coded value (i.e. 8) of Rania Kyne’s customer id

delete from order_line 
where order_id in (
	select order_id 
	from order_header 
	where customer_id in (
		select customer_id
		from customer
		where customer_name = 'Rania Kyne'
))
;

delete from order_header 
where customer_id in(
	select customer_id
	from customer
	where customer_name = 'Rania Kyne'
)
;

delete from customer 
where customer_name = 'Rania Kyne'
;

-- check to see if that worked
select *
from customer
where customer_name = 'Rania Kyne'
;

-- 3. Delete the customer “Allistir Rickett” from the customer table, followed by their order header records,
-- followed by their order line records.

alter table order_header
drop constraint order_fkey_customer_id
;

delete from customer 
where customer_name = 'Allistir Rickett'
;

alter table order_line 
drop constraint order_line_fkey_order_id
;

delete from order_header 
where customer_id is NULL
;

delete from order_line 
where order_id is NULL
;

-- 4. Re-add any constraints that were dropped in order to meet the requirements for step 1.

alter table order_line 
add constraint order_line_fkey_order_id foreign key (order_id) references order_header(order_id)
;

alter table order_header
add constraint order_fkey_customer_id foreign key (customer_id) references customer(customer_id)
;

