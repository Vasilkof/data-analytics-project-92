-- Report: Total customers
select count(*) as customers_count
from customers;


-- Report 1: Top 10 sellers by income
select
    trim(e.first_name || ' ' || e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(
        sum(
            p.price * s.quantity
        )
    ) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    e.first_name,
    e.last_name
order by
    income desc
limit 10;


-- Report 2: Sellers with average income below overall sellers average
select
    trim(e.first_name || ' ' || e.last_name) as seller,
    floor(
        avg(
            p.price * s.quantity
        )
    ) as average_income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    e.first_name,
    e.last_name
having
    avg(
        p.price * s.quantity
    ) < (
        select avg(sub.seller_avg) as avg_seller_avg
        from (
            select
                avg(
                    p2.price * s2.quantity
                ) as seller_avg
            from sales as s2
            inner join products as p2
                on s2.product_id = p2.product_id
            group by
                s2.sales_person_id
        ) as sub
    )
order by
    average_income asc;


-- Report 3: Sellers income by day of week
select
    trim(e.first_name || ' ' || e.last_name) as seller,
    trim(
        to_char(
            s.sale_date,
            'day'
        )
    ) as day_of_week,
    floor(
        sum(
            p.price * s.quantity
        )
    ) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    e.first_name,
    e.last_name,
    trim(
        to_char(
            s.sale_date,
            'day'
        )
    ),
    extract(
        isodow from s.sale_date
    )
order by
    extract(
        isodow from s.sale_date
    ),
    seller;


-- Report: Number of customers in age groups
select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    count(*) as age_count
from customers as c
group by
    age_category
order by
    age_category;


-- Report: Unique customers and income by month
select
    to_char(
        s.sale_date,
        'YYYY-MM'
    ) as selling_month,
    count(distinct s.customer_id) as total_customers,
    floor(
        sum(
            p.price * s.quantity
        )
    ) as income
from sales as s
inner join products as p
    on s.product_id = p.product_id
group by
    to_char(
        s.sale_date,
        'YYYY-MM'
    )
order by
    selling_month;


-- Report: Customers whose first purchase was during a special offer (price = 0)
select
    so.sale_date,
    trim(c.first_name || ' ' || c.last_name) as customer,
    trim(e.first_name || ' ' || e.last_name) as seller
from (
    select distinct on (s.customer_id)
        s.customer_id,
        s.sale_date,
        s.product_id,
        s.sales_person_id
    from sales as s
    order by
        s.customer_id,
        s.sale_date
) as so
inner join products as p
    on so.product_id = p.product_id
inner join customers as c
    on so.customer_id = c.customer_id
inner join employees as e
    on so.sales_person_id = e.employee_id
where
    p.price = 0
order by
    so.customer_id;
