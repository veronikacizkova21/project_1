4 Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

CREATE OR REPLACE VIEW v_food AS
SELECT year, 
	ROUND(AVG(food_percent_changes),2) AS average_change_food
FROM (
SELECT
	year,
	tc1.category_food,
	tc1. average_price,
	LAG(average_price, 1) OVER
            (PARTITION BY category_food ORDER BY year) AS last_price,
	(ROUND(average_price/LAG(average_price, 1) OVER
            (PARTITION BY category_food ORDER BY year), 4) -1) * 100 AS food_percent_changes
FROM t_veronika_cizkova_project_SQL_primary_final tc1
GROUP BY year, tc1.category_food, tc1.code_food, average_price
) a
GROUP BY a.year
ORDER BY a.year;


CREATE OR REPLACE VIEW v_payroll AS
SELECT
	a.year,
	ROUND(AVG(a.percent_changes),2) AS average_change_payroll
FROM (
SELECT
	tc1.year,
	tc1.industry_branch_name,
	ROUND(AVG(tc1.average_payroll),2) AS average_payroll,	
	LAG(tc1.average_payroll, 1) OVER
            (PARTITION BY tc1.industry_branch_name ORDER BY tc1.year) AS last_payroll,
	(ROUND(tc1.average_payroll/LAG(tc1.average_payroll, 1) OVER
            (PARTITION BY tc1.industry_branch_name ORDER BY tc1.year), 4) -1) * 100 AS percent_changes
FROM t_veronika_cizkova_project_SQL_primary_final tc1
GROUP BY year, tc1.industry_branch_name
) a
GROUP BY a.year
ORDER BY a.year;


SELECT 
	v_food.year,
	v_food.average_change_food,
	v_payroll.average_change_payroll,
	average_change_food - average_change_payroll AS difference
FROM v_food 
LEFT JOIN v_payroll
	ON v_food.year = v_payroll.year
-- WHERE average_change_food - average_change_payroll > 10
ORDER BY difference DESC
;









