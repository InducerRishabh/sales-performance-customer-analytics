/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.
    - Validation of financial calculations.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================

-- Check for Uniqueness of Customer Key
-- Expectation: No results

SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================

-- Check for Uniqueness of Product Key
-- Expectation: No results

SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================

-- Check the data model connectivity between fact and dimensions
-- Expectation: No results

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;


-- ====================================================================
-- Checking Financial Calculations
-- ====================================================================

-- Revenue validation
-- Expectation: revenue_difference = 0

SELECT
    SUM(sales_amount) AS stored_revenue,
    SUM(quantity * unit_price) AS calculated_revenue,
    SUM(sales_amount) - SUM(quantity * unit_price) AS revenue_difference
FROM gold.fact_sales;


-- Gross profit validation
-- Expectation: profit_difference = 0

SELECT
    SUM(estimated_gross_profit) AS stored_profit,
    SUM(sales_amount - (quantity * unit_cost)) AS calculated_profit,
    SUM(estimated_gross_profit)
        - SUM(sales_amount - (quantity * unit_cost)) AS profit_difference
FROM gold.fact_sales;