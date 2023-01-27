CREATE DATABASE IF NOT EXISTS Project2;
USE Project2;

CREATE TABLE IF NOT EXISTS sample_countries (
	country_id varchar(255),
	country_name varchar(255)
);

SELECT * FROM sample_countries;

CREATE TABLE IF NOT EXISTS education_factor (
	country_id varchar(255),
	year int,
    education_value float8
);

CREATE TABLE IF NOT EXISTS mortality_factor (
	country_id varchar(255),
	year int,
    mortality_value float8
);

CREATE TABLE IF NOT EXISTS income_ineq_factor (
	country_id varchar(255),
	indicator varchar(255),
    subject varchar(255),
    measure varchar(255),
    frequency varchar(255),
    year int,
    value float8,
    flag varchar(255)
);

CREATE TABLE IF NOT EXISTS income_ineq_factor_filtered 
SELECT
b.country_id,
a.year,
a.value
FROM income_ineq_factor a JOIN sample_countries b
ON a.country_id = b.country_id
WHERE a.subject = 'GINI'
;

 CREATE TABLE IF NOT EXISTS poverty_rate_factor (
	country_id varchar(255),
	indicator varchar(255),
    subject varchar(255),
    measure varchar(255),
    frequency varchar(255),
    year int,
    value float8,
    flag varchar(255)
);

CREATE TABLE IF NOT EXISTS poverty_rate_factor_filtered 
SELECT
b.country_id,
a.year,
a.value
FROM poverty_rate_factor a JOIN sample_countries b
ON a.country_id = b.country_id
WHERE a.subject = 'TOT'
;

SELECT
c.country_name,
e.year,
education_value as education_value,
mortality_value as mortality_value,
i.value as income_value,
p.value as poverty_value
FROM sample_countries c 
JOIN education_factor e ON c.country_id = e.country_id
JOIN mortality_factor m ON e.country_id = m.country_id AND e.year = m.year
JOIN income_ineq_factor i ON m.country_id = i.country_id AND m.year = i.year
JOIN poverty_rate_factor p ON i.country_id = p.country_id AND i.year = p.year
WHERE e.year BETWEEN 2012 AND 2019
ORDER BY c.country_name ASC
;

SELECT * FROM all_data;

WITH constants AS (
SELECT
MIN(education_value) AS min_edu,
MAX(education_value) AS max_edu,
MIN(mortality_rate) AS min_mortality,

FROM all_data

)

