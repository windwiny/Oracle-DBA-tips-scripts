-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_clob.sql                                         |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script that demonstrates how to create tables       |
-- |            containing a CLOB datatype in Oracle8i and higher. One of the   |
-- |            biggest differences between creating a CLOB in Oracle8 and      |
-- |            Oracle8i or higher is the use of the INDEX clause within the LOB|
-- |            clause declaration. In Oracle8 it is possible to name the LOB   |
-- |            INDEX and declare a tablespace and storage clause for it. With  |
-- |            versions Oracle8i and higher, it is still possible to name the  |
-- |            INDEX LOB SEGMENT using the INDEX clause but these versions of  |
-- |            Oracle (8i and higher) will simply ignore anything else within  |
-- |            the INDEX clause (like tablespaces and storage clause.) From    |
-- |            what I have read Oracle is deprecating the tablespace and       |
-- |            storage clauses from being used within the INDEX clause.        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

DROP TABLE xml_documents
/

CREATE TABLE xml_documents (
      docname            VARCHAR2(200)
    , xmldoc             CLOB
    , log                CLOB
    , timestamp          DATE
)
LOB (xmldoc)
    STORE AS xml_documents_lob (
        TABLESPACE lob_data
        STORAGE (
            INITIAL 1m NEXT 1m PCTINCREASE 0 MAXEXTENTS unlimited
        )
        INDEX xml_documents_lob_idx
    )
LOB (log)
    STORE AS xml_log_lob (
        TABLESPACE lob_data
        STORAGE (
            INITIAL 1m NEXT 1m PCTINCREASE 0 MAXEXTENTS unlimited
        )
        INDEX xml_log_lob_idx
    )
TABLESPACE users
STORAGE (
    INITIAL      256k
    NEXT         256k
    MINEXTENTS   1
    MAXEXTENTS   121
    PCTINCREASE  0
)
/

