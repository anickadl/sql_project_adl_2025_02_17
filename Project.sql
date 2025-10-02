
DROP TABLE IF EXISTS t_anna_dilenardo_project_SQL_primary_final;

CREATE TABLE t_anna_dilenardo_project_sql_primary_final AS
WITH wages AS ( 
  SELECT   
    cp.payroll_year,
    cp.payroll_quarter,
    cp.value 	AS avg_monthly_wage,
    cpc.name 	AS calculation_type,
    cpib.name 	AS industry_branch_name,
    cpu.name 	AS payrolunit_type
  FROM czechia_payroll cp
  LEFT JOIN czechia_payroll_calculation     cpc  ON cpc.code = cp.calculation_code 
  LEFT JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
  LEFT JOIN czechia_payroll_unit            cpu  ON cpu.code = cp.unit_code 
  LEFT JOIN czechia_payroll_value_type      cpvt ON cpvt.code = cp.value_type_code 
  WHERE cpvt.code = 5958   -- nepracuju s prumernym poctem zamestnanych osob
    AND cpc.code  = 200    -- pracuji s přepočtenou mzdou, abych ji mela pro vsechny ve stejne vysi a TO na plny uvazek
    AND cpu.code  = 200    -- pracuji pouze se mzdou a nikoliv s počtem osob
),
wages_yearly AS (           
  SELECT
    industry_branch_name,
    payroll_year                         AS payroll_year,
    AVG(avg_monthly_wage)                AS avg_monthly_wage  -- průměr přes 4 kvartály
  FROM wages
  WHERE industry_branch_name IS NOT NULL
  GROUP BY industry_branch_name, payroll_year
),
prices_yearly AS (       
  SELECT 
    cpc.name                              AS product,
    DATE_PART('year', date_from)		  AS price_year,
    AVG(cpr.value)                        AS avg_price,
    cpc.price_unit                        AS price_unit,
    'Czech Republic'                      AS state
  FROM czechia_price cpr
  LEFT JOIN czechia_price_category cpc ON cpr.category_code = cpc.code
  GROUP BY cpc.name, DATE_PART('year', date_from), cpc.price_unit
)
SELECT 
  p.state,
  w.payroll_year AS YEAR ,
  w.industry_branch_name,
  w.avg_monthly_wage,
  p.product,
  p.avg_price,
  p.price_unit
FROM wages_yearly w
JOIN prices_yearly p ON w.payroll_year = p.price_year
ORDER BY w.industry_branch_name, w.payroll_year, p.product;



DROP TABLE IF EXISTS t_anna_dilenardo_project_SQL_secondary_final;

CREATE TABLE t_anna_dilenardo_project_SQL_secondary_final AS 
	SELECT 
		e.country, 
		e."year", 
		e.GDP, 
		e.population, -- populace per rok, v countries tabulce jen asi nejaka obecna
		e.gini
	FROM economies e 
	JOIN countries c ON e.country = c.country
	JOIN t_anna_dilenardo_project_SQL_primary_final t1 ON t1.YEAR = e.YEAR -- ziskam stejne obdobi jako primarni prehled
	WHERE c.continent = 'Europe';


SELECT * FROM t_anna_dilenardo_project_SQL_primary_final;

SELECT * FROM t_anna_dilenardo_project_SQL_secondary_final;




SELECT *
FROM t_anna_dilenardo_project_SQL_primary_final 

SELECT *
FROM czechia_price cpr

SELECT *
FROM czechia_price_category cpc;

SELECT DISTINCT industry_branch_code
FROM czechia_payroll cp

SELECT *
FROM czechia_payroll cp 
WHERE industry_branch_code IS NULL AND cp.value_type_code =5958 AND unit_code =200 AND calculation_code = 200


SELECT *
FROM czechia_payroll_value_type cpvt;

SELECT *
FROM czechia_payroll_industry_branch cpib 

SELECT *
FROM czechia_payroll_calculation cpc 


SELECT *
FROM czechia_payroll_unit cpu 

SELECT *
FROM economies

SELECT *
FROM countries