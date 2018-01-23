-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_owner_to_tablespace.sql                                     |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Provide a summary report of owner to tablespace for all         |
-- |            segments in the database.                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Owner to Tablespace Report                                  |
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

COLUMN owner           FORMAT a20                  HEADING "Owner"
COLUMN tablespace_name FORMAT a30                  HEADING "Tablespace Name"
COLUMN segment_type    FORMAT a18                  HEADING "Segment Type"
COLUMN bytes           FORMAT 9,999,999,999,999    HEADING "Size (in Bytes)"
COLUMN seg_count       FORMAT 9,999,999,999        HEADING "Segment Count"

BREAK ON report ON owner SKIP 2

COMPUTE sum LABEL ""                OF seg_count bytes ON owner
COMPUTE sum LABEL "Grand Total: "   OF seg_count bytes ON report

SELECT
    owner
  , tablespace_name
  , segment_type
  , sum(bytes)  bytes
  , count(*)    seg_count
FROM
    dba_segments
GROUP BY
    owner
  , tablespace_name
  , segment_type
ORDER BY
    owner
  , tablespace_name
  , segment_type
/

