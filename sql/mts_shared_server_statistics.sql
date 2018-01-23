-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : mts_shared_server_statistics.sql                                |
-- | CLASS    : Multi-threaded Server (MTS)                                     |
-- | PURPOSE  : Display status and metrics related to MTS shared server         |
-- |            statistics.                                                     |
-- |                                                                            |
-- |            SERVERS_STARTED    : The number of shared server processes      |
-- |                                 started as the instance adjusts the number |
-- |                                 of shared processes up and down from the   |
-- |                                 initial value specified by the MTS_SERVERS |
-- |                                 parameter. When the instance starts, and   |
-- |                                 after the initial number of shared server  |
-- |                                 processes processes specified by           |
-- |                                 MTS_SERVERS has been started, this value   |
-- |                                 is set to 0. From that point on, this      |
-- |                                 value is incremented whenever a new shared |
-- |                                 server process is started.                 |
-- |            SERVERS_TERMINATED : A count of the total number of shared      |
-- |                                 server processes that have been terminated |
-- |                                 since the instance was started.            |
-- |            SERVERS_HIGHWATER  : The maximum number of shared server        |
-- |                                 processes that have ever been running at   |
-- |                                 one moment in time.                        |
-- |                                                                            |
-- |            NOTES: If the SERVERS_HIGHWATER value matches, the instance's   |
-- |                   MTS_MAX_SERVERS value, then you might realize a          |
-- |                   performance benefit from increasing MTS_MAX_SERVERS. If  |
-- |                   the counts for SERVERS_STARTED and SERVERS_TERMINATED    |
-- |                   keep climbing, then you should consider raising          |
-- |                   MTS_SERVERS. Raising the minimum number of shared server |
-- |                   processes should reduce the number that are deleted only |
-- |                   to be recreated later.                                   |
-- |                                                                            |
-- |            This script is RAC enabled.                                     |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Multi-threaded Server: Shared Server Statistics             |
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

COLUMN instance_name        FORMAT a10              HEAD 'Instance'
COLUMN servers_started      FORMAT 999,999,999      HEAD 'Servers Started'
COLUMN servers_terminated   FORMAT 999,999,999      HEAD 'Servers Terminated'
COLUMN servers_highwater    FORMAT 999,999,999      HEAD 'Servers Highwater'

SELECT
    i.instance_name           instance_name
  , s.servers_started         servers_started
  , s.servers_terminated      servers_terminated
  , s.servers_highwater       servers_highwater
FROM
    gv$instance i
  , gv$shared_server_monitor s
WHERE
    i.inst_id = s.inst_id
ORDER BY
    i.instance_name;

