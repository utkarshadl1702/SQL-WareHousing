TRUNCATE TABLE bronze.crm_cust_info;
COPY bronze.crm_cust_info
FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_crm/cust_info.csv'
WITH (FORMAT csv, HEADER true);

Select COUNT(*) from bronze.crm_cust_info;

TRUNCATE TABLE bronze.crm_prd_info;
COPY bronze.crm_prd_info
FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_crm/prd_info.csv'
WITH (FORMAT csv, HEADER true);

select COUNT(*) from bronze.crm_prd_info;

COPY bronze.crm_sales_details
FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_crm/sales_details.csv'
WITH (FORMAT csv, HEADER true);


COPY bronze.erp_cat_info
FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_erp/PX_CAT_G1V2.csv'
WITH (FORMAT csv, HEADER true);


TRUNCATE TABLE bronze.erp_loc_info;
COPY bronze.erp_cust_info
FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_erp/CUST_AZ12.csv'
WITH (FORMAT csv, HEADER true);


COPY bronze.erp_loc_info
FROM '/Users/utkarshadlakha/Documents/SQL-WareHousing/datasets/source_erp/LOC_A101.csv'
WITH (FORMAT csv, HEADER true);

