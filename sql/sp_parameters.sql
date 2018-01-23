-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sp_parameters.sql                                               |
-- | CLASS    : Statspack                                                       |
-- | PURPOSE  : Provide a report of all Statspack parameters.                   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

COLUMN name               FORMAT a10           HEAD 'Database|Name'
COLUMN snap_level         FORMAT 999999        HEAD 'Snap|Level'
COLUMN num_sql            FORMAT 999,999       HEAD 'Number|SQL'
COLUMN executions_th      FORMAT 999,999       HEAD 'Executions|(TH)'
COLUMN parse_calls_th     FORMAT 999,999       HEAD 'Parse|Calls|(TH)'
COLUMN disk_reads_th      FORMAT 999,999       HEAD 'Disk|Reads|(TH)'
COLUMN buffer_gets_th     FORMAT 999,999       HEAD 'Buffer|Gets|(TH)'
COLUMN sharable_mem_th    FORMAT 999,999,999   HEAD 'Sharable|Mem.|(TH)'
COLUMN version_count_th                        HEAD 'Version|Count|(TH)'
COLUMN pin_statspack                           HEAD 'Pin|Statspack'
COLUMN all_init                                HEAD 'All|Init'
COLUMN last_modified                           HEAD 'Last|Modified'

SELECT
    b.name
  , a.snap_level
  , a.num_sql
  , a.executions_th
  , a.parse_calls_th
  , a.disk_reads_th
  , a.buffer_gets_th
  , a.sharable_mem_th
  , a.version_count_th
  , a.pin_statspack
  , a.all_init
  , TO_CHAR(a.last_modified, 'DD-MON-YYYY HH24:MI:SS') last_modified
FROM
    stats$statspack_parameter  a
  , v$database                 b
/

