-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_lru_latch_contention.sql                                   |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : This script will detect latch contention in the db block buffer |
-- |            LRU. The ratio of sleeps/gets should be < 1%.                   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN child_num           HEADING "Child Number"
COLUMN ratio_sleeps_gets   HEADING "Sleeps / Gets Ratio"
COLUMN ratio               HEADING "Ratio"

SELECT
    child#                             child_num
  , ROUND(sleeps/gets * 100,2)         ratio_sleeps_gets
  , ROUND(((1 - sleeps/gets) * 100),2) ratio
FROM
  v$latch_children
WHERE
  name = 'cache buffers lru chain'
/ 

