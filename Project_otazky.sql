/*
* 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
*/


SELECT 
    industry_branch_name AS odvetvi,
  	SUM(CASE WHEN avg_monthly_wage < avg_monthly_wage_last_year THEN 1 ELSE 0 END) AS pocet_poklesu,
    STRING_AGG(CASE
	    		WHEN avg_monthly_wage < avg_monthly_wage_last_year 
	    		THEN year::TEXT 
	    		END,
	    		', ') AS roky_s_poklesem
FROM (
    SELECT 
        industry_branch_name,
        year,
        avg(avg_monthly_wage) AS avg_monthly_wage ,
        LAG(avg_monthly_wage) OVER (PARTITION BY industry_branch_name ORDER BY year) AS avg_monthly_wage_last_year
    FROM t_anna_dilenardo_project_sql_primary_final tp
   GROUP BY industry_branch_name, YEAR, avg_monthly_wage
) t
GROUP BY industry_branch_name
ORDER BY industry_branch_name;



/*
* 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
*/

SELECT *
FROM t_anna_dilenardo_project_sql_primary_final tadl1
WHERE product ILIKE '%chléb%'
	or product ILIKE '%mléko%'

WITH first_last_years AS (
    SELECT MIN(year) AS first_year,
           MAX(year) AS last_year
    FROM t_anna_dilenardo_project_sql_primary_final
    WHERE product IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
),
prices_wages AS (
    SELECT 
        year,
        product,
        AVG(avg_monthly_wage) AS wage,
        AVG(avg_price) AS price,
        price_unit
    FROM t_anna_dilenardo_project_sql_primary_final
    WHERE product IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
    GROUP BY year, product, price_unit
)
SELECT 
    p.product AS produkt,
    CASE WHEN p.year = f.first_year THEN 'První období'
         WHEN p.year = f.last_year  THEN 'Poslední období'
    END AS obdobi,
    round (p.wage::decimal,2) AS mzda,
    round(p.price::decimal,2) AS cena,
    ROUND(p.wage / p.price::decimal, 0) AS mnozstvi,
    price_unit
FROM prices_wages p
JOIN first_last_years f 
    ON p.year = f.first_year OR p.year = f.last_year
ORDER BY p.product, p.year;



/*
* 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
*/

WITH price_changes AS (
    SELECT
        product,
        year,
        avg(avg_price) AS avg_price,
        LAG(avg_price) OVER (PARTITION BY product ORDER BY year) AS prev_price
    FROM t_anna_dilenardo_project_sql_primary_final
    GROUP BY product, YEAR, avg_price 
)
, pct_changes AS (
    SELECT
        product,
        year,
        ((avg_price - prev_price) / prev_price) * 100 AS pct_growth
    FROM price_changes
    WHERE prev_price IS NOT NULL
)
SELECT 
    product AS produkt,
    ROUND(AVG(pct_growth)::decimal, 2) AS procentni_rust
FROM pct_changes
GROUP BY product
ORDER BY procentni_rust ASC
LIMIT 1;


/*
* 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
*/

WITH price_changes AS (
    SELECT
        year,
        avg(avg_price) AS avg_price
    FROM t_anna_dilenardo_project_sql_primary_final
    GROUP BY YEAR
)
, pct_changes_price AS (
    SELECT
        year,
        ((avg_price - LAG(avg_price) OVER (ORDER BY YEAR)) / LAG(avg_price) OVER (ORDER BY YEAR)) * 100 AS pct_growth_price
    FROM price_changes
)
, wage_changes AS (
    SELECT
        year,
        avg(avg_monthly_wage) AS avg_wage
    FROM t_anna_dilenardo_project_sql_primary_final
    GROUP BY YEAR
)
, pct_changes_wage AS (
    SELECT
        year,
        ((avg_wage - LAG(avg_wage) OVER (ORDER BY YEAR)) / LAG(avg_wage) OVER (ORDER BY YEAR)) * 100 AS pct_growth_wage
    FROM wage_changes
)
SELECT 
    pch.year AS rok,
    round(pch.pct_growth_price::decimal, 2) AS procentni_rust_cen,
    round(wch.pct_growth_wage::decimal, 2) AS procentni_rust_mezd,
    round((pch.pct_growth_price - wch.pct_growth_wage)::decimal, 2) AS rozdil
FROM pct_changes_price pch
JOIN pct_changes_wage wch ON pch.YEAR = wch.YEAR
WHERE (pch.pct_growth_price - wch.pct_growth_wage) > 10
--WHERE pch.pct_growth_price - wch.pct_growth_wage IS NOT NULL --pro zjisteni max rozdilu
ORDER BY pch.year ASC
--ORDER BY rozdil DESC --pro zjisteni max rozdilu
LIMIT 1;

--nebyl, nejvyšší rozdíl roční nárust byl 6,59 a to v roce 2013
--nic mi nevypíše, protože pro zadanou podmínku neexistuje


/*
* 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví 
* se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
*/

WITH price_changes AS (
    SELECT
        year,
        avg(avg_price) AS avg_price
    FROM t_anna_dilenardo_project_sql_primary_final
    GROUP BY year
),
pct_changes_price AS (
    SELECT
        year,
        ((avg_price - LAG(avg_price) OVER (ORDER BY year)) / LAG(avg_price) OVER (ORDER BY year)) * 100 AS pct_growth_price
    FROM price_changes
),
wage_changes AS (
    SELECT
        year,
        avg(avg_monthly_wage) AS avg_wage
    FROM t_anna_dilenardo_project_sql_primary_final
    GROUP BY year
),
pct_changes_wage AS (
    SELECT
        year,
        ((avg_wage - LAG(avg_wage) OVER (ORDER BY year)) / LAG(avg_wage) OVER (ORDER BY year)) * 100 AS pct_growth_wage
    FROM wage_changes
),
gdp_changes AS (
    SELECT
        year,
        avg(gdp) AS avg_gdp
    FROM t_anna_dilenardo_project_sql_secondary_final tadl2
    WHERE country = 'Czech Republic'
    GROUP BY YEAR
),
pct_gdp_changes AS (
    SELECT
        year,
        ((avg_gdp - LAG(avg_gdp) OVER (ORDER BY year)) / LAG(avg_gdp) OVER (ORDER BY year)) * 100 AS pct_growth_gdp
    FROM gdp_changes
),
avg_gdp_growth AS (
    SELECT AVG(pct_growth_gdp) AS avg_growth
    FROM pct_gdp_changes
),
result AS (
    SELECT 
        pch.year AS rok,
        round(gch.pct_growth_gdp::decimal, 2) AS procentni_rust_hdp,
        round(wch.pct_growth_wage::decimal, 2) AS procentni_rust_mezd,
        round(LEAD (wch.pct_growth_wage) OVER (ORDER BY pch.year)::decimal, 2) AS procentni_rust_mezd_nasledujici,
        round(pch.pct_growth_price::decimal, 2) AS procentni_rust_cen,
        round(LEAD(pch.pct_growth_price) OVER (ORDER BY pch.year)::decimal, 2) AS procentni_rust_cen_nasledujici 
    FROM pct_changes_price pch 
    JOIN pct_changes_wage wch ON pch.year = wch.year 
    JOIN pct_gdp_changes gch ON pch.year = gch.year 
    ORDER BY pch.year ASC
)
SELECT r.*
FROM result r
CROSS JOIN avg_gdp_growth a
--WHERE r.procentni_rust_hdp > a.avg_growth
WHERE r.procentni_rust_hdp > 5;

