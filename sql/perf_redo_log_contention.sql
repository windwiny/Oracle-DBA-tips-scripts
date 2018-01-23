-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_redo_log_contention.sql                                    |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report on overall redo log contention for the instance since    |
-- |            the instance was last started.                                  |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

prompt
prompt =======================================
prompt Latches
prompt =======================================
prompt 

COLUMN name             FORMAT a30           HEADING 'Latch Name'
COLUMN gets             FORMAT 999,999,999   HEADING 'Gets'
COLUMN misses           FORMAT 999,999,999   HEADING 'Misses'
COLUMN sleeps           FORMAT 999,999,999   HEADING 'Sleeps'
COLUMN immediate_gets   FORMAT 999,999,999   HEADING 'Immediate Gets'
COLUMN immediate_misses FORMAT 999,999,999   HEADING 'Immediate Misses'

BREAK ON report
COMPUTE SUM OF gets             ON report
COMPUTE SUM OF misses           ON report
COMPUTE SUM OF sleeps           ON report
COMPUTE SUM OF immediate_gets   ON report
COMPUTE SUM OF immediate_misses ON report

SELECT 
    INITCAP(name) name
  , gets
  , misses
  , sleeps
  , immediate_gets
  , immediate_misses
FROM  sys.v_$latch
WHERE name LIKE 'redo%'
ORDER BY 1;


prompt
prompt =======================================
prompt System Statistics
prompt =======================================
prompt

COLUMN name    FORMAT a30               HEADING 'Statistics Name'
COLUMN value   FORMAT 999,999,999,999   HEADING 'Value'

SELECT
    name
  , value
FROM
    v$sysstat
WHERE
    name LIKE 'redo%';

