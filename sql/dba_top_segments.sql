-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_top_segments.sql                                            |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Provides a report on the top segments (in bytes) grouped by     |
-- |            Segment Type.                                                   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Top Segments                                                |
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

COLUMN segment_type        FORMAT A20                HEADING 'Segment Type'
COLUMN owner               FORMAT A15                HEADING 'Owner'
COLUMN segment_name        FORMAT A30                HEADING 'Segment Name'
COLUMN partition_name      FORMAT A30                HEADING 'Partition Name'
COLUMN tablespace_name     FORMAT A20                HEADING 'Tablespace Name'
COLUMN bytes               FORMAT 9,999,999,999,999  HEADING 'Size (in bytes)'
COLUMN extents             FORMAT 999,999,999        HEADING 'Extents'

BREAK ON segment_type SKIP 1

COMPUTE sum OF bytes ON segment_type

SELECT
    a.segment_type      segment_type
  , a.owner             owner
  , a.segment_name      segment_name
  , a.partition_name    partition_name
  , a.tablespace_name   tablespace_name
  , a.bytes             bytes
  , a.extents           extents
FROM
    (select
         b.segment_type
       , b.owner
       , b.segment_name
       , b.partition_name
       , b.tablespace_name
       , b.bytes
       , b.extents
     from
         dba_segments b
     order by
         b.bytes desc
    ) a
WHERE
    rownum < 101
ORDER BY
    segment_type, bytes desc, owner, segment_name
/

