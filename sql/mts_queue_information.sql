-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : mts_queue_information.sql                                       |
-- | CLASS    : Multi-threaded Server (MTS)                                     |
-- | PURPOSE  : Display status and metrics related to MTS queue information.    |
-- |            You can get an idea of how well work is flowing through the     |
-- |            request and response queues by using v$queue. The DECODE in the |
-- |            query handles the case where the TOTALQ column, which is the    |
-- |            divisor, happens to be zero.                                    |
-- |                                                                            |
-- |            The average wait time is reported in hundreths of a second.     |
-- |            (i.e. If the average wait time of a dispatcher is 37, works out |
-- |                  to 0.37 seconds.)                                         |
-- |                                                                            |
-- |            The COMMON queue is where requests are placed so that they can  |
-- |            be picked up and executed by a shared server process. If you    |
-- |            average wait time is high, you might be able to lower it by     |
-- |            creating more shared server processes.                          |
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
PROMPT | Report   : Multi-threaded Server: Queue Information                    |
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
COLUMN queue_type         FORMAT a13      HEAD 'Queue Type'
COLUMN queued                             HEAD 'Queued'
COLUMN awt                FORMAT 999.99   HEAD 'Average_Wait_Time'

SELECT
    i.instance_name                       instance_name
  , d.name                                dispatcher_name
  , q.type                                queue_type
  , q.queued                              queued
  , DECODE(q.totalq,0,0,q.wait/q.totalq)  awt
FROM
    gv$instance i
  , gv$queue q
  , gv$dispatcher d
WHERE
      i.inst_id = q.inst_id
  AND d.inst_id = q.inst_id
  AND d.paddr = q.paddr
ORDER BY
    i.instance_name
  , d.name;

