/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL silver.load_silver;
===============================================================================
*/

DROP PROCEDURE IF EXISTS silver.load_silver;

DELIMITER $$

CREATE PROCEDURE silver.load_silver()
BEGIN
	SET @batch_start_time := NOW();
	SELECT "=====================================================";
	SELECT "Loading Silver Layer";
	SELECT "=====================================================";

	SELECT "-----------------------------------------------------";
	SELECT "Loading CRM Tables";
	SELECT "-----------------------------------------------------";
    
    SET @start_time := NOW();
		SELECT "Truncating Table: silver.crm_cust_info";
		TRUNCATE TABLE silver.crm_cust_info;

		SELECT "Inserting Data Into: silver.crm_cust_info";
		INSERT INTO silver.crm_cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status,
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr, 
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL AND cst_id <> 0
		) t
		WHERE flag_last = 1;
    SET @end_time := NOW();
	SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
	SELECT "-------------------------";

	SET @start_time:= NOW();
		SELECT "Truncating Table: silver.crm_prd_info";
		TRUNCATE TABLE silver.crm_prd_info;

		SELECT "Inserting Data Into: silver.crm_prd_info";
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,        
			prd_nm,
			IFNULL(prd_cost, 0) AS prd_cost,
			CASE 
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line, 
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				DATE_SUB(
					LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
					INTERVAL 1 DAY
				) AS DATE
			) AS prd_end_dt
		FROM bronze.crm_prd_info;
    SET @end_time := NOW();
	SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
	SELECT "-------------------------";

	SET @start_time:= NOW();
		SELECT "Truncating Table: silver.crm_sales_details";
		TRUNCATE TABLE silver.crm_sales_details;

		SELECT "Inserting Data Into: silver.crm_sales_details";
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
			END AS sls_due_dt,
			CASE
        		WHEN sls_sales IS NULL OR sls_sales <= 0 
					OR sls_sales != sls_quantity * ABS(
                 		CASE 
							WHEN sls_price IS NULL OR sls_price = 0 
								THEN sls_sales / NULLIF(sls_quantity, 0)
							WHEN sls_price < 0 
								THEN ABS(sls_price)
							ELSE sls_price
						END
            		)
        			THEN sls_quantity * ABS(
            			CASE 
							WHEN sls_price IS NULL OR sls_price = 0 
								THEN sls_sales / NULLIF(sls_quantity, 0)
							WHEN sls_price < 0 
								THEN ABS(sls_price)
							ELSE sls_price
						END
					)
					ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price = 0 
					THEN sls_sales / NULLIF(sls_quantity, 0)
				WHEN sls_price < 0 
					THEN ABS(sls_price)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
    SET @end_time := NOW();
	SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
	SELECT "-------------------------";

	SET @start_time := NOW();
		SELECT "Truncating Table: silver.erp_cust_az12";
		TRUNCATE TABLE silver.erp_cust_az12;

		SELECT "Inserting Data Into: silver.erp_cust_az12";
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
				ELSE cid
			END AS cid, 
			CASE
				WHEN bdate > CURRENT_DATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE
				WHEN UPPER(TRIM(REPLACE(gen,'\r',''))) in ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(REPLACE(gen,'\r',''))) in ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;
    SET @end_time := NOW();
	SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
	SELECT "-------------------------";

	SET @start_time := NOW();
		SELECT "Truncating Table: silver.erp_loc_a101";
		TRUNCATE TABLE silver.erp_loc_a101;

		SELECT "Inserting Data Into: silver.erp_loc_a101";
		INSERT INTO silver.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid, 
			CASE
				WHEN UPPER(TRIM(REPLACE(cntry,'\r',''))) = 'DE' THEN 'Germany'
				WHEN UPPER(TRIM(REPLACE(cntry,'\r',''))) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(REPLACE(cntry,'\r','')) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(REPLACE(cntry,'\r',''))
			END AS cntry
		FROM bronze.erp_loc_a101;
    SET @end_time := NOW();
	SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
	SELECT "-------------------------";

	SET @start_time := NOW();
		SELECT "Truncating Table: silver.erp_px_cat_g1v2";
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		SELECT "Inserting Data Into: silver.erp_px_cat_g1v2";
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			CASE
				WHEN UPPER(TRIM(REPLACE(maintenance,'\r',''))) = 'YES' THEN 'Yes'
				WHEN UPPER(TRIM(REPLACE(maintenance,'\r',''))) = 'NO' THEN 'No'
				ELSE 'n/a'
			END AS maintenance
		FROM bronze.erp_px_cat_g1v2;
    SET @end_time := NOW();
	SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
	SELECT "-------------------------";	
    
    SET @batch_end_time := NOW();
	SELECT "=====================================================";
	SELECT "Loading Silver Layer is Completed";
	SELECT CONCAT("Total Load Duration: ", TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time), " seconds");
	SELECT "=====================================================";
END $$
DELIMITER ;
