# Gold Layer Data Catalog

The gold layer contains the final, business-ready tables used for analytics and reporting. These tables are cleaned, standardized, and structured for easy reporting, filtering, and dashboarding.

## gold.dim_customers
Purpose: Stores cleaned customer-level information used for customer segmentation and demographic analysis.

CREATE TABLE gold.dim_customers (
    customer_id INT,
    customer_key VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    marital_status VARCHAR(50),
    gender VARCHAR(20),
    birth_date DATE,
    country VARCHAR(100)
);

## gold.dim_products
Purpose: Stores standardized product master data used for product analysis, category reporting, and lifecycle tracking.

CREATE TABLE gold.dim_products (
    product_id INT,
    product_key VARCHAR(100),
    category_id VARCHAR(50),
    product_name VARCHAR(200),
    product_cost DECIMAL(10,2),
    product_line VARCHAR(50),
    product_start_date DATE,
    product_end_date DATE
);

## gold.fact_sales
Purpose: Stores transactional sales records used for revenue analysis, trend analysis, and business performance reporting.

CREATE TABLE gold.fact_sales (
    order_number VARCHAR(50),
    product_key VARCHAR(100),
    customer_id INT,
    order_date DATE,
    ship_date DATE,
    due_date DATE,
    sales_amount DECIMAL(12,2),
    quantity INT,
    unit_price DECIMAL(12,2)
);