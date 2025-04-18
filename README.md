# 📊 End-to-End SQL Data Analytics Project

![Project Overview](Project.png)

This repository contains an end-to-end SQL project that showcases the design and implementation of a complete data pipeline using a multi-layered **Data Warehouse Architecture** (Bronze → Silver → Gold), followed by **Exploratory Data Analysis (EDA)** and **Advanced Data Analytics** to drive business insights.

---

## 🗂️ Project Overview

> A modern SQL-based solution to ingest, clean, transform, and analyze data for business intelligence, reporting, and machine learning use cases.

---

## 🏗️ Architecture: Bronze → Silver → Gold

This project follows a standard Data Lakehouse approach using the following layers:

### 🔸 Bronze Layer – *Raw Data Ingestion*
- 📥 Sources: CRM, ERP Systems, CSV Files
- 🧱 Object Type: Tables
- ⚙️ Loading Methods:
  - Batch Processing
  - Full Load
  - Truncate & Insert
- ❌ No data model applied
- 🗃️ **Purpose**: Stores raw data as-is from source systems. Data is ingested from CSV Files into SQL Server Database.

### 🔹 Silver Layer – *Cleaned & Standardized Data*
- 🧼 Data Cleaning & Standardization
- 🧱 Object Type: Tables
- 🧬 Data Model: Wide Tables (Wide-1)
- 🔁 Used for intermediate transformations and staging
- 🗃️ **Purpose**: Includes data cleansing, standardization, and normalization processes to prepare data for analysis.

### 🟡 Gold Layer – *Business-Ready Data*
- 🔄 Data Integration & Aggregation
- 📊 Business Logic Implementation
- 🧱 Object Type: Views
- ⭐ Data Model: Star Schema (Fact & Dimension Tables)
- ✅ Used for reporting and advanced analytics
- 🗃️ **Purpose**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

## 🔍 Exploratory Data Analysis (EDA)

- 🛠️ Performed using SQL queries
- 🧾 Tasks:
  - Basic Queries
  - Data Profiling
  - Simple Aggregations
  - Subqueries

---

## 📈 Advanced Data Analytics

> Focused on solving business use cases and generating actionable insights

- 🧠 Complex SQL Queries
- 🔁 Window Functions
- 🧵 CTEs (Common Table Expressions)
- 🔍 Nested Subqueries
- 📄 Report Generation

---

## 🚀 Consumption Layer

The final outputs are used in:
- 📊 **BI & Reporting Dashboards**
- 🧪 **Ad-Hoc SQL Analysis**
- 🤖 **Machine Learning Pipelines**

---

## 🛠️ Tech Stack

- **Database**: MySQL
- **Tools**: SQL, Excel, BI Tools (like Power BI or Tableau)
- **Architecture**: Layered Data Warehouse (Bronze/Silver/Gold)

---

## 🧠 What are CRM & ERP Systems?

| CRM | ERP |
|-----|-----|
| Customer Relationship Management system | Enterprise Resource Planning system |
| Manages external-facing activities like sales and customer support | Manages internal processes like inventory, HR, finance |
| Examples: Salesforce, Zoho CRM | Examples: SAP, Oracle ERP, Odoo |

---

## 📁 Folder Structure

```plaintext
├── Project.png                  # Project overview diagram
│
├── DATE_WAREHOUSE/              # Data warehouse implementation
│   ├── datasets/                # Source datasets
│   ├── docs/                    # Documentation
│   ├── scripts/                 # SQL scripts for each pipeline layer
│   │   ├── bronze/              # 1. Bronze Layer: Raw ingestion scripts
│   │   ├── silver/              # 2. Silver Layer: Cleaning & standardization scripts
│   │   ├── gold/                # 3. Gold Layer: Star schema views
│   │   └── init_database.sql    # Database initialization script
│   └── tests/                   # Test scripts
│
├── EXPLORATORY_DATA_ANALYSIS/   # EDA implementation
│   └── scripts/                 # SQL scripts for exploratory data analysis
│
├── ADVANCED_DATA_ANALYTICS/     # Advanced analytics implementation
│   └── scripts/                 # SQL scripts for business case-driven analytics
│
└── README.md                    # Project documentation
