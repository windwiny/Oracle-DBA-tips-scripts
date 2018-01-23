-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_uncommited_transactions.sql                                |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : Query all users with uncommited transactions.                   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Uncommited Transactions                                     |
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

COLUMN sid                      FORMAT 999999           HEADING 'SID'
COLUMN serial_id                FORMAT 99999999         HEADING 'Serial ID'
COLUMN session_status           FORMAT a9               HEADING 'Status'
COLUMN oracle_username          FORMAT a18              HEADING 'Oracle User'
COLUMN os_username              FORMAT a18              HEADING 'O/S User'
COLUMN os_pid                   FORMAT a8               HEADING 'O/S PID'
COLUMN session_program          FORMAT a30              HEADING 'Session Program'  TRUNC
COLUMN session_machine          FORMAT a30              HEADING 'Machine'          TRUNC
COLUMN number_of_undo_records   FORMAT 999,999,999,999  HEADING "# Undo Records"
COLUMN used_undo_size           FORMAT     999,999,999  HEADING  "Used Undo (MB)"

SELECT
    s.sid                               sid
  , s.status                            session_status
  , s.username                          oracle_username
  , s.osuser                            os_username
  , p.spid                              os_pid
  , b.used_urec                         number_of_undo_records
  , (b.used_ublk * d.value)/1024/1024   used_undo_size
  , s.program                           session_program
  , s.machine                           session_machine
FROM
    v$process      p
  , v$session      s
  , v$transaction  b
  , v$parameter    d
WHERE
      b.ses_addr =  s.saddr
  AND p.addr (+) =  s.paddr
  AND s.audsid   <> userenv('SESSIONID')
  AND d.name     =  'db_block_size';

