-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_temporary_tables.sql                             |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script that demonstrates how to create temporary    |
-- |            tables.                                                         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


connect scott/tiger

set serveroutput on

Prompt ====================================================
Prompt CREATE TEMPORARY TABLE WITH DEFAULT SETTINGS...
Prompt (Oracle8i will use on commit delete rows by default)
Prompt ====================================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

CREATE GLOBAL TEMPORARY TABLE mytemptab1 (
    id    NUMBER
  , name  VARCHAR2(500)
  , average_salary  NUMBER(15,2)
)
/


Prompt ================================================
Prompt CREATE TEMPORARY TABLE: on commit delete rows...
Prompt ================================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

CREATE GLOBAL TEMPORARY TABLE mytemptab2 (
    id    NUMBER
  , name  VARCHAR2(500)
  , average_salary  NUMBER(15,2)
) ON COMMIT DELETE ROWS
/


Prompt ==================================================
Prompt CREATE TEMPORARY TABLE: on commit preserve rows...
Prompt ==================================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

CREATE GLOBAL TEMPORARY TABLE mytemptab3 (
    id    NUMBER
  , name  VARCHAR2(500)
  , average_salary  NUMBER(15,2)
) ON COMMIT PRESERVE ROWS
/


