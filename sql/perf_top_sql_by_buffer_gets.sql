-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_top_sql_by_buffer_gets.sql                                 |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report on top SQL statements ordered by most buffer gets.       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN username        FORMAT a18                  HEADING 'Username'
COLUMN buffer_gets     FORMAT 999,999,999,999,999  HEADING 'Buffer Gets'
COLUMN executions      FORMAT 999,999,999,999,999  HEADING 'Executions'
COLUMN gets_per_exec   FORMAT 999,999,999,999,999  HEADING 'Gets / Executions'
COLUMN sql                                         HEADING 'SQL Statement'

BREAK ON report
COMPUTE sum OF buffer_gets    ON report
COMPUTE sum OF executions     ON report
COMPUTE sum OF gets_per_exec  ON report

prompt 
prompt =============================================
prompt SQL with buffer gets greater than 1000
prompt =============================================


SELECT
    UPPER(b.username)                                        username
  , a.buffer_gets                                            buffer_gets
  , a.executions                                             executions
  , a.buffer_gets / decode(a.executions, 0, 1, a.executions) gets_per_exec
  , sql_text || chr(10) || chr(10)                           sql 
FROM 
    sys.v_$sqlarea a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id 
  AND a.buffer_gets > 1000
  AND b.username NOT IN ('SYS','SYSTEM')
ORDER BY
    buffer_gets desc;

