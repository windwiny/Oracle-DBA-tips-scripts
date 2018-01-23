-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_top_sql_by_disk_reads.sql                                  |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report on top SQL statements ordered by disk reads.             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN username        FORMAT a18                  HEADING 'Username'
COLUMN disk_reads      FORMAT 999,999,999,999,999  HEADING 'Disk Reads'
COLUMN executions      FORMAT 999,999,999,999,999  HEADING 'Executions'
COLUMN reads_per_exec  FORMAT 999,999,999,999,999  HEADING 'Reads / Executions'
COLUMN sql                                         HEADING 'SQL Statement'

BREAK ON report
COMPUTE sum OF disk_reads     ON report
COMPUTE sum OF executions     ON report
COMPUTE sum OF reads_per_exec ON report

prompt 
prompt =============================================
prompt SQL with disk reads greater than 1000
prompt =============================================

SELECT
    UPPER(b.username)                                       username
  , a.disk_reads                                            disk_reads
  , a.executions                                            executions
  , a.disk_reads / decode(a.executions, 0, 1, a.executions) reads_per_exec
  , sql_text || chr(10) || chr(10)                          sql 
FROM 
    sys.v_$sqlarea a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id 
  AND a.disk_reads > 1000
  AND b.username NOT IN ('SYS','SYSTEM')
ORDER BY
    disk_reads desc;
