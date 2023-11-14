--ZAD1
DECLARE
    numer_max departments.department_id%TYPE;
    new_departament_number departments.department_id%TYPE;
    new_departament_name departments.department_name%TYPE := 'EDUCATION';
BEGIN
    SELECT MAX(department_id) INTO numer_max FROM departments;
    new_departament_number := numer_max + 10;
    INSERT INTO departments (department_id, department_name)
    VALUES (new_departament_number, new_departament_name);
END;

--ZAD2
DECLARE
    numer_max departments.department_id%TYPE;
    new_departament_number departments.department_id%TYPE;
    new_departament_name departments.department_name%TYPE := 'EDUCATION';
   	new_location_id departments.location_id%TYPE = 3000;
BEGIN
    SELECT MAX(department_id) INTO numer_max FROM departments;
    new_departament_number := numer_max + 10;
    INSERT INTO departments (department_id, department_name, location_id)
    VALUES (new_departament_number, new_departament_name, new_location_id);
END;

--ZAD3
CREATE TABLE nowa (
    value NUMBER(2, 0)
);
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= 10 LOOP
        IF i != 4 AND i != 6 THEN
            INSERT INTO nowa (value) VALUES (i);
        END IF;
        i := i + 1;
    END LOOP;
END;

--ZAD4
DECLARE
    v_country countries%ROWTYPE;
BEGIN
    SELECT * INTO v_country
    FROM countries
    WHERE country_id = 'CA';

    DBMS_OUTPUT.PUT_LINE('Name: ' || v_country.country_name);
    DBMS_OUTPUT.PUT_LINE('Region ID: ' || v_country.region_id);
END;

--ZAD5
DECLARE
	TYPE DepartmentTable IS TABLE OF departments.department_name%TYPE
	INDEX BY PLS_INTEGER;
	departments_table DepartmentTable;
BEGIN
	FOR dep IN (SELECT department_id, department_name FROM departments) LOOP
		departments_table(dep.department_id) := dep.department_name;
	END LOOP;
	FOR i IN 1 .. 10 LOOP
		DBMS_OUTPUT.PUT_LINE('Num: ' || i * 10);
		DBMS_OUTPUT.PUT_LINE('Departament name: ' || departments_table(i*10));
	END LOOP;
END;

--ZAD6
DECLARE
    TYPE DepartmentRecord IS RECORD (
        department_id departments.department_id%TYPE,
        department_name departments.department_name%TYPE,
        manager_id departments.manager_id%TYPE,
        location_id departments.location_id%TYPE
    );

    TYPE DepartmentTable IS TABLE OF DepartmentRecord
        INDEX BY PLS_INTEGER;

    department_info DepartmentTable;

BEGIN
    FOR dep IN (SELECT * FROM departments) LOOP
        department_info(dep.department_id).department_id := dep.department_id;
        department_info(dep.department_id).department_name := dep.department_name;
        department_info(dep.department_id).manager_id := dep.manager_id;
        department_info(dep.department_id).location_id := dep.location_id;
    END LOOP;
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE('Department ID: ' || department_info(i*10).department_id);
        DBMS_OUTPUT.PUT_LINE('Department Name: ' || department_info(i*10).department_name);
        DBMS_OUTPUT.PUT_LINE('Manager ID: ' || department_info(i*10).manager_id);
        DBMS_OUTPUT.PUT_LINE('Location ID: ' || department_info(i*10).location_id);
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;

--ZAD7

DECLARE
    CURSOR wynagrodzenie_cur IS
        SELECT last_name, salary
        FROM employees
        WHERE department_id = 50;

    v_last_name employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    FOR rec IN wynagrodzenie_cur LOOP
        v_last_name := rec.last_name;
        v_salary := rec.salary;

        IF v_salary > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(v_last_name || ' nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_last_name || ' dać podwyżkę');
        END IF;
    END LOOP;
END;

--ZAD8AB
DECLARE
    CURSOR zarobki_cur(p_min_salary NUMBER, p_max_salary NUMBER, p_part_of_name VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p_min_salary AND p_max_salary AND (INSTR(first_name, p_part_of_name) > 0 OR INSTR(first_name, UPPER(p_part_of_name)) > 0);

    v_first_name employees.first_name%TYPE;
    v_last_name employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pracownicy z widełkami 1000-5000 i częścią imienia a (może być również A):');
    FOR rec IN zarobki_cur(1000, 5000, 'a') LOOP
        v_first_name := rec.first_name;
        v_last_name := rec.last_name;
        v_salary := rec.salary;
        DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name || ', Zarobki: ' || v_salary);
    END;

    DBMS_OUTPUT.PUT_LINE('Pracownicy z widełkami 5000-20000 i częścią imienia u (może być również U):');
    FOR rec IN zarobki_cur(5000, 20000, 'u') LOOP
        v_first_name := rec.first_name;
        v_last_name := rec.last_name;
        v_salary := rec.salary;
        DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name || ', Zarobki: ' || v_salary);
    END;
END;

--ZAD9A
CREATE OR REPLACE PROCEDURE DodajJob(p_job_id VARCHAR2, p_job_title VARCHAR2) AS
BEGIN
    INSERT INTO jobs (job_id, job_title) VALUES (p_job_id, p_job_title);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END DodajJob;


--ZAD9B
CREATE OR REPLACE PROCEDURE ModyfikujJobTitle(p_job_id VARCHAR2, p_new_job_title VARCHAR2) AS
BEGIN
    UPDATE jobs
    SET job_title = p_new_job_title
    WHERE job_id = p_job_id;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'No Jobs updated');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END ModyfikujJobTitle;


--ZAD9C
CREATE OR REPLACE PROCEDURE UsunJob(p_job_id VARCHAR2) AS
BEGIN
    DELETE FROM jobs WHERE job_id = p_job_id;

    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No Jobs deleted');
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END UsunJob;