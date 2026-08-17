----------------------------ERP--------------------------------

            --------erp_cust_info-------
-- we can connect this table with crm_cust_info using cst_key and cst_id


-- Comparing tables
 SELECT * FROM silver.crm_cust_info

 SELECT * FROM bronze.erp_cust_info



-- In cid we have NAS as extra letters so we can remove them
-- There are dates which can be seen in future (future bdays are not possible)

-- gen has NULL/F/M/Male/Female

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

FROM bronze.erp_cust_info




-- Also check for unmatching data in both the tables
--WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LENGTH(cid))
    --ELSE cid END  IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

SELECT * FROM silver.erp_cust_info


