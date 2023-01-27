USE project2;
SELECT * FROM norm_data;

CREATE TEMPORARY TABLE data_constants
WITH constants AS (
SELECT
MIN(education_value) as min_edu,
MAX(education_value) as max_edu,
MIN(mortality_rate) as min_mortality,
MAX(mortality_rate) as max_mortality,
MIN(gini) as min_gini,
MAX(gini) as max_gini,
MIN(poverty_rate) as min_poverty,
MAX(poverty_rate) as max_poverty
FROM raw_data
WHERE year BETWEEN 2013 AND 2019
)
SELECT
country_name,
year,
education_value,
mortality_rate,
gini,
poverty_rate,
min_edu,
max_edu,
min_mortality,
max_mortality,
min_gini,
max_gini,
min_poverty,
max_poverty
FROM raw_data CROSS JOIN constants
;

CREATE TABLE IF NOT EXISTS norm_data
SELECT
country_name,
year,
(education_value - min_edu) / (max_edu - min_edu) as norm_edu,
(mortality_rate - min_mortality) / (max_mortality - min_mortality) as norm_mortality,
(gini - min_gini) / (max_gini - min_gini) as norm_gini,
(poverty_rate - min_poverty) / (max_poverty - min_poverty) as norm_poverty
FROM data_constants
;

-- Education (2/9) Mortality (2/9) GINI (2/9) Poverty (1/3)
CREATE TABLE poverty_indicator
SELECT 
country_name,
year,
2/9 * norm_edu + 2/9 * norm_mortality + 2/9 * norm_gini + 1/3 * norm_poverty AS composite_poverty_indicator
FROM norm_data
;

-- AVG Indicator on the period per country + ranking
SELECT 
country_name,
AVG(composite_poverty_indicator) as average
FROM poverty_indicator
GROUP BY
country_name
ORDER BY average ASC
;

-- Variation on the period
WITH tab2013 AS 
(
SELECT
country_name,
year,
composite_poverty_indicator as composite_2013
FROM poverty_indicator 
WHERE year = '2013'
),
tab2019 AS 
(
SELECT
country_name,
year,
composite_poverty_indicator as composite_2019
FROM poverty_indicator 
WHERE year = '2019'
)
SELECT 
a.country_name,
composite_2013,
composite_2019,
(composite_2019 - composite_2013) as variation
FROM tab2013 a JOIN tab2019 b ON a.country_name = b.country_name
ORDER BY variation ASC
;


