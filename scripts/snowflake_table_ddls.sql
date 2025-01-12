Create DATABASE car_rental;

use car_rental;

CREATE OR REPLACE TABLE location_dim (
location_key INTEGER AUTOINCREMENT PRIMARY KEY,
location_id STRING UNIQUE NOT NULL,
location_name STRING
);

INSERT INTO location_dim(location_id, location_name) VALUES
('LOC001', 'New York - JFK Airport'),
('LOC002', 'Los Angeles - LAX Airport'),
('LOC003', 'Chicago - O\'Hare Airport'),
('LOC004', 'Houston - Bush Intercontinental Airport'),
('LOC005', 'San Francisco - SFO Airport'),
('LOC006', 'Miami - MIA Airport'),
('LOC007', 'Seattle - SeaTac Airport'),
('LOC008', 'Atlanta - Hartsfield-Jackson Airport'),
('LOC009', 'Dallas - DFW Airport'),
('LOC010', 'Denver - DEN Airport');

SELECT * FROM LOCATION_DIM;

CREATE OR REPLACE TABLE car_dim (
car_key INTEGER AUTOINCREMENT PRIMARY KEY,
car_id STRING UNIQUE NOT NULL,
make STRING,
model STRING,
year INTEGER
);

INSERT INTO car_dim (car_id, make, model, year) VALUES
('CAR001', 'Toyota', 'Camry', 2020),
('CAR002', 'Honda', 'Civic', 2019),
('CAR003', 'Ford', 'Mustang', 2021),
('CAR004', 'Chevrolet', 'Impala', 2018),
('CAR005', 'Tesla', 'Model S', 2022),
('CAR006', 'BMW', '3 Series', 2021),
('CAR007', 'Audi', 'A4', 2020),
('CAR008', 'Mercedes-Benz', 'C-Class', 2019),
('CAR009', 'Volkswagen', 'Passat', 2021),
('CAR010', 'Nissan', 'Altima', 2020);

SELECT * FROM car_dim;

CREATE OR REPLACE TABLE date_dim (
date_key INTEGER AUTOINCREMENT PRIMARY KEY,
date DATE UNIQUE NOT NULL,
year INTEGER,
month INTEGER,
day INTEGER,
quarter INTEGER
);

INSERT INTO date_dim (date_key, date, year, month, day, quarter) VALUES
(20240701, '2024-07-01', 2024, 7, 1, 3),
(20240702, '2024-07-02', 2024, 7, 2, 3),
(20240703, '2024-07-03', 2024, 7, 3, 3),
(20240704, '2024-07-04', 2024, 7, 4, 3),
(20240705, '2024-07-05', 2024, 7, 5, 3),
(20240706, '2024-07-06', 2024, 7, 6, 3),
(20240707, '2024-07-07', 2024, 7, 7, 3),
(20240708, '2024-07-08', 2024, 7, 8, 3),
(20240709, '2024-07-09', 2024, 7, 9, 3),
(20240710, '2024-07-10', 2024, 7, 10, 3),
(20240711, '2024-07-11', 2024, 7, 11, 3),
(20240712, '2024-07-12', 2024, 7, 12, 3),
(20240713, '2024-07-13', 2024, 7, 13, 3),
(20240714, '2024-07-14', 2024, 7, 14, 3),
(20240715, '2024-07-15', 2024, 7, 15, 3),
(20240716, '2024-07-16', 2024, 7, 16, 3),
(20240717, '2024-07-17', 2024, 7, 17, 3),
(20240718, '2024-07-18', 2024, 7, 18, 3),
(20240719, '2024-07-19', 2024, 7, 19, 3),
(20240720, '2024-07-20', 2024, 7, 20, 3),
(20240721, '2024-07-21', 2024, 7, 21, 3),
(20240722, '2024-07-22', 2024, 7, 22, 3),
(20240723, '2024-07-23', 2024, 7, 23, 3),
(20240724, '2024-07-24', 2024, 7, 24, 3),
(20240725, '2024-07-25', 2024, 7, 25, 3),
(20240726, '2024-07-26', 2024, 7, 26, 3),
(20240727, '2024-07-27', 2024, 7, 27, 3),
(20240728, '2024-07-28', 2024, 7, 28, 3),
(20240729, '2024-07-29', 2024, 7, 29, 3),
(20240730, '2024-07-30', 2024, 7, 30, 3),
(20240731, '2024-07-31', 2024, 7, 31, 3);


SELECT * FROM DATE_dim;



CREATE OR REPLACE TABLE customer_dim(
customer_key INTEGER AUTOINCREMENT PRIMARY KEY,
customer_id STRING UNIQUE NOT NULL,
name STRING,
email STRING,
phone STRING,
effective_date TIMESTAMP,
end_date TIMESTAMP,
is_current BOOLEAN
)


CREATE OR REPLACE TABLE rentals_fact (
    rental_id STRING PRIMARY KEY,
    customer_key INTEGER,
    car_key INTEGER,
    pickup_location_key INTEGER,
    dropoff_location_key INTEGER,
    start_date_key INTEGER,
    end_date_key INTEGER,
    amount FLOAT,
    quantity INTEGER,
    rental_duration_days INTEGER,
    total_rental_amount FLOAT,
    average_daily_rental_amount FLOAT,
    is_long_rental BOOLEAN,
    FOREIGN KEY (customer_key) REFERENCES customer_dim(customer_key),
    FOREIGN KEY (car_key) REFERENCES car_dim(car_key),
    FOREIGN KEY (pickup_location_key) REFERENCES location_dim(location_key),
    FOREIGN KEY (dropoff_location_key) REFERENCES location_dim(location_key),
    FOREIGN KEY (start_date_key) REFERENCES date_dim(date_key),
    FOREIGN KEY (end_date_key) REFERENCES date_dim(date_key)
);

CREATE FILE FORMAT csv_format TYPE=csv;

CREATE STORAGE INTEGRATION gcs_car_rental_integration
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = GCS
STORAGE_ALLOWED_LOCATIONS = ('gcs://car_rental_ingestion_project/customer_daily_data/')
ENABLED = TRUE;

DESC INTEGRATION gcs_car_rental_integration;

CREATE OR REPLACE STAGE car_rental_data_stage
URL = 'gcs://car_rental_ingestion_project/customer_daily_data/'
STORAGE_INTEGRATION = gcs_car_rental_integration
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '"');



select * from customer_dim;

select * from rentals_fact;

-- truncate table rentals_fact;

-- truncate table customer_dim;

-- truncate table location_dim;