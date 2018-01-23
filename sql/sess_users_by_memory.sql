-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_users_by_memory.sql                                        |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : List all currently connected user sessions ordered by current   |
-- |            PGA size.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : User Sessions Ordered by Current PGA Size                   |
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

COLUMN sid                      FORMAT 999999         HEADING 'SID'
COLUMN serial_id                FORMAT 99999999       HEADING 'Serial ID'
COLUMN session_status           FORMAT a9             HEADING 'Status'
COLUMN oracle_username          FORMAT a12            HEADING 'Oracle User'
COLUMN os_username              FORMAT a12            HEADING 'O/S User'
COLUMN os_pid                   FORMAT a8             HEADING 'O/S PID'
COLUMN session_machine          FORMAT a20            HEADING 'Machine'          TRUNC
COLUMN session_program          FORMAT a30            HEADING 'Session Program'  TRUNC
COLUMN session_pga_memory       FORMAT 9,999,999,999  HEADING 'PGA Memory'
COLUMN session_pga_memory_max   FORMAT 9,999,999,999  HEADING 'PGA Memory Max'
COLUMN session_uga_memory       FORMAT 9,999,999,999  HEADING 'UGA Memory'
COLUMN session_uga_memory_max   FORMAT 9,999,999,999  HEADING 'UGA Memory MAX'

SELECT
    s.sid             sid
  , s.serial#         serial_id
  , s.status          session_status
  , s.username        oracle_username
  , s.osuser          os_username
  , p.spid            os_pid
  , s.machine         session_machine
  , s.program         session_program
  , sstat1.value      session_pga_memory
  , sstat2.value      session_pga_memory_max
  , sstat3.value      session_uga_memory
  , sstat4.value      session_uga_memory_max
FROM 
    v$process  p
  , v$session  s
  , v$sesstat  sstat1
  , v$sesstat  sstat2
  , v$sesstat  sstat3
  , v$sesstat  sstat4
  , v$statname statname1
  , v$statname statname2
  , v$statname statname3
  , v$statname statname4
WHERE
      p.addr (+)            = s.paddr
  AND s.sid                 = sstat1.sid
  AND s.sid                 = sstat2.sid
  AND s.sid                 = sstat3.sid
  AND s.sid                 = sstat4.sid
  AND statname1.statistic#  = sstat1.statistic#
  AND statname2.statistic#  = sstat2.statistic#
  AND statname3.statistic#  = sstat3.statistic#
  AND statname4.statistic#  = sstat4.statistic#
  AND statname1.name        = 'session pga memory'
  AND statname2.name        = 'session pga memory max'
  AND statname3.name        = 'session uga memory'
  AND statname4.name        = 'session uga memory max'
ORDER BY session_pga_memory DESC
/

