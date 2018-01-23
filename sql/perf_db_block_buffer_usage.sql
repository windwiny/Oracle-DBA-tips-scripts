-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_db_block_buffer_usage.sql                                  |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report on the state of all DB_BLOCK_BUFFERS. This script must   |
-- |            be run as the SYS user.                                         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 135
SET PAGESIZE 9999
SET VERIFY   off

COLUMN block_status      HEADING "Block Status"
COLUMN count             HEADING "Count"

SELECT
    DECODE(state, 0, 'Free',
                  1, DECODE(lrba_seq, 0, 'Available', 'Being Modified'),
                  2, 'Not Modified',
                  3, 'Being Read',
                     'Other') block_status
  , count(*) count
FROM
  sys.x$bh
GROUP BY
    DECODE(state, 0, 'Free',
                  1, DECODE(lrba_seq, 0, 'Available', 'Being Modified'),
                  2, 'Not Modified',
                  3, 'Being Read',
                     'Other')
/

