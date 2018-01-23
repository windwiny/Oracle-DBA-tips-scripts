-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_sga_usage.sql                                              |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report on all components within the SGA.                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET FEEDBACK off
SET VERIFY   off

COLUMN bytes   FORMAT  999,999,999
COLUMN percent FORMAT  999.99999

break on report

compute sum of bytes on report
compute sum of percent on report

SELECT
    a.name
  , a.bytes
  , a.bytes/(b.sum_bytes*100)  Percent  
FROM sys.v_$sgastat a
   , (SELECT SUM(value)sum_bytes FROM sys.v_$sga) b 
ORDER BY bytes DESC
/

