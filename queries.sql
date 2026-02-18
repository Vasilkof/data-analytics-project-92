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

