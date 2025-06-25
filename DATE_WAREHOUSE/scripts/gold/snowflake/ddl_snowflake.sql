DROP DATABASE IF EXISTS snowflake;

CREATE DATABASE snowflake;

USE snowflake;

DROP TABLE IF EXISTS snowflake.dim_country;

CREATE TABLE snowflake.dim_country(
    country_key INT,
    country VARCHAR(50)
);

DROP TABLE IF EXISTS snowflake.dim_category;

CREATE TABLE snowflake.dim_category(
    category_key INT,
    category VARCHAR(50)
);

DROP TABLE IF EXISTS snowflake.dim_subcategory;

CREATE TABLE snowflake.dim_subcategory(
    subcategory_key INT,
    subcategory_id VARCHAR(50),
    subcategory VARCHAR(50),
    maintenance VARCHAR(50),
    category_key INT
);

DROP TABLE IF EXISTS snowflake.dim_product_line;

CREATE TABLE snowflake.dim_product_line (
    product_line_key INT,
    product_line VARCHAR(50)
);

DROP TABLE IF EXISTS snowflake.dim_products;

CREATE TABLE snowflake.dim_products (
    product_key INT,
    product_id INT,
    product_number VARCHAR(50),
    product_name VARCHAR(50),
    subcategory_key INT,
    cost INT,
    product_line_key INT,
    start_date DATE
);

DROP TABLE IF EXISTS snowflake.dim_customer;

CREATE TABLE snowflake.dim_customer (
    customer_key INT,
    customer_id INT,
    customer_number VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country_key INT,
    marital_status VARCHAR(50),
    gender VARCHAR(50),
    birthdate DATE,
    create_date DATE
);

DROP TABLE IF EXISTS snowflake.fact_sales;

CREATE TABLE snowflake.fact_sales (
    order_number VARCHAR(50),
    product_key INT,
    customer_key INT,
    order_date DATE,
    shipping_date DATE,
    due_date DATE,
    sales_amount INT,
    quantity INT,
    price INT
);

INSERT INTO snowflake.dim_country (country_key, country)
SELECT
    ROW_NUMBER() OVER (ORDER BY cntry) AS country_key, -- Surrogate key
    cntry AS country
FROM (
    SELECT DISTINCT cntry
    FROM silver.erp_loc_a101
) t;

INSERT INTO snowflake.dim_category (category_key, category)
SELECT
    ROW_NUMBER() OVER (ORDER BY cat) AS category_key, -- Surrogate key
    cat AS category
FROM (
    SELECT DISTINCT cat
    FROM silver.erp_px_cat_g1v2
) t;

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

INSERT INTO snowflake.dim_product_line (product_line_key, product_line)
SELECT
	ROW_NUMBER() OVER(ORDER BY prd_line) AS product_line_key, -- Surrogate key
    prd_line AS product_line
FROM (
	SELECT DISTINCT prd_line
    FROM silver.crm_prd_info
) t;

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