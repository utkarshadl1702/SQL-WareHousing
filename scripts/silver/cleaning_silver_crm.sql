


----------------------------------CRM----------------------------------------------
        ------------------------crm_cust_info------------------------
-- Checking for duplicates
SELECT cst_id, COUNT(*) FROM bronze.crm_cust_info GROUP BY cst_id HAVING COUNT(*) > 1;




SELECT * FROM (
--Checking for timestamps of same ids
-- This will sort all same same ids with numbers and flag them as 1,2,3,.... based on ranking in their own id
-- Now we need to select only flag=1 (lastest one) and remove older
SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
 FROM bronze.crm_cust_info
)t WHERE flag=1;


-- Check for unwanted spaces


-- Returns all the records where there are unwanted spaces in the first name column
SELECT cst_firstname FROM bronze.crm_cust_info WHERE cst_firstname!=TRIM(cst_firstname);

-- Now clean the first and last name
SELECT cst_id,cst_key,TRIM(cst_firstname) AS cst_firstname, TRIM(cst_lastname) AS cst_lastname,cst_marital_status,cst_gndr,cst_create_date FROM bronze.crm_cust_info;


-- Data Standardization and Consistency

-- Having meaningfull data instead of M/F/null 
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT cst_id,cst_key,TRIM(cst_firstname) AS cst_firstname, TRIM(cst_lastname) AS cst_lastname,cst_marital_status,

CASE WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
ELSE 'Not Specified' END AS cst_marital_status,

CASE WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
ELSE 'Not Specified' END AS cst_gndr
,cst_create_date FROM bronze.crm_cust_info;



-- Now insert this cleaned bronze data to silver layer
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info
SELECT cst_id,cst_key,TRIM(cst_firstname) AS cst_firstname, TRIM(cst_lastname) AS cst_lastname,

CASE WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
ELSE 'Not Specified' END AS cst_marital_status,

CASE WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
ELSE 'Not Specified' END AS cst_gndr
,cst_create_date FROM
(
--Checking for timestamps of same ids
-- This will sort all same same ids with numbers and flag them as 1,2,3,.... based on ranking in their own id
-- Now we need to select only flag=1 (lastest one) and remove older
SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
 FROM bronze.crm_cust_info
)t WHERE flag=1;


SELECT * FROM silver.crm_cust_info; 



-- NOW check for duplicates in silver layer
SELECT * FROM (
--Checking for timestamps of same ids
-- This will sort all same same ids with numbers and flag them as 1,2,3,.... based on ranking in their own id
-- Now we need to select only flag=1 (lastest one) and remove older
SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
 FROM silver.crm_cust_info
)t WHERE flag!=1;






        ------------------------crm_prd_info------------------------

SELECT * FROM bronze.crm_prd_info;
SELECT prd_id, COUNT(*) FROM bronze.crm_prd_info GROUP BY prd_id HAVING COUNT(*) > 1;



INSERT INTO silver.crm_prd_info
SELECT
prd_id
,
-- In this product key 1st 4 letters are category id so extract it
REPLACE(SUBSTRING(prd_key,1, 5),'-','_') AS cat_id --Adds a column cat_id
,SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key -- Now extract other part of the number
,prd_nm
,COALESCE(prd_cost,0) AS prd_cost
,
CASE UPPER(TRIM(prd_line))
WHEN 'M' THEN 'Mountain'
WHEN 'R' THEN 'Road'
WHEN 'S' THEN 'Other Sales'
WHEN 'T' THEN 'Touring'
ELSE 'Not Specified' END AS prd_line -- Map lines to descriptive values
,prd_start_dt
,LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt -- pt 1*
FROM 
bronze.crm_prd_info
;


-- Now in this some of the dates are like start>end so need to fix that
-- also there could be some overlapping date timelines

-- 1*
-- A fix could be to disregard end date and order them by start date and then end date for next will be start date of previous
-- as it would make sense, and the last one will have NULL/current as its the latest one
-- LEAD() function can be used to get the next row's start date and use it as end date for current row


-- Date check
SELECT*FROM silver.crm_prd_info
WHERE prd_end_dt<prd_start_dt



SELECT * FROM silver.crm_prd_info;
SELECT distinct id from bronze.erp_cat_info; -- This info is in cat_id as we created and checked
SELECT distinct sls_prd_key from bronze.crm_sales_details; -- This info is in prd_key as we created and checked


        ------------------------crm_sales_details------------------------

SELECT * FROM bronze.crm_sales_details;
-- Now dates are in int format
-- Checks for dates:-
-- - date<=0 should be null
-- - date length should be 8
-- - date should be valid as the year provided by provider (> starting year and < ending or current year)
-- - order date < = ship date <= due date



-- BUSINESS RULES
-- Sales = Quantity * Price
-- Negative sales, quantity, null should not be allowed
SELECT 
NULLIF(sls_order_dt,0) sales_order_dt -- dates = 0 should be null
FROM bronze.crm_sales_details
WHERE sls_order_dt<0
OR LENGTH(CAST(sls_order_dt AS VARCHAR))!=8
OR sls_order_dt<20000101
OR sls_order_dt>20231231
;


INSERT INTO silver.crm_sales_details
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,

CASE WHEN sls_order_dt=0 OR LENGTH(CAST(sls_order_dt AS VARCHAR))!=8 THEN NULL 
ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sales_order_dt,

CASE WHEN sls_ship_dt=0 OR LENGTH(CAST(sls_ship_dt AS VARCHAR))!=8 THEN NULL 
ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sales_ship_dt,

CASE WHEN sls_due_dt=0 OR LENGTH(CAST(sls_due_dt AS VARCHAR))!=8 THEN NULL 
ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sales_due_dt,

CASE WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales!=sls_quantity*sls_price THEN sls_quantity*ABS(sls_price)
 ELSE sls_sales
END AS sales_sales,


sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price<=0
    THEN sls_sales/NULLIF(sls_quantity,0)
    ELSE sls_price END AS sls_price


FROM bronze.crm_sales_details



-- Business rules check
SELECT * FROM bronze.crm_sales_details
WHERE sls_sales<0
OR sls_quantity<0
OR sls_price<0
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales!=sls_quantity*sls_price


-- Rules assumed to be applied:-
-- - if sales<=0 or null then derive using quantity and price
-- - if price=0 or null the do it with sales and quantity
-- - if price <0 convert to +ve 

-- LOOKUP
SELECT * FROM silver.crm_sales_details