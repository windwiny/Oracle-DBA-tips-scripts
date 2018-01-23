-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : asm_templates.sql                                               |
-- | CLASS    : Automatic Storage Management                                    |
-- | PURPOSE  : Provide a summary report of all template information for all    |
-- |            ASM disk groups.                                                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ASM Templates                                               |
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

COLUMN disk_group_name        FORMAT a25           HEAD 'Disk Group Name'
COLUMN entry_number           FORMAT 999999        HEAD 'Entry Number'
COLUMN redundancy             FORMAT a12           HEAD 'Redundancy'
COLUMN stripe                 FORMAT a8            HEAD 'Stripe'
COLUMN system                 FORMAT a6            HEAD 'System'
COLUMN template_name          FORMAT a30           HEAD 'Template Name'

BREAK ON report ON disk_group_name SKIP 1

SELECT
    b.name                                           disk_group_name
  , a.entry_number                                   entry_number
  , a.redundancy                                     redundancy
  , a.stripe                                         stripe
  , a.system                                         system
  , a.name                                           template_name
FROM
    v$asm_template a JOIN v$asm_diskgroup b USING (group_number)
ORDER BY
    b.name
  , a.entry_number
/

