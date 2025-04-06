/*
===============================================================================
Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This loads data into the 'bronze' database from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `LOAD DATA` command to load data from csv Files to bronze tables.
===============================================================================
*/

SET @batch_start_time := NOW();
SELECT "=====================================================";
SELECT "Loading Bronze Layer";
SELECT "=====================================================";

-- This is used to load the uncleaned data as it is by avoiding error.
SELECT @@SESSION.sql_mode;
SET SESSION sql_mode = '';

SELECT "-----------------------------------------------------";
SELECT "Loading CRM Tables";
SELECT "-----------------------------------------------------";

SET @start_time := NOW();
	SELECT "Truncating Table: bronze.crm_cust_info";
	TRUNCATE TABLE bronze.crm_cust_info;

	SELECT "Inserting Data Into: bronze.crm_cust_info";
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
	INTO TABLE bronze.crm_cust_info
	FIELDS TERMINATED BY ',' 
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date);
SET @end_time := NOW();
SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
SELECT "-------------------------";

SET @start_time := NOW();
	SELECT "Truncating Table: bronze.crm_prd_info";
	TRUNCATE TABLE bronze.crm_prd_info;

	SELECT "Inserting Data Into: bronze.crm_prd_info";
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
	INTO TABLE bronze.crm_prd_info
	FIELDS TERMINATED BY ',' 
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(prd_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt);
SET @end_time := NOW();
SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
SELECT "-------------------------";

SET @start_time:= NOW();
	SELECT "Truncating Table: bronze.crm_sales_details";
	TRUNCATE TABLE bronze.crm_sales_details;

	SELECT "Inserting Data Into: bronze.crm_sales_details";
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
	INTO TABLE bronze.crm_sales_details
	FIELDS TERMINATED BY ',' 
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price);
SET @end_time := NOW();
SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
SELECT "-------------------------";

SELECT "-----------------------------------------------------";
SELECT "Loading Erp Tables";
SELECT "-----------------------------------------------------";

SET @start_time := NOW();
	SELECT "Truncating Table: bronze.erp_loc_a101";
	TRUNCATE TABLE bronze.erp_loc_a101;

	SELECT "Inserting Data Into: bronze.erp_loc_a101";
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
	INTO TABLE bronze.erp_loc_a101
	FIELDS TERMINATED BY ',' 
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(CID,CNTRY);
SET @end_time := NOW();
SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
SELECT "-------------------------";

SET @start_time:= NOW();
	SELECT "Truncating Table: bronze.erp_cust_az12";
	TRUNCATE TABLE bronze.erp_cust_az12;

	SELECT "Inserting Data Into: bronze.erp_cust_az12";
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
	INTO TABLE bronze.erp_cust_az12
	FIELDS TERMINATED BY ',' 
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(CID,BDATE,GEN);
SET @end_time := NOW();
SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
SELECT "-------------------------";

SET @start_time := NOW();
	SELECT "Truncating Table: bronze.erp_px_cat_g1v2";
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;

	SELECT "Inserting Data Into: bronze.erp_px_cat_g1v2";
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
	INTO TABLE bronze.erp_px_cat_g1v2
	FIELDS TERMINATED BY ',' 
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(ID,CAT,SUBCAT,MAINTENANCE);
SET @end_time := NOW();
SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
SELECT "-------------------------";

SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SELECT @@SESSION.sql_mode;

SET @batch_end_time := NOW();
SELECT "=====================================================";
SELECT "Loading Bronze Layer is Completed";
SELECT CONCAT("Total Load Duration: ", TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time), " seconds");
SELECT "=====================================================";