USE DataWarehouse;
GO

/*
===============================================================================
Sales Trends Analysis
===============================================================================
Purpose:
    Analyze sales performance over time using the Gold fact table.

Metrics:
    - Monthly revenue
    - Monthly orders
    - Monthly units sold
    - Monthly gross profit
===============================================================================
*/

SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,

    COUNT(DISTINCT order_number) AS total_orders,

    SUM(quantity) AS total_units_sold,

    SUM(sales_amount) AS total_revenue,

    SUM(estimated_gross_profit) AS estimated_gross_profit

FROM gold.fact_sales

WHERE order_date IS NOT NULL

GROUP BY
    YEAR(order_date),
    MONTH(order_date)

ORDER BY
    sales_year,
    sales_month;