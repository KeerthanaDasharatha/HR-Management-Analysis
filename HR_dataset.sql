CREATE database HR_Management;
USE HR_Management;

SELECT * from HRdataset;

-- 1 How many unique employees are present in the dataset?
SELECT COUNT(DISTINCT Empid) num_emp FROM HRdataset;

-- 2 What is the average tenure (in years) of employees by department?
SELECT 
    Department,
    ROUND(AVG(DATEDIFF(
        COALESCE(Termination_Date, CURDATE()), 
        Hireing_Date) / 365), 2) AS Avg_Tenure_Years
FROM HRDataset
GROUP BY Department
ORDER BY Avg_Tenure_Years DESC;


-- 3 What is the average salary of employees by department?
SELECT department,
AVG(salary) as emp_avg_salary
FROM HRdataset
GROUP BY department;


-- 4 Find the number of employees hired each year along with the average salary for that year.
SELECT department,
date_format(Hireing_Date,'%Y') as hire_year,
COUNT(*) as number_of_employees,
AVG(salary) as avg_salary
FROM HRdataset
GROUP BY department,hire_year
ORDER BY hire_year;

-- 5 How does gender distribution vary across departments and employment status, 
-- and what are the average performance scores and employee satisfaction levels for each group?
SELECT 
    Department,Gender,Employment_Status,
    COUNT(*) AS Employee_Count,
    AVG(CASE 
            WHEN Performance_Score = 'Fully Meets' THEN 3
            WHEN Performance_Score = 'Exceeds' THEN 4
            WHEN Performance_Score = 'Needs Improvement' THEN 2
            ELSE 1
        END) AS Avg_Performance_Score,
    AVG(Emp_Satisfaction) AS Avg_Satisfaction
FROM HRDataset
GROUP BY Department, Gender, Employment_Status
ORDER BY Department, Gender;

-- 6  Which recruitment sources have contributed the most employees overall, regardless of performance?

SELECT 
    RecruitmentSource,
    COUNT(*) AS High_Performers_Count
FROM HRDataset
GROUP BY RecruitmentSource
ORDER BY High_Performers_Count DESC;

-- 7 What is the distribution of marital status across different employment statuses, and how does it relate to employee engagement scores?

SELECT 
    Marital_Status,
    Employment_Status,
    COUNT(*) AS Employee_Count,
    round(AVG(Engagement_Survey),2) AS Avg_Engagement_Score
FROM HRDataset
GROUP BY Marital_Status, Employment_Status
ORDER BY Marital_Status, Employment_Status;

-- 8 Longest tenure employees with performance and satisfaction comparison
 SELECT 
    Employee_Name,
    Department,
    DATEDIFF(
        COALESCE(Termination_Date, CURDATE()), 
        Hireing_Date
    ) AS Tenure_Days,
    Performance_Score,
    Emp_Satisfaction
FROM HRDataset
ORDER BY Tenure_Days DESC
LIMIT 10;


-- 9  How many employees are in each salary band by department and gender? Also, what are the minimum and maximum salaries in those groups?
SELECT 
    department,
    gender,
    COUNT(*) AS Employee_Count,
    MIN(salary) AS Min_Salary,
    MAX(salary) AS Max_Salary,
    CASE
        WHEN salary > 80000 THEN 'high'
        WHEN salary BETWEEN 60000 AND 80000 THEN 'medium'
        ELSE 'low'
    END AS salary_band
    FROM HRdataset
GROUP BY department, gender, salary_band
ORDER BY department, gender, salary_band;



-- 10  Who are the top earners in each department based on salary,and what are their positions and performance scores?

SELECT Department,Employee_Name,Position,Salary,Performance_Score
FROM HRDataset hrd1
WHERE Salary = (SELECT MAX(Salary) FROM HRDataset hrd2 WHERE hrd2.salary = hrd1.salary)
ORDER BY salary desc;

-- 11 How many employees were hired and terminated each year, and what was the average tenure of terminated employees?
SELECT 
YEAR(Hireing_Date) AS Hire_Year,
YEAR(Termination_Date) AS Termination_Year,
    COUNT(*) AS Terminated_Employees,
	ROUND(AVG(DATEDIFF(Termination_Date, Hireing_Date)/365), 2) AS Avg_Tenure_Years
FROM HRDataset
WHERE Termination_Date IS NOT NULL
GROUP BY YEAR(Hireing_Date), YEAR(Termination_Date)
ORDER BY Termination_Year;

-- 12 Which departments have the highest termination rates, 
-- and what are the most common reasons (performance scores or employment statuses) associated with these terminations?
SELECT 
Department,Employment_Status,Performance_Score,
    COUNT(*) AS Termination_Count
FROM HRDataset
WHERE Employment_Status LIKE '%Terminated%'
GROUP BY Department, Employment_Status, Performance_Score
ORDER BY Termination_Count DESC;

-- 13 Which citizen status groups have the highest average salaries and satisfaction levels, and how do these differ by gender and department?
SELECT 
Citizen_Status,Gender,Department,
ROUND(AVG(Salary), 2) AS Avg_Salary,
ROUND(AVG(Emp_Satisfaction), 2) AS Avg_Satisfaction
FROM HRDataset
GROUP BY Citizen_Status, Gender, Department
ORDER BY Citizen_Status, Department, Gender;


-- 14 Department ranking by average engagement score and identifying below-average performers
WITH DeptEngagement AS (
SELECT 
Department,
AVG(Engagement_Survey) AS Avg_Engagement
FROM HRDataset
GROUP BY Department
),
CompanyAvg AS (
SELECT AVG(Engagement_Survey) AS Company_Avg FROM HRDataset
)
SELECT 
d.Department,d.Avg_Engagement,
RANK() OVER (ORDER BY d.Avg_Engagement DESC) AS Dept_Rank,
  CASE 
      WHEN d.Avg_Engagement < c.Company_Avg THEN 'Below Average'
      ELSE 'Above Average'
	END AS Performance_Level
FROM DeptEngagement d
CROSS JOIN CompanyAvg c
ORDER BY Dept_Rank;



-- 15  Which positions have the highest average engagement survey scores, and how does this vary by gender?
SELECT 
Position,Gender,
ROUND(AVG(Engagement_Survey), 2) AS Avg_Engagement_Score,
COUNT(*) AS Num_Employees
FROM HRDataset
GROUP BY Position, Gender
HAVING COUNT(*) > 5
ORDER BY Avg_Engagement_Score DESC;

-- How many employees belong to each Citizen_Status category 
SELECT citizen_status,
COUNT(*) as num_emp
FROM hrdataset
GROUP BY citizen_status;

-- -- For each state, how many employees belong to each citizen status group
SELECT state,citizen_status,
COUNT(*) AS num_emp
FROM hrdataset
GROUP BY state, citizen_status
ORDER BY num_emp DESC;


