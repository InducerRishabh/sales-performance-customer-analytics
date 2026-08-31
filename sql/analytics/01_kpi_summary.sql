/*
===============================================================================
Sales Performance & Customer Analytics
KPI Summary
===============================================================================
*/

USE DataWarehouse;
GO

SELECT
    COUNT(DISTINCT order_number) AS total_orders,

    COUNT(DISTINCT customer_key) AS total_customers,

    COUNT(DISTINCT product_key) AS total_products,

    SUM(quantity) AS total_units_sold,

    SUM(sales_amount) AS total_revenue,

    SUM(estimated_gross_profit) AS estimated_gross_profit,

    CAST(
        SUM(estimated_gross_profit) * 100.0
        / NULLIF(SUM(sales_amount), 0)
        AS DECIMAL(10,2)
    ) AS estimated_gross_margin_pct,

    CAST(
        SUM(sales_amount) * 1.0
        / NULLIF(COUNT(DISTINCT order_number), 0)
        AS DECIMAL(12,2)
    ) AS average_order_value

FROM gold.fact_sales;