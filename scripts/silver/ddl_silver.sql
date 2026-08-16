
/* CRM */
/*Follow the naming convention to create tables*/

DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
    prd_id INT,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50),
    prd_nm VARCHAR(100),
    prd_cost DECIMAL(10,2),
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);


DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales DECIMAL(10,2),
    sls_quantity INT,
    sls_price DECIMAL(10,2),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


/*ERP*/

DROP TABLE silver.erp_cust_info;
CREATE TABLE silver.erp_cust_info(
    CID VARCHAR,
    BDATE VARCHAR(10),
    GEN VARCHAR(10),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- IF OBJECT_ID('silver.erp_loc_info', 'U') IS NOT NULL
DROP TABLE silver.erp_loc_info;
CREATE TABLE silver.erp_loc_info(
    CID VARCHAR,
    CNTRY VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);  


DROP TABLE silver.erp_cat_info;
CREATE TABLE silver.erp_cat_info(
    ID VARCHAR(50),
    CAT VARCHAR(50),
    SUBCAT VARCHAR(50),
    MAINTENANCE VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




