-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : rollback_users.sql                                              |
-- | CLASS    : Rollback Segments                                               |
-- | PURPOSE  : Query all active rollback segments and the sessions that are    |
-- |            using them.                                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Rollback Users                                              |
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

COLUMN rollback_name      FORMAT a25        HEADING 'Rollback Name'
COLUMN sid                FORMAT 999999     HEADING 'SID'
COLUMN serial_id          FORMAT 99999999   HEADING 'Serial ID'
COLUMN session_status     FORMAT a9         HEADING 'Status'
COLUMN oracle_username    FORMAT a18        HEADING 'Oracle User'
COLUMN os_username        FORMAT a18        HEADING 'O/S User'
COLUMN session_machine    FORMAT a30        HEADING 'Machine'          TRUNC
COLUMN session_program    FORMAT a40        HEADING 'Session Program'  TRUNC

SELECT
    r.name              rollback_name
  , s.sid               sid
  , s.serial#           serial_id
  , s.status            session_status
  , s.username          oracle_username
  , s.osuser            os_username
  , s.machine           session_machine
  , s.program           session_program
FROM
    v$lock     l
  , v$rollname r
  , v$session  s
WHERE
      s.sid = l.sid
  AND TRUNC (l.id1(+)/65536) = r.usn
  AND l.type(+) = 'TX'
  AND l.lmode(+) = 6
ORDER BY
    s.sid;

