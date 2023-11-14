-- zad1

SELECT CONCAT(last_name, CONCAT(' ', salary)) AS lastname_salary
FROM employees
WHERE (department_id = 20 OR department_id = 50) AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

-- zad2
SELECT hire_date, last_name, salary
FROM (SELECT e.hire_date, e.last_name, e.salary
AS salary 
FROM employees e 
WHERE e.manager_id
IS NOT NULL AND EXTRACT(YEAR FROM hire_date) = 2005)
ORDER BY salary;

-- zad3
SELECT CONCAT(first_name, CONCAT(' ', last_name)) AS name, salary, phone_number
FROM employees
WHERE SUBSTR(LAST_NAME, 3, 1) = 'e'
AND SUBSTR(FIRST_NAME, 1, 2) = 'Da'
ORDER BY name DESC, salary;

-- zad4
SELECT first_name, last_name,
	ROUND(MONTHS_BETWEEN(CURRENT_DATE, hire_date)) AS il_miesiecy,
	CASE
	 WHEN ROUND(MONTHS_BETWEEN(CURRENT_DATE, hire_date)) <=150 THEN 0.1 * salary
	 WHEN ROUND(MONTHS_BETWEEN(CURRENT_DATE, hire_date)) <=200 THEN 0.2 * salary
	 ELSE 0.3 * salary
	END AS wysokosc_dodatku
FROM employees
ORDER BY il_miesiecy;

-- zad5
SELECT department_id, SUM(salary) AS suma_zarobkow, ROUND(AVG(salary)) AS srednia_zarobkow
FROM employees
GROUP BY department_id
HAVING MIN(salary) > 5000;

-- zad6
SELECT e.last_name, e.department_id, d.department_name, e.job_id
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
WHERE d.location_id = 'Toronto';

-- zad7
SELECT e1.first_name, e1.last_name, e2.first_name, e2.last_name
FROM employees e1
JOIN employees e2 ON e1.employee_id <> e2.employee_id
WHERE e1.first_name = 'Jennifer';

-- zad8
SELECT d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

-- zad10
SELECT e.first_name, e.last_name, e.job_id, d.department_name, e.salary, j.grade
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN job_grades j ON e.salary > j.min_salary AND e.salary < j.max_salary;

-- zad11
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- zad12
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE e.department_id IN (
    SELECT DISTINCT department_id
    FROM employees
    WHERE last_name LIKE '%u%'
);