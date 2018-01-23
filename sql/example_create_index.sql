-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_index.sql                                        |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script to demonstrate how to create indexes with    |
-- |            proper naming conventions.                                      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

/*
 * -------------------------------
 * UNIQUE INDEX
 * -------------------------------
 */

CREATE UNIQUE INDEX emp_u1
  ON emp(emp_id)
  TABLESPACE indexes
  STORAGE (
    INITIAL      256K
    NEXT         256K
    MINEXTENTS   1
    MAXEXTENTS   121
    PCTINCREASE  0
    FREELISTS    3
  )
/


/*
 * -------------------------------
 * NON-UNIQUE (default) INDEX
 * -------------------------------
 */

CREATE INDEX emp_n1
  ON emp(name)
  TABLESPACE indexes
  STORAGE (
    INITIAL      64K
    NEXT         64K
    MINEXTENTS   1
    MAXEXTENTS   121
    PCTINCREASE  0
    FREELISTS    3
  )
/


/*
 * -------------------------------
 * PRIMARY KEY INDEX
 * -------------------------------
 */

ALTER TABLE emp
ADD CONSTRAINT emp_pk PRIMARY KEY(emp_id)
    USING INDEX
    TABLESPACE indexes
    STORAGE (
      INITIAL     64K
      NEXT        64K
      MINEXTENTS  1
      MAXEXTENTS  121
      PCTINCREASE 0
    )
/

