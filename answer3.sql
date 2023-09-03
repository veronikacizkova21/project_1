-- 3 Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT
	a.category_food,
	MIN(a.percent_changes) AS min_percent_change,
	MAX(a.percent_changes) AS max_percent_change,
	ROUND((EXP(AVG(LOG(1 + (percent_changes / 100)))) - 1)*100 ,2) AS geometric_mean
FROM (
SELECT
	tc1.year,
	tc1.category_food,
	tc1.code_food,
	tc1.average_price,
	LAG(average_price, 1) OVER
            (PARTITION BY code_food ORDER BY year) AS last_price,
	(ROUND(average_price/LAG(average_price, 1) OVER
            (PARTITION BY code_food ORDER BY year), 4) -1) * 100 AS percent_changes
FROM t_veronika_cizkova_project_SQL_primary_final tc1
GROUP BY year, tc1.category_food, tc1.code_food, tc1.average_price
ORDER BY percent_changes
) a
GROUP BY category_food
-- HAVING geometric_mean > 0
ORDER BY geometric_mean
;
