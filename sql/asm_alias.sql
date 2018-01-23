-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : asm_alias.sql                                                   |
-- | CLASS    : Automatic Storage Management                                    |
-- | PURPOSE  : Provide a summary report of all alias definitions contained     |
-- |            within all ASM disk groups.                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ASM Aliases                                                 |
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

COLUMN disk_group_name        FORMAT a25         HEAD 'Disk Group Name'
COLUMN alias_name             FORMAT a50         HEAD 'Alias Name'
COLUMN file_number                               HEAD 'File|Number'
COLUMN file_incarnation                          HEAD 'File|Incarnation'
COLUMN alias_index                               HEAD 'Alias|Index'
COLUMN alias_incarnation                         HEAD 'Alias|Incarnation'
COLUMN parent_index                              HEAD 'Parent|Index'
COLUMN reference_index                           HEAD 'Reference|Index'
COLUMN alias_directory        FORMAT a10         HEAD 'Alias|Directory?'
COLUMN system_created         FORMAT a8          HEAD 'System|Created?'

BREAK ON report ON disk_group_name SKIP 1

SELECT
    g.name               disk_group_name
  , a.name               alias_name
  , a.file_number        file_number
  , a.file_incarnation   file_incarnation
  , a.alias_index        alias_index
  , a.alias_incarnation  alias_incarnation
  , a.parent_index       parent_index
  , a.reference_index    reference_index
  , a.alias_directory    alias_directory
  , a.system_created     system_created
FROM
    v$asm_alias a JOIN v$asm_diskgroup g USING (group_number)
ORDER BY
    g.name
  , a.file_number
/

