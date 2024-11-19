USE sakila;

-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id,
    crs.customer_name,
    crs.email,
    crs.rental_count,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM customer_rental_summary crs LEFT JOIN payment p 
ON p.customer_id = crs.customer_id
GROUP BY crs.customer_id, crs.customer_name, crs.email, crs.rental_count;

WITH customer_summary_cte AS (
    SELECT 
        cps.customer_name,
        cps.email,
        cps.rental_count,
        cps.total_paid,
        CASE 
            WHEN cps.rental_count > 0 THEN ROUND(cps.total_paid / cps.rental_count, 2)
            ELSE 0
        END AS average_payment_per_rental
    FROM 
        customer_payment_summary cps
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM 
    customer_summary_cte
ORDER BY 
    total_paid DESC;
