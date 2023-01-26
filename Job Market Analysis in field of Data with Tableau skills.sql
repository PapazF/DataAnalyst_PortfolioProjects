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


/* Number of Job Postings, Number of Applicants by Job Title with grand totals */
SELECT 
    COALESCE(JobTitle,'Grand Total') AS JobTitle, 
    COUNT(JobPostingID) AS num_job_postings, 
    SUM(NumberApplicants) AS num_applicants
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%'
GROUP BY JobTitle WITH ROLLUP;


/* Average years of Experience based on the Job Level */
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

/* Get the Minimum and Maximum salary by JobTitle */
SELECT 
    JobTitle, 
    MIN(MinimumPay) AS min_salary,
    MAX(MaximumPay) AS max_salary
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%'
GROUP BY JobTitle;


/* Average Salary based on the Job Title */
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


/* Total Number of Jobs (excluding Data related jobs) */
SELECT COUNT(*)
FROM job_postings
WHERE JobTitle NOT IN (
SELECT COUNT(*)
FROM job_postings
WHERE JobTitle IN ('Data Analyst','Data Scientist','Data Science Manager', 'Data Engineer')
AND JobSkills LIKE '%tableau%');


/* Compere Tableau with Power BI based on the Number of Job Postings */
WITH tablea_vs_power_bi AS (
SELECT COUNT(*) AS tableau_jobs, 
	(SELECT COUNT(*)
	FROM job_postings
	WHERE JobSkills LIKE '%power_bi%'
	AND JobSkills NOT LIKE '%tableau%') AS power_bi_jobs
FROM job_postings
WHERE JobSkills LIKE '%tableau%'
AND JobSkills NOT LIKE '%power_bi%')
SELECT tableau_jobs - power_bi_jobs
FROM tablea_vs_power_bi;
    
