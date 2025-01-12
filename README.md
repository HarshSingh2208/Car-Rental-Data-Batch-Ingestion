# Car-Rental-Data-Batch-Ingestion
Car Rental Data Batch Ingestion using Python, PySpark, GCP Dataproc, Airflow, Snowflake.

## Overview

This project implements a scalable data ingestion pipeline for car rental data using Python, PySpark, GCP Dataproc, Airflow, and Snowflake. The pipeline processes daily car rental and customer data from Google Storage, performs transformations, and updates the Snowflake data warehouse.

## Tech Stack

- **Python**: For scripting and automation.
- **PySpark**: For data processing and transformations.
- **GCP Dataproc**: For running PySpark jobs.
- **Airflow**: For orchestrating workflows and scheduling.
- **Snowflake**: For data warehousing.
- **Google Cloud Storage**: For storing raw data.

## Project Components

### Data Pipeline

1. **Ingestion**: Reads daily car rental and customer data from Google Storage.
2. **Transformation**: Uses PySpark to transform the raw data.
3. **Data Warehouse**: Updates the Snowflake data warehouse with the transformed data.

### Snowflake Schema

- **`location_dim`**: Static dimension table for locations.
- **`date_dim`**: Static dimension table for dates.
- **`car_dim`**: Static dimension table for cars.
- **`customer_dim`**: Dimension table with Slowly Changing Dimension Type 2 (SCD2) merge to maintain historical data.
- **`rentals_fact`**: Fact table for storing rental transactions.

## Setup

### Prerequisites

- Python 3.x
- PySpark
- Airflow
- GCP Dataproc and Google Cloud Storage access
- Snowflake account

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/car-rental-data-ingestion.git
   cd car-rental-data-ingestion
