/* retriveing data by using select and where condition */

SELECT * FROM employees WHERE first_name = 'Denis' ;


/* equal operators 
AND OR IN-NOT IN  LIKE- NOT LIKE  BETWEEN AND   EXISTS-NOT EXISTS  IS NULL - IS NOT NULL   ECT */

SELECT * FROM employees WHERE first_name = 'Kellie' AND gender = 'F'; 

SELECT * FROM employees WHERE first_name = 'Kellie' OR first_name = 'Aruna'; 

SELECT * FROM employees WHERE gender = 'F' AND (first_name = 'Kellie' OR first_name = 'Aruna');

SELECT * FROM employees WHERE first_name IN ('Denis' , 'Elvis');

SELECT * FROM employees WHERE first_name NOT IN ('John' , 'Mark', 'Jacob');

SELECT * FROM employees WHERE first_name LIKE ('%JACK%');

SELECT * FROM employees WHERE first_name NOT LIKE ('%Jack%'); 

SELECT * FROM salaries WHERE salary BETWEEN 66000 AND 70000;

SELECT dept_name FROM departments WHERE dept_no IS NOT NULL;

SELECT * FROM employees WHERE hire_date >= '2000-01-01' AND gender = 'F';

SELECT DISTINCT hire_date FROM employees;

SELECT * FROM employees ORDER BY hire_date DESC;

SELECT salary, COUNT(emp_no) AS emps_with_same_salary FROM salaries
WHERE salary > 80000 GROUP BY salary ORDER BY salary;

SELECT emp_no, AVG(salary) FROM salaries
GROUP BY emp_no
HAVING AVG(salary) > 120000
ORDER BY emp_no;

SELECT emp_no FROM dept_emp WHERE from_date > '2000-01-01'
GROUP BY emp_no
HAVING COUNT(from_date) > 1
ORDER BY emp_no;


SELECT * FROM dept_emp LIMIT 100;

/* inserting data by using insert into */

insert into employees
(
	emp_no,
    birth_date,
    first_name,
    last_name,
    gender,
    hire_date

)
values
(
	 999901,
    '1986-04-21',
    'john',
    'picksy',
    'M',
    '2011-01-01'

);
SELECT * FROM employees ORDER BY emp_no DESC LIMIT 10;


INSERT INTO departments VALUES ('d010', 'Analysis');


/* Updationg data by using UPDATE  */

UPDATE departments
SET
    dept_name = 'Data Analysis'
WHERE
    dept_no = 'd010';

COMMIT;

rollback;

/* Deleting data by using Delete  */

DELETE FROM departments WHERE dept_no = 'd010';


/* Aggregate Functions  */

SELECT  COUNT(DISTINCT dept_no) FROM dept_emp;

SELECT SUM(salary) FROM salaries WHERE from_date > '1997-01-01';

SELECT MIN(emp_no) FROM employees;

SELECT MAX(emp_no) FROM employees;

SELECT AVG(salary) FROM salaries WHERE from_date > '1997-01-01';

SELECT ROUND(AVG(salary), 2) FROM salaries WHERE from_date > '1997-01-01';

/*Joins  */

/* Extract a list containing information about all managers’ employee number, first and last name, department number, and hire date*/
SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    dm.dept_no,
    e.hire_date
FROM employees e
	JOIN
    dept_manager dm ON e.emp_no = dm.emp_no;


SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    dm.dept_no,
    dm.from_date
FROM
    employees e
	LEFT JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
WHERE
    e.last_name = 'Markovitch'
ORDER BY dm.dept_no DESC, e.emp_no;

/*CROSS JOINS */

SELECT
    e.*, d.*
FROM
    employees e
        CROSS JOIN
    departments d
WHERE
    e.emp_no < 10011
ORDER BY e.emp_no, d.dept_name;

/*Select all managers’ first and last name, hire date, job title, start date, and department name.*/
/*multiple joins */
SELECT
    e.first_name,
    e.last_name,
    e.hire_date,
    t.title,
    m.from_date,
    d.dept_name
FROM
    employees e
        JOIN
    dept_manager m ON e.emp_no = m.emp_no
        JOIN
    departments d ON m.dept_no = d.dept_no
        JOIN
    titles t ON e.emp_no = t.emp_no
WHERE t.title = 'Manager'
ORDER BY e.emp_no;

/*Union*/

SELECT * FROM
    (SELECT
        e.emp_no,
		e.first_name,
		e.last_name,
		NULL AS dept_no,
		NULL AS from_date
    FROM
        employees e
    WHERE
        last_name = 'Denis' UNION SELECT
        NULL AS emp_no,
		NULL AS first_name,
		NULL AS last_name,
		dm.dept_no,
		dm.from_date
    FROM
        dept_manager dm) as a
ORDER BY -a.emp_no DESC;


                 /*Sub Queries */
     
/*Extract the information about all department managers who were hired between the 1st of January 1990 and the 1st of January 1995.*/

SELECT * FROM
    dept_manager
WHERE
    emp_no IN (SELECT
		emp_no
        FROM
        employees
        WHERE
		hire_date BETWEEN '1990-01-01' AND '1995-01-01');

/*Select the entire information for all employees whose job title is “Assistant Engineer” */

SELECT * FROM
    employees e
WHERE
    EXISTS( SELECT
            *
        FROM
            titles t
        WHERE
            t.emp_no = e.emp_no
		AND title = 'Assistant Engineer');
                
                
                /*Views*/
/*Create a view that will extract the average salary of all managers registered in the database. Round this value to the nearest cent */

CREATE OR REPLACE VIEW v_manager_avg_salary AS
    SELECT
        ROUND(AVG(salary), 2)
    FROM
        salaries s
            JOIN
        dept_manager m ON s.emp_no = m.emp_no;
        
        
        
        /* Stored Procedures */
	/*Create a procedure that will provide the average salary of all employees.*/
        
        
   DELIMITER $$
CREATE PROCEDURE avg_salary()
BEGIN
			SELECT
				AVG(salary)
			FROM
				salaries;
END$$
DELIMITER ;
CALL avg_salary;
CALL avg_salary();
CALL employees.avg_salary;
CALL employees.avg_salary();     
        
        /*Create a procedure called ‘emp_info’ that uses as parameters the first and the last name of an individual, and returns their employee number*/
        
DELIMITER $$
CREATE PROCEDURE emp_info(in p_first_name varchar(255), in p_last_name varchar(255), out p_emp_no integer)
BEGIN
		SELECT
			e.emp_no
		INTO p_emp_no FROM
			employees e
		WHERE
			e.first_name = p_first_name
			AND e.last_name = p_last_name;
END$$
DELIMITER ;        
	SET @v_emp_no = 0;
	CALL emp_info('Aruna', 'Journel', @v_emp_no);
	SELECT @v_emp_no;
			
				/*Create a function called ‘emp_info’ that takes for parameters the first and last name of an employee, 
                and returns the salary from the newest contract of that employee*/
        
DELIMITER $$
CREATE FUNCTION emp_info(p_first_name varchar(255), p_last_name varchar(255)) RETURNS decimal(10,2)
BEGIN
	DECLARE v_max_from_date date;
    DECLARE v_salary decimal(10,2);
		SELECT
    MAX(from_date)
INTO v_max_from_date FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name
        AND e.last_name = p_last_name;
			SELECT
    s.salary
INTO v_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name
        AND e.last_name = p_last_name
        AND s.from_date = v_max_from_date;
                RETURN v_salary;
END$$
DELIMITER ;
SELECT EMP_INFO('Aruna', 'Journel');


					/*Triggers*/

/*Create a trigger that checks if the hire date of an employee is higher than the current date. If true, set this date to be the current date*/


DELIMITER $$
CREATE TRIGGER trig_hire_date
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN

		IF NEW.hire_date > date_format(sysdate(), '%Y-%m-%d') THEN
			SET NEW.hire_date = date_format(sysdate(), '%Y-%m-%d');
		END IF;
END $$
DELIMITER ;

INSERT employees VALUES ('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');
SELECT * FROM employees
ORDER BY emp_no DESC;

									/*indexes*/

/*Select all records from the ‘salaries’ table of people whose salary is higher than $89,000 per annum.*/


SELECT * FROM
salaries
WHERE
    salary > 89000;
CREATE INDEX i_salary ON salaries(salary);
SELECT * FROM salaries
WHERE
    salary > 89000;


							/* CASE Statement */

/*Extract the employee number, first name, and last name of the first 100 employees, 
	and add a fourth column, called “current_employee” saying “Is still employed” 
		if the employee is still working in the company, or “Not an employee anymore” if they aren’t*/

SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    CASE
        WHEN MAX(de.to_date) > SYSDATE() THEN 'Is still employed'
        ELSE 'Not an employee anymore'
    END AS current_employee
FROM
    employees e
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
GROUP BY de.emp_no
LIMIT 100;





