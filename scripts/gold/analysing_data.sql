-- Avoid inner join as it might lose customers (data)
----------------------------Customer dimension-----------------------------
CREATE VIEW gold.dim_customers AS
-- It is a dimension table as it is telling the information not the events or facts
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- surrogate key to define this table
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


-------------------------------Product Dimension-------------------------------


CREATE VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.prd_cost AS product_cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date,
-- pn.prd_end_dt

pn.cat_id AS category_id,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance

FROM silver.crm_prd_info AS pn

LEFT JOIN silver.erp_cat_info AS pc
 ON pn.cat_id=pc.id
WHERE prd_end_dt IS NULL -- Filter out all historical data



--- Uniqueness Check

SELECT prd_key,COUNT(*) FROM(
SELECT 
pn.prd_id,
pn.prd_key,
pn.prd_nm,
-- pn.prd_end_dt
pn.cat_id,
pc.cat,
pn.prd_cost,
pc.maintenance,
pn.prd_line,
pn.prd_start_dt,
pc.subcat


FROM silver.crm_prd_info AS pn

LEFT JOIN silver.erp_cat_info AS pc
 ON pn.cat_id=pc.id
WHERE prd_end_dt IS NULL 
)t GROUP BY prd_key HAVING COUNT(*)>1


-------------------------------Sales Fact-------------------------------

-- lots of transactions and data so consider this as fact
-- Connect with the dimensions

CREATE VIEW gold.fact_sales AS
SELECT 
sd.sls_ord_num AS order_number,
-- sd.sls_prd_key,
pr.product_key,--Surrogate key
-- sd.sls_cust_id,
cu.customer_id, -- Surrogate key
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS sales_quantity,
sd.sls_price AS price

FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr 
ON sd.sls_prd_key=pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id=cu.customer_id