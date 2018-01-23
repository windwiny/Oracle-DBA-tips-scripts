-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_clob_8.sql                                       |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script that demonstrates how to create tables       |
-- |            containing a CLOB datatype in Oracle8. One of biggest           |
-- |            differences between creating a CLOB in Oracle8 and Oracle8i or  |
-- |            higher is the use of the INDEX clause within the LOB clause     |
-- |            declaration. In Oracle8 it is possible to name the LOB INDEX    |
-- |            and declare a tablespace and storage clause for it. With        |
-- |            versions Oracle8i and higher, it is still possible to name the  |
-- |            INDEX LOB SEGMENT using the INDEX clause but these versions of  |
-- |            Oracle (8i and higher) will simply ignore  anything else within |
-- |            the INDEX clause (like tablespaces and storage clause.) From    |
-- |            what I have read Oracle is deprecating the tablespace and       |
-- |            storage clauses from being used within the INDEX clause.        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

DROP TABLE test_clob CASCADE CONSTRAINTS
/

CREATE TABLE test_clob (
      testrunid          NUMBER(15)
    , startdate          DATE
    , parameters         VARCHAR2(1000)
    , testtopology       CLOB
    , comments           VARCHAR2(4000)
    , testlog            CLOB
    , prefix             VARCHAR2(100)
)
LOB (testtopology)
    STORE AS testtopology_lob (
        TABLESPACE lob_data
        STORAGE (
            INITIAL 1m NEXT 1m PCTINCREASE 0 MAXEXTENTS unlimited
        )
        INDEX testtopology_lob_idx (
            TABLESPACE lob_indexes
            STORAGE (
                INITIAL 256k NEXT 256k PCTINCREASE 0 MAXEXTENTS unlimited
            )
        )
    )
LOB (testlog)
    STORE AS testlog_lob (
        TABLESPACE lob_data
        STORAGE (
            INITIAL 1m NEXT 1m PCTINCREASE 0 MAXEXTENTS unlimited
        )
        INDEX testlog_lob_idx (
            TABLESPACE lob_indexes
            STORAGE (
                INITIAL 256k NEXT 256k PCTINCREASE 0 MAXEXTENTS unlimited
            )
        )
    )
TABLESPACE users
STORAGE (
    INITIAL      256k
    NEXT         256k
    MINEXTENTS   1
    MAXEXTENTS   505
    PCTINCREASE  0
)
/

