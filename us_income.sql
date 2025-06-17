USE us_income;

ALTER TABLE ushouseholdincome RENAME TO us_household_income;

-- CLEANING
SELECT * 
FROM us_household_income;

-- Remove duplicates
SELECT id,
COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1
;

SELECT *
FROM (
	SELECT id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
	FROM us_household_income
) AS row_table
WHERE row_num > 1
;

DELETE FROM us_household_income
WHERE id IN (
	SELECT id
	FROM (
		SELECT id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		FROM us_household_income
	) AS row_table
	WHERE row_num > 1
    )
;

-- stat table
SELECT * 
FROM us_household_income_statistics;

-- Remove duplicates, stat
SELECT id,
COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1
;
# No duplicate in statistic table

-- Fixing spellings in State_Name
SELECT DISTINCT State_Name
FROM us_household_income
;
# alabama seems to be self fixed to Alabama by SQL?

SELECT *
FROM us_household_income
WHERE State_Name = 'Georgia'
;

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'Georia'
;

UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;


SELECT *
FROM us_household_income
WHERE Place = ''
;
-- blank in place for 1 obs

SELECT *
FROM us_household_income
WHERE County = 'Autauga County'
AND Place = ''
;

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND Place = ''
;

SELECT Type,
COUNT(Type)
FROM us_household_income
GROUP BY Type
;
-- CDP (988 obs) same thing as CPH (2 obs) ??????
-- Boroughs (1obs) seems to be spelled wrong, Borough ( 128 obs)


SELECT *
FROM us_household_income
WHERE Type = 'Boroughs'
;

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

SELECT *
FROM us_household_income
WHERE (ALand = 0 OR ALand IS NULL OR ALand ='')
AND (AWater = 0 OR AWater IS NULL OR AWater ='')
;

SELECT *
FROM us_household_income
WHERE (ALand = 0 OR ALand IS NULL OR ALand ='')
AND (AWater = 0 OR AWater IS NULL OR AWater ='')
;

SELECT *
FROM us_household_income
WHERE (ALand = 0 OR ALand IS NULL OR ALand ='')
AND (AWater = 0 OR AWater IS NULL OR AWater ='')
;

SELECT *
FROM us_household_income
WHERE (ALand = 0 OR ALand IS NULL OR ALand ='')
;

SELECT *
FROM us_household_income
WHERE (AWater = 0 OR AWater IS NULL OR AWater ='')
;

-- Stat table

-- Fixing spellings in State_Name

SELECT *
FROM us_household_income_statistics
;

SELECT DISTINCT State_Name
FROM us_household_income_statistics
;


SELECT *
FROM us_household_income_statistics
WHERE Stdev = ''
;
-- no blank whole table

SELECT *
FROM us_household_income_statistics
WHERE Mean = 0 
AND Median = 0
AND Stdev = 0
AND sum_w = 0
;

-- Mean, Median, Stdev, sum_w are together 0 for many obs
-- Only all of these 3 are 0 or none of them
-- DELETE THESE ROWS? yip

DELETE FROM us_household_income_statistics
WHERE Mean = 0 
AND Median = 0
AND Stdev = 0
AND sum_w = 0
;

-- EDA
-- Sum of Aland, Awater for each state

SELECT *
FROM us_household_income;

SELECT State_Name,
SUM(Aland),
SUM(AWater)
FROM us_household_income
GROUP BY State_Name;

SELECT COUNT(id)
FROM us_household_income
;
-- 32519

SELECT COUNT(id)
FROM us_household_income_statistics
;
-- 32211

SELECT *
FROM us_household_income i
JOIN us_household_income_statistics s
	ON i.id = s.id
;

-- Compare mean, median income between places (State, County)
SELECT i.State_Name,
ROUND(AVG(s.Mean),0),
ROUND(AVG(s.Median),0)
FROM us_household_income i
JOIN us_household_income_statistics s
	ON i.id = s.id
GROUP BY State_Name
ORDER BY 2,3
LIMIT 5
;

SELECT i.State_Name,
ROUND(AVG(s.Mean),0),
ROUND(AVG(s.Median),0)
FROM us_household_income i
JOIN us_household_income_statistics s
	ON i.id = s.id
GROUP BY State_Name
ORDER BY 2 DESC ,3 DESC
LIMIT 5
;

-- Label each id as high or low income
SELECT i.id,
i.State_Name,
i.County,
i.City,
i.Place,
s.Median,
CASE
	WHEN s.Median > 88000 THEN 'High'
    WHEN s.Median < 70000 THEN 'Low'
    ELSE 'Middle'
END AS high_low_cat
FROM us_household_income i
JOIN us_household_income_statistics s
	ON i.id = s.id
;

-- Each County low high middle count
SELECT County,
high_low_cat,
COUNT(high_low_cat)
FROM (
	SELECT i.id,
	i.State_Name,
	i.County,
	i.City,
	i.Place,
	s.Median,
	CASE
		WHEN s.Median > 88000 THEN 'High'
		WHEN s.Median < 70000 THEN 'Low'
		ELSE 'Middle'
	END AS high_low_cat
	FROM us_household_income i
	JOIN us_household_income_statistics s
		ON i.id = s.id
) AS count_table
GROUP BY County, high_low_cat
ORDER BY County
;

-- Compare mean and median income between Type
SELECT Type,
COUNT(Type),
ROUND(AVG(s.Mean),0),
ROUND(AVG(s.Median),0)
FROM us_household_income i
JOIN us_household_income_statistics s
	ON i.id = s.id
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 4
;

SELECT i.State_Name,
i.City,
ROUND(AVG(s.Mean))
FROM us_household_income i
JOIN us_household_income_statistics s
	ON i.id = s.id
GROUP BY i.State_Name,i.City
ORDER BY 3 DESC
;


SELECT i.State_Name,
i.City,
ROUND(AVG(s.Median))
FROM us_household_income i
JOIN us_household_income_statistics s
	ON i.id = s.id
GROUP BY i.State_Name,i.City
ORDER BY 3 DESC
;
-- A lot of city has same avg median 300000?? Why
