-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_index_organized_table.sql                        |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script that demonstrates how to create an Index     |
-- |            Organized Table (IOT) object.                                   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

/*
 * ------------------------
 * NORMAL IOT
 * ------------------------
 */

DROP TABLE my_iot
/

CREATE TABLE my_iot (
      id        NUMBER
    , name      VARCHAR2(100)
    , hiredate  DATE
    , CONSTRAINT my_iot_pk PRIMARY KEY (id)
)
ORGANIZATION INDEX
OVERFLOW TABLESPACE users
/


/*
 * --------------------------------------------
 * CREATE IOT FROM SELECTING FROM ANOTHER TABLE
 * --------------------------------------------
 */

DROP TABLE my_iot_from_table
/

CREATE TABLE my_iot_from_table (
    emp_id
  , dept_id
  , name
  , date_of_birth
  , date_of_hire
  , monthly_salary
  , position
  , extension
  , office_location
  , CONSTRAINT my_iot_from_table_pk PRIMARY KEY (emp_id)
)
ORGANIZATION INDEX
OVERFLOW TABLESPACE users
AS
SELECT * FROM emp
/

