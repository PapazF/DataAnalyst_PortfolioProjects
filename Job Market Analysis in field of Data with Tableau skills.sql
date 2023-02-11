/* MySQL Job Market analysis project */
/* Focused on Data related jobs 'Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer' */
/* Required skill 'Tableau' */

/* Check first 10 rows */
SELECT * 
FROM job_postings
LIMIT 10;


/* Check how many rows */
SELECT COUNT(*)
FROM job_postings;


/* Number of Job Postings and Number of Applicants for Job Title with Grand Totals */
SELECT 
    COALESCE(JobTitle,'Grand Total') AS JobTitle, 
    COUNT(JobPostingID) AS num_job_postings, 
    SUM(NumberApplicants) AS num_applicants
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%'
GROUP BY JobTitle WITH ROLLUP;


/* Average years of Experience for each Position Level */
SELECT
    JobPositionLevel, 
    ROUND(AVG(YearsExperience),2) AS avg_years_experiance
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%'
GROUP BY JobPositionLevel
ORDER BY avg_years_experiance;


/* Number of Job Postings and number of Applicants per Industry */
SELECT 
    CompanyIndustry, 
    COUNT(*) AS num_jobs, 
    SUM(NumberApplicants) AS num_applicants
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%'
GROUP BY CompanyIndustry
HAVING num_jobs>100
ORDER BY num_jobs DESC;

/* Get the Minimum and Maximum salary for JobTitle */
SELECT 
    JobTitle, 
    MIN(MinimumPay) AS min_salary,
    MAX(MaximumPay) AS max_salary
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%'
GROUP BY JobTitle;


/* Average Salary for each Job Title */
SELECT 
     JobTitle, 
    (MinimumPay+MaximumPay)/2 AS avg_salary
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%'
GROUP BY JobTitle
ORDER BY avg_salary DESC;


/* Top 5 months with the most Job Postings */
SELECT 
    MONTH(JobPostingDate) AS month, 
    COUNT(*) AS num_jobs
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%'
GROUP BY month 
ORDER BY num_jobs DESC
LIMIT 5;


/* Number of Jobs (excluding Data related jobs) */
SELECT COUNT(*)
FROM job_postings
WHERE JobTitle NOT IN (
SELECT COUNT(*)
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%');


/* Tableau VS Power_Bi */
 
CREATE VIEW power_bi AS (
SELECT 
    JobTitle,
    COUNT(*) AS power_bi_num_jobs,
    MIN(MinimumPay) AS power_bi_min_salary,
    MAX(MaximumPay) AS power_bi_max_salary,
    (MinimumPay+MaximumPay)/2 AS power_bi_avg_salary
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
    AND JobSkills LIKE '%power_bi%'
    AND JobSkills NOT LIKE '%tableau%'
GROUP BY JobTitle
);

CREATE VIEW tableau AS (
SELECT 
    JobTitle,
    COUNT(*) AS tableau_num_jobs,
    MIN(MinimumPay) AS tableau_min_salary,
    MAX(MaximumPay) AS tableau_max_salary,
    (MinimumPay+MaximumPay)/2 AS tableau_avg_salary
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
     AND JobSkills LIKE '%tableau%'
     AND JobSkills NOT LIKE '%power_bi%'
GROUP BY JobTitle
);

SELECT *
FROM tableau
INNER JOIN power_bi
USING(JobTitle)
