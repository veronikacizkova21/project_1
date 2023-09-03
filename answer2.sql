-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


SELECT 
	tc1.code_food,
	tc1.category_food,
	tc1.year,
	ROUND(AVG(tc1.average_payroll),2) AS avg_payroll, 
	ROUND(AVG(tc1.average_price),2) AS avg_price,
	ROUND(ROUND(AVG(tc1.average_payroll),2)/ROUND(AVG(tc1.average_price),2)) AS purchasing_power,
	tc1.price_unit
FROM t_veronika_cizkova_project_SQL_primary_final tc1
WHERE tc1.code_food IN  (111301, 114201)
	AND year IN (2006, 2018)
GROUP BY tc1.code_food, tc1.category_food, tc1.year, tc1.price_unit
ORDER BY tc1.code_food
;