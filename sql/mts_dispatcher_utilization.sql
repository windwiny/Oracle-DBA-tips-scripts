-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : mts_dispatcher_utilization.sql                                  |
-- | CLASS    : Multi-threaded Server (MTS)                                     |
-- | PURPOSE  : Display MTS dispatcher utilization. This script is RAC enabled. |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Multi-threaded Server: Dispatcher Utilization               |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN instance_name      FORMAT a10      HEAD 'Instance'
COLUMN dispatcher_name    FORMAT a16      HEAD 'Dispatcher Name'
COLUMN busy               FORMAT 999.99   HEAD '% Busy'

SELECT
    i.instance_name                             instance_name
  , d.name                                      dispatcher_name
  , ROUND(d.busy / (d.busy + d.idle) * 100, 2)  busy
FROM
    gv$instance i
  , gv$dispatcher d
WHERE
    i.inst_id = d.inst_id
ORDER BY
    i.instance_name
  , d.name;

