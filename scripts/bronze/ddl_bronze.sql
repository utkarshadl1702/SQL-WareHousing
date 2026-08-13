
/* CRM */

CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);
CREATE TABLE bronze.prd_info(
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(100),
    prd_cost DECIMAL(10,2),
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);
CREATE TABLE bronze.sales_details(
    sls_ord_num INT,
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales DECIMAL(10,2),
    sls_quantity INT,
    sls_price DECIMAL(10,2)
);


/*ERP*/
CREATE TABLE bronze.CUST_AZ12(
    CID INT,
    BDATE DATE,
    GEN VARCHAR(10)
);


