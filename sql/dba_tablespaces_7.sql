-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_tablespaces_7.sql                                           |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on all tablespaces including size and usage. This       |
-- |            script was designed to work with Oracle7 and Oracle8. This      |
-- |            script can be run against higher database versions (i.e.        |
-- |            Oracle8i) but will not return information about true TEMPORARY  |
-- |             tablespaces. (i.e. use of "tempfiles")                         |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespaces                                                 |
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

COLUMN tablespace  FORMAT a30                HEADING 'Tablespace Name'
COLUMN dummy       NOPRINT
COLUMN bytes       FORMAT 9,999,999,999,999  HEADING 'Tablespace Size'
COLUMN used        FORMAT 9,999,999,999,999  HEADING 'Used (in bytes)'
COLUMN free        FORMAT 9,999,999,999,999  HEADING 'Free (in bytes)'
COLUMN pct_used    FORMAT 999                HEADING 'Pct. Used'

BREAK ON report

COMPUTE avg OF pct_used ON report
COMPUTE sum OF bytes    ON report
COMPUTE sum OF used     ON report
COMPUTE sum OF free     ON report

SELECT
    b.tablespace_name                                               tablespace
  , a.tablespace_name                                               dummy
  , SUM(b.bytes)/COUNT(DISTINCT a.file_id||'.'||a.block_id )        bytes
  , NVL(SUM(b.bytes)/COUNT(DISTINCT a.file_id||'.'||a.block_id ) -
        SUM(a.bytes)/COUNT(DISTINCT b.file_id ),
        SUM(b.bytes)/COUNT(DISTINCT a.file_id||'.'||a.block_id ))   used
  , NVL(SUM(a.bytes)/COUNT(DISTINCT b.file_id ),0)                  free
  , NVL(TRUNC(CEIL(100 * ( (SUM(b.bytes)/COUNT(DISTINCT a.file_id||'.'||a.block_id )) -
                  (SUM(a.bytes)/COUNT(DISTINCT b.file_id ) )) /
                  (SUM(b.bytes)/COUNT(DISTINCT a.file_id||'.'||a.block_id )))),100)  pct_used
FROM
    sys.dba_free_space a
  , sys.dba_data_files b
WHERE
    a.tablespace_name (+) = b.tablespace_name
GROUP BY
    a.tablespace_name, b.tablespace_name
/

