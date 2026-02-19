-- Report: Total  customers

SELECT COUNT(*) AS customers_count
FROM customers;

-- Report 1: Top 10 
SELECT
    TRIM(e.first_name || ' ' || e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;
-- Report 2: Sellers with average 

SELECT
    TRIM(e.first_name || ' ' || e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.first_name, e.last_name
HAVING AVG(p.price * s.quantity) < (
    SELECT AVG(seller_avg)
    FROM (
        SELECT AVG(p2.price * s2.quantity) AS seller_avg
        FROM sales s2
        JOIN products p2 ON s2.product_id = p2.product_id
        GROUP BY s2.sales_person_id
    ) sub
)
ORDER BY average_income ASC;

-- Report 3: Sellers day
SELECT
    TRIM(e.first_name || ' ' || e.last_name) AS seller,
    TRIM(TO_CHAR(s.sale_date, 'day')) AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
GROUP BY
    e.first_name,
    e.last_name,
    TRIM(TO_CHAR(s.sale_date, 'day')),
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date),
    seller;

-- Report : Number of customers  age groups 
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;


-- Report : Number of unique customers
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month;


-- Report : Customers  special offer 

SELECT
    TRIM(c.first_name || ' ' || c.last_name) AS customer,
    s.sale_date,
    TRIM(e.first_name || ' ' || e.last_name) AS seller
FROM (
    SELECT customer_id, MIN(sale_date) AS first_sale_date
    FROM sales
    GROUP BY customer_id
) first_sales
JOIN sales s
    ON s.customer_id = first_sales.customer_id
    AND s.sale_date = first_sales.first_sale_date
JOIN products p ON s.product_id = p.product_id
JOIN customers c ON s.customer_id = c.customer_id
JOIN employees e ON s.sales_person_id = e.employee_id
WHERE p.price = 0
ORDER BY s.customer_id;
