-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_primary_foreign_key.sql                          |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script that creates a Primary / Foreign key         |
-- |            relationship between the EMP and DEPT tables. It is advisable to|
-- |            create a non-unique index on all foreign keys.                  |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

-- +-----------------------------------------------------------------+
-- | ADD PRIMARY KEY                                                 |
-- +-----------------------------------------------------------------+

ALTER TABLE dept
ADD CONSTRAINT dept_pk PRIMARY KEY(dept_id)
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


-- +-----------------------------------------------------------------+
-- | ADD FOREIGN KEY                                                 |
-- +-----------------------------------------------------------------+

ALTER TABLE emp
ADD CONSTRAINT emp_fk1 FOREIGN KEY (dept_id)
    REFERENCES dept(dept_id)
/


-- +-----------------------------------------------------------------+
-- | ADD NON-UNIQUE INDEX FOR THE FOREIGN KEY                        |
-- +-----------------------------------------------------------------+

CREATE INDEX emp_fk_n1
  ON emp(dept_id)
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

