-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : locks_dml_ddl.sql                                               |
-- | CLASS    : Locks                                                           |
-- | PURPOSE  : Query all DML and DDL locks in the database. This script will   |
-- |            query critical information about the lock including Lock Type,  |
-- |            Object Name/Owner, OS/Oracle User and Wait time (in minutes).   |
-- |            This script is not RAC enabled and will only display locks on   |
-- |            the current instance.                                           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DML and DDL Locks                                           |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    256
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN instance_name                FORMAT a9           HEADING 'Instance'
COLUMN sid_serial                   FORMAT a15          HEADING 'SID / Serial#'
COLUMN session_status               FORMAT a9           HEADING 'Status'
COLUMN locking_oracle_user          FORMAT a20          HEADING 'Locking Oracle User'
COLUMN lock_type                    FORMAT a9           HEADING 'Lock Type'
COLUMN mode_held                    FORMAT a10          HEADING 'Mode Held'
COLUMN object                       FORMAT a42          HEADING 'Object'
COLUMN program                      FORMAT a20          HEADING 'Program'
COLUMN wait_time_min                FORMAT 999,999      HEADING 'Wait Time (min)'

CLEAR BREAKS

SELECT
    i.instance_name                                 instance_name
  , l.session_id || ' / ' || s.serial#              sid_serial
  , s.status                                        session_status
  , s.username                                      locking_oracle_user
  , l.lock_type                                     lock_type
  , l.mode_held                                     mode_held
  , o.owner || '.' || o.object_name                 object
  , SUBSTR(s.program, 0, 20)                        program
  , ROUND(w.seconds_in_wait/60, 2)                  wait_time_min
FROM
    v$instance      i
  , v$session       s
  , dba_locks       l
  , dba_objects     o
  , v$session_wait  w
WHERE 
      s.sid = l.session_id
  AND l.lock_type IN ('DML','DDL')
  AND l.lock_id1 = o.object_id
  AND l.session_id = w.sid
ORDER BY
    i.instance_name
  , l.session_id
/

