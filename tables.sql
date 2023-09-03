CREATE OR REPLACE TABLE t_veronika_cizkova_project_SQL_primary_final AS
SELECT
	a.code_food,
    a.category_food,
    a.average_price,
    a.price_value,
    a.price_unit,
    b.average_payroll,
    b.payroll_year AS 'year',
	b.industry_branch_code,
	b.name AS industry_branch_name
FROM
(SELECT
    cp.category_code AS code_food,
    cpc.name AS category_food,
    ROUND(AVG(value),2) AS average_price,
    cpc.price_value,
    cpc.price_unit,
    YEAR(cp.date_to) AS year_food
FROM czechia_price cp
LEFT JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code 
WHERE region_code IS NULL
GROUP BY cp.category_code, YEAR(cp.date_to),cpc.price_unit, cpc.price_value
) a
JOIN (SELECT 
	ROUND(AVG(cp2.value),2) AS average_payroll,
	cp2.payroll_year,
	cp2.industry_branch_code,
	cpib.name
FROM czechia_payroll cp2
LEFT JOIN czechia_payroll_industry_branch cpib 
	ON cp2.industry_branch_code = cpib.code 
	WHERE cp2.value_type_code = 5958
	AND cp2.calculation_code = 100
	AND cp2.industry_branch_code IS NOT NULL
GROUP BY cp2.payroll_year, cp2.industry_branch_code, cpib.name) b
	ON a.year_food = b.payroll_year
ORDER BY year
	-- sledované období je: 2006 - 2018
;


CREATE OR REPLACE TABLE t_veronika_cizkova_project_SQL_secondary_final AS
SELECT 
	c.country,
	e.population,
	e.gini,
	e.gdp,
	e.year
FROM economies e
JOIN countries c
	ON e.country = c.country
WHERE c.continent LIKE 'Europe'
	AND (e.year BETWEEN 2006 AND 2018)
ORDER BY e.year, c.country
;