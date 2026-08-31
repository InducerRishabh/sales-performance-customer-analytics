USE DataWarehouse;
GO

/* ============================================================
   05 - CATEGORY & SUBCATEGORY ANALYSIS
   ============================================================ */


/* ============================================================
   1. Category Performance
   ============================================================ */

SELECT
    dp.category,
    COUNT(DISTINCT dp.product_key) AS product_count,
    COUNT(DISTINCT fs.order_number) AS total_orders,
    SUM(fs.quantity) AS total_units_sold,
    SUM(fs.sales_amount) AS total_revenue,

    SUM(
        fs.sales_amount - (fs.quantity * dp.unit_cost)
    ) AS estimated_gross_profit,

    CAST(
        SUM(
            fs.sales_amount - (fs.quantity * dp.unit_cost)
        ) * 100.0
        / NULLIF(SUM(fs.sales_amount), 0)
        AS DECIMAL(10,2)
    ) AS estimated_gross_margin_pct

FROM gold.fact_sales fs

LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key

GROUP BY
    dp.category

ORDER BY
    total_revenue DESC;


/* ============================================================
   2. Subcategory Performance
   ============================================================ */

SELECT
    dp.category,
    dp.subcategory,

    COUNT(DISTINCT dp.product_key) AS product_count,
    COUNT(DISTINCT fs.order_number) AS total_orders,
    SUM(fs.quantity) AS total_units_sold,
    SUM(fs.sales_amount) AS total_revenue,

    SUM(
        fs.sales_amount - (fs.quantity * dp.unit_cost)
    ) AS estimated_gross_profit,

    CAST(
        SUM(
            fs.sales_amount - (fs.quantity * dp.unit_cost)
        ) * 100.0
        / NULLIF(SUM(fs.sales_amount), 0)
        AS DECIMAL(10,2)
    ) AS estimated_gross_margin_pct

FROM gold.fact_sales fs

LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key

GROUP BY
    dp.category,
    dp.subcategory

ORDER BY
    total_revenue DESC;


/* ============================================================
   3. Top 10 Products by Revenue
   ============================================================ */

SELECT TOP 10

    dp.product_key,
    dp.product_name,
    dp.category,
    dp.subcategory,
    dp.product_line,

    SUM(fs.quantity) AS total_units_sold,
    SUM(fs.sales_amount) AS total_revenue,

    SUM(
        fs.sales_amount - (fs.quantity * dp.unit_cost)
    ) AS estimated_gross_profit

FROM gold.fact_sales fs

LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key

GROUP BY
    dp.product_key,
    dp.product_name,
    dp.category,
    dp.subcategory,
    dp.product_line

ORDER BY
    total_revenue DESC;


/* ============================================================
   4. Top 10 Products by Estimated Gross Profit
   ============================================================ */

SELECT TOP 10

    dp.product_key,
    dp.product_name,
    dp.category,
    dp.subcategory,
    dp.product_line,

    SUM(fs.quantity) AS total_units_sold,
    SUM(fs.sales_amount) AS total_revenue,

    SUM(
        fs.sales_amount - (fs.quantity * dp.unit_cost)
    ) AS estimated_gross_profit

FROM gold.fact_sales fs

LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key

GROUP BY
    dp.product_key,
    dp.product_name,
    dp.category,
    dp.subcategory,
    dp.product_line

ORDER BY
    estimated_gross_profit DESC;