-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_waiting.sql                                                |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : This script produces a report of the top sessions that have     |
-- |            waited (the entries at top have waited the longest) for         |
-- |            non-idle wait events (event column). The Oracle Server          |
-- |            Reference Manual can be used to further diagnose the wait event |
-- |            (along with its parameters). Metalink can also be used by       |
-- |            supplying the event name in the search bar.                     |
-- |                                                                            |
-- |            The INST_ID column shows the instance where the session resides |
-- |            and the SID is the unique identifier for the session            |
-- |            (gv$session). The p1, p2, and p3 columns will show event        |
-- |            specific information that may be important to debug the         |
-- |            problem.                                                        |
-- | EXAMPLE  : For example, you can search Metalink by supplying the event     |
-- | METALINK : name (surrounded by single quotes) as in the following example: |
-- | SEARCH   :                                                                 |
-- |                          [ 'Sync ASM rebalance' ]                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Session Waits                                               |
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

COLUMN instance_name     FORMAT a9            HEADING 'Instance'
COLUMN sid               FORMAT 999999        HEADING 'SID'
COLUMN serial_id         FORMAT 99999999      HEADING 'Serial ID'
COLUMN session_status    FORMAT a9            HEADING 'Status'
COLUMN oracle_username   FORMAT a20           HEADING 'Oracle User'
COLUMN state             FORMAT a8            HEADING 'State'
COLUMN event             FORMAT a25           HEADING 'Event'
COLUMN wait_time_sec     FORMAT 999,999,999   HEADING 'Wait Time (sec)'
COLUMN last_sql          FORMAT a45           HEADING 'Last SQL'

SELECT
    i.instance_name                 instance_name
  , s.sid                           sid
  , s.serial#                       serial_id
  , s.username                      oracle_username
  , sw.state                        state
  , sw.event                        event
  , sw.seconds_in_wait              wait_time_sec
  , sa.sql_text                     last_sql
FROM
    gv$session_wait sw
  , gv$session s
  , gv$sqlarea sa
  , gv$instance i
WHERE
      sw.event NOT IN (   'rdbms ipc message'
                        , 'smon timer'
                        , 'pmon timer'
                        , 'SQL*Net message from client'
                        , 'lock manager wait for remote message'
                        , 'ges remote message'
                        , 'gcs remote message'
                        , 'gcs for action'
                        , 'client message'
                        , 'pipe get'
                        , 'null event'
                        , 'PX Idle Wait'
                        , 'single-task message'
                        , 'PX Deq: Execution Msg'
                        , 'KXFQ: kxfqdeq - normal deqeue'
                        , 'listen endpoint status'
                        , 'slave wait'
                        , 'wakeup time manager'
                      )
  AND sw.seconds_in_wait > 0 
  AND sw.inst_id = s.inst_id
  AND sw.sid = s.sid
  AND s.inst_id = sa.inst_id
  AND s.sql_address = sa.address
  AND s.inst_id = i.inst_id
ORDER BY
    wait_time_sec DESC
  , i.instance_name;

