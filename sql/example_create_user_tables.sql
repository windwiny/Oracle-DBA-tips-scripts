-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_user_tables.sql                                  |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Yet another SQL script that demonstrates how to sample tables   |
-- |            and a PL/SQL routine that populates those tables.               |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

/*
** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

/*

CONNECT /

CREATE TABLESPACE users
  DATAFILE '/u10/app/oradata/ORA901/users01.dbf' SIZE 10M
/

CREATE TABLESPACE idx
  DATAFILE '/u09/app/oradata/ORA901/idx01.dbf' SIZE 10M
/

CREATE USER jhunter IDENTIFIED BY jhunter
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
/

GRANT dba, resource, connect TO jhunter
/

*/

/*
** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

CONNECT jhunter/jhunter

/*
** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

DROP TABLE user_names CASCADE CONSTRAINTS
/

CREATE TABLE user_names (
    name_intr_no     NUMBER(15)
  , name             VARCHAR2(30)
  , age              NUMBER(3)
  , update_log_date  DATE
) 
TABLESPACE users
STORAGE (
  INITIAL      64K
  NEXT         64K
  MINEXTENTS   1
  MAXEXTENTS   100
  PCTINCREASE  0
)
/

ALTER TABLE user_names
ADD CONSTRAINT user_names_pk PRIMARY KEY(name_intr_no)
    USING INDEX
    TABLESPACE idx
    STORAGE (
      INITIAL     28K
      NEXT        28K
      MINEXTENTS  1
      MAXEXTENTS  100
      PCTINCREASE 0
    )
/

ALTER TABLE user_names
MODIFY (   name            CONSTRAINT user_names_nn1  NOT NULL
         , age             CONSTRAINT user_names_nn2  NOT NULL
         , update_log_date CONSTRAINT user_names_nn3  NOT NULL
)
/

/*
** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

DROP TABLE user_names_phone
/

CREATE TABLE user_names_phone (
    name_intr_no        number(15)
  , phone_number     varchar2(12)
  , country_code     varchar2(15)
) 
TABLESPACE users
STORAGE (
  INITIAL      64K
  NEXT         64K
  MINEXTENTS   1
  MAXEXTENTS   100
  PCTINCREASE  0
)
/

ALTER TABLE user_names_phone
ADD CONSTRAINT user_names_phone_pk PRIMARY KEY(name_intr_no, phone_number)
    USING INDEX
    TABLESPACE idx
    STORAGE (
      INITIAL     28K
      NEXT        28K
      MINEXTENTS  1
      MAXEXTENTS  100
      PCTINCREASE 0
    )
/


ALTER TABLE user_names_phone
MODIFY ( country_code  CONSTRAINT user_names_phone_nn1  NOT NULL
)
/

ALTER TABLE user_names_phone
ADD CONSTRAINT user_names_phone_fk1 FOREIGN KEY (name_intr_no)
    REFERENCES user_names(name_intr_no)
/

/*
** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

DROP TABLE user_names_company
/

CREATE TABLE user_names_company (
    name_intr_no        number(15)
  , company_code     varchar2(15)
) 
TABLESPACE users
STORAGE (
  INITIAL      64K
  NEXT         64K
  MINEXTENTS   1
  MAXEXTENTS   100
  PCTINCREASE  0
)
/

/*
** +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

create or replace procedure insert_user_names (
  num_records IN number)

IS

  CURSOR csr1 IS
    SELECT max(name_intr_no)
    FROM user_names;

  max_intr_no      NUMBER;

BEGIN

  /*
  || ENABLE DBMS_OUTPUT
  */
  DBMS_OUTPUT.ENABLE;

  /*
  || SET ROLLBACK SEGMENT TO THE LARGEST ONE: rbs2
  */
  DECLARE
    incomplete_transaction  EXCEPTION;
    pragma EXCEPTION_INIT (incomplete_transaction, -01453);
  BEGIN
    SET TRANSACTION USE ROLLBACK SEGMENT rbs2;
  EXCEPTION
    WHEN incomplete_transaction THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Needed to rollback previous transaction');
      SET TRANSACTION USE ROLLBACK SEGMENT rbs2;
  END;

  /*
  || INSERT DUMMY RECORDS INTO THE USER DEFINED
  || TABLE: user_names. THE FIRST PARAMETER TO THIS
  || FUNCTION WILL DETERMINE THE NUMBER OF RECORDS
  || TO INSERT.
  */

  DECLARE
    fail_rollback_segment  EXCEPTION;
    pragma EXCEPTION_INIT (fail_rollback_segment, -01562);
 
  BEGIN
    OPEN csr1;
    FETCH csr1 INTO max_intr_no;
    CLOSE csr1;

    max_intr_no := NVL(max_intr_no,0) + 1;

    FOR loop_index IN max_intr_no .. (max_intr_no + (num_records-1))
    LOOP

      INSERT INTO user_names 
      VALUES (loop_index, 'Oracle DBA', 30, SYSDATE);

      INSERT INTO user_names_phone
      VALUES (loop_index, '412-555-1234', 'USA');

      INSERT INTO user_names_company
      VALUES (loop_index, 'DBA Zone');

      IF (MOD(loop_index, 100) = 0) THEN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Commit point reached at: ' || loop_index || '.');
      END IF;

    END LOOP;
    COMMIT;
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Successfully inserted ' ||  num_records ||
                          ' records into table: user_names');
  EXCEPTION
    WHEN fail_rollback_segment THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Fail to extent rollback segment: RBS2');
  END;

END;
/

show errors;

