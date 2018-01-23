-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_hit_ratio_by_session.sql                                   |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Reports on all sessions along with their individual hit ratio.  |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 180
SET PAGESIZE 9999

COLUMN unix_id          FORMAT a10                  HEAD Username
COLUMN oracle_id        FORMAT a10                  HEAD OracleID
COLUMN os_user          FORMAT a20                  HEAD OS_User
COLUMN sid              FORMAT 99999                HEAD SID
COLUMN serial_id        FORMAT 999999               HEAD Serial#
COLUMN unix_pid         FORMAT a9                   HEAD UNIX_Pid
COLUMN consistent_gets  FORMAT 999,999,999,999,999  HEAD Cons_Gets
COLUMN block_gets       FORMAT 999,999,999,999,999  HEAD Block_Gets
COLUMN physical_reads   FORMAT 999,999,999,999,999  HEAD Phys_Reads
COLUMN hit_ratio        FORMAT 999.00               HEAD Hit_Ratio

SELECT
    p.username            unix_id
  , s.username            oracle_id
  , s.osuser              os_user
  , s.sid                 sid
  , s.serial#             serial_id
  , LPAD(p.spid,7)        unix_pid
  , sio.consistent_gets   consistent_gets
  , sio.block_gets        block_gets
  , sio.physical_reads    physical_reads
  , ROUND((consistent_gets+Block_gets-Physical_reads) /
          (Consistent_gets+Block_gets)*100,2)             hit_ratio
FROM
    v$process p
  , v$session s
  , v$sess_io sio
WHERE
      p.addr (+) = s.paddr
  AND s.sid      = sio.sid
  AND (sio.consistent_gets + sio.block_gets) > 0
  AND s.username is not null
ORDER BY hit_ratio
/

