-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : fra_files.sql                                                   |
-- | CLASS    : Flash Recovery Area                                             |
-- | PURPOSE  : Provide a list of all files in the Flash Recovery Area.         |
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
PROMPT | Report   : FRA Files                                                   |
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

COLUMN name       FORMAT a80                  HEADING 'File Name'
COLUMN member     FORMAT a80                  HEADING 'File Name'
COLUMN handle     FORMAT a80                  HEADING 'File Name'
COLUMN bytes      FORMAT 999,999,999,999,999  HEADING 'File Size (Bytes)'

SELECT    name, (blocks*block_size) bytes
FROM      v$datafile_copy
WHERE     is_recovery_dest_file = 'YES'
UNION
SELECT    name, null
FROM      v$controlfile
WHERE     is_recovery_dest_file = 'YES'
UNION
SELECT    member, null
FROM      v$logfile
WHERE     is_recovery_dest_file = 'YES'
UNION
SELECT    handle, bytes
FROM      v$backup_piece
WHERE     is_recovery_dest_file = 'YES'
UNION
SELECT    name, (blocks*block_size) bytes
FROM      v$archived_log
WHERE     is_recovery_dest_file = 'YES'
ORDER BY
    1
  , 2
/

