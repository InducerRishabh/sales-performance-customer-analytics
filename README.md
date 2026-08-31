# Sales Performance & Customer Analytics

## Project Overview

An end-to-end data analytics project built using SQL Server and Power BI to transform raw CRM and ERP sales data into a business-ready analytical model and interactive dashboard.

The project follows a Bronze → Silver → Gold data architecture for data ingestion, cleansing, transformation, validation, and analytics.

---

## Business Objective

The objective of this project is to analyze sales performance and provide insights into:

- Overall revenue and profitability
- Sales trends over time
- Product and product-line performance
- Category performance
- Geographic sales performance
- Customer and order activity
- Shipping performance

The final Power BI dashboard provides interactive filtering for business analysis.

---

## Tools & Technologies

- **SQL Server**
- **T-SQL**
- **Power BI**
- **DAX**
- **Git & GitHub**

---

## Data Sources

The project uses six CSV files from CRM and ERP source systems.

### CRM

- Customer information
- Product information
- Sales transactions

### ERP

- Customer information
- Customer location
- Product category information

---

## Data Warehouse Architecture

The project follows a three-layer architecture:

```text
CRM Sources ──────┐
                  │
                  ▼
              BRONZE
          Raw Data Ingestion
                  │
                  ▼
               SILVER
       Cleaning & Transformation
                  │
                  ▼
                GOLD
      Business-Ready Analytical Views
                  │
                  ▼
              POWER BI
       Dashboard & Visualization