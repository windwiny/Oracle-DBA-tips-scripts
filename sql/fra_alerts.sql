-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : fra_alerts.sql                                                  |
-- | CLASS    : Flash Recovery Area                                             |
-- | PURPOSE  : Provide a list of alerts regarding the Oracle Flash Recovery    |
-- |            Area.                                                           |
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
PROMPT | Report   : FRA Alerts                                                  |
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

COLUMN object_type        FORMAT a12    HEADING 'Object Type'
COLUMN message_type       FORMAT a13    HEADING 'Message Type'
COLUMN message_level                    HEADING 'Message Level'
COLUMN reason             FORMAT a50    HEADING 'Reason'            WRAP
COLUMN suggested_action   FORMAT a50    HEADING 'Suggested Action'  WRAP

prompt 
prompt The database issues a warning alert when reclaimable space is less than
prompt 15% and a critical alert when relaimable space is less than 3%. To warn
prompt the DBA of this condition, an entry is added to the alert.log and to the
prompt DBA_OUTSTANDING_ALERTS table (used by Enterprise Manager). However, the
prompt database continues to consume space in the Flash Recovery Area until
prompt there is no reclaimable space left. When the Flash Recovery Area is
prompt completely full, the following error will be reported:
prompt
prompt ORA-19809: limit exceeded for recovery files
prompt ORA-19804: cannot reclaim nnnnn bytes disk space from mmmmm limit
prompt
prompt where nnnnn is the number of bytes required and mmmmm is the disk quota
prompt for the Flash Recovery Area.
prompt
prompt The following Error would be reported in the alert.log
prompt ORA-19815: WARNING: db_recovery_file_dest_size of "size of FRA configured"
prompt bytes is 100.00% used, and has 0 remaining bytes available.
prompt 

SELECT
    object_type
  , message_type
  , message_level
  , reason
  , suggested_action
FROM
    dba_outstanding_alerts
/

