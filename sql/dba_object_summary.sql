-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_object_summary.sql                                          |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Provide a summary report of all objects in the database.        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Object Summary                                              |
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

COLUMN owner           FORMAT A20               HEADING "Owner"
COLUMN object_type     FORMAT A25               HEADING "Object Type"
COLUMN obj_count       FORMAT 999,999,999,999   HEADING "Object Count"

BREAK ON report ON owner SKIP 2

COMPUTE sum LABEL ""               OF obj_count ON owner
COMPUTE sum LABEL "Grand Total: "  OF obj_count ON report

SELECT
    owner
  , object_type
  , count(*)    obj_count
FROM
    dba_objects
GROUP BY
    owner
  , object_type
ORDER BY
    owner
  , object_type
/

