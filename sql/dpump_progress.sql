-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dpump_progress.sql                                              |
-- | CLASS    : Data Pump                                                       |
-- | PURPOSE  : Display the progress of Data Pump job.                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Data Pump Job Progress                                      |
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

COLUMN instance_name     FORMAT a9                  HEADING 'Instance|Name'
COLUMN owner_name        FORMAT a15                 HEADING 'Owner|Name'
COLUMN job_name          FORMAT a20                 HEADING 'Job|Name'
COLUMN session_type      FORMAT a8                  HEADING 'Session|Type'
COLUMN start_time        FORMAT a19                 HEADING 'Start|Time'
COLUMN time_remaining    FORMAT 9,999,999,999       HEADING 'Time|Remaining (min.)'
COLUMN sofar             FORMAT 9,999,999,999,999   HEADING 'Bytes Completed|So Far'
COLUMN totalwork         FORMAT 9,999,999,999,999   HEADING 'Total Bytes|for Job'
COLUMN pct_completed     FORMAT a10                 HEADING 'Percent|Completed'

BREAK ON report ON instance_name_print ON owner_name ON job_name

SELECT
    i.instance_name                                        instance_name
  , dj.owner_name                                          owner_name 
  , dj.job_name                                            job_name
  , ds.type                                                session_type
  , TO_CHAR(sl.start_time,'mm/dd/yyyy HH24:MI:SS')         start_time
  , ROUND(sl.time_remaining/60,0)                          time_remaining
  , sl.sofar                                               sofar
  , sl.totalwork                                           totalwork
  , TRUNC(ROUND((sl.sofar/sl.totalwork) * 100, 1)) || '%'  pct_completed
FROM
    gv$datapump_job         dj
  , gv$datapump_session     ds
  , gv$session              s
  , gv$instance             i
  , gv$session_longops      sl
WHERE
      s.inst_id  = i.inst_id
  AND ds.inst_id = i.inst_id
  AND dj.inst_id = i.inst_id
  AND sl.inst_id = i.inst_id
  AND s.saddr    = ds.saddr
  AND dj.job_id  = ds.job_id
  AND sl.sid     = s.sid
  AND sl.serial# = s.serial#
  AND ds.type    = 'MASTER'
ORDER BY
    i.instance_name
  , dj.owner_name
  , dj.job_name
  , ds.type;
