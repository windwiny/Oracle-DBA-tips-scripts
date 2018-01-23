-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_users.sql                                                  |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : List all currently connected users. This script is RAC enabled. |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : User Sessions (All)                                         |
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

COLUMN instance_name     FORMAT a8         HEADING 'Instance'
COLUMN sid               FORMAT 999999     HEADING 'SID'
COLUMN serial_id         FORMAT 99999999   HEADING 'Serial ID'
COLUMN session_status    FORMAT a9         HEADING 'Status'
COLUMN oracle_username   FORMAT a18        HEADING 'Oracle User'
COLUMN os_username       FORMAT a18        HEADING 'O/S User'
COLUMN os_pid            FORMAT a8         HEADING 'O/S PID'
COLUMN session_terminal  FORMAT a10        HEADING 'Terminal'         TRUNC
COLUMN session_machine   FORMAT a30        HEADING 'Machine'          TRUNC
COLUMN session_program   FORMAT a40        HEADING 'Session Program'  TRUNC

BREAK ON instance_name SKIP PAGE

SELECT
    i.instance_name     instance_name
  , s.sid               sid
  , s.serial#           serial_id
  , s.status            session_status
  , s.username          oracle_username
  , s.osuser            os_username
  , p.spid              os_pid
  , s.terminal          session_terminal
  , s.machine           session_machine
  , s.program           session_program
FROM 
             gv$session  s
  INNER JOIN gv$process  p ON (s.paddr = p.addr AND s.inst_id = p.inst_id)
  INNER JOIN gv$instance i ON (p.inst_id = i.inst_id)
ORDER BY
    i.instance_name
  , s.sid;

