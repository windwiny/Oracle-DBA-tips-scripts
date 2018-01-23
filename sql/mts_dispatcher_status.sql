-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : mts_dispatcher_status.sql                                       |
-- | CLASS    : Multi-threaded Server (MTS)                                     |
-- | PURPOSE  : Display status and metrics related to the MTS dispatcher. The   |
-- |            following notes provide information on how to read and interpret|
-- |            the results of this query:                                      |
-- |                                                                            |
-- |            NAME       : Returns the dispatcher's name. This forms part of  |
-- |                         the operating system process name.                 |
-- |            STATUS       WAIT       : The dispatcher is idle and waiting    |
-- |                                      for work.                             |
-- |                         SEND       : The dispatcher is sending a message.  |
-- |                         RECEIVE    : The dispatcher is receiving a message.|
-- |                         CONNECT    : The dispatcher is establishing a new  |
-- |                                      connection from a client.             |
-- |                         DISCONNECT : A client is disconnecting from the    |
-- |                                      dispatcher.                           |
-- |                         BREAK      : The dispatcher is handling a break.   |
-- |                         OUTBOUND   : The dispatcher is establishing an     |
-- |                                      outbound connection.                  |
-- |            ACCEPT     : Tells you whether or not the dispatcher is         |
-- |                         accepting new connections. Valid values are YES    |
-- |                         and NO.                                            |
-- |            CREATED    : Returns the number of virtual circuits currently   |
-- |                         associated with this dispatcher.                   |
-- |            CONFIG IDX : Indicates the specific MTS_DISPATCHERS             |
-- |                         initialization parameter on which this dispatcher  |
-- |                         is based. Dispatchers created from the first       |
-- |                         MTS_DISPATCHERS parameter in your instance's       |
-- |                         parameter file will have a CONF_INDX value of 0.   |
-- |                         Dispatcher's created from the second               |
-- |                         MTS_DISPATCHERS parameter will have a value of 1,  |
-- |                         and so on.                                         |
-- |            NETWORK    : Returns the dispatcher's network address.          |
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
PROMPT | Report   : Multi-threaded Server: Dispatcher Status                    |
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
COLUMN dispatcher_status  FORMAT a10      HEAD 'Status'
COLUMN accept             FORMAT a10      HEAD 'Accept'
COLUMN created                            HEAD 'Created'
COLUMN conf_indx                          HEAD 'Config. Index'
COLUMN network            FORMAT a70      HEAD 'Network'

SELECT
    i.instance_name   instance_name
  , d.name            dispatcher_name
  , d.status          dispatcher_status
  , d.accept          accept
  , d.created         created
  , d.conf_indx       conf_indx
  , d.network         network
FROM
    gv$instance i
  , gv$dispatcher d
WHERE
    i.inst_id = d.inst_id
ORDER BY
    i.instance_name
  , d.name;

