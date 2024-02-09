/*
Heart Disease Dataset Exploration 

Skills used: CTE's, Aggregate Functions, Creating Views, Converting Data Types, CASE Statement, Subqueries

*/
SELECT *
FROM heart_disease;


-- Data Cleansing: Replacing Numeric Values with Labels for Improved Clarity

-- Replaced 1 with "male" and 0 with "female" in the "sex" column.
-- Step 1: Add a temporary column
ALTER TABLE heart_disease
ADD COLUMN sex_temp VARCHAR;

-- Step 2: Update the temporary column
UPDATE heart_disease
SET sex_temp = CASE
    WHEN sex = 1 THEN 'male'
    ELSE 'female'
END;

-- Step 3: Drop the original column
ALTER TABLE heart_disease
DROP COLUMN sex_temp;

-- Step 4: Rename the temporary column
ALTER TABLE heart_disease
RENAME COLUMN sex_temp TO sex;

-- Changed the data type of the "chest_pain_type" column from integer to string and replaced values 1, 2, 3, 4 with 'TA', 'ATA', 'NAP', 'ASY' in the same column.
-- Step 1: Add a temporary column
ALTER TABLE heart_disease
ADD COLUMN chest_pain_temp VARCHAR;

-- Step 2: Update the temporary column
UPDATE heart_disease
SET chest_pain_type = CASE
    WHEN chest_pain_type = 0 THEN 'TA'
    WHEN chest_pain_type = 1 THEN 'ATA'
    WHEN chest_pain_type = 2 THEN 'NAP'
    WHEN chest_pain_type = 3 THEN 'ASY'
    ELSE chest_pain_type::VARCHAR
END;

-- Step 3: Drop the original column
ALTER TABLE heart_disease
DROP COLUMN chest_pain_type;

-- Step 4: Rename the temporary column
ALTER TABLE heart_disease
RENAME COLUMN chest_pain_temp TO chest_pain_type;

-- Next I changed the data type of the "resting_ecg" column from integer to string and replaced the values 0, 1, 2 with their corresponding labels: "Normal," "ST," "LVH"
-- Step 1: Add a temporary column
ALTER TABLE heart_disease
ADD COLUMN resting_ecg_temp VARCHAR;

-- Step 2: Update the temporary column
UPDATE heart_disease
SET resting_ecg_temp = CASE
    WHEN resting_ecg = 0 THEN 'Normal'
    WHEN resting_ecg = 1 THEN 'ST'
    WHEN resting_ecg = 2 THEN 'LVH'
    ELSE resting_ecg::VARCHAR
END;

-- Step 3: Drop the original column
ALTER TABLE heart_disease
DROP COLUMN resting_ecg;

-- Step 4: Rename the temporary column
ALTER TABLE heart_disease
RENAME COLUMN resting_ecg_temp TO resting_ecg;

-- Changed the data type of the "slope" column from integer to string and replaced the values 0, 1, 2 with their corresponding labels: "Up" (upsloping), "Flat" (flat), "Down" (downsloping)
-- Step 1: Add a temporary column
ALTER TABLE heart_disease
ADD COLUMN slope_temp VARCHAR;

-- Step 2: Update the temporary column
UPDATE heart_disease
SET slope_temp = CASE
    WHEN slope = 0 THEN 'Up'
    WHEN slope = 1 THEN 'Flat'
    WHEN slope = 2 THEN 'Down'
    ELSE slope::VARCHAR
END;

-- Step 3: Drop the original column
ALTER TABLE heart_disease
DROP COLUMN slope;

-- Step 4: Rename the temporary column
ALTER TABLE heart_disease
RENAME COLUMN slope_temp TO st_slope;

-- -- Changed the data type of the "thal" (thalassemia) column from integer to string and replace the values 1, 2, 3 with their corresponding labels: 1 = 'normal'; 2 = 'fixed defect'; 3 = 'reversable defect'
-- Step 1: Add a temporary column
ALTER TABLE heart_disease
ADD COLUMN thal_temp VARCHAR;

-- Step 2: Update the temporary column
UPDATE heart_disease
SET thal_temp = CASE
    WHEN thal = 1 THEN 'normal'
    WHEN thal = 2 THEN 'fixed defect'
    WHEN thal = 3 THEN 'reversible defect'
    ELSE thal::VARCHAR
END;

-- Step 3: Drop the original column
ALTER TABLE heart_disease
DROP COLUMN thal;

-- Step 4: Rename the temporary column
ALTER TABLE heart_disease
RENAME COLUMN thal_temp TO thal;


-- Overview of Heart Disease Dataset
SELECT *
FROM heart_disease;

--I provided Exploratory Data Analysis in order to explore, investigate and learn the data variables within our dataset
-- 1. Investigated the distribution of ages and gender in the dataset:

SELECT
    AVG(age) AS avg_age,
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    COUNT(*) AS total_records,
	(SUM(CASE WHEN sex = 'male' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS male_percentage,
    (SUM(CASE WHEN sex = 'female' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS female_percentage
FROM heart_disease;


-- 2. Provided the Chest Pain Analysis in order to investigate trends in chest pain types based on age or gender:
SELECT chest_pain_type, COUNT(*) AS count
FROM heart_disease
GROUP BY chest_pain_type;

-- Chest Pain Trends Based on Age
SELECT
    CASE
        WHEN age < 31 THEN '<31' 
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        WHEN age BETWEEN 51 AND 60 THEN '51-60'
        WHEN age BETWEEN 61 AND 70 THEN '61-70'
        ELSE '70+' 
    END AS age_group,
    chest_pain_type,
    COUNT(*) AS pain_type_count
FROM heart_disease
GROUP BY age_group, chest_pain_type
ORDER BY age_group, COUNT(*) DESC;

-- Chest Pain Trends Based on Gender
SELECT
    sex,
    chest_pain_type,
    COUNT(*) AS pain_type_count,
	(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM heart_disease)) AS percentage
FROM heart_disease
GROUP BY sex, chest_pain_type
ORDER BY sex, COUNT(*) DESC;

-- 3. Examined Cardiovascular Risk Factors:
-- Investigate the distribution of resting blood pressure, serum cholesterol, and maximum heart rate achieved.:
SELECT
    AVG(resting_blood_pressure) AS avg_blood_pressure,
    AVG(cholesterol) AS avg_cholesterol,
    AVG(max_heart_rate) AS avg_heart_rate
FROM heart_disease;

-- 4. Fasting Blood Sugar and ECG Results:
-- Analyzed the prevalence of fasting blood sugar > 120 mg/dl, where 0 = True, 1 = False:
SELECT fasting_blood_sugar, COUNT(*) AS count,
(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM heart_disease)) AS percentage
FROM heart_disease
GROUP BY fasting_blood_sugar;

-- Explored the distribution of resting electrocardiographic results with the prevalence of fasting blood sugar:
SELECT
    resting_ecg,
	AVG(CASE WHEN fasting_blood_sugar = 1 THEN 1 ELSE 0 END)*100 AS fasting_blood_sugar_percentage,
    COUNT(*) AS ecg_result_count
FROM heart_disease
GROUP BY resting_ecg
ORDER BY 3 DESC;

-- 4. Exercise-Related Insights:
-- Investigated the occurrence of exercise-induced angina:
SELECT
    AVG(CASE WHEN exercise_angina = 1 THEN 1 ELSE 0 END)*100 AS angina_percentage,
    AVG(oldpeak) AS avg_st_depression
FROM heart_disease;

-- 5. Heart Disease Severity Indicators: examined the distribution of the slope of the peak exercise ST segment:
SELECT
    st_slope,
    COUNT(*) AS st_slope_count,
	(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM heart_disease)) AS percentage
FROM heart_disease
GROUP BY st_slope;

-- Analyzed the number of major vessels colored by fluoroscopy:
SELECT n_major_vessels, COUNT(*) AS total
FROM heart_disease
GROUP BY n_major_vessels
ORDER BY 1;

-- 6. Thalassemia Analysis: explored the distribution of thalassemia types (normal, fixed defect, reversible defect):
SELECT
    thal,
    COUNT(*) AS thal_count
FROM heart_disease
GROUP BY thal;






