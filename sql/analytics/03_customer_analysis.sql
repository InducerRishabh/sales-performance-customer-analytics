/*
===============================================================================
Customer Analysis
===============================================================================
Purpose:
    Analyze customer purchasing behavior using the Gold layer.

Analysis includes:
    1. Customer-level revenue and order metrics
    2. Top customers by revenue
    3. Customer segmentation by revenue
===============================================================================
*/

USE DataWarehouse;
GO


-- =============================================================================
-- 1. Customer-Level Analysis
-- =============================================================================

SELECT
    dc.customer_key,
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.country,
    dc.gender,
    COUNT(DISTINCT fs.order_number) AS total_orders,
    SUM(fs.quantity) AS total_units,
    SUM(fs.sales_amount) AS total_revenue,
    AVG(fs.sales_amount) AS avg_transaction_value
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
    ON fs.customer_key = dc.customer_key
GROUP BY
    dc.customer_key,
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.country,
    dc.gender
ORDER BY
    total_revenue DESC;


-- =============================================================================
-- 2. Top 10 Customers by Revenue
-- =============================================================================

SELECT TOP 10
    dc.customer_key,
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.country,
    COUNT(DISTINCT fs.order_number) AS total_orders,
    SUM(fs.quantity) AS total_units,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
    ON fs.customer_key = dc.customer_key
GROUP BY
    dc.customer_key,
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.country
ORDER BY
    total_revenue DESC;


-- =============================================================================
-- 3. Customer Revenue Segmentation
-- =============================================================================
-- High Value    : Revenue >= 10,000
-- Medium Value  : Revenue >= 5,000 and < 10,000
-- Low Value     : Revenue < 5,000
-- =============================================================================

WITH customer_revenue AS
(
    SELECT
        customer_key,
        SUM(sales_amount) AS total_revenue,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(quantity) AS total_units
    FROM gold.fact_sales
    GROUP BY customer_key
)

SELECT
    CASE
        WHEN total_revenue >= 10000 THEN 'High Value'
        WHEN total_revenue >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,

    COUNT(*) AS customer_count,
    SUM(total_revenue) AS segment_revenue,
    AVG(total_revenue) AS avg_customer_revenue,
    AVG(total_orders) AS avg_orders_per_customer,
    AVG(total_units) AS avg_units_per_customer

FROM customer_revenue

GROUP BY
    CASE
        WHEN total_revenue >= 10000 THEN 'High Value'
        WHEN total_revenue >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END

ORDER BY
    segment_revenue DESC;