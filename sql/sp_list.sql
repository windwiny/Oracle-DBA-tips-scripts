-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sp_list.sql                                                     |
-- | CLASS    : Statspack                                                       |
-- | PURPOSE  : Provide a summary report of all Statspack snapshot IDs.         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

COLUMN snap_id                        HEAD 'Snap ID'
COLUMN startup_time     FORMAT a25    HEAD 'Startup Time'
COLUMN snap_time        FORMAT a25    HEAD 'Snap Time'

BREAK on startup_time SKIP 1

SELECT
    a.snap_id
  , TO_CHAR(a.startup_time, 'DD-MON-YYYY HH24:MI:SS')  startup_time
  , TO_CHAR(a.snap_time, 'DD-MON-YYYY HH24:MI:SS')     snap_time
FROM
    stats$snapshot  a
  , v$database      b
ORDER BY
    snap_id
/

