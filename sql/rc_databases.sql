-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : rc_databases.sql                                                |
-- | CLASS    : Recovery Manager                                                |
-- | PURPOSE  : Provide a listing of all databases found in the RMAN recovery   |
-- |            catalog.                                                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : RMAN Registered Databases                                   |
PROMPT | Instance : &current_instance                                           |
PROMPT | Note     : Listing of all databases in the RMAN recovery catalog.      |
PROMPT +------------------------------------------------------------------------+

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

COLUMN db_key                 FORMAT 999999                 HEADING 'DB|Key'
COLUMN dbinc_key              FORMAT 999999                 HEADING 'DB Inc|Key'
COLUMN dbid                                                 HEADING 'DBID'
COLUMN name                   FORMAT a12                    HEADING 'Database|Name'
COLUMN resetlogs_change_num                                 HEADING 'Resetlogs|Change Num'
COLUMN resetlogs              FORMAT a21                    HEADING 'Reset Logs|Date/Time'

SELECT
    rd.db_key
  , rd.dbinc_key
  , rd.dbid
  , rd.name
  , rd.resetlogs_change#                                 resetlogs_change_num
  , TO_CHAR(rd.resetlogs_time, 'DD-MON-YYYY HH24:MI:SS') resetlogs
FROM
    rc_database   rd
ORDER BY
    rd.name
/

