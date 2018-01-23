-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_current_user_transactions.sql                              |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : List table locking and current user transactions information.   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : User Transactions                                           |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    256
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN sid                FORMAT 999999     HEADING 'SID'
COLUMN serial_id          FORMAT 99999999   HEADING 'Serial ID'
COLUMN oracle_username    FORMAT a18        HEADING 'Oracle User'
COLUMN logon_time         FORMAT a18        HEADING 'Login Time'
COLUMN owner              FORMAT a20        HEADING 'Owner'
COLUMN object_type        FORMAT a11        HEADING 'Object Type'
COLUMN object_name        FORMAT a25        HEADING 'Object Name'
COLUMN locked_mode        FORMAT a11        HEADING 'Locked Mode'

prompt 
prompt +----------------------------------------------------+
prompt | Table Locking Information                          |
prompt +----------------------------------------------------+

SELECT
    a.session_id                    sid
  , c.serial#                       serial_id
  , a.oracle_username               oracle_username
  , TO_CHAR(
      c.logon_time,'mm/dd/yy hh24:mi:ss'
    )                               logon_time
  , b.owner                         owner
  , b.object_type                   object_type
  , b.object_name                   object_name
  , DECODE(
        a.locked_mode
      , 0, 'None'
      , 1, 'Null'
      , 2, 'Row-S'
      , 3, 'Row-X'
      , 4, 'Share'
      , 5, 'S/Row-X'
      , 6, 'Exclusive'
    )                               locked_mode
FROM
    v$locked_object a
  , dba_objects b
  , v$session c
WHERE
      a.object_id  = b.object_id
  AND a.session_id = c.sid
ORDER BY
    b.owner
  , b.object_type
  , b.object_name
/


prompt 
prompt +----------------------------------------------------+
prompt | User Transactions Information                      |
prompt +----------------------------------------------------+


COLUMN sid                      FORMAT 999999           HEADING 'SID'
COLUMN serial_id                FORMAT 99999999         HEADING 'Serial ID'
COLUMN session_status           FORMAT a9               HEADING 'Status'
COLUMN oracle_username          FORMAT a18              HEADING 'Oracle User'
COLUMN os_username              FORMAT a18              HEADING 'O/S User'
COLUMN os_pid                   FORMAT a8               HEADING 'O/S PID'
COLUMN trnx_start_time          FORMAT a18              HEADING 'Trnx Start Time'
COLUMN current_time             FORMAT a18              HEADING 'Current Time'
COLUMN elapsed_time             FORMAT 999999999.99     HEADING 'Elapsed(mins)'
COLUMN undo_name                FORMAT a10              HEADING 'Undo Name'             TRUNC
COLUMN number_of_undo_records   FORMAT 999,999,999,999  HEADING '# Undo Records'
COLUMN used_undo_blks           FORMAT     999,999,999  HEADING 'Used Undo Blks' 
COLUMN used_undo_size           FORMAT     999,999,999  HEADING 'Used Undo (MB)'
COLUMN logical_io_blks          FORMAT     999,999,999  HEADING 'Logical I/O (Blks)'
COLUMN logical_io_size          FORMAT 999,999,999,999  HEADING 'Logical I/O (MB)' 
COLUMN physical_io_blks         FORMAT     999,999,999  HEADING 'Physical I/O (Blks)'
COLUMN physical_io_size         FORMAT 999,999,999,999  HEADING 'Physical I/O (MB)'
COLUMN session_program          FORMAT a26              HEADING 'Session Program'       TRUNC

SELECT
    s.sid                               sid
  , s.status                            session_status
  , s.username                          oracle_username
  , p.spid                              os_pid
  , TO_CHAR(
        TO_DATE(
            b.start_time
          ,'mm/dd/yy hh24:mi:ss'
        )
        , 'mm/dd/yy hh24:mi:ss'
    )                                   trnx_start_time
  , ROUND(60*24*(sysdate-to_date(b.start_time,'mm/dd/yy hh24:mi:ss')),2)  elapsed_time
  , c.segment_name                      undo_name
  , b.used_urec                         number_of_undo_records
  , (b.used_ublk * d.value)/1024/1024   used_undo_size
  , (b.log_io*d.value)/1024/1024        logical_io_size
  , (b.phy_io*d.value)/1024/1024        physical_io_size
  , s.program                           session_program
FROM
    v$session         s
  , v$transaction     b
  , dba_rollback_segs c
  , v$parameter       d
  , v$process         p
WHERE
      b.ses_addr = s.saddr
  AND b.xidusn   = c.segment_id
  AND d.name     = 'db_block_size'
  AND p.ADDR     = s.PADDR
ORDER BY 1
/

