-- =========================================================
-- Silver layer validation tests
-- Purpose: check data quality after bronze-to-silver cleanup
-- =========================================================

-- ---------------------------------------------------------
-- CRM CUSTOMER DATA CHECKS
-- ---------------------------------------------------------

-- 1. Duplicate customer IDs in bronze layer
SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- 2. Duplicate customer IDs in silver layer
SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- 3. Check for leading/trailing spaces in customer first names
SELECT
    cst_id,
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- 4. Check for leading/trailing spaces in customer last names
SELECT
    cst_id,
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- 5. Check distinct gender values in bronze data
SELECT DISTINCT
    cst_gndr
FROM bronze.crm_cust_info
ORDER BY cst_gndr;

-- 6. Validate that only expected gender mappings exist after standardization
SELECT
    cst_id,
    cst_gndr
FROM silver.crm_cust_info
WHERE UPPER(TRIM(cst_gndr)) NOT IN ('MALE', 'FEMALE', 'NOT SPECIFIED');

-- 7. Validate that only expected marital status values exist after standardization
SELECT
    cst_id,
    cst_marital_status
FROM silver.crm_cust_info
WHERE UPPER(TRIM(cst_marital_status)) NOT IN ('MARRIED', 'SINGLE', 'NOT SPECIFIED');

-- 8. Confirm duplicates were removed from silver table using row_number logic
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
    FROM silver.crm_cust_info
) t
WHERE flag != 1;


-- ---------------------------------------------------------
-- CRM PRODUCT DATA CHECKS
-- ---------------------------------------------------------

-- 9. Duplicate product IDs in bronze layer
SELECT
    prd_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- 10. Check product key format and category extraction sanity
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key FROM 1 FOR 5), '-', '_') AS cat_id
FROM bronze.crm_prd_info
WHERE prd_key IS NULL OR LENGTH(prd_key) < 5;

-- 11. Check for null or zero product cost values
SELECT
    prd_id,
    prd_key,
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost <= 0;

-- 12. Check product line values before mapping
SELECT DISTINCT
    UPPER(TRIM(prd_line)) AS prd_line_value
FROM bronze.crm_prd_info
ORDER BY prd_line_value;

-- 13. Validate product line mapping in silver output
SELECT
    prd_id,
    prd_key,
    prd_line
FROM silver.crm_prd_info
WHERE UPPER(TRIM(prd_line)) NOT IN ('MOUNTAIN', 'ROAD', 'OTHER SALES', 'TOURING', 'NOT SPECIFIED');

-- 14. Check for invalid date ranges after end-date derivation
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- 15. Check if any product end date is before start date in bronze data
SELECT
    prd_id,
    prd_key,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_end_dt IS NOT NULL AND prd_end_dt < prd_start_dt;


-- ---------------------------------------------------------
-- CRM SALES DATA CHECKS
-- ---------------------------------------------------------

-- 16. Check for invalid date values in bronze sales data
SELECT
    sls_ord_num,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0
   OR sls_ship_dt = 0
   OR sls_due_dt = 0
   OR LENGTH(CAST(sls_order_dt AS VARCHAR)) != 8
   OR LENGTH(CAST(sls_ship_dt AS VARCHAR)) != 8
   OR LENGTH(CAST(sls_due_dt AS VARCHAR)) != 8;

-- 17. Check for negative or invalid sales values in bronze layer
SELECT
    sls_ord_num,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales < 0
   OR sls_quantity < 0
   OR sls_price < 0
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL;

-- 18. Check whether sales equals quantity * price in bronze data
SELECT
    sls_ord_num,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;

-- 19. Check for invalid final values in silver sales data
SELECT
    sls_ord_num,
    sales_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sales_sales < 0
   OR sls_quantity < 0
   OR sls_price < 0
   OR sales_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL;

-- 20. Check if any sales records were not normalized correctly
SELECT *
FROM silver.crm_sales_details
WHERE sales_order_dt IS NULL
   OR sales_ship_dt IS NULL
   OR sales_due_dt IS NULL;


-- ---------------------------------------------------------
-- ERP CUSTOMER DATA CHECKS
-- ---------------------------------------------------------

-- 21. Check for missing values in ERP customer gender column
SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_info
WHERE gen IS NULL OR TRIM(gen) = '';

-- 22. Check for future birth dates in ERP data
SELECT
    cid,
    bdate
FROM bronze.erp_cust_info
WHERE bdate > CURRENT_DATE;

-- 23. Validate gender normalization mapping
SELECT
    cid,
    gen
FROM silver.erp_cust_info
WHERE UPPER(TRIM(gen)) NOT IN ('FEMALE', 'MALE', 'N/A');

-- 24. Check if ERP customer IDs still contain NAS prefix after cleansing
SELECT
    cid
FROM silver.erp_cust_info
WHERE cid LIKE 'NAS%';


-- ---------------------------------------------------------
-- ERP LOCATION DATA CHECKS
-- ---------------------------------------------------------

-- 25. Check for empty or null country values in bronze ERP location data
SELECT
    cid,
    cntry
FROM bronze.erp_loc_info
WHERE cntry IS NULL OR TRIM(cntry) = '';

-- 26. Check for country values in bronze data that need standardization
SELECT DISTINCT
    cntry
FROM bronze.erp_loc_info
ORDER BY cntry;

-- 27. Validate the silver country mapping values
SELECT
    cid,
    cntry
FROM silver.erp_loc_info
WHERE UPPER(TRIM(cntry)) NOT IN ('GERMANY', 'UNITED STATES', 'N/A');

-- 28. Check for leftover dashes in customer IDs after cleansing
SELECT
    cid
FROM silver.erp_loc_info
WHERE cid LIKE '%-%';


-- ---------------------------------------------------------
-- ERP CATEGORY DATA CHECKS
-- ---------------------------------------------------------

-- 29. Check for empty or null values in ERP category bronze data
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_cat_info
WHERE id IS NULL OR cat IS NULL OR subcat IS NULL OR maintenance IS NULL;

-- 30. Check for unwanted spaces in category names
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_cat_info
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- 31. Validate that silver ERP category records are preserved without unexpected change
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM silver.erp_cat_info
WHERE id IS NULL OR cat IS NULL OR subcat IS NULL OR maintenance IS NULL;
