-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_invalid_objects_summary.sql                                 |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Provides a summary report of all invalid objects in the         |
-- |            database.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Invalid Objects Summary                                     |
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

COLUMN owner           FORMAT a25             HEADING 'Owner'
COLUMN object_name     FORMAT a30             HEADING 'Object Name'
COLUMN object_type     FORMAT a20             HEADING 'Object Type'
COLUMN count           FORMAT 999,999,999     HEADING 'Count'

BREAK ON owner SKIP 2 ON REPORT

COMPUTE sum   LABEL "Count: "        OF count ON owner
COMPUTE sum   LABEL "Grand Total: "  OF count ON report

SELECT
    owner
  , object_type
  , count(*) Count
FROM dba_objects
WHERE status <> 'VALID'
GROUP BY owner, object_type
/

