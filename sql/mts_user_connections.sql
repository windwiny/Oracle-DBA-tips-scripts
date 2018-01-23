-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : mts_user_connections.sql                                        |
-- | CLASS    : Multi-threaded Server (MTS)                                     |
-- | PURPOSE  : Display status and metrics related to MTS user connections.     |
-- |                                                                            |
-- |            NAME     : Returns the dispatcher's name. This forms part of    |
-- |                       the operating system process name.                   |
-- |            USERNAME : Oracle username.                                     |
-- |            STATUS   : Reports the status of the circuit, and may take one  |
-- |                       of the following values:                             |
-- |                       BREAK    : The circuit had been interrupted due to a |
-- |                                  break.                                    |
-- |                       EOF      : The connection is terminating, and the    |
-- |                                  circuit is about to be deleted.           |
-- |                       OUTBOUND : The circuit represents an outbound        |
-- |                                  connection to another database.           |
-- |                       NORMAL   : The circuit represents a normal client    |
-- |                                  connection.                               |
-- |            QUEUE    : Reports on the work currently being done. One the    |
-- |                       following values will be returned:                   |
-- |                       COMMON     : A request has been placed into the      |
-- |                                    common request queue, and the circuit   |
-- |                                    is waiting for it to be picked up be a  |
-- |                                    shared server process.                  |
-- |                       DISPATCHER : Results from a request are being        |
-- |                                    returned to the client by the           |
-- |                                    dispatcher.                             |
-- |                       SERVER     : A request is currently being acted upon |
-- |                                    by a shared server process.             |
-- |                       NONE       : A circuit (or connection) is idle.      |
-- |                                    Nothing is happening.                   |
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
PROMPT | Report   : Multi-threaded Server: User Connections                     |
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

COLUMN instance_name      FORMAT a10    HEAD 'Instance'
COLUMN dispatcher_name    FORMAT a16    HEAD 'Dispatcher Name'
COLUMN s_username         FORMAT a15    HEAD 'Username'
COLUMN c_circuit_status   FORMAT a15    HEAD 'Circuit Status'
COLUMN c_circuit_queue    FORMAT a15    HEAD 'Circuit Queue'

SELECT
    i.instance_name   instance_name
  , d.name            dispatcher_name
  , s.username        s_username
  , c.status          c_circuit_status
  , c.queue           c_circuit_queue
FROM
    gv$instance i
  , gv$circuit     c
  , gv$dispatcher  d
  , gv$session     s
WHERE
      i.inst_id = d.inst_id
  AND c.inst_id = d.inst_id
  AND s.inst_id = d.inst_id
  AND c.dispatcher = d.paddr
  AND c.saddr = s.saddr
ORDER BY
    i.instance_name
  , d.name
  , s.username;

