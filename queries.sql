-- Report: Total customers
SELECT
    COUNT(*) AS customers_count
FROM customers;


-- Report 1: Top 10 sellers by income
SELECT
    TRIM(e.first_name || ' ' || e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.first_name,
    e.last_name
ORDER BY
    income DESC
LIMIT 10;


-- Report 2: Sellers with average income below overall sellers average
SELECT
    TRIM(e.first_name || ' ' || e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.first_name,
    e.last_name
HAVING AVG(p.price * s.quantity) < (
    SELECT
        AVG(sub.seller_avg) AS avg_seller_avg
    FROM (
        SELECT
            AVG(p2.price * s2.quantity) AS seller_avg
        FROM sales AS s2
        INNER JOIN products AS p2
            ON s2.product_id = p2.product_id
        GROUP BY
            s2.sales_person_id
    ) AS sub
)
ORDER BY
    average_income ASC;


-- Report 3: Sellers income by day of week
SELECT
    TRIM(e.first_name || ' ' || e.last_name) AS seller,
    TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    e.first_name,
    e.last_name,
    TRIM(TO_CHAR(s.sale_date, 'day')),
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date),
    seller;


-- Report: Number of customers in age groups
SELECT
    CASE
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers AS c
GROUP BY
    age_category
ORDER BY
    age_category;


-- Report: Unique customers and income by month
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY
    selling_month;


-- Report: Customers whose first purchase was during a special offer (price = 0)
SELECT
    TRIM(c.first_name || ' ' || c.last_name) AS customer,
    so.sale_date,
    TRIM(e.first_name || ' ' || e.last_name) AS seller
FROM (
    SELECT DISTINCT ON (s.customer_id)
        s.customer_id,
        s.sale_date,
        s.product_id,
        s.sales_person_id
    FROM sales AS s
    ORDER BY
        s.customer_id,
        s.sale_date
) AS so
INNER JOIN products AS p
    ON so.product_id = p.product_id
INNER JOIN customers AS c
    ON so.customer_id = c.customer_id
INNER JOIN employees AS e
    ON so.sales_person_id = e.employee_id
WHERE
    p.price = 0
ORDER BY
    so.customer_id;
