-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_users_by_cursors.sql                                       |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : List all currently connected user sessions ordered by the       |
-- |            number of current open cursors within their session.            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : User Sessions Ordered by Number of Open Cursors             |
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

COLUMN sid               FORMAT 999999            HEADING 'SID'
COLUMN serial_id         FORMAT 99999999          HEADING 'Serial ID'
COLUMN session_status    FORMAT a9                HEADING 'Status'
COLUMN oracle_username   FORMAT a18               HEADING 'Oracle User'
COLUMN os_username       FORMAT a18               HEADING 'O/S User'
COLUMN os_pid            FORMAT a8                HEADING 'O/S PID'
COLUMN session_machine   FORMAT a30               HEADING 'Machine'          TRUNC
COLUMN session_program   FORMAT a40               HEADING 'Session Program'  TRUNC
COLUMN open_cursors      FORMAT 99,999            HEADING 'Open Cursors'
COLUMN open_pct          FORMAT 999               HEADING 'Open %'

SELECT
    s.sid                             sid
  , s.serial#                         serial_id
  , s.status                          session_status
  , s.username                        oracle_username
  , s.osuser                          os_username
  , p.spid                            os_pid
  , s.machine                         session_machine
  , s.program                         session_program
  , sstat.value                       open_cursors
  , ROUND((sstat.value/u.value)*100)  open_pct
FROM 
    v$process  p
  , v$session  s
  , v$sesstat  sstat
  , v$statname statname
  , (select name, value
     from v$parameter) u
WHERE
      p.addr (+)          = s.paddr
  AND s.sid               = sstat.sid
  AND statname.statistic# = sstat.statistic#
  AND statname.name       = 'opened cursors current'
  AND u.name              = 'open_cursors'
ORDER BY open_cursors DESC
/

