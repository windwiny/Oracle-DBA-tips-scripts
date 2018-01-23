-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : asmm_components.sql                                             |
-- | CLASS    : Automatic Shared Memory Management                              |
-- | PURPOSE  : Provide a summary report of all dynamic components as part of   |
-- |            Oracle's ASMM configuration.                                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ASMM Components                                             |
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

COLUMN component             FORMAT a25              HEAD 'Component Name'
COLUMN current_size          FORMAT 9,999,999,999    HEAD 'Current Size'
COLUMN min_size              FORMAT 9,999,999,999    HEAD 'Min Size'
COLUMN max_size              FORMAT 9,999,999,999    HEAD 'Max Size'
COLUMN user_specified_size   FORMAT 9,999,999,999    HEAD 'User Specified|Size'
COLUMN oper_count            FORMAT 9,999            HEAD 'Oper.|Count'
COLUMN last_oper_type        FORMAT a10              HEAD 'Last Oper.|Type'
COLUMN last_oper_mode        FORMAT a10              HEAD 'Last Oper.|Mode'
COLUMN last_oper_time        FORMAT a20              HEAD 'Last Oper.|Time'
COLUMN granule_size          FORMAT 999,999,999      HEAD 'Granule Size'

SELECT
    component
  , current_size
  , min_size
  , max_size
  , user_specified_size
  , oper_count
  , last_oper_type
  , last_oper_mode
  , TO_CHAR(last_oper_time, 'DD-MON-YYYY HH24:MI:SS') last_oper_time
  , granule_size
FROM
    v$sga_dynamic_components
ORDER BY
    component DESC
/

