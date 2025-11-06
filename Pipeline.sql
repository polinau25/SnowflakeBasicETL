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
file_format = (format_name = json_format);

// create table for parsed data
create table results_table (
    test_date date,
    test_name varchar,
    test_value float  
);

// insert data from raw table to final table
insert into results_table (test_date, test_name, test_value)
select
    json_content:date::date,
    test.value:type::varchar,
    test.value:value::float
from raw_json_data,
lateral flatten(input => json_content:tests) as test;

// Create separate tables for fasting_glucose test
create table fasting_glucose_table (
    test_date date,
    test_value float  
);

insert into fasting_glucose_table (test_date, test_value)
select
    json_content:date::date,
    test.value:value::float
from 
    raw_json_data,
    lateral flatten(input => json_content:tests) as test
where test.value:type = 'fasting_glucose';

// Some basic queries

// what was maximum value for thyroid stimulating hormone blood test
select max(test_value)
from results_table
where test_name = 'tsh';

// what is the average fasting glucose level
select avg(test_value)
from fasting_glucose_table;
