-- Avoid inner join as it might lose customers (data)


-- It is a dimension table as it is telling the information not the events or facts
SELECT 
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr != 'Not Specified' THEN
    ci.cst_gndr ELSE
    COALESCE(ca.gen,'n/a')
    END AS Gender,
    ci.cst_create_date AS create_date,

    ca.bdate AS birthdate,

    la.cntry AS country
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_info AS ca
ON ci.cst_key = ca.cid -- Done after preparation of data in silver layer

LEFT JOIN silver.erp_loc_info AS la
ON ci.cst_key=la.cid


-- Rename columns to friendly names

------------------------------- Checks ---------------------------------


-- Now in this we have 2 columns for gender we need to do data integration

SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE WHEN ci.cst_gndr != 'Not Specified' THEN
    ci.cst_gndr ELSE
    COALESCE(ca.gen,'n/a')
    END AS new_gen

FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_info AS ca
ON ci.cst_key = ca.cid -- Done after preparation of data in silver layer

LEFT JOIN silver.erp_loc_info AS la
ON ci.cst_key=la.cid

ORDER BY 1,2
-- Nulls can come after joining as if tables dont find match
-- Also some issues with mismatching data
-- Ask for master column, we will give more priority to that column while integrating 
-- In this scenario crm is master table





-- Make sure for no duplicates

SELECT cst_id,COUNT(*) FROM
(SELECT 
    ci.cst_id ,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,

    ca.bdate,
    ca.gen,

    la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_info AS ca
ON ci.cst_key = ca.cid -- Done after preparation of data in silver layer

LEFT JOIN silver.erp_loc_info AS la
ON ci.cst_key=la.cid)t GROUP BY cst_id
HAVING COUNT(*)>1

