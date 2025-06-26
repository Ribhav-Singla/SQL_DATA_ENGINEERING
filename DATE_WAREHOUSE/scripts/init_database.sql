/*
=============================================================
Create Database
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three databases .
    database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

-- inside the bronze layer
DROP DATABASE IF EXISTS bronze;
CREATE database bronze;

-- Inside the silver layer
DROP DATABASE IF EXISTS silver;
CREATE database silver;

-- Inside the gold layer
DROP DATABASE IF EXISTS star;
CREATE database star;

DROP DATABASE IF EXISTS snowflake;
CREATE DATABASE snowflake;
