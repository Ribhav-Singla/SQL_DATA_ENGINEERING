# Data Catalog for Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension and fact tables for specific business metrics. This project implements two distinct schemas: a Star Schema and a Snowflake Schema.

---

## Star Schema (`star` database)

A denormalized model optimized for fast queries.

### 1. **star.dim_customers**
- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**

| Column Name      | Data Type     | Description                                      |
|------------------|---------------|--------------------------------------------------|
| `customer_key`   | INT           | Surrogate key for the customer dimension.        |
| `customer_id`    | INT           | Original customer identifier from the source.    |
| `customer_number`| VARCHAR(50)   | Business key for the customer.                   |
| `first_name`     | VARCHAR(50)   | Customer's first name.                           |
| `last_name`      | VARCHAR(50)   | Customer's last name.                            |
| `country`        | VARCHAR(50)   | Customer's country of residence.                 |
| `marital_status` | VARCHAR(50)   | Customer's marital status.                       |
| `gender`         | VARCHAR(50)   | Customer's gender.                               |
| `birthdate`      | DATE          | Customer's date of birth.                        |
| `create_date`    | DATE          | Date the customer record was created.            |

### 2. **star.dim_products**
- **Purpose:** Provides detailed information about products.
- **Columns:**

| Column Name      | Data Type     | Description                                      |
|------------------|---------------|--------------------------------------------------|
| `product_key`    | INT           | Surrogate key for the product dimension.         |
| `product_id`     | INT           | Original product identifier from the source.     |
| `product_number` | VARCHAR(50)   | Business key for the product.                    |
| `product_name`   | VARCHAR(50)   | Name of the product.                             |
| `category_id`    | VARCHAR(50)   | Identifier for the product category.             |
| `category`       | VARCHAR(50)   | Product category name.                           |
| `subcategory`    | VARCHAR(50)   | Product subcategory name.                        |
| `maintenance`    | VARCHAR(50)   | Indicates if maintenance is required.            |
| `cost`           | INT           | Cost of the product.                             |
| `product_line`   | VARCHAR(50)   | Product line (e.g., Road, Mountain).             |
| `start_date`     | DATE          | Date the product became available.               |

### 3. **star.fact_sales**
- **Purpose:** Stores transactional sales data.
- **Columns:**

| Column Name      | Data Type     | Description                                      |
|------------------|---------------|--------------------------------------------------|
| `order_number`   | VARCHAR(50)   | Unique identifier for the sales order.           |
| `product_key`    | INT           | Foreign key referencing `dim_products`.          |
| `customer_key`   | INT           | Foreign key referencing `dim_customers`.         |
| `order_date`     | DATE          | Date the order was placed.                       |
| `shipping_date`  | DATE          | Date the order was shipped.                      |
| `due_date`       | DATE          | Date the payment was due.                        |
| `sales_amount`   | INT           | Total sales amount for the transaction.          |
| `quantity`       | INT           | Number of units sold.                            |
| `price`          | INT           | Price per unit.                                  |

---

## Snowflake Schema (`snowflake` database)

A normalized model that reduces redundancy by breaking down dimensions.

### 1. **snowflake.dim_country**
- **Purpose:** Stores country information.
- **Columns:**

| Column Name   | Data Type     | Description                                      |
|---------------|---------------|--------------------------------------------------|
| `country_key` | INT           | Surrogate key for the country dimension.         |
| `country`     | VARCHAR(50)   | Name of the country.                             |

### 2. **snowflake.dim_category**
- **Purpose:** Stores product category information.
- **Columns:**

| Column Name    | Data Type     | Description                                      |
|----------------|---------------|--------------------------------------------------|
| `category_key` | INT           | Surrogate key for the category dimension.        |
| `category`     | VARCHAR(50)   | Name of the product category.                    |

### 3. **snowflake.dim_subcategory**
- **Purpose:** Stores product subcategory information.
- **Columns:**

| Column Name       | Data Type     | Description                                      |
|-------------------|---------------|--------------------------------------------------|
| `subcategory_key` | INT           | Surrogate key for the subcategory dimension.     |
| `subcategory_id`  | VARCHAR(50)   | Original subcategory identifier.                 |
| `subcategory`     | VARCHAR(50)   | Name of the product subcategory.                 |
| `maintenance`     | VARCHAR(50)   | Indicates if maintenance is required.            |
| `category_key`    | INT           | Foreign key referencing `dim_category`.          |

### 4. **snowflake.dim_product_line**
- **Purpose:** Stores product line information.
- **Columns:**

| Column Name        | Data Type     | Description                                      |
|--------------------|---------------|--------------------------------------------------|
| `product_line_key` | INT           | Surrogate key for the product line dimension.    |
| `product_line`     | VARCHAR(50)   | Name of the product line.                        |

### 5. **snowflake.dim_products**
- **Purpose:** Central product dimension, linking to normalized attributes.
- **Columns:**

| Column Name       | Data Type     | Description                                      |
|-------------------|---------------|--------------------------------------------------|
| `product_key`     | INT           | Surrogate key for the product dimension.         |
| `product_id`      | INT           | Original product identifier.                     |
| `product_number`  | VARCHAR(50)   | Business key for the product.                    |
| `product_name`    | VARCHAR(50)   | Name of the product.                             |
| `subcategory_key` | INT           | Foreign key referencing `dim_subcategory`.       |
| `cost`            | INT           | Cost of the product.                             |
| `product_line_key`| INT           | Foreign key referencing `dim_product_line`.      |
| `start_date`      | DATE          | Date the product became available.               |

### 6. **snowflake.dim_customer**
- **Purpose:** Central customer dimension, linking to normalized attributes.
- **Columns:**

| Column Name      | Data Type     | Description                                      |
|------------------|---------------|--------------------------------------------------|
| `customer_key`   | INT           | Surrogate key for the customer dimension.        |
| `customer_id`    | INT           | Original customer identifier.                    |
| `customer_number`| VARCHAR(50)   | Business key for the customer.                   |
| `first_name`     | VARCHAR(50)   | Customer's first name.                           |
| `last_name`      | VARCHAR(50)   | Customer's last name.                            |
| `country_key`    | INT           | Foreign key referencing `dim_country`.           |
| `marital_status` | VARCHAR(50)   | Customer's marital status.                       |
| `gender`         | VARCHAR(50)   | Customer's gender.                               |
| `birthdate`      | DATE          | Customer's date of birth.                        |
| `create_date`    | DATE          | Date the customer record was created.            |

### 7. **snowflake.fact_sales**
- **Purpose:** Stores transactional sales data, identical in structure to the star schema's fact table.
- **Columns:**

| Column Name      | Data Type     | Description                                      |
|------------------|---------------|--------------------------------------------------|
| `order_number`   | VARCHAR(50)   | Unique identifier for the sales order.           |
| `product_key`    | INT           | Foreign key referencing `dim_products`.          |
| `customer_key`   | INT           | Foreign key referencing `dim_customer`.          |
| `order_date`     | DATE          | Date the order was placed.                       |
| `shipping_date`  | DATE          | Date the order was shipped.                      |
| `due_date`       | DATE          | Date the payment was due.                        |
| `sales_amount`   | INT           | Total sales amount for the transaction.          |
| `quantity`       | INT           | Number of units sold.                            |
| `price`          | INT           | Price per unit.                                  |
