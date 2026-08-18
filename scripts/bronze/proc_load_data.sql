CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMPTZ;
BEGIN
    start_time := clock_timestamp();

    -- CRM
    TRUNCATE TABLE bronze.crm_cust_info;
    COPY bronze.crm_cust_info
    (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
    FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_crm/cust_info.csv'
    WITH (FORMAT csv, HEADER true, NULL '', FORCE_NULL(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date));

    TRUNCATE TABLE bronze.crm_prd_info;
    COPY bronze.crm_prd_info
    (prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
    FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_crm/prd_info.csv'
    WITH (FORMAT csv, HEADER true, NULL '', FORCE_NULL(prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt));

    TRUNCATE TABLE bronze.crm_sales_details;
    COPY bronze.crm_sales_details
    (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
    FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_crm/sales_details.csv'
    WITH (FORMAT csv, HEADER true, NULL '', FORCE_NULL(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price));

    -- ERP
    TRUNCATE TABLE bronze.erp_cust_info;
    COPY bronze.erp_cust_info
    (cid, bdate, gen)
    FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_erp/CUST_AZ12.csv'
    WITH (FORMAT csv, HEADER true, NULL '', FORCE_NULL(cid, bdate, gen));

    TRUNCATE TABLE bronze.erp_loc_info;
    COPY bronze.erp_loc_info
    (cid, cntry)
    FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_erp/LOC_A101.csv'
    WITH (FORMAT csv, HEADER true, NULL '', FORCE_NULL(cid, cntry));

    TRUNCATE TABLE bronze.erp_cat_info;
    COPY bronze.erp_cat_info
    (id, cat, subcat, maintenance)
    FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_erp/PX_CAT_G1V2.csv'
    WITH (FORMAT csv, HEADER true, NULL '', FORCE_NULL(id, cat, subcat, maintenance));

    RAISE NOTICE 'Bronze load completed in %', clock_timestamp() - start_time;
END;
$$;

