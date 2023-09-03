-- 5 Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

CREATE OR REPLACE VIEW v_cze_gdp AS
SELECT 
	tc2.year,
	tc2.gdp,
	LAG(tc2.gdp,1) OVER
		(PARTITION BY country ORDER BY year) AS last_gdp,
	(ROUND(gdp/LAG(gdp, 1) OVER
         (PARTITION BY country ORDER BY year),4) -1)*100 AS percentual_change_gdp
FROM  t_veronika_cizkova_project_SQL_secondary_final tc2
WHERE country LIKE 'czech_republic'
;


CREATE OR REPLACE VIEW v_gdp_food_payroll AS
SELECT 
	v_cze_gdp.*,
	v_food.average_change_food,
	v_payroll.average_change_payroll,
	LEAD(v_food.average_change_food, 1) OVER (ORDER BY year) AS next_average_change_food,
	LEAD(v_payroll.average_change_payroll, 1) OVER (ORDER BY year) AS next_average_change_payroll
FROM v_cze_gdp
LEFT JOIN v_food
	ON v_food.year = v_cze_gdp.year
LEFT JOIN v_payroll
	ON v_payroll.year = v_cze_gdp.year
;


SELECT *,
	CASE 
		WHEN (average_change_food > 3 OR next_average_change_food > 3) AND (average_change_payroll > 3 OR next_average_change_payroll > 3) THEN 'payroll and food'
		WHEN (average_change_food < 3 AND next_average_change_food < 3) AND (average_change_payroll < 3 AND next_average_change_payroll < 3) THEN 'not food not payroll'
		WHEN (average_change_payroll < 3 AND next_average_change_payroll < 3) AND (average_change_food > 3 OR next_average_change_food > 3) THEN 'food not payroll'
		WHEN (average_change_food < 3 AND next_average_change_food < 3) AND (average_change_payroll > 3 OR next_average_change_payroll > 3) THEN 'payroll not food'
		ELSE 0
	END AS influence_gdp
FROM v_gdp_food_payroll
-- WHERE percentual_change_gdp > 5
;


SELECT a.influence_gdp,
	COUNT(a.influence_gdp) AS count_of_influence
FROM (SELECT *,
	CASE 
		WHEN (average_change_food > 3 OR next_average_change_food > 3) AND (average_change_payroll > 3 OR next_average_change_payroll > 3) THEN 'payroll and food'
		WHEN (average_change_food < 3 AND next_average_change_food < 3) AND (average_change_payroll < 3 AND next_average_change_payroll < 3) THEN 'not food not payroll'
		WHEN (average_change_payroll < 3 AND next_average_change_payroll < 3) AND (average_change_food > 3 OR next_average_change_food > 3) THEN 'food not payroll'
		WHEN (average_change_food < 3 AND next_average_change_food < 3) AND (average_change_payroll > 3 OR next_average_change_payroll > 3) THEN 'payroll not food'
		ELSE 0
	END AS influence_gdp
FROM v_gdp_food_payroll
WHERE percentual_change_gdp > 5
) a
GROUP BY a.influence_gdp
;









