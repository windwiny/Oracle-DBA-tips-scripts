-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_emp_dept_custom.sql                              |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Creates several DEMO tables along with creating a PL/SQL        |
-- |            procedure (fill_emp) for seeding the tables with demo data.     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

prompt Connect as the test user. Default SCOTT...
CONNECT scott

/*
 * -------------------------------------------------------------
 *                ---  CREATE TABLE DEPT  ---
 * -------------------------------------------------------------
 */

DROP TABLE dept CASCADE CONSTRAINTS
/

CREATE TABLE dept (
    dept_id       NUMBER
  , name          VARCHAR2(100)
  , location      VARCHAR2(100)
)
/

ALTER TABLE dept
  ADD CONSTRAINT dept_pk PRIMARY KEY(dept_id)
/

ALTER TABLE dept
MODIFY (   name         CONSTRAINT dept_nn1  NOT NULL
         , location     CONSTRAINT dept_nn2  NOT NULL
)
/

/*
 * -------------------------------------------------------------
 *                ---  CREATE TABLE EMP  ---
 * -------------------------------------------------------------
 */

DROP TABLE emp CASCADE CONSTRAINTS
/

CREATE TABLE emp (
    emp_id           NUMBER
  , dept_id          NUMBER
  , name             VARCHAR2(30)
  , date_of_birth    DATE
  , date_of_hire     DATE
  , monthly_salary   NUMBER(15,2)
  , position         VARCHAR2(100)
  , extension        NUMBER
  , office_location  VARCHAR2(100)
)
/

ALTER TABLE emp
  ADD CONSTRAINT emp_pk PRIMARY KEY(emp_id)
/

ALTER TABLE emp
MODIFY (   name            CONSTRAINT emp_nn1  NOT NULL
         , date_of_birth   CONSTRAINT emp_nn2  NOT NULL
         , date_of_hire    CONSTRAINT emp_nn3  NOT NULL
         , monthly_salary  CONSTRAINT emp_nn4  NOT NULL
         , position        CONSTRAINT emp_nn5  NOT NULL
)
/

ALTER TABLE emp
ADD CONSTRAINT emp_fk1 FOREIGN KEY (dept_id)
    REFERENCES dept(dept_id)
/

/*
 * -------------------------------------------------------------
 *                ---  INSERT INTO DEPT  ---
 * -------------------------------------------------------------
 */

INSERT INTO DEPT VALUES (100 , 'ACCOUNTING'          , 'BUTLER, PA');
INSERT INTO DEPT VALUES (101 , 'RESEARCH'            , 'DALLAS, TX');
INSERT INTO DEPT VALUES	(102 , 'SALES'               , 'CHICAGO, IL');
INSERT INTO DEPT VALUES	(103 , 'OPERATIONS'          , 'BOSTON, MA');
INSERT INTO DEPT VALUES (104 , 'IT'                  , 'PITTSBURGH, PA');
INSERT INTO DEPT VALUES (105 , 'ENGINEERING'         , 'WEXFORD, PA');
INSERT INTO DEPT VALUES (106 , 'QA'                  , 'WEXFORD, PA');
INSERT INTO DEPT VALUES (107 , 'PROCESSING'          , 'NEW YORK, NY');
INSERT INTO DEPT VALUES (108 , 'CUSTOMER SUPPORT'    , 'TRANSFER, PA');
INSERT INTO DEPT VALUES (109 , 'HQ'                  , 'WEXFORD, PA');
INSERT INTO DEPT VALUES (110 , 'PRODUCTION SUPPORT'  , 'MONTEREY, CA');
INSERT INTO DEPT VALUES (111 , 'DOCUMENTATION'       , 'WEXFORD, PA');
INSERT INTO DEPT VALUES (112 , 'HELP DESK'           , 'GREENVILLE, PA');
INSERT INTO DEPT VALUES (113 , 'AFTER HOURS SUPPORT' , 'SAN JOSE, CA');
INSERT INTO DEPT VALUES (114 , 'APPLICATION SUPPORT' , 'WEXFORD, PA');
INSERT INTO DEPT VALUES (115 , 'MARKETING'           , 'SEASIDE, CA');
INSERT INTO DEPT VALUES (116 , 'NETWORKING'          , 'WEXFORD, PA');
INSERT INTO DEPT VALUES (117 , 'DIRECTORS OFFICE'    , 'WEXFORD, PA');
INSERT INTO DEPT VALUES (118 , 'ASSISTANTS'          , 'WEXFORD, PA');
INSERT INTO DEPT VALUES (119 , 'COMMUNICATIONS'      , 'SEATTLE, WA');
INSERT INTO DEPT VALUES (120 , 'REGIONAL SUPPORT'    , 'PORTLAND, OR');
COMMIT;


/*
 * -------------------------------------------------------------
 *          ---  CREATE PACKAGE (random) ---
 * -------------------------------------------------------------
 */

CREATE OR REPLACE PACKAGE random IS

  -- Returns random integer between [0, r-1]
  FUNCTION rndint(r IN NUMBER) RETURN NUMBER;

  -- Returns random real between [0, 1]
  FUNCTION rndflt RETURN NUMBER;

END;
/

CREATE OR REPLACE PACKAGE BODY random IS

  m         CONSTANT NUMBER:=100000000;  /* initial conditions */
  m1        CONSTANT NUMBER:=10000;      /* (for best results) */
  b         CONSTANT NUMBER:=31415821;   /*      */
  a         NUMBER;                      /* seed */
  the_date  DATE;                        /*      */
  days      NUMBER;                      /* for generating initial seed */
  secs      NUMBER;                      /*      */

  -- ------------------------
  -- Private utility FUNCTION
  -- ------------------------
  FUNCTION mult(p IN NUMBER, q IN NUMBER) RETURN NUMBER IS
    p1     NUMBER; 
    p0     NUMBER; 
    q1     NUMBER; 
    q0     NUMBER; 
  BEGIN 
    p1:=TRUNC(p/m1); 
    p0:=MOD(p,m1); 
    q1:=TRUNC(q/m1); 
    q0:=MOD(q,m1); 
    RETURN(MOD((MOD(p0*q1+p1*q0,m1)*m1+p0*q0),m)); 
  END;

  -- ---------------------------------------
  -- Returns random integer between [0, r-1]
  -- ---------------------------------------
  FUNCTION rndint (r IN NUMBER) RETURN NUMBER IS 
  BEGIN 
    -- Generate a random NUMBER, and set it to be the new seed
    a:=MOD(mult(a,b)+1,m); 

    -- Convert it to integer between [0, r-1] and return it
    RETURN(TRUNC((TRUNC(a/m1)*r)/m1));
  END;
 
  -- ----------------------------------
  -- Returns random real between [0, 1]
  -- ----------------------------------
  FUNCTION rndflt RETURN NUMBER IS
    BEGIN
      -- Generate a random NUMBER, and set it to be the new seed
      a:=MOD(mult(a,b)+1,m);
      RETURN(a/m);
    END;

BEGIN
  -- Generate initial seed "a" based on system date
  the_date:=SYSDATE;
  days:=TO_NUMBER(TO_CHAR(the_date, 'J'));
  secs:=TO_NUMBER(TO_CHAR(the_date, 'SSSSS'));
  a:=days*24*3600+secs;
END;
/

/*
 * -------------------------------------------------------------
 *             ---  CREATE PROCEDURE (fill_emp)  ---
 * -------------------------------------------------------------
 */

CREATE OR REPLACE PROCEDURE fill_emp (
  num_records IN number)

IS

  rand          NUMBER;
  randf         NUMBER;
  randfe        NUMBER;
  rand_dept_id  NUMBER;
  rand_dob      NUMBER;
  rand_date     NUMBER;
  rand_salary   NUMBER;

  record_count_success     NUMBER;
  record_count_fail_ic     NUMBER;
  record_count_fail_other  NUMBER;

  max_emp_id    NUMBER;

  CURSOR max_emp_csr IS
    SELECT MAX(emp_id)
    FROM emp;

BEGIN

  DBMS_OUTPUT.ENABLE;

  OPEN max_emp_csr;
  FETCH max_emp_csr INTO max_emp_id;
  CLOSE max_emp_csr;

  max_emp_id := NVL(max_emp_id,0) + 1;

  record_count_success     := 0;
  record_count_fail_ic     := 0;
  record_count_fail_other  := 0;

  FOR loop_index IN max_emp_id .. (max_emp_id + (num_records-1))
  LOOP

    rand          := random.rndint(20);
    randf         := random.rndflt;
    randfe        := TRUNC( (random.rndflt*10000));
    IF (randfe < 1000) THEN
      randfe := randfe * 10;
    END IF;
    rand_dept_id  := (rand + 100);
    rand_date     := rand * 10;
    rand_salary   := randf * 10000;
    IF (rand_salary < 1000) THEN
      rand_salary := rand_salary * 10;
    END IF;

    DECLARE
      integrity_constraint_e  EXCEPTION;
      pragma EXCEPTION_INIT (integrity_constraint_e, -02291);
    BEGIN

      INSERT INTO emp 
        VALUES (   loop_index
                 , rand_dept_id
                 , 'Name at : ' || (rand_dept_id * 17)
                 , sysdate - (rand_date * 90)
                 , sysdate + rand_date
                 , rand_salary
                 , 'Position at : ' || (rand_dept_id * 13)
                 , randfe
                 , 'Office Location at : ' || (rand_dept_id * 15)
        );

      IF (MOD(loop_index, 1000) = 0) THEN
        COMMIT;
      --  DBMS_OUTPUT.PUT_LINE('Commit point reached at: ' || loop_index || '.');
      END IF;

      record_count_success := record_count_success + 1;

    EXCEPTION
      WHEN integrity_constraint_e THEN
        -- DBMS_OUTPUT.PUT_LINE('Integrity constraint for dept_id: ' || rand_dept_id);
        record_count_fail_ic := record_count_fail_ic + 1;
      WHEN others THEN
        -- DBMS_OUTPUT.PUT_LINE('Other failure');
        record_count_fail_other := record_count_fail_other + 1;
    END;

  END LOOP;

  COMMIT;

  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Procedure complete inserting records into emp.');
  DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Requested records                     : ' || num_records);
  DBMS_OUTPUT.PUT_LINE('Successfully inserted records         : ' || record_count_success);
  DBMS_OUTPUT.PUT_LINE('Failed records (integrity_constraint) : ' || record_count_fail_ic);
  DBMS_OUTPUT.PUT_LINE('Failed records (other)                : ' || record_count_fail_other);

END;
/

