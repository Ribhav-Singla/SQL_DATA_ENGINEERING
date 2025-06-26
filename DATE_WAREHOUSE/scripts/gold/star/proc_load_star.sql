/*
===============================================================================
Stored Procedure: Load Star Layer (Silver -> Star)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to populate the 'star' schema
    tables from the 'silver' schema.
    Actions Performed:
        - Truncates Star tables.
        - Inserts transformed data from Silver into Star tables.

Parameters:
    None.

Usage Example:
    CALL star.proc_load_star;
===============================================================================
*/

DROP PROCEDURE IF EXISTS star.proc_load_star;

DELIMITER $$

CREATE PROCEDURE star.proc_load_star()
BEGIN
    SET @batch_start_time := NOW();
    SELECT "=====================================================";
    SELECT "Loading Star Layer";
    SELECT "=====================================================";

    -- Load dim_customers
    SET @start_time := NOW();
        SELECT "Truncating Table: star.dim_customers";
        TRUNCATE TABLE star.dim_customers;

        SELECT "Inserting Data Into: star.dim_customers";
        INSERT INTO star.dim_customers(
            customer_key,
            customer_id,
            customer_number,
            first_name,
            last_name,
            country,
            marital_status,
            gender,
            birthdate,
            create_date
        )
        SELECT
            ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Surrogate key
            ci.cst_id                          AS customer_id,
            ci.cst_key                         AS customer_number,
            ci.cst_firstname                   AS first_name,
            ci.cst_lastname                    AS last_name,
            la.cntry                           AS country,
            ci.cst_marital_status              AS marital_status,
            CASE 
                WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
                ELSE COALESCE(ca.gen, 'n/a')  			   
            END                                AS gender,
            ca.bdate                           AS birthdate,
            ci.cst_create_date                 AS create_date
        FROM silver.crm_cust_info ci
        LEFT JOIN silver.erp_cust_az12 ca
            ON ci.cst_key = ca.cid
        LEFT JOIN silver.erp_loc_a101 la
            ON ci.cst_key = la.cid;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    -- Load dim_products
    SET @start_time := NOW();
        SELECT "Truncating Table: star.dim_products";
        TRUNCATE TABLE star.dim_products;

        SELECT "Inserting Data Into: star.dim_products";
        INSERT INTO star.dim_products (
            product_key,
            product_id,
            product_number,
            product_name,
            category_id,
            category,
            subcategory,
            maintenance,
            cost,
            product_line,
            start_date
        )
        SELECT
            ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key, -- Surrogate key
            pi.prd_id       AS product_id,
            pi.prd_key      AS product_number,
            pi.prd_nm       AS product_name,
            pi.cat_id       AS category_id,
            pc.cat          AS category,
            pc.subcat       AS subcategory,
            pc.maintenance  AS maintenance,
            pi.prd_cost     AS cost,
            pi.prd_line     AS product_line,
            pi.prd_start_dt AS start_date
        FROM silver.crm_prd_info pi
        LEFT JOIN silver.erp_px_cat_g1v2 pc
            ON pi.cat_id = pc.id
        WHERE pi.prd_end_dt IS NULL;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    -- Load fact_sales
    SET @start_time := NOW();
        SELECT "Truncating Table: star.fact_sales";
        TRUNCATE TABLE star.fact_sales;

        SELECT "Inserting Data Into: star.fact_sales";
        INSERT INTO star.fact_sales (
            order_number,
            product_key,
            customer_key,
            order_date,
            shipping_date,
            due_date,
            sales_amount,
            quantity,
            price
        )
        SELECT
            sd.sls_ord_num  AS order_number,
            pr.product_key  AS product_key,
            cu.customer_key AS customer_key,
            sd.sls_order_dt AS order_date,
            sd.sls_ship_dt  AS shipping_date,
            sd.sls_due_dt   AS due_date,
            sd.sls_sales    AS sales_amount,
            sd.sls_quantity AS quantity,
            sd.sls_price    AS price
        FROM silver.crm_sales_details sd
        LEFT JOIN star.dim_products pr
            ON sd.sls_prd_key = pr.product_number
        LEFT JOIN star.dim_customers cu
            ON sd.sls_cust_id = cu.customer_id;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    SET @batch_end_time := NOW();
    SELECT "=====================================================";
    SELECT "Loading Star Layer is Completed";
    SELECT CONCAT("Total Load Duration: ", TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time), " seconds");
    SELECT "=====================================================";
END $$
DELIMITER ;