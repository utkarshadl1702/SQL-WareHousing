CREATE OR REPLACE PROCEDURE silver.load_silver_erp()
LANGUAGE plpgsql
AS $$
BEGIN

----------------------------ERP--------------------------------
-- Truncate the tables before inserting to avoid duplicates
            --------erp_cust_info-------
-- we can connect this table with crm_cust_info using cst_key and cst_id


-- Comparing tables

-- SELECT * FROM silver.crm_cust_info

-- SELECT * FROM bronze.erp_cust_info



-- In cid we have NAS as extra letters so we can remove them
-- There are dates which can be seen in future (future bdays are not possible)

-- gen has NULL/F/M/Male/Female

TRUNCATE TABLE silver.erp_cust_info;
INSERT INTO silver.erp_cust_info
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LENGTH(cid))
    ELSE cid
END AS cid,


CASE WHEN bdate > CURRENT_TIMESTAMP THEN NULL
ELSE bdate END AS bdate,


CASE 
WHEN UPPER (TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
WHEN UPPER (TRIM(gen)) IN ('M','MALE') THEN 'Male'
ELSE 'n/a'
END AS gen

FROM bronze.erp_cust_info;




-- Also check for unmatching data in both the tables
--WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LENGTH(cid))
    --ELSE cid END  IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

-- SELECT * FROM silver.erp_cust_info


            --------erp_loc_info--------
-- Need to join it with silver crm_cust_info via cid

-- SELECT * FROM bronze.erp_loc_info



TRUNCATE TABLE silver.erp_loc_info;
INSERT INTO silver.erp_loc_info
SELECT
REPLACE(cid,'-','') AS cid,   -- Remove extra dashes between the cid

CASE WHEN TRIM(cntry)='DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
    WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_info;


-- Data standardization



-- SELECT DISTINCT cntry FROM bronze.erp_loc_info ORDER BY cntry

-- SELECT * FROM silver.erp_loc_info

-- USA has 3 versions:- United States, US, USA
-- null values found
-- empty values found
-- DE found for Germany

            ---------------erp_cat_info-----------------
TRUNCATE TABLE silver.erp_cat_info;
INSERT INTO silver.erp_cat_info
SELECT
id,
cat,
subcat,
maintenance

FROM bronze.erp_cat_info;

-- can connect it to crm_prd_info using prd_key

-- check for unwanted spaces as well as any unwanted information
-- SELECT DISTINCT cat FROM bronze.erp_cat_info

-- SELECT * FROM bronze.erp_cat_info
-- WHERE cat!=TRIM(cat)





-- SELECT * FROM silver.erp_cat_info
END;
$$;

