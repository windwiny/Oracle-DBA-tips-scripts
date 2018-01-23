-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : fdb_log_files.sql                                               |
-- | CLASS    : Flashback Database                                              |
-- | PURPOSE  : Provide a list of all Flasback log files.                       |
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
PROMPT | Report   : Flashback Database Log Files                                |
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

COLUMN thread#                                              HEADING 'Thread #'
COLUMN sequence#                                            HEADING 'Sequence #'
COLUMN name                     FORMAT a65                  HEADING 'Log File Name'
COLUMN log#                                                 HEADING 'Log #'
COLUMN bytes                    FORMAT 999,999,999,999      HEADING 'Bytes'
COLUMN first_change#                                        HEADING 'First Change #'
COLUMN first_time                                           HEADING 'First Time' JUST RIGHT

BREAK ON thread# SKIP 2

COMPUTE count OF sequence# ON thread#
COMPUTE sum OF bytes ON thread#

SELECT
    thread#
  , sequence#
  , name
  , log#
  , bytes
  , first_change#
  , TO_CHAR(first_time, 'DD-MON-YYYY HH24:MI:SS') first_time
FROM 
    v$flashback_database_logfile
ORDER BY
    thread#
  , sequence#;

