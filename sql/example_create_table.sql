-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_table.sql                                        |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Simple create table script.                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


/*
 * --------------------------------------------------------
 * ---------------- CREATE TABLE (DEPT) -------------------
 * --------------------------------------------------------
 */

prompt Dropping Table (dept)...

DROP TABLE dept CASCADE CONSTRAINTS
/

prompt Creating Table (dept)...

CREATE TABLE dept (
      deptno   NUMBER(2)
    , dname    VARCHAR2(14)
    , loc      VARCHAR2(13)
) 
TABLESPACE users
STORAGE (
    INITIAL      128K
    NEXT         128K
    MINEXTENTS   1
    MAXEXTENTS   121
    PCTINCREASE  0
)
/

ALTER TABLE dept
ADD CONSTRAINT dept_pk PRIMARY KEY(deptno)
    USING INDEX
    TABLESPACE idx
    STORAGE (
      INITIAL     64K
      NEXT        64K
      MINEXTENTS  1
      MAXEXTENTS  121
      PCTINCREASE 0
    )
/

ALTER TABLE dept
MODIFY (   dname           CONSTRAINT dept_nn1  NOT NULL
)
/


/*
 * -------------------------------------------------------
 * ---------------- CREATE TABLE (EMP) -------------------
 * -------------------------------------------------------
 */

prompt Dropping Table (emp)...

DROP TABLE emp CASCADE CONSTRAINTS
/

prompt Creating Table (emp)...

CREATE TABLE emp (
      empno     NUMBER(4)
    , ename     VARCHAR2(10)
    , job       VARCHAR2(9)
    , mgr       NUMBER(4)
    , hiredate  DATE
    , sal       NUMBER(7,2)
    , comm      NUMBER(7,2)
    , deptno    NUMBER(2)
) 
TABLESPACE users
STORAGE (
    INITIAL      128K
    NEXT         128K
    MINEXTENTS   1
    MAXEXTENTS   121
    PCTINCREASE  0
)
/

ALTER TABLE emp
ADD CONSTRAINT emp_pk PRIMARY KEY(empno)
    USING INDEX
    TABLESPACE idx
    STORAGE (
        INITIAL     64K
        NEXT        64K
        MINEXTENTS  1
        MAXEXTENTS  121
        PCTINCREASE 0
    )
/

ALTER TABLE emp
MODIFY (   ename           CONSTRAINT emp_nn1  NOT NULL
         , job             CONSTRAINT emp_nn2  NOT NULL
         , hiredate        CONSTRAINT emp_nn3  NOT NULL
)
/

ALTER TABLE emp
ADD CONSTRAINT emp_fk1 FOREIGN KEY (deptno)
    REFERENCES dept(deptno)
/

