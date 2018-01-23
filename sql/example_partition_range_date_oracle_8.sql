-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_partition_range_date_oracle_8.sql                       |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL syntax used to create and maintain range partitions |
-- |            in Oracle8. The table in this example is partitioned by a date  |
-- |            range. In Oracle8, only range partitions are available.         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

CONNECT scott/tiger

/*
 ** +-----------------------------------+
 ** | DROP ALL OBJECTS                  |
 ** +-----------------------------------+
*/

DROP TABLE emp_date_part CASCADE CONSTRAINTS
/


/*
 ** +-------------------------------------------------+
 ** | CREATE (Range) PARTITIONED TABLE                |
 ** | ----------------------------------------------- |
 ** | Create testing table partitioned by a           |
 ** | "range" of DATE values.                         |
 ** |                                                 |
 ** | NOTE: The only functions permitted in the       |
 ** | 'VALUES LESS THAN (value1, value2 ..., valueN)' | 
 ** | clause are TO_DATE and RPAD.                    |
 ** +-------------------------------------------------+
*/

CREATE TABLE emp_date_part (
    empno      NUMBER(15) NOT NULL
  , ename      VARCHAR2(100)
  , sal        NUMBER(7,2)
  , hire_date  DATE NOT NULL
)
TABLESPACE users
STORAGE (
  INITIAL      128K
  NEXT         128K
  PCTINCREASE  0
  MAXEXTENTS   UNLIMITED
)
PARTITION BY RANGE (hire_date) (
  PARTITION emp_date_part_Q1_2001_part
    VALUES LESS THAN (TO_DATE('01-APR-2001', 'DD-MON-YYYY'))
    TABLESPACE part_1_data_tbs,
  PARTITION emp_date_part_Q2_2001_part
    VALUES LESS THAN (TO_DATE('01-JUL-2001', 'DD-MON-YYYY'))
    TABLESPACE part_2_data_tbs,
  PARTITION emp_date_part_Q3_2001_part
    VALUES LESS THAN (TO_DATE('01-OCT-2001', 'DD-MON-YYYY'))
    TABLESPACE part_3_data_tbs,
  PARTITION emp_date_part_Q4_2001_part
    VALUES LESS THAN (TO_DATE('01-JAN-2002', 'DD-MON-YYYY'))
    TABLESPACE part_4_data_tbs
)
/

