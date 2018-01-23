-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_query_sql.sql                                              |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : Displays the SQL being run by a given session given the SID.    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : SQL Query Search Interface                                  |
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

COLUMN sid                FORMAT 999999     HEADING 'SID'
COLUMN serial_id          FORMAT 99999999   HEADING 'Serial ID'
COLUMN session_status     FORMAT a9         HEADING 'Status'
COLUMN oracle_username    FORMAT a18        HEADING 'Oracle User'
COLUMN os_username        FORMAT a18        HEADING 'O/S User'
COLUMN os_pid             FORMAT a8         HEADING 'O/S PID'
COLUMN session_program    FORMAT a40        HEADING 'Session Program'  TRUNC

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Listing all User Sessions                                              |
PROMPT +------------------------------------------------------------------------+

SELECT
    s.sid           sid
  , s.serial#       serial_id
  , s.status        session_status
  , s.username      oracle_username
  , s.osuser        os_username
  , p.spid          os_pid
  , s.program       session_program
FROM 
    v$process p
  , v$session s
WHERE
    p.addr (+) = s.paddr
ORDER BY
    sid
/


REM +----------------------------------------------------+
REM | PROMPT USER FOR ORACLE SID.                        |
REM +----------------------------------------------------+

PROMPT 
ACCEPT ora_sid CHAR PROMPT 'Enter Oracle SID: '

COLUMN sql_text FORMAT a80

SELECT
    a.sql_text
FROM
    v$sqlarea a
  , v$session s
WHERE
      a.address = s.sql_address
  AND s.sid = &&ora_sid
/

