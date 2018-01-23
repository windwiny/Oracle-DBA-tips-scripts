-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : temp_sort_segment.sql                                           |
-- | CLASS    : Temporary_Tablespace                                            |
-- | PURPOSE  : List all temporary tablespaces and details about the actual     |
-- |            sort segment. The statistics that come from the v$sort_segment  |
-- |            view depicts the true space within the temporary segment at     |
-- |            this current time. This script is RAC enabled.                  |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Temporary Sort Segments                                     |
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

COLUMN instance_name              FORMAT a8                 HEADING 'Instance'
COLUMN tablespace_name            FORMAT a15                HEADING 'Tablespace|Name'          JUST right
COLUMN temp_segment_name          FORMAT a8                 HEADING 'Segment|Name'             JUST right
COLUMN current_users              FORMAT 9,999              HEADING 'Current|Users'            JUST right
COLUMN total_temp_segment_size    FORMAT 999,999,999,999    HEADING 'Total Temp|Segment Size'  JUST right
COLUMN currently_used_bytes       FORMAT 999,999,999,999    HEADING 'Currently|Used Bytes'     JUST right
COLUMN pct_used                   FORMAT 999                HEADING 'Pct.|Used'                JUST right
COLUMN extent_hits                FORMAT 999,999            HEADING 'Extent|Hits'              JUST right
COLUMN max_size                   FORMAT 999,999,999,999    HEADING 'Max|Size'                 JUST right
COLUMN max_used_size              FORMAT 999,999,999,999    HEADING 'Max Used|Size'            JUST right
COLUMN max_sort_size              FORMAT 999,999,999,999    HEADING 'Max Sort|Size'            JUST right
COLUMN free_requests              FORMAT 999                HEADING 'Free|Requests'            JUST right

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Segment Name            : The segment name is a concatenation of the   |
PROMPT |                           SEGMENT_FILE (File number of the first       |
PROMPT |                           extent) and the SEGMENT_BLOCK (Block number  |
PROMPT |                           of the first extent)                         |
PROMPT | Current Users           : Number of active users of the segment        |
PROMPT | Total Temp Segment Size : Total size of the temporary segment in bytes |
PROMPT | Currently Used Bytes    : Bytes allocated to active sorts              |
PROMPT | Extent Hits             : Number of times an unused extent was found   |
PROMPT |                           in the pool                                  |
PROMPT | Max Size                : Maximum number of bytes ever used            |
PROMPT | Max Used Size           : Maximum number of bytes used by all sorts    |
PROMPT | Max Sort Size           : Maximum number of bytes used by an           |
PROMPT |                           individual sort                              |
PROMPT | Free Requests           : Number of requests to de-allocate            |
PROMPT +------------------------------------------------------------------------+

BREAK ON instance_name SKIP PAGE

SELECT
    i.instance_name               instance_name
  , t.tablespace_name             tablespace_name
  , 'SYS.'          || 
    t.segment_file  ||
    '.'             || 
    t.segment_block               temp_segment_name
  , t.current_users               current_users
  , (t.total_blocks*b.value)      total_temp_segment_size
  , (t.used_blocks*b.value)       currently_used_bytes
  , TRUNC(ROUND((t.used_blocks/t.total_blocks)*100))    pct_used
  , t.extent_hits                 extent_hits
  , (t.max_blocks*b.value)        max_size
  , (t.max_used_blocks*b.value)   max_used_size
  , (t.max_sort_blocks *b.value)  max_sort_size
  , t.free_requests               free_requests
FROM
    gv$instance                     i
  , gv$sort_segment                 t
  , (select value from v$parameter
     where name = 'db_block_size')  b
WHERE
    t.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , t.tablespace_name;

