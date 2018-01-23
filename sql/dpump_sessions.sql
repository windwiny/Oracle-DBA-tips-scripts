-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dpump_sessions.sql                                              |
-- | CLASS    : Data Pump                                                       |
-- | PURPOSE  : Query all Data Pump jobs and session information.               |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Data Pump Sessions                                          |
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

COLUMN instance_name     FORMAT a9         HEADING 'Instance'
COLUMN owner_name        FORMAT a15        HEADING 'Owner Name'
COLUMN job_name          FORMAT a20        HEADING 'Job Name'
COLUMN session_type      FORMAT a15        HEADING 'Session Type'
COLUMN sid               FORMAT 999999     HEADING 'SID'
COLUMN serial_id         FORMAT 99999999   HEADING 'Serial ID'
COLUMN oracle_username   FORMAT a18        HEADING 'Oracle User'
COLUMN os_username       FORMAT a18        HEADING 'O/S User'
COLUMN os_pid            FORMAT a8         HEADING 'O/S PID'

BREAK ON report ON instance_name_print ON owner_name ON job_name

SELECT
    i.instance_name    instance_name
  , dj.owner_name      owner_name 
  , dj.job_name        job_name
  , ds.type            session_type
  , s.sid              sid
  , s.serial#          serial_id
  , s.username         oracle_username
  , s.osuser           os_username
  , p.spid             os_pid
FROM
    gv$datapump_job         dj
  , gv$datapump_session     ds
  , gv$session              s
  , gv$instance             i
  , gv$process              p
WHERE
      s.inst_id  = i.inst_id
  AND s.inst_id  = p.inst_id
  AND ds.inst_id = i.inst_id
  AND dj.inst_id = i.inst_id
  AND s.saddr    = ds.saddr
  AND s.paddr    = p.addr (+)
  AND dj.job_id  = ds.job_id
ORDER BY
    i.instance_name
  , dj.owner_name
  , dj.job_name
  , ds.type;
