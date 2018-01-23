-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_column_constraints.sql                                      |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on all column constraints in the database.              |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Column Constraints for a Specified Table                    |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT schema   CHAR PROMPT 'Enter schema     : '
ACCEPT tab_name CHAR PROMPT 'Enter table name : '

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN constraint_name  FORMAT a20          HEADING 'Constraint Name'
COLUMN table_name       FORMAT a20          HEADING 'Table Name'
COLUMN column_name      FORMAT a25          HEADING 'Column Name'
COLUMN position         FORMAT 999,999,999  HEADING 'Index Position'

BREAK ON report ON owner ON table_name SKIP 1

SELECT
    owner
  , table_name
  , constraint_name
  , column_name
  , position
FROM
  dba_cons_columns
WHERE
      owner = UPPER('&schema')  
  AND table_name = UPPER('&tab_name')
ORDER BY
    owner
  , table_name
  , constraint_name
  , position
/

