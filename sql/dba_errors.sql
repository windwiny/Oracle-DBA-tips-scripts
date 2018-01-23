-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_errors.sql                                                  |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Report on all procedural (PL/SQL, Views, Triggers, etc.) errors.|
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : All Procedural (PL/SQL, Views, Triggers, etc.) Errors       |
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

COLUMN type                 FORMAT a15      HEAD 'Object Type'
COLUMN owner                FORMAT a17      HEAD 'Schema'
COLUMN name                 FORMAT a30      HEAD 'Object Name'
COLUMN sequence             FORMAT 999,999  HEAD 'Sequence'
COLUMN line                 FORMAT 999,999  HEAD 'Line'
COLUMN position             FORMAT 999,999  HEAD 'Position'
COLUMN text                                 HEAD 'Text'

SELECT
    type
  , owner
  , name
  , sequence
  , line
  , position
  , text || chr(10) || chr(10) text
FROM
    dba_errors
ORDER BY
    1, 2, 3
/

