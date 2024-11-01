create table sales (
`sales_id` INT,
`customer_id` INT,
`product_id` INT,
`sale_date` DATE,
`quantity` INT,
`total_amount` DECIMAL
);

create table customers (
`customer_id` INT,
`customer_name` VARCHAR(255),
`sales_region` VARCHAR(255),
`sign_up_date` DATE
);

create table products (
`product_id` INT,
`product_name` VARCHAR(255),
`category` VARCHAR(255),
`price` DECIMAL
);

insert into sales (`sales_id`, `customer_id`, `product_id`, 
`sale_date`, `quantity`, `total_amount`) VALUES
(1, 1, 1, '2023-09-05', 5, 5000.00), -- Ami Smith buys 5 headphones for a giveaway --
(2, 6, 2, '2023-06-19', 1, 1000.00), -- Jeremiah Cole buys a new charger --
(3, 8, 4, '2023-07-08', 2, 2000.00), -- Conrad Fisher buys 2 new phones --
(4, 7, 9, '2023-10-13', 4, 4000.00), -- Nicole samuels buys 4 new laptops --
(5, 2, 5, '2023-01-25', 4, 4000.00), -- Lemuel Asante buys 4 new ipads --
(6, 4, 3, '2023-09-13', 1, 1000.00), -- Mimi Tafara buys a set of earpiece --
(7, 6, 5, '2023-03-13', 6, 6000.00), -- Jeremiah Cole buys 6 new ipads returning customer --
(8, 4, 1, '2023-12-13', 3, 3000.00);  -- Mimi Tafara buys 3 headphones returning customer --

select *
from clip_board.sales;

update clip_board.sales 
set `total_amount` = 100
where `sales_id` = 2 or `sales_id` = 6;
 
insert into products (`product_id`, `product_name`, `category`, `price`) VALUES
(1, 'Headphones', 'Electronics', 1000.00),
(2, 'Charger', 'Electronics', 100.00),
(4, 'Phones', 'Electronics', 1000.00),
(9, 'Laptop', 'Electronics', '1000.00'),
(5, 'Ipad', 'Electronics', '1000'),
(3, 'Earpirce', 'Electronics', 100);

select *
from clip_board.products ;

insert into customers (`customer_id`, `customer_name`, 
`sales_region`, `sign_up_date`) VALUES
(1, 'Ami Smith', 'West', '2023-06-15'),
(6, 'Jeremiah Cole', 'West', '2023-04-20'),
(8, 'Conrad Fisher', 'East', '2023-01-04'),
(7, 'Nicole Samuels', 'South', '2023-09-06'),
(2, 'Lemuel Asante', 'West', '2023-02-26'),
(4, 'Mimi Tafara', 'North', '2023-05-08');

select *
from clip_board.customers;

-- A query that returns customer_name, product_name, and total_amount for each sale in the last 30 days --
select customers.`customer_name`, products.`product_name`, sales.`total_amount`
from clip_board.sales
inner join customers on sales.customer_id = customers.customer_id 
inner join products on sales.product_id = products.product_id
where `sale_date` >= date_sub(curdate(), interval 30 day);

-- update some dates to fit the criteria--
update clip_board.sales
set `sale_date` = CASE
when `sales_id` = 1 then '2024-10-02'
when `sales_id` = 3 then '2024-10-08'
when `sales_id` = 5 then '2024-10-15'
end 
where `sales_id` in (1,3,5);

-- A query to find total revenue genrated by each product in the last year -- 
select p.`category`,
sum(s.`total_amount`) as total_revenue
from sales s
join products p on s.`product_id` = p.`product_id`
where s.sale_date >= curdate() - interval 1 year
group by p.`category`;

-- A query that returns customers who made purchases in 2023 and are located in the West region 
select `customer_name`, `sale_date`
from clip_board.customers
inner join sales
on sales.customer_id = customers.customer_id 
where `sale_date` like '2023%' and `sales_region` = 'West';

-- A query displaying total number of sales, total quantity sold, and total revenue for each customer
select c.`customer_name`,
count(s.`sales_id`) as total_sales,
sum(s.`quantity`) as total_quantity_sold,
sum(s.`total_amount`) as total_revenue
from clip_board.sales s
inner join clip_board.customers c
on s.customer_id = c.customer_id
group by c.`customer_name`
;

-- A query to find top 3 customers by total revenue in 2023 --
select c.`customer_name`,
sum(s.`total_amount`) as total_revenue,
min(s.`sale_date`) as early_sale_date
from clip_board.sales s
inner join clip_board.customers c
on s.customer_id = c.customer_id
where `sale_date` like '2023%'
group by c.`customer_name`
order by total_revenue DESC
limit 3
;

-- A query to rank products by their total sales quantity in 2023 --
select p.`product_name`,
sum(s.`quantity`) as total_quantity_sold,
rank() over (order by sum(s.`quantity`) desc) as `rank`
from clip_board.sales s
inner join clip_board.products p
on s.product_id = p.product_id
where `sale_date` like '2023%'
group by p.`product_name`
order by `rank`;

-- A query that categorizes customers into 'New' if they signed up in the last 6 months or existing based on their sign up date --
select c.`customer_name`,
 c.`sales_region` as region,
case
when c.sign_up_date >= date_sub(curdate(), interval 6 month) then 'New'
else 'existing'
end as category 
from clip_board.customers c;

-- A query that returns the month and year along with the total sales for each month for the last 12 months --
select date_format(`sale_date`, '%Y-%M') as sale_month,
count(`sales_id`) as total_sales
from clip_board.sales
where sales.`sale_date` >= date_sub(curdate(), interval 12 month)
group by sale_month
order by sale_month
;

-- A query to return the product categories that generated more than $50,000 in revenue during the last 6 month -- 
select p.`category`,
sum(s.`total_amount`) as total_revenue
from clip_board.products p
join clip_board.sales s
on s.`product_id` = p.`product_id`
where s.`sale_date` >= date_sub(curdate(), interval 6 month)
group by p.`category`
having total_revenue > 50000 
;

-- A query that checks for any sales where total_amount doesn't match expected value (quantity * price)
select *,
(s.`quantity` * p.`price`) as expected_value
from clip_board.`sales` s
join clip_board.products p
on s.`product_id` = p.`product_id`
where s.total_amount != (s.quantity * p.price)
;



