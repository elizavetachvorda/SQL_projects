-- Creates the 'trees' table
CREATE TABLE trees (
    index INTEGER PRIMARY KEY,
	tree_id INTEGER, 
    tree_dbh INTEGER,
    stump_diam INTEGER,
    status VARCHAR,
    health VARCHAR,
    spc_latin VARCHAR,
    spc_common VARCHAR,
    address VARCHAR,
    zipcode INTEGER,
    borocode INTEGER,
    boroname VARCHAR,
    nta_name VARCHAR,
    state VARCHAR,
    latitude FLOAT,
    longitude FLOAT
);

-- Retrieves the first 10 rows from the 'trees' table
SELECT *
FROM trees
LIMIT 10;

-- Creates the 'income_trees' table
CREATE TABLE income_trees (
    zipcode INTEGER,
    Estimate_Total INTEGER,
    Margin_of_Error_Total INTEGER,
    Estimate_Median_income INTEGER,
    Margin_of_Error_Median_income INTEGER,
    Estimate_Mean_income INTEGER,
    Margin_of_Error_Mean_income INTEGER
);

-- Retrieves the first 10 rows from the 'income_trees' table
SELECT *
FROM income_trees
LIMIT 10;

-- Counts the total number of trees
SELECT COUNT(tree_id)
FROM trees;

-- Counts the number of duplicate tree IDs
SELECT tree_id, COUNT(*)
FROM trees
GROUP BY tree_id
HAVING COUNT(*) > 1;

-- Counts the number of duplicate zipcodes
SELECT zipcode, COUNT(*)
FROM income_trees
GROUP BY zipcode
HAVING COUNT(*) > 1;

-- Counts the number of trees in each borough and calculates their percentage of the total
SELECT boroname AS borough_name, COUNT(*) AS tree_count, 
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM trees),2) AS percentage_of_total
FROM trees
WHERE boroname IS NOT NULL
GROUP BY boroname
ORDER BY 2 DESC;

DROP TABLE IF EXISTS joined_trees;
-- Creates a temporary table 'joined_trees' by joining 'trees' and 'income_trees' tables
CREATE TEMP TABLE joined_trees AS
SELECT
    t.index,
    t.tree_id,
    t.tree_dbh,
    t.stump_diam,
    t.status,
    t.health,
    t.spc_latin,
    t.spc_common,
    t.address,
    COALESCE(t.zipcode, it.zipcode) AS zipcode,
    t.borocode,
    t.boroname,
    t.nta_name,
    t.state,
    t.latitude,
    t.longitude,
    COALESCE(it.Estimate_Total, 0) AS estimate_total,
    COALESCE(it.Margin_of_Error_Total, 0) AS margin_of_error_total,
    COALESCE(it.Estimate_Median_income, 0) AS estimate_median_income,
    COALESCE(it.Margin_of_Error_Median_income, 0) AS margin_of_error_median_income,
    COALESCE(it.Estimate_Mean_income, 0) AS estimate_mean_income,
    COALESCE(it.Margin_of_Error_Mean_income, 0) AS margin_of_error_mean_income
FROM 
    trees t
FULL OUTER JOIN 
    income_trees it ON t.zipcode = it.zipcode;

-- Calculates median and average income for each borough
SELECT
    boroname,
	ROUND(AVG(estimate_mean_income), 0) AS mean_income,
	ROUND(AVG(estimate_median_income), 0) AS median_income,
	COUNT(tree_id) AS count_trees
FROM
    joined_trees
WHERE estimate_median_income > 0 and estimate_mean_income > 0 AND boroname IS NOT NULL
GROUP BY
    boroname
ORDER BY 4 DESC;

-- Retrieves the top 5 zipcodes with the highest median income
SELECT
	DISTINCT zipcode,
	estimate_median_income,
	boroname as borough
FROM
    joined_trees
WHERE boroname IS NOT NULL
ORDER BY estimate_median_income DESC
LIMIT 5;

-- Retrieves the top 5 zipcodes with the lowest median income (excluding zero values)
SELECT
	DISTINCT zipcode,
	estimate_median_income,
	boroname as borough
FROM
    joined_trees
WHERE boroname IS NOT NULL AND estimate_median_income != 0
ORDER BY estimate_median_income
LIMIT 5;


-- Retrieves the poorest and richest zip code for each borough
WITH Borough_Ranks AS (
    SELECT
        boroname AS borough,
        zipcode,
        estimate_median_income,
        ROW_NUMBER() OVER (PARTITION BY boroname ORDER BY estimate_median_income) AS poorest_rank,
        ROW_NUMBER() OVER (PARTITION BY boroname ORDER BY estimate_median_income DESC) AS richest_rank
    FROM
        joined_trees
	WHERE boroname IS NOT NULL and zipcode != 83
)
SELECT
    boroname,
    MIN(CASE WHEN poorest_rank = 1 THEN zipcode END) AS poorest_zipcode,
    MAX(CASE WHEN richest_rank = 1 THEN zipcode END) AS richest_zipcode
FROM
    Borough_Ranks
GROUP BY
    boroname;

-- Calculates various statistics for each borough tree count, and percentage of trees in different health states
WITH Boroughs AS (
    SELECT DISTINCT boroname
    FROM joined_trees
),
Borough_Health_Tree_Counts AS (
    SELECT
        j.boroname,
        j.health,
        COUNT(*) AS tree_count
    FROM joined_trees j
    WHERE j.health IS NOT NULL AND j.health != ''
    GROUP BY j.boroname, j.health
),
Borough_Health_Total_Trees AS (
    SELECT
        bh.boroname,
        SUM(bh.tree_count) AS total_trees
    FROM Borough_Health_Tree_Counts bh
    GROUP BY bh.boroname
)
SELECT
    b.boroname AS Borough,
    bh.health AS Health_State,
    SUM(bh.tree_count) AS Total_Trees,
    ROUND(SUM(bh.tree_count * 100.0) / bt.total_trees, 2) AS Percentage
FROM
    Boroughs b
CROSS JOIN
    (SELECT DISTINCT health FROM Borough_Health_Tree_Counts WHERE health IS NOT NULL) AS h
LEFT JOIN
    Borough_Health_Tree_Counts bh ON b.boroname = bh.boroname AND h.health = bh.health
JOIN
    Borough_Health_Total_Trees bt ON b.boroname = bt.boroname
GROUP BY
    b.boroname, bh.health, bt.total_trees
ORDER BY
    b.boroname, bh.health;
	

--Computes the percentage of total trees in each borough categorized by their status
SELECT boroname AS borough, 
status, 
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY boroname), 2) AS percentage_of_total
FROM trees
GROUP BY boroname, status;

-- Calculates the average trunk diameter of trees (only selects the top 10 boroughs with the largest average tree diameter) in each borough 
SELECT borough,
       trunk_diameter
FROM (
    SELECT boroname AS borough,
           ROUND(AVG(tree_dbh), 2) AS trunk_diameter,
           RANK() OVER (PARTITION BY boroname ORDER BY AVG(tree_dbh) DESC) AS rank
    FROM trees
    GROUP BY boroname
) AS ranked_trees
WHERE rank <= 10
ORDER BY 2 DESC;




