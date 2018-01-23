-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_registry.sql                                                |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Provides summary report on all registered components.           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Database Registry Components                                |
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

COLUMN comp_id    FORMAT a9    HEADING 'Component|ID'
COLUMN comp_name  FORMAT a35   HEADING 'Component|Name'
COLUMN version    FORMAT a13   HEADING 'Version'
COLUMN status     FORMAT a11   HEADING 'Status'
COLUMN modified                HEADING 'Modified'
COLUMN Schema     FORMAT a15   HEADING 'Schema'
COLUMN procedure  FORMAT a45   HEADING 'Procedure'

SELECT
    comp_id
  , comp_name
  , version
  , status
  , modified
  , schema
  , procedure
FROM
    dba_registry
ORDER BY
    comp_id;

