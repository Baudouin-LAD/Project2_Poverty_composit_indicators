CREATE DATABASE IF NOT EXISTS Project2;
USE Project2;

CREATE TABLE poverty_rate_cleaned (
SELECT location, time, value FROM poverty_rate WHERE Subject="TOT");

CREATE TABLE income_inequality_cleaned (
SELECT location, time, value FROM income_inequality WHERE Subject="GINI");

DROP TABLE income_inequality;
DROP TABLE poverty_rate;

CREATE TEMPORARY TABLE IF NOT EXISTS all_data
SELECT
c.country_name,
e.year,
education_value as education_value,
mortality_value as mortality_rate,
i.value as gini,
p.value as poverty_rate
FROM oecd_list c
JOIN education e ON c.country_id = e.country_id
JOIN mortality m ON e.country_id = m.country_id AND e.year = m.year
JOIN income_inequality_cleaned i ON m.country_id = i.location AND m.year = i.time
JOIN poverty_rate_cleaned p ON i.location = p.location AND i.time = p.time
WHERE e.year BETWEEN 2012 AND 2019
ORDER BY c.country_name ASC
;

SELECT country_name,
all_data.year,
(education_value - MIN(education_value))/(MAX(education_value) - MIN(education_value)) AS norm_education,
(mortality_rate - MIN(mortality_rate))/(MAX(mortality_rate) - MIN(mortality_rate)) AS norm_mortality,
(gini - MIN(gini))/(MAX(gini) - MIN(gini)) AS norm_gini,
(poverty_rate - MIN(poverty_rate))/(MAX(poverty_rate) - MIN(poverty_rate)) AS norm_poverty
FROM all_data
GROUP BY country_name, all_data.year, education_value, mortality_rate, gini, poverty_rate;

DROP TABLE constants;
CREATE TABLE constants 
SELECT MIN(education_value) as min_educ,
MAX(education_value) as max_educ,
MIN(mortality_rate) as min_mortality,
MAX(mortality_rate) as max_mortality,
MIN(gini) as min_gini,
MAX(gini) as max_gini,
MIN(poverty_rate) as min_poverty,
MAX(poverty_rate) as max_poverty
FROM all_data;

DROP TABLE data_constant;
CREATE TABLE data_constant
SELECT a.country_name,
a.year,
a.education_value,
a.mortality_rate,
a.gini,
a.poverty_rate,
c.min_educ,
c.max_educ,
c.min_mortality,
c.max_mortality,
c.min_gini,
c.max_gini,
c.min_poverty,
c.max_poverty
FROM all_data a
CROSS JOIN constants c;

CREATE TABLE norm_data
SELECT country_name,
year,
(education_value - min_educ)/(max_educ - min_educ) AS norm_educ,
(mortality_rate - min_mortality)/(max_mortality - min_mortality) AS norm_mortality,
(gini - min_gini)/(max_gini - min_gini) AS norm_gini,
(poverty_rate - min_poverty)/(max_poverty - min_poverty) AS norm_poverty
FROM data_constant d;

SELECT *
from nor;
