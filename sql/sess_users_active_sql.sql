-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_users_active_sql.sql                                       |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : List all currently connected and active users and the SQL that  |
-- |            they are running.                                               |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : All Active User Sessions and Current SQL                    |
PROMPT | Instance : &current_instance                                           |
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

COLUMN sid               FORMAT 999999     HEADING 'SID'
COLUMN serial_id         FORMAT 99999999   HEADING 'Serial ID'
COLUMN session_status    FORMAT a9         HEADING 'Status'
COLUMN oracle_username   FORMAT a18        HEADING 'Oracle User'
COLUMN os_username       FORMAT a18        HEADING 'O/S User'
COLUMN os_pid            FORMAT a8         HEADING 'O/S PID'
COLUMN session_machine   FORMAT a30        HEADING 'Machine'          TRUNC
COLUMN session_program   FORMAT a40        HEADING 'Session Program'  TRUNC
COLUMN current_sql       FORMAT a85        HEADING 'Current SQL'      FOLD_AFTER WRAP

SELECT
    s.sid                         sid
  , s.serial#                     serial_id
  , s.status                      session_status
  , s.username                    oracle_username
  , s.osuser                      os_username
  , p.spid                        os_pid
  , s.machine                     session_machine
  , s.program                     session_program
  , SUBSTR(sa.sql_text, 1, 1024)  current_sql
FROM 
    v$process p
  , v$session s
  , v$sqlarea sa
WHERE
      p.addr (+)       =  s.paddr
  AND s.sql_address    =  sa.address(+) 
  AND s.sql_hash_value =  sa.hash_value(+)
  AND s.audsid         <> userenv('SESSIONID')
  AND s.username       IS NOT NULL
  AND s.status         = 'ACTIVE'
ORDER BY sid
/

