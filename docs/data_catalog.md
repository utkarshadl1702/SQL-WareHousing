# Gold Layer Data Catalog

The gold layer contains the final, business-ready tables used for analytics and reporting. These tables are cleaned, standardized, and structured for easy reporting, filtering, and dashboarding.

## gold.dim_customers
Purpose: Stores cleaned customer-level information used for customer segmentation and demographic analysis.

| Column | Type | Description |
|---|---|---|
| customer_id | INT | Unique identifier for each customer. |
| customer_key | VARCHAR(50) | Business key used to match the customer across source systems. |
| first_name | VARCHAR(100) | Customer first name after trimming and standardization. |
| last_name | VARCHAR(100) | Customer last name after trimming and standardization. |
| marital_status | VARCHAR(50) | Standardized marital status such as Married or Single. |
| gender | VARCHAR(20) | Standardized gender value such as Male or Female. |
| birth_date | DATE | Customer date of birth. |
| country | VARCHAR(100) | Standardized country name derived from ERP location data. |

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

| Column | Type | Description |
|---|---|---|
| product_id | INT | Unique identifier for each product. |
| product_key | VARCHAR(100) | Product identifier used in CRM transactions. |
| category_id | VARCHAR(50) | Extracted category code from the product key. |
| product_name | VARCHAR(200) | Cleaned product name. |
| product_cost | DECIMAL(10,2) | Standardized product cost. |
| product_line | VARCHAR(50) | Product line such as Road, Mountain, or Touring. |
| product_start_date | DATE | When the product became active. |
| product_end_date | DATE | When the product was replaced or no longer active. |

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

| Column | Type | Description |
|---|---|---|
| order_number | VARCHAR(50) | Unique sales order identifier. |
| product_key | VARCHAR(100) | Product reference associated with the sale. |
| customer_id | INT | Customer reference linked to the order. |
| order_date | DATE | Date the order was placed. |
| ship_date | DATE | Date the order was shipped. |
| due_date | DATE | Expected delivery or due date for the order. |
| sales_amount | DECIMAL(12,2) | Final normalized sales value. |
| quantity | INT | Quantity sold in the order. |
| unit_price | DECIMAL(12,2) | Price per unit after standardization. |

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