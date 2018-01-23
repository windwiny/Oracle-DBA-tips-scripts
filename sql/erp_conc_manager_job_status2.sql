-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : erp_conc_manager_job_status.sql                                 |
-- | CLASS    : Oracle Applications                                             |
-- | PURPOSE  : Reports on concurrent manager job status.                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Concurrent Manager Job Status                               |
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

COLUMN start_time   FORMAT a20          HEADING "Start|Time"
COLUMN program_name FORMAT a50          HEADING "Program|Name"
COLUMN reqid        FORMAT 9999999999   HEADING "Request|ID"
COLUMN tot_mins     FORMAT 9999999      HEADING "Total|Run-Time|in Mins"
COLUMN hrs          FORMAT 99999        HEADING "Running|Hrs"
COLUMN mins         FORMAT 99999        HEADING "Running|Mins"
COLUMN secs         FORMAT 99999        HEADING "Running|Secs"
COLUMN user_name    FORMAT a18          HEADING "User|Name"
COLUMN oracle_sid   FORMAT 99999        HEADING "Oracle|SID"
COLUMN serial#      FORMAT 9999999      HEADING "Serial|#"
COLUMN phase        FORMAT a5           HEADING "Phase|Code"
COLUMN status       FORMAT a6           HEADING "Status|Code"

SELECT
    r.request_id                                            reqid
  , TO_CHAR(r.actual_start_date, 'DD-MON-YYYY HH24:MI:SS')  start_time
  , u.user_name                                             user_name
  , r.phase_code                                            phase
  , r.status_code                                           status
  , FLOOR(((SYSDATE - r.actual_start_date)*24*60*60)/3600)  hrs
  , FLOOR((((SYSDATE - r.actual_start_date)*24*60*60) - FLOOR(((SYSDATE - r.actual_start_date)*24*60*60)/3600)*3600)/60) mins
  , ROUND((((SYSDATE - r.actual_start_date)*24*60*60) - FLOOR(((SYSDATE - r.actual_start_date)*24*60*60)/3600)*3600 - (FLOOR((((SYSDATE - r.actual_start_date)*24*60*60) - FLOOR(((SYSDATE - r.actual_start_date)*24*60*60)/3600)*3600)/60)*60) )) secs
  , (SYSDATE - r.actual_start_date)*24*60                   tot_mins
  , /* p.concurrent_program_id progid,*/
    DECODE(   p.user_concurrent_program_name
            , 'Request Set Stage', 'RSS - '||r.description
            , 'Report Set', 'RS - '||r.description
            , p.user_concurrent_program_name )              program_name
  , s.sid                                                   oracle_sid
  , s.serial#
FROM
    v$session s
  , apps.fnd_user u
  , apps.fnd_concurrent_processes pr
  , apps.fnd_concurrent_programs_vl p
  , apps.fnd_concurrent_requests r
WHERE
      s.process = pr.os_process_id
  AND pr.concurrent_process_id = r.controlling_manager
  AND r.phase_code = 'R' -- and r.status_code = 'R'
  AND r.requested_by = u.user_id
  AND p.concurrent_program_id = r.concurrent_program_id
ORDER BY
    1
/

