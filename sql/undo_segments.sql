-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : undo_segments.sql                                               |
-- | CLASS    : Undo Segments                                                   |
-- | PURPOSE  : Reports undo statistic information including name, shrinks,     |
-- |            wraps, size and optimal size. This script is RAC enabled.       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Undo Segments                                               |
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

COLUMN instance_name  FORMAT a9               HEADING 'Instance'
COLUMN undo_name      FORMAT a30              HEADING 'Undo Name'
COLUMN tablespace     FORMAT a11              HEADING 'Tablspace'
COLUMN in_extents     FORMAT a23              HEADING 'Init / Next Extents'
COLUMN m_extents      FORMAT a23              HEADING 'Min / Max Extents'
COLUMN status         FORMAT a8               HEADING 'Status'
COLUMN wraps          FORMAT 99,999           HEADING 'Wraps' 
COLUMN shrinks        FORMAT 99,999           HEADING 'Shrinks'
COLUMN opt            FORMAT 999,999,999,999  HEADING 'Opt. Size'
COLUMN bytes          FORMAT 999,999,999,999  HEADING 'Bytes'
COLUMN extents        FORMAT 999              HEADING 'Extents'

BREAK ON instance_name SKIP 2

COMPUTE SUM LABEL 'Total: ' OF bytes ON instance_name

SELECT
    i.instance_name                           instance_name
  , a.owner || '.' || a.segment_name          undo_name
  , a.tablespace_name                         tablespace
  , TRIM(TO_CHAR(a.initial_extent, '999,999,999,999')) || ' / ' ||
    TRIM(TO_CHAR(a.next_extent, '999,999,999,999'))                    in_extents
  , TRIM(TO_CHAR(a.min_extents, '999,999,999,999'))    || ' / ' ||
    TRIM(TO_CHAR(a.max_extents, '999,999,999,999'))                    m_extents
  , a.status                                  status
  , b.bytes                                   bytes
  , b.extents                                 extents
  , d.shrinks                                 shrinks
  , d.wraps                                   wraps
  , d.optsize                                 opt
FROM
                gv$instance       i
    INNER JOIN  gv$rollstat       d   ON (i.inst_id      = d.inst_id)
    INNER JOIN  sys.undo$         c   ON (d.usn          = c.us#)
    INNER JOIN  dba_rollback_segs a   ON (a.segment_name = c.name)
    INNER JOIN  dba_segments      b   ON (a.segment_name = b.segment_name)
ORDER BY
    i.instance_name
  , a.segment_name;

