-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_tables_query_user.sql                                       |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Prompt the user for a schema and then query all tables within   |
-- |            that schema.                                                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Query Tables for Specified Schema                           |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT schema CHAR PROMPT 'Enter schema : '

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

COLUMN owner            FORMAT a20              HEADING "Owner"
COLUMN table_name       FORMAT a30              HEADING "Table Name"
COLUMN tablespace_name  FORMAT a30              HEADING "Tablespace"
COLUMN last_analyzed    FORMAT a20              HEADING "Last Analyzed"
COLUMN num_rows         FORMAT 999,999,999,999  HEADING "# of Rows"

SELECT
    owner
  , table_name
  , tablespace_name
  , TO_CHAR(last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed
  , num_rows
FROM dba_tables
WHERE owner = UPPER('&schema')
ORDER BY
    owner
  , table_name
/

