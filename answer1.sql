-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE OR REPLACE VIEW v_payroll_change AS
SELECT
	tc1.year,
	tc1.industry_branch_name,
	ROUND(tc1.average_payroll,0) AS average_payroll,	
	LAG(tc1.average_payroll, 1) OVER
            (PARTITION BY tc1.industry_branch_name ORDER BY tc1.year) AS last_payroll,
	(ROUND(tc1.average_payroll/LAG(tc1.average_payroll, 1) OVER
            (PARTITION BY tc1.industry_branch_name ORDER BY tc1.year), 4) -1) * 100 AS percent_changes
FROM t_veronika_cizkova_project_SQL_primary_final tc1
GROUP BY year, tc1.industry_branch_name, tc1.average_payroll
ORDER BY percent_changes;


SELECT
	*
FROM v_payroll_change vpc
WHERE vpc.percent_changes IS NOT NULL
	AND vpc.percent_changes < 0
ORDER BY  vpc.percent_changes, vpc.year, vpc.industry_branch_name
;


SELECT
	*
FROM v_payroll_change vpc
WHERE vpc.percent_changes IS NOT NULL
	AND vpc.percent_changes < 0
ORDER BY vpc.year
;


SELECT 
	vpc.year,
	vpc.industry_branch_name,
	vpc.average_payroll,
	LAG(average_payroll, 12) OVER
            (PARTITION BY industry_branch_name ORDER BY year) AS total_difference_payroll,
	ROUND(average_payroll/LAG(average_payroll, 12) OVER
            (PARTITION BY industry_branch_name ORDER BY year),4)*100-100 AS total_percent_change
FROM v_payroll_change vpc
GROUP BY vpc.year, vpc.industry_branch_name, vpc.average_payroll
ORDER BY total_percent_change DESC
;
