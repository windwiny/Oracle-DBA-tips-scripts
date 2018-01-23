-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : rsrc_plan_status_summary.sql                                    |
-- | CLASS    : Database Resource Manager                                       |
-- | PURPOSE  : List all available resource plans and their status.             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Database Resource Manager - Resource Plan Summary Report    |
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

COLUMN resource_plan_name     FORMAT a30    HEAD 'Resource Plan Name'     JUST left
COLUMN comments               FORMAT a50    HEAD 'Comments'               JUST left WRAP
COLUMN num_plan_directives    FORMAT 999    HEAD '# of Plan|Directives'   JUST left
COLUMN status                 FORMAT a10    HEAD 'Status'                 JUST left
COLUMN mandatory              FORMAT a10    HEAD 'Mandatory?'             JUST left
COLUMN run_status             FORMAT a11    HEAD 'Run|Status'             JUST left

SELECT
    a.plan                       resource_plan_name
  , a.comments                   comments
  , a.num_plan_directives        num_plan_directives
  , a.status                     status
  , a.mandatory                  mandatory
  , DECODE(b.name, a.plan, 'Running', 'Not Running')  run_status
FROM
    dba_rsrc_plans a LEFT OUTER JOIN v$rsrc_plan b ON (a.plan = b.name)
/

