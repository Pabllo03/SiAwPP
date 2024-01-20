-- ZAD_01

CREATE OR REPLACE FUNCTION find_job(identifier IN VARCHAR2)
    RETURN VARCHAR2
IS
    v_result jobs.job_title%TYPE;
BEGIN
    SELECT job_title
    INTO v_result
    FROM jobs
    WHERE job_id = identifier;

    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: No matching entry found');
END;
/
DECLARE
    v_output VARCHAR2(100);
BEGIN
    v_output := find_job('IT_PROG');
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_output);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


-- ZAD_02

CREATE OR REPLACE FUNCTION calculate_calculate_annual_earnings(employee_id_param IN NUMBER)
    RETURN NUMBER
IS
    v_salary employees.salary%TYPE;
    v_commission_pct employees.commission_pct%TYPE;
    v_calculate_annual_earnings NUMBER;
BEGIN
    -- Pobieramy wynagrodzenie i premie pracownika na podstawie ID
    SELECT salary, commission_pct
    INTO v_salary, v_commission_pct
    FROM employees
    WHERE employee_id = employee_id_param;

    -- Obliczamy roczne zarobki (wynagrodzenie 12-miesieczne plus premia)
    v_calculate_annual_earnings := v_salary * 12 + (v_salary * v_commission_pct);

    RETURN v_calculate_annual_earnings;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: The employee with the given ID does not exist');
END;


-- ZAD_03

CREATE OR REPLACE FUNCTION extract_area_code(phone_number IN VARCHAR2)
    RETURN VARCHAR2
IS
    v_area_code VARCHAR2(10);
BEGIN
    -- Sprawdzenie, czy numer telefonu ma odpowiednia dlugosc i format
    IF LENGTH(phone_number) >= 9 AND REGEXP_LIKE(phone_number, '^\+\d{1,4}-\d{2,8}$') THEN
        -- Wyodrebnienie numer kierunkowy z numeru telefonu
        v_area_code := SUBSTR(phone_number, 2, INSTR(phone_number, '-') - 2);
        RETURN v_area_code;
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Error: Invalid phone number format');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Failed to extract area code');
END;


CREATE OR REPLACE FUNCTION zmien_wielkosc_liter(p_ciag VARCHAR2) RETURN VARCHAR2
IS
    v_wynik VARCHAR2(4000);
BEGIN
    IF LENGTH(p_ciag) = 0 THEN
        RETURN NULL;
    END IF;

    v_wynik := INITCAP(SUBSTR(p_ciag, 1, 1)) || LOWER(SUBSTR(p_ciag, 2, LENGTH(p_ciag) - 2)) || INITCAP(SUBSTR(p_ciag, -1, 1));

    RETURN v_wynik;
END;


-- ZAD_04

CREATE OR REPLACE FUNCTION format_name_case(input_string IN VARCHAR2)
    RETURN VARCHAR2
IS
    v_result VARCHAR2(255);
BEGIN
    IF LENGTH(input_string) = 0 THEN
        RETURN NULL;
    END IF;

    v_result := INITCAP(SUBSTR(input_string, 1, 1)) || LOWER(SUBSTR(input_string, 2, LENGTH(input_string) - 2)) || INITCAP(SUBSTR(input_string, -1, 1));

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Failed to transform string');
END;



SELECT format_name_case('fourth task test') AS wynik FROM DUAL;


-- ZAD_05

CREATE OR REPLACE FUNCTION pesel_to_date(pesel IN VARCHAR2)
    RETURN VARCHAR2
IS
    v_year VARCHAR2(4);
    v_month VARCHAR2(2);
    v_day VARCHAR2(2);
    v_birthdate VARCHAR2(10);
BEGIN
    -- Sprawdzamy, czy PESEL ma poprawna dlugosc
    IF LENGTH(pesel) = 11 THEN
        -- Wyodrebniamy rok, miesiac i dzien z PESEL
        v_year := SUBSTR(pesel, 1, 2);
        v_month := SUBSTR(pesel, 3, 2);
        v_day := SUBSTR(pesel, 5, 2);

        -- Dodajemy "19" lub "20" na poczatku roku w zaleznosci od cyfry miesiaca
        IF TO_NUMBER(v_month) <= 12 THEN
            v_year := '19' || v_year;
        ELSE
            v_year := '20' || v_year;
        END IF;

        -- Tworzymy date urodzenia w formacie 'yyyy-mm-dd'
        v_birthdate := v_year || '-' || v_month || '-' || v_day;

        RETURN v_birthdate;
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Error: Invalid PESEL number length');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Failed to convert PESEL number to date of birth');
END;
/


-- ZAD_06

CREATE OR REPLACE FUNCTION employee_and_department_count(kraj VARCHAR2)
RETURN
    VARCHAR2
IS
    v_liczba_pracownikow INT;
    v_liczba_departamentow INT;
    wynik VARCHAR2(100);
BEGIN
    -- Znajdz liczbe pracownikow w danym kraju
    SELECT COUNT(*) INTO v_liczba_pracownikow
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.location_id IN (SELECT l.location_id FROM locations l JOIN countries c ON l.country_id = c.country_id
    WHERE c.country_name = kraj);

    -- Znajdz liczbe departamentow w danym kraju
    SELECT COUNT(*) INTO v_liczba_departamentow
    FROM departments d
    JOIN locations l ON d.location_id = l.location_id
    JOIN countries c ON l.country_id = c.country_id
    WHERE c.country_name = kraj;

    IF v_liczba_departamentow = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'The specified country does not exist in the database.');
    END IF;

    wynik := 'Number of employees: ' || TO_CHAR(v_liczba_pracownikow) || '. Number of departments: '
    || TO_CHAR(v_liczba_departamentow);

    RETURN wynik;

END;
/
SELECT employee_and_department_count('United States of America') FROM DUAL;


-- Wyzwalacz_01

DROP TABLE archiwum_departamentow;
-- TABELA_POMOCNICZA
CREATE TABLE archiwum_departamentow (
    id NUMBER,
    nazwa VARCHAR2(100),
    data_zamkniecia DATE,
    ostatni_manager VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER archiwum_departamentow_trigger
AFTER DELETE ON departments
FOR EACH ROW
DECLARE
    v_manager_first_name employees.first_name%TYPE;
    v_manager_last_name employees.last_name%TYPE;
BEGIN
    SELECT first_name, last_name
    INTO v_manager_first_name, v_manager_last_name
    FROM employees
    WHERE employee_id = :OLD.manager_id;

    INSERT INTO archiwum_departamentow (id, nazwa, data_zamkniecia, ostatni_manager)
    VALUES (:OLD.department_id, :OLD.department_name, SYSDATE, v_manager_first_name || ' ' || v_manager_last_name);
END;


-- Wyzwalacz_02

DROP TABLE zlodziej;

CREATE TABLE zlodziej (
    id NUMBER,
    "USER" VARCHAR2(100),
    czas_zmiany TIMESTAMP
);

DECLARE
    v_sequence_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_sequence_exists FROM user_sequences WHERE sequence_name = 'ZLODZIEJ_SEQ';

    IF v_sequence_exists = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE zlodziej_seq';
    END IF;
END;

CREATE OR REPLACE TRIGGER employees_salary_check_trigger
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN
        INSERT INTO zlodziej (id, "USER", czas_zmiany)
        VALUES (zlodziej_seq.NEXTVAL, USER, SYSTIMESTAMP);

        RAISE_APPLICATION_ERROR(-20001, 'Salary must be within range  2000 - 26000');
    END IF;
END;


-- Wyzwalacz_03

CREATE SEQUENCE employees_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE;

-- WYZWALACZ
CREATE OR REPLACE TRIGGER employees_auto_increment_trigger
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF :NEW.employee_id IS NULL THEN
        SELECT employees_seq.NEXTVAL INTO :NEW.employee_id FROM DUAL;
    END IF;
END;


-- Wyzwalacz_04

CREATE OR REPLACE TRIGGER jod_grades_trigger
BEFORE INSERT OR UPDATE OR DELETE ON JOB_GRADES
BEGIN
  RAISE_APPLICATION_ERROR(-20024, 'Operations on the JOB_GRADES s¹ table are prohibited.');
END;


-- Wyzwalacz_05

CREATE OR REPLACE TRIGGER jobs_before_update_trigger
BEFORE UPDATE ON jobs
FOR EACH ROW
BEGIN
    :NEW.max_salary := :OLD.max_salary;
    :NEW.min_salary := :OLD.min_salary;
END;
/

Update JOBS SET min_salary=1, max_salary= 2 WHERE job_id = 'AD_PRES';
SELECT * FROM JOBS WHERE job_id = 'AD_PRES';


-- Paczka_1

CREATE OR REPLACE PACKAGE package1 AS
    FUNCTION find_job(job_id VARCHAR2) RETURN VARCHAR2;
    FUNCTION calculate_annual_earnings(employee_id INT) RETURN FLOAT;
    FUNCTION extract_area_code(phone_number IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION format_name_case(p_string VARCHAR2) RETURN VARCHAR2;
    FUNCTION pesel_to_date(p_pesel VARCHAR2) RETURN VARCHAR2;
    FUNCTION employee_and_department_count(country VARCHAR2) RETURN VARCHAR2;
    PROCEDURE AddJob(p_job_id Jobs.Job_id%TYPE, p_job_title Jobs.Job_title%TYPE);
    PROCEDURE EditJobTitle(p_job_id JOBS.job_id%TYPE, p_job_title JOBS.job_title%TYPE);
    PROCEDURE DeleteJob(p_job_id JOBS.job_id%TYPE);
    PROCEDURE EmployeeEarnings(p_employee_id Employees.employee_id%TYPE, o_earnings OUT employees.salary%TYPE, o_last_name OUT employees.last_name%TYPE);
    PROCEDURE AddEmployee(
        p_first_name employees.first_name%TYPE,
        p_last_name employees.last_name%TYPE,
        p_salary employees.salary%TYPE DEFAULT 1000,
        p_email employees.email%TYPE DEFAULT 'example@mail.com',
        p_phone_number employees.phone_number%TYPE DEFAULT NULL,
        p_hire_date employees.hire_date%TYPE DEFAULT SYSDATE,
        p_job_id employees.job_id%TYPE DEFAULT 'IT_PROG',
        p_commission_pct employees.commission_pct%TYPE DEFAULT NULL,
        p_manager_id employees.manager_id%TYPE DEFAULT NULL,
        p_department_id employees.department_id%TYPE DEFAULT 60
    );
END package1;
/

CREATE OR REPLACE PACKAGE BODY package1 AS
    FUNCTION find_job(job_id VARCHAR2) RETURN VARCHAR2
    IS
        v_job_title VARCHAR2(100);
    BEGIN
        SELECT job_title
        INTO v_job_title
        FROM JOBS
        WHERE job_id = job_id;

        RETURN v_job_title;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Job with the given ID does not exist');
    END;

    FUNCTION calculate_annual_earnings(employee_id INT) RETURN FLOAT
    IS
        v_salary FLOAT;
        v_commission FLOAT;
    BEGIN
        SELECT (salary * 12)
        INTO v_salary
        FROM employees
        WHERE employee_id = employee_id;

        SELECT (salary * commission_pct)
        INTO v_commission
        FROM employees
        WHERE employee_id = employee_id;

        IF v_commission IS NOT NULL THEN
            RETURN (v_salary + v_commission);
        END IF;
        RETURN v_salary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Employee with the given ID does not exist');
    END;

    FUNCTION extract_area_code(phone_number IN VARCHAR2) RETURN VARCHAR2
    IS
        v_area_code VARCHAR2(50);
    BEGIN
        v_area_code := '(' || SUBSTR(phone_number,1, LENGTH(phone_number)-9) || ')' || SUBSTR(phone_number,LENGTH(phone_number)-9+1);
        RETURN v_area_code;
    END;

    FUNCTION format_name_case(p_string VARCHAR2) RETURN VARCHAR2
    IS
        v_result VARCHAR2(4000);
    BEGIN
        IF LENGTH(p_string) = 0 THEN
            RETURN NULL;
        END IF;

        v_result := INITCAP(SUBSTR(p_string, 1, 1)) || LOWER(SUBSTR(p_string, 2, LENGTH(p_string) - 2)) || INITCAP(SUBSTR(p_string, -1, 1));

        RETURN v_result;
    END;

    FUNCTION pesel_to_date(p_pesel VARCHAR2) RETURN VARCHAR2
    IS
        v_year VARCHAR2(4);
        v_month VARCHAR2(2);
        v_day VARCHAR2(2);
        v_birth_date VARCHAR2(10);
    BEGIN
        IF LENGTH(p_pesel) <> 11 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid PESEL (incorrect length)!');
        END IF;

        v_month := SUBSTR(p_pesel, 3, 2);
        IF v_month > 20 THEN
            v_year := '20' || SUBSTR(p_pesel, 1, 2);
            v_month := TO_CHAR(TO_NUMBER( v_month)-20);
        ELSE
            v_year := '19' || SUBSTR(p_pesel, 1, 2);
        END IF;
        v_day := SUBSTR(p_pesel, 5, 2);

        v_birth_date := v_year || '-' || v_month || '-' || v_day;

        RETURN v_birth_date;
    END;

    FUNCTION employee_and_department_count(country VARCHAR2) RETURN VARCHAR2
    IS
        v_employee_count INT;
        v_department_count INT;
        result VARCHAR2(100);
    BEGIN
        SELECT COUNT(*) INTO v_employee_count
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        WHERE d.location_id IN (SELECT l.location_id FROM locations l JOIN countries c ON l.country_id = c.country_id
        WHERE c.country_name = country);

        SELECT COUNT(*) INTO v_department_count
        FROM departments d
        JOIN locations l ON d.location_id = l.location_id
        JOIN countries c ON l.country_id = c.country_id
        WHERE c.country_name = country;

        IF v_department_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'The specified country does not exist in the database.');
        END IF;
        result := ' Employee count: ' || TO_CHAR(v_employee_count) || '. Department count: '
        || TO_CHAR(v_department_count);
        RETURN result;
    END;

    PROCEDURE AddJob(p_job_id Jobs.Job_id%TYPE, p_job_title Jobs.Job_title%TYPE)
    AS
    BEGIN
        INSERT INTO Jobs (Job_id, Job_title)
        VALUES (p_job_id, p_job_title);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error while adding a row to the Jobs table: ' || SQLERRM);
    END AddJob;

    PROCEDURE EditJobTitle(p_job_id JOBS.job_id%TYPE, p_job_title JOBS.job_title%TYPE)
    AS
        no_jobs_updated EXCEPTION;
        PRAGMA EXCEPTION_INIT(no_jobs_updated, -20000);
    BEGIN
        UPDATE JOBS SET job_title = p_job_title WHERE job_id = p_job_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE no_jobs_updated;
        END IF;
        COMMIT;
    EXCEPTION
        WHEN
            no_jobs_updated THEN
        DBMS_OUTPUT.PUT_LINE('No updated rows in the Jobs table.');
    END EditJobTitle;

    PROCEDURE DeleteJob(p_job_id JOBS.job_id%TYPE)
    AS
        no_jobs_deleted EXCEPTION;
        PRAGMA EXCEPTION_INIT(no_jobs_deleted, -20001);
    BEGIN
        DELETE FROM Jobs WHERE job_id = p_job_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE no_jobs_deleted;
        END IF;
        COMMIT;
    EXCEPTION
        WHEN no_jobs_deleted THEN
            DBMS_OUTPUT.PUT_LINE('No deleted rows in the Jobs table.');
    END DeleteJob;

    PROCEDURE EmployeeEarnings(p_employee_id Employees.employee_id%TYPE, o_earnings OUT employees.salary%TYPE, o_last_name OUT employees.last_name%TYPE)
    AS
    BEGIN
        SELECT salary, last_name INTO o_earnings, o_last_name FROM employees
        WHERE employees.employee_id = p_employee_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No employee with the specified ID.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error while retrieving employee data: ' || SQLERRM);
    END EmployeeEarnings;

    PROCEDURE AddEmployee(
        p_first_name employees.first_name%TYPE,
        p_last_name employees.last_name%TYPE,
        p_salary employees.salary%TYPE DEFAULT 1000,
        p_email employees.email%TYPE DEFAULT 'example@mail.com',
        p_phone_number employees.phone_number%TYPE DEFAULT NULL,
        p_hire_date employees.hire_date%TYPE DEFAULT SYSDATE,
        p_job_id employees.job_id%TYPE DEFAULT 'IT_PROG',
        p_commission_pct employees.commission_pct%TYPE DEFAULT NULL,
        p_manager_id employees.manager_id%TYPE DEFAULT NULL,
        p_department_id employees.department_id%TYPE DEFAULT 60
    )
    AS
        salary_too_high EXCEPTION;
        PRAGMA EXCEPTION_INIT(salary_too_high, -20002);
        v_employee_id NUMBER;
    BEGIN
        SELECT (MAX(employee_id)+1) INTO v_employee_id FROM employees;
        IF p_salary > 20000 THEN
            RAISE salary_too_high;
        ELSE
            INSERT INTO employees
            VALUES (v_employee_id, p_first_name, p_last_name, p_email, p_phone_number,
            p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id);
            COMMIT;
        END IF;
    EXCEPTION
        WHEN salary_too_high THEN
            DBMS_OUTPUT.PUT_LINE('Salary exceeds 20000, cannot add employee.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error while adding an employee: ' || SQLERRM);
    END AddEmployee;
END package1;
/


-- Paczka_02

CREATE OR REPLACE PACKAGE regions_package AS
  PROCEDURE add_region(p_region_id NUMBER, p_region_name VARCHAR2);
  PROCEDURE update_region(p_region_id NUMBER, p_new_region_name VARCHAR2);
  PROCEDURE delete_region(p_region_id NUMBER);

  FUNCTION get_region_name(p_region_id NUMBER) RETURN VARCHAR2;
  FUNCTION get_region_id_by_name(p_region_name VARCHAR2) RETURN NUMBER;
END regions_package;
/

CREATE OR REPLACE PACKAGE BODY regions_package AS
  PROCEDURE add_region(p_region_id NUMBER, p_region_name VARCHAR2) IS
  BEGIN
    INSERT INTO regions (region_id, region_name) VALUES (p_region_id, p_region_name);
    COMMIT;
  END add_region;

  PROCEDURE update_region(p_region_id NUMBER, p_new_region_name VARCHAR2) IS
  BEGIN
    UPDATE regions SET region_name = p_new_region_name WHERE region_id = p_region_id;
    COMMIT;
  END update_region;

  PROCEDURE delete_region(p_region_id NUMBER) IS
  BEGIN
    DELETE FROM regions WHERE region_id = p_region_id;
    COMMIT;
  END delete_region;

  FUNCTION get_region_name(p_region_id NUMBER) RETURN VARCHAR2 IS
    v_region_name regions.region_name%TYPE;
  BEGIN
    SELECT region_name INTO v_region_name FROM regions WHERE region_id = p_region_id;
    RETURN v_region_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_region_name;

  FUNCTION get_region_id_by_name(p_region_name VARCHAR2) RETURN NUMBER IS
    v_region_id regions.region_id%TYPE;
  BEGIN
    SELECT region_id INTO v_region_id FROM regions WHERE region_name = p_region_name;
    RETURN v_region_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_region_id_by_name;
END regions_package;
/