-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_drop_unused_column.sql                                  |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL syntax used to drop unused columns from a table.    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

connect scott/tiger

set serveroutput on

Prompt ======================
Prompt DROP existing table...
Prompt ======================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

DROP TABLE d_table
/


Prompt =======================
Prompt CREATE TESTING TABLE...
Prompt =======================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

CREATE TABLE d_table (
    id_no     NUMBER
  , name      VARCHAR2(100)
  , d_column  VARCHAR2(100)
)
/


Prompt ========================
Prompt MARK COLUMN AS UNUSED...
Prompt ========================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

ALTER TABLE d_table SET UNUSED COLUMN d_column;


Prompt =======================================
Prompt QUERY ALL TABLES WITH UNUSED COLUMNS...
Prompt =======================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

SELECT * FROM sys.dba_unused_col_tabs;


Prompt ======================================
Prompt PHYSICALLY REMOVE THE UNUSED COLUMN...
Prompt ======================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

ALTER TABLE d_table DROP UNUSED COLUMNS;


Prompt ================================================
Prompt IF YOU WANTED TO PHYSICALLY REMOVE THE COLUMN...
Prompt ================================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

-- ALTER TABLE d_table DROP COLUMN d_column;


Prompt =========================================
Prompt OPTIONALLY SYNTAX FOR REMOVING COLUMNS...
Prompt =========================================
Prompt
Prompt ALTER TABLE d_table DROP COLUMN d_column CASCADE CONSTRAINTS;
Prompt ALTER TABLE d_table DROP COLUMN d_column INVALIDATE;
Prompt ALTER TABLE d_table DROP COLUMN d_column CHECKPOINT 1000;
Prompt
accept a1 Prompt "Hit <ENTER> to EXIT";


