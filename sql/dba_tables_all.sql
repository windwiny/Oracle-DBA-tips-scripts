-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_tables_all.sql                                              |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Query all tables (and owners) within the database.              |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : All Database Tables                                         |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     OFF
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

DEFINE spool_file=database_tables.lst

SPOOL &spool_file

SELECT
    owner
  , table_name
  , tablespace_name
  , TO_CHAR(last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed
  , num_rows
FROM
    dba_tables
WHERE
    owner NOT IN ('SYS', 'SYSTEM')
ORDER BY
    owner
  , table_name
/

SPOOL OFF

SET TERMOUT ON

PROMPT 
PROMPT Report written to &spool_file
PROMPT 
