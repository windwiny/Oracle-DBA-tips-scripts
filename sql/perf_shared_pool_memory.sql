-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_shared_pool_memory.sql                                     |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Query the total memory in the Shared Pool and the amount of     |
-- |            free memory.                                                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN value       FORMAT 999,999,999,999 HEADING "Shared Pool Size"
COLUMN bytes       FORMAT 999,999,999,999 HEADING "Free Bytes"
COLUMN percentfree FORMAT 999             HEADING "Percent Free"

SELECT
    TO_NUMBER(p.value)       value
  , s.bytes                  bytes
  , (s.bytes/p.value) * 100  percentfree
FROM
    v$sgastat    s
  , v$parameter  p
WHERE
      s.name = 'free memory'
  AND s.pool = 'shared pool'
  AND p.name = 'shared_pool_size'
/

