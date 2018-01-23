-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_hit_ratio_system.sql                                       |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Reports buffer cache hit ratio.                                 |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SELECT
    TO_CHAR(SUM(DECODE(name, 'consistent gets', value, 0)), 
            '999,999,999,999,999,999') con
  , TO_CHAR(SUM(DECODE(name, 'db block gets'  , value, 0)), 
            '999,999,999,999,999,999') dbblockgets
  , TO_CHAR(SUM(DECODE(name, 'physical reads' , value, 0)), 
            '999,999,999,999,999,999') physrds
  , ROUND( ( ( 
               SUM(DECODE(name, 'consistent gets', Value,0))
               + 
               SUM(DECODE(name, 'db block gets', value,0)) 
               -
               SUM(DECODE(name, 'physical reads', value,0))
             ) 
             /
             (
               SUM(DECODE(name, 'consistent gets', Value,0))
               +
               SUM(DECODE(name, 'db block gets', Value,0))
             )
           ) *100,2
         ) Hitratio
FROM v$sysstat
/

