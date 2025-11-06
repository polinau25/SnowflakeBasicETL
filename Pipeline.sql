use role accountadmin;
use warehouse compute_wh;

create or replace database results_database;
create or replace schema results_schema;

use results_database.results_schema;

// create json file format
create or replace file format json_format
    type = json;
    
// create stage for raw data
create or replace stage initial_stage;

// create table for raw data    
create table raw_json_data (
    json_content variant
);

// copy raw data from stage
copy into raw_json_data
from @initial_stage/
FILE_FORMAT = (FORMAT_NAME = json_format);

// create table for parsed data
create table results_table (
    test_date DATE,
    test_name VARCHAR,
    test_value FLOAT  
);

// insert data from raw table to final table
INSERT INTO results_table (test_date, test_name, test_value)
SELECT
    json_content:date::DATE,
    test.value:type::VARCHAR,
    test.value:value::FLOAT
FROM raw_json_data,
LATERAL FLATTEN(INPUT => json_content:tests) AS test;

// Create separate tables for fasting_glucose test
create table fasting_glucose_table (
    test_date DATE,
    test_value FLOAT  
);

INSERT INTO fasting_glucose_table (test_date, test_value)
SELECT
    json_content:date::DATE,
    test.value:value::FLOAT
FROM 
    raw_json_data,
    LATERAL FLATTEN(INPUT => json_content:tests) AS test
WHERE test.value:type = 'fasting_glucose';

// Some basic queries

// what was maximum value for thyroid stimulating hormone blood test
SELECT MAX(test_value)
FROM results_table
WHERE test_name = 'tsh';

// what is average fasting glucose level
SELECT AVG(test_value)
FROM fasting_glucose_table;
