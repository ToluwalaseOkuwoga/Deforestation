CREATE VIEW forestation
AS
SELECT f.country_code code
	,f.country_name country
	,f.year "year"
	,f.forest_area_sqkm forest_area_sqkm
	,l.total_area_sq_mi total_area_sq_mi
	,r.region region
	,r.income_group income_group
	,100.0 * (f.forest_area_sqkm / (l.total_area_sq_mi * 2.59)) AS percentage
FROM forest_area f
	,land_area l
	,regions r
WHERE (
		f.country_code = l.country_code
		AND f.year = l.year
		AND r.country_code = l.country_code
		);



SELECT SUM(forest_area_sqkm) FROM forestation
WHERE year = 1990
AND region = 'World';

SELECT SUM(forest_area_sqkm) FROM forestation
WHERE year = 2016
AND region = 'World';



SELECT (f1.forest_area_sqkm - f2.forest_area_sqkm) AS forest_area_diff
FROM forestation f1
	,forestation f2
WHERE f1.year = 1990
	AND f1.region = 'World'
	AND f2.year = 2016
	AND f2.region = 'World';

  SELECT (f1.forest_area_sqkm - f2.forest_area_sqkm) * 100 / f1.forest_area_sqkm AS pct_change
  FROM forestation f1
  	,forestation f2
  WHERE f1.year = 1990
  	AND f1.region = 'World'
  	AND f2.year = 2016
  	AND f2.region = 'World';



WITH t1
AS (
	SELECT MAX(forest_area_sqkm) - MIN(forest_area_sqkm) AS deforestation_1
	FROM forestation
	)
	,t2
AS (
	SELECT *
		,total_area_sq_mi * 2.59 AS total_area_sq_km
	FROM land_area l
	FULL JOIN t1 ON l.total_area_sq_mi = t1.deforestation_1
	)
	,t3
AS (
	SELECT *
		,CASE
			WHEN deforestation_1 IS NULL
				THEN 1324449
			ELSE NULL
			END AS deforestation_2
	FROM t2
	)
SELECT country_name
	,total_area_sq_km
FROM t3
WHERE total_area_sq_km < deforestation_2
	AND YEAR = 2016
ORDER BY total_area_sq_km DESC;



SELECT percentage
FROM forestation
WHERE year = 2016
	AND country = 'World';



SELECT region
	,ROUND(CAST(percent_forest AS NUMERIC), 2)
FROM (
	SELECT region
		,SUM(forest_area_sqkm) * 100 / SUM(total_area_sq_mi) AS percent_forest
	FROM forestation
	WHERE year = 2016
	GROUP BY 1
	) sub
ORDER BY 2 DESC LIMIT 1;

SELECT region
	,ROUND(CAST(percent_forest AS NUMERIC), 2)
FROM (
	SELECT region
		,SUM(forest_area_sqkm) * 100 / SUM(total_area_sq_mi) AS percent_forest
	FROM forestation
	WHERE year = 2016
		AND region NOT LIKE 'World'
	GROUP BY 1
	) sub
ORDER BY 2 LIMIT 1;


SELECT region
	,ROUND(CAST((region_forest_1990 / region_area_1990) * 100 AS NUMERIC), 2) AS forest_percent_1990
	,ROUND(CAST((region_forest_2016 / region_area_2016) * 100 AS NUMERIC), 2) AS forest_percent_2016
FROM (
	SELECT SUM(f1.forest_area_sqkm) region_forest_1990
		,SUM(f1.total_area_sq_mi) region_area_1990
		,f1.region
		,SUM(f2.forest_area_sqkm) region_forest_2016
		,SUM(f2.total_area_sq_mi) region_area_2016
	FROM forestation f1
		,forestation f2
	WHERE f1.year = '1990'
		AND f1.country != 'World'
		AND f2.year = '2016'
		AND f2.country != 'World'
		AND f1.region = f2.region
	GROUP BY f1.region
	) region_percent
ORDER BY forest_percent_1990 DESC;


WITH t1
AS (
	SELECT region
		,SUM(forest_area_sqkm) AS forest_sum_1990
	FROM forestation
	WHERE year = 1990
		AND region NOT LIKE 'World'
	GROUP BY 1
	)
	,t2
AS (
	SELECT region
		,SUM(forest_area_sqkm) AS forest_sum_2016
	FROM forestation
	WHERE year = 2016
		AND region NOT LIKE 'World'
	GROUP BY 1
	)
SELECT t1.region
	,t1.forest_sum_1990
	,t2.forest_sum_2016
FROM t1
JOIN t2 ON t1.region = t2.region
WHERE t2.forest_sum_2016 < t1.forest_sum_1990;


SELECT f1.country_name
	,f1.forest_area_sqkm - f2.forest_area_sqkm AS difference
FROM forest_area AS f1
JOIN forest_area AS f2 ON (
		f1.year = '2016'
		AND f2.year = '1990'
		)
	AND f1.country_name = f2.country_name
ORDER BY difference DESC;


SELECT f1.country_name
	,100.0 * (f1.forest_area_sqkm - f2.forest_area_sqkm) / f2.forest_area_sqkm AS percentage
FROM forest_area AS f1
JOIN forest_area AS f2 ON (
		f1.year = '2016'
		AND f2.year = '1990'
		)
	AND f1.country_name = f2.country_name
ORDER BY percentage DESC;


SELECT f1.country_name
	,f1.forest_area_sqkm - f2.forest_area_sqkm AS difference
FROM forest_area AS f1
JOIN forest_area AS f2 ON (
		f1.year = '2016'
		AND f2.year = '1990'
		)
	AND f1.country_name = f2.country_name
ORDER BY difference;


SELECT f1.country_name
	,100.0 * (f1.forest_area_sqkm - f2.forest_area_sqkm) / f2.forest_area_sqkm AS percentage
FROM forest_area AS f1
JOIN forest_area AS f2 ON (
		f1.year = '2016'
		AND f2.year = '1990'
		)
	AND f1.country_name = f2.country_name
ORDER BY percentage;



SELECT DISTINCT (quartiles)
	,COUNT(country) OVER (PARTITION BY quartiles)
FROM (
	SELECT country
		,CASE
			WHEN percentage <= 25
				THEN '0-25%'
			WHEN percentage <= 75
				AND percentage > 50
				THEN '50-75%'
			WHEN percentage <= 50
				AND percentage > 25
				THEN '25-50%'
			ELSE '75-100%'
			END AS quartiles
	FROM forestation
	WHERE percentage IS NOT NULL
		AND year = 2016
	) quart
ORDER BY quartiles DESC;


SELECT country
	,percentage
FROM forestation
WHERE percentage > 75
	AND year = 2016
ORDER BY percentage DESC;


SELECT COUNT(country)
FROM forestation
WHERE year = 2016
	AND percentage > (
		SELECT percentage
		FROM forestation
		WHERE country = 'United States'
			AND year = 2016
		);
