-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : awr_snapshots_dbtime.sql                                        |
-- | CLASS    : Automatic Workload Repository                                   |
-- | PURPOSE  : Provide a list of all AWR snapshots and the total database time |
-- |            (DB Time) consumed within its interval.                         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : AWR Snapshots (DB Time Report)                              |
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

COLUMN instance_name_print  FORMAT a13                   HEADING 'Instance Name'
COLUMN snap_id              FORMAT 9999999               HEADING 'Snap ID'
COLUMN startup_time         FORMAT a21                   HEADING 'Instance Startup Time'
COLUMN begin_interval_time  FORMAT a20                   HEADING 'Begin Interval Time'
COLUMN end_interval_time    FORMAT a20                   HEADING 'End Interval Time'
COLUMN elapsed_time         FORMAT 999,999,999,999.99    HEADING 'Elapsed Time (min)'
COLUMN db_time              FORMAT 999,999,999,999.99    HEADING 'DB Time (min)'
COLUMN pct_db_time          FORMAT 999999999             HEADING '% DB Time'
COLUMN cpu_time             FORMAT 999,999,999.99        HEADING 'CPU Time (min)'

BREAK ON instance_name_print ON startup_time

DEFINE spool_file=awr_snapshots_dbtime.lst

SPOOL &spool_file

SELECT
    i.instance_name                                                                     instance_name_print
  , s.snap_id                                                                           snap_id
  , TO_CHAR(s.startup_time, 'mm/dd/yyyy HH24:MI:SS')                                    startup_time
  , TO_CHAR(s.begin_interval_time, 'mm/dd/yyyy HH24:MI:SS')                             begin_interval_time
  , TO_CHAR(s.end_interval_time, 'mm/dd/yyyy HH24:MI:SS')                               end_interval_time
  , ROUND(EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
          EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
          EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
          EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60, 2)     elapsed_time
  , ROUND((e.value - b.value)/1000000/60, 2)                                            db_time
  , ROUND(((((e.value - b.value)/1000000/60) / (EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
                                                EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
                                                EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
                                                EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60) ) * 100), 2)   pct_db_time
FROM
    dba_hist_snapshot       s
  , gv$instance             i
  , dba_hist_sys_time_model e
  , dba_hist_sys_time_model b
WHERE
      i.instance_number = s.instance_number
  AND e.snap_id         = s.snap_id
  AND b.snap_id         = s.snap_id - 1
  AND e.stat_id         = b.stat_id
  AND e.instance_number = b.instance_number
  AND e.instance_number = s.instance_number
  AND e.stat_name       = 'DB time'
ORDER BY
    i.instance_name
  , s.snap_id;

SPOOL OFF

PROMPT Report written to &spool_file
PROMPT 
