-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_jobs.sql                                                    |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Provides summary report on all registered and scheduled jobs.   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Oracle Jobs                                                 |
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

COLUMN job        FORMAT 9999999    HEADING 'Job ID'
COLUMN username   FORMAT a20        HEADING 'User'
COLUMN what       FORMAT a30        HEADING 'What'
COLUMN next_date                    HEADING 'Next Run Date'
COLUMN interval   FORMAT a30        HEADING 'Interval'
COLUMN last_date                    HEADING 'Last Run Date'
COLUMN failures                     HEADING 'Failures'
COLUMN broken     FORMAT a7         HEADING 'Broken?'

SELECT
    job
  , log_user username
  , what
  , TO_CHAR(next_date, 'DD-MON-YYYY HH24:MI:SS') next_date
  , interval
  , TO_CHAR(last_date, 'DD-MON-YYYY HH24:MI:SS') last_date
  , failures
  , broken
FROM
    dba_jobs;

