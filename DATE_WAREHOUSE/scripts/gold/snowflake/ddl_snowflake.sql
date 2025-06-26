

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

