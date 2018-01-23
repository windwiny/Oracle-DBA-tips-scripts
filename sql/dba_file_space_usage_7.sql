-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_file_space_usage_7.sql                                      |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on all data file usage. This script was designed to     |
-- |            work with Oracle7 and Oracle8. This script can be run against   |
-- |            higher database versions (i.e. Oracle8i) but will not return    |
-- |            information about true TEMPORARY tablespaces. (i.e. use of      |
-- |            "tempfiles")                                                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : File Usage                                                  |
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

COLUMN bs NEW_VALUE xbs NOPRINT FORMAT a1

COLUMN tablespace  FORMAT a30                 HEADING 'Tablespace Name'
COLUMN filename    FORMAT a55                 HEADING 'Filename'
COLUMN filesize    FORMAT 9,999,999,999,999   HEADING 'File Size'
COLUMN used        FORMAT 9,999,999,999,999   HEADING 'Used (in bytes)'
COLUMN free        FORMAT 9,999,999,999,999   HEADING 'Free (in bytes)'
COLUMN pct_used    FORMAT 999                 HEADING 'Pct. Used'

SET TERMOUT OFF
SELECT value bs FROM v$parameter WHERE name = 'db_block_size';
SET TERMOUT ON

BREAK ON report

COMPUTE avg OF pct_used  ON report
COMPUTE sum OF filesize  ON report
COMPUTE sum OF used      ON report
COMPUTE sum OF free      ON report

SELECT
    DECODE(x.online$,
           1,x.name,
           65537, substr(rpad(x.name,9),1,9)||' (TEMP)',
           substr(rpad(x.name,9),1,9)||' (OFF)')                      tablespace
  , a.file_name                                                        filename
  , ROUND(f.blocks*&xbs)                                               filesize
  , NVL(ROUND(SUM(s.length*&xbs),1),0)                                 used
  , ROUND(((f.blocks*&xbs)) - nvl(sum(s.length*&xbs),0), 1)            free
  , NVL(TRUNC(ROUND(SUM(s.length*&xbs) / (f.blocks*&xbs) * 100, 1)),0) pct_used
FROM
    sys.dba_data_files A
  , sys.uet$ s
  , sys.file$ f
  , sys.ts$ x
WHERE
      x.ts#      = f.ts#
  AND x.online$ IN (1,2,65537)
  AND f.status$ = 2
  AND f.ts#      = s.ts# (+)
  AND f.file#    = s.file# (+)
  AND f.file#    = a.file_id
GROUP BY
    x.name
  , x.online$
  , f.blocks
  , A.file_name
  , a.file_id
/

