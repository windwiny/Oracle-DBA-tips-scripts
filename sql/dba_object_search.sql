-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_object_search.sql                                           |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Prompt the user for a query string and look for any object that |
-- |            contains that string.                                           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Object Search Interface                                     |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT schema CHAR PROMPT 'Enter search string (i.e. GE_LINES) : '

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

COLUMN owner           FORMAT A20    HEADING "Owner"
COLUMN object_name     FORMAT A45    HEADING "Object Name"
COLUMN object_type     FORMAT A18    HEADING "Object Type"
COLUMN created                       HEADING "Created"
COLUMN status                        HEADING "Status"

SELECT
    owner
  , object_name
  , object_type
  , TO_CHAR(created, 'DD-MON-YYYY HH24:MI:SS') created
  , LPAD(status, 7) status
FROM all_objects
WHERE object_name like UPPER('%&schema%')
ORDER BY owner, object_name, object_type
/

