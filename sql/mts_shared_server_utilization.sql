-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : mts_shared_server_utilization.sql                               |
-- | CLASS    : Multi-threaded Server (MTS)                                     |
-- | PURPOSE  : Display status and metrics related to MTS shared server         |
-- |            utilization. This script is RAC enabled.                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Multi-threaded Server: Shared Server Utilization            |
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

COLUMN instance_name    FORMAT a10    HEAD 'Instance'
COLUMN s_name           FORMAT a25    HEAD 'Server Name'
COLUMN s_busy                         HEAD '% Busy'

SELECT
    i.instance_name                             instance_name
  , s.name                                      s_name
  , ROUND(s.busy / (s.busy + s.idle) * 100, 2)  s_busy
FROM
    gv$instance i
  , gv$shared_server s
WHERE
    i.inst_id = s.inst_id
ORDER BY
    i.instance_name
  , s.name;

