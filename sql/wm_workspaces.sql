-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : wm_workspaces.sql                                               |
-- | CLASS    : Workspace Manager                                               |
-- | PURPOSE  : Identify all workspaces and which workspace is the current      |
-- |            workspace.                                                      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance
FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : All Workspaces                                              |
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

COLUMN current_workspace  FORMAT a10        HEADING "Current|Workspace"
COLUMN owner              FORMAT a20        HEADING "Workspace|Owner"
COLUMN workspace          FORMAT a30        HEADING "Workspace|Name"
COLUMN parent_workspace   FORMAT a30        HEADING "Parent|Workspace"
COLUMN createtime         FORMAT a20        HEADING "Create|Time"
COLUMN freeze_status      FORMAT a8         HEADING "Freeze|Status"
COLUMN freeze_mode        FORMAT a20        HEADING "Freeze|Mode"
COLUMN ver_tables         FORMAT a50        HEADING "All Current Versioned Tables"

SELECT
    CASE  WHEN dbms_wm.getworkspace = workspace THEN '    *'
          ELSE null
    END AS current_workspace
  , owner
  , workspace
  , parent_workspace
  , TO_CHAR(createtime, 'DD-MON-YYYY HH24:MI:SS') createtime
  , freeze_status
  , freeze_mode
FROM
    dba_workspaces
ORDER BY
    owner
  , workspace;

SELECT
    owner || '.' || table_name AS ver_tables
FROM
    wmsys.wm$versioned_tables
UNION ALL
SELECT
    'No versioned tables found'
FROM
    dual
WHERE NOT EXISTS ( SELECT owner, table_name
                   FROM wmsys.wm$versioned_tables)
ORDER BY 1;

