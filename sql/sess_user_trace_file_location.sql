-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sess_user_trace_file_location.sql                               |
-- | CLASS    : Session Management                                              |
-- | PURPOSE  : Oracle writes TRACE to the directory based on the value of your |
-- |            "user_dump_dest" parameter in init.ora file. The trace files    |
-- |            use the "System Process ID" as part of the file name to ensure  |
-- |            a unique file for each user session. The following query helps  |
-- |            the DBA to determine where the TRACE files will be written and  |
-- |            the name of the file it would create for its particular         |
-- |            session.                                                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : User Session Trace File Location                            |
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

COLUMN "Trace File Path" FORMAT a80 HEADING 'Your trace file with path is:'

SELECT
    a.trace_path || ' > ' || b.trace_file "Trace File Path"
FROM
    (  SELECT value trace_path 
       FROM   v$parameter 
       WHERE  name='user_dump_dest'
    ) a
  , (  SELECT c.instance || '_ora_' || spid ||'.trc' TRACE_FILE 
       FROM   v$process,
              (select lower(instance_name) instance from v$instance)  c
       WHERE  addr = ( SELECT paddr 
                       FROM v$session 
                       WHERE (audsid, sid) = (  SELECT
                                                    sys_context('USERENV', 'SESSIONID')
                                                  , sys_context('USERENV', 'SID') 
                                                FROM dual
                                              )
                     )
    ) b
/

