/*
===============================================================================
Stored Procedure: Load Snowflake Layer (Silver -> Snowflake)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL process to populate the 'snowflake' schema
    tables from the 'silver' schema.
    Actions Performed:
        - Truncates Snowflake tables.
        - Inserts transformed data from Silver into Snowflake tables.

Parameters:
    None.

Usage Example:
    CALL snowflake.proc_load_snowflake;
===============================================================================
*/

DROP PROCEDURE IF EXISTS snowflake.proc_load_snowflake;

DELIMITER $$

CREATE PROCEDURE snowflake.proc_load_snowflake()
BEGIN
    SET @batch_start_time := NOW();
    SELECT "=====================================================";
    SELECT "Loading Snowflake Layer";
    SELECT "=====================================================";

    -- Load dim_country
    SET @start_time := NOW();
        SELECT "Truncating Table: snowflake.dim_country";
        TRUNCATE TABLE snowflake.dim_country;
        SELECT "Inserting Data Into: snowflake.dim_country";
        INSERT INTO snowflake.dim_country (country_key, country)
        SELECT
            ROW_NUMBER() OVER (ORDER BY cntry) AS country_key, -- Surrogate key
            cntry AS country
        FROM (
            SELECT DISTINCT cntry
            FROM silver.erp_loc_a101
        ) t;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    -- Load dim_category
    SET @start_time := NOW();
        SELECT "Truncating Table: snowflake.dim_category";
        TRUNCATE TABLE snowflake.dim_category;
        SELECT "Inserting Data Into: snowflake.dim_category";
        INSERT INTO snowflake.dim_category (category_key, category)
        SELECT
            ROW_NUMBER() OVER (ORDER BY cat) AS category_key, -- Surrogate key
            cat AS category
        FROM (
            SELECT DISTINCT cat
            FROM silver.erp_px_cat_g1v2
        ) t;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    -- Load dim_subcategory
    SET @start_time := NOW();
        SELECT "Truncating Table: snowflake.dim_subcategory";
        TRUNCATE TABLE snowflake.dim_subcategory;
        SELECT "Inserting Data Into: snowflake.dim_subcategory";
        INSERT INTO snowflake.dim_subcategory (subcategory_key, subcategory_id, subcategory, maintenance, category_key)
        SELECT
            ROW_NUMBER() OVER (ORDER BY pc.subcat) AS subcategory_key, -- Surrogate key
            pc.id as subcategory_id,
            pc.subcat as subcategory,
            pc.maintenance,
            dc.category_key AS category_key
        FROM silver.erp_px_cat_g1v2 pc
        LEFT JOIN snowflake.dim_category dc
        ON pc.cat = dc.category;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    -- Load dim_product_line
    SET @start_time := NOW();
        SELECT "Truncating Table: snowflake.dim_product_line";
        TRUNCATE TABLE snowflake.dim_product_line;
        SELECT "Inserting Data Into: snowflake.dim_product_line";
        INSERT INTO snowflake.dim_product_line (product_line_key, product_line)
        SELECT
            ROW_NUMBER() OVER(ORDER BY prd_line) AS product_line_key, -- Surrogate key
            prd_line AS product_line
        FROM (
            SELECT DISTINCT prd_line
            FROM silver.crm_prd_info
        ) t;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    -- Load dim_products
    SET @start_time := NOW();
        SELECT "Truncating Table: snowflake.dim_products";
        TRUNCATE TABLE snowflake.dim_products;
        SELECT "Inserting Data Into: snowflake.dim_products";
        INSERT INTO snowflake.dim_products (
            product_key,
            product_id,
            product_number,
            product_name,
            subcategory_key,
            cost,
            product_line_key,
            start_date
        )
        SELECT
            ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key, -- Surrogate key
            pi.prd_id       AS product_id,
            pi.prd_key      AS product_number,
            pi.prd_nm       AS product_name,
            su.subcategory_key	AS subcategory_key,
            pi.prd_cost     AS cost,
            pl.product_line_key,
            pi.prd_start_dt AS start_date
        FROM silver.crm_prd_info pi
        LEFT JOIN snowflake.dim_subcategory su
            ON pi.cat_id = su.subcategory_id
        LEFT JOIN snowflake.dim_product_line pl
            ON pi.prd_line = pl.product_line
        WHERE pi.prd_end_dt IS NULL;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    -- Load dim_customer
    SET @start_time := NOW();
        SELECT "Truncating Table: snowflake.dim_customer";
        TRUNCATE TABLE snowflake.dim_customer;
        SELECT "Inserting Data Into: snowflake.dim_customer";
        INSERT INTO snowflake.dim_customer (
            customer_key,
            customer_id,
            customer_number,
            first_name,
            last_name,
            country_key,
            marital_status,
            gender,
            birthdate,
            create_date
        )
        WITH CTE AS (
            SELECT
                la.cid AS customer_id,
                co.country_key AS country_key,
                co.country
            FROM silver.erp_loc_a101 la
            JOIN snowflake.dim_country co
            ON la.cntry = co.country
        )
        SELECT
            ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Surrogate key
            ci.cst_id                          AS customer_id,
            ci.cst_key                         AS customer_number,
            ci.cst_firstname                   AS first_name,
            ci.cst_lastname                    AS last_name,
            ct.country_key                     AS country_key,
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
        LEFT JOIN cte ct
            ON ci.cst_key = ct.customer_id;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    -- Load fact_sales
    SET @start_time := NOW();
        SELECT "Truncating Table: snowflake.fact_sales";
        TRUNCATE TABLE snowflake.fact_sales;
        SELECT "Inserting Data Into: snowflake.fact_sales";
        INSERT INTO snowflake.fact_sales (
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
        LEFT JOIN snowflake.dim_products pr
            ON sd.sls_prd_key = pr.product_number
        LEFT JOIN snowflake.dim_customers cu
            ON sd.sls_cust_id = cu.customer_id;
    SET @end_time := NOW();
    SELECT CONCAT("Load Duration: ", TIMESTAMPDIFF(SECOND, @start_time, @end_time), " seconds");
    SELECT "-------------------------";

    SET @batch_end_time := NOW();
    SELECT "=====================================================";
    SELECT "Loading Snowflake Layer is Completed";
    SELECT CONCAT("Total Load Duration: ", TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time), " seconds");
    SELECT "=====================================================";
END $$
DELIMITER ;